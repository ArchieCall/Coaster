SegsPerFt = 2
Radius = 100.
xc = 200.
yc = 100.
#-- BegAng and EndAng both must be >= 0. and < 360.
BegAng = 180.
EndAng = 0.
RotateType = "CCW"  #-- rotate arc counter clock wise (ie. positive rotation angles)
#RotateType = "CW"   #-- rotate arc clock wise (ie. negative rotation angles)

DiffAng = EndAng - BegAng
if RotateType == "CCW"
  if DiffAng < 0.
    DiffAng += 360.  #-- wrapped the 0. deg axis
  end
end
if RotateType == "CW"
  if DiffAng > 0.
    DiffAng -= 360.  #-- wrapped the 0. deg axis
  end
end
#ArcLength = 2 * pi * Radius * (DiffAng / 360.)
#error("woo")

NumArcSegs = max( 1, abs(round(Int, DiffAng * SegsPerFt)))
DegInc = DiffAng / NumArcSegs
@show(DegInc, NumArcSegs)
ThisDeg = BegAng
for i = 1:NumArcSegs
  x2 = xc + Radius * cosd(ThisDeg)
  y2 = yc + Radius * sind(ThisDeg)
  #@printf("i => %4i  deg => %8.4f  x2 => %8.4f  y2 => %8.4f\n", i, ThisDeg, x2, y2 )
  ThisDeg +=  DegInc
end

u = 6.999
@show(typeof(u))
uu = round(Int, u)
@show(round(Int, 3.4))

DiffAng = 7.6
SegsPerFt = 2
bbb = round(Int, DiffAng * SegsPerFt)
@show(bbb)
RInt(x::AbstractFloat) = round(Int, x)
@show(RInt(6.7))
@show(round(Int, 6.7))
error("ll")
using Plots
x = 1:10; y = rand(10) # These are the plotting data
lenx = length(x)
plot(x[1:lenx - 3],y)

