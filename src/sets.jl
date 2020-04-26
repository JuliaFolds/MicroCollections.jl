"""
    EmptySet() :: AbstractSet{Union{}}
    EmptySet{T}() :: AbstractSet{T}
"""
EmptySet

"""
    SingletonSet(itr) :: AbstractSet
    SingletonSet{T}(itr) :: AbstractSet{T}
"""
SingletonSet

abstract type AbstractMicroSet{T,L} <: AbstractSet{T} end
abstract type AbstractEmptySet{T,L} <: AbstractMicroSet{T,L} end
abstract type AbstractSingletonSet{T,L} <: AbstractMicroSet{T,L} end

struct EmptySet{T,L} <: AbstractEmptySet{T,L} end
EmptySet() = EmptySet{Union{},Set}()
EmptySet{T}() where {T} = EmptySet{T,Set}()

struct SingletonSet{T,L} <: AbstractSingletonSet{T,L}
    value::T
end
SingletonSet{T}(x::T) where {T} = SingletonSet{T,Set}(x)

@inline getvalue(A::SingletonSet) = A.value
@inline upcast(A::AbstractMicroSet{T,L}) where {T,L} = L(A)::AbstractSet{T}

Base.length(::AbstractEmptySet) = 0
@inline Base.iterate(::AbstractEmptySet) = nothing

Base.length(::AbstractSingletonSet) = 1
@inline Base.iterate(A::AbstractSingletonSet) = (getvalue(A), nothing)
@inline Base.iterate(A::AbstractSingletonSet, ::Nothing) = nothing

emptyshim(::Type{L}, ::Type{T}) where {T,L<:AbstractSet} = EmptySet{T,L}()
singletonshim(::Type{L}, x::T) where {T,L<:AbstractSet} = SingletonSet{T,L}(x)

function EmptySet(itr)
    validate_empty_iterator(itr, :EmptySet)
    if Base.IteratorEltype(itr) isa Base.HasEltype
        return EmptySet{eltype(itr)}()
    else
        return EmptySet()
    end
end

function EmptySet{T}(itr) where {T}
    validate_empty_iterator(itr, :EmptySet)
    return EmptySet{T}()
end

function SingletonSet(itr)
    x = validate_singleton_iterator(itr, :SingletonSet)
    if Base.IteratorEltype(itr) isa Base.HasEltype
        return SingletonSet{eltype(itr)}((x,))
    else
        return SingletonSet{typeof(x)}(x)
    end
end

function SingletonSet{T}(itr) where {T}
    x = validate_singleton_iterator(itr, :SingletonSet)
    return SingletonSet{T}((x,))
end

# fast-path:
SingletonSet((x,)::Tuple{T}) where {T} = SingletonSet{T}(x)
SingletonSet{T}((x,)::Tuple{Any}) where {T} = SingletonSet{T}(convert(T, x)::T)
