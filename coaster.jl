# coaster.jl
# 10/01/2017

#=
Computes forces on multihill roller coaster
TODO:
allow program to continue on and fill Slope and Radius vectors with a vel of 1.
Arc 4 or 5 is wrong
use ArcLength to generate DegInc to match desired SegsPerFt
computer summary stats by each uphill and downhill
loops in track
twists in track
=#

module RollerCoaster
const MassDensityAir = .0029   #-- density of air [ld/ft^3]
const GravityConstant = 32.    #-- force of gravity on earth [ft/sec^2]
const CfWindFr = .60           #-- coef of wind friction on coaster front [coef]
const FrontalArea = 15.        #-- front area of coaster [ft^2]
const CfRunnerFriction = .015  #-- friction coef of runner wheels on track (null)
const CstrLbs = 2000.          #-- weight of coaster cars and riders (lb)
const NumHills = 3             #-- number of hills on the track 
const SegsPerFt = 2            #-- number of segments per foot of horizontal distance
const WheelBaseFt = 8          #-- wheel base of coaster car must be integer
const WheelBaseSegments = WheelBaseFt * SegsPerFt  #-- segments in wheel base
const WheelBaseSegmentsHalf = Int(WheelBaseSegments * .5)  #-- one half wheel base

using DataFrames
SourceFile = "c:\\ArchieCoaster\\ArcData.csv"
#-- the last row of csv file is an EOF row => allows error free processing from 2nd last row
df = readtable(SourceFile, header=true)
numrows = nrow(df)
@show(df)   #--- show the data frame as specified by csv file
println("  ")


#-- infer missing data for all columns of data frame except EOF row
for i =1:numrows - 1     #-- note excludes EOF row
  #-- get the data out of data frame
  rad = df[i, :Radius]
  ang1 = df[i, :BegAng]
  ang2 = df[i, :EndAng]
  revdeg = df[i, :RevDeg]
  rotdir = df[i, :RotDir]

  ang2 = ang1 + revdeg
  if rotdir == "CW"
    ang2 = ang1 - revdeg
  end
  if ang2 > 360.
    ang2 -= 360.
  end
  if ang2 < 0.
    ang2 += 360.
  end 
  x1 = df[i, :BegX]
  x2 = df[i, :EndX]
  y1 = df[i, :BegY]
  y2 = df[i, :EndY]
  xc = df[i, :XCen]
  yc = df[i, :YCen]
  if i == 1
    #-- calc p1 and p2
    x1 = xc + rad * cosd(ang1)
    x2 = xc + rad * cosd(ang2)
    y1 = yc + rad * sind(ang1)
    y2 = yc + rad * sind(ang2)
    #-- put p1 back in data frame
    df[i, :BegX] = x1
    df[i, :BegY] = y1
    #-- put p2 back in data frame
    df[i, :EndX] = x2
    df[i, :EndY] = y2
    #-- put p2 in next arc as p1
    df[i+1, :BegX] = x2
    df[i+1, :BegY] = y2
    
  end
  if i > 1
    #-- assume a longer radius
    #-- calc new center of radius
    xc = x1 - rad * cosd(ang1)
    yc = y1 - rad * sind(ang1)
    df[i, :XCen] = xc
    df[i, :YCen] = yc
    
    x2 = xc + rad * cosd(ang2)
    y2 = yc + rad * sind(ang2)
    #-- put p2 back in data frame
    df[i, :EndX] = x2
    df[i, :EndY] = y2
    #-- put p2 in next arc as p1
    df[i+1, :BegX] = x2
    df[i+1, :BegY] = y2
    
    
  end
  
end
@show(df)  #--- data frame with all missing data inferred
@goto 112
#error("do fuzz")
println(" ")

#-- create XTemp, YTemp
XTemp = Array{Float64}(10000)
YTemp = Array{Float64}(10000)

#-- fill the XC and YC vectors from the dataframe arcs
SegsPerFt = 2
Counter = 1
for i =1:numrows - 1
  Radius = df[i, :Radius]
  BegAng = df[i, :BegAng]
  EndAng = df[i, :EndAng]
  RotateType = df[i, :RotDir]
  xc = df[i, :XCen]
  yc = df[i, :YCen]
  
  DiffAng = EndAng - BegAng
  if RotateType == "CCW"
    if DiffAng < 0.
      DiffAng += 360.  #-- wrapped the 0. deg axis
    end
  end
  if RotateType == "CW"
    if DiffAng > 0.
      DiffAng -= 360.  #-- wrapped the 0. deg axis
    end
  end
  #ArcLength = 2 * pi * Radius * (DiffAng / 360.)
  
  NumArcSegs = max( 1, abs(round(Int, DiffAng * SegsPerFt)))
  DegInc = DiffAng / NumArcSegs
  @show(DegInc, NumArcSegs)
  ThisDeg = BegAng
  for i = 1:NumArcSegs
    x2 = xc + Radius * cosd(ThisDeg)
    y2 = yc + Radius * sind(ThisDeg)
    @printf("i => %4i  deg => %8.4f  x2 => %8.4f  y2 => %8.4f\n", i, ThisDeg, x2, y2 )
    XTemp[Counter] = x2
    YTemp[Counter] = y2
    ThisDeg +=  DegInc
    Counter += 1
  end
  
end
@show(df)

#-- create XC, YC, SlopeSegment, RadiusSegment float arrays
XC = Array{Float64}(Counter)
YC = Array{Float64}(Counter)
SlopeSegment = Array{Float64}(Counter)
RadiusSegment = Array{Float64}(Counter)
for i = 1:Counter
  XC[i] = XTemp[i]
  YC[i] = YTemp[i]
end

#error("dizzy")

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

for i = 1:10:Counter
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
    #error("Error velocity on uphill reached zero!")
    #println("Error velocity on uphill reached zero!")
    NewVel = 1.
  else
    NewVel = sqrt(InsideSqrt)
  end
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
EndXFt =   round(Int, (Counter / SegsPerFt)) - 10       #-- ending hor coor
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