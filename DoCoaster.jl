#DoCoaster
include("coaster.jl")
using RollerCoaster
bypass = true
if !bypass
  using Plots
  lenXC = length(XC)
  plot(XC[1: lenXC - 1],YC, size=(600,230) )  #-- plot whole vector except last point
end