module ROOT2

import Base.getindex
import Base.setindex!

import Libdl
import Pkg
using CxxWrap

if !isfile("$(@__DIR__)/../deps/libjlROOT2." * Libdl.dlext)
    Pkg.build("ROOT2", verbose=true)
end

include("$(@__DIR__)/../deps/deps.jl")

@wrapmodule(()->"$(@__DIR__)/../deps/libjlROOT2." * Libdl.dlext)

include("iROOT2.jl")

TF1!kDefault = 0

function __init__()
    saved_path=ENV["PATH"]
    #workaroud to prevent a crash with root installed with Conda linker to
    #the c++ compiler called by cling to get the include directories and
    #missing in the PATH list. In the Conda install, compiler is same directory as ROOT
    #binaries, rootbindir
    ENV["PATH"] *= ":" * rootbindir
    @initcxx
    ENV["PATH"] = saved_path
    global gROOT = ROOT!GetROOT()
    isinteractive() && _init_event_loop()
end

export gROOT, gSystem
include("ROOT2-export.jl")
export SetAddress

include("ROOT2ex.jl")
include("demo.jl")


end #module
