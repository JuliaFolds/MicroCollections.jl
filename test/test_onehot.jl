module TestOneHot

using BangBang.Extras: broadcast_inplace!!
using InitialValues
using MicroCollections
using Test

@testset begin
    @test broadcast_inplace!!(+, InitialValue(+), OneHotArray(2 => 1, 3)) == [0, 1, 0]
    @test broadcast_inplace!!(+, [1, 2, 3], OneHotArray(2 => 1, 3)) == [1, 3, 3]
    @test broadcast_inplace!!(
        +,
        InitialValue(+),
        OneHotArray(2 => 1, 3),
        OneHotArray(3 => -2, 3),
    ) == [0, 1, -2]

    @test broadcast_inplace!!(*, InitialValue(*), OneHotArray(2 => 111, 3)) == [1, 111, 1]
    @test broadcast_inplace!!(*, [1, 2, 3], OneHotArray(2 => 111, 3)) == [1, 222, 3]
end

end  # module
