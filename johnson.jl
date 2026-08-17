# Johnson Solids (J₁ to J₉₂)
# 92 strictly convex polyhedra with regular polygon faces, classified by Norman Johnson (1966).

# --- J1 to J6: Pyramids, Cupolae, and Rotunda ---

"""Johnson solid J₁: Square pyramid (V=5, F=5)"""
square_pyramid(; s::Real=1.0) = pyramid(4; r=s / (2 * sin(π / 4)))

"""Johnson solid J₂: Pentagonal pyramid (V=6, F=6)"""
pentagonal_pyramid(; s::Real=1.0) = pyramid(5; r=s / (2 * sin(π / 5)))

"""Johnson solid J₃: Triangular cupola (V=9, F=8)"""
triangular_cupola(; s::Real=1.0) = cupola(3; s=s)

"""Johnson solid J₄: Square cupola (V=12, F=10)"""
square_cupola(; s::Real=1.0) = cupola(4; s=s)

"""Johnson solid J₅: Pentagonal cupola (V=15, F=12)"""
pentagonal_cupola(; s::Real=1.0) = cupola(5; s=s)

# --- J7 to J17: Modified Pyramids & Bipyramids ---

"""Johnson solid J₇: Elongated triangular pyramid (V=7, F=7)"""
function elongated_triangular_pyramid(; s::Real=1.0)
    p = prism(3; r=s / (2 * sin(π / 3)))
    f_idx = findfirst(f -> length(f) == 3, p.f)
    return augment(p, f_idx; cap=pyramid(3; r=s / (2 * sin(π / 3))))
end

"""Johnson solid J₈: Elongated square pyramid (V=9, F=9)"""
function elongated_square_pyramid(; s::Real=1.0)
    pyr = square_pyramid(s=s)
    f_idx = findfirst(f -> length(f) == 4, pyr.f)
    return elongate(pyr, f_idx)
end

"""Johnson solid J₉: Elongated pentagonal pyramid (V=11, F=11)"""
function elongated_pentagonal_pyramid(; s::Real=1.0)
    pyr = pentagonal_pyramid(s=s)
    f_idx = findfirst(f -> length(f) == 5, pyr.f)
    return elongate(pyr, f_idx)
end

"""Johnson solid J₁₀: Gyroelongated square pyramid (V=9, F=13)"""
function gyroelongated_square_pyramid(; s::Real=1.0)
    pyr = square_pyramid(s=s)
    f_idx = findfirst(f -> length(f) == 4, pyr.f)
    return gyroelongate(pyr, f_idx)
end

"""Johnson solid J₁₁: Gyroelongated pentagonal pyramid (V=11, F=16)"""
function gyroelongated_pentagonal_pyramid(; s::Real=1.0)
    pyr = pentagonal_pyramid(s=s)
    f_idx = findfirst(f -> length(f) == 5, pyr.f)
    return gyroelongate(pyr, f_idx)
end

"""Johnson solid J₁₂: Triangular bipyramid (V=5, F=6)"""
triangular_bipyramid(; s::Real=1.0) = bipyramid(3; r=s / (2 * sin(π / 3)))

"""Johnson solid J₁₃: Pentagonal bipyramid (V=7, F=10)"""
pentagonal_bipyramid(; s::Real=1.0) = bipyramid(5; r=s / (2 * sin(π / 5)))

"""Johnson solid J₁₄: Elongated triangular bipyramid (V=8, F=9)"""
function elongated_triangular_bipyramid(; s::Real=1.0)
    p = prism(3; r=s / (2 * sin(π / 3)))
    pyr = pyramid(3; r=s / (2 * sin(π / 3)))
    tri_faces = findall(f -> length(f) == 3, p.f)
    p_half = augment(p, tri_faces[1]; cap=pyr)
    other_tri = findfirst(f -> length(f) == 3 && (centroid([p_half.v[i] for i in f])[3] < 0), p_half.f)
    return augment(p_half, other_tri; cap=pyr)
end

"""Johnson solid J₁₅: Elongated square bipyramid (V=10, F=12)"""
function elongated_square_bipyramid(; s::Real=1.0)
    esp = elongated_square_pyramid(s=s)
    sq_idx = findfirst(f -> length(f) == 4, esp.f)
    return augment(esp, sq_idx; cap=square_pyramid(s=s))
end

"""Johnson solid J₁₆: Elongated pentagonal bipyramid (V=12, F=15)"""
function elongated_pentagonal_bipyramid(; s::Real=1.0)
    epp = elongated_pentagonal_pyramid(s=s)
    pent_idx = findfirst(f -> length(f) == 5, epp.f)
    return augment(epp, pent_idx; cap=pentagonal_pyramid(s=s))
end

"""Johnson solid J₁₇: Gyroelongated square bipyramid (V=10, F=16)"""
function gyroelongated_square_bipyramid(; s::Real=1.0)
    gsp = gyroelongated_square_pyramid(s=s)
    sq_idx = findfirst(f -> length(f) == 4, gsp.f)
    return augment(gsp, sq_idx; cap=square_pyramid(s=s))
end

# --- J18 to J25: Elongated & Gyroelongated Cupolae/Rotunda ---

"""Johnson solid J₁₈: Elongated triangular cupola (V=15, F=14)"""
function elongated_triangular_cupola(; s::Real=1.0)
    c = triangular_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 6, c.f)
    return elongate(c, f_idx)
end

"""Johnson solid J₁₉: Elongated square cupola (V=20, F=18)"""
function elongated_square_cupola(; s::Real=1.0)
    c = square_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 8, c.f)
    return elongate(c, f_idx)
end

"""Johnson solid J₂₀: Elongated pentagonal cupola (V=25, F=22)"""
function elongated_pentagonal_cupola(; s::Real=1.0)
    c = pentagonal_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 10, c.f)
    return elongate(c, f_idx)
end

"""Johnson solid J₂₁: Elongated pentagonal rotunda (V=30, F=27)"""
function elongated_pentagonal_rotunda(; s::Real=1.0)
    r = rotunda(s=s)
    f_idx = findfirst(f -> length(f) == 10, r.f)
    return elongate(r, f_idx)
end

"""Johnson solid J₂₂: Gyroelongated triangular cupola (V=15, F=16)"""
function gyroelongated_triangular_cupola(; s::Real=1.0)
    c = triangular_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 6, c.f)
    return gyroelongate(c, f_idx)
end

"""Johnson solid J₂₃: Gyroelongated square cupola (V=20, F=26)"""
function gyroelongated_square_cupola(; s::Real=1.0)
    c = square_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 8, c.f)
    return gyroelongate(c, f_idx)
end

"""Johnson solid J₂₄: Gyroelongated pentagonal cupola (V=25, F=32)"""
function gyroelongated_pentagonal_cupola(; s::Real=1.0)
    c = pentagonal_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 10, c.f)
    return gyroelongate(c, f_idx)
end

"""Johnson solid J₂₅: Gyroelongated pentagonal rotunda (V=30, F=37)"""
function gyroelongated_pentagonal_rotunda(; s::Real=1.0)
    r = rotunda(s=s)
    f_idx = findfirst(f -> length(f) == 10, r.f)
    return gyroelongate(r, f_idx)
