#-- DebugTester.jl  10/14/2017

#= 
-- this is doc
ee
(IndexNum::Int, LocLabel::AbstractString, VarName::AbstractString, VarValue::Any)
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

iter   :  whenever a Lookee call is encountered in the running program
{wait} :  implies wait for a keyed command after the log of an iter
[n]    :  parm relating to number of iters in a specific command
log    :  display VarValue in the log file, may or may not {wait} for a specific iter

[i]-> s[n] : skip the next n iters, log (n+1)th iter, then {wait}
[i]-> l[n] : log next n iters, {wait} only on the nth iter
[i]->      : log next iter, then {wait} Note: this is the DEFAULT state
[i]-> i    : show the present state of all (i)'s
[i]-> ?    : show help screen
(i)-> c[u] : change prompt from (i) to (u)
(i)-> i    : inactivate logging of (i)
(i)-> a    : activate logging of (i) to its previous state
(i)-> d    : set all (i)'s to DEFAULT state
(i)-> r    : repeat automatically the latest state for (i)
States:
-------
snnn skip nnn and wait
lnnn log nnn and wait - limit nnnn to 9999
i inactive
r repeat last state using its own n
TODO:
cursor moves right in Cmd file between entries
repeat last line of log file in command file so you always know where you are
verify all usage of i - inactivate
how to define the global vars outside of Lookee function
function LookWarn  -- print error messages in DebugLog.txt file
=#
    
    
#----- global vars and arrays for Lookee function
MaxStored = 1_000_000
MTLine = ""
StoredLines = fill(MTLine, MaxStored)  #-- array to hold consecutive logged lines
TimesCalled = zeros(Int, 10)  #-- num of calls to (i)
SkipThisNum = zeros(Int, 10)  #-- num of calls to skip for (i)
HitsSkipped = zeros(Int, 10)  #-- calls skipped so far for (i)
LogThisNum = zeros(Int, 10)   #-- num of calls to log for (i)
HitsLogged = zeros(Int, 10)   #-- calls logged so far for (i)
OverallConsecutiveLogged = 0    #-- consecutive calls logged over all (i)
LastFullCommand = fill("l1",10)  #-- latest full command for (i)  {s100}
LastCharCommand = fill("l",10)  #-- latest char command for (i)  {s}
#--- an array of tuples (CharCmd, MaxQty)
CmdDef = [
("l", "MinMax", 1, 25000),
("i", "NoQty", 0, 0),
("s", "NoMax", 1, 0)]
NumCmds = length(CmdDef)


