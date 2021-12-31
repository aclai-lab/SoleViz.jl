module SoleViz

using Reexport
using SoleBase
using Statistics
using DataStructures
@reexport using Plots

export plotdescription

include("dataset/utils.jl")
include("dataset/descriptors.jl")

end
