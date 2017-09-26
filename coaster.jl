# coaster.jl
# 09/26/2017
#=
Computes forces on multihill roller coaster
TODO:
computer summary stats by each uphill and downhill
loops in track
twists in track
TODO:
arc segments
------------
constants that apply to everything
----------------------------------
MinRadius::Float64  - the minimum allowed radius [ft]
SegsPerDeg:Int      - number of segments per degree of arc
each X
---------------------------------------------------
ArcNumber::Int   -- number to ID the segment [1 .. n]
Radius::Float64  -- radius of arc [ft]
XCtr::Float64 -- x coor of center of radius [ft]
YCtr::Float64 -- y coor of center of radius [ft]
RotationDir:Int  -- direction of rotation [1 = CW, -1 = CCW]  note: may not be needed?
BegXC::Float64   -- beg x coor [ft]
BegYC::Float64   -- beg y coor [ft]
BegAng::Float64   -- begin angle of arc [deg]
EndAng::Float64   -- end   angle of arc [deg]
EndXC::Float64   -- end x coor [ft]
EndYC::Float64   -- end y coor [ft]
----------------------------------------------------
segments correspond to 
everything is arcs -> there are not straight lines
all arcs start from ArcNumber 1 and proceed to ArcNumber n
Radius is always known and under tight control not to be less than a certain limit
XCenter and YCenter are specified on first arc, and imputed thereafter
compute the ArcLength from beg ang to end ang for a given radius
.. NumArcSegs = max( 1, round(Int, ArcLength * SegsPerFt) - 1)
.. DegInc = (EndAng - BegAng) / NumArcSegs

=#
module RollerCoaster
const MassDensityAir = .0029   #-- density of air [ld/ft^3]
const GravityConstant = 32.    #-- force of gravity on earth [ft/sec^2]
const CfWindFr = .60           #-- coef of wind friction on coaster front [coef]
const FrontalArea = 15.        #-- front area of coaster [ft^2]
const CfRunnerFriction = .015  #-- friction coef of runner wheels on track (null)
const CstrLbs = 2000.          #-- weight of coaster cars and riders (lb)
const NumHills = 3             #-- number of hills on the track 
const SegsPerFt = 10           #-- number of segments per foot of horizontal distance
const WheelBaseFt = 8          #-- wheel base of coaster car must be integer
const WheelBaseSegments = WheelBaseFt * SegsPerFt  #-- segments in wheel base
const WheelBaseSegmentsHalf = Int(WheelBaseSegments * .5)  #-- one half wheel base

#=
. hills are symmetric left and right
. hills begin and end at zero elevation 
=#

#-- setup the hill lengths and heights
HillHeight = Array{Int}(NumHills) #-- vertical height of each hill
HillHeight = [200, 150, 100]
HillLength = Array{Int}(NumHills) #-- horizontal length of each hill
HillLength = [400, 300, 200 ]

#-- setup the offset array
Offset = zeros(Int, NumHills) #-- beginning offset of a hill in segments
Offset[1] = 0
for o = 2:NumHills
  Offset[o] = Offset[o-1] + (HillLength[o-1] * SegsPerFt)
end
@show(Offset)

CoasterLengthFt = sum(HillLength)   #-- total length of all hills in coaster [ft]
CoasterLengthSegs = CoasterLengthFt * SegsPerFt  #-- ditto [segments]

#-- create XC, YC, SlopeSegment, RadiusSegment float arrays
XC = Array{Float64}(CoasterLengthSegs)
YC = Array{Float64}(CoasterLengthSegs)
SlopeSegment = Array{Float64}(CoasterLengthSegs)
RadiusSegment = Array{Float64}(CoasterLengthSegs)

# fill the x values of XC
for i = 1:CoasterLengthFt
  for j = 1:SegsPerFt
    k = (i-1) * SegsPerFt + j
    XC[k] =  (k-1) / SegsPerFt
  end
end

# calc the y values of the hills (YC)
Counter = 0


