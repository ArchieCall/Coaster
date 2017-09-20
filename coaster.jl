# coaster.jl
# 09/19/2017
#=
Computes forces on multihill roller coaster
TODO:
g force perpendicular to track
runner friction

=#
module RollerCoaster
const MassDensityAir = .0029  #-- density of air [ld/ft^3]
const GravityConstant = 32.      #-- force of gravity on earth [ft/sec^2]
const CfWindFr = .65     #-- coef of wind friction on coaster front [coef]
#const CfWindFr = 0.     #-- coef of wind friction on coaster front [coef]
const FrontalArea = 22.  #-- front area of coaster [ft^2]
const runner_friction = .006  #-- friction coef of runner wheels on track (null)
const CstrPounds = 2_000.  #-- weight of whole coaster and riders (lb)
const NumHills = 3  #-- number of hills on the track
#=
. first hill and last hill are very short dummy hills to make programming easier
. hills are symmetric left and right
. hills begin and end at zero elevation 
=#
HillHeight = Array{Float64}(NumHills) #-- vertical height of hill
HillHeight = [300, 150, 100]
HillLength = Array{Float64}(NumHills) #-- horizontal length of hill
HillLength = [600, 150, 100]

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
  #GravPounds = GravityConstant * (slope * -1.) #-- must reverse sign of slope
  SlopeSign = -1.
  if slope < 0.
    SlopeSign = 1.
  end
  WeightFraction = abs(slope) / sqrt(slope^2 + 1.)
  WeightFraction1 = sind(atand(slope))
  if !isapprox(abs(WeightFraction), abs(WeightFraction1))
    @show(slope)
    error("unequal fractions")
  end

  ScaledCstrPounds = CstrPounds * (WeightFraction * SlopeSign) #-- must reverse sign of slope
  WindPounds = CfWindFr * FrontalArea * .5 * MassDensityAir * Vel * Vel
  NetPoundForce = ScaledCstrPounds - WindPounds  #-- net pound force of coaster in direction of travel
  #@show(slope, ScaledCstrPounds, WindPounds, NetPoundForce)
  Acc = NetPoundForce / (CstrPounds / GravityConstant)  #-- acceleration of coaster
  NewVel = sqrt(Vel^2 +(2. * Acc * Distance ))
  #@show(Distance, NewVel)
  TravelTime = (2. * Distance) / (Vel + NewVel)  #-- time to travel from this point to next point
  return Acc, TravelTime, Distance, NewVel
end

BeginVel = 25.0
BeginXFt = 290
EndXFt = 500
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
println("done")
end