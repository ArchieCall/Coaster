#-- DebugTester.jl  10/07/2017
#=
TODO: -- this is doc
Lookee debug function calls inserted at strategic locations in program
Lookee(IndexNum::Int, LocLabel::AbstractString, VarName::AbstractString, VarValue::Any)
---------------------------------------------------------------------------------------
IndexNum : unique integer number referring to the actual location of the function call
LocLabel : text description of the location
VarName  : text label for the actual var to be logged
VarValue : value of the var being logged
----------------------------------------
(i) refers to one specific Lookee function call
Cmds
----
(i)  refers to Loc(i)

[i]->      : log next iter for [i] Note: this is DEFAULT state
[i]-> s[n] : skip next n-1 iters for [i], log the nth iter for [i]
[i]-> l[n] : log next n iters for [i]
[i]-> i    : show the present state of all (i)'s
[i]-> ?    : show help screen
(i)-> c[u] : change prompt from (i) to (u)
(i)-> i    : inactivate logging of (i)
(i)-> a    : activate logging of (i) to its previous state
(i)-> d    : set all (i)'s to DEFAULT state
(i)-> r    : repeat automatically the latest state for (i)
TODO:
parse(Int64,"1_000")  errors while parse("1_000") does not
how to indicate the last command
(1) Iters>1 Loc>Init gg = 1_000  {a}  last command for (1) between the curly brackets
=#

TimesCalled = zeros(Int, 10)
HitsSkipped = zeros(Int, 10)
SkipThisNum = zeros(Int, 10)
LastCommand = fill("",10)

function Lookee(IndexNum::Int, LocLabel::AbstractString, VarName::AbstractString, VarValue::Any)
  i = IndexNum  #-- make the name shorter
  global TimesCalled[i] += 1
  global HitsSkipped[i] += 1
  if HitsSkipped[i] < SkipThisNum[i]
    return false
  end
  
  HitsSkipped[i] = 0
  s0 = "(" * string(i) * ") "
  s1 = "Iter>"
  s2 = string(TimesCalled[i])
  s3 = " Loc>"
  s4 = string(LocLabel) * " "
  s5 = string(VarName)
  s6 = " = "
  s7 = string(VarValue)
  s75 = "  {13}"
  s8 = "\n"
  
  newstr = s0 * s1 * s2 * s3 * s4 * s5 * s6 * s7 * s75 * s8
  filew = "c:\\ArchieCoaster\\DebugCmd.txt"
  filel = "c:\\ArchieCoaster\\DebugLog.txt"
  
  
  #-- write to the log file here
  sleep(.02)
  #-- write to the log file
  q = open(filel,"a")
  write(q, newstr)
  close(q)
  sleep(.02)

  #--- wait until ctrl-s pressed on DebugCmd.txt
  Base.Filesystem.watch_file(filew, 300.)
  sleep(.02)
  rr = open(filew, "r")
  NumSkips = readline(filew)  #-- get the actual command typed
  close(rr)
  LastCommand[i] = NumSkips
  NumSkipsI = 0
  if NumSkips != ""
    #NumSkipsI = parse(Int64, NumSkips)
    NumSkipsI = parse(NumSkips)
  end
  global SkipThisNum[i] = NumSkipsI
  
  #-- blank out the command file
  sleep(.2)
  w = open(filew, "w")
  write(w, "")
  close(w)
  sleep(.2)
  return true
end


gg = 1
for p = 1:10_000_000
  Var = "gg"
  gg = string(p)
  hh = string(p*2)
  Lookee(1, "Init", "gg", gg)
  #Lookee(2, "Main", "hh", hh)
end
