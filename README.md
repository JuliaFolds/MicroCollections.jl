# MicroCollections

MicroCollections.jl provides immutable empty and singleton collections.

```julia
julia> using MicroCollections

julia> vec0()  # or EmptyVector()
0-element EmptyVector{Union{}}

julia> vec0(Int)  # or EmptyVector{Int}()
0-element EmptyVector{Int64}

julia> vec1(1)  # or SingletonVector((1,))
1-element SingletonVector{Int64}:
 1

julia> EmptyDict()
EmptyDict{Union{},Union{}}()

julia> EmptyDict{Symbol,Char}()
EmptyDict{Symbol,Char}()

julia> SingletonDict(:a => 0)
SingletonDict{Symbol,Int64} with 1 entry:
  :a => 0

julia> EmptySet()
EmptySet{Union{}}()

julia> EmptySet{Int64}()
EmptySet{Int64}()

julia> SingletonSet((1,))
SingletonSet{Int64} with 1 element:
  1
```

With BangBang.jl, MicroCollections.jl is useful for constructing
singleton solutions that can be combined with a reduce:

```julia
julia> using BangBang.Experimental: mergewith!!

julia> @assert mapreduce(
           x -> SingletonDict(abs(x) % 10 => 1), mergewith!!(+), 1:1000,
       ) == Dict(
           0 => 100,
           1 => 100,
           2 => 100,
           3 => 100,
           4 => 100,
           5 => 100,
           6 => 100,
           7 => 100,
           8 => 100,
           9 => 100,
       )
```
