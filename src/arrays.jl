"""
    UndefArray(size [, factory])
    UndefArray{T}(size [, factory])
    UndefArray{T,N}(size [, factory])

# Examples
```jldoctest
julia> using MicroCollections

julia> UndefArray((2,))
2-element UndefVector{Union{}}(2):
 #undef
 #undef

julia> UndefArray{Int}((2, 3))
2×3 UndefArray{2,Int64}((2, 3)):
 #undef  #undef  #undef
 #undef  #undef  #undef
```

The size of an `UndefArray` can be "changed" by using
[`Setfield.@set`](https://github.com/jw3126/Setfield.jl)

```jldoctest; setup = :(using MicroCollections)
julia> using Setfield

julia> x = UndefArray((2,))
2-element UndefVector{Union{}}(2):
 #undef
 #undef

julia> @set size(x) = (1, 3)
1×3 UndefArray{2,Union{}}((1, 3)):
 #undef  #undef  #undef
```
"""
UndefArray

"""
    UndefVector(length)

# Examples
```jldoctest
julia> using MicroCollections

julia> UndefVector(3)
3-element UndefVector{Union{}}(3):
 #undef
 #undef
 #undef
```
"""
UndefVector

struct UndefArray{T,N,F} <: AbstractArray{T,N}
    size::NTuple{N,Int}
    factory::F
end

const UndefVector{T,F} = UndefArray{T,1,F}

default_factory(T, size) = Array{T}(undef, size)

UndefArray{T,N}(size::NTuple{N,Int}, factory::F = default_factory) where {T,N,F} =
    UndefArray{T,N,F}(size, factory)
UndefArray{T}(size::Tuple{Vararg{Int}}, factory = default_factory) where {T} =
    UndefArray{T,length(size)}(size, factory)
UndefArray(size::Tuple{Vararg{Int}}, factory = default_factory) =
    UndefArray{Union{}}(size, factory)
UndefArray(size::Int...) = UndefArray(size)

UndefVector{T}(length::Int, factory = default_factory) where {T} =
    UndefArray{T,1}((length,), factory)
UndefVector(length::Int, factory = default_factory) = UndefArray((length,), factory)

UndefArray{T,N}(::Tuple{}, factory::F = default_factory) where {T,N,F} =
    UndefArray{T,N,F}(ntuple(_ -> 0, N), factory)

Base.size(a::UndefArray) = a.size
Base.isassigned(::UndefArray, ::Integer...) = false

Base.similar(a::UndefArray, T::Type, size::Tuple{Vararg{Int}}) = a.factory(T, size)

function Base.showarg(io::IO, x::UndefArray, _toplevel::Bool)
    if ndims(x) == 1
        print(io, "UndefVector{", eltype(x), "}")
    else
        print(io, "UndefArray{", ndims(x), ',', eltype(x), '}')
    end
    print(io, '(')
    if length(x.size) == 1
        show(io, x.size[1])
    else
        show(io, x.size)
    end
    if x.factory !== default_factory
        print(io, ", ")
        show(io, x.factory)
    end
    print(io, ')')
end

function Setfield.set(x::UndefArray, ::typeof(@lens size(_)), dims::Tuple{Vararg{Integer}})
    dims = convert(Tuple{Vararg{Int}}, dims)
    return UndefArray{eltype(x)}(dims, x.factory)
end
