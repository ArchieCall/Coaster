#RadiusCalc
#function CalculateCircleCenter(Vector2 p1, Vector2 p2, Vector2 p3)
function CalcCenter(p1x::Float64, p1y::Float64, p2x::Float64, p2y::Float64,
  p3x::Float64, p3y::Float64)
  ma = (p2y - p1y) / (p2x - p1x)
  mb = (p3y - p2y) / (p3x - p2x)
  centerx = (ma * mb * (p1y - p3y) + mb * (p1x + p2x) - ma * (p2x + p3x)) / (2 * (mb - ma))
  centery = (-1 / ma) * (centerx - (p1x + p2x) / 2) + (p1y + p2y) / 2
  radius = sqrt((centerx - p1x)^2 + (centery - p1y)^2)
  return centerx, centery, radius
end
CalcCenter(5., 10., -5., 0., 9., -6.)
