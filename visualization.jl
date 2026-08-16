using GLMakie
using GLMakie.GeometryBasics
using GLMakie.Colors
using Random

# --- 6-Color Polygon Type Palette & Handed Mirror Shading ---
# 1. Vermilion dye, 2. Celtic blue, 3. Lincoln green, 4. Saffron, 5. Tyrian purple, 6. Brownish gray
const POLYGON_TYPE_PALETTE = [
    RGB{Float32}(0.890f0, 0.259f0, 0.204f0),  # 1. Vermilion dye (#E34234)
    RGB{Float32}(0.141f0, 0.420f0, 0.808f0),  # 2. Celtic blue (#246BCE)
    RGB{Float32}(0.098f0, 0.349f0, 0.020f0),  # 3. Lincoln green (#195905)
    RGB{Float32}(0.957f0, 0.769f0, 0.188f0),  # 4. Saffron (#F4C430)
    RGB{Float32}(0.400f0, 0.008f0, 0.235f0),  # 5. Tyrian purple (#66023C)
    RGB{Float32}(0.478f0, 0.431f0, 0.392f0)   # 6. Brownish gray (#7A6E64)
]

function _darken_color(c::RGB{Float32}, factor::Float32=0.65f0)
    return RGB{Float32}(c.r * factor, c.g * factor, c.b * factor)
end

function _darken_color(c::Colorant, factor::Real=0.65)
    rgb = RGB{Float32}(c)
    return _darken_color(rgb, Float32(factor))
end

"""
    get_polygon_colors(num_types::Int) -> Vector{RGB{Float32}}

Returns a palette of colors for `num_types` distinct polygon types.
Uses the 6 official colors up to type 6. For 7 or more types, randomizes all needed colors.
"""
function get_polygon_colors(num_types::Int)
    if num_types <= 6
        return copy(POLYGON_TYPE_PALETTE[1:max(1, num_types)])
    else
        # For > 6 types (7 or more), randomize all colors
        rng = Random.MersenneTwister(1337)
        return [RGB{Float32}(rand(rng, Float32), rand(rng, Float32), rand(rng, Float32)) for _ in 1:num_types]
    end
end

# --- 2D Polygon Display ---

"""
    display_polygon!(ax::Axis, poly::AbstractVector{<:Pt2}; 
                     color=:dodgerblue, 
                     edgecolor=:black, 
                     linewidth=2.0, 
                     show_vertices=true, 
                     vertex_color=:crimson, 
                     vertex_size=10, 
                     show_labels=false, 
                     label_color=:black, 
                     label_size=14)

Plots a 2D polygon onto an existing Makie `Axis`.
"""
function display_polygon!(ax::Axis, poly::AbstractVector{<:Pt2}; 
                          color=:dodgerblue, 
                          edgecolor=:black, 
                          linewidth=2.0, 
                          show_vertices=true, 
                          vertex_color=:crimson, 
                          vertex_size=10, 
                          show_labels=false, 
                          label_color=:black, 
                          label_size=14)
    pts = [Point2f(p[1], p[2]) for p in poly]
    
    # 1. Fill polygon (solid)
    poly!(ax, pts; color=color, strokewidth=linewidth, strokecolor=edgecolor)
    
    # 2. Vertices
    if show_vertices
        scatter!(ax, pts; color=vertex_color, markersize=vertex_size)
    end
    
    # 3. Vertex numbering labels
    if show_labels
        for (i, p) in enumerate(pts)
            text!(ax, string(i), position=p, align=(:center, :bottom), color=label_color, fontsize=label_size, offset=(0, 4))
        end
    end
    
    return ax
end

"""
    display_polygon(poly::AbstractVector{<:Pt2}; 
                    title="2D Polygon", 
                    size=(600, 600), 
                    kwargs...)
    plot_polygon(poly::AbstractVector{<:Pt2}; kwargs...)

Opens a Makie window displaying a 2D polygon. Returns `(Figure, Axis)`.
"""
function display_polygon(poly::AbstractVector{<:Pt2}; 
                         title::AbstractString="2D Polygon", 
                         size::Tuple{Int, Int}=(600, 600), 
                         kwargs...)
    fig = Figure(size=size)
    ax = Axis(fig[1, 1], aspect=DataAspect(), title=title)
    hidespines!(ax)
    hidedecorations!(ax, grid=false)
    display_polygon!(ax, poly; kwargs...)
    return fig
end

const plot_polygon = display_polygon
const plot_polygon! = display_polygon!

# --- 3D Polygon Display ---

"""
    display_polygon!(ax::Axis3, poly::AbstractVector{<:Pt3}; 
                     color=:dodgerblue, 
                     edgecolor=:black, 
                     linewidth=2.0, 
                     show_vertices=true, 
                     vertex_color=:crimson, 
                     vertex_size=10, 
                     show_labels=false, 
                     label_color=:black, 
                     label_size=14)

Plots a 3D polygon onto an existing Makie `Axis3`.
"""
function display_polygon!(ax::Axis3, poly::AbstractVector{<:Pt3}; 
                          color=:dodgerblue, 
                          edgecolor=:black, 
                          linewidth=2.0, 
                          show_vertices=true, 
                          vertex_color=:crimson, 
                          vertex_size=10, 
                          show_labels=false, 
                          label_color=:black, 
                          label_size=14)
    pts = [Point3f(p[1], p[2], p[3]) for p in poly]
    n = length(pts)
    
    # 1. Triangulate planar/skew 3D polygon (solid with no transparency, unshaded flat colors)
    tris = [TriangleFace(1, i, i+1) for i in 2:(n-1)]
    m = normal_mesh(pts, tris)
    mesh!(ax, m; color=color, transparency=false, shading=NoShading)
    
    # 2. Outline boundary edges
    edge_pts = Point3f[]
    for i in 1:n
        push!(edge_pts, pts[i])
        push!(edge_pts, pts[i == n ? 1 : i + 1])
    end
    linesegments!(ax, edge_pts; color=edgecolor, linewidth=linewidth)
    
    # 3. Vertices
    if show_vertices
        scatter!(ax, pts; color=vertex_color, markersize=vertex_size)
    end
    
    # 4. Vertex labels
    if show_labels
        for (i, p) in enumerate(pts)
            text!(ax, string(i), position=p, color=label_color, fontsize=label_size)
        end
    end
    
    return ax
end

"""
    display_polygon(poly::AbstractVector{<:Pt3}; 
                    title=nothing, 
                    size=(700, 700), 
                    show_axis::Bool=false,
                    backgroundcolor=:white,
                    kwargs...)

Opens a Makie window displaying a 3D polygon on a plain background with no axes. Returns `Figure`.
"""
function display_polygon(poly::AbstractVector{<:Pt3}; 
                         title::Union{AbstractString, Nothing}=nothing, 
                         size::Tuple{Int, Int}=(700, 700), 
                         show_axis::Bool=false,
                         backgroundcolor=:white,
                         kwargs...)
    fig = Figure(size=size, backgroundcolor=backgroundcolor)
    ax = Axis3(fig[1, 1], aspect=:data, title=(title !== nothing ? title : ""))
    if !show_axis
        hidedecorations!(ax)
        hidespines!(ax)
    end
    display_polygon!(ax, poly; show_vertices=false, kwargs...)
    return fig
end

# --- 3D Polyhedron Display ---

"""
    display_polyhedron!(ax::Axis3, P::Polyhedron; 
                        color=:auto, 
                        edgecolor=:black, 
                        linewidth=2.0, 
                        show_faces=true, 
                        show_edges=true, 
                        show_vertices=false, 
                        vertex_color=:crimson, 
                        vertex_size=8, 
                        color_by_face_size=false, 
                        colormap=:viridis, 
                        show_vertex_labels=false, 
                        show_face_labels=false, 
                        label_color=:black, 
                        label_size=12)

Renders a 3D `Polyhedron` onto an existing Makie `Axis3`.
By default (`color=:auto`), automatically classifies polygon types and colors each face type according to the
official 6-color palette (1. Vermilion dye, 2. Celtic blue, 3. Lincoln green, 4. Saffron, 5. Tyrian purple, 6. Brownish gray,
or randomized for >=7 types). Chiral handed mirror faces receive a darker version of the same color.
"""
function display_polyhedron!(ax::Axis3, P::Polyhedron; 
                            color=:auto, 
                            edgecolor=:black, 
                            linewidth=2.0, 
                            show_faces=true, 
                            show_edges=true, 
                            show_vertices=false, 
                            vertex_color=:crimson, 
                            vertex_size=8, 
                            color_by_face_size=false, 
                            colormap=:viridis, 
                            show_vertex_labels=false, 
                            show_face_labels=false, 
                            label_color=:black, 
                            label_size=12)
    pts = [Point3f(p[1], p[2], p[3]) for p in P.v]
    
    # 1. Shaded solid faces via dynamic triangulation of n-gons (no transparency)
    if show_faces && !isempty(P.f)
        if color_by_face_size
            mesh_pts = Point3f[]
            mesh_tris = TriangleFace{Int}[]
            vert_colors = Float64[]
            
            for face in P.f
                n = length(face)
                base_idx = length(mesh_pts)
                for idx in face
                    p = P.v[idx]
                    push!(mesh_pts, Point3f(p[1], p[2], p[3]))
                    push!(vert_colors, Float64(n))
                end
                for i in 2:(n-1)
                    push!(mesh_tris, TriangleFace(base_idx + 1, base_idx + i, base_idx + i + 1))
                end
            end
            
            m = normal_mesh(mesh_pts, mesh_tris)
            mesh!(ax, m; color=vert_colors, colormap=colormap, transparency=false, shading=NoShading)
        elseif color === :auto || color === nothing
            # Color by polygon type with darker shade for handed mirror reflections (unshaded flat)
            types, is_mirror = classify_faces_with_handedness(P)
            num_types = isempty(types) ? 1 : maximum(types)
            base_colors = get_polygon_colors(num_types)
            
            mesh_pts = Point3f[]
            mesh_tris = TriangleFace{Int}[]
            mesh_colors = RGB{Float32}[]
            
            for (face_idx, face) in enumerate(P.f)
                n = length(face)
                base_idx = length(mesh_pts)
                t = types[face_idx]
                base_c = base_colors[t]
                face_col = is_mirror[face_idx] ? _darken_color(base_c, 0.65f0) : base_c
                
                for idx in face
                    p = P.v[idx]
                    push!(mesh_pts, Point3f(p[1], p[2], p[3]))
                    push!(mesh_colors, face_col)
                end
                for i in 2:(n-1)
                    push!(mesh_tris, TriangleFace(base_idx + 1, base_idx + i, base_idx + i + 1))
                end
            end
            
            m = normal_mesh(mesh_pts, mesh_tris)
            mesh!(ax, m; color=mesh_colors, transparency=false, shading=NoShading)
        else
            # Explicit user single color override (unshaded flat)
            tris = TriangleFace{Int}[]
            for face in P.f
                n = length(face)
                for i in 2:(n-1)
                    push!(tris, TriangleFace(face[1], face[i], face[i+1]))
                end
            end
            m = normal_mesh(pts, tris)
            mesh!(ax, m; color=color, transparency=false, shading=NoShading)
        end
    end
    
    # 2. Wireframe edges
    if show_edges && !isempty(P.f)
        edges = Set{Tuple{Int, Int}}()
        for face in P.f
            n = length(face)
            for i in 1:n
                u = face[i]
                v = face[i == n ? 1 : i + 1]
                push!(edges, (min(u, v), max(u, v)))
            end
        end
        
        edge_pts = Point3f[]
        for (u, v) in edges
            push!(edge_pts, pts[u])
            push!(edge_pts, pts[v])
        end
        linesegments!(ax, edge_pts; color=edgecolor, linewidth=linewidth)
    end
    
    # 3. Vertices
    if show_vertices
        scatter!(ax, pts; color=vertex_color, markersize=vertex_size)
    end
    
    # 4. Vertex index labels
    if show_vertex_labels
        for (i, p) in enumerate(pts)
            text!(ax, string(i), position=p, color=label_color, fontsize=label_size)
        end
    end
    
    # 5. Face index labels at face centroids
    if show_face_labels
        for (f_idx, face) in enumerate(P.f)
            c = centroid([P.v[i] for i in face])
            text!(ax, string(f_idx), position=Point3f(c[1], c[2], c[3]), color=label_color, fontsize=label_size)
        end
    end
    
    return ax
end

"""
    display_polyhedron(P::Polyhedron; 
                       title=nothing, 
                       size=(800, 800), 
                       show_axis::Bool=false,
                       backgroundcolor=:white,
                       kwargs...)
    plot_polyhedron(P::Polyhedron; kwargs...)

Opens an interactive 3D Makie window displaying the given `Polyhedron` on a clean, plain background
with no axes, grids, or vertex markers by default.
Returns the created `Figure`.
"""
function display_polyhedron(P::Polyhedron; 
                            title::Union{AbstractString, Nothing}=nothing, 
                            size::Tuple{Int, Int}=(800, 800), 
                            show_axis::Bool=false,
                            backgroundcolor=:white,
                            kwargs...)
    fig = Figure(size=size, backgroundcolor=backgroundcolor)
    ax = Axis3(fig[1, 1], aspect=:data, title=(title !== nothing ? title : ""))
    if !show_axis
        hidedecorations!(ax)
        hidespines!(ax)
    end
    display_polyhedron!(ax, P; show_vertices=false, kwargs...)
    return fig
end

const plot_polyhedron = display_polyhedron
const plot_polyhedron! = display_polyhedron!

# --- Unified `viz` dispatcher ---

"""
    viz(poly_or_polyhedron; kwargs...)
    viz(name::Symbol; kwargs...)

Unified visualization tool. Automatically displays 2D polygons, 3D polygons, polyhedra,
or named solids (e.g. `viz(:dodecahedron)` or `viz(:J84)`).
"""
viz(poly::AbstractVector{<:Pt2}; kwargs...) = display_polygon(poly; kwargs...)
viz(poly::AbstractVector{<:Pt3}; kwargs...) = display_polygon(poly; kwargs...)
viz(P::Polyhedron; kwargs...) = display_polyhedron(P; kwargs...)

function viz(name::Symbol; kwargs...)
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
    elseif haskey(EXCLUDED_COOKSON_MAP, name)
        excluded_cookson(name)
    elseif haskey(JOHNSON_SOLID_MAP, name)
        johnson(name)
    else
        error("Unknown solid symbol: :$name. Available across Platonic, Archimedean, Kepler-Poinsot, Catalan, Cookson (H1-H8), and Johnson families.")
    end
    return display_polyhedron(P; title=titlecase(replace(string(name), "_" => " ")), kwargs...)
end
