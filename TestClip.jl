#test small code
function HH(i::Integer, monkey::AbstractString)
  @show(monkey)
  news = string(i) * monkey
  @show(news)
  return 7
end
HH(2,"archie")