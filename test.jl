using Test
include("unihedron.jl")
using .Unihedron

@testset "Unihedron Test Suite" begin

    @testset "Points & Polyhedron Constructors" begin
        p_int = Points((0, 0, 0), [1, 0, 0], (1, 1, 0), [0, 1, 0])
        @test length(p_int) == 4
        @test eltype(p_int) == Pt3{Int64}

        p_float = Points((0., 0, 0), [1, 0, 0], (1, 1, 0), [0, 1, 0])
        @test eltype(p_float) == Pt3{Float64}

        v = Points((0.,0,0), [1,0,0], [1,1,0], [0,1,0], [0,0,1])
        f = [[1,2,3,4], [1,2,5], [2,3,5], [3,4,5], [4,1,5]]
        P = Polyhedron(v, f)

        @test length(P) == 5
        @test P.f[1] == [1, 2, 3, 4]
        @test P[1][1] == Pt3{Float64}(0.0, 0.0, 0.0)

        # Mutability test via face view
        P[1][1] = Pt3{Float64}(0.1, 0.0, 0.0)
        @test P.v[1] == Pt3{Float64}(0.1, 0.0, 0.0)
        P[1][1] = Pt3{Float64}(0.0, 0.0, 0.0) # revert
    end

    @testset "Polygon2 (3D to 2D projection)" begin
        square_3d = [Pt3{Float64}(0,0,5), Pt3{Float64}(2,0,5), Pt3{Float64}(2,2,5), Pt3{Float64}(0,2,5)]
        p2d = Polygon2(square_3d)

        @test length(p2d) == 4
        @test p2d[1] ≈ Pt2{Float64}(0.0, 0.0)
        @test p2d[2] ≈ Pt2{Float64}(2.0, 0.0)
        @test p2d[3] ≈ Pt2{Float64}(2.0, 2.0)
        @test p2d[4] ≈ Pt2{Float64}(0.0, 2.0)

        # 2D pass-through
        pts_2d = [Pt2{Float64}(1, 2), Pt2{Float64}(3, 4)]
        @test Polygon2(pts_2d) == pts_2d
    end

    @testset "Geometric Helpers (centroid, face_normal, isCoplanar, isBordering)" begin
        t₁ = [Pt3{Float64}(0,0,0), Pt3{Float64}(1,0,0), Pt3{Float64}(0,1,0)]
        @test centroid(t₁) ≈ Pt3{Float64}(1/3, 1/3, 0.0)
        @test face_normal(t₁) ≈ Pt3{Float64}(0, 0, 1)

        t₂ = [Pt3{Float64}(1,0,0), Pt3{Float64}(0,1,0), Pt3{Float64}(0,0,1)]
        @test !isCoplanar(t₁, t₂)

        t₃ = [Pt3{Float64}(0,0,0), Pt3{Float64}(1,0,0), Pt3{Float64}(1,1,0)]
        @test isCoplanar(t₁, t₃)

        @test isBordering(t₁, t₃)[1] == true
        @test isBordering(t₁, t₃; allow_flipped=false)[1] == true

        t₄ = [Pt3{Float64}(1,0,0), Pt3{Float64}(0,0,0), Pt3{Float64}(0.5,-1,0)]
        @test isBordering(t₁, t₄; allow_flipped=false)[1] == false
        @test isBordering(t₁, t₄; allow_flipped=true)[1] == true
    end

    @testset "Polygon Similarity and Congruence (isSimilar, isCongruent)" begin
        s₁ = [Pt3{Float64}(0,0,0), Pt3{Float64}(1,0,0), Pt3{Float64}(1,1,0), Pt3{Float64}(0,1,0)]
        s₂ = [Pt3{Float64}(10,10,0), Pt3{Float64}(12,10,0), Pt3{Float64}(12,12,0), Pt3{Float64}(10,12,0)]
        
        sim = isSimilar(s₁, s₂)
        @test sim[1] == true
        @test sim[2] ≈ 2.0

        cong = isCongruent(s₁, [p .+ Pt3{Float64}(5, 5, 5) for p in s₁])
        @test cong[1] == true
        @test cong[2] ≈ 1.0
    end

    @testset "Convex Hull Overloads (2D and 3D)" begin
        pts_2d = [Pt2{Float64}(0,0), Pt2{Float64}(1,0), Pt2{Float64}(1,1), Pt2{Float64}(0,1), Pt2{Float64}(0.5,0.5)]
        hull_2d = convex_hull(pts_2d)
        @test length(hull_2d) == 4
        @test Pt2{Float64}(0.5, 0.5) ∉ hull_2d

        pts_3d = [Pt3{Float64}(0,0,0), Pt3{Float64}(1,0,0), Pt3{Float64}(1,1,0), Pt3{Float64}(0,1,0), Pt3{Float64}(0.5,0.5,1.0)]
        hull_3d = convex_hull(pts_3d)
        @test hull_3d isa Polyhedron
        @test length(hull_3d.v) == 5
        @test length(hull_3d) == 6
    end

    @testset "Platonic Solids" begin
        tet = tetrahedron()
        @test length(tet.v) == 4
        @test length(tet) == 4

        cub = cube()
        @test length(cub.v) == 8
        @test length(cub) == 6

        oct = octahedron()
        @test length(oct.v) == 6
        @test length(oct) == 8

        ico = icosahedron()
        @test length(ico.v) == 12
        @test length(ico) == 20

        dod = dodecahedron()
        @test length(dod.v) == 20
        @test length(dod) == 12
    end

end
