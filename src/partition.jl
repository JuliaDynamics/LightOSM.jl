using Metis
using DataStructures
using SparseArrays
using PyCall
using LightOSM
pydeck = pyimport("pydeck")

MAPBOX_TOKEN = "pk.eyJ1IjoiY2FwdGNoYW5qYWNrIiwiYSI6ImNrMzJ1enJoZjBueWwzY245ZDV0YjJ3Z3YifQ.VAWolOVu6eDYSnj3SC4NeQ"
MAXPBOX_STYLE = "mapbox://styles/captchanjack/ckepp735v2m2719lirl762qbi"
VIEWPORT_LOCATION = GeoLocation(-37.8142176, 144.9631608) # Melbourne (lat, lon)

view_state = pydeck.ViewState(longitude=VIEWPORT_LOCATION.lon,
                              latitude=VIEWPORT_LOCATION.lat,
                              zoom=13,
                              min_zoom=1,
                              max_zoom=25,
                              pitch=50,
                              bearing=-45)

g = graph_from_file("denver_10km.osm", graph_type=:light)

new_weights = copy(g.weights)

for (u, v, w) in zip(findnz(new_weights)...)
    if new_weights[v, u] == 0
        new_weights[v, u] = w
    end
end

mg = Metis.graph(new_weights)
# partitions = Metis.partition(mg, 9, alg=:RECURSIVE)
partitions = Metis.separator(mg)
node_to_part = Dict{Integer,Integer}(n => partitions[i] for (i, n) in g.index_to_node)

# colour mapping
partition_colour_mapping = Dict(
    1 => [rand(1:255), rand(1:255), rand(1:255)],
    2 => [rand(1:255), rand(1:255), rand(1:255)],
    3 => [rand(1:255), rand(1:255), rand(1:255)],
    4 => [rand(1:255), rand(1:255), rand(1:255)],
    5 => [rand(1:255), rand(1:255), rand(1:255)],
    6 => [rand(1:255), rand(1:255), rand(1:255)],
    7 => [rand(1:255), rand(1:255), rand(1:255)],
    8 => [rand(1:255), rand(1:255), rand(1:255)],
    9 => [rand(1:255), rand(1:255), rand(1:255)],
)

# Transform data
nodes_pydeck_data = [
    Dict(
        "ID" => id,
        "Type" => "Node",
        "Longitude" => node.location.lon,
        "Latitude" => node.location.lat,
        "Coordinates" => string([node.location.lon, node.location.lat]),
        "Name" => "",
        "Maxspeed" => "",
        "Lanes" => "",
        "Oneway" => "",
        "Colour" => partition_colour_mapping[node_to_part[id]],
        "Partition" => node_to_part[id]
    ) for (id, node) in g.nodes
]

# Build the layer
nodes_layer = pydeck.Layer("ScatterplotLayer",
                           nodes_pydeck_data,
                           pickable=true,
                           opacity=0.8,
                           stroked=true,
                           filled=true,
                           line_width_min_pixels=5,
                           line_width_max_pixels=5,
                           line_width_scale=1,
                           auto_highlight=true,
                           get_position=["Longitude", "Latitude"],
                           get_radius=1,
                           radius_scale=1,
                           get_line_width=1,
                           get_line_color="Colour",
                           get_fill_color="Colour")

# Define tooltip
tooltip_style = Dict(
    "color" => "white",
    "border-radius" => "10px",
    "border-color" => "dark grey",
    "background-color" => "CadetBlue",
    "font-family" => "Trebuchet MS",
    "z-index" => 3,
    "position" => "absolute"
)

nodes_tooltip = Dict(
    "html" => "<b>ID:</b> {ID}<br><b>Coordinates:</b> {Coordinates}<br><b>Partition</b>: {Partition}",
    "style" => tooltip_style
)

# Build the deck
r = pydeck.Deck(layers=[nodes_layer],
                initial_view_state=view_state,
                mapbox_key=MAPBOX_TOKEN,
                map_style=MAXPBOX_STYLE,
                tooltip=nodes_tooltip)

# Save to .html file and display
r.to_html("nodes.html", notebook_display=true)