# Unihedron

**Universal Polyhedral & Polytopic Geometry Engine for Julia**

Unihedron is a comprehensive computational geometry library for Julia providing exact mathematical construction, constructive operations, classification, interactive 3D visualization, and multi-format I/O for 2D polygons, 3D polyhedra, geodesic domes, and fullerenes.

All solids are constructed using **pure constructive geometry and exact algebraic polynomial roots** (no arbitrary floating-point approximations or magic numbers).

---

## Features

- **Complete Polyhedral Families**:
  - **Platonic Solids (5)**: Tetrahedron, Cube, Octahedron, Dodecahedron, Icosahedron.
  - **Archimedean Solids (13)**: Truncated tetrahedron, Cuboctahedron, Rhombicosidodecahedron, Truncated icosahedron (Buckyball), Snub dodecahedron, etc.
  - **Kepler-Poinsot Star Polyhedra (4)**: Great dodecahedron, Small stellated dodecahedron, Great stellated dodecahedron, Great icosahedron.
  - **Catalan Solids (13)**: Exact Archimedean duals (Rhombic dodecahedron, Deltoidal hexecontahedron, Disdyakis triacontahedron, etc.).
  - **Cookson Solids (6)**: Spherical Catalan projections with planar crease restoration discovered by **Arthur J Cookson in 2026** ($C_1$ to $C_6$).
  - **Johnson Solids (92 Complete)**: All 92 convex regular-faced polyhedra ($J_1$ to $J_{92}$) constructed via constructive augmentation/diminution/gyration and exact radical/polynomial roots for elementary solids ($J_{84} \dots J_{92}$).
  - **Geodesic Spheres & Buckyballs / Honeyballs**: Generalized degree-$\nu$ Fullerenes ($C_{20\nu^2}$) and triangulated geodesic duals (Honeyballs).
  - **Prisms, Antiprisms, Pyramids, Bipyramids & Trapezohedra**: Parametric $n$-gonal families.
- **2D Polygons, Polygrams & Star Outlines**:
  - Regular $n$-gons, Schläfli $\{p/q\}$ star polygrams (e.g. pentagram, hexagram Star of David), $2n$-gon star boundaries, and parametric shapes (rectangles, rhombi, trapezoids, parallelograms, kites, Reuleaux polygons).
- **Constructive Polyhedral Operations**:
  - `augment`, `diminish`, `gyrate`, `elongate`, `gyroelongate`, `cupola`, `rotunda`.
  - Exact polar `dual` operation.
  - `sew_coplanar_faces`: Merges bordering coplanar facets into planar $n$-gons.
  - `convex_hull`: 2D and 3D convex hull generation with automatic planar face merging.
- **Face Congruence Classification**:
  - `classify_faces(P)`: Detects unique congruent face types and returns polygon class IDs for each face.
  - `unique_face_polygons(P)`: Extracts canonical 2D/3D representative polygons.
  - `face_type_counts(P)`: Counts faces per congruent polygon type.
- **Interactive 3D Makie Visualization**:
  - `viz(poly_or_solid; color_by_face_size=true)`: High-performance interactive 3D rendering with GLMakie.
  - Wireframe edges, vertex markers, and facet labels.
- **Multi-Format I/O & Master Database**:
  - Default format: **`.off`** (Object File Format).
  - Supported: **`.off`**, **`.obj`**, **`.json`**, **`.h5` / `.hdf5`**, **`.stl`** (3D printing), **`.csv`**.
  - `export_database_hdf5("solids.h5")`: Serializes all 130+ polyhedra into a single structured HDF5 archive.
- **High-Resolution Printing & Gallery Generation**:
  - `print_polyhedron`, `print_polygon`, `print_gallery`: High-resolution raster (PNG, JPG) and vector (SVG, PDF) image exports.

---

## Quickstart

```julia
using Unihedron

# 1. Access solids by constructor or family symbol:
c = cube()
bucky = truncated_icosahedron()
j92 = johnson(92)   # J92: Triangular hebesphenorotunda
c5 = cookson(:C5)   # C5: Gyrotrapezotrigonal Octasphere

# 2. Interactive 3D Visualization:
viz(:dodecahedron)
viz(j92; color_by_face_size=true)

# 3. Classify congruent face shapes:
# Detects 4 unique face types (triangles, squares, pentagons, hexagon):
face_classes = classify_faces(j92)
face_counts  = face_type_counts(j92)

# 4. Constructive Operations:
# Elongate a square pyramid into an augmented cube:
elongated_pyr = elongate(square_pyramid())

# 5. Geodesic Spheres and Buckyballs:
b3 = buckyball(3)    # Degree 3 Fullerene (12 pentagons, 80 hexagons)
h3 = honeyball(3)    # Degree 3 Geodesic Sphere dual

# 6. File I/O (defaults to .off):
save_polyhedron(bucky, "buckyball.off")
p_loaded = load_polyhedron("buckyball.off")

# 7. Print high-resolution image:
print_polyhedron(bucky, "buckyball.png"; color_by_face_size=true)
```

---

## The Cookson Solids (Discovered by Arthur J Cookson, 2026)

The Cookson solids are spherical polyhedra constructed by radially projecting the vertices of non-triangular Catalan solids onto a circumscribed sphere and subdividing non-planar faces along internal creases.

