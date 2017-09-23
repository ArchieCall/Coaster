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

x1,y1,x2,y2,x3,y3 = d[0],d[1],d[2],d[3],d[4],d[5]

    A = x2 - x1
    B = y2 - y1
    C = x3 - x1
    D = y3 - y1
    E = A * (x1 + x2) + B * (y1 + y2)
    F = C * (x1 + x3) + D * (y1 + y3)
    G = 2*(A*(y3-y2)-B*(x3-x2))
    if G == 0:
        return
    x = (D * E - B * F) / G
    y = (A * F - C * E) / G
    """
    ma = (y2-y1)/(x2-x1)
    mb = (y3-y2)/(x3-x2)
    x = (ma*mb*(y1-y3) + mb*(x1+x2) - ma*(x2+x3))/(2*(mb-ma))
    if not ma == 0:
        y = (-1/ma)*(x-(x1+x2)/2)+(y1+y2)/2
    else:
        y = (-1/mb)*(x-(x2+x3)/2)+(y2+y3)/2
    """
    r = math.sqrt((x-x1)*(x-x1)+(y-y1)*(y-y1))
