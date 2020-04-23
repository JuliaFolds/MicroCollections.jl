module TestInterface

using BangBang: merge!!, union!!
using MicroCollections
using Test

const DATASET_VECTOR = [
    :vector => (
        ltype = [Vector],
        emptyargs = [(Int,)],
        singletonargs = [(0,)],
        #
    ),
    :dict => (
        ltype = [Dict],
        emptyargs = [(Pair{Symbol,Int},)],
        singletonargs = [(:a => 0,)],
        #
    ),
    :set => (
        ltype = [Set],
        emptyargs = [(Int,)],
        singletonargs = [(0,)],
        #
    ),
]
const DATASET_DICT = Dict(DATASET_VECTOR)


@testset "generic" begin
    @testset "empty" begin
        @testset "$key/$ltype/$emptyargs" for (key, recipe) in DATASET_VECTOR,
            ltype in recipe.ltype,
            emptyargs in recipe.emptyargs

            xs = emptyshim(ltype, emptyargs...)
            items = collect(xs)

            @testset "printing" begin
                @test !isempty(sprint(show, xs))
                @test !isempty(sprint(show, "text/plain", xs))
            end

            @testset "iterator" begin
                @test length(xs) == 0
                @test eltype(xs) === eltype(items)
                @test eltype(items) !== Any
            end

            @testset "ltype" begin
                ys = ltype(xs)
                @test ys == xs
                @test ys == ltype(items)
            end
        end
    end
    @testset "singleton" begin
        @testset "$key/$ltype/$singletonargs" for (key, recipe) in DATASET_VECTOR,
            ltype in recipe.ltype,
            singletonargs in recipe.singletonargs

            xs = singletonshim(ltype, singletonargs...)
            items = collect(xs)

            @testset "printing" begin
                @test !isempty(sprint(show, xs))
                @test !isempty(sprint(show, "text/plain", xs))
            end

            @testset "iterator" begin
                @test length(xs) == 1
                @test eltype(xs) === eltype(items)
                @test eltype(items) !== Any
            end

            @testset "ltype" begin
                ys = ltype(xs)
                @test ys == xs
                @test ys == ltype(items)
            end
        end
    end
end


@testset "empty Union{}" begin
    @testset "$key/$ltype" for (key, recipe) in DATASET_VECTOR, ltype in recipe.ltype
        xs = emptyshim(ltype)

        @testset "printing" begin
            @test !isempty(sprint(show, xs))
            @test !isempty(sprint(show, "text/plain", xs))
        end

        @testset "iterator" begin
            @test length(xs) == 0
            if key === :dict
                @test eltype(xs) === Pair{Union{},Union{}}
            else
                @test eltype(xs) === Union{}
            end
        end

        @testset "ltype" begin
            items = collect(xs)
            ys = ltype(xs)
            @test ys == xs
            @test ys == ltype(items)
        end
    end
end


@testset "vector" begin
    recipe = DATASET_DICT[:vector]
    @testset "empty" begin
        @testset for ltype in recipe.ltype, emptyargs in recipe.emptyargs
            xs = emptyshim(ltype, emptyargs...)
            @test xs isa AbstractVector
            @test ltype <: AbstractVector
            @test_throws BoundsError xs[1]

            @testset "double" begin
                ys = vcat(xs, xs)
                @test ys isa ltype
                @test length(ys) == 0
                @test eltype(xs) == eltype(ys)
            end

            @testset "append 0" begin
                ys = vcat(xs, [zero(eltype(xs))])
                @test ys == [0]
                @test eltype(ys) == eltype(xs)
            end
        end
    end
    @testset "singleton" begin
        @testset for ltype in recipe.ltype, singletonargs in recipe.singletonargs
            xs = singletonshim(ltype, singletonargs...)
            @test xs isa AbstractVector
            @test ltype <: AbstractVector
            @test xs[1] == collect(xs)[1]
            @test_throws BoundsError xs[0]
            @test_throws BoundsError xs[2]

            @testset "double" begin
                ys = vcat(xs, xs)
                @test ys isa ltype
                @test length(ys) == 2
                @test eltype(xs) == eltype(ys)
            end

            @testset "vcat Union{}" begin
                ys = vcat(xs, Union{}[])
                @test ys == collect(xs)
                @test eltype(ys) == eltype(xs)
            end

            @testset "append 0" begin
                ys = vcat(xs, [zero(eltype(xs))])
                @test ys == [xs[1], 0]
                @test eltype(ys) == eltype(xs)
            end
        end
    end
end


@testset "dict" begin
    recipe = DATASET_DICT[:dict]
    @testset "empty" begin
        @testset for ltype in recipe.ltype, emptyargs in recipe.emptyargs
            xs = emptyshim(ltype, emptyargs...)
            @test xs isa AbstractDict
            @test ltype <: AbstractDict
            @test_throws KeyError xs[1]
            @test !haskey(xs, :non_existing_item)
            @test !((:non_existing_item => nothing) in xs)
            @test keys(xs) == Set()
            @test collect(values(xs)) == []

            @testset "double" begin
                ys = merge!!(xs, xs)
                @test ys isa ltype
                @test length(ys) == 0
                @test eltype(xs) == eltype(ys)
            end
        end
    end
    @testset "singleton" begin
        @testset for ltype in recipe.ltype, singletonargs in recipe.singletonargs
            xs = singletonshim(ltype, singletonargs...)
            @test xs isa AbstractDict
            @test ltype <: AbstractDict
            (k, v), = collect(xs)
            @test xs[k] == v
            @test_throws KeyError xs[:non_existing_item]
            @test haskey(xs, k)
            @test !haskey(xs, :non_existing_item)
            @test (k => v) in xs
            @test !((:non_existing_item => nothing) in xs)
            @test keys(xs) == Set([k])
            @test collect(values(xs)) == [v]

            @testset "double" begin
                ys = merge!!(xs, xs)
                @test ys isa ltype
                @test length(ys) == 1
                @test eltype(xs) == eltype(ys)
            end
        end
    end
end


@testset "set" begin
    recipe = DATASET_DICT[:set]
    @testset "empty" begin
        @testset for ltype in recipe.ltype, emptyargs in recipe.emptyargs
            xs = emptyshim(ltype, emptyargs...)
            @test xs isa AbstractSet
            @test ltype <: AbstractSet
            @test nothing ∉ xs
            @test xs == Set()

            @testset "double" begin
                ys = union!!(xs, xs)
                @test ys isa ltype
                @test length(ys) == 0
                @test eltype(xs) == eltype(ys)
            end
        end
    end
    @testset "singleton" begin
        @testset for ltype in recipe.ltype, singletonargs in recipe.singletonargs
            xs = singletonshim(ltype, singletonargs...)
            @test xs isa AbstractSet
            @test ltype <: AbstractSet
            x, = collect(xs)
            @test :non_existing_item ∉ xs
            @test x in xs
            @test xs == Set([x])

            @testset "double" begin
                ys = union!!(xs, xs)
                @test ys isa ltype
                @test length(ys) == 1
                @test eltype(xs) == eltype(ys)
            end
        end
    end
end

end  # module
