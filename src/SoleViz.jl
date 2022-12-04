module SoleViz

using Reexport
using SoleBase
using SoleData
using Statistics
using DataStructures
@reexport using Plots

export plotdescription

include("dataset/descriptors.jl")

end
