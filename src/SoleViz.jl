module SoleViz

using Reexport
using SoleBase
using SoleData
using Statistics
using DataFrames
using DataStructures
@reexport using Plots
using SimpleCaching

export plotdescription

include("dataset/utils.jl")
include("dataset/descriptors.jl")

end
