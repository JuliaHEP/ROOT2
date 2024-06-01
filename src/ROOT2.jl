module ROOT2

import Base.getindex
import Base.setindex!

import Libdl
import Pkg
using CxxWrap

Sys.iswindows() && error("Windows platform detected. ROOT2 is supported on Linux and MacOS only.")

if !isfile("$(@__DIR__)/../deps/deps.jl")
    error("File '$(@__DIR__)/../deps/deps.jl' missing. This can happen if the ROOT2 package was installed with the Pkg.develop() (or ] dev) command. Run 'import Pkg; Pkg.build(\"ROOT2\", verbose=true)' (or ] build -v ROOT2) to generate the missing file.")
end

include("$(@__DIR__)/../deps/deps.jl")
include_dependency(libpath)

if !isfile(libpath)
    error("File '$libpath' missing. This can happen if the ROOT2 package was installed with the Pkg.develop() (or ] dev) command. Run 'import Pkg; Pkg.build(\"ROOT2\", verbose=true)' (or ] build -v ROOT2) to generate the missing file.")
end

@wrapmodule(()->libpath)

include("iROOT2.jl")

TF1!kDefault = 0

function __init__()
    # Some required environment cleanup before loading the ROOT libraries
    saved_path = ENV["PATH"]
    saved_ld_library_path = get(ENV, "LD_LIBRARY_PATH", nothing)
    saved_dyld_library_path = get(ENV, "DYLD_LIBRARY_PATH", nothing)
    #   Prevent mix-up of root library version is another version than ours is in LD_LIBRARY_PATH:
    isnothing(saved_ld_library_path) || (ENV["LD_LIBRARY_PATH"] = "")
    isnothing(saved_dyld_library_path) || (ENV["DYLD_LIBRARY_PATH"] = "")
    #   Workaroud to prevent a crash with root installed with Conda linker to
    #   the c++ compiler called by cling to get the include directories and
    #   missing in the PATH list. In the Conda install, compiler is same directory as ROOT
    #   binaries, rootbindir
    ENV["PATH"] *= ":" * rootbindir

    @initcxx
    global gROOT = ROOT!GetROOT()

    #Restore the environment:
    ENV["PATH"] = saved_path
    println(">>", saved_ld_library_path)
    isnothing(saved_ld_library_path) || (ENV["LD_LIBRARY_PATH"] = saved_ld_library_path)
    isnothing(saved_dyld_library_path) || (ENV["DYLD_LIBRARY_PATH"] = saved_dyld_library_path)

    isinteractive() && _init_event_loop()
end

export gROOT, gSystem
include("ROOT2-export.jl")
export SetAddress

include("ROOT2ex.jl")
include("demo.jl")

end #module
