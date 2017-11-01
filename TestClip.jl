using BenchmarkTools

#-- a mutable struct containing two vars and an array
mutable struct MyData
  Hits::Int  #-- var1 of type Int
  Skips::Int #-- var2 of type Int
  SomeArray::Array{Int}  #-- Array type of Int => Note: no dims or length seem to be allowed
end
VarData = MyData(0, 0, zeros(Int,4,3) )
@show(VarData)
#error("jose")

#--- intialize VarData in following two lines
VarData = MyData(0, 0, repeat(0:0, outer = 12))  #--- initialize vars to 0, and Array to length 12x1 with val 0
VarData.SomeArray = reshape(VarData.SomeArray, 4,3)  #-- reshape Array into desired dims of 4x3
#--- is there a (better) way to combine the preceeding two lines into one line?

VarData.Hits = 17
VarData.Skips = 11
VarData.SomeArray[2,3] = 100  #-- set value of SomeArray[2,3] to 100

#-- dummy function to test speed of composite type
function SomeFunc!(NumIters::Int, VarData1::MyData, Val3::Int)
  for i = 1:NumIters
    VarData1.SomeArray[1,3] = Val3  #-- do something arbitrary based on Val3
  end
end

SomeFunc!(2, VarData, 2)  #-- warm up the function
@benchmark SomeFunc!(100_000, VarData, 2)  #-- time by griding thru 100 millions iters

println("all done.")


