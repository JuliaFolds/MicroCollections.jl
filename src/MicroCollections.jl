module MicroCollections

export EmptyDict,
    EmptySet,
    EmptyVector,
    SingletonDict,
    SingletonSet,
    SingletonVector,
    emptyshim,
    singletonshim

include("core.jl")
include("vectors.jl")
include("dicts.jl")
include("sets.jl")
include("bangbang.jl")

end # module
