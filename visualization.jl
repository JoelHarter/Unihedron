# Visualization & Display Functions for 2D Polygons, 3D Polygons, and Polyhedra using Makie

using GLMakie
using GLMakie.GeometryBasics

# --- 2D Polygon Display ---

"""
    display_polygon!(ax::Axis, poly::AbstractVector{<:Pt2}; 
                     color=(:dodgerblue, 0.6), 
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
                          color=(:dodgerblue, 0.6), 
                          edgecolor=:black, 
                          linewidth=2.0, 
                          show_vertices=true, 
                          vertex_color=:crimson, 
                          vertex_size=10, 
                          show_labels=false, 
                          label_color=:black, 
                          label_size=14)
    pts = [Point2f(p[1], p[2]) for p in poly]
    
    # 1. Fill polygon
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
                     color=(:dodgerblue, 0.7), 
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
                          color=(:dodgerblue, 0.7), 
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
    
    # 1. Triangulate planar/skew 3D polygon
    tris = [TriangleFace(1, i, i+1) for i in 2:(n-1)]
    m = normal_mesh(pts, tris)
    mesh!(ax, m; color=color)
    
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
                    title="3D Polygon", 
                    size=(700, 700), 
                    kwargs...)

Opens a Makie window displaying a 3D polygon in an interactive 3D viewport. Returns `Figure`.
"""
function display_polygon(poly::AbstractVector{<:Pt3}; 
                         title::AbstractString="3D Polygon", 
                         size::Tuple{Int, Int}=(700, 700), 
                         kwargs...)
    fig = Figure(size=size)
    ax = Axis3(fig[1, 1], aspect=:data, title=title)
    display_polygon!(ax, poly; kwargs...)
    return fig
end

# --- 3D Polyhedron Display ---

"""
    display_polyhedron!(ax::Axis3, P::Polyhedron; 
                        color=(:dodgerblue, 0.8), 
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
Supports arbitrary n-gons (triangulated dynamically for shaded rendering), sharp wireframe outlines,
vertex scatter markers, and face/vertex index annotations.
"""
function display_polyhedron!(ax::Axis3, P::Polyhedron; 
                            color=(:dodgerblue, 0.8), 
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
    
    # 1. Shaded faces via dynamic triangulation of n-gons
    if show_faces && !isempty(P.f)
        tris = TriangleFace{Int}[]
        tri_values = Float64[]
        
        for face in P.f
            n = length(face)
            for i in 2:(n-1)
                push!(tris, TriangleFace(face[1], face[i], face[i+1]))
                push!(tri_values, Float64(n))
            end
        end
        
        m = normal_mesh(pts, tris)
        if color_by_face_size
            mesh!(ax, m; color=tri_values, colormap=colormap)
        else
            mesh!(ax, m; color=color)
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
                       title="Polyhedron", 
                       size=(800, 800), 
                       kwargs...)
    plot_polyhedron(P::Polyhedron; kwargs...)

Opens an interactive 3D Makie window displaying the given `Polyhedron`.
Returns the created `Figure`.
"""
function display_polyhedron(P::Polyhedron; 
                            title::Union{AbstractString, Nothing}=nothing, 
                            size::Tuple{Int, Int}=(800, 800), 
                            kwargs...)
    header = title !== nothing ? title : "Polyhedron (V=$(length(P.v)), F=$(length(P)))"
    fig = Figure(size=size)
    ax = Axis3(fig[1, 1], aspect=:data, title=header)
    display_polyhedron!(ax, P; kwargs...)
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
    elseif haskey(JOHNSON_SOLID_MAP, name)
        johnson(name)
    else
        error("Unknown solid symbol: :$name. Available across Platonic, Archimedean, Kepler-Poinsot, Catalan, Cookson, and Johnson families.")
    end
    return display_polyhedron(P; title=titlecase(replace(string(name), "_" => " ")), kwargs...)
end
