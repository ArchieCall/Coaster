#junk code
a = 2.
b = 5.
function arch(a::Float64, b::Float64)
  if isapprox(a,b)
    r1 = 2.
    return
  end
  r2 = 3.
  return r2
end
j = arch(a,b)
@show(j)