# coaster.jl
# 09/23/2017
#=
Computes forces on multihill roller coaster
TODO:
slope possibly calculates wrong at transition from one hill to next
why is centrifugal force so high at bottom of sine hill
computer summary stats by each uphill and downhill
loops in track
twists in track
=#
module RollerCoaster
const MassDensityAir = .0029   #-- density of air [ld/ft^3]
const GravityConstant = 32.    #-- force of gravity on earth [ft/sec^2]
const CfWindFr = .450          #-- coef of wind friction on coaster front [coef]
const FrontalArea = 8.        #-- front area of coaster [ft^2]
const CfRunnerFriction = .015  #-- friction coef of runner wheels on track (null)
const CstrLbs = 200.        #-- weight of coaster cars and riders (lb)
const NumHills = 2             #-- number of hills on the track 
const SegsPerFt = 10           #-- number of segments per foot of horizontal distance

#=
. hills are symmetric left and right
. hills begin and end at zero elevation 
=#

#-- setup the hill lengths and heights
HillHeight = Array{Int}(NumHills) #-- vertical height of each hill
HillHeight = [10, 10]
HillLength = Array{Int}(NumHills) #-- horizontal length of each hill
HillLength = [20, 20]

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
    kx = k * 1.
    XC[k] = kx * .1
  end
end

# calc the y values of the hills (YC)
Counter = 0
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
@show(Counter)

#-- calc the slope vector
for k = 1:Counter - 1
  # if uphill - slope is positive, if downhill - slope is negative
  SlopeSegment[k] = (YC[k+1] - YC[k] ) / (XC[k+1] - XC[k])  #-- slope of this segment
  #@printf("x => %8.4f  y => %8.4f   slope => %9.5f\n", XC[k], YC[k], SlopeSegment[k])
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
  #RadiusSegment[k] = CalcCenter(p1x, p1y, p2x, p2y, p3x, p3y)
  RadiusSegment[k] = CalcCenter1(p1x, p1y, p2x, p2y, p3x, p3y)
end

#=
for i = 1:Counter-1
  @printf("x = %8.3f y = %8.3f slope = %8.3f radius = %8.3f\n", 
  XC[i], YC[i], SlopeSegment[i], RadiusSegment[i])
end
error("stopper")
=#

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
  CentrifugalWheelLbs1 = (CstrLbs / GravityConstant) * Vel * Vel / RadiusSegment[x_index]
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
BeginXFt = 10     #-- beginning hor coor
EndXFt =   39       #-- ending hor coor
BeginVel = 10.0    #-- initial velocity at beginning coor
BeginPoint = BeginXFt * SegsPerFt  #-- beginning point in segments
EndPoint = EndXFt * SegsPerFt      #-- ending point in segments
NewVel = BeginVel
TotDistance = 0.
TotTime = 0.
const StatsBeg = 10  #-- feet when stat begin
const StatsFt = 1   #-- show stats when coaster travels this many ft
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





SkipCode = true
if !SkipCode
end
println("Griffin's roller coaster program is done.")
end