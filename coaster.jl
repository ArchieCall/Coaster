# coaster.jl
# 09/20/2017
#=
Computes forces on multihill roller coaster
TODO:
on uphill if not enough speed then gracefully exit rather than neg sqrt
g force perpendicular to track
runner friction - g force above

=#
module RollerCoaster
const MassDensityAir = .0029  #-- density of air [ld/ft^3]
const GravityConstant = 32.      #-- force of gravity on earth [ft/sec^2]
const CfWindFr = .10     #-- coef of wind friction on coaster front [coef]
const FrontalArea = 10.  #-- front area of coaster [ft^2]
const CfRunnerFriction = .01  #-- friction coef of runner wheels on track (null)
const CstrPounds = 2_000.  #-- weight of whole coaster and riders (lb)
const NumHills = 3  #-- number of hills on the track
#=
. first hill and last hill are very short dummy hills to make programming easier
. hills are symmetric left and right
. hills begin and end at zero elevation 
=#
HillHeight = Array{Float64}(NumHills) #-- vertical height of hill
HillHeight = [520, 150, 100]
HillLength = Array{Float64}(NumHills) #-- horizontal length of hill
HillLength = [300, 150, 100]

CoasterLengthFt = sum(HillLength)
CoasterLengthIn = CoasterLengthFt * 10
XC = Array{Float64}(CoasterLengthIn)
YC = Array{Float64}(CoasterLengthIn)
SlopeC = Array{Float64}(CoasterLengthIn)
# fill the x values of XC
for i = 1:CoasterLengthFt
  for j = 1:10
    k = (i-1) * 10 + j
    kx = k * 1.
    XC[k] = kx * .1
  end
end

# calc the y values of first hill (YC)
DegInc = 360. / (HillLength[1] * 10.)
DegInitial = -90.
Counter = 0
HH = HillHeight[1]
for i = 1:HillLength[1]
  for j = 1:10
    k = (i-1) * 10 + j
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
@show(Counter)

#-- calc the slope vector
for k = 1:Counter - 1
  SlopeC[k] = (YC[k+1] - YC[k] ) / (XC[k+1] - XC[k])
  #@printf("x => %8.4f  y => %8.4f   slope => %9.5f\n", XC[k], YC[k], SlopeC[k])
end

function Forces(x_index::Int, Vel::Float64)
  x = XC[x_index]  #-- x coor of this point
  y = YC[x_index]  #-- y coor of this point
  
  x_next = XC[x_index + 1]  #-- x coor of next point
  y_next = YC[x_index + 1]  #-- y coor of next point
  Distance =  sqrt((x_next - x)^2 + (y_next - y)^2)  #-- dist from this point to next point
  #@show(Distance)
  slope = SlopeC[x_index]    #-- + slope => going uphill, - slope => going downhill
  
  #-- pound forces on coaster in direction of travel
  PullFraction = -sind(atand(slope))  #-- fraction of gravity along track
  WheelFraction = abs(cosd(atand(slope))) #-- fraction of wheel weight perpendicular to track
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

BeginVel = 120.0
BeginXFt = 151
EndXFt = 299
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