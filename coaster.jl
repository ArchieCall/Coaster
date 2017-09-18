# coaster.jl
# 09/17/2017
#=
Computes forces on multihill roller coaster
=#
const MassDensityAir = .0029  #-- density of air [ld/ft^3]
const Poundal = 32.      #-- force of gravity on earth [ft/sec^2]
const CfWindFr = .65     #-- coef of wind friction on coaster front [coef]
const FrontalArea = 22.  #-- front area of coaster [ft^2]
const runner_friction = .006  #-- friction coef of runner wheels on track (null)
const CstrWt = 10_000.  #-- weight of whole coaster and riders (lb)
const NumHills = 3  #-- number of hills on the track
#=
. first hill and last hill are very short dummy hills to make programming easier
. hills are symmetric left and right
. hills begin and end at zero elevation 
=#
HillHeight = Array{Float64}(NumHills) #-- vertical height of hill
#HillHeight = [.001, 200, 100, 50, .001]
HillHeight = [.001, 200, .001]
HillLength = Array{Float64}(NumHills) #-- horizontal length of hill
#HillLength = [.001, 200., 100., 50., .001]
HillLength = [.001, 200., .001]

#-- calc angle of coaster on track given x position (deg)
function CoasterAngle(xpos::Float64)
  #@show(xpos)
  xPosRel = HillLength[1]
  HPos = xpos - xPosRel #-- pos on a specific hill
  HillAng = 0.
  SlopeAng = 0.
  Slope = 0.
  VPos = 0.
  for i = 2:NumHills - 1
    if HPos <= HillLength[i]
      #@printf("HillNum => %2i\n", i)
      #@printf("HillLength      => %8.3f\n", HillLength[i])
      #@printf("HillHeight      => %8.3f\n", HillHeight[i])
      #@printf("Hor pos on hill => %8.3f\n", HPos)
      HL = HillLength[i]
      HH = HillHeight[i]
      HillAng = -90. + (360. * HPos / HL)
      #VPos = (sind(HillAng) + 1.0) * .5 * HH
      VPos = (sind(HillAng) + 1.0) * HH
      #@printf("Ver pos on hill => %8.3f\n", VPos)
      SlopeAng = HillAng - 90.  #-- displace sine by 90 def to left
      ScaleFactor = HH / HL
      Slope = sind(SlopeAng) * ScaleFactor  #-- slope is the sine ang displace left by 90 deg
      #@show(HillAng)
      #@show(SlopeAng)
      #@show(Slope)
      #println(" ")
      break
    end
    xPosRel += HillLength[i]
    HPos = xpos - xPosRel #-- pos on a specific hill
  end
  return VPos, Slope
end

#=
=== Global Constants ===
CstrWt = 2000 [lb]
Poundal = 32 [lb-ft/sec^2]
FrontalArea = 20 [ft^2]
CfWindFr = 1.1 [coef]
CfRunnerFr = .005 [coef]
DeltaTime = .1 [sec]
MassDensAir = .0029 [lb/ft^3]
=#

function CoasterForces(XPos::Float64, Vel::Float64)

  #=
  gravitational force = 32 ft/sec^2 (ie. 32 poundals)
  F (poundals -> lb-ft/sec^2) = Wt (lbs) * Acc (ft/sec^2) -- poundals force
  f (lbs) = (Wt (lbs) / 32 ft/sec^2) * Acc (ft/sec^2)     -- pounds force
  Slope = function(XPos)
  WindFr = CfWindFr * FrontalArea * .5 * MassDensAir * Vel * Vel
  RunnerFr = CfRunnerFr * CstrWt * Slope
  GravityPull = CstrWt / Poundal * Slope
  =#

  YPos, Slope = CoasterAngle(XPos)
  GravityPull = (CstrWt / Poundal) * Slope
  WindFr = CfWindFr * FrontalArea * .5 * MassDensityAir * Vel * Vel
  @show(XPos)
  @show(YPos)
  @show(Slope)
  @show(GravityPull)
  @show(WindFr)
  println("in CoasterForces function")
  
  #return NewVel, NewXPos, NewYPos, AccCstr, AccVert, WtOnTrack
  return XPos, YPos, Slope
end
VelMPH = 80. 
VelFPS = VelMPH * (88. / 60.)

PrevY = 0.
PrevX = 0.
for i = 100:200
  XP = (i * 1.) + .001
  XPos, YPos, Slope = CoasterForces(XP, VelFPS)
  if i > 100
    @show(XPos)
    @show(YPos)
    @show(PrevX)
    @show(PrevY)
    CalcSlope = (YPos - PrevY) / (XPos - PrevX)
    @show(CalcSlope)
  end
  PrevY = YPos
  PrevX = XPos
end
println("done")