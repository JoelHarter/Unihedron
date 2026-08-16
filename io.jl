# Unihedron I/O: Exporters, Importers, and Image Renderers for Polyhedra and Polygons
# Supports OFF, OBJ, JSON, HDF5, STL, CSV, and Image formats (PNG, JPG, JPEG, SVG, PDF).

using HDF5
using JSON3
using LinearAlgebra
using StaticArrays
using GLMakie
using GLMakie.GeometryBasics

# --- Default File Format Configuration ---
const DEFAULT_POLYHEDRON_FORMAT = :off

const IMAGE_EXTENSIONS = (".png", ".jpg", ".jpeg", ".svg", ".pdf")

function _infer_format(filepath::AbstractString; default::Symbol=DEFAULT_POLYHEDRON_FORMAT)
    ext = lowercase(splitext(filepath)[2])
    if ext == ".off"
        return :off
    elseif ext == ".obj"
        return :obj
    elseif ext == ".json"
        return :json
    elseif ext in (".h5", ".hdf5")
        return :hdf5
    elseif ext == ".stl"
        return :stl
    elseif ext == ".csv"
        return :csv
    elseif ext in IMAGE_EXTENSIONS
        return :image
    elseif isempty(ext)
        return default
    else
        error("Unsupported file extension: $ext. Supported: .off, .obj, .json, .h5, .hdf5, .stl, .csv, .png, .jpg, .svg, .pdf")
    end
end

function _ensure_extension(filepath::AbstractString, fmt::Symbol)
    ext = splitext(filepath)[2]
    if !isempty(ext)
        return filepath
    end
    if fmt == :off
        return filepath * ".off"
    elseif fmt == :obj
        return filepath * ".obj"
    elseif fmt == :json
        return filepath * ".json"
    elseif fmt == :hdf5
        return filepath * ".h5"
    elseif fmt == :stl
        return filepath * ".stl"
    elseif fmt == :csv
        return filepath * ".csv"
    elseif fmt == :image
        return filepath * ".png"
    end
    return filepath
end

# ============================================================================
# 1. OFF (Object File Format) - Canonical standard for arbitrary n-gons
# ============================================================================

"""
    save_off(P::Polyhedron, io_or_file)

Writes a `Polyhedron` to OFF (Object File Format). Uses standard 0-indexed vertex indices.
"""
function save_off(P::Polyhedron, io::IO)
    println(io, "OFF")
    println(io, length(P.v), " ", length(P.f), " 0")
    for v in P.v
        println(io, v[1], " ", v[2], " ", v[3])
    end
    for face in P.f
        println(io, length(face), " ", join(face .- 1, " "))
    end
end

function save_off(P::Polyhedron, filepath::AbstractString)
    open(filepath, "w") do io
        save_off(P, io)
    end
    return filepath
end

"""
    load_off(filepath::AbstractString) -> Polyhedron{Float64}

Reads a `Polyhedron` from an OFF file.
"""
function load_off(filepath::AbstractString)
    lines = filter(l -> !isempty(strip(l)) && !startswith(strip(l), "#"), readlines(filepath))
    header = strip(lines[1])
    
    line_idx = 2
    if header != "OFF" && startswith(header, "OFF")
        counts_str = header[4:end]
        tokens = split(counts_str)
        nV = parse(Int, tokens[1])
        nF = parse(Int, tokens[2])
    else
        tokens = split(lines[line_idx])
        nV = parse(Int, tokens[1])
        nF = parse(Int, tokens[2])
        line_idx += 1
    end
    
    vertices = Pt3{Float64}[]
    for _ in 1:nV
        toks = split(lines[line_idx])
        push!(vertices, Pt3{Float64}(parse(Float64, toks[1]), parse(Float64, toks[2]), parse(Float64, toks[3])))
        line_idx += 1
    end
    
    faces = Vector{Int}[]
    for _ in 1:nF
        toks = split(lines[line_idx])
        n = parse(Int, toks[1])
        # OFF is 0-indexed -> convert to 1-indexed for Julia
        face = [parse(Int, toks[k]) + 1 for k in 2:(n+1)]
        push!(faces, face)
        line_idx += 1
    end
    
    return Polyhedron(vertices, faces)
end

# ============================================================================
# 2. Wavefront OBJ
# ============================================================================

