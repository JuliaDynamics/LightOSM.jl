# TinyInt.jl

[![Build Status](https://travis-ci.org/mcovalt/TinyInt.jl.svg?branch=master)](https://travis-ci.org/mcovalt/TinyInt.jl)

`TinyInt.jl` is a Julia package for compressing integer vectors very quickly. Elements of the compressed integer vector can be accessed just as you would with a normal vector.

## Requirements
* Julia 0.5 and up
* GCC installed (Linux or macOS)
* **Windows is unsupported at this time.**

## Instalation
```julia
julia> Pkg.add("TinyInt")
julia> Pkg.test("TinyInt")
```

## What is TinyInt.jl?
`TinyInt.jl` quickly compresses and decompresses vectors of *unsigned* integers.
```julia
using TinyInt

x = rand(1:100, 20000000)
tinyx = pack(x)
Base.summarysize(x)
# 160000000
Base.summarysize(tinyx)
# 19531282
```
Compression is fairly fast.
```julia
function pack_example(x)
  tinyx = pack(x)
end

x = rand(1:100, 20000000)
@time pack_example(x)
# 0.043057 seconds (156.52 k allocations: 32.373 MiB)
```
Decompression is very fast.
```julia
function unpack_example(tinyx, out)
  unpack!(tinyx, out)
end

tinyx = pack(rand(1:100, 20000000))
out = zeros(UInt32, 20000000)
@time unpack_example(tinyx, out)
# 0.010429 seconds (5 allocations: 784 bytes)
```
Additionally, individual elements can be selected, but with a bit of CPU overhead.
```julia
function select_example(x)
  y = 0
  for i = 1:length(x)
    y += x[i]
  end
end

x = rand(1:100, 20000000)
tinyx = pack(x)
@time select_example(x)
# 0.009573 seconds (4 allocations: 160 bytes)
@time select_example(tinyx)
# 0.168778 seconds (4 allocations: 160 bytes)
```
*These times are from a quad-core Intel® Core™ i7-4790 CPU @ 3.60GHz*

## Functions
Function              | Description
--------------------- | ------------
`pack(x)`             | Compresses integer vector and outputs compressed integer vector.
`unpack(tinyx)`       | Decompresses integer vector and outputs decompressed integer vector.
`unpack!(tinyx, out)` | Decompresses integer vector, storing decompressed integers into `out`.
`tinyx[i]`            | Outputs the `i'th` integer from a compressed vector.
`length(tinyx)`       | Outputs the number of elements in a compressed vector.

## Low-level Functions
These functions are provided in order to give developers low-level access to the chunks of the compressed array.

Function&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description
-------------------------------- | -----------
`unpack(tinyx, chunk)`           | Decompresses an integer vector chunk and outputs decompressed integer vector chunk.
`unpack!(tinyx, out, chunk)`     | Decompresses an integer vector chunk, storing decompressed integers into `out`. <br />**Important!** Ensure `out` is a contiguous array of 128 `UInt32` integers. This function performs no bounds checking and is intended for speed critical applications.

## Notes
* **The compressed vector is immutable.** Once a compressed vector has been made, it's elements cannot be changed.
* **Vectors are compressed into 128 32-bit unsigned integer chunks.** This aids in SIMD operations. Vector chunks less than 128 integers are padded with zeros. This additional data is negligible for large vectors, but if your integer vector contains significantly less than 128 elements, this tool is likely not for you. To avoid integer type conversion costs with `unpack!`, ensure the vector being overwritten is a `Vector{UInt32}` type.
* **The more random your elements, the less compression.** There's not a great way to compress randomness.

## References
This Julia package uses the Frame-of-Reference compression code from [the SIMDComp library](https://github.com/lemire/simdcomp).
