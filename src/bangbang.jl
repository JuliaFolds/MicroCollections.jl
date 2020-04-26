module BangBangImpl

# TODO: Let BangBang depend on MicroCollections.
using BangBang: BangBang, append!!, merge!!, union!!

using ..MicroCollections:
    AbstractMicroDict, AbstractMicroSet, AbstractMicroVector, SingletonVector, upcast

BangBang.append!!(A::AbstractMicroVector, B::AbstractVector) = append!!(upcast(A), B)
# TODO: Avoid allocating array twice if `upcast(A)` is going to be
# widen anyway.

BangBang.push!!(A::AbstractMicroVector, x) = append!!(A, SingletonVector((x,)))

BangBang.merge!!(dest::AbstractMicroDict, src) = merge!!(upcast(dest), src)

BangBang.union!!(A::AbstractMicroSet, B) = union!!(upcast(A), B)

end  # module