"""
    save_obj(P::Polyhedron, io_or_file)

Writes a `Polyhedron` to Wavefront OBJ format.
"""
function save_obj(P::Polyhedron, io::IO)
    println(io, "# Unihedron Polyhedron Export")
    println(io, "# Vertices: $(length(P.v)), Faces: $(length(P.f))")
    for v in P.v
        println(io, "v ", v[1], " ", v[2], " ", v[3])
    end
    for face in P.f
        println(io, "f ", join(face, " "))
    end
end

function save_obj(P::Polyhedron, filepath::AbstractString)
    open(filepath, "w") do io
        save_obj(P, io)
    end
    return filepath
end

function load_obj(filepath::AbstractString)
    vertices = Pt3{Float64}[]
    faces = Vector{Int}[]
    for line in eachline(filepath)
        s = strip(line)
        isempty(s) && continue
        if startswith(s, "v ")
            toks = split(s)
            push!(vertices, Pt3{Float64}(parse(Float64, toks[2]), parse(Float64, toks[3]), parse(Float64, toks[4])))
        elseif startswith(s, "f ")
            toks = split(s)[2:end]
            face = [parse(Int, split(t, "/")[1]) for t in toks]
            push!(faces, face)
        end
    end
    return Polyhedron(vertices, faces)
end

# ============================================================================
# 3. JSON
# ============================================================================

"""
    save_json(P::Polyhedron, filepath; name="Polyhedron")

Writes a `Polyhedron` to a JSON file.
"""
function save_json(P::Polyhedron, filepath::AbstractString; name::AbstractString="Polyhedron")
    dict = Dict{String, Any}(
        "name" => name,
        "num_vertices" => length(P.v),
        "num_faces" => length(P.f),
        "vertices" => [[v[1], v[2], v[3]] for v in P.v],
        "faces" => P.f
    )
    open(filepath, "w") do io
        JSON3.write(io, dict)
    end
    return filepath
end

function load_json(filepath::AbstractString)
    data = open(filepath, "r") do io
        JSON3.read(io)
    end
    verts = Pt3{Float64}[Pt3{Float64}(v[1], v[2], v[3]) for v in data["vertices"]]
    faces = Vector{Int}[Vector{Int}(f) for f in data["faces"]]
    return Polyhedron(verts, faces)
end

# ============================================================================
# 4. HDF5 Binary Storage (Single & Multi-Solid Database)
# ============================================================================

"""
    save_hdf5(P::Polyhedron, filepath; group="polyhedron", name="Polyhedron")

Writes a `Polyhedron` to an HDF5 dataset.
"""
function save_hdf5(P::Polyhedron, filepath::AbstractString; group::AbstractString="polyhedron", name::AbstractString="Polyhedron")
    h5open(filepath, isfile(filepath) ? "r+" : "w") do h5
        if haskey(h5, group)
            delete_object(h5, group)
        end
        g = create_group(h5, group)
        
        # 3 x V matrix
        v_mat = hcat([[v[1], v[2], v[3]] for v in P.v]...)
        g["vertices"] = v_mat
        
        # CSR format for ragged n-gon faces
        flat_faces = Int[]
        offsets = Int[0]
        for face in P.f
            append!(flat_faces, face)
            push!(offsets, length(flat_faces))
        end
        g["faces_flat"] = flat_faces
        g["face_offsets"] = offsets
        
        HDF5.attributes(g)["name"] = name
        HDF5.attributes(g)["num_vertices"] = length(P.v)
        HDF5.attributes(g)["num_faces"] = length(P.f)
    end
    return filepath
end

"""
    load_hdf5(filepath::AbstractString; group="polyhedron") -> Polyhedron{Float64}

Reads a `Polyhedron` from an HDF5 group.
"""
function load_hdf5(filepath::AbstractString; group::AbstractString="polyhedron")
    h5open(filepath, "r") do h5
        g = h5[group]
        v_mat = read(g["vertices"])
        pts = Pt3{Float64}[Pt3{Float64}(v_mat[:, i]...) for i in 1:size(v_mat, 2)]
        flat_faces = read(g["faces_flat"])
        offsets = read(g["face_offsets"])
        faces = Vector{Int}[]
        for i in 1:(length(offsets) - 1)
            push!(faces, flat_faces[(offsets[i]+1):offsets[i+1]])
        end
        Polyhedron(pts, faces)
    end
end