For comprehensive documentation, taxonomy, geometric breakdown, and API usage, see **[doc/cookson.md](doc/cookson.md)**.

| Index | Official Name | Polygon Root | Symmetry | Parent Catalan Solid | Regime Type | $V$ | $F$ |
| :---: | :--- | :--- | :--- | :--- | :--- | :---: | :---: |
| **C1** | **Trigonal Octasphere** | Trigonal | Octasphere | Rhombic Dodecahedron | Convex | 14 | 24 |
| **C2** | **Trigonal Icosasphere** | Trigonal | Icosasphere | Rhombic Triacontahedron | Convex | 32 | 60 |
| **C3** | **Bitrigonal Octasphere** | Bitrigonal | Octasphere | Deltoidal Icositetrahedron | Convex | 26 | 48 |
| **C4** | **Bitrigonal Icosasphere** | Bitrigonal | Icosasphere | Deltoidal Hexecontahedron | Convex | 62 | 120 |
| **C5** | **Gyrotrapezotrigonal Octasphere** | Gyrotrapezotrigonal | Octasphere | Pentagonal Icositetrahedron | Convex | 38 | 48 |
| **C6** | **Gyrotrapezotrigonal Icosasphere** | Gyrotrapezotrigonal | Icosasphere | Pentagonal Hexecontahedron | Convex | 92 | 120 |
| **C7** | **Concave Trigonal Octasphere** | Trigonal | Octasphere | Rhombic Dodecahedron | Concave Shadow | 14 | 24 |
| **C8** | **Concave Trigonal Icosasphere** | Trigonal | Icosasphere | Rhombic Triacontahedron | Concave Shadow | 32 | 60 |
| **C9** | **Concave Bitrigonal Octasphere** | Bitrigonal | Octasphere | Deltoidal Icositetrahedron | Concave Shadow | 26 | 48 |
| **C10** | **Concave Bitrigonal Icosasphere** | Bitrigonal | Icosasphere | Deltoidal Hexecontahedron | Concave Shadow | 62 | 120 |
| **C11** | **Concave Gyrotrapezotrigonal Octasphere** | Gyrotrapezotrigonal | Octasphere | Pentagonal Icositetrahedron | Concave Shadow | 38 | 72 |
| **C12** | **Concave Gyrotrapezotrigonal Icosasphere** | Gyrotrapezotrigonal | Icosasphere | Pentagonal Hexecontahedron | Concave Shadow | 92 | 180 |

---

## Buckyballs & Honeyballs

Unihedron implements generalized degree-$\nu$ Buckyballs (Goldberg Fullerenes) and their dual Honeyballs (Geodesic Spheres):

| Degree ($\nu$) | Solid / Fullerene | Vertices ($V=20\nu^2$) | Faces ($F=10\nu^2+2$) | Dual Geodesic Sphere |
| :---: | :--- | :---: | :---: | :---: |
| **$\nu = 1$** | **Regular Dodecahedron** | 20 | 12 (12 pentagons) | $V=12, F=20$ (Icosahedron) |
| **$\nu = 2$** | **$C_{80}$ Fullerene** | 80 | 42 (12 pentagons, 30 hexagons) | $V=42, F=80$ (2V Honeyball) |
| **$\nu = 3$** | **$C_{180}$ Fullerene** | 180 | 92 (12 pentagons, 80 hexagons) | $V=92, F=180$ (3V Honeyball) |
| **$\nu = 4$** | **$C_{320}$ Fullerene** | 320 | 162 (12 pentagons, 150 hexagons) | $V=162, F=320$ (4V Honeyball) |

```julia
b = buckyball(2)  # C80 Fullerene
h = honeyball(2)  # Dual 2V Geodesic Sphere
```

---

## 2D Polygons & Polygrams

```julia
# Regular polygons:
tri = equilateral_triangle(side=2.0)
sq  = square_polygon(side=1.5)
hex = regular_hexagon(radius=1.0)

# Star polygrams {p/q} and star outlines:
pgram = pentagram()         # Schläfli {5/2}
hgram = hexagram()          # Schläfli {6/2} (Star of David compound)
star5 = star_polygon(5)     # Non-self-intersecting 10-gon star boundary

# Parametric 2D shapes:
rect = rectangle(4.0, 2.0)
rh   = rhombus(3.0, 5.0)
trap = trapezoid(2.0, 4.0, 3.0)
reu  = reuleaux_polygon(3; radius=1.0) # Reuleaux triangle
```

---

## File I/O & Master Database

```julia
# 1. Save and load single polyhedra (defaults to .off):
save_polyhedron(tetrahedron(), "tetra.off")
save_polyhedron(cube(), "cube.obj")
save_polyhedron(dodecahedron(), "dodec.json")
save_polyhedron(octahedron(), "octa.stl")

# 2. Export all 130+ solids to a unified HDF5 archive:
export_database_hdf5("unihedron_database.h5")

# Load any solid from the master archive:
solid_j84 = load_hdf5("unihedron_database.h5"; group="johnson/J84")
solid_c6  = load_hdf5("unihedron_database.h5"; group="cookson/C6")
```

---

## Running Tests

To run the complete test suite (401 unit tests):

```bash
julia test.jl
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.
