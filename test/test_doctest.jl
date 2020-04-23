module TestDoctest

using Documenter
using Test
using MicroCollections

@testset "doctest" begin
    if lowercase(get(ENV, "JULIA_PKGEVAL", "false")) == "true"
        @info "Skipping doctests on PkgEval."
    else
        doctest(MicroCollections; manual = false)
    end
end

end  # module
