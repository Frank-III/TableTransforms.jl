using TableTransforms
using Distributions
using Tables
using TypedTables
using LinearAlgebra
using Statistics
using Test, Random, Plots
using ReferenceTests, ImageIO

# set default configurations for plots
gr(ms=2, mc=:black, aspectratio=:equal,
   label=false, size=(600,400))

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__,"data")

# list of tests
testfiles = [
  "distributions.jl",
  "transforms.jl"
]

# For Functor tests in Functional testset
struct Polynomial{T<:Real}
  coeffs::Vector{T}
end
Polynomial(args::T...) where {T<:Real} = Polynomial(collect(args))
function (p::Polynomial)(x)
  n = length(p.coeffs) - 1
  sum(zip(p.coeffs, 0:n)) do (a, i)
    a * x^i
  end
end

@testset "TableTransforms.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end