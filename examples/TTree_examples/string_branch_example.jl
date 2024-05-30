using ROOT2
const R = ROOT2

tree = R.TTree("tree", "tree")
br = Branch(tree, "s", Ptr{Nothing}(), "s/C")
s  = "ABC"
GC.@preserve s begin
    SetBranchAddress(tree, "s", convert(Ptr{Int8}, pointer(s)))
    Fill(tree)
end
Scan(tree)
