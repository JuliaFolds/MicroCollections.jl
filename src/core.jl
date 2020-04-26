"""
    emptyshim(ContainerType)
    emptyshim(ContainerType, ElementType)

Create an empty "shim" container that is widen to `ContainerType` when
appending elements to it.  Default `ElementType` is `Union{}`.

# Examples
```jldoctest
julia> using MicroCollections, BangBang

julia> @assert append!!(emptyshim(Vector), [0]) == [0]

julia> @assert merge!!(emptyshim(Dict), Dict(:a => 1)) == Dict(:a => 1)

julia> @assert union!!(emptyshim(Set), Set([0])) == Set([0])
```
"""
emptyshim

"""
    singletonshim(ContainerType, x)

Create a "shim" container with one element `x` that is widen to
`ContainerType` when appending elements to it.

# Examples
```jldoctest
julia> using MicroCollections, BangBang

julia> @assert push!!(singletonshim(BitVector, false), true)::BitArray == [false, true]
```
"""
singletonshim

emptyshim(T) = emptyshim(T, Union{})

"""
    vec0(T::Type = Union{})

Create an empty vector shim of element type `T`.
"""
vec0

"""
    vec1(x)

Create a singleton vector with element `x`.
"""
vec1

"""
    dict0(T::Type = Pair{Union{},Union{}})

Create an empty dict shim of element type `T`.
"""
dict0

"""
    dict1(k => v)

Create a singleton dict with key `k` and value `v`.
"""
dict1

"""
    set0(T::Type = Union{})

Create an empty set shim of element type `T`.
"""
set0

"""
    set1(x)

Create a singleton set with element `x`.
"""
set1

vec0() = emptyshim(Vector, Union{})
vec0(::Type{T}) where {T} = emptyshim(Vector, T)
vec1(x) = singletonshim(Vector, x)

dict0() = emptyshim(Dict)
dict0(::Type{T}) where {T} = emptyshim(Dict, T)
dict1(x) = singletonshim(Dict, x)

set0() = emptyshim(Set)
set0(::Type{T}) where {T} = emptyshim(Set, T)
set1(x) = singletonshim(Set, x)

"""
    MicroCollections.upcast(singleton_container::C) -> container::C
"""
upcast

# utils
function validate_empty_iterator(itr, container_name)
    y = iterate(itr)
    y === nothing || throw(ArgumentError(string(
        "Given iterator is not empty. ",
        "`$container_name` expects an empty iterator.",
    )))
end

function validate_singleton_iterator(itr, container_name)
    y = iterate(itr)
    y === nothing && throw(ArgumentError(string(
        "Given iterator is empty. ",
        "`$container_name` requires an iterator of length 1.",
    )))
    x, state = y
    y = iterate(itr, state)
    y === nothing || throw(ArgumentError(string(
        "Given iterator has more than one element. ",
        "`$container_name` requires an iterator of length 1.",
    )))
    return x
end

function safe_length(x)
    if Base.IteratorSize(x) isa Union{Base.HasLength,Base.HasShape}
        return length(x)
    else
        return nothing
    end
end
