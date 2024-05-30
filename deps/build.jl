import CxxWrap
import Libdl
import Conda

const CXXWRAP_PREFIX = CxxWrap.prefix_path()
const JL_SHARE = joinpath(Sys.BINDIR, Base.DATAROOTDIR, "julia")
const JULIA = joinpath(Sys.BINDIR, "julia")
const libname="libjlROOT2." * Libdl.dlext

const required_root_version="6.30.04"

used_root_version = ""
root_libdir = ""
root_bindir = ""
rootconfig = "root-config"

#function version_decode(version_label)
#    nums = split(version_label, ".")
#    if length(nums) < 3
#        error("Error in ROOT version check. Unrecognized version label $version_label")
#    end
#    nums
#end

if isfile(libname)
    @info "Library " * libname * " found. Nothing to build."
    exit(0)
end

#Test root installation
try
    global used_root_version = readchomp(`$rootconfig --version`)
    global rootlibdir = readchomp(`$rootconfig --libdir`)
    global root_found = true
catch
    global root_found = false
end

#vnums_used=version_decode(used_root_version)
#vnums_required=version_decode(required_root_version)

found_root_ok = root_found && used_root_version == required_root_version

if found_root_ok
    @info "ROOT libraries from $root_libdir will be used."
else
    if !root_found
        @info "Executable root-config not found. We will try to install ROOT from conda-forge."
    elseif !found_root_ok
        @info "Release of the found root installation is not compatible. Release " * required_root_version * " required.  We will try to install root from conda-forge."
    end
    try
        cmd=:(Conda.add("root=$required_root_version", args=`--strict-channel-priority --override-channels -c conda-forge`, satisfied_skip_solve=true))
        @info "Conda command: $cmd"
        eval(cmd)
        global rootlibdir = Conda.LIBDIR
        global rootconfig = joinpath(Conda.BINDIR, "root-config")
        global found_root_ok = true
    catch
        @error "Failed to install ROOT release $required_root_version from conda-forge. Check you network connection or install ROOT yourself and restart julia with the path to the ROOT executables included in the shell exectable path list (PATH)."
        #no-op
    end
end

found_root_ok || exit(1)

cmd=`make CXXWRAP_PREFIX="$CXXWRAP_PREFIX" JL_SHARE="$JL_SHARE" JULIA="$JULIA" ROOT_CONFIG="$rootconfig" -j $(Sys.CPU_THREADS)`
@info "Build command: " * string(cmd)[2:end-1] * " executed in " * pwd() * " directory."

#julia needs to be in the PATH for julia-config.jl, invoked by the Makefile, to run
PATH=Sys.BINDIR * ":" * ENV["PATH"]

build_rc = run(Cmd(cmd, env = ["PATH" => PATH], ignorestatus=true)).exitcode
try
    run(`make clean`)
catch
    @warn "Failed to clean-up directory after dependency build."
end

if build_rc == 0
    rootbindir = readchomp(`$rootconfig --bindir`)
    open("deps.jl", "w") do f
        println(f, "const rootlibdir = \"", rootlibdir, "\"")
        println(f, "const rootbindir = \"", rootbindir, "\"")
    end
end

exit(build_rc)