end

# --- J26: Gyrobifastigium ---

"""Johnson solid J₂₆: Gyrobifastigium (V=8, F=8)"""
function gyrobifastigium(; s::Real=1.0)
    h_ridge = (s * √3) / 2
    a = s / 2
    v = [
        Pt3{Float64}( a,  a,  0.0),
        Pt3{Float64}(-a,  a,  0.0),
        Pt3{Float64}(-a, -a,  0.0),
        Pt3{Float64}( a, -a,  0.0),
        Pt3{Float64}( a,  0.0,  h_ridge),
        Pt3{Float64}(-a,  0.0,  h_ridge),
        Pt3{Float64}( 0.0,  a, -h_ridge),
        Pt3{Float64}( 0.0, -a, -h_ridge)
    ]
    return convex_hull(v; merge_coplanar=true)
end

# --- J27 to J34: Bicupolae, Cupola-Rotundae, Birotundae ---

"""Johnson solid J₂₇: Triangular orthobicupola (V=12, F=14)"""
function triangular_orthobicupola(; s::Real=1.0)
    c = triangular_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 6, c.f)
    return augment(c, f_idx; cap=c, twist_index=0)
end

"""Johnson solid J₂₈: Square orthobicupola (V=16, F=18)"""
function square_orthobicupola(; s::Real=1.0)
    c = square_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 8, c.f)
    return augment(c, f_idx; cap=c, twist_index=0)
end

"""Johnson solid J₂₉: Square gyrobicupola (V=16, F=18)"""
function square_gyrobicupola(; s::Real=1.0)
    c = square_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 8, c.f)
    return augment(c, f_idx; cap=c, twist_index=1)
end

"""Johnson solid J₃₀: Pentagonal orthobicupola (V=20, F=22)"""
function pentagonal_orthobicupola(; s::Real=1.0)
    c = pentagonal_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 10, c.f)
    return augment(c, f_idx; cap=c, twist_index=0)
end

"""Johnson solid J₃₁: Pentagonal gyrobicupola (V=20, F=22)"""
function pentagonal_gyrobicupola(; s::Real=1.0)
    c = pentagonal_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 10, c.f)
    return augment(c, f_idx; cap=c, twist_index=1)
end

"""Johnson solid J₃₂: Pentagonal orthocupolarotunda (V=25, F=27)"""
function pentagonal_orthocupolarotunda(; s::Real=1.0)
    c = pentagonal_cupola(s=s)
    r = rotunda(s=s)
    f_idx = findfirst(f -> length(f) == 10, c.f)
    return augment(c, f_idx; cap=r, twist_index=0)
end

"""Johnson solid J₃₃: Pentagonal gyrocupolarotunda (V=25, F=27)"""
function pentagonal_gyrocupolarotunda(; s::Real=1.0)
    c = pentagonal_cupola(s=s)
    r = rotunda(s=s)
    f_idx = findfirst(f -> length(f) == 10, c.f)
    return augment(c, f_idx; cap=r, twist_index=1)
end

"""Johnson solid J₃₄: Pentagonal orthobirotunda (V=30, F=32)"""
function pentagonal_orthobirotunda(; s::Real=1.0)
    r = rotunda(s=s)
    f_idx = findfirst(f -> length(f) == 10, r.f)
    return augment(r, f_idx; cap=r, twist_index=0)
end

# --- J35 to J43: Elongated Bicupolae, Cupola-Rotundae, Birotundae ---

"""Johnson solid J₃₅: Elongated triangular orthobicupola (V=18, F=20)"""
function elongated_triangular_orthobicupola(; s::Real=1.0)
    etc = elongated_triangular_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 6, etc.f)
    return augment(etc, f_idx; cap=triangular_cupola(s=s), twist_index=0)
end

"""Johnson solid J₃₆: Elongated triangular gyrobicupola (V=18, F=20)"""
function elongated_triangular_gyrobicupola(; s::Real=1.0)
    etc = elongated_triangular_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 6, etc.f)
    return augment(etc, f_idx; cap=triangular_cupola(s=s), twist_index=1)
end

"""Johnson solid J₃₇: Elongated square gyrobicupola (Pseudo-rhombicuboctahedron, V=24, F=26)"""
function elongated_square_gyrobicupola(; s::Real=1.0)
    esc = elongated_square_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 8, esc.f)
    return augment(esc, f_idx; cap=square_cupola(s=s), twist_index=1)
end

"""Johnson solid J₃₈: Elongated pentagonal orthobicupola (V=30, F=32)"""
function elongated_pentagonal_orthobicupola(; s::Real=1.0)
    epc = elongated_pentagonal_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 10, epc.f)
    return augment(epc, f_idx; cap=pentagonal_cupola(s=s), twist_index=0)
end

"""Johnson solid J₃₉: Elongated pentagonal gyrobicupola (V=30, F=32)"""
function elongated_pentagonal_gyrobicupola(; s::Real=1.0)
    epc = elongated_pentagonal_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 10, epc.f)
    return augment(epc, f_idx; cap=pentagonal_cupola(s=s), twist_index=1)
end

"""Johnson solid J₄₀: Elongated pentagonal orthocupolarotunda (V=35, F=37)"""
function elongated_pentagonal_orthocupolarotunda(; s::Real=1.0)
    epc = elongated_pentagonal_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 10, epc.f)
    return augment(epc, f_idx; cap=rotunda(s=s), twist_index=0)
end

"""Johnson solid J₄₁: Elongated pentagonal gyrocupolarotunda (V=35, F=37)"""
function elongated_pentagonal_gyrocupolarotunda(; s::Real=1.0)
    epc = elongated_pentagonal_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 10, epc.f)
    return augment(epc, f_idx; cap=rotunda(s=s), twist_index=1)
end

"""Johnson solid J₄₂: Elongated pentagonal orthobirotunda (V=40, F=42)"""
function elongated_pentagonal_orthobirotunda(; s::Real=1.0)
    epr = elongated_pentagonal_rotunda(s=s)
    f_idx = findfirst(f -> length(f) == 10, epr.f)
    return augment(epr, f_idx; cap=rotunda(s=s), twist_index=0)
end

"""Johnson solid J₄₃: Elongated pentagonal gyrobirotunda (V=40, F=42)"""
function elongated_pentagonal_gyrobirotunda(; s::Real=1.0)
    epr = elongated_pentagonal_rotunda(s=s)
    f_idx = findfirst(f -> length(f) == 10, epr.f)
    return augment(epr, f_idx; cap=rotunda(s=s), twist_index=1)
end

# --- J44 to J48: Gyroelongated Bicupolae, Cupola-Rotundae, Birotundae ---

"""Johnson solid J₄₄: Gyroelongated triangular bicupola (V=18, F=22)"""
function gyroelongated_triangular_bicupola(; s::Real=1.0)
    gtc = gyroelongated_triangular_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 6, gtc.f)
    return augment(gtc, f_idx; cap=triangular_cupola(s=s))
end

"""Johnson solid J₄₅: Gyroelongated square bicupola (V=24, F=30)"""
function gyroelongated_square_bicupola(; s::Real=1.0)
    gsc = gyroelongated_square_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 8, gsc.f)
    return augment(gsc, f_idx; cap=square_cupola(s=s))
