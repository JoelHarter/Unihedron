using Test
using LinearAlgebra
using GLMakie
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

    @testset "Coplanar Face Sewing (sew_coplanar_faces / merge_coplanar_faces)" begin
        # 1. Dodecahedron vertices in raw convex hull produces 36 triangles -> sew into 12 pentagons
        dodec_pts = dodecahedron().v
        raw_dodec = convex_hull(dodec_pts; merge_coplanar=false)
        @test length(raw_dodec.v) == 20
        @test length(raw_dodec) == 36 # 36 triangulated facets
        @test all(length.(raw_dodec.f) .== 3)

        sewn_dodec = sew_coplanar_faces(raw_dodec)
        @test length(sewn_dodec.v) == 20
        @test length(sewn_dodec) == 12 # 12 regular pentagons!
        @test all(length.(sewn_dodec.f) .== 5)

        # Alias test: merge_coplanar_faces & sew_faces
        @test merge_coplanar_faces(raw_dodec) isa Polyhedron
        @test sew_faces(raw_dodec) isa Polyhedron

        # 2. Cube vertices in raw convex hull produces 12 triangles -> sew into 6 squares
        raw_cube = convex_hull(cube().v; merge_coplanar=false)
        @test length(raw_cube) == 12
        sewn_cube = sew_coplanar_faces(raw_cube)
        @test length(sewn_cube) == 6
        @test all(length.(sewn_cube.f) .== 4)

        # 3. Truncated icosahedron (Buckyball) raw triangles -> 12 pentagons + 20 hexagons
        raw_bucky = convex_hull(truncated_icosahedron().v; merge_coplanar=false)
        sewn_bucky = sew_coplanar_faces(raw_bucky)
        @test length(sewn_bucky.v) == 60
        @test length(sewn_bucky) == 32
        @test count(length.(sewn_bucky.f) .== 5) == 12
        @test count(length.(sewn_bucky.f) .== 6) == 20

        # 4. Purely triangular solids remain unchanged (idempotence)
        raw_ico = icosahedron()
        @test sew_coplanar_faces(raw_ico) == raw_ico
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

    @testset "Cookson Solids (6 solids & cookson operator)" begin
        # 1. Cooksonian Rhombic Dodecahedron (V=14, F=24 triangles)
        crd = cooksonian_rhombic_dodecahedron()
        @test length(crd.v) == 14 && length(crd) == 24
        @test all(length.(crd.f) .== 3)

        # 2. Cooksonian Rhombic Triacontahedron (V=32, F=60 triangles)
        crt = cooksonian_rhombic_triacontahedron()
        @test length(crt.v) == 32 && length(crt) == 60
        @test all(length.(crt.f) .== 3)

        # 3. Cooksonian Deltoidal Icositetrahedron (V=26, F=48 triangles)
        cdi = cooksonian_deltoidal_icositetrahedron()
        @test length(cdi.v) == 26 && length(cdi) == 48
        @test all(length.(cdi.f) .== 3)

        # 4. Cooksonian Deltoidal Hexecontahedron (V=62, F=120 triangles)
        cdh = cooksonian_deltoidal_hexecontahedron()
        @test length(cdh.v) == 62 && length(cdh) == 120
        @test all(length.(cdh.f) .== 3)

        # 5. Cooksonian Pentagonal Icositetrahedron (V=38, F=48: 24 trapezoids, 24 triangles)
        cpi = cooksonian_pentagonal_icositetrahedron()
        @test length(cpi.v) == 38 && length(cpi) == 48
        @test count(length.(cpi.f) .== 4) == 24
        @test count(length.(cpi.f) .== 3) == 24

        # 6. Cooksonian Pentagonal Hexecontahedron (V=92, F=120: 60 trapezoids, 60 triangles)
        cph = cooksonian_pentagonal_hexecontahedron()
        @test length(cph.v) == 92 && length(cph) == 120
        @test count(length.(cph.f) .== 4) == 60
        @test count(length.(cph.f) .== 3) == 60

        # Verify all vertices lie on sphere of given radius
        @test all(isapprox.(norm.(cph.v), 1.0, atol=1e-10))
        cph_r2 = gyrotrapezotrigonal_icosasphere(radius=2.5)
        @test all(isapprox.(norm.(cph_r2.v), 2.5, atol=1e-10))

        # Official function names
        @test trigonal_octasphere() isa Polyhedron
        @test trigonal_icosasphere() isa Polyhedron
        @test bitrigonal_octasphere() isa Polyhedron
        @test bitrigonal_icosasphere() isa Polyhedron
        @test gyrotrapezotrigonal_octasphere() isa Polyhedron
        @test gyrotrapezotrigonal_icosasphere() isa Polyhedron

        # Shorthand symbols and names
        @test cookson(:C1) isa Polyhedron
        @test cookson(:C6) isa Polyhedron
        @test cookson(:trigonal_octasphere) isa Polyhedron
        @test cookson(1) isa Polyhedron
        @test length(cookson_names()) == 6
        @test cookson_name(1) == "Trigonal Octasphere"
        @test cookson_name(6) == "Gyrotrapezotrigonal Icosasphere"

        # Structural metadata verification
        info1 = cookson_info(1)
        @test info1.polygon_root == "Trigonal" && info1.symmetry == "Octasphere" && info1.parent_catalan == "Rhombic Dodecahedron"
        info6 = cookson_info(:C6)
        @test info6.polygon_root == "Gyrotrapezotrigonal" && info6.symmetry == "Icosasphere" && info6.parent_catalan == "Pentagonal Hexecontahedron"

        # Arbitrary polyhedron projection operator
        @test length(cookson(cube()).v) == 8
    end

    @testset "Prisms, Antiprisms, Pyramids, Bipyramids, and Trapezohedra" begin
        # 1. Prisms
        p3 = prism(3)
        @test length(p3.v) == 6 && length(p3) == 5 # 2 triangles, 3 squares

        p5 = prism(5)
        @test length(p5.v) == 10 && length(p5) == 7 # 2 pentagons, 5 squares
        @test count(length.(p5.f) .== 5) == 2
        @test count(length.(p5.f) .== 4) == 5

        # 2. Antiprisms
        ap3 = antiprism(3) # Octahedron topology
        @test length(ap3.v) == 6 && length(ap3) == 8
        @test all(length.(ap3.f) .== 3)

        ap5 = antiprism(5)
        @test length(ap5.v) == 10 && length(ap5) == 12 # 2 pentagons, 10 triangles
        @test count(length.(ap5.f) .== 5) == 2
        @test count(length.(ap5.f) .== 3) == 10

        # 3. Pyramids
        pyr3 = pyramid(3) # Regular tetrahedron
        @test length(pyr3.v) == 4 && length(pyr3) == 4

        pyr4 = pyramid(4) # Johnson J1 square pyramid
        @test length(pyr4.v) == 5 && length(pyr4) == 5
        @test count(length.(pyr4.f) .== 4) == 1
        @test count(length.(pyr4.f) .== 3) == 4

        pyr5 = pyramid(5) # Johnson J2 pentagonal pyramid
        @test length(pyr5.v) == 6 && length(pyr5) == 6
        @test count(length.(pyr5.f) .== 5) == 1
        @test count(length.(pyr5.f) .== 3) == 5

        # 4. Bipyramids / Dipyramids
        bp3 = bipyramid(3) # Johnson J12 triangular bipyramid
        @test length(bp3.v) == 5 && length(bp3) == 6

        bp4 = dipyramid(4) # Regular octahedron
        @test length(bp4.v) == 6 && length(bp4) == 8

        bp5 = bipyramid(5) # Johnson J13 pentagonal bipyramid
        @test length(bp5.v) == 7 && length(bp5) == 10
        @test all(length.(bp5.f) .== 3)

        # 5. Trapezohedra / Gyrated Bipyramids
        # n=3: Trigonal trapezohedron / Rhombohedron (V=8, F=6 quadrilaterals)
        trap3 = trapezohedron(3; gyration=0.5)
        @test length(trap3.v) == 8 && length(trap3) == 6
        @test all(length.(trap3.f) .== 4)

        # n=5: Pentagonal trapezohedron / d10 die (V=12, F=10 quadrilaterals)
        trap5 = trapezohedron(5; gyration=0.5)
        @test length(trap5.v) == 12 && length(trap5) == 10
        @test all(length.(trap5.f) .== 4)

        # Aliases test
        @test gyrobipyramid(5) isa Polyhedron
        @test antidipyramid(5) isa Polyhedron
        @test deltohedron(5) isa Polyhedron

        # Gyration parameter sweep (0.1, 0.25, 0.5, 0.75, 0.9)
        for t in [0.1, 0.25, 0.5, 0.75, 0.9]
            th = trapezohedron(5; gyration=t)
            @test length(th.v) == 12 && length(th) == 10
            @test all(length.(th.f) .== 4)
        end
    end

    @testset "Constructive Operations (cupola, rotunda, elongate, gyroelongate, augment, diminish, gyrate)" begin
        # 1. Cupolae (J3, J4, J5)
        c3 = cupola(3) # Triangular cupola (V=9, F=8)
        @test length(c3.v) == 9 && length(c3) == 8
        @test count(length.(c3.f) .== 6) == 1
        @test count(length.(c3.f) .== 4) == 3
        @test count(length.(c3.f) .== 3) == 4

        c4 = cupola(4) # Square cupola (V=12, F=10)
        @test length(c4.v) == 12 && length(c4) == 10
        @test count(length.(c4.f) .== 8) == 1
        @test count(length.(c4.f) .== 4) == 5

        c5 = cupola(5) # Pentagonal cupola (V=15, F=12)
        @test length(c5.v) == 15 && length(c5) == 12
        @test count(length.(c5.f) .== 10) == 1
        @test count(length.(c5.f) .== 5) == 1

        # 2. Rotunda (J6)
        rot = rotunda() # Pentagonal rotunda (V=20, F=17)
        @test length(rot.v) == 20 && length(rot) == 17
        @test count(length.(rot.f) .== 10) == 1
        @test count(length.(rot.f) .== 5) == 6
        @test count(length.(rot.f) .== 3) == 10

        # 3. Elongate: J1 -> J8 (Elongated square pyramid)
        pyr4 = pyramid(4)
        sq_idx = findfirst(f -> length(f) == 4, pyr4.f)
        j8 = elongate(pyr4, sq_idx)
        @test length(j8.v) == 9 && length(j8) == 9

        # 4. Gyroelongate: J1 -> J10 (Gyroelongated square pyramid)
        j10 = gyroelongate(pyr4, sq_idx)
        @test length(j10.v) == 9 && length(j10) == 13

        # 5. Augment: J8 + pyramid(4) -> J15 (Elongated square bipyramid)
        sq_idx_j8 = findfirst(f -> length(f) == 4, j8.f)
        j15 = augment(j8, sq_idx_j8; cap=pyr4)
        @test length(j15.v) == 10 && length(j15) == 12

        # 6. Diminish & Gyrate on Icosahedron
        ico = icosahedron()
        # Diminishing top vertex of icosahedron yields pentagonal pyramid base (Johnson solid)
        dim_ico = diminish(ico, [1])
        @test length(dim_ico.v) == 11 && length(dim_ico) == 16
    end

    @testset "Johnson Solids Family (J1 to J92)" begin
        # 1. Base building blocks
        @test length(johnson(1).v) == 5 && length(johnson(1)) == 5 # J1: square pyramid
        @test length(johnson(2).v) == 6 && length(johnson(2)) == 6 # J2: pentagonal pyramid
        @test length(johnson(3).v) == 9 && length(johnson(3)) == 8 # J3: triangular cupola
        @test length(johnson(4).v) == 12 && length(johnson(4)) == 10 # J4: square cupola
        @test length(johnson(5).v) == 15 && length(johnson(5)) == 12 # J5: pentagonal cupola
        @test length(johnson(6).v) == 20 && length(johnson(6)) == 17 # J6: pentagonal rotunda

        # 2. Key composite solids
        @test length(johnson(8).v) == 9 && length(johnson(8)) == 9 # J8: elongated square pyramid
        @test length(johnson(10).v) == 9 && length(johnson(10)) == 13 # J10: gyroelongated square pyramid
        @test length(johnson(15).v) == 10 && length(johnson(15)) == 12 # J15: elongated square bipyramid
        @test length(johnson(26).v) == 8 && length(johnson(26)) == 8 # J26: gyrobifastigium
        @test length(johnson(37).v) == 24 && length(johnson(37)) == 26 # J37: elongated square gyrobicupola (pseudo-rhombicuboctahedron)

        # 3. Elementary solids (Exact algebraic constructions)
        @test length(johnson(84).v) == 8 && length(johnson(84)) == 12 # J84: snub disphenoid
        @test length(johnson(85).v) == 16 && length(johnson(85)) == 26 # J85: snub square antiprism
        @test length(johnson(86).v) == 10 && length(johnson(86)) == 14 # J86: sphenocorona
        @test length(johnson(87).v) == 11 && length(johnson(87)) == 17 # J87: augmented sphenocorona
        @test length(johnson(88).v) == 12 && length(johnson(88)) == 18 # J88: sphenomegacorona
        @test length(johnson(89).v) == 14 && length(johnson(89)) == 21 # J89: hebesphenomegacorona
        @test length(johnson(90).v) == 16 && length(johnson(90)) == 24 # J90: disphenocingulum
        @test length(johnson(91).v) == 14 && length(johnson(91)) == 14 # J91: bilunabirotunda
        @test length(johnson(92).v) == 18 && length(johnson(92)) == 20 # J92: triangular hebesphenorotunda

        # 4. Dispatchers & metadata
        @test johnson(:square_pyramid) isa Polyhedron
        @test johnson(:J1) isa Polyhedron
        @test johnson(:j84) isa Polyhedron
        @test length(johnson_names()) == 92
        @test johnson_name(1) == "Square Pyramid"
        @test johnson_name(92) == "Triangular Hebesphenorotunda"

        # 5. Verify Euler characteristic V - E + F = 2 for every single one of the 92 Johnson solids
        for idx in 1:92
            P = johnson(idx)
            edges = Set{Tuple{Int, Int}}()
            for face in P.f
                n_pts = length(face)
                for k in 1:n_pts
                    u = face[k]
                    v = face[k == n_pts ? 1 : k + 1]
                    push!(edges, (min(u, v), max(u, v)))
                end
            end
            V = length(P.v)
            E = length(edges)
            F = length(P)
            @test V - E + F == 2
        end
    end

    @testset "Makie Visualization & Display" begin
        # 1. 2D Polygon display
        p2 = [Pt2{Float64}(0,0), Pt2{Float64}(1,0), Pt2{Float64}(1,1), Pt2{Float64}(0,1)]
        fig_2d = display_polygon(p2; title="Square", show_vertices=true, show_labels=true)
        @test fig_2d isa Figure

        # 2. 3D Polygon display
        p3 = [Pt3{Float64}(0,0,0), Pt3{Float64}(1,0,0), Pt3{Float64}(1,1,1), Pt3{Float64}(0,1,1)]
        fig_3d = display_polygon(p3; title="3D Quad", show_vertices=true, show_labels=true)
        @test fig_3d isa Figure

        # 3. 3D Polyhedron display
        dodec = dodecahedron()
        fig_poly1 = display_polyhedron(dodec; show_faces=true, show_edges=true, show_vertices=true, show_vertex_labels=true, show_face_labels=true)
        @test fig_poly1 isa Figure

        # Face coloring by face polygon size
        bucky = truncated_icosahedron()
        fig_poly2 = plot_polyhedron(bucky; color_by_face_size=true)
        @test fig_poly2 isa Figure

        # Unified viz dispatcher
        @test viz(p2) isa Figure
        @test viz(p3) isa Figure
        @test viz(dodec) isa Figure
        @test viz(:icosahedron) isa Figure
    end

    @testset "File I/O and Exporters (OFF, OBJ, JSON, HDF5, STL, CSV)" begin
        mktempdir() do tmpdir
            cube_p = cube()

            # 1. Default format save (defaults to .off)
            f_def = save_polyhedron(cube_p, joinpath(tmpdir, "cube_default"))
            @test endswith(f_def, ".off")
            @test isfile(f_def)
            cube_loaded_def = load_polyhedron(f_def)
            @test length(cube_loaded_def.v) == 8 && length(cube_loaded_def) == 6

            # 2. OFF format save & load
            f_off = joinpath(tmpdir, "dodec.off")
            save_off(dodecahedron(), f_off)
            dodec_loaded = load_off(f_off)
            @test length(dodec_loaded.v) == 20 && length(dodec_loaded) == 12

            # 3. Wavefront OBJ format save & load
            f_obj = joinpath(tmpdir, "octa.obj")
            save_obj(octahedron(), f_obj)
            octa_loaded = load_obj(f_obj)
            @test length(octa_loaded.v) == 6 && length(octa_loaded) == 8

            # 4. JSON format save & load
            f_json = joinpath(tmpdir, "bucky.json")
            save_json(truncated_icosahedron(), f_json; name="Buckyball")
            bucky_loaded = load_json(f_json)
            @test length(bucky_loaded.v) == 60 && length(bucky_loaded) == 32

            # 5. HDF5 format save & load
            f_h5 = joinpath(tmpdir, "j84.h5")
            save_hdf5(johnson(84), f_h5; group="j84", name="Snub Disphenoid")
            j84_loaded = load_hdf5(f_h5; group="j84")
            @test length(j84_loaded.v) == 8 && length(j84_loaded) == 12

            # 6. STL format save
            f_stl = joinpath(tmpdir, "tetra.stl")
            save_stl(tetrahedron(), f_stl)
            @test isfile(f_stl) && filesize(f_stl) > 0

            # 7. Polygons 2D & 3D save and load
            f_poly2 = joinpath(tmpdir, "square.csv")
            p2 = [Pt2{Float64}(0,0), Pt2{Float64}(1,0), Pt2{Float64}(1,1), Pt2{Float64}(0,1)]
            save_polygon(p2, f_poly2)
            p2_loaded = load_polygon2d(f_poly2)
            @test length(p2_loaded) == 4

            f_poly3 = joinpath(tmpdir, "quad.json")
            p3 = [Pt3{Float64}(0,0,0), Pt3{Float64}(1,0,0), Pt3{Float64}(1,1,1), Pt3{Float64}(0,1,1)]
            save_polygon(p3, f_poly3)
            p3_loaded = load_polygon3d(f_poly3)
            @test length(p3_loaded) == 4

            # 8. Master HDF5 Database generator
            f_db = joinpath(tmpdir, "master_archive.h5")
            export_database_hdf5(f_db)
            @test isfile(f_db) && filesize(f_db) > 10000
            
            # Load a solid back from the master archive
            j92_from_db = load_hdf5(f_db; group="johnson/J92")
            @test length(j92_from_db.v) == 18 && length(j92_from_db) == 20
        end
    end

    @testset "Face Congruence Classification (classify_faces, unique_face_polygons)" begin
        # 1. Cube: 1 unique face type (6 congruent squares)
        c_types = classify_faces(cube())
        @test length(c_types) == 6
        @test all(c_types .== 1)
        @test length(unique_face_polygons(cube())) == 1

        # 2. Cuboctahedron: 2 unique face types (8 equilateral triangles, 6 squares)
        co_types = classify_faces(cuboctahedron())
        @test length(co_types) == 14
        @test length(unique(co_types)) == 2
        counts_co = face_type_counts(cuboctahedron())
        @test sort(collect(values(counts_co))) == [6, 8]

        # 3. Truncated Icosahedron: 2 unique face types (12 pentagons, 20 hexagons)
        bucky_types = classify_faces(truncated_icosahedron())
        @test length(bucky_types) == 32
        @test length(unique(bucky_types)) == 2
        counts_bucky = face_type_counts(truncated_icosahedron())
        @test sort(collect(values(counts_bucky))) == [12, 20]

        # 4. Rhombicosidodecahedron: 3 unique face types (20 triangles, 30 squares, 12 pentagons)
        rd_types = classify_faces(rhombicosidodecahedron())
        @test length(rd_types) == 62
        @test length(unique(rd_types)) == 3
        counts_rd = face_type_counts(rhombicosidodecahedron())
        @test sort(collect(values(counts_rd))) == [12, 20, 30]

        # 5. J92 Triangular Hebesphenorotunda: 4 unique face types (13 triangles, 3 squares, 3 pentagons, 1 hexagon)
        j92_types = classify_faces(johnson(92))
        @test length(j92_types) == 20
        @test length(unique(j92_types)) == 4
        counts_j92 = face_type_counts(johnson(92))
        @test sort(collect(values(counts_j92))) == [1, 3, 3, 13]
    end

    @testset "2D Polygon & Polygram Generators" begin
        # 1. Regular polygons
        tri = equilateral_triangle(side=2.0)
        @test length(tri) == 3
        @test isapprox(norm(tri[1] - tri[2]), 2.0; atol=1e-8)

        sq = square_polygon(side=1.5)
        @test length(sq) == 4
        @test isapprox(norm(sq[1] - sq[2]), 1.5; atol=1e-8)

        pent = regular_pentagon()
        @test length(pent) == 5

        hex = regular_hexagon()
        @test length(hex) == 6

        dodec = regular_dodecagon()
        @test length(dodec) == 12

        # 2. Polygrams & Stars
        # Pentagram {5/2}
        pgram = pentagram()
        @test length(pgram) == 5

        # Hexagram {6/2} (compound: 2 triangles)
        hgram = hexagram()
        @test length(hgram) == 2 # 2 component triangles
        @test length(hgram[1]) == 3 && length(hgram[2]) == 3

        # Star outline
        s5 = star_polygon(5)
        @test length(s5) == 10 # 10 vertices

        # 3. Parametric shapes
        rect = rectangle(4.0, 2.0)
        @test length(rect) == 4

        rh = rhombus(3.0, 5.0)
        @test length(rh) == 4

        trap = trapezoid(2.0, 4.0, 3.0)
        @test length(trap) == 4

        plg = parallelogram(3.0, 2.0, π/3)
        @test length(plg) == 4

        kt = kite_polygon(2.0, 4.0)
        @test length(kt) == 4

        elp = ellipse_polygon(3.0, 2.0; n=32)
        @test length(elp) == 32

        reu = reuleaux_polygon(3; radius=1.0)
        @test length(reu) >= 24
    end

end







