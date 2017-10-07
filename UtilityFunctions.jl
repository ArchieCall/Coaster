module UtilityFunctions
RInt(x::AbstractFloat) = round(Int, x)  #-- convert x to an integer by rounding to default rounding mode
export RInt
end