end

"""Johnson solid J₄₆: Gyroelongated pentagonal bicupola (V=30, F=38)"""
function gyroelongated_pentagonal_bicupola(; s::Real=1.0)
    gpc = gyroelongated_pentagonal_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 10, gpc.f)
    return augment(gpc, f_idx; cap=pentagonal_cupola(s=s))
end

"""Johnson solid J₄₇: Gyroelongated pentagonal cupolarotunda (V=35, F=43)"""
function gyroelongated_pentagonal_cupolarotunda(; s::Real=1.0)
    gpc = gyroelongated_pentagonal_cupola(s=s)
    f_idx = findfirst(f -> length(f) == 10, gpc.f)
    return augment(gpc, f_idx; cap=rotunda(s=s))
end

"""Johnson solid J₄₈: Gyroelongated pentagonal birotunda (V=40, F=48)"""
function gyroelongated_pentagonal_birotunda(; s::Real=1.0)
    gpr = gyroelongated_pentagonal_rotunda(s=s)
    f_idx = findfirst(f -> length(f) == 10, gpr.f)
    return augment(gpr, f_idx; cap=rotunda(s=s))
end

# --- J49 to J57: Augmented Prisms ---

"""Johnson solid J₄₉: Augmented triangular prism (V=7, F=8)"""
function augmented_triangular_prism(; s::Real=1.0)
    p = prism(3; r=s / (2 * sin(π / 3)))
    f_idx = findfirst(f -> length(f) == 4, p.f)
    return augment(p, f_idx; cap=square_pyramid(s=s))
end

"""Johnson solid J₅₀: Biaugmented triangular prism (V=8, F=11)"""
function biaugmented_triangular_prism(; s::Real=1.0)
    atp = augmented_triangular_prism(s=s)
    f_idx = findfirst(f -> length(f) == 4, atp.f)
    return augment(atp, f_idx; cap=square_pyramid(s=s))
end

"""Johnson solid J₅₁: Triaugmented triangular prism (V=9, F=14)"""
function triaugmented_triangular_prism(; s::Real=1.0)
    btp = biaugmented_triangular_prism(s=s)
    f_idx = findfirst(f -> length(f) == 4, btp.f)
    return augment(btp, f_idx; cap=square_pyramid(s=s))
end

"""Johnson solid J₅₂: Augmented pentagonal prism (V=11, F=10)"""
function augmented_pentagonal_prism(; s::Real=1.0)
    p = prism(5; r=s / (2 * sin(π / 5)))
    f_idx = findfirst(f -> length(f) == 4, p.f)
    return augment(p, f_idx; cap=square_pyramid(s=s))
end

"""Johnson solid J₅₃: Biaugmented pentagonal prism (Parabiaugmented, V=12, F=13)"""
function biaugmented_pentagonal_prism(; s::Real=1.0)
    app = augmented_pentagonal_prism(s=s)
    # Find the non-adjacent square face
    sq_faces = findall(f -> length(f) == 4, app.f)
    f_idx = sq_faces[3] # opposing square face
    return augment(app, f_idx; cap=square_pyramid(s=s))
end

"""Johnson solid J₅₄: Metabiaugmented pentagonal prism (V=12, F=13)"""
function metabiaugmented_pentagonal_prism(; s::Real=1.0)
    app = augmented_pentagonal_prism(s=s)
    sq_faces = findall(f -> length(f) == 4, app.f)
    f_idx = sq_faces[2] # adjacent square face
    return augment(app, f_idx; cap=square_pyramid(s=s))
end

"""Johnson solid J₅₅: Augmented hexagonal prism (V=13, F=11)"""
function augmented_hexagonal_prism(; s::Real=1.0)
    p = prism(6; r=s / (2 * sin(π / 6)))
    f_idx = findfirst(f -> length(f) == 4, p.f)
    return augment(p, f_idx; cap=square_pyramid(s=s))
end

"""Johnson solid J₅₆: Parabiaugmented hexagonal prism (V=14, F=14)"""
function parabiaugmented_hexagonal_prism(; s::Real=1.0)
    ahp = augmented_hexagonal_prism(s=s)
    sq_faces = findall(f -> length(f) == 4, ahp.f)
    f_idx = sq_faces[3] # opposite square face
    return augment(ahp, f_idx; cap=square_pyramid(s=s))
end

"""Johnson solid J₅₇: Metabiaugmented hexagonal prism (V=14, F=14)"""
function metabiaugmented_hexagonal_prism(; s::Real=1.0)
    ahp = augmented_hexagonal_prism(s=s)
    sq_faces = findall(f -> length(f) == 4, ahp.f)
    f_idx = sq_faces[2] # meta (separated by one face) square face
    return augment(ahp, f_idx; cap=square_pyramid(s=s))
end

"""Johnson solid J₅₈: Triaugmented hexagonal prism (V=15, F=17)"""
function triaugmented_hexagonal_prism(; s::Real=1.0)
    mbhp = metabiaugmented_hexagonal_prism(s=s)
    sq_faces = findall(f -> length(f) == 4, mbhp.f)
    f_idx = sq_faces[2]
    return augment(mbhp, f_idx; cap=square_pyramid(s=s))
end

# --- J59 to J64: Augmented Dodecahedra & Diminished Icosahedra ---

"""Johnson solid J₅₉: Augmented dodecahedron (V=21, F=16)"""
function augmented_dodecahedron(; s::Real=1.0)
    d = dodecahedron()
    f_idx = 1
    return augment(d, f_idx; cap=pentagonal_pyramid())
end

"""Johnson solid J₆₀: Parabiaugmented dodecahedron (V=22, F=20)"""
function parabiaugmented_dodecahedron(; s::Real=1.0)
    ad = augmented_dodecahedron()
    pent_faces = findall(f -> length(f) == 5, ad.f)
    n1 = face_normal([ad.v[i] for i in ad.f[pent_faces[1]]])
    # Opposite pentagonal face has normal dot product closest to -1.0
    dots = [dot(face_normal([ad.v[i] for i in ad.f[idx]]), n1) for idx in pent_faces]
    f_idx = pent_faces[argmin(dots)]
    return augment(ad, f_idx; cap=pentagonal_pyramid())
end

"""Johnson solid J₆₁: Metabiaugmented dodecahedron (V=22, F=20)"""
function metabiaugmented_dodecahedron(; s::Real=1.0)
    ad = augmented_dodecahedron()
    pent_faces = findall(f -> length(f) == 5, ad.f)
    f_idx = pent_faces[3] # non-opposite pentagonal face
    return augment(ad, f_idx; cap=pentagonal_pyramid())
end

"""Johnson solid J₆₂: Triaugmented dodecahedron (V=23, F=24)"""
function triaugmented_dodecahedron(; s::Real=1.0)
    mbd = metabiaugmented_dodecahedron()
    pent_faces = findall(f -> length(f) == 5, mbd.f)
    f_idx = pent_faces[3]
    return augment(mbd, f_idx; cap=pentagonal_pyramid())
end

