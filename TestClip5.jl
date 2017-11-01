using BenchmarkTools
macro fastrand(b, n)
  return :( round(Int, ($n - $b + 1) * rand(), RoundUp) + $b )
end

speedy = function()
    jake = @fastrand(2, 11)
  return
end
speedy()
@benchmark speedy()

weedy = function()
  jack = rand(1:10)
end

weedy()
@benchmark weedy()

#-- noop by archie
#---- more
  

