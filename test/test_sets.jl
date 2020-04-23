module TestSets

using BangBang: union!!
using MicroCollections
using Test

@testset "empty" begin
    @test EmptySet() === emptyshim(Set)
    @test eltype(EmptySet()) === Union{}
    @test EmptySet(Set{Int}())::AbstractSet{Int} == Set{Int}()
end

@testset "singleton" begin
    @test SingletonSet([0]) === singletonshim(Set, 0)
    @test SingletonSet([0])::AbstractSet{Int} == Set([0])
    @test SingletonSet([nothing])::AbstractSet{Nothing} == Set([nothing])
    @test SingletonSet(Set([0]))::AbstractSet{Int} == Set([0])
    @test SingletonSet((0,))::AbstractSet{Int} == Set([0])
    @test union!!(SingletonSet([0]), [0.5])::Set{Float64} == Set([0.0, 0.5])
    @test union(SingletonSet([0]), [0.5])::Set{Float64} == Set([0.0, 0.5])
end

end  # module