# ============================================================================
# 5. STL (Stereolithography for 3D Printing)
# ============================================================================

"""
    save_stl(P::Polyhedron, filepath; name="Solid")

Writes a `Polyhedron` to an ASCII STL file, fan-triangulating all n-gon faces.
"""
function save_stl(P::Polyhedron, filepath::AbstractString; name::AbstractString="Solid")
    open(filepath, "w") do io
        println(io, "solid ", name)
        for face in P.f
            n = length(face)
            norm_v = face_normal([P.v[i] for i in face])
            for i in 2:(n-1)
                println(io, "  facet normal ", norm_v[1], " ", norm_v[2], " ", norm_v[3])
                println(io, "    outer loop")
                for idx in (face[1], face[i], face[i+1])
                    v = P.v[idx]
                    println(io, "      vertex ", v[1], " ", v[2], " ", v[3])
                end
                println(io, "    endloop")
                println(io, "  endfacet")
            end
        end
        println(io, "endsolid ", name)
    end
    return filepath
end

# ============================================================================
# 6. Image Rendering & Export (PNG, JPG, SVG, PDF)
# ============================================================================

"""
    save_polyhedron_image(P::Polyhedron, filepath::AbstractString; 
                          size=(800, 800), 
                          px_per_unit=2.0, 
                          color=(:dodgerblue, 0.8), 
                          edgecolor=:black, 
                          linewidth=2.0, 
                          color_by_face_size=false, 
                          title=nothing, 
                          kwargs...)

Renders a 3D `Polyhedron` using Makie and saves it as an image file (.png, .jpg, .svg, .pdf).
"""
function save_polyhedron_image(P::Polyhedron, filepath::AbstractString; 
                               size::Tuple{Int, Int}=(800, 800), 
                               px_per_unit::Real=2.0, 
                               color=(:dodgerblue, 0.8), 
                               edgecolor=:black, 
                               linewidth=2.0, 
                               color_by_face_size::Bool=false, 
                               title::Union{AbstractString, Nothing}=nothing, 
                               kwargs...)
    fig = display_polyhedron(P; 
                             size=size, 
                             color=color, 
                             edgecolor=edgecolor, 
                             linewidth=linewidth, 
                             color_by_face_size=color_by_face_size, 
                             title=title, 
                             kwargs...)
    GLMakie.save(filepath, fig; px_per_unit=Float32(px_per_unit))
    return filepath
end

"""
    save_polygon_image(poly::AbstractVector{<:Union{Pt2, Pt3}}, filepath::AbstractString; 
                       size=(600, 600), 
                       px_per_unit=2.0, 
                       color=(:dodgerblue, 0.6), 
                       edgecolor=:black, 
                       linewidth=2.0, 
                       title="Polygon", 
                       kwargs...)

Renders a 2D or 3D polygon using Makie and saves it as an image file.
"""
function save_polygon_image(poly::AbstractVector{<:Pt2}, filepath::AbstractString; 
                            size::Tuple{Int, Int}=(600, 600), 
                            px_per_unit::Real=2.0, 
                            color=(:dodgerblue, 0.6), 
                            edgecolor=:black, 
                            linewidth=2.0, 
                            title::AbstractString="2D Polygon", 
                            kwargs...)
    fig = display_polygon(poly; size=size, color=color, edgecolor=edgecolor, linewidth=linewidth, title=title, kwargs...)
    GLMakie.save(filepath, fig; px_per_unit=Float32(px_per_unit))
    return filepath
end

function save_polygon_image(poly::AbstractVector{<:Pt3}, filepath::AbstractString; 
                            size::Tuple{Int, Int}=(700, 700), 
                            px_per_unit::Real=2.0, 
                            color=(:dodgerblue, 0.7), 
                            edgecolor=:black, 
                            linewidth=2.0, 
                            title::AbstractString="3D Polygon", 
                            kwargs...)
    fig = display_polygon(poly; size=size, color=color, edgecolor=edgecolor, linewidth=linewidth, title=title, kwargs...)
    GLMakie.save(filepath, fig; px_per_unit=Float32(px_per_unit))
    return filepath
end

"""
    save_image(poly_or_polyhedron, filepath::AbstractString; kwargs...)
    save_image(name::Symbol, filepath::AbstractString; kwargs...)

Unified image exporter for polyhedra, 2D polygons, 3D polygons, or named solid symbols.
"""
save_image(P::Polyhedron, filepath::AbstractString; kwargs...) = save_polyhedron_image(P, filepath; kwargs...)
save_image(poly::AbstractVector{<:Union{Pt2, Pt3}}, filepath::AbstractString; kwargs...) = save_polygon_image(poly, filepath; kwargs...)

function save_image(name::Symbol, filepath::AbstractString; kwargs...)
    P = if haskey(PLATONIC_SOLID_MAP, name)
        platonic(name)
    elseif haskey(ARCHIMEDEAN_SOLID_MAP, name)
        archimedean(name)
    elseif haskey(KEPLER_POINSOT_SOLID_MAP, name)
        kepler_poinsot(name)
    elseif haskey(CATALAN_SOLID_MAP, name)
        catalan(name)
    elseif haskey(COOKSON_SOLID_MAP, name)
        cookson(name)
    elseif haskey(JOHNSON_SOLID_MAP, name)
        johnson(name)
    else
        error("Unknown solid symbol: :$name")
    end
    title_str = titlecase(replace(string(name), "_" => " "))
    return save_polyhedron_image(P, filepath; title=title_str, kwargs...)
end

# ============================================================================
# 7. Polygons I/O (2D & 3D Tabular & JSON)
# ============================================================================

"""
    save_polygon(poly::AbstractVector{<:Union{Pt2, Pt3}}, filepath)

Saves a 2D or 3D polygon to CSV, JSON, or Image (PNG/JPG/SVG).
"""
function save_polygon(poly::AbstractVector{<:Pt2}, filepath::AbstractString; kwargs...)
    fmt = _infer_format(filepath; default=:csv)
    target = _ensure_extension(filepath, fmt)
    if fmt == :image
        return save_polygon_image(poly, target; kwargs...)
    elseif fmt == :json
        open(target, "w") do io
            JSON3.write(io, Dict("type" => "Polygon2D", "vertices" => [[p[1], p[2]] for p in poly]))
        end
    else
        open(target, "w") do io
            println(io, "x,y")
            for p in poly
                println(io, p[1], ",", p[2])
            end
        end
    end
    return target
end

function save_polygon(poly::AbstractVector{<:Pt3}, filepath::AbstractString; kwargs...)
    fmt = _infer_format(filepath; default=:csv)
    target = _ensure_extension(filepath, fmt)
    if fmt == :image
        return save_polygon_image(poly, target; kwargs...)
    elseif fmt == :json
        open(target, "w") do io
            JSON3.write(io, Dict("type" => "Polygon3D", "vertices" => [[p[1], p[2], p[3]] for p in poly]))
        end
    else
        open(target, "w") do io
            println(io, "x,y,z")
            for p in poly
                println(io, p[1], ",", p[2], ",", p[3])
            end
        end
    end
    return target
end

"""
    load_polygon2d(filepath::AbstractString) -> Vector{Pt2{Float64}}
    load_polygon3d(filepath::AbstractString) -> Vector{Pt3{Float64}}
"""
function load_polygon2d(filepath::AbstractString)
    fmt = _infer_format(filepath; default=:csv)
    if fmt == :json
        data = open(filepath, "r") do io; JSON3.read(io); end
        return Pt2{Float64}[Pt2{Float64}(p[1], p[2]) for p in data["vertices"]]
    else
        pts = Pt2{Float64}[]
        for (i, line) in enumerate(eachline(filepath))
            i == 1 && contains(line, "x") && continue
            toks = split(strip(line), ",")
            push!(pts, Pt2{Float64}(parse(Float64, toks[1]), parse(Float64, toks[2])))
        end
        return pts
    end
end

function load_polygon3d(filepath::AbstractString)
    fmt = _infer_format(filepath; default=:csv)
    if fmt == :json
        data = open(filepath, "r") do io; JSON3.read(io); end
        return Pt3{Float64}[Pt3{Float64}(p[1], p[2], p[3]) for p in data["vertices"]]
    else
        pts = Pt3{Float64}[]
        for (i, line) in enumerate(eachline(filepath))
            i == 1 && contains(line, "x") && continue
            toks = split(strip(line), ",")
            push!(pts, Pt3{Float64}(parse(Float64, toks[1]), parse(Float64, toks[2]), parse(Float64, toks[3])))
        end
        return pts
    end
end