"""Johnson solid J₆₃: Metabidiminished icosahedron (V=10, F=12)"""
function metabidiminished_icosahedron()
    ico = icosahedron()
    # Remove two non-adjacent vertices
    return diminish(ico, [1, 3])
end

"""Johnson solid J₆₄: Tridiminished icosahedron (V=9, F=8)"""
function tridiminished_icosahedron()
    ico = icosahedron()
    # Remove three mutually non-adjacent vertices
    return diminish(ico, [1, 3, 6])
end

# --- J65 to J83: Archimedean Augmentations, Diminutions & Gyrations ---

"""Johnson solid J₆₅: Augmented tridiminished icosahedron (V=10, F=10)"""
function augmented_tridiminished_icosahedron()
    ti = tridiminished_icosahedron()
    tri_face = findfirst(f -> length(f) == 3, ti.f)
    return augment(ti, tri_face; cap=pyramid(3))
end

"""Johnson solid J₆₆: Augmented truncated tetrahedron (V=15, F=11)"""
function augmented_truncated_tetrahedron()
    tt = truncated_tetrahedron()
    hex_face = findfirst(f -> length(f) == 6, tt.f)
    return augment(tt, hex_face; cap=cupola(3))
end

"""Johnson solid J₆₇: Augmented truncated cube (V=28, F=17)"""
function augmented_truncated_cube()
    tc = truncated_cube()
    oct_face = findfirst(f -> length(f) == 8, tc.f)
    return augment(tc, oct_face; cap=cupola(4))
end

"""Johnson solid J₆₈: Biaugmented truncated cube (V=32, F=20)"""
function biaugmented_truncated_cube()
    atc = augmented_truncated_cube()
    oct_face = findfirst(f -> length(f) == 8, atc.f)
    return augment(atc, oct_face; cap=cupola(4))
end

"""Johnson solid J₆₉: Augmented truncated dodecahedron (V=65, F=37)"""
function augmented_truncated_dodecahedron()
    td = truncated_dodecahedron()
    dec_face = findfirst(f -> length(f) == 10, td.f)
    return augment(td, dec_face; cap=cupola(5))
end

"""Johnson solid J₇₀: Parabiaugmented truncated dodecahedron (V=70, F=42)"""
function parabiaugmented_truncated_dodecahedron()
    atd = augmented_truncated_dodecahedron()
    dec_face = findfirst(f -> length(f) == 10 && centroid([atd.v[i] for i in f])[3] < 0, atd.f)
    return augment(atd, dec_face; cap=cupola(5))
end

"""Johnson solid J₇₁: Metabiaugmented truncated dodecahedron (V=70, F=42)"""
function metabiaugmented_truncated_dodecahedron()
    atd = augmented_truncated_dodecahedron()
    dec_faces = findall(f -> length(f) == 10, atd.f)
    return augment(atd, dec_faces[2]; cap=cupola(5))
end

"""Johnson solid J₇₂: Triaugmented truncated dodecahedron (V=75, F=47)"""
function triaugmented_truncated_dodecahedron()
    mbtd = metabiaugmented_truncated_dodecahedron()
    dec_faces = findall(f -> length(f) == 10, mbtd.f)
    return augment(mbtd, dec_faces[2]; cap=cupola(5))
end

"""Johnson solid J₇₃: Gyrate rhombicosidodecahedron (V=60, F=62)"""
function gyrate_rhombicosidodecahedron()
    rd = rhombicosidodecahedron()
    # Gyrate one pentagonal cupola section by π/5
    top_cupola_verts = filter(i -> rd.v[i][3] > 0.8, 1:length(rd.v))
    return gyrate(rd, top_cupola_verts; angle=π/5)
end

"""Johnson solid J₇₄: Parabigyrate rhombicosidodecahedron (V=60, F=62)"""
function parabigyrate_rhombicosidodecahedron()
    grd = gyrate_rhombicosidodecahedron()
    bot_cupola_verts = filter(i -> grd.v[i][3] < -0.8, 1:length(grd.v))
    return gyrate(grd, bot_cupola_verts; angle=π/5)
end

"""Johnson solid J₇₅: Metabigyrate rhombicosidodecahedron (V=60, F=62)"""
function metabigyrate_rhombicosidodecahedron()
    grd = gyrate_rhombicosidodecahedron()
    side_cupola_verts = filter(i -> grd.v[i][1] > 0.8, 1:length(grd.v))
    return gyrate(grd, side_cupola_verts; angle=π/5)
end

"""Johnson solid J₇₆: Trigyrate rhombicosidodecahedron (V=60, F=62)"""
function trigyrate_rhombicosidodecahedron()
    mbgrd = metabigyrate_rhombicosidodecahedron()
    other_cupola_verts = filter(i -> mbgrd.v[i][2] > 0.8, 1:length(mbgrd.v))
    return gyrate(mbgrd, other_cupola_verts; angle=π/5)
end

"""Johnson solid J₇₆: Diminished rhombicosidodecahedron (V=55, F=52)"""
function diminished_rhombicosidodecahedron()
    rd = rhombicosidodecahedron()
    sort_z = sortperm(rd.v, by = p -> p[3])
    top5 = sort_z[56:60]
    return diminish(rd, top5)
end

"""Johnson solid J₇₇: Paragyrate diminished rhombicosidodecahedron (V=55, F=52)"""
function paragyrate_diminished_rhombicosidodecahedron()
    drd = diminished_rhombicosidodecahedron()
    sort_z = sortperm(drd.v, by = p -> p[3])
    bot5 = sort_z[1:5]
    return gyrate(drd, bot5; angle=π/5)
end

"""Johnson solid J₇₈: Metagyrate diminished rhombicosidodecahedron (V=55, F=52)"""
function metagyrate_diminished_rhombicosidodecahedron()
    drd = diminished_rhombicosidodecahedron()
    sort_x = sortperm(drd.v, by = p -> p[1])
    side5 = sort_x[51:55]
    return gyrate(drd, side5; angle=π/5)
end

"""Johnson solid J₇₉: Bigyrate diminished rhombicosidodecahedron (V=55, F=52)"""
function bigyrate_diminished_rhombicosidodecahedron()
    mgrd = metagyrate_diminished_rhombicosidodecahedron()
    sort_y = sortperm(mgrd.v, by = p -> p[2])
    other5 = sort_y[51:55]
    return gyrate(mgrd, other5; angle=π/5)
end

"""Johnson solid J₈₀: Parabidiminished rhombicosidodecahedron (V=50, F=42)"""
function parabidiminished_rhombicosidodecahedron()
    rd = rhombicosidodecahedron()
    sort_z = sortperm(rd.v, by = p -> p[3])
    top5 = sort_z[56:60]
    bot5 = sort_z[1:5]
    return diminish(rd, [top5; bot5])
end

"""Johnson solid J₈₁: Metabidiminished rhombicosidodecahedron (V=50, F=42)"""
function metabidiminished_rhombicosidodecahedron()
    rd = rhombicosidodecahedron()
    sort_z = sortperm(rd.v, by = p -> p[3])
    sort_x = sortperm(rd.v, by = p -> p[1])
    top5 = sort_z[56:60]
    side5 = sort_x[56:60]
    return diminish(rd, [top5; side5])
