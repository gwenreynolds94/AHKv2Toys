#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force
SetMouseDelay -1

#Include <DBT>

span := 250
iterations := 10000
center := {x: A_ScreenWidth/2, y: A_ScreenHeight/2}

perf := PerfCounter()

perf.StartTimer()

direction := 1
Loop iterations
{
    DllCall "SetCursorPos"
          , "Int", (center.x + span*direction*(A_Index*(1 / iterations)))
          , "Int", (center.y + span*direction*(A_Index*(1 / iterations)))
    direction := direction * -1
}

stdo perf.Lap()

Loop iterations
{
    DllCall "SetCursorPos"
          , "Int", (center.x + (A_ScreenWidth/2 - 50)*direction)
          , "Int", (center.y + (A_ScreenHeight/2 - 50)*direction)
    direction := direction * -1
}

stdo perf.Lap()

direction := 1
Loop iterations
{
    MouseMove (center.x + span*direction*(A_Index*(1 / iterations)))
            , (center.y + span*direction*(A_Index*(1 / iterations)))
            , 0
    direction := direction * -1
}

stdo perf.Lap()

Loop iterations
{
    MouseMove (center.x + (A_ScreenWidth/2 - 50)*direction)
            , (center.y + (A_ScreenHeight/2 - 50)*direction)
            , 0
    direction := direction * -1
}

stdo perf.Lap()
perf.StopTimer()