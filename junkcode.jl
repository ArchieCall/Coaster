SegsPerFt = 10
BegAng = 45.
EndAng = 55.
ArcLength = 2.3
ArcLength = .29

NumArcSegs = max( 1, round(Int, ArcLength * SegsPerFt))
DegInc = (EndAng - BegAng) / NumArcSegs
ThisDeg = BegAng
for i = 1:NumArcSegs
  ThisDeg +=  DegInc
  @show(i, ThisDeg)
end

using Plots
x = 1:10; y = rand(10) # These are the plotting data
plot(x,y)
