## Copyright (c) 2015, Júlio Hoffimann Mendes <juliohm@stanford.edu>
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

abstract AbstractVariogram

"""
    GaussianVariogram(s, r, n)

*INPUTS*:

  * s ∈ ℜ - sill
  * r ∈ ℜ - range
  * n ∈ ℜ - nugget
"""
immutable GaussianVariogram{T<:Real} <: AbstractVariogram
  sill::T
  range::T
  nugget::T
end
GaussianVariogram{T<:Real}(s::T, r::T) = GaussianVariogram(s, r, zero(T))
GaussianVariogram() = GaussianVariogram(1.,1.)
(γ::GaussianVariogram)(h) = (γ.sill - γ.nugget) * (1 - exp(-(h/γ.range).^2)) + γ.nugget

"""
    SphericalVariogram(s, r, n)

*INPUTS*:

  * s ∈ ℜ - sill
  * r ∈ ℜ - range
  * n ∈ ℜ - nugget
"""
immutable SphericalVariogram{T<:Real} <: AbstractVariogram
  sill::T
  range::T
  nugget::T
end
SphericalVariogram{T<:Real}(s::T, r::T) = SphericalVariogram(s, r, zero(T))
SphericalVariogram() = SphericalVariogram(1.,1.)
(γ::SphericalVariogram)(h) = (h .< γ.range) .* (γ.sill - γ.nugget) .* (1 - 1.5h/γ.range + 0.5(h/γ.range).^3) +
                             (h .≥ γ.range) .* (γ.sill - γ.nugget) + γ.nugget

"""
    ExponentialVariogram(s, r, n)

*INPUTS*:

  * s ∈ ℜ - sill
  * r ∈ ℜ - range
  * n ∈ ℜ - nugget
"""
immutable ExponentialVariogram{T<:Real} <: AbstractVariogram
  sill::T
  range::T
  nugget::T
end
ExponentialVariogram{T<:Real}(s::T, r::T) = ExponentialVariogram(s, r, zero(T))
ExponentialVariogram() = ExponentialVariogram(1.,1.)
(γ::ExponentialVariogram)(h) = (γ.sill - γ.nugget) * (1 - exp(-(h/γ.range))) + γ.nugget
