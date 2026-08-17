# Geodesic Spheres & Goldberg Polyhedra (Fullerenes / Buckyballs)

**Formalized by the American architect and systems theorist R. Buckminster Fuller (1895–1983) and the American mathematician Michael Goldberg (1902–1990) in his 1937 paper *A Class of Multi-Symmetric Polyhedra*.**

---

## 1. Historical & Mathematical Context

* **Geodesic Spheres**: Buckminster Fuller patented and popularized the **geodesic dome** (1954), triangulating spherical surfaces by subdividing the 20 faces of a regular icosahedron into smaller triangular networks and projecting the vertices onto the unit sphere. The subdivision frequency is denoted by $\nu$ (or $T$).
* **Goldberg Polyhedra & Buckyballs**: Michael Goldberg (1937) classified the exact polar duals of geodesic icosahedra, denoted $GP(m, n)$. Goldberg proved that **every Goldberg polyhedron contains exactly 12 regular pentagons** (at the 12 original vertices of the icosahedron) and a variable number of hexagons ($10(T-1)$ hexagons).
* **Carbon-60 (Buckminsterfullerene)**: In 1985, Harold Kroto, Robert Curl, and Richard Smalley discovered the $C_{60}$ carbon cage molecule, naming it *Buckminsterfullerene* (awarded the 1996 Nobel Prize in Chemistry).

---

## 2. Defining Axioms & Rules

To qualify as a Geodesic Sphere or Goldberg Polyhedron, the mesh must satisfy the following generative rules:

1. **Icosahedral Foundation**: Subdivided from the base symmetry of the regular icosahedron ($I_h$).
2. **Triangulation Subdivision (Frequency $\nu$)**: Each icosahedral triangular face is divided into $\nu^2$ smaller triangles.
3. **Spherical Normalization**: Every vertex $\mathbf{v}$ is projected radially onto the unit sphere: $\mathbf{v}_{\text{sphere}} = R \frac{\mathbf{v}}{\|\mathbf{v}\|}$.
4. **Dual Polyhedra (The 12-Pentagon Theorem)**: By Euler's formula ($\chi = 2$), any closed spherical mesh composed exclusively of pentagons and hexagons must contain **precisely 12 pentagons**, regardless of how many hundreds or thousands of hexagons surround them.

---

## 3. The Geodesic & Goldberg Series Table

| Frequency ($\nu$) / Type | Preview | Name | Vertices ($V$) | Edges ($E$) | Faces ($F$) | Face Breakdown | Dual Counterpart |
| :---: | :---: | :--- | :---: | :---: | :---: | :--- | :--- |
| **$\nu = 1$** | <img src="img/geodesic/geodesic_1v.png" width="90" alt="1v Geodesic"> | **$1\nu$ Geodesic Sphere** (Regular Icosahedron) | 12 | 30 | 20 | 20 Equilateral Triangles | Regular Dodecahedron ($C_{20}$) |
| **$\nu = 2$** | <img src="img/geodesic/geodesic_2v.png" width="90" alt="2v Geodesic"> | **$2\nu$ Geodesic Sphere** | 42 | 120 | 80 | 80 Spherical Triangles | $C_{80}$ Fullerene ($GP(2,0)$) |
| **$\nu = 3$** | <img src="img/geodesic/geodesic_3v.png" width="90" alt="3v Geodesic"> | **$3\nu$ Geodesic Sphere** | 92 | 270 | 180 | 180 Spherical Triangles | $C_{180}$ Fullerene ($GP(3,0)$) |
| **Dual $\nu = 2$** | <img src="img/geodesic/buckyball_c80.png" width="90" alt="C80 Fullerene"> | **$C_{80}$ Buckyball / Fullerene** | 80 | 120 | 42 | 12 Pentagons, 30 Hexagons | $2\nu$ Geodesic Sphere |
| **Dual $\nu = 3$** | <img src="img/geodesic/buckyball_c180.png" width="90" alt="C180 Fullerene"> | **$C_{180}$ Buckyball / Fullerene** | 180 | 270 | 92 | 12 Pentagons, 80 Hexagons | $3\nu$ Geodesic Sphere |
| **Hex Honeyball** | <img src="img/geodesic/honeyball.png" width="90" alt="Honeyball"> | **Honeyball (Honeycomb Sphere)** | Variable | Variable | Variable | Hexagonal/Pentagonal cells | Geodesic dual |

---

## 4. Julia API Usage

```julia
using Unihedron

# Geodesic spheres by frequency ν (1, 2, 3, ...)
g1 = geodesic_sphere(1; radius=1.0)  # Regular icosahedron (V=12, F=20)
g2 = geodesic_sphere(2; radius=1.0)  # 2v geodesic sphere (V=42, F=80)
g3 = geodesic_sphere(3; radius=1.0)  # 3v geodesic sphere (V=92, F=180)

# Buckyballs / Goldberg Polyhedra (Duals of Geodesic Spheres)
b2 = buckyball(2)                    # C80 fullerene (12 pentagons, 30 hexagons)
b3 = buckyball(3)                    # C180 fullerene (12 pentagons, 80 hexagons)
gp = goldberg_polyhedron(2)          # Alias for buckyball

# Honeyball (Honeycomb ball)
hb = honeyball(2; radius=1.0)
```
