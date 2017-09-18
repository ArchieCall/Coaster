#junk code
#=
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
for i = 1:NumIncs + 1
  hinc = HillHeight[2] / NumIncs
  h = ((i - 1) * hinc) + HillLength[1]
  CoasterAngle(h)
end

#----- calc wind friction on front of coaster (lb)
function WindFriction(speed::Float64)
  #-- speed => speed of coaster along track(ft/sec)
  area = 4.0  #--square feet of frontal area of coaster train
  coef_friction = 1.1  #-- coef of air friction of coaster train
  wind_friction = coef_friction * area * air_density * .5 * speed * speed #-- wind friction (lb)
  return
end

WindFriction(50.)
=#