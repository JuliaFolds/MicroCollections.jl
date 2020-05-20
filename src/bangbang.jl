module BangBangImpl

# TODO: Let BangBang depend on MicroCollections.
using BangBang: BangBang, append!!, push!!, setindex!!, union!!
using BangBang.Experimental: mergewith!!

using ..MicroCollections:
    AbstractMicroDict,
    AbstractMicroSet,
    AbstractMicroVector,
    SingletonVector,
    UndefArray,
    upcast

BangBang.append!!(A::AbstractMicroVector, B::AbstractVector) = append!!(upcast(A), B)
# TODO: Avoid allocating array twice if `upcast(A)` is going to be
# widen anyway.

BangBang.push!!(A::AbstractMicroVector, x) = append!!(A, SingletonVector((x,)))

struct _NoValue end

function BangBang.Experimental.mergewith!!(combine, dict::AbstractMicroDict, other)
    udict = foldl(push!!, pairs(other), init = upcast(dict))
    if length(dict) == 0
        return udict
    else
        k, v = first(dict)
        vo = get(other, k, _NoValue())
        if vo isa _NoValue
            return udict
        else
            return setindex!!(udict, combine(v, vo), k)
        end
    end
end

BangBang.setindex!!(dict::AbstractMicroDict, v, k) = setindex!!(upcast(dict), v, k)

BangBang.union!!(A::AbstractMicroSet, B) = union!!(upcast(A), B)

BangBang.implements(::typeof(resize!), ::Type{<:UndefArray}) = false

end  # module
