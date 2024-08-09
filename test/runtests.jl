using FixedFunctions

using Aqua: Aqua
using Test: Test, @testset

@testset "FixedFunctions" begin
    @testset "Aqua" begin
        Aqua.test_all(FixedFunctions)
    end
end
