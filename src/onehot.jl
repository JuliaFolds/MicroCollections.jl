"""
    OneHotArray(index => value, shape) -> array::AbstractArray

Create an `array` such that `isequal(array[index], value)`.  The values at
indices other than `index` are undefined.

Currently, this array type is likely only useful as the second argument to
`BangBang.Extras.broadcast_inplace!!` and as the input argument to FLoops.jl's 
`@reduce`

# Examples
```jldoctest
julia> using MicroCollections, BangBang.Extras

julia> broadcast_inplace!!(+, ones(Int64, 4), OneHotVector(2 => 3, 4))
4-element Vector{Int64}:
 1
 4
 1
 1

julia> using InitialValues

julia> broadcast_inplace!!(+, InitialValue(+), OneHotVector(2 => 3, 4))
4-element Vector{Int64}:
 0
 3
 0
 0
```
"""
OneHotArray

using BangBang: BangBang, setindex!!
using InitialValues: GenericInitialValue

struct OneHotArray{T,N,Index<:Tuple,Value} <: AbstractArray{T,N}
    index::Index
    value::Value
    shape::NTuple{N,Int}

    global _OneHotArray
    @inline _OneHotArray(
        ::Type{T},
        index::Index,
        value::Value,
        shape::NTuple{N,Int},
    ) where {T,N,Index,Value} = new{T,N,Index,Value}(index, value, shape)
end

const OneHotVector{T,Index<:Tuple,Value} = OneHotArray{T,1,Index,Value}
const OneHotMatrix{T,Index<:Tuple,Value} = OneHotArray{T,2,Index,Value}

indexof(oh::OneHotArray) = oh.index
valueof(oh::OneHotArray) = oh.value

const DimsLike = Union{Tuple{Vararg{Integer}},Integer}

astuple(index) = (index,)
astuple(index::Tuple) = index

@inline function OneHotArray{T}(index_value::Pair, shape::DimsLike) where {T}
    index = astuple(first(index_value))
    value = last(index_value)
    array = _OneHotArray(T, index, value, astuple(shape))
    @boundscheck checkbounds(array, index...)
    return array
end

@inline OneHotArray(index_value::Pair, shape::DimsLike) =
    OneHotArray{typeof(last(index_value))}(index_value, shape)

@inline OneHotArray{T,N}(index_value::Pair, shape::NTuple{N,<:Integer}) where {T,N} =
    OneHotArray{T}(index_value, shape)::OneHotArray{T,N}

@inline OneHotArray{<:Any,N}(index_value::Pair{<:Any,T}, shape::DimsLike) where {N,T} =
    OneHotArray(index_value, astuple(shape))::OneHotArray{<:Any,N}

@inline OneHotVector{T}(index_value::Pair, length::Integer) where {T,N} =
    OneHotArray{T}(index_value, (length,))::OneHotArray{T,N}

Base.size(A::OneHotArray) = A.shape

@inline function Base.getindex(A::OneHotArray{<:Any,N}, I::Vararg{Int,N}) where {N}
    index::NTuple{N,Int} = to_indices(A, A.index)
    if I == index
        return A.value
    else
        throw(UndefRefError())
    end
end

commonsize(a::OneHotArray) = size(a)
Base.@propagate_inbounds function commonsize(a::OneHotArray, b::OneHotArray, rest...)
    @boundscheck if size(a) != size(b)
        error("incompatible size: size(a) = ", size(a), " size(b) = ", size(b))
    end
    commonsize(a, rest...)
    return size(a)
end

Base.@propagate_inbounds function BangBang.Extras.broadcast_inplace!!(
    f,
    inputoutput,
    oh::OneHotArray,
)
    i = indexof(oh)
    v = valueof(oh)
    return setindex!!(inputoutput, f(inputoutput[i...], v), i...)
end

Base.@propagate_inbounds function BangBang.Extras.broadcast_inplace!!(
    op::OP,
    ::GenericInitialValue{OP},
    oh::OneHotArray,
    rest::OneHotArray...,
) where {OP}
    T = mapfoldl(eltype, promote_type, rest; init = eltype(oh))
    output = fill(Base.reduce_empty(op, T), commonsize(oh, rest...))
    output[indexof(oh)...] = valueof(oh)
    for oh in rest  # TODO: unroll?
        output[indexof(oh)...] = valueof(oh)
    end
    return output
end
