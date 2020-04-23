"""
    EmptyDict() :: AbstractDict{Union{},Union{}}
    EmptyDict(itr) :: AbstractDict
    EmptyDict{K,V}() :: AbstractDict{K,V}
    EmptyDict{K,V}(itr) :: AbstractDict{K,V}
"""
EmptyDict

"""
    SingletonDict(k => v) :: AbstractDict
    SingletonDict(itr) :: AbstractDict
    SingletonDict{K,V}(k => v) :: AbstractDict{K,V}
    SingletonDict{K,V}(itr) :: AbstractDict{K,V}
"""
SingletonDict

abstract type AbstractMicroDict{K,V,L} <: AbstractDict{K,V} end
abstract type AbstractEmptyDict{K,V,L} <: AbstractMicroDict{K,V,L} end
abstract type AbstractSingletonDict{K,V,L} <: AbstractMicroDict{K,V,L} end

struct EmptyDict{K,V,L} <: AbstractEmptyDict{K,V,L} end
EmptyDict() = EmptyDict{Union{},Union{},Dict}()
EmptyDict{K,V}() where {K,V} = EmptyDict{K,V,Dict}()
EmptyDict(::Type{Pair{K,V}}) where {K,V} = EmptyDict{K,V,Dict}()

struct SingletonDict{K,V,L} <: AbstractSingletonDict{K,V,L}
    k::K
    v::V
end
SingletonDict(kv::Pair{K,V}) where {K,V} = SingletonDict{K,V,Dict}(first(kv), last(kv))
SingletonDict{K,V}((k, v)::Pair) where {K,V} =
    SingletonDict{K,V,Dict}(convert(K, k)::K, convert(V, v)::V)

@inline getvalue(d::SingletonDict) = d.k => d.v

Base.length(::AbstractEmptyDict) = 0
@inline Base.get(::AbstractEmptyDict, _, default) = default
@inline Base.getindex(::AbstractEmptyDict, k) = throw(KeyError(k))
@inline Base.iterate(::AbstractEmptyDict) = nothing

Base.length(::AbstractSingletonDict) = 1
@inline Base.get(d::AbstractSingletonDict, k, default) =
    isequal(first(getvalue(d)), k) ? last(getvalue(d)) : default
@inline function Base.getindex(d::AbstractSingletonDict, k)
    @boundscheck isequal(k, first(getvalue(d))) || throw(KeyError(k))
    return last(getvalue(d))
end
@inline Base.iterate(d::AbstractSingletonDict) = (getvalue(d), nothing)
@inline Base.iterate(d::AbstractSingletonDict, ::Nothing) = nothing

BangBang.merge!!(dest::AbstractMicroDict{K,V,L}, src) where {K,V,L} =
    merge!!(L(dest)::AbstractDict{K,V}, src)

emptyshim(::Type{L}) where {L<:AbstractDict} = EmptyDict{Union{},Union{},L}()
emptyshim(::Type{L}, ::Type{Pair{K,V}}) where {K,V,L<:AbstractDict} = EmptyDict{K,V,L}()
singletonshim(::Type{L}, kv::Pair{K,V}) where {K,V,L<:AbstractDict} =
    SingletonDict{K,V,L}(first(kv), last(kv))

function EmptyDict(itr)
    validate_empty_iterator(itr, :EmptyDict)
    if Base.IteratorEltype(itr) isa Base.HasEltype
        T = eltype(itr)
        if T === Union{}
            return EmptyDict()
        elseif T <: Pair
            return EmptyDict(T)
        end
        throw(ArgumentError("Unexpected `eltype`: `$T`"))
    else
        return EmptyDict()
    end
end

function EmptyDict{K,V}(itr) where {K,V}
    validate_empty_iterator(itr, :EmptyDict)
    return EmptyDict{K,V}()
end

function SingletonDict(itr)
    kv = validate_singleton_iterator(itr, :SingletonDict)
    safe_length(kv) == 2 || throw(ArgumentError(string(
        "Given iterator does not contain a pair. ",
        "`SingletonDict` requires an iterator of exactly one pair.",
    )))
    k, v = kv
    return SingletonDict(k => v)
end

function SingletonDict{K,V}(itr) where {K,V}
    kv = validate_singleton_iterator(itr, :SingletonDict)
    safe_length(kv) == 2 || throw(ArgumentError(string(
        "Given iterator does not contain a pair. ",
        "`SingletonDict` requires an iterator of exactly one pair.",
    )))
    k, v = kv
    return SingletonDict{K,V}(k => v)
end