end

"""Johnson solid J₈₂: Gyrate bidiminished rhombicosidodecahedron (V=50, F=42)"""
function gyrate_bidiminished_rhombicosidodecahedron()
    mbdrd = metabidiminished_rhombicosidodecahedron()
    sort_y = sortperm(mbdrd.v, by = p -> p[2])
    other5 = sort_y[46:50]
    return gyrate(mbdrd, other5; angle=π/5)
end

"""Johnson solid J₈₃: Tridiminished rhombicosidodecahedron (V=45, F=32)"""
function tridiminished_rhombicosidodecahedron()
    rd = rhombicosidodecahedron()
    sort_z = sortperm(rd.v, by = p -> p[3])
    sort_x = sortperm(rd.v, by = p -> p[1])
    sort_y = sortperm(rd.v, by = p -> p[2])
    top5 = sort_z[56:60]
    side5 = sort_x[56:60]
    other5 = sort_y[56:60]
    return diminish(rd, [top5; side5; other5])
end

# --- J84 to J92: The 9 Elementary (Sporadic) Johnson Solids ---
# Constructed from exact algebraic polynomial roots and closed-form radical equations.

function _poly_root(p_fn::Function, x0::Real; max_iters::Int=40, tol::Float64=1e-15)
    x = Float64(x0)
    for _ in 1:max_iters
        val = p_fn(x)
        abs(val) < tol && break
        dval = (p_fn(x + 1e-7) - p_fn(x - 1e-7)) / 2e-7
        x -= val / dval
    end
    return x
end

"""Johnson solid J₈₄: Snub disphenoid (V=8, F=12)"""
function snub_disphenoid(; s::Real=1.0)
    # Roots of canonical defining cubic polynomials
    A = _poly_root(x -> 2*x^3 - x^2 - 8*x - 4, 2.5)
    B = _poly_root(x -> 2*x^3 + 11*x^2 + 4*x - 1, 0.2)
    C = _poly_root(x -> x^3 - 17*x^2 + 64*x - 64, 1.6)
    
    scale = Float64(s) / 2.0
    v = Pt3{Float64}[
        Pt3{Float64}( 0.0,  √A,  1.0) * scale,
        Pt3{Float64}( 0.0,  √A, -1.0) * scale,
        Pt3{Float64}( √C,   √B,  0.0) * scale,
        Pt3{Float64}(-√C,   √B,  0.0) * scale,
        Pt3{Float64}( 0.0, -√B,  √C)  * scale,
        Pt3{Float64}( 0.0, -√B, -√C)  * scale,
        Pt3{Float64}( 1.0, -√A,  0.0) * scale,
        Pt3{Float64}(-1.0, -√A,  0.0) * scale
    ]
    return convex_hull(v; merge_coplanar=true)
end

"""Johnson solid J₈₅: Snub square antiprism (V=16, F=26)"""
function snub_square_antiprism(; s::Real=1.0)
    # Root of canonical 6th-degree polynomial
    A = _poly_root(A -> A^6 - 2*A^5 - 13*A^4 + 8*A^3 + 32*A^2 - 8*A - 4, 1.75)
    B = sqrt(1.0 - (1.0 - 1.0/√2)*A^2)
    C = sqrt(2.0*(1.0 + √2*A - A^2)) + B
    
    scale = Float64(s) / 2.0
    v = Pt3{Float64}[]
    for sx in (-1, 1), sy in (-1, 1)
        push!(v, Pt3{Float64}(sx, sy, C) * scale)
    end
    for s_sign in (-1, 1)
        push!(v, Pt3{Float64}(s_sign * √2 * A, 0.0, B) * scale)
        push!(v, Pt3{Float64}(0.0, s_sign * √2 * A, B) * scale)
    end
    for sx in (-1, 1), sy in (-1, 1)
        push!(v, Pt3{Float64}(sx * A, sy * A, -B) * scale)
    end
    for s_sign in (-1, 1)
        push!(v, Pt3{Float64}(0.0, s_sign * √2, -C) * scale)
        push!(v, Pt3{Float64}(s_sign * √2, 0.0, -C) * scale)
    end
    return convex_hull(v; merge_coplanar=true)
end

"""Johnson solid J₈₆: Sphenocorona (V=10, F=14)"""
function sphenocorona(; s::Real=1.0)
    A = _poly_root(A -> 15*A^4 - 24*A^3 - 100*A^2 + 112*A + 92, 1.7)
    B = _poly_root(x -> 225*x^4 - 24*x^3 - 3176*x^2 - 96*x + 3600, 1.1)
    C = _poly_root(x -> 225*x^4 - 24*x^3 - 3176*x^2 - 96*x + 3600, 3.6)
    D = _poly_root(D -> 15*D^4 - 36*D^3 - 82*D^2 + 100*D + 95, 1.6)
    E = 2.0 + 2.0*√6
    
    scale = Float64(s) / 2.0
    v = Pt3{Float64}[
        Pt3{Float64}( 0.0, 0.0,  1.0) * scale,
        Pt3{Float64}( 0.0, 0.0, -1.0) * scale,
        Pt3{Float64}(  A,  √B,   1.0) * scale,
        Pt3{Float64}( -A,  √B,   1.0) * scale,
        Pt3{Float64}(  A,  √B,  -1.0) * scale,
        Pt3{Float64}( -A,  √B,  -1.0) * scale,
        Pt3{Float64}( 0.0, √C,    D)  * scale,
        Pt3{Float64}( 0.0, √C,   -D)  * scale,
        Pt3{Float64}( 1.0, √E,   0.0) * scale,
        Pt3{Float64}(-1.0, √E,   0.0) * scale
    ]
    return convex_hull(v; merge_coplanar=true)
end

"""Johnson solid J₈₇: Augmented sphenocorona (V=11, F=17)"""
function augmented_sphenocorona(; s::Real=1.0)
    sc = sphenocorona(s=s)
    sq_face = findfirst(f -> length(f) == 4, sc.f)
    return augment(sc, sq_face; cap=square_pyramid(s=s))
end

"""Johnson solid J₈₈: Sphenomegacorona (V=12, F=18)"""
function sphenomegacorona(; s::Real=1.0)
    # Timofeenko 16th-degree polynomial root
    A = _poly_root(A -> 1680*A^16 - 4800*A^15 - 3712*A^14 + 17216*A^13 + 1568*A^12 - 24576*A^11 + 2464*A^10 + 17248*A^9 - 3384*A^8 - 5584*A^7 + 2000*A^6 + 240*A^5 - 776*A^4 + 304*A^3 + 200*A^2 - 56*A - 23, 0.59)
    B = sqrt(1.0 - A^2)
    C = sqrt(3.0 - 4.0*A^2)
    D = 1.0 - 2.0*A^2
    
    scale = Float64(s) / 2.0
    v = Pt3{Float64}[
        Pt3{Float64}( 1.0, 0.0, 2*B) * scale,
        Pt3{Float64}(-1.0, 0.0, 2*B) * scale,
        Pt3{Float64}( 1.0,  2*A, 0.0) * scale,
        Pt3{Float64}( 1.0, -2*A, 0.0) * scale,
        Pt3{Float64}(-1.0,  2*A, 0.0) * scale,
        Pt3{Float64}(-1.0, -2*A, 0.0) * scale,
        Pt3{Float64}( (C+B)/B, 0.0, D/B) * scale,
        Pt3{Float64}(-(C+B)/B, 0.0, D/B) * scale,
        Pt3{Float64}(0.0,  1.0, -sqrt(2.0 + 4.0*A - 4.0*A^2)) * scale,
        Pt3{Float64}(0.0, -1.0, -sqrt(2.0 + 4.0*A - 4.0*A^2)) * scale,
        Pt3{Float64}( (1.0 + C*D/B^3), 0.0, (2.0*A^4 - 1.0)/B^3) * scale,
        Pt3{Float64}(-(1.0 + C*D/B^3), 0.0, (2.0*A^4 - 1.0)/B^3) * scale
    ]
    return convex_hull(v; merge_coplanar=true)
