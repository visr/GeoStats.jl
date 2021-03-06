## Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
##
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

"""
    OrdinaryKriging(X, z, γ)

*INPUTS*:

  * X ∈ ℜ^(mxn) - matrix of data locations
  * z ∈ ℜⁿ      - vector of observations for X
  * γ           - variogram model
"""
type OrdinaryKriging{T<:Real,V} <: AbstractEstimator
  # input fields
  X::AbstractMatrix{T}
  z::AbstractVector{V}
  γ::AbstractVariogram

  # state fields
  LU::Base.LinAlg.Factorization{T}

  function OrdinaryKriging(X, z, γ)
    @assert size(X, 2) == length(z) "incorrect data configuration"
    OK = new(X, z, γ)
    fit!(OK, X, z)
    OK
  end
end

OrdinaryKriging(X, z, γ) = OrdinaryKriging{eltype(X),eltype(z)}(X, z, γ)

function fit!{T<:Real,V}(estimator::OrdinaryKriging{T,V}, X::AbstractMatrix{T}, z::AbstractVector{V})
  # udpate data
  estimator.X = X
  estimator.z = z

  nobs = size(X,2)

  # variogram/covariance
  γ = estimator.γ
  cov(h) = γ.sill - γ(h)

  # LHS of Kriging system
  C = pairwise(cov, X)
  A = [C ones(nobs); ones(nobs)' 0]

  # factorize
  estimator.LU = lufact(A)
end

function weights{T<:Real,V}(estimator::OrdinaryKriging{T,V}, xₒ::AbstractVector{T})
  X = estimator.X; z = estimator.z
  γ = estimator.γ
  cov(h) = γ.sill - γ(h)
  LU = estimator.LU
  nobs = length(z)

  # evaluate covariance at location
  c = Float64[cov(norm(X[:,j]-xₒ)) for j=1:nobs]

  # solve linear system
  b = [c; 1]
  x = LU \ b

  # return weights
  OrdinaryKrigingWeights(estimator, x[1:nobs], x[nobs+1:end], b)
end

function estimate{T<:Real,V}(estimator::OrdinaryKriging{T,V}, xₒ::AbstractVector{T})
  # compute weights
  OKweights = weights(estimator, xₒ)

  # return estimate and variance
  combine(OKweights)
end

"""
    OrdinaryKrigingWeights(estimator, λ, ν, b)

Container that holds weights `λ`, Lagrange multipliers `ν` and RHS `b` for `estimator`.
"""
immutable OrdinaryKrigingWeights{T<:Real,V} <: AbstractWeights{OrdinaryKriging{T,V}}
  estimator::OrdinaryKriging{T,V}
  λ::AbstractVector{T}
  ν::AbstractVector{T}
  b::AbstractVector{T}
end

function combine{T<:Real,V}(weights::OrdinaryKrigingWeights{T,V})
  γ = weights.estimator.γ; z = weights.estimator.z
  λ = weights.λ; ν = weights.ν; b = weights.b

  z⋅λ, γ.sill - b⋅[λ;ν]
end
