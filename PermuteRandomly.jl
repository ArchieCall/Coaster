#-- 10/24/2017
#-- generate an array of random permutations of length n
using BenchmarkTools
@views function rand1(n::Int, k::Int)  #-- function wrapping existing randperm function
  return randperm(n)[1:k]
end


@views function PermuteRandom(n::Int, k::Int)
  #-- n => length of array to permute
  #-- k => number of array elements to return in final permutted array
  RetArray = zeros(Int, k)  #-- returned permutted array - not presently resized
  #PctReduce = .5000000001  #-- amount to reduce the array in each iteration
  PctReduce = .41000000001  #-- amount to reduce the array in each iteration
  FoundNum = falses(n)  #-- array of bools to determine whether a digit has been used
  #-- a series of iterations to generate k digits in each iteration
  LastRecoding = false
  PermsQueued = n
  FinalQueue = 4
  PermsFilled = 0
  NumDups = 0
  
  for m = 1:100  #-- outer loop perform reduction on each pass
    if m == 1   #-- the first reduction loop
      PermsFilled = 0
      PermsUnfilled = n  #-- 
      Offset = collect(Int, 1:n)  #-- relative offset of remaining permutations 
      PermsQueued = round(Int, PermsUnfilled * PctReduce)
    else     #-- subsequent reduction loops
      
      PermsUnfilled = n - PermsFilled  #-- this line replaces the two commented lines above
      
      PermsQueued = round(Int, PermsUnfilled * PctReduce)
      if PermsUnfilled <= FinalQueue
        PermsQueued = PermsUnfilled
        LastRecoding = true
        #--
      end
      Offset = zeros(Int, PermsUnfilled)
      vi = 0
      for v = 1:n
        if !FoundNum[v]
          vi += 1
          Offset[vi] = v
        else
        end
      end
    end
    
    #println(" ")
    #@show(m, PermsFilled, PermsUnfilled, PermsQueued)
    
    @inbounds for q = 1:PermsQueued
      LoopCnt = 0
      KeepLooping = true
      while KeepLooping  #-- put exactly PermsQueued nums in RetArray
        Trial = round(Int, PermsUnfilled * rand() + .500000001)
        CkNum = Offset[Trial]
        if FoundNum[CkNum] == false
          #-- this is a unique digit put in return array
          FoundNum[CkNum] = true
          RetIndex = q + PermsFilled
          RetArray[RetIndex] = CkNum
          break
        else
          NumDups += 1
        end
      end
    end #-- end of inner loop for q
    PermsFilled += PermsQueued
    if LastRecoding
      break  #-- you are done
    end
  end  #-- end outer loop
  @show(NumDups)
  return RetArray
end

function PermuteRandom1(n::Int64, k::Int64)
  #-- n: length of array to permute
  #-- k: number of array elements to return - not used at present
  PermArray = collect(Int, 1:n)  #-- returned permutted array - not presently resized
  for P1 = 1:n-1
    #P2 = round(Int, (n - P1 + 1) * rand() + .500000001) + P1 - 1
    P2 = rand(P1+1:n)
    PermArray[P1], PermArray[P2] = PermArray[P2], PermArray[P1]
  end
  return PermArray
end


n = 1024  #-- length of Array to permute randomly
k = 1024  #-- number of items from Array to compute

n1 = 50_000_000  #-- length of Array to permute randomly
k1 = 50_000_000  #-- number of items from Array to compute

println("")
println("randperm")
rand1(200, 200)
tic()
rand1(40_000_000, 40_000_000)
toc()

#@benchmark rand1(n,k)

#=
PermuteRandom(n, k)
tic()
PermuteRandom(n1, k1)
toc()
error("you done")

println(" ")
println("stats for PermuteRandom")
tic()
PermuteRandom(n1, k1)
toc()
#@benchmark PermuteRandom(n,k)
=#

println("")
println("PermuteRandom1")
PermuteRandom1(8,8)
tic()
PermuteRandom1(40_000_000, 40_000_000)
toc()
error("after one call")
jj = PermuteRandom1(40_000_000, 40_000_000)
@show(jj[40_000_000])
#@show(jj)