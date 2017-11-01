# test arrays access within function where not passed to functions
TheOutputLine = " kddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd\n"
NumRows = 1_000_000
println("start fill")
BigArray = fill(TheOutputLine, NumRows)
println("end fill")
filel = "c:\\ArchieCoaster\\BigLog.txt"


#-- write to the log file here
#sleep(.02)
#-- write to the log file
q = open(filel,"a")
for i = 1:1_000_000
  ThisLine = string(i) * BigArray[i]
  write(q, ThisLine)
end
close(q)
println("lines have been written")
kk = 37
sleep(200.)
#sleep(.02)