for h = 1:NumHills  #-- loop over each hill
  @printf("Hill = %3i\n", h)
  RadCirc = HillHeight[h] / 2
  RadCircInt = round(Int, HillHeight[h] / 2)  
  SemiCircSegs = RadCircInt * SegsPerFt    #-- number of segments in the radius
  ycen = RadCirc * 1.                      #-- y center the same in all quadrants
  fuzz = .00000001
  
  #-- uphill lower quadrant
  println("got to uphill lower")
  xcen = (Offset[h] / SegsPerFt) * 1. 
  for i = 1:SemiCircSegs
    Counter += 1
    k = Offset[h] + i     #-- in segs
    x = XC[k]
    sqval = RadCirc^2 - (x - xcen)^2 + fuzz
    y = ycen - sqrt(sqval)
    YC[k] = y
    #@show(k, RadCirc, x, xcen, y, ycen, sqval)
    #error("stop at first uphill")
  end
  
  #-- uphill upper quadrant
  println("got to uphill upper")
  xcen = (Offset[h] / SegsPerFt) * 1. + (2. * RadCirc)
  for i = 1:SemiCircSegs
    Counter += 1
    k = Offset[h] + (RadCircInt * SegsPerFt) + i
    x = XC[k]
    juu = RadCirc^2 - (x - xcen)^2 + fuzz
    #@show(k, RadCirc, x, xcen)
    #@show(juu)
    y = sqrt(juu) + ycen
    #error("uuu")
    YC[k] = y
  end
  
  #-- downhill upper quadrant
  println("got to downhill upper")
  xcen = (Offset[h] / SegsPerFt) * 1. + (2. * RadCirc)
  for i = 1:SemiCircSegs
    Counter += 1
    k = Offset[h] + (2 * RadCircInt * SegsPerFt) + i
    x = XC[k]
    #@show(k, RadCirc, x, xcen)
    y = sqrt(RadCirc^2 - (x - xcen)^2 + fuzz) + ycen
    YC[k] = y
  end
  
  #-- downhill lower quadrant
  println("got to downhill lower")
  xcen = (Offset[h] / SegsPerFt) * 1. + (4. * RadCirc)
  for i = 1:SemiCircSegs
    Counter += 1
    k = Offset[h] + (3 * RadCircInt * SegsPerFt) + i
    x = XC[k]
    #@show(k, RadCirc, x, xcen)
    y = -sqrt(RadCirc^2 - (x - xcen)^2 + fuzz) + ycen
    YC[k] = y
  end
end



@show(Counter)

#-- calc the slope vector based on adjacent segments
for k = 1:Counter-1
  # if uphill - slope is positive, if downhill - slope is negative
  SlopeSegment[k] = (YC[k+1] - YC[k] ) / (XC[k+1] - XC[k])  #-- slope of this segment
  #@printf("x => %8.4f  y => %8.4f   slope => %9.5f\n", XC[k], YC[k], SlopeSegment[k])
end


function CalcCenter1(x1::Float64, y1::Float64, x2::Float64, y2::Float64, x3::Float64, y3::Float64)
  slope1 = (y2-y1)/(x2-x1)
  slope2 = (y3-y2)/(x3-x2)
  
  if isapprox(slope1, slope2)
    radius = 100_000.
    return radius
  end
  
  A = x1 * (y2-y3) - y1 * (x2-x3) + x2*y3 - x3*y2
  B = (x1^2 + y1^2) * (y3-y2) + (x2^2 + y2^2) * (y1-y3) + (x3^2 + y3^2) * (y2-y1)
  C = (x1^2 + y1^2) * (x2-x3) + (x2^2 + y2^2) * (x3-x1) + (x3^2 + y3^2) * (x1-x2)
  D = (x1^2 + y1^2) * (x3*y2 - x2*y3) + (x2^2 + y2^2) * (x1*y3 - x3*y1)
  D = D + (x3^2 + y3^2) * (x2*y1 - x1*y2)
  radius = sqrt((B^2 + C^2 - 4. * A * D)/(4. * A^2))
  return radius
end

#-- calc the radius vector
for k = 2:Counter-1
  p1x = XC[k-1]
  p1y = YC[k-1]
  p2x = XC[k]
  p2y = YC[k]
  p3x = XC[k+1]
  p3y = YC[k+1]
  RadiusSegment[k] = CalcCenter1(p1x, p1y, p2x, p2y, p3x, p3y)
end

#-- recalc radius at center of wheelbase based on backward and forward wheels
for k = WheelBaseSegmentsHalf+1:Counter-WheelBaseSegmentsHalf
  l = k - WheelBaseSegmentsHalf
  m = l + WheelBaseSegments - 1
  p1x = XC[l]
  p1y = YC[l]
  p2x = XC[k]
  p2y = YC[k]
  p3x = XC[m]
  p3y = YC[m]
  RadiusSegment[k] = CalcCenter1(p1x, p1y, p2x, p2y, p3x, p3y)
  #@printf("x => %8.4f  y => %8.4f   slope => %9.5f\n", XC[k], YC[k], SlopeSegment[k])
end