end

"""Johnson solid J₈₉: Hebesphenomegacorona (V=14, F=21)"""
function hebesphenomegacorona(; s::Real=1.0)
    # Timofeenko 10th-degree polynomial root
    A = _poly_root(A -> 26880*A^10 + 35328*A^9 - 25600*A^8 - 39680*A^7 + 6112*A^6 + 13696*A^5 + 2128*A^4 - 1808*A^3 - 1119*A^2 + 494*A - 47, 0.21)
    B = sqrt(1.0 - A^2)
    C = sqrt(2.0*(1.0 - 2.0*A))
    D = sqrt(3.0 - 4.0*A^2)
    E = sqrt(1.0 + A)
    F = 2.0*(1.0 - A)
    
    scale = Float64(s) / 2.0
    v = Pt3{Float64}[
        Pt3{Float64}( 1.0,  1.0, 2*B) * scale,
        Pt3{Float64}( 1.0, -1.0, 2*B) * scale,
        Pt3{Float64}(-1.0,  1.0, 2*B) * scale,
        Pt3{Float64}(-1.0, -1.0, 2*B) * scale,
        Pt3{Float64}( 1.0,  (1.0+2*A), 0.0) * scale,
        Pt3{Float64}( 1.0, -(1.0+2*A), 0.0) * scale,
        Pt3{Float64}(-1.0,  (1.0+2*A), 0.0) * scale,
        Pt3{Float64}(-1.0, -(1.0+2*A), 0.0) * scale,
        Pt3{Float64}( (1.0 + C/sqrt(1.0-A)), 0.0, -(2.0*A^2 + A - 1.0)/B) * scale,
        Pt3{Float64}(-(1.0 + C/sqrt(1.0-A)), 0.0, -(2.0*A^2 + A - 1.0)/B) * scale,
        Pt3{Float64}(0.0,  1.0, -D) * scale,
        Pt3{Float64}(0.0, -1.0, -D) * scale,
        Pt3{Float64}( (D*C+E)/(F*E), 0.0, ((2.0*A-1.0)*D)/F - C/(F*E)) * scale,
        Pt3{Float64}(-(D*C+E)/(F*E), 0.0, ((2.0*A-1.0)*D)/F - C/(F*E)) * scale
    ]
    return convex_hull(v; merge_coplanar=true)
end

"""Johnson solid J₉₀: Disphenocingulum (V=16, F=24)"""
function disphenocingulum(; s::Real=1.0)
    # Timofeenko 12th-degree polynomial root
    B = _poly_root(B -> B^12 - 4*B^11 - 26*B^10 + 116*B^9 + 97*B^8 - 824*B^7 + 312*B^6 + 2176*B^5 - 2024*B^4 - 1888*B^3 + 2688*B^2 - 192*B - 368, 1.55)
    C = sqrt((1.0 + 2.0*B - B^2) / 2.0)
    A = C + sqrt(4.0 - B^2)
    E = (A^2 - B^2 - C^2) / (2.0 * sqrt(4.0 - B^2))
    D = 1.0 + sqrt(4.0 - (A - E)^2)
    
    scale = Float64(s) / 2.0
    v = Pt3{Float64}[
        Pt3{Float64}( 1.0, 0.0,  A) * scale,
        Pt3{Float64}(-1.0, 0.0,  A) * scale,
        Pt3{Float64}( 1.0,  B,  C) * scale,
        Pt3{Float64}( 1.0, -B,  C) * scale,
        Pt3{Float64}(-1.0,  B,  C) * scale,
        Pt3{Float64}(-1.0, -B,  C) * scale,
        Pt3{Float64}( D, 0.0,  E) * scale,
        Pt3{Float64}(-D, 0.0,  E) * scale,
        Pt3{Float64}(0.0,  D, -E) * scale,
        Pt3{Float64}(0.0, -D, -E) * scale,
        Pt3{Float64}( B,  1.0, -C) * scale,
        Pt3{Float64}( B, -1.0, -C) * scale,
        Pt3{Float64}(-B,  1.0, -C) * scale,
        Pt3{Float64}(-B, -1.0, -C) * scale,
        Pt3{Float64}(0.0,  1.0, -A) * scale,
        Pt3{Float64}(0.0, -1.0, -A) * scale
    ]
    return convex_hull(v; merge_coplanar=true)
end

"""Johnson solid J₉₁: Bilunabirotunda (V=14, F=14)"""
function bilunabirotunda(; s::Real=1.0)
    ϕ = (1.0 + √5) / 2.0
    scale = Float64(s) / 2.0
    v = Pt3{Float64}[]
    for sx in (-1, 1), sz in (-1, 1)
        push!(v, Pt3{Float64}(sx, 0.0, sz * ϕ^2) * scale)
    end
    for sx in (-1, 1), sy in (-1, 1), sz in (-1, 1)
        push!(v, Pt3{Float64}(sx * ϕ, sy, sz) * scale)
    end
    for sy in (-1, 1)
        push!(v, Pt3{Float64}(0.0, sy * ϕ, 0.0) * scale)
    end
    return convex_hull(v; merge_coplanar=true)
end

"""Johnson solid J₉₂: Triangular hebesphenorotunda (V=18, F=20)"""
function triangular_hebesphenorotunda(; s::Real=1.0)
    ϕ = (1.0 + √5) / 2.0
    scale = Float64(s) / 2.0
    v = Pt3{Float64}[
        Pt3{Float64}( 0.0,  2.0/√3,  2.0*ϕ^2/√3) * scale,
        Pt3{Float64}( 1.0, -1.0/√3,  2.0*ϕ^2/√3) * scale,
        Pt3{Float64}(-1.0, -1.0/√3,  2.0*ϕ^2/√3) * scale,
        Pt3{Float64}( 1.0,  ϕ^3/√3,  2.0*ϕ/√3)   * scale,
        Pt3{Float64}(-1.0,  ϕ^3/√3,  2.0*ϕ/√3)   * scale,
        Pt3{Float64}( ϕ^2, -1.0/(ϕ*√3),  2.0*ϕ/√3) * scale,
        Pt3{Float64}(-ϕ^2, -1.0/(ϕ*√3),  2.0*ϕ/√3) * scale,
        Pt3{Float64}( ϕ,   -(ϕ+2.0)/√3,  2.0*ϕ/√3) * scale,
        Pt3{Float64}(-ϕ,   -(ϕ+2.0)/√3,  2.0*ϕ/√3) * scale,
        Pt3{Float64}( ϕ^2,  ϕ^2/√3,    2.0/√3)   * scale,
        Pt3{Float64}(-ϕ^2,  ϕ^2/√3,    2.0/√3)   * scale,
        Pt3{Float64}( 0.0, -2.0*ϕ^2/√3,  2.0/√3) * scale,
        Pt3{Float64}( 1.0,  √3,  0.0) * scale,
        Pt3{Float64}(-1.0,  √3,  0.0) * scale,
        Pt3{Float64}( 1.0, -√3,  0.0) * scale,
        Pt3{Float64}(-1.0, -√3,  0.0) * scale,
        Pt3{Float64}( 2.0, 0.0,  0.0) * scale,
        Pt3{Float64}(-2.0, 0.0,  0.0) * scale
    ]
    return convex_hull(v; merge_coplanar=true)
end

# --- Mapping & Dispatchers ---

const JOHNSON_SOLID_MAP = Dict{Symbol, Function}(
    :square_pyramid => square_pyramid,
    :pentagonal_pyramid => pentagonal_pyramid,
    :triangular_cupola => triangular_cupola,
    :square_cupola => square_cupola,
    :pentagonal_cupola => pentagonal_cupola,
    :pentagonal_rotunda => pentagonal_rotunda,
    :elongated_triangular_pyramid => elongated_triangular_pyramid,
    :elongated_square_pyramid => elongated_square_pyramid,
    :elongated_pentagonal_pyramid => elongated_pentagonal_pyramid,
    :gyroelongated_square_pyramid => gyroelongated_square_pyramid,
    :gyroelongated_pentagonal_pyramid => gyroelongated_pentagonal_pyramid,
    :triangular_bipyramid => triangular_bipyramid,
    :pentagonal_bipyramid => pentagonal_bipyramid,
    :elongated_triangular_bipyramid => elongated_triangular_bipyramid,
    :elongated_square_bipyramid => elongated_square_bipyramid,
    :elongated_pentagonal_bipyramid => elongated_pentagonal_bipyramid,
    :gyroelongated_square_bipyramid => gyroelongated_square_bipyramid,
    :elongated_triangular_cupola => elongated_triangular_cupola,
    :elongated_square_cupola => elongated_square_cupola,
    :elongated_pentagonal_cupola => elongated_pentagonal_cupola,
    :elongated_pentagonal_rotunda => elongated_pentagonal_rotunda,
    :gyroelongated_triangular_cupola => gyroelongated_triangular_cupola,
    :gyroelongated_square_cupola => gyroelongated_square_cupola,
    :gyroelongated_pentagonal_cupola => gyroelongated_pentagonal_cupola,
    :gyroelongated_pentagonal_rotunda => gyroelongated_pentagonal_rotunda,
    :gyrobifastigium => gyrobifastigium,
    :triangular_orthobicupola => triangular_orthobicupola,
    :square_orthobicupola => square_orthobicupola,
    :square_gyrobicupola => square_gyrobicupola,
    :pentagonal_orthobicupola => pentagonal_orthobicupola,
    :pentagonal_gyrobicupola => pentagonal_gyrobicupola,
    :pentagonal_orthocupolarotunda => pentagonal_orthocupolarotunda,
    :pentagonal_gyrocupolarotunda => pentagonal_gyrocupolarotunda,
    :pentagonal_orthobirotunda => pentagonal_orthobirotunda,
    :elongated_triangular_orthobicupola => elongated_triangular_orthobicupola,
    :elongated_triangular_gyrobicupola => elongated_triangular_gyrobicupola,
    :elongated_square_gyrobicupola => elongated_square_gyrobicupola,
    :elongated_pentagonal_orthobicupola => elongated_pentagonal_orthobicupola,
    :elongated_pentagonal_gyrobicupola => elongated_pentagonal_gyrobicupola,
    :elongated_pentagonal_orthocupolarotunda => elongated_pentagonal_orthocupolarotunda,
    :elongated_pentagonal_gyrocupolarotunda => elongated_pentagonal_gyrocupolarotunda,
    :elongated_pentagonal_orthobirotunda => elongated_pentagonal_orthobirotunda,
    :elongated_pentagonal_gyrobirotunda => elongated_pentagonal_gyrobirotunda,
    :gyroelongated_triangular_bicupola => gyroelongated_triangular_bicupola,
    :gyroelongated_square_bicupola => gyroelongated_square_bicupola,
    :gyroelongated_pentagonal_bicupola => gyroelongated_pentagonal_bicupola,
    :gyroelongated_pentagonal_cupolarotunda => gyroelongated_pentagonal_cupolarotunda,
    :gyroelongated_pentagonal_birotunda => gyroelongated_pentagonal_birotunda,
    :augmented_triangular_prism => augmented_triangular_prism,
    :biaugmented_triangular_prism => biaugmented_triangular_prism,
    :triaugmented_triangular_prism => triaugmented_triangular_prism,
    :augmented_pentagonal_prism => augmented_pentagonal_prism,
    :biaugmented_pentagonal_prism => biaugmented_pentagonal_prism,
    :augmented_hexagonal_prism => augmented_hexagonal_prism,
    :parabiaugmented_hexagonal_prism => parabiaugmented_hexagonal_prism,
    :metabiaugmented_hexagonal_prism => metabiaugmented_hexagonal_prism,
    :triaugmented_hexagonal_prism => triaugmented_hexagonal_prism,
    :augmented_dodecahedron => augmented_dodecahedron,
    :parabiaugmented_dodecahedron => parabiaugmented_dodecahedron,
    :metabiaugmented_dodecahedron => metabiaugmented_dodecahedron,
    :triaugmented_dodecahedron => triaugmented_dodecahedron,
    :metabidiminished_icosahedron => metabidiminished_icosahedron,
    :tridiminished_icosahedron => tridiminished_icosahedron,
    :augmented_tridiminished_icosahedron => augmented_tridiminished_icosahedron,
    :augmented_truncated_tetrahedron => augmented_truncated_tetrahedron,
    :augmented_truncated_cube => augmented_truncated_cube,
    :biaugmented_truncated_cube => biaugmented_truncated_cube,
    :augmented_truncated_dodecahedron => augmented_truncated_dodecahedron,
    :parabiaugmented_truncated_dodecahedron => parabiaugmented_truncated_dodecahedron,
    :metabiaugmented_truncated_dodecahedron => metabiaugmented_truncated_dodecahedron,
    :triaugmented_truncated_dodecahedron => triaugmented_truncated_dodecahedron,
    :gyrate_rhombicosidodecahedron => gyrate_rhombicosidodecahedron,
    :parabigyrate_rhombicosidodecahedron => parabigyrate_rhombicosidodecahedron,
    :metabigyrate_rhombicosidodecahedron => metabigyrate_rhombicosidodecahedron,
    :trigyrate_rhombicosidodecahedron => trigyrate_rhombicosidodecahedron,
    :diminished_rhombicosidodecahedron => diminished_rhombicosidodecahedron,
    :paragyrate_diminished_rhombicosidodecahedron => paragyrate_diminished_rhombicosidodecahedron,
    :metagyrate_diminished_rhombicosidodecahedron => metagyrate_diminished_rhombicosidodecahedron,
    :bigyrate_diminished_rhombicosidodecahedron => bigyrate_diminished_rhombicosidodecahedron,
    :parabidiminished_rhombicosidodecahedron => parabidiminished_rhombicosidodecahedron,
    :metabidiminished_rhombicosidodecahedron => metabidiminished_rhombicosidodecahedron,
    :gyrate_bidiminished_rhombicosidodecahedron => gyrate_bidiminished_rhombicosidodecahedron,
    :tridiminished_rhombicosidodecahedron => tridiminished_rhombicosidodecahedron,
    :snub_disphenoid => snub_disphenoid,
    :snub_square_antiprism => snub_square_antiprism,
    :sphenocorona => sphenocorona,
    :augmented_sphenocorona => augmented_sphenocorona,
    :sphenomegacorona => sphenomegacorona,
    :hebesphenomegacorona => hebesphenomegacorona,
    :disphenocingulum => disphenocingulum,
    :bilunabirotunda => bilunabirotunda,
    :triangular_hebesphenorotunda => triangular_hebesphenorotunda
)

