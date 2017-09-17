const air_density = .0029  #-- density of air (ld/ft^3)
const gravity = 32.     #force of gravity on earth (ft/sec^2)
const runner_friction = .006  #-- friction coef of runner wheels on track (null)
const coaster_weight = 2000.  #-- weight of whole coaster and riders (lb)
const NumHills = 5  #-- number of hills on the track
HillHeight = Array{Float64}(NumHills) #-- vertical height of hill
HillHeight = [.1, 200, 100, 50, 1]
HillLength = Array{Float64}(NumHills) #-- horizontal length of hill
HillLength = [.1, 200, 100, 50, 1]

#----- calc wind friction on front of coaster (lb)
function WindFriction(speed::Float64)
  #-- speed => speed of coaster along track(ft/sec)
  area = 4.0  #--square feet of frontal area of coaster train
  coef_friction = 1.1  #-- coef of air friction of coaster train
  wind_friction = coef_friction * area * air_density * .5 * speed * speed #-- wind friction (lb)
  return
end

WindFriction(50.)

#-- calc angle of coaster on track given x position (deg)
function CoasterAngle(xpos::Float64)
  @show(xpos)
  xPosRel = HillLength[1]
  HPos = xpos - xPosRel #-- pos on a specific hill
  HillAng = 0.
  SlopeAng = 0.
  Slope = 0.
  for i = 2:NumHills - 1
    if HPos <= HillLength[i]
      @printf("HillNum => %2i\n", i)
      @printf("HillLength      => %8.3f\n", HillLength[i])
      @printf("HillHeight      => %8.3f\n", HillHeight[i])
      @printf("Hor pos on hill => %8.3f\n", HPos)
      HL = HillLength[i]
      HH = HillHeight[i]
      HillAng = -90. + (360. * HPos / HL)
      #VPos = (sind(HillAng) * HH * .5) + (.5 * HH)
      VPos = (sind(HillAng) + 1.0) * .5 * HH
      @printf("Ver pos on hill => %8.3f\n", VPos)
      SlopeAng = HillAng - 90.  #-- slope is the sine ang displace left by 90 deg
      Slope = sind(SlopeAng)
      @show(HillAng)
      @show(SlopeAng)
      @show(Slope)
      println(" ")
      break
    end
    xPosRel += HillLength[i]
    HPos = xpos - xPosRel #-- pos on a specific hill
  end
  return HPos, HillAng, SlopeAng, Slope
end

#=
. === Global Constants ===
. CstrWt = 2000 [lb]
. Poundal = 32 [lb-ft/sec^2]
. FrontalArea = 20 [ft^2]
. CfWindFr = 1.1 [coef]
. CfRunnerFr = .005 [coef]
. DeltaTime = .1 [sec]
. MassDensAir = .0029 [lb/ft^3]
=#
function CoasterForces(Vel, XPos,  )
  # gravitational force = 32 ft/sec^2 (ie. 32 poundals)
  # F (poundals -> lb-ft/sec^2) = Wt (lbs) * Acc (ft/sec^2) -- poundals force
  # f (lbs) = (Wt (lbs) / 32 ft/sec^2) * Acc (ft/sec^2)     -- pounds force
  # Slope = function(XPos)
  # WindFr = CfWindFr * FrontalArea * .5 * MassDensAir * Vel * Vel
  # RunnerFr = CfRunnerFr * CstrWt * Slope
  # GravityPull = CstrWt / Poundal * Slope

end


CoasterAngle(1.01)
CoasterAngle(51.1)
CoasterAngle(100.11)
CoasterAngle(151.1)
println("shoud be good thru here")
CoasterAngle(200.99)
CoasterAngle(250.99)
CoasterAngle(310.)
println("interate over hill 2")
NumIncs = 10
for i = 1:NumIncs
  hinc = HillHeight[2] / NumIncs
  h = ((i - 1) * hinc) + HillLength[1]
  CoasterAngle(h)

end