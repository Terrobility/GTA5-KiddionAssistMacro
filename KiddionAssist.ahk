#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SendMode Event
SetKeyDelay, 0, 50

; 1) Run this script with administrator privileges.
; 2) Keep GTA 5 in Windowed/Borderless mode.
; 3) Start the "Blow Up II" job, ideally with matchmaking closed.
; 4) Ensure the menu is open with "Kill All Cars" selected.
; 5) Also crank up tunables Min Mission Payout to $100,000 and RP Multiplier to 10x.
; -- (Going above 20x makes RP glitch out at 0. I purposely do that to avoid gaining levels.)
; 6) Press Numpad * to start or pause the script!

; Configurables
TargetCycles := 1000  ; Should run for just under 24h, earning GTA$100M (+ up to 5,000,000 RP) total

; Internals - DO NOT EDIT BELOW THIS LINE!
Paused := 1
ElapsedCycles := -1
ElapsedTime := 0

SetTimer, MissionCycle, 1000

; Numpad multiply (*) toggles whether the cycle should run
NumpadMult::
    Paused := Paused = 1 ? 0 : 1
    ToolTip, % "[TOGGLE] Is paused: " . Paused, 64, 96, 2
    SetTimer, RemoveToolTip2, -3000
return

; Numpad subtract (-) kills the script
NumpadSub::
    Paused := true
    ToolTip, % "[EXITAPP] Elapsed cycles: " . ElapsedCycles . " (" . (ElapsedTime / 1000 / 60 / 60) . " hrs)", 64, 96, 2
    SetTimer, RemoveToolTip2, -5000
    Sleep, 5000
    ExitApp
return

; Mission cycle loop
MissionCycle() {
    ; Assume global
    global

    ; Don't run if paused
    if (Paused = 1) {
        ; ToolTip, % "[DEBUG] Paused returned 1", 64, 64
        return
    }

    ; Delay initial start
    if (ElapsedCycles = -1) {
        ToolTip, % "[DEBUG] Held on delayed initial start", 64, 64
        Sleep, 5000
        ElapsedCycles := 0
        return
    }

    ; Check if hit target cycles
    if (ElapsedCycles = TargetCycles) {
        ToolTip, % "[DEBUG] Paused and reset after hitting " . TargetCycles . " TargetCycles`n`nCompleted cycles: " . ElapsedCycles . " (" . (ElapsedTime / 1000 / 60 / 60) . " hrs)", 64, 64
        Paused := true
        ElapsedCycles := -1
        ElapsedTime := 0
        return
    }

    ; Attempts kill all cars 2 times for a total of 10 seconds
    Loop, 2
    {
        ToolTip, % "[DEBUG] Sending Numpad5 - " . A_Index, 64, 64
        ; Selects the highlighted menu option
        Send, {Numpad5}
        ; Waits 10 seconds for mission selection prompt
        Sleep, 5000
    }

    ; Attempts quick repeat 6 times for a total of 30 seconds
    Loop, 6
    {
        ToolTip, % "[DEBUG] Sending PgUp - " . A_Index, 64, 64
        ; Press the quick repeat hotkey, has no effect if replay is already loading
        Send, {PgUp}
        ; Waits 5 seconds
        Sleep, 5000
    }

    ; Delay for another 20 to 30 seconds
    ; -- If removed, you'll get transaction errors after running for 2.5 hours ($28M earned)
    Random, rand, 22500, 30000
    ToolTip, % "[DEBUG] Sleeping for " . rand . " ms", 64, 64
    Sleep, % rand

    ; Track elapsed stats
    ElapsedCycles += 1
    ElapsedTime += (10000 + 30000 + rand)

    ; Display tooltip
    ToolTip, % "[DEBUG] Elapsed cycles: " . ElapsedCycles . " (" . (ElapsedTime / 1000 / 60 / 60) . " hrs)", 64, 64
    ; SetTimer, RemoveToolTip, -10000
}

RemoveToolTip(Which:=1) {
    ToolTip,,,, % Which
}

RemoveToolTip2() {
    ToolTip,,,, 2
}
