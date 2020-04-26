# MicroCollections

MicroCollections.jl provides immutable empty and singleton collections.

```julia
julia> using MicroCollections

julia> vec0()
0-element EmptyVector{Union{}}

julia> vec0(Int)
0-element EmptyVector{Int64}

julia> vec1(1)
1-element SingletonVector{Int64}:
 1

julia> dict0()
EmptyDict{Union{},Union{}}()

julia> dict0(Pair{Symbol,Char})
EmptyDict{Symbol,Char}()

julia> dict1(:a => 0)
SingletonDict{Symbol,Int64} with 1 entry:
  :a => 0

julia> set0()
EmptySet{Union{}}()

julia> set0(Int)
EmptySet{Int64}()

julia> set1(1)
SingletonSet{Int64} with 1 element:
  1
```
