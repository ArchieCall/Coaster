#using BenchmarkTools
@views function rand1(n::Int, k::Int)
  return randperm(n)[1:k]
end

@views function rand2(n::Int, k::Int)
  FoundNum = falses(n)
  RetArray = zeros(Int, k)
  for i = 1:k
    Trial = round(Int, (n - 1) * rand()) + 1
    if !FoundNum[Trial]
      FoundNum[Trial] = true
      RetArray[i] = Trial
      #break
    else
      for j = 1:n
        upnum = Trial + j
        if upnum <= n
          if !FoundNum[upnum]
            FoundNum[upnum] = true
            RetArray[i] = upnum
            break
          end
        end
        dnnum = Trial - j
        if dnnum >= 1
          if !FoundNum[dnnum]
            FoundNum[dnnum] = true
            RetArray[i] = dnnum
            break
          end
        end
      end
    end
  end
  return RetArray
end

@noinline function rand3(n::Int, k::Int)
  RetArray = zeros(Int, k)
  #Offset = zeros(Int, k)
  Offset = collect(Int, 1:k)
  PctReduce = .5
  FoundNum = falses(n)
  minkmax = 4
  LastRecoding = false
  nmax = n
  kmax = n
  for m = 1:3  #-- outer loop perform reduction on each pass
    if m == 1   #-- the first reduction loop
      nmax = n
      kmax = round(Int, nmax * PctReduce)
      priorkmax = 0
      @show(m, nmax, kmax, priorkmax)
      @show(Offset)
    else     #-- subsequent reduction loops
      @show(m)
      @show(kmax)
      println("i got here with m bigger than 1")
      #-- recode Offset array
      nmax = kmax
      priorkmax = kmax
      kmax = round(Int, nmax * PctReduce)
      if nmax <= minkmax
        kmax = nmax
        LastRecoding = true
        #--
      end
      @show(m, nmax, kmax, priorkmax)
      Offset = zeros(Int, nmax)
      @show(FoundNum, Offset)
      numtrue = 0
      for cc = 1:n
        if FoundNum[cc]
        numtrue += 1
        end
      end
      @show(numtrue)
      vi = 0
      for v = 1:n
        if FoundNum[v]
          vi += 1
          @show(vi)
          Offset[vi] = v
        end
      end
      println("you completed an offset recalc")
      @show(FoundNum, Offset, kmax)
      #error("you stoppa")
    end
    for q = 1:kmax
      LoopCnt = 0
      KeepLooping = true
      while KeepLooping  #-- put exactly kmax nums in RetArray
        Trial = round(Int, (nmax - 1) * rand()) + 1
        CkNum = Offset[Trial]
        @show(Trial, CkNum)
        if !FoundNum[CkNum]
          FoundNum[CkNum] = true
          RetIndex = q + priorkmax
          RetArray[RetIndex] = CkNum
          @show(Trial, CkNum, RetIndex)
          break
        end
        LoopCnt += 1
        LoopCnt == 8 && break
      end
    end #-- end of inner loop for q
    if LastRecoding
      break  #-- you are done
    end
    @show(kmax, FoundNum)
    sleep(1.)
  end  #-- end outer loop
  return RetArray
end



n = 32
k = 32

#=
rand1(n,k)
for l = 1:10
  b = rand1(n,k)
  show(b)
  println("")
end
#@benchmark rand1(n,k)
=#

rand3(n,k)
error("bummer")
for l = 1:10
  b = rand3(n,k)
  show(b)
  println("")
end
#@benchmark rand3(n,k)