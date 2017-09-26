# old code
DoSineWave = false
if DoSineWave 
  for h = 1:NumHills  #-- loop over each hill
    DegInc = 360. / (HillLength[h] * SegsPerFt)
    DegInitial = -90.
    HH = HillHeight[h]
    IncsOffset = Offset[h]
    for i = 1:HillLength[h]
      for j = 1:SegsPerFt    #-- gen the sine wave segments
        k = (i-1) * SegsPerFt + j + IncsOffset    #-- gen the segment num
        HillAng = DegInitial + (DegInc * (k - 1))  #-- ang of sine wave
        SinAng = sind(HillAng)
        if SinAng >= 0.
          VPos = (.5 * HH) + (.5 * HH * SinAng)  #-- upper portion of sine wave
        else
          VPos = abs(.5 * HH * (1. + SinAng))    #-- lower portion of sine wave
        end
        YC[k] = VPos  #-- store the y coor
        Counter += 1
      end
    end
  end
end

#-- get radius of curved track based on three adjacent segments
function CalcCenter(p1x::Float64, p1yu::Float64, p2x::Float64, p2yu::Float64,
  p3x::Float64, p3y::Float64)
  
  #--- add jitter to points 1 and 2 to allow three points in straight line
  p1y = p1yu + rand() * .00001  
  p2y = p2yu + rand() * .00001
  p1y = p1yu
  p2y = p2yu
  
  ma = (p2y - p1y) / (p2x - p1x)  #-- slope of first line between pts 1 and 2
  mb = (p3y - p2y) / (p3x - p2x)  #-- slope of second line between pts 2 and 3
  centerx = (ma * mb * (p1y - p3y) + mb * (p1x + p2x) - ma * (p2x + p3x)) / (2 * (mb - ma))
  centery = (-1 / ma) * (centerx - (p1x + p2x) / 2) + (p1y + p2y) / 2
  radius = sqrt((centerx - p1x)^2 + (centery - p1y)^2)
  return radius
end

