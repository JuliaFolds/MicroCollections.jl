module MicroCollections

export EmptyDict,
    EmptySet,
    EmptyVector,
    SingletonDict,
    SingletonSet,
    SingletonVector,
    emptyshim,
    singletonshim

# TODO: Let BangBang depend on MicroCollections, instead of the other
# way around?  Defining "`upcast`" is enough for defining efficient
# !!-methods in BangBang?
using BangBang: BangBang, append!!, merge!!, union!!

include("core.jl")
include("vectors.jl")
include("dicts.jl")
include("sets.jl")

end # module
