module MicroCollections

export EmptyDict,
    EmptySet,
    EmptyVector,
    SingletonDict,
    SingletonSet,
    SingletonVector,
    dict0,
    dict1,
    emptyshim,
    set0,
    set1,
    singletonshim,
    vec0,
    vec1

include("core.jl")
include("vectors.jl")
include("dicts.jl")
include("sets.jl")
include("bangbang.jl")

end # module
