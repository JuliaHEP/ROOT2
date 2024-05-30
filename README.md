# ROOT2

## Introduction

ROOT2 is a Julia interface to the C++ [ROOT Data analysis framework](https://root.cern/) used in the high energy physics community.

It is a work-in-progress package covering a limited set of ROOT classes. It targets persons used to the ROOT framework and wishing to access it from Julia.

Function documentation for the Julia help command is not yet available. Please refer to the [C++ ROOT reference guide](https://root.cern/doc/master/) for API documentation.

ROOT2 uses [CxxWrap](https://github.com/JuliaInterop/CxxWrap.jl) to interface to the C++ libraries and the wrappers were generated using [WrapIt!](https://github.com/grasph/wrapit).

## Installation

```
import Pkg
Pkg.add("ROOT2")
```

⚠️  Installation or first import may take a while due to code compilation.

## ROOT version

Current ROOT2 version uses ROOT release 6.30.04. If a ROOT installation is found in the default binary search paths (PATH environment variable) with this version then it will be used. Otherwise, ROOT will be installed using [Conda](https://github.com/JuliaPy/Conda.jl) into `$HOME/.julia/Conda/3`.

## C++ / Julia mapping and symbol export

C++ classes are mapped to Julia struct with the same name. Non-static class methods are mapped to julia methods, with the same name, taking the class instance as first argument followed by the arguments of the C++ methods. The double column `::` used for C++ namespace and for static fields in C++ is mapped to the ! symbol: static function `f` of class `A`, `A::f()` becomes `A!f()` in Julia.

Non-static methods of C++ classes are exported, the other symbols (classes, global functions, etc) are not.

## Use Example

### Short demo

```julia
import ROOT2

ROOT2.demo()
```

### Simple example

```julia

#Import the module.
# The iROOT module is required for interactive graphic display
# Loading the package trigger a loop that process ROOT graphic events.
using ROOT2

# An alias for ROOT2
const R = ROOT2

# Create a ROOT histogram, fill it with random events, and fit it.
h = R.TH1D("h", "Normal distribution", 100, -5., 5.)
R.FillRandom(h, "gaus")

#Draw the histogram on screen
c = R.TCanvas()
R.Draw(h)

#Fit the histogram wih a normal distribution
R.Fit(h, "gaus")

#Save the Canvas in an image file
R.SaveAs(c, "demo_ROOT.png")

#Save the histogram and the graphic canvas in the demo_ROOT_out.root file.
f = R.TFile!Open("demo_ROOT_out.root", "RECREATE")
R.Write(h)
R.Write(c)
Close(f)
```

### More examples

More examples can be found in the `examples` directory.

## Supported ROOT classes

### Principal supported ROOT classes:

  - `TSystem`
  - `TROOT`
  - `TTree`
  - `TBranch`
  - `TCanvas`
  - `TH1`
  - `TRandom`
  - `TAxis`
  - `TGraph`
  - `TF1`
  - `TApplication`
  - `TFile`, `TDirectoryFile`
  - `TTreeReader`, `TTreeReaderValue`, `TTreeReaderArray`
  - `TVectorD`, `TVectorF`
  - `TObject`, `TNamed`

### Complete list of suppported ROOT class and types

   - CpuInfo_t
   - FileStat_t
   - Foption_t
   - _IO_FILE
   - MemInfo_t
   - ProcInfo_t
   - RedirectHandle_t
   - ROOT::Internal::GetFunctorType
   - ROOT::Internal::TF1Builder
   - ROOT::Internal::TParBranchProcessingRAII
   - ROOT::Internal::TStringView
   - ROOT::Internal::TTreeReaderArrayBase
   - ROOT::Internal::TTreeReaderValueBase
   - ROOT::TIOFeatures
   - SysInfo_t
   - TApplication
   - TApplicationImp
   - TArrayC
   - TArrayD
   - TAxis
   - TBranch
   - TBranchPtr
   - TBuffer
   - TCanvas
   - TClass
   - TCollection
   - TDataType
   - TDatime
   - TDictionary
   - TDirectory
   - TDirectoryFile
   - TEntryList
   - TF1
   - TF1Parameters
   - TF1::TF1FunctorPointer
   - TFile
   - TFileHandler
   - TFileOpenHandle
   - TFitResultPtr
   - TFormula
   - TGraph
   - TH1
   - TH1C
   - TH1D
   - TH1F
   - TH1I
   - TH1S
   - TInetAddress
   - TInterpreter
   - TIterator
   - TLeaf
   - TList
   - TMethodCall
   - TNamed
   - TObjArray
   - TObject
   - TObjLink
   - TPad
   - TProcessEventTimer
   - TRandom
   - TROOT
   - TSeqCollection
   - TSignalHandler
   - TStdExceptionHandler
   - TStreamerInfo
   - TString
   - TSystem
   - TTime
   - TTimer
   - TTreeFriendLeafIter
   - TTreeReader
   - TTreeReaderArray
   - TTreeReader::Iterator_t
   - TTreeReaderValue
   - TTree, TTree::TClusterIterator
   - TUrl
   - TVectorT
   - TVirtualMutex
   - TVirtualPad
   - TVirtualTreePlayer
   - UserGroup_t
