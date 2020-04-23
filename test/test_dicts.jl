module TestDicts

using BangBang: merge!!
using MicroCollections
using Test

@testset "empty" begin
    @test EmptyDict() === emptyshim(Dict)
    @test eltype(EmptyDict()) === Pair{Union{},Union{}}
    @test EmptyDict(Dict{Symbol,Int}()) === EmptyDict{Symbol,Int}()
    @test EmptyDict(Union{}[]) === EmptyDict{Union{},Union{}}()
    @test EmptyDict{Char,Nothing}(Dict{Symbol,Int}()) === EmptyDict{Char,Nothing}()
    @test EmptyDict{Char,Nothing}(Union{}[]) === EmptyDict{Char,Nothing}()
    @test_throws ArgumentError EmptyDict(Dict(:a => 1))
    @test_throws ArgumentError EmptyDict{Char,Nothing}(Dict(:a => 1))
end

@testset "singleton" begin
    @test SingletonDict(:a => 0) === singletonshim(Dict, :a => 0)
    @test SingletonDict(:a => 0)::AbstractDict{Symbol,Int} == Dict(:a => 0)
    @test SingletonDict(Dict(:a => 0)) === singletonshim(Dict, :a => 0)
    @test SingletonDict{Symbol,Float64}(Dict(:a => 0)) === singletonshim(Dict, :a => 0.0)
    @test_throws ArgumentError SingletonDict(Dict())
    @test_throws ArgumentError SingletonDict(Dict(:a => 0, :b => 1))
end

@testset "$_merge" for _merge in [merge, merge!!]
    @test _merge(SingletonDict(:a => 0), Dict(:b => 0.5))::Dict{Symbol,Float64} ==
          Dict(:a => 0.0, :b => 0.5)
    @test _merge(SingletonDict(:a => 0), SingletonDict(:b => 0.5))::Dict{Symbol,Float64} ==
          Dict(:a => 0.0, :b => 0.5)
    @test _merge(SingletonDict(:a => 0), EmptyDict())::Dict{Symbol,Int} == Dict(:a => 0)
    @test _merge(EmptyDict(), SingletonDict(:a => 0))::Dict{Symbol,Int} == Dict(:a => 0)
    @test _merge(SingletonDict(:a => 0), EmptyDict())::Dict{Symbol,Int} == Dict(:a => 0)

    @test _merge(+, SingletonDict(:a => 1), Dict(:a => 0.5))::Dict{Symbol,Float64} ==
          Dict(:a => 1.5)
    @test _merge(
        +,
        SingletonDict(:a => 1),
        SingletonDict(:a => 0.5),
    )::Dict{Symbol,Float64} == Dict(:a => 1.5)
    @test _merge(+, EmptyDict(), SingletonDict(:a => 1))::Dict{Symbol,Int} == Dict(:a => 1)

    @test _merge(+, SingletonDict(:a => 1), EmptyDict()) == Dict(:a => 1)
    if _merge === merge!!
        @test_broken _merge(+, SingletonDict(:a => 1), EmptyDict()) isa Dict{Symbol,Int}
        # or is it OK to return a `SingletonDict`?
    else
        @test _merge(+, SingletonDict(:a => 1), EmptyDict()) isa Dict{Symbol,Int}
    end
end

end  # module
