
## descriptors

"""
    _descriptors2grouped(descriptors)

Convert a Vector of descriptors to its grouped version generating singleton groups.
"""
function _descriptors2grouped(descs::AbstractVector{<:AbstractString})
    return Dict{String,Vector{Symbol}}(["$(d)" => [Symbol(d)] for d in descs]...)
end
function _descriptors2grouped(descs::AbstractVector{Symbol})
    return _descriptors2grouped(string.(descs))
end
function _descriptors2grouped(descs::AbstractDict{<:AbstractString,<:AbstractVector{Symbol}})
    return descs
end

"""
    _grouped2descriptors(grouped_descriptors)

Convert a Dict of `grouped_descriptors` to vector of them.
"""
function _grouped2descriptors(grouped::AbstractDict{<:AbstractString,<:AbstractVector{Symbol}})
    result = Symbol[]

    for (group_name, descriptors) in grouped
        for descriptor in descriptors
            push!(result, descriptor)
        end
    end

    return result
end

## windows object

"""
    _nwindows(d)

Get the number of windows `d` contains.

This is the number of `t` values, not the number of windows the dimensional data will be
divided into.
"""
function _nwindows(d::AbstractVector{<:AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}}})
    return length(d)
end
_nwindows(d::AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}}) = 1

"""
    _framedims(d)

Get the dimension of each frame in `d`.
"""
function _framedims(d::AbstractVector{<:NTuple{3,<:Integer}})
    return length(d)
end
function _framedims(d::AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}})
    return [_framedims(frame) for frame in d]
end
function _framedims(d::AbstractVector{<:AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}}})
    return [_framedims(w) for w in d]
end

"""
    _nframes(d)

Get the number of frames in `d`.
"""
function _nframes(d::AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}})
    return length(d)
end
function _nframes(d::AbstractVector{<:AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}}})
    return [_nframes(w) for w in d]
end

"""
    _get_t(d)
"""
function _get_t(d::NTuple{3,<:Integer})
    return d[1]
end
function _get_t(d::AbstractVector{<:NTuple{3,<:Integer}})
    return ([_get_t(dimension) for dimension in d]...,)
end
function _get_t(d::AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}})
    return [_get_t(frame) for frame in d]
end
function _get_t(d::AbstractVector{<:AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}}})
    return [_get_t(w) for w in d]
end

"""
    _get_l(d)
"""
function _get_l(d::NTuple{3,<:Integer})
    return d[2]
end
function _get_l(d::AbstractVector{<:NTuple{3,<:Integer}})
    return ([_get_l(dimension) for dimension in d]...,)
end
function _get_l(d::AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}})
    return [_get_l(frame) for frame in d]
end
function _get_l(d::AbstractVector{<:AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}}})
    return [_get_l(w) for w in d]
end

"""
    _get_r(d)
"""
function _get_r(d::NTuple{3,<:Integer})
    return d[3]
end
function _get_r(d::AbstractVector{<:NTuple{3,<:Integer}})
    return ([_get_r(dimension) for dimension in d]...,)
end
function _get_r(d::AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}})
    return [_get_r(frame) for frame in d]
end
function _get_r(d::AbstractVector{<:AbstractVector{<:AbstractVector{<:NTuple{3,<:Integer}}}})
    return [_get_r(w) for w in d]
end

## MFD description object
# Vector{Vector{DataFrame}}

function _is_description(dfs::AbstractDataFrame)
    return count(eltype.(eachcol(dfs)[2:end]) .<: AbstractArray) == ncol(dfs) - 1
end
function _is_description(dfs::AbstractVector{<:AbstractDataFrame})
    return length(findall(_is_description, dfs)) == length(dfs)
end

function _nwindows(d::AbstractVector{<:AbstractVector{<:AbstractDataFrame}})
    return length(d)
end
function _nwindows(d::AbstractVector{<:AbstractDataFrame})
    return 1
end

const _ndescriptions = _nwindows

function _framedims(d::AbstractArray)
    # NOTE: first dimension of Array is the number of instances
    return length([(s, 0, 0) for s in size(d)[2:end]])
end
function _framedims(d::AbstractVector{<:AbstractArray})
    # NOTE: assumed all arrays have the same dimension
    return length(d) > 0 ? _framedims(d[1]) : []
end
function _framedims(d::AbstractDataFrame)
    @assert _is_description(d) "`d` has to be a MultiFrameDataset description"

    # NOTE: assumed all attributes have same dimension
    return _framedims(d[1,2])
end
function _framedims(d::AbstractVector{<:AbstractDataFrame})
    return [_framedims(frame) for frame in d]
end
function _framedims(d::AbstractVector{<:AbstractVector{<:AbstractDataFrame}})
    return [_framedims(w) for w in d]
end

function _nframes(d::AbstractVector{<:AbstractDataFrame})
    return length(d)
end
function _nframes(d::AbstractVector{<:AbstractVector{<:AbstractDataFrame}})
    return [_nframes(w) for w in d]
end
function _nframes(d::AbstractDataFrame)
    return 1
end

function _get_win(d::AbstractArray)
    # NOTE: first dimension of Array is the number of instances
    return [(s, 0, 0) for s in size(d)[2:end]]
end
function _get_win(d::AbstractVector{<:AbstractArray})
    # NOTE: assumed all arrays have the same dimension
    return length(d) > 0 ? _get_win(d[1]) : []
end
function _get_win(d::AbstractDataFrame)
    @assert _is_description(d) "`d` has to be a MultiFrameDataset description"

    # NOTE: assumed all attributes have same dimension
    return _get_win(d[1,2])
end
function _get_win(d::AbstractVector{<:AbstractDataFrame})
    return [_get_win(frame) for frame in d]
end
function _get_win(d::AbstractVector{<:AbstractVector{<:AbstractDataFrame}})
    return [_get_win(w) for w in d]
end

function _nattributes(d::AbstractDataFrame)
    @assert _is_description(d) "`d` has to be a MultiFrameDataset description"

    return nrow(d)
end
function _nattributes(d::AbstractVector{<:AbstractDataFrame})
    return [_nattributes(frame) for frame in d]
end
function _nattributes(d::AbstractVector{<:AbstractVector{<:AbstractDataFrame}})
    return [_nattributes(description) for description in d]
end

function _attributes(d::AbstractDataFrame)
    @assert _is_description(d) "`d` has to be a MultiFrameDataset description"

    return Symbol.(d[:,1])
end
function _attributes(d::AbstractVector{<:AbstractDataFrame})
    return [_attributes(frame) for frame in d]
end
function _attributes(d::AbstractVector{<:AbstractVector{<:AbstractDataFrame}})
    return [_attributes(description) for description in d]
end

function _ndescriptors(d::AbstractDataFrame)
    @assert _is_description(d) "`d` has to be a MultiFrameDataset description"

    return ncol(d) - 1
end
function _ndescriptors(d::AbstractVector{<:AbstractDataFrame})
    return [_ndescriptors(frame) for frame in d]
end
function _ndescriptors(d::AbstractVector{<:AbstractVector{<:AbstractDataFrame}})
    return [_ndescriptors(description) for description in d]
end

function _descriptors(d::AbstractDataFrame)
    @assert _is_description(d) "`d` has to be a MultiFrameDataset description"

    return Symbol.(names(d)[2:end])
end
function _descriptors(d::AbstractVector{<:AbstractDataFrame})
    return [_descriptors(frame) for frame in d]
end
function _descriptors(d::AbstractVector{<:AbstractVector{<:AbstractDataFrame}})
    return [_descriptors(description) for description in d]
end
