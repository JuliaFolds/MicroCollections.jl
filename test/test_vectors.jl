module TestVectors

using BangBang: push!!
using MicroCollections
using Test

const EMPTY_ITR = (UNKNOWN for _ in 1:0)
@assert Base.IteratorEltype(EMPTY_ITR) isa Base.EltypeUnknown

const UNSTABLE_ONE = Ref{Any}(1)
const SINGLETON_ITR = (UNSTABLE_ONE[] for _ in 1:1)
@assert Base.IteratorEltype(SINGLETON_ITR) isa Base.EltypeUnknown

@testset "empty" begin
    @test EmptyVector() === emptyshim(Vector)
    @test eltype(EmptyVector()) === Union{}
    @test EmptyVector(Int[]) === emptyshim(Vector, Int)::AbstractVector{Int}
    @test EmptyVector(()) === emptyshim(Vector)
    @test EmptyVector{Symbol}(Int[]) === emptyshim(Vector, Symbol)
    @test EmptyVector{Symbol}(EMPTY_ITR) === emptyshim(Vector, Symbol)
    @test push!!(EmptyVector(), 0) == [0]
end

@testset "singleton" begin
    @test SingletonVector([0]) === singletonshim(Vector, 0)
    @test SingletonVector([0])::AbstractVector{Int} == [0]
    @test SingletonVector([nothing])::AbstractVector{Nothing} == [nothing]
    @test vcat(SingletonVector([0]), [0.5])::Vector{Float64} == [0.0, 0.5]
    @test SingletonVector(SINGLETON_ITR) === singletonshim(Vector, 1)
    @test SingletonVector{Float64}(SINGLETON_ITR) === singletonshim(Vector, 1.0)
    @test SingletonVector(Real[0])::AbstractVector{Real} == [0]
    @test SingletonVector{Int}(Real[0])::AbstractVector{Int} == [0]
    @test SingletonVector((0,))::AbstractVector{Int} == [0]
    @test push!!(SingletonVector([0]), 0.5) == [0.0, 0.5]
end

@testset "singleton BitVector" begin
    ys = singletonshim(BitVector, true)
    @test ys[1] === true
    @test vcat(ys, [false]) == [true, false]
    @test vcat(ys, [2]) == [1, 2]
    @test_throws InexactError push!!(singletonshim(BitVector, 2), false)
end

end  # module
