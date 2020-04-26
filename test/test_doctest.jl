module TestDoctest

using Documenter
using Test
using MicroCollections

@testset "doctest" begin
    if lowercase(get(ENV, "JULIA_PKGEVAL", "false")) == "true"
        @info "Skipping doctests on PkgEval."
    elseif VERSION < v"1.5-"
        @info "Skipping doctests on Julia `$VERSION`."
    else
        doctest(MicroCollections; manual = false)
    end
end

end  # module