# ============================================================================
# 8. Unified Dispatcher & Exporter
# ============================================================================

"""
    save_polyhedron(P::Polyhedron, filepath::AbstractString; format=nothing, name="Polyhedron", kwargs...)

Saves a `Polyhedron` to file. Defaults to `.off` if no extension or format is specified.
Supported formats: `:off`, `:obj`, `:json`, `:hdf5`, `:stl`, and image formats (`.png`, `.jpg`, `.svg`, `.pdf`).
"""
function save_polyhedron(P::Polyhedron, filepath::AbstractString; format::Union{Symbol, Nothing}=nothing, name::AbstractString="Polyhedron", kwargs...)
    fmt = format !== nothing ? format : _infer_format(filepath; default=DEFAULT_POLYHEDRON_FORMAT)
    target = _ensure_extension(filepath, fmt)
    
    if fmt == :image
        save_polyhedron_image(P, target; title=name, kwargs...)
    elseif fmt == :off
        save_off(P, target)
    elseif fmt == :obj
        save_obj(P, target)
    elseif fmt == :json
        save_json(P, target; name=name)
    elseif fmt in (:h5, :hdf5)
        save_hdf5(P, target; group="polyhedron", name=name)
    elseif fmt == :stl
        save_stl(P, target; name=name)
    else
        error("Unsupported format: $fmt")
    end
    return target
end

"""
    load_polyhedron(filepath::AbstractString; format=nothing, group="polyhedron") -> Polyhedron{Float64}

Loads a `Polyhedron` from `.off`, `.obj`, `.json`, or `.h5` / `.hdf5`.
"""
function load_polyhedron(filepath::AbstractString; format::Union{Symbol, Nothing}=nothing, group::AbstractString="polyhedron")
    fmt = format !== nothing ? format : _infer_format(filepath; default=DEFAULT_POLYHEDRON_FORMAT)
    if fmt == :off
        return load_off(filepath)
    elseif fmt == :obj
        return load_obj(filepath)
    elseif fmt == :json
        return load_json(filepath)
    elseif fmt in (:h5, :hdf5)
        return load_hdf5(filepath; group=group)
    else
        error("Unsupported load format: $fmt")
    end
end

# ============================================================================
# 9. Complete Database HDF5 Archive Generator
# ============================================================================

"""
    export_database_hdf5(filepath::AbstractString="unihedron_solids.h5")

Generates a unified master HDF5 archive containing all 130+ solids:
- 5 Platonic Solids (`/platonic/...`)
- 13 Archimedean Solids (`/archimedean/...`)
- 4 Kepler-Poinsot Star Polyhedra (`/kepler_poinsot/...`)
- 13 Catalan Solids (`/catalan/...`)
- 6 Cookson Solids (`/cookson/...`)
- 92 Johnson Solids (`/johnson/J1` to `/johnson/J92`)
"""
function export_database_hdf5(filepath::AbstractString="unihedron_solids.h5")
    target = _ensure_extension(filepath, :hdf5)
    
    h5open(target, "w") do h5
        # 1. Platonics
        for name in PLATONIC_SOLID_ORDER
            P = platonic(name)
            save_hdf5(P, target; group="platonic/$(name)", name=string(name))
        end
        
        # 2. Archimedeans
        for name in ARCHIMEDEAN_SOLID_ORDER
            P = archimedean(name)
            save_hdf5(P, target; group="archimedean/$(name)", name=string(name))
        end
        
        # 3. Kepler-Poinsot
        for name in KEPLER_POINSOT_SOLID_ORDER
            P = kepler_poinsot(name)
            save_hdf5(P, target; group="kepler_poinsot/$(name)", name=string(name))
        end
        
        # 4. Catalans
        for name in CATALAN_SOLID_ORDER
            P = catalan(name)
            save_hdf5(P, target; group="catalan/$(name)", name=string(name))
        end
        
        # 5. Cooksons (C1 to C12)
        for i in 1:12
            name_sym = COOKSON_SOLID_ORDER[i]
            P = cookson(name_sym)
            save_hdf5(P, target; group="cookson/C$(i)", name=cookson_name(i))
        end
        
        # 6. Johnson Solids (J1 to J92)
        for i in 1:92
            P = johnson(i)
            save_hdf5(P, target; group="johnson/J$(i)", name="J$(i): $(johnson_name(i))")
        end
    end
    
    return target
end
