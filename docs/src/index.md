![GeoStatsLogo](images/GeoStats.png)

[![Build Status](https://travis-ci.org/juliohm/GeoStats.jl.svg?branch=master)](https://travis-ci.org/juliohm/GeoStats.jl)
[![GeoStats](http://pkg.julialang.org/badges/GeoStats_0.5.svg)](http://pkg.julialang.org/?pkg=GeoStats)
[![Coverage Status](https://codecov.io/gh/juliohm/GeoStats.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/juliohm/GeoStats.jl)

## Overview

This package provides efficient implementations of geostatistical algorithms in pure Julia.
It is in its initial development, and currently only implements Kriging estimation methods.
More features will be added as the Julia type system matures.

## Installation

Get the latest stable release with Julia's package manager:

```julia
Pkg.add("GeoStats")
```

## Quick example

Below is a quick example of usage:

```@example
using GeoStats
srand(2017) # hide

# create some data
dim, nobs = 3, 10
X = rand(dim, nobs); z = rand(nobs)

# target location
xₒ = rand(dim)

# define a variogram model
γ = GaussianVariogram(1.,1.,0.) # sill, range and nugget

# define an estimator (i.e. build the Kriging system)
simkrig = SimpleKriging(X, z, γ, mean(z))
ordkrig = OrdinaryKriging(X, z, γ)
unikrig = UniversalKriging(X, z, γ, 1)

# estimate at target location
μ, σ² = estimate(simkrig, xₒ)
println("Simple Kriging:") # hide
println("  μ = $μ, σ² = $σ²") # hide
μ, σ² = estimate(ordkrig, xₒ)
println("Ordinary Kriging:") # hide
println("  μ = $μ, σ² = $σ²") # hide
μ, σ² = estimate(unikrig, xₒ)
println("Universal Kriging:") # hide
println("  μ = $μ, σ² = $σ²") # hide
```
