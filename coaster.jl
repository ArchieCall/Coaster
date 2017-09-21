# coaster.jl
# 09/21/2017
#=
Computes forces on multihill roller coaster
TODO:
process multiple hills properly
radius between two line segments
angular momentum on track and associated runner friction
computer summary stats by each uphill and downhill
loops
twists
=#
module RollerCoaster
const MassDensityAir = .0029  #-- density of air [ld/ft^3]
const GravityConstant = 32.      #-- force of gravity on earth [ft/sec^2]
const CfWindFr = .30     #-- coef of wind friction on coaster front [coef]
const FrontalArea = 15.  #-- front area of coaster [ft^2]
const CfRunnerFriction = .01  #-- friction coef of runner wheels on track (null)
const CstrPounds = 10_000.  #-- weight of all coaster cars and riders (lb)
const NumHills = 3  #-- number of hills on the track
#=
. hills are symmetric left and right
. hills begin and end at zero elevation 
=#
HillHeight = Array{Float64}(NumHills) #-- vertical height of hill
HillHeight = [300, 150, 100]
HillLength = Array{Float64}(NumHills) #-- horizontal length of hill
HillLength = [300, 150, 100]

Offset = Array{Int}(NumHills) #-- beginning inc offset of a hill
Offset[1] = 0
for o = 2:NumHills
  Offset[o] = Offset[o-1] + (HillLength[o-1] * 10)
end
@show(Offset)


CoasterLengthFt = sum(HillLength)
CoasterLengthIn = CoasterLengthFt * 10
XC = Array{Float64}(CoasterLengthIn)
YC = Array{Float64}(CoasterLengthIn)
SlopeSegment = Array{Float64}(CoasterLengthIn)
RadiusSegment = Array{Float64}(CoasterLengthIn)
# fill the x values of XC
for i = 1:CoasterLengthFt
  for j = 1:10
    k = (i-1) * 10 + j
    kx = k * 1.
    XC[k] = kx * .1
  end
end

# calc the y values of the hills (YC)
Counter = 0
for h = 1:NumHills  #-- loop over each hill
  DegInc = 360. / (HillLength[h] * 10.)
  DegInitial = -90.
  HH = HillHeight[h]
  IncsOffset = Offset[h]
  for i = 1:HillLength[h]
    for j = 1:10
      k = (i-1) * 10 + j + IncsOffset
      HillAng = DegInitial + (DegInc * (k - 1))
      SinAng = sind(HillAng)
      if SinAng >= 0.
        VPos = (.5 * HH) + (.5 * HH * SinAng)
      else
        VPos = abs(.5 * HH * (1. + SinAng))
      end
      YC[k] = VPos
      Counter += 1
    end
  end
end
@show(Counter)

#-- calc the slope vector
for k = 1:Counter - 1
  SlopeSegment[k] = (YC[k+1] - YC[k] ) / (XC[k+1] - XC[k])
  #@printf("x => %8.4f  y => %8.4f   slope => %9.5f\n", XC[k], YC[k], SlopeSegment[k])
end

function Forces(x_index::Int, Vel::Float64)
  println(" ")
  x = XC[x_index]  #-- x coor of this point
  y = YC[x_index]  #-- y coor of this point
  
  x_next = XC[x_index + 1]  #-- x coor of next point
  y_next = YC[x_index + 1]  #-- y coor of next point
  Distance =  sqrt((x_next - x)^2 + (y_next - y)^2)  #-- dist from this point to next point
  slope = SlopeSegment[x_index]    #-- + slope => going uphill, - slope => going downhill
  
  #-- pound forces on coaster in direction of travel
  PullFraction = -sind(atand(slope))  #-- fraction of gravity along track
  WheelFraction = abs(cosd(atand(slope))) #-- fraction of wheel weight perpendicular to track
  @show(PullFraction, WheelFraction)
  CstrPullPounds = CstrPounds * PullFraction   #-- coaster pull along track
  WindPounds = CfWindFr * FrontalArea * .5 * MassDensityAir * Vel * Vel  #-- wind resistance
  WheelFrictionPounds = CstrPounds * WheelFraction * CfRunnerFriction  #-- wheel friction
  NetPoundForce = CstrPullPounds - WindPounds - WheelFrictionPounds  #-- net pound force of coaster
  @show(slope, CstrPullPounds, WindPounds, WheelFrictionPounds, NetPoundForce)
  Acc = NetPoundForce / (CstrPounds / GravityConstant)  #-- acceleration of coaster
  InsideSqrt = Vel^2 +(2. * Acc * Distance )
  if InsideSqrt < 0.
    error("Error velocity on uphill reached zero!")
  end
  NewVel = sqrt(InsideSqrt)
  @show(x_index / 10., slope, Acc, InsideSqrt, NewVel * 60./88., Distance)
  #@show(Distance, NewVel)
  TravelTime = (2. * Distance) / (Vel + NewVel)  #-- time to travel from this point to next point
  return Acc, TravelTime, Distance, NewVel
end

BeginVel = 50.0
BeginXFt = 151
EndXFt = 549
BeginPoint = BeginXFt * 10
EndPoint = EndXFt * 10
NewVel = BeginVel
TotDistance = 0.
TotTime = 0.
for l = BeginPoint:EndPoint
  CurrVel = NewVel
  acc, t, d, NewVel = Forces(l, CurrVel)
  TotDistance += d
  TotTime += t
  #@show(acc, t, NewVel)
  #println(" ")
end
@show(TotDistance, TotTime, NewVel)





SkipCode = true
if !SkipCode
end
println("Griffin's roller coaster program is done.")
end