module SoleViz

using Reexport
using SoleBase
using Statistics
using DataStructures
@reexport using Plots
using SimpleCaching
# `add https://github.com/ferdiu/SimpleCaching.jl`

export plotdescription

include("dataset/utils.jl")
include("dataset/descriptors.jl")

end
