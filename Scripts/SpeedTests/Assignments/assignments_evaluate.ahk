#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force
SetWorkingDir A_ScriptDir


if A_ScriptName="assignments_evaluate.ahk" {
    RunTests 1000
    PrintStats
}

RunTests(iterations:=200){
    Loop iterations {
        RunEvalSep()
        RunEvalSame()
        RunEvalCont()
    }
}

ResetStats() {
    FileDelete "AssignContinuation.txt"
    FileDelete "AssignSeparate.txt"
    FileDelete "AssignSame.txt"
    FileAppend "", "AssignContinuation.txt"
    FileAppend "", "AssignSeparate.txt"
    FileAppend "", "AssignSame.txt"
}

GetStats() {
    cont_sum := 0, sep_sum  := 0, same_sum := 0
    cont_line_count := 0, sep_line_count := 0, same_line_count := 0
    Loop Read, "AssignContinuation.txt" {
        test_time := Number(StrReplace(StrReplace(A_LoopReadLine, "`r"), "`n"))
        cont_sum += test_time
        if test_time
            cont_line_count++
    }
    Loop Read, "AssignSeparate.txt" {
        test_time := Number(StrReplace(StrReplace(A_LoopReadLine, "`r"), "`n"))
        sep_sum += test_time
        if test_time
            sep_line_count++
    }
    Loop Read, "AssignSame.txt" {
        test_time := Number(StrReplace(StrReplace(A_LoopReadLine, "`r"), "`n"))
        same_sum += test_time
        if test_time
            same_line_count++
    }
    Return {
        cont: {
            avg: cont_sum/cont_line_count
          , sum: cont_sum
          , count: cont_line_count
        }
      , sep: {
            avg: sep_sum/sep_line_count
          , sum: sep_sum
          , count: sep_line_count
        }
      , same: {
            avg: same_sum/same_line_count
          , sum: same_sum
          , count: same_line_count
        }
    }
}

PrintStats() {
    stats := GetStats()
    stdo "Separate:"
       , "`t"   "avg: " stats.sep.avg
       , "`t"   "sum: " stats.sep.sum
       , "`t" "count: " stats.sep.count
       , "Same:"
       , "`t"   "avg: " stats.same.avg
       , "`t"   "sum: " stats.same.sum
       , "`t" "count: " stats.same.count
       , "Continuation:"
       , "`t"   "avg: " stats.cont.avg
       , "`t"   "sum: " stats.cont.sum
       , "`t" "count: " stats.cont.count
}


#Include ..\..\..\Lib\DEBUG\DBT.ahk
#Include .\assignments_separate.ahk
#Include .\assignments_same.ahk
#Include .\assignments_continuation.ahk