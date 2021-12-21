module SoleViz

using Reexport
using SoleBase
using Statistics
using DataStructures
@reexport using Plots

export plotdescription
export _preparedescription
export _createdescription

include("dataset/descriptors.jl")

end