#function Lookee(IndexNum::Int, LocLabel::AbstractString, VarName::AbstractString, VarValue::Any)
function Lookee(IndexNum::Int, LocLabel::AbstractString, VarName::AbstractString)
  i = IndexNum  #-- make the name shorter
  global TimesCalled[i] += 1  #-- calls to (i)
  
  if LastCharCommand[i] == "i"
    return false    #-- this command is inactive, just return
  end
  
  if LastCharCommand[i] == "s"
    global HitsSkipped[i] += 1
    if HitsSkipped[i] <= SkipThisNum[i]   #-- return early if skipping and below limit
      return false
    end
    HitsSkipped[i] = 0  #-- reset skips
    SkipThisNum[i] = 0  #-- reset skip limit
  end
  
  #-- build up the ValueLine
  s0 = "(" * string(i) * ") "
  s1 = "Iter>"
  s2 = string(TimesCalled[i])
  s3 = " Loc>"
  s4 = string(LocLabel) * "  "
  s5 = string(VarName)
  s6 = " => "
  #s7 = string(VarValue)
  #@show(VarName)
  #error("quitter")
  s7a = include_string(s5)
  s7 = string(s7a)
  s72 = LastFullCommand[i]
  s75 = "    {" * s72 * "}"
  s8 = "\n"
  ValueLine = s0 * s1 * s2 * s3 * s4 * s5 * s6 * s7 * s75 * s8
  
  fDebug = "c:\\ArchieCoaster\\DebugCmd.txt"
  fLog = "c:\\ArchieCoaster\\DebugLog.txt"
  
  #-- write to the log file here
  q = open(fLog,"a")
  write(q, ValueLine)
  close(q)
  #=
  tic()
  q = open(fLog,"r")
  qas  = readstring(q)
  toc()
  close(q)
  lenqas = length(qas)
  qasclip = qas[lenqas-50:lenqas]
  @show(qasclip)
  line = ""
  tic()
  q = open(fLog,"r")
  for line in eachline(q)
  end
  toc()
  close(q)
  @show(line)
  error("stoppydopp")
  =#
  
  
  
  if LastCharCommand[i] == "l"
    if HitsLogged[i] + 1 < LogThisNum[i]
      HitsLogged[i] += 1
      #global OverallConsecutiveLogged += 1  #-- bump overall log count
      o = OverallConsecutiveLogged
      #global StoredLines[o] = ValueLine  #--- store the ValueLine
      return true  #-- do not wait
    else
      HitsLogged[i] = 0
      LogThisNum[i] = 0
    end
  end
  
  #-- blank out the command file
  sleep(.1)
  CmdPrompt = ""
  VLine = chomp(ValueLine) 
  w = open(fDebug, "w+")
  write(w, CmdPrompt)
  close(w)
  flush(w)
  sleep(.1)
  
  CmdKeyed = ""
  #--- wait until ctrl-s pressed on DebugCmd.txt
  OuterIsLooping = true
  while OuterIsLooping   #-- outer loop to recycle back if an error found
    InnerIsLooping = true
    CommandIsValid = false
    while InnerIsLooping  #-- inner loop to build up valid command
      
      Base.Filesystem.watch_file(fDebug, 300.)  #-- wait until command file is saved
      
      sleep(.1)
      rr = open(fDebug,"r")
      CmdLine = readline(fDebug, chomp = true)  #-- get and chomp the line of actual command keyed
      close(rr)
      flush(rr)
      sleep(.2)
      CmdKeyed = strip(CmdLine)
      @show(CmdKeyed)
      if CmdKeyed == ""
        CmdKeyed = "l1"  #-- remake an MT line into "l1"
      end
      LenCmd = length(CmdKeyed)
      CharCmd = ""
      QtyCmd = ""
      if LenCmd >= 1
        CharCmd = CmdKeyed[1:1] #-- peel out the char command
      end
      LenCmd > 1 && (QtyCmd = CmdKeyed[2:LenCmd])  #-- peel out the string qty
      WarnMsg = fill("", 10)
      
      #-- test CharCmd (ie. 1st char of command)
      CharCmdOK = false
      CharVal = ""
      CharQtyRange = ""
      CharQtyMin = 0
      CharQtyMax = 0
      for t = 1:NumCmds
        CharVal, CharQtyRange, CharQtyMin, CharQtyMax = CmdDef[t]
        if CharVal == CharCmd
          CharCmdOK = true
          break
        end
      end
      if !CharCmdOK
        #-- error in CharCmd
        WarnMsg[1] = "Full command => " * CmdKeyed
        WarnMsg[2] = "Command ID => " * CharCmd * " is invalid!!"
        NumMsgs = 2
        q = open(fLog,"a")
        write(q, "\n")
        write(q, "------------ an error was found! ---------------\n")
        for m = 1:NumMsgs
          MsgL = WarnMsg[m] * "\n"
          write(q, MsgL)
        end
        write(q, "\n")
        close(q)
        sleep(.3)
        break   #-- break out of inner loop
      end
      
      
      #-- test the quantity string is all integers
      ValidQty = true
      for g = 2:LenCmd
        if !isdigit(CmdKeyed[g])
          ValidQty = false
          WarnMsg[1] = "Full command => " * CmdKeyed
          WarnMsg[2] = "Specified quantity => " * QtyCmd * " is invalid!!"
          NumMsgs = 2
          q = open(fLog,"a")
          write(q, "\n")
          write(q, "------------ an error was found! ---------------\n")
          for m = 1:NumMsgs
            MsgL = WarnMsg[m] * "\n"
            write(q, MsgL)
          end
          write(q, "\n")
          close(q)
          sleep(.3)
          
          break  #-- break out of for loop
        end
      end
      !ValidQty && break   #-- break out of inner loop
      
      
      CmdQty = parse(Int, CmdKeyed[2:end])
      #--- validate the MinMax quantity
      if CharQtyRange == "MinMax"
        ValidRange = false
        if (CmdQty <= CharQtyMax) & (CmdQty >= CharQtyMin)
          ValidRange = true
        else
          WarnMsg[1] = "Full command => " * CmdKeyed
          WarnMsg[2] = "Specified quantity => " * QtyCmd * " is out of range!!"
          WarnMsg[3] = "... it must be between " * string(CharQtyMin) * " and " * string(CharQtyMax)
          NumMsgs = 3
          q = open(fLog,"a")
          write(q, "\n")
          write(q, "------------ an error was found! ---------------\n")
          for m = 1:NumMsgs
            MsgL = WarnMsg[m] * "\n"
            write(q, MsgL)
          end
          write(q, "\n")
          close(q)
          sleep(.3)
        end
        !ValidRange && break  #-- break out of inner loop if invalid range
      end
      
      #--- validate the NoMax quantity
      ValidRange = false
      if CharQtyRange == "NoMax" 
        ValidRange = false
        if CmdQty >= CharQtyMin
          ValidRange = true
        else
          WarnMsg[1] = "Full command => " * CmdKeyed
          WarnMsg[2] = "Specified quantity => " * QtyCmd * " is out of range!!"
          WarnMsg[3] = "... it must be greater than " * string(CharQtyMin)
          NumMsgs = 3
          q = open(fLog,"a")
          write(q, "\n")
          write(q, "------------ an error was found! ---------------\n")
          for m = 1:NumMsgs
            MsgL = WarnMsg[m] * "\n"
            write(q, MsgL)
          end
          write(q, "\n")
          close(q)
          sleep(.3)
        end
        !ValidRange && break  #-- break out of inner loop if invalid range
      end
      
      #-- all portions of command have been validated 
      CommandIsValid = true
      break  #-- break out with a valid command
    end   #-- end of inner loop
    
    CommandIsValid && break    #-- break out with a valid command
    
  end  #-- end of outer loop
  
  NQty = parse(Int, CmdKeyed[2:end])
  CharKeyed = lowercase(CmdKeyed[1:1])
  LastFullCommand[i] = CmdKeyed
  LastCharCommand[i] = CharKeyed
  
  if CharKeyed == "s"
    #-- a skip command -> skip nnn hits and wait on nnn+1th
    global SkipThisNum[i] = NQty
  end
  
  if CharKeyed == "l"
    #-- a log command -> log nnn hits and wait on the nnnth
    global LogThisNum[i] = NQty
  end
  
  #if CharKeyed == ""
  #  #-- default command which is same as "l1"
  #  global LogThisNum[i] = 1
  #end
  
  #-- blank out the command file
  sleep(.18)
  w = open(fDebug, "w")
  write(w, "")
  close(w)
  #sleep(.2)
  
  
  return true
end

gg = 1
gp = 77
for p = 1:1_000_000
  Var = "gg"
  gg = string(p)
  hh = string(p*2)
  #gp = p
  #Lookee(1, "Init", "gg", gg)
  Lookee(1, "Init", "gp")
  #Lookee(2, "Railroad", "hh", hh)
end
    