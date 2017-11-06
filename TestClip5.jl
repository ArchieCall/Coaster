#using BenchmarkTools
xx = 1.
for i = 1:100
  xx = xx/i
  y = xx^xx
  @show(xx,y)
end
