# LightOSM.jl

__[`LightOSM.jl`](https://github.com/captchanjack/LightOSM.jl)__ is __[Julia](https://julialang.org/)__ package for downloading and analysing geospatial data from __[OpenStreetMap](https://wiki.openstreetmap.org/wiki/Main_Page)__ APIs (__[Nominatim](https://nominatim.openstreetmap.org/ui/search.html)__ and __[Overpass](https://overpass-api.de)__), such as nodes, ways, relations and building polygons.

## Acknowledgements

__[`LightOSM.jl`](https://github.com/captchanjack/LightOSM.jl)__ is a package developed and open sourced as part of Deloitte’s __[Optimal Reality](https://optimalreality.com/)__ Digital Twin offering. It aims to achieve 3 things - accurate parsing of OpenStreetMap **transport network** data, performant **path finding** and easy-to-use **interface**. 

It is inspired by the Python package __[OSMnx](https://github.com/gboeing/osmnx)__ for its interface and Overpass query logic. Graph analysis algorithms (connected components and shortest path) are based are based on __[LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl)__ implmentation, but adapted to account for turn restrictions and improve runtime performance.

Another honourable mention goes to an existing Julia package __[OpenStreetMapX.jl](https://github.com/pszufe/OpenStreetMapX.jl)__ as many learnings were taken to improve parsing of raw OpenStreetMap data.

## Key Features

- `Search`, `download` and `save` OpenSteetMap data in .osm, .xml or .json, using a place name, centroid point or bounding box
- Parse OpenStreetMap `transport network` data such as motorway, cycleway or walkway
- Parse OpenStreetMap `buildings` data into a format consistent with the __[GeoJSON](https://tools.ietf.org/html/rfc7946)__ standard, allowing for visualisation with libraries such as __[deck.gl](https://github.com/visgl/deck.gl)__
- Calculate `shortest path` between two nodes using the Dijkstra or A* algorithm (based on LightGraphs.jl, but adapted for better performance and use cases such as `turn resrictions`)
- Find `nearest nodes` from a query point using a K-D Tree data structure (implemented using __[NearestNeighbors.jl](https://github.com/KristofferC/NearestNeighbors.jl)__)

## Documentation

Documentation for the API can be found here __[INSERT DOCUMENTATION LINK]()__.

## Usage

A comprehensive tutorial can be found found here __[INSERT TUTORIAL LINK]()__.


## Benchmarks

Benchmark comparison for shortest path algorithms can be found here __[INSERT BENCHMARKS LINK]()__.
