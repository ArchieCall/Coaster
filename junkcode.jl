module UtilityFunctions
RInt(x::AbstractFloat) = round(Int, x)  #-- convert x to an integer by rounding to default rounding mode
export RInt
end
using UtilityFunctions
@show(RInt(6.7))
@show(round(Int, 6.7))
RotDir,  Radius,  XCen,  YCen, BegX,  BegY, BegAng, RevDeg, EndAng,  EndX,  EndY
"CCW",    100.,    0.,  100.,   0.,    0.,    270.,    90.,     0.,    0.,   0.
"CW",     100.,    0.,    0.,   0.,    0.,    180.,   180.,     0.,    0.,   0.
"CCW",    100.,    0.,    0.,   0.,    0.,    180.,    90.,   270.,    0.,   0.
"CCW",     75.,    0.,    0.,   0.,    0.,    270.,    50.,   320.,    0.,   0.
"CCW",    175.,    0.,    0.,   0.,    0.,    320.,    20.,   340.,    0.,   0.
"CW",     175.,    0.,    0.,   0.,    0.,    160.,    60.,   100.,    0.,   0.
"EOF",      0.,    0.,    0.,   0.,    0.,      0.,     0.,     0.,    0.,   0.
