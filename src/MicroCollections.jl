module MicroCollections

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia"m => "```jldoctest README")
end MicroCollections

export EmptyDict,
    EmptySet,
    EmptyVector,
    SingletonDict,
    SingletonSet,
    SingletonVector,
    UndefArray,
    UndefVector,
    emptyshim,
    singletonshim,
    vec0,
    vec1

using Setfield: @lens, Setfield

include("core.jl")
include("vectors.jl")
include("dicts.jl")
include("sets.jl")
include("arrays.jl")
include("bangbang.jl")

end # module