const JOHNSON_SOLID_ORDER = [
    :square_pyramid,
    :pentagonal_pyramid,
    :triangular_cupola,
    :square_cupola,
    :pentagonal_cupola,
    :pentagonal_rotunda,
    :elongated_triangular_pyramid,
    :elongated_square_pyramid,
    :elongated_pentagonal_pyramid,
    :gyroelongated_square_pyramid,
    :gyroelongated_pentagonal_pyramid,
    :triangular_bipyramid,
    :pentagonal_bipyramid,
    :elongated_triangular_bipyramid,
    :elongated_square_bipyramid,
    :elongated_pentagonal_bipyramid,
    :gyroelongated_square_bipyramid,
    :elongated_triangular_cupola,
    :elongated_square_cupola,
    :elongated_pentagonal_cupola,
    :elongated_pentagonal_rotunda,
    :gyroelongated_triangular_cupola,
    :gyroelongated_square_cupola,
    :gyroelongated_pentagonal_cupola,
    :gyroelongated_pentagonal_rotunda,
    :gyrobifastigium,
    :triangular_orthobicupola,
    :square_orthobicupola,
    :square_gyrobicupola,
    :pentagonal_orthobicupola,
    :pentagonal_gyrobicupola,
    :pentagonal_orthocupolarotunda,
    :pentagonal_gyrocupolarotunda,
    :pentagonal_orthobirotunda,
    :elongated_triangular_orthobicupola,
    :elongated_triangular_gyrobicupola,
    :elongated_square_gyrobicupola,
    :elongated_pentagonal_orthobicupola,
    :elongated_pentagonal_gyrobicupola,
    :elongated_pentagonal_orthocupolarotunda,
    :elongated_pentagonal_gyrocupolarotunda,
    :elongated_pentagonal_orthobirotunda,
    :elongated_pentagonal_gyrobirotunda,
    :gyroelongated_triangular_bicupola,
    :gyroelongated_square_bicupola,
    :gyroelongated_pentagonal_bicupola,
    :gyroelongated_pentagonal_cupolarotunda,
    :gyroelongated_pentagonal_birotunda,
    :augmented_triangular_prism,
    :biaugmented_triangular_prism,
    :triaugmented_triangular_prism,
    :augmented_pentagonal_prism,
    :biaugmented_pentagonal_prism,
    :augmented_hexagonal_prism,
    :parabiaugmented_hexagonal_prism,
    :metabiaugmented_hexagonal_prism,
    :triaugmented_hexagonal_prism,
    :augmented_dodecahedron,
    :parabiaugmented_dodecahedron,
    :metabiaugmented_dodecahedron,
    :triaugmented_dodecahedron,
    :metabidiminished_icosahedron,
    :tridiminished_icosahedron,
    :augmented_tridiminished_icosahedron,
    :augmented_truncated_tetrahedron,
    :augmented_truncated_cube,
    :biaugmented_truncated_cube,
    :augmented_truncated_dodecahedron,
    :parabiaugmented_truncated_dodecahedron,
    :metabiaugmented_truncated_dodecahedron,
    :triaugmented_truncated_dodecahedron,
    :gyrate_rhombicosidodecahedron,
    :parabigyrate_rhombicosidodecahedron,
    :metabigyrate_rhombicosidodecahedron,
    :trigyrate_rhombicosidodecahedron,
    :diminished_rhombicosidodecahedron,
    :paragyrate_diminished_rhombicosidodecahedron,
    :metagyrate_diminished_rhombicosidodecahedron,
    :bigyrate_diminished_rhombicosidodecahedron,
    :parabidiminished_rhombicosidodecahedron,
    :metabidiminished_rhombicosidodecahedron,
    :gyrate_bidiminished_rhombicosidodecahedron,
    :tridiminished_rhombicosidodecahedron,
    :snub_disphenoid,
    :snub_square_antiprism,
    :sphenocorona,
    :augmented_sphenocorona,
    :sphenomegacorona,
    :hebesphenomegacorona,
    :disphenocingulum,
    :bilunabirotunda,
    :triangular_hebesphenorotunda
]

# Aliases for J1 to J92 and j1 to j92
for (i, sym) in enumerate(JOHNSON_SOLID_ORDER)
    JOHNSON_SOLID_MAP[Symbol("J", i)] = JOHNSON_SOLID_MAP[sym]
    JOHNSON_SOLID_MAP[Symbol("j", i)] = JOHNSON_SOLID_MAP[sym]
end

"""
    johnson(name::Symbol)
    johnson(index::Integer)
    johnson(name::AbstractString)

Access any of the 92 Johnson solids by name symbol, Johnson ID symbol (e.g. `:J1`, `:J84`),
index (`1:92`), or string name.
"""
function johnson(name::Symbol)
    haskey(JOHNSON_SOLID_MAP, name) || error("Unknown Johnson solid: $name. Available: :J1 to :J92 or name symbols like :square_pyramid.")
    return JOHNSON_SOLID_MAP[name]()
end

function johnson(index::Integer)
    1 <= index <= 92 || error("Johnson solid index must be between 1 and 92, got $index.")
    return johnson(JOHNSON_SOLID_ORDER[index])
end

johnson(name::AbstractString) = johnson(Symbol(replace(lowercase(strip(name)), " " => "_", "-" => "_")))

"""
    johnson_name(index::Integer)

Returns the human-readable name of Johnson solid J_index.
"""
function johnson_name(index::Integer)
    1 <= index <= 92 || error("Johnson solid index must be between 1 and 92, got $index.")
    sym = JOHNSON_SOLID_ORDER[index]
    return titlecase(replace(string(sym), "_" => " "))
end

"""
    johnson_names()

Returns a vector of name symbols for all 92 Johnson solids.
"""
function johnson_names()
    return copy(JOHNSON_SOLID_ORDER)
end
