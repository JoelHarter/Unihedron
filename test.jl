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

        # Merged coplanar facets (e.g. cube vertices)
        cube_pts = [
            Pt3{Float64}(-1,-1,-1), Pt3{Float64}( 1,-1,-1),
            Pt3{Float64}( 1, 1,-1), Pt3{Float64}(-1, 1,-1),
            Pt3{Float64}(-1,-1, 1), Pt3{Float64}( 1,-1, 1),
            Pt3{Float64}( 1, 1, 1), Pt3{Float64}(-1, 1, 1)
        ]
        cube_hull = convex_hull(cube_pts; merge_coplanar=true)
        @test length(cube_hull.v) == 8
        @test length(cube_hull) == 6
        @test all(length.(cube_hull.f) .== 4)
    end

    @testset "Dual Operation (dual)" begin
        c = cube()
        d_c = dual(c)
        @test length(d_c.v) == 6
        @test length(d_c) == 8

        # Double dual recovers original cube
        d_d_c = dual(d_c)
        @test length(d_d_c.v) == 8
        @test length(d_d_c) == 6
        @test isapprox(d_d_c.v, c.v)

        t = tetrahedron()
        d_t = dual(t)
        @test length(d_t.v) == 4
        @test length(d_t) == 4

        ico = icosahedron()
        d_ico = dual(ico)
        @test length(d_ico.v) == 20
        @test length(d_ico) == 12
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

        # Index / symbol dispatcher
        @test platonic(:cube) isa Polyhedron
        @test platonic(2) isa Polyhedron
        @test length(platonic(5).v) == 20
    end

    @testset "Archimedean Solids (13 solids)" begin
        # 1. Truncated Tetrahedron (V=12, F=8)
        tt = truncated_tetrahedron()
        @test length(tt.v) == 12 && length(tt) == 8

        # 2. Cuboctahedron (V=12, F=14)
        co = cuboctahedron()
        @test length(co.v) == 12 && length(co) == 14

        # 3. Truncated Cube (V=24, F=14)
        tc = truncated_cube()
        @test length(tc.v) == 24 && length(tc) == 14

        # 4. Truncated Octahedron (V=24, F=14)
        to = truncated_octahedron()
        @test length(to.v) == 24 && length(to) == 14

        # 5. Rhombicuboctahedron (V=24, F=26)
        rc = rhombicuboctahedron()
        @test length(rc.v) == 24 && length(rc) == 26

        # 6. Truncated Cuboctahedron (V=48, F=26)
        tco = truncated_cuboctahedron()
        @test length(tco.v) == 48 && length(tco) == 26

        # 7. Snub Cube (V=24, F=38)
        sc = snub_cube()
        @test length(sc.v) == 24 && length(sc) == 38

        # 8. Icosidodecahedron (V=30, F=32)
        id = icosidodecahedron()
        @test length(id.v) == 30 && length(id) == 32

        # 9. Truncated Icosahedron (V=60, F=32)
        ti = truncated_icosahedron()
        @test length(ti.v) == 60 && length(ti) == 32

        # 10. Truncated Dodecahedron (V=60, F=32)
        td = truncated_dodecahedron()
        @test length(td.v) == 60 && length(td) == 32

        # 11. Rhombicosidodecahedron (V=60, F=62)
        rd = rhombicosidodecahedron()
        @test length(rd.v) == 60 && length(rd) == 62

        # 12. Truncated Icosidodecahedron (V=120, F=62)
        tid = truncated_icosidodecahedron()
        @test length(tid.v) == 120 && length(tid) == 62

        # 13. Snub Dodecahedron (V=60, F=92)
        sd = snub_dodecahedron()
        @test length(sd.v) == 60 && length(sd) == 92

        # Dispatcher tests
        @test archimedean(:cuboctahedron) isa Polyhedron
        @test length(archimedean(1).v) == 12
        @test length(archimedean(13).v) == 60
    end

    @testset "Kepler-Poinsot Star Polyhedra (4 solids)" begin
        # 1. Great Dodecahedron (V=12, F=12)
        gd = great_dodecahedron()
        @test length(gd.v) == 12 && length(gd) == 12

        # 2. Small Stellated Dodecahedron (V=12, F=12)
        ssd = small_stellated_dodecahedron()
        @test length(ssd.v) == 12 && length(ssd) == 12

        # 3. Great Stellated Dodecahedron (V=20, F=12)
        gsd = great_stellated_dodecahedron()
        @test length(gsd.v) == 20 && length(gsd) == 12

        # 4. Great Icosahedron (V=12, F=20)
        gi = great_icosahedron()
        @test length(gi.v) == 12 && length(gi) == 20

        # Dispatcher tests
        @test kepler_poinsot(:great_dodecahedron) isa Polyhedron
        @test length(kepler_poinsot(1).v) == 12
        @test length(kepler_poinsot(3).v) == 20
    end

    @testset "Catalan Solids via dual() (13 solids)" begin
        # 1. Triakis Tetrahedron (V=8, F=12)
        c1 = triakis_tetrahedron()
        @test length(c1.v) == 8 && length(c1) == 12

        # 2. Rhombic Dodecahedron (V=14, F=12)
        c2 = rhombic_dodecahedron()
        @test length(c2.v) == 14 && length(c2) == 12

        # 3. Triakis Octahedron (V=14, F=24)
        c3 = triakis_octahedron()
        @test length(c3.v) == 14 && length(c3) == 24

        # 4. Tetrakis Hexahedron (V=14, F=24)
        c4 = tetrakis_hexahedron()
        @test length(c4.v) == 14 && length(c4) == 24

        # 5. Deltoidal Icositetrahedron (V=26, F=24)
        c5 = deltoidal_icositetrahedron()
        @test length(c5.v) == 26 && length(c5) == 24

        # 6. Disdyakis Dodecahedron (V=26, F=48)
        c6 = disdyakis_dodecahedron()
        @test length(c6.v) == 26 && length(c6) == 48

        # 7. Pentagonal Icositetrahedron (V=38, F=24)
        c7 = pentagonal_icositetrahedron()
        @test length(c7.v) == 38 && length(c7) == 24

        # 8. Rhombic Triacontahedron (V=32, F=30)
        c8 = rhombic_triacontahedron()
        @test length(c8.v) == 32 && length(c8) == 30

        # 9. Pentakis Dodecahedron (V=32, F=60)
        c9 = pentakis_dodecahedron()
        @test length(c9.v) == 32 && length(c9) == 60

        # 10. Triakis Icosahedron (V=32, F=60)
        c10 = triakis_icosahedron()
        @test length(c10.v) == 32 && length(c10) == 60

        # 11. Deltoidal Hexecontahedron (V=62, F=60)
        c11 = deltoidal_hexecontahedron()
        @test length(c11.v) == 62 && length(c11) == 60

        # 12. Disdyakis Triacontahedron (V=62, F=120)
        c12 = disdyakis_triacontahedron()
        @test length(c12.v) == 62 && length(c12) == 120

        # 13. Pentagonal Hexecontahedron (V=92, F=60)
        c13 = pentagonal_hexecontahedron()
        @test length(c13.v) == 92 && length(c13) == 60

        # Dispatcher tests
        @test catalan(:rhombic_dodecahedron) isa Polyhedron
        @test length(catalan(1).v) == 8
        @test length(catalan(13).v) == 92
    end

end
