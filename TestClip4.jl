using BenchmarkTools

function MethodA(n::Int64)
  #-- produce a random integer uniformly distributed between 1 and n
  IntegerDigit = rand(1:n)  
  return IntegerDigit
end

function MethodB(n::Int64)
  #-- initially generate a random float uniformly distributed between 0. and 1.
  #-- round above float to be an integer uniformly distributed between 1 and n
  IntegerDigit = round(Int, n * rand(), RoundUp)  #-- generate digit uniformly distributed between 1 and n
  return IntegerDigit
end

function TestRandomDigits()
  NumLoops = 40_000_000
  SumRandA = zeros(Int, 10)
  SumRandB = zeros(Int, 10)
  for i = 1:NumLoops
    A = rand(1:10)
    #B = round(Int, 10*rand()+.50000000001)
    B = round(Int, 10*rand(), RoundUp)
    SumRandA[A] += 1
    SumRandB[B] += 1
  end
  SumA = sum(SumRandA)
  SumB = sum(SumRandB)
  Space = " "
  NoSpace = ""
  println("")
  println("...  Verify uniform distribution of two methods  ...")
  println("               Method - A            Method - B")
  println("              ------------          ------------")
  for j = 1:10
    CurrSpace = NoSpace
    if j < 10
      CurrSpace = Space
    end
    @printf("Digit: %i  %s  Count:  %i       Count:  %i\n",j, CurrSpace, SumRandA[j], SumRandB[j])
  end
  @printf("  Sum        Count: %i       Count: %i\n",SumA, SumB)
  println("")
end 
TestRandomDigits()  #-- simple test of uniform distribution

println("")
println("MethodA performance")
MethodA(10)  #-- warm up
@benchmark MethodA(10) #-- time with benchmark
@benchmark MethodA(100_000) #-- time with benchmark

println("")
println("MethodB performance")
MethodB(10)  #-- warm up
@benchmark MethodB(10)  #-- time with benchmark
@benchmark MethodB(100_000)  #-- time with benchmark

