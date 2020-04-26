"""
    EmptyVector() :: AbstractVector{Union{}}
    EmptyVector(itr) :: AbstractVector
    EmptyVector{T}() :: AbstractVector{T}
    EmptyVector{T}(itr) :: AbstractVector{T}

Create an empty vector.  Iterator `itr` must be empty.

The unary constructors `EmptyVector(itr)` and `EmptyVector{T}(itr)`
asserts that the iterator `itr` is empty.  The constructor
`EmptyVector(itr)` uses `eltype(itr)` if `IteratorEltype(itr)` is
`HasEltype`.
"""
EmptyVector

"""
    SingletonVector(itr) :: AbstractVector
    SingletonVector{T}(itr) :: AbstractVector{T}

Create a singleton vector.  Iterator `itr` must have one and only one
element.

The constructor `SingletonVector(itr)` uses `eltype(itr)` if
`IteratorEltype(itr)` is `HasEltype`.
"""
SingletonVector

abstract type AbstractMicroVector{T,L} <: AbstractVector{T} end
abstract type AbstractEmptyVector{T,L} <: AbstractMicroVector{T,L} end
abstract type AbstractSingletonVector{T,L} <: AbstractMicroVector{T,L} end

struct EmptyVector{T,L} <: AbstractEmptyVector{T,L} end
EmptyVector() = EmptyVector{Union{},Vector}()
EmptyVector{T}() where {T} = EmptyVector{T,Vector}()

struct SingletonVector{T,L} <: AbstractSingletonVector{T,L}
    value::T
end
SingletonVector{T}(x::T) where {T} = SingletonVector{T,Vector}(x)

@inline getvalue(A::SingletonVector) = A.value
@inline upcast(A::AbstractMicroVector{T,L}) where {T,L} = L(A)::AbstractVector{T}

Base.size(::AbstractEmptyVector) = (0,)
Base.IndexStyle(::Type{<:AbstractEmptyVector}) = Base.IndexLinear()
@inline function Base.getindex(A::AbstractEmptyVector, i::Int)
    checkbounds(A, i)
end

Base.size(::AbstractSingletonVector) = (1,)
Base.IndexStyle(::Type{<:AbstractSingletonVector}) = Base.IndexLinear()
@inline function Base.getindex(A::AbstractSingletonVector, i::Int)
    @boundscheck checkbounds(A, i)
    return getvalue(A)
end

emptyshim(::Type{L}, ::Type{T}) where {T,L<:AbstractVector} = EmptyVector{T,L}()
singletonshim(::Type{L}, x::T) where {T,L<:AbstractVector} = SingletonVector{T,L}(x)

function EmptyVector(itr)
    validate_empty_iterator(itr, :EmptyVector)
    if Base.IteratorEltype(itr) isa Base.HasEltype
        return EmptyVector{eltype(itr)}()
    else
        return EmptyVector()
    end
end

function EmptyVector{T}(itr) where {T}
    validate_empty_iterator(itr, :EmptyVector)
    return EmptyVector{T}()
end

function SingletonVector(itr)
    x = validate_singleton_iterator(itr, :SingletonVector)
    if Base.IteratorEltype(itr) isa Base.HasEltype
        return SingletonVector{eltype(itr)}((x,))
    else
        return SingletonVector{typeof(x)}(x)
    end
end

function SingletonVector{T}(itr) where {T}
    x = validate_singleton_iterator(itr, :SingletonVector)
    return SingletonVector{T}((x,))
end

# fast-path:
SingletonVector((x,)::Tuple{T}) where {T} = SingletonVector{T}(x)
SingletonVector{T}((x,)::Tuple{Any}) where {T} = SingletonVector{T}(convert(T, x)::T)

function Base.showarg(io::IO, v::EmptyVector{<:Any,Vector}, toplevel::Bool)
    @nospecialize
    print(io, "EmptyVector")
    toplevel && print(io, '{', eltype(v), '}')
end

function Base.showarg(io::IO, v::SingletonVector{<:Any,Vector}, toplevel::Bool)
    @nospecialize
    print(io, "SingletonVector")
    toplevel && print(io, '{', eltype(v), '}')
end