for i = 1:10:9000
  @printf("x = %8.3f y = %8.3f slope = %8.3f radius = %8.3f\n", 
  XC[i], YC[i], SlopeSegment[i], RadiusSegment[i])
end
#error("stopper")

ShowCounter = 0
#-- calc all forces on coaster at specific segment
function Forces(x_index::Int, Vel::Float64, ShowOutput::Bool)
  x = XC[x_index]  #-- x coor of this point
  y = YC[x_index]  #-- y coor of this point
  
  x_next = XC[x_index + 1]  #-- x coor of next point
  y_next = YC[x_index + 1]  #-- y coor of next point
  Distance =  sqrt((x_next - x)^2 + (y_next - y)^2)  #-- dist from this point to next point
  slope = SlopeSegment[x_index]    #-- + slope => going uphill, - slope => going downhill
  
  #-- coaster pounds parallel to direction of travel
  TrackPullLbs = -sind(atand(slope)) * CstrLbs
  
  #-- weight of coaster perpendicular to track - assumes track is straight
  #-- this weight presses against top of track
  #-- note:  this is not correct if car is upside down
  WheelLbs = abs(cosd(atand(slope))) * CstrLbs
  
  #-- added or reduced wheel pounds from centrifugal force on a curved track
  RadiusTrack = RadiusSegment[x_index] + 20.   #-- add 20 ft to debug high g force at bottom
  CentrifugalWheelLbs1 = (CstrLbs / GravityConstant) * Vel * Vel / RadiusTrack
  if slope > 0. && slope < 1.
    CentrifugalSign = -1    #-- centrifugal force applied to bottom of coaster rail
  elseif  slope < 0. && slope > -1.
    CentrifugalSign = -1    #-- centrifugal force applied to bottom of coaster rail
  else
    CentrifugalSign = 1     #-- centrifugal force applied to top of coaster rail
  end
  CentrifugalWheelLbs = CentrifugalSign * CentrifugalWheelLbs1  #-- apply sign to centrifugal pounds
  
  TotalWheelLbs = abs(WheelLbs + CentrifugalWheelLbs)
  WheelFrictionLbs = TotalWheelLbs * CfRunnerFriction   #-- wheel friction
  PctCentrifugalLbs = (CentrifugalWheelLbs / (WheelLbs + abs(CentrifugalWheelLbs)))*100.
  
  #-- wind resistance of coaster
  WindFrictionLbs = CfWindFr * FrontalArea * .5 * MassDensityAir * Vel * Vel  
  
  #-- net force that accelerates the coaster
  NetLbs = TrackPullLbs - WindFrictionLbs - WheelFrictionLbs
  
  
  Acc = NetLbs / (CstrLbs / GravityConstant)  #-- acceleration of coaster
  
  InsideSqrt = Vel^2 +(2. * Acc * Distance )
  if InsideSqrt < 0.
    error("Error velocity on uphill reached zero!")
  end
  NewVel = sqrt(InsideSqrt)
  TravelTime = (2. * Distance) / (Vel + NewVel)  #-- time to travel from this point to next point
  if ShowOutput
    println(" ")
    @show(x_index / SegsPerFt, Acc, NewVel * 60./88., TravelTime)
    @show(slope, TrackPullLbs, WindFrictionLbs, WheelFrictionLbs)
    @show(CentrifugalWheelLbs1, WheelLbs, NetLbs, RadiusSegment[x_index])
  end
  return Acc, TravelTime, Distance, NewVel
end

#--- run the simulation of roller coaster
BeginXFt = 200     #-- beginning hor coor
EndXFt =   890       #-- ending hor coor
BeginVel = 10.0    #-- initial velocity at beginning coor
BeginPoint = BeginXFt * SegsPerFt  #-- beginning point in segments
EndPoint = EndXFt * SegsPerFt      #-- ending point in segments
NewVel = BeginVel
TotDistance = 0.
TotTime = 0.
const StatsBeg = 200  #-- feet when stats begin
const StatsFt = 10   #-- show stats when coaster travels this many ft
const ShowLimit = StatsFt * SegsPerFt
ShowCounter = ShowLimit
for l = BeginPoint:EndPoint
  ShowOutput = false
  CurrVel = NewVel
  if l >= StatsBeg * SegsPerFt
    if ShowCounter == ShowLimit
      ShowCounter = 0
      ShowOutput = true
    end
    ShowCounter += 1
  end
  acc, t, d, NewVel = Forces(l, CurrVel, ShowOutput)
  TotDistance += d
  TotTime += t
end
@show(TotDistance, TotTime, NewVel)
export XC, YC
end