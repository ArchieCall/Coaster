using BenchmarkTools
y = zeros(Float64, 4_000_000,10 )
y[:, 3] = 1.  #-- change and arbitrary col

@views function abv(y::Array)
  y[:,1] = rand()
  ub = sum(y[2:end, 2:end])
  return ub
end
abv(y)  #-- warmup
@benchmark abv(y)

function abnv(y::Array)
  y[:,1] = rand()
  ub = sum(y[2:end, 2:end])
  return ub
end
abnv(y)  #-- warmup
@benchmark abnv(y)
