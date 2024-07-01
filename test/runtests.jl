using FixedFunctions

using Aqua: Aqua
using Test: Test, @testset, @test, @test_throws

id(args...; kwargs...) = args, kwargs

const simple = FixedFunction(id, (3, Free(), -2, Free(), 7))
const keywords = FixedFunction(id, (Free(), 6), (; x=0, y=2))
const variadic = FixedFunction(id, (-4, Free(), VarFree(), 1, Free()))

@testset "FixedFunctions" begin
    @testset "Aqua" begin
        Aqua.test_all(FixedFunctions)
    end

    @test_throws ArgumentError FixedFunction(id, (), (;))
    @test_throws ArgumentError FixedFunction(id, (VarFree(), VarFree()), (;))

    # simple
    @test simple(2, 4) == id(3, 2, -2, 4, 7)
    @test_throws ArgumentError simple(2)  # too few arguments
    @test_throws ArgumentError simple(2, 4, -1)  # too many arguments

    @test fix(id, 3, Free(), -2, Free(), 7) == simple

    # keywords
    @test keywords(3; y=3, z=-4) == id(3, 6; x=0, y=3, z=-4)
    @test_throws ArgumentError keywords(; y=3, z=-4)  # too few arguments
    @test_throws ArgumentError keywords(3, 1; y=3, z=-4)  # too many arguments

    @test fix(id, Free(), 6; x=0, y=2) == keywords

    # variadic
    @test variadic(2, -2) == id(-4, 2, 1, -2)
    @test variadic(2, -5, -2) == id(-4, 2, -5, 1, -2)
    @test variadic(2, -5, 3, -2) == id(-4, 2, -5, 3, 1, -2)
    @test_throws ArgumentError variadic(2)  # too few arguments

    @test fix(id, -4, Free(), VarFree(), 1, Free()) == variadic
end
