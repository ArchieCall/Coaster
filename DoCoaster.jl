#DoCoaster
include("Coaster.jl")
using RollerCoaster
bypass = false
if !bypass
  using Plots
  lenXC = length(XC)
  @show(Counter, lenXC)
  XScale = MaxXC - MinXC
  YScale = (MaxYC - MinYC) * 1.1
  plot(XC[1: lenXC - 1],YC, size=(XScale,YScale) )  #-- plot whole vector except last point
end