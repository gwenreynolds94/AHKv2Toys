
Class QuickTip {

    Static Initialize()
    {
        Tooltip.On  := this.TipOn
        Tooltip.Off := this.TipOff
    }

    Static TipOn => ( _this, _msg:="", _dur:=False) => (
                        ( TimerArgs:=[(*)=>Tooltip()] ),
                        ( !!_dur and IsNumber(_dur) ) ? ( TimerArgs.Push(_dur) ) : (0), 
                        ( Tooltip(_msg), (SetTimer(TimerArgs*)), (_dur) ))
    Static TipOff => 
        (_this, _delay:=1000) => (SetTimer((*) => Tooltip(), _delay))
    
    Static Initialized => 
        (!!Tooltip.HasOwnProp("On") and !!ToolTip.HasOwnProp("Off")) ? True : False
}

Class QuickTip2 {
    Call(a*) => Tooltip(a*)
    Initialized => (!!this.HasOwnProp("On") and !!this.HasOwnProp("Off")) ? True : False
    Off(_delay:=1000) => (SetTimer((*) => Tooltip(), _delay))
    On(_msg:="", _dur:=False) => (
        ( TimerArgs:=[(*)=>Tooltip()] ),
        ( !!_dur and IsNumber(_dur) ) ? ( TimerArgs.Push(_dur) ) : (0), 
        ( Tooltip(_msg), (SetTimer(TimerArgs*)), (_dur) ))
}

#Include ..\DEBUG\DBT.ahk

; QuickTip3:={}
; QuickTip3.Prototype := ToolTip.Base
; dbgo QuickTip3
; dbgo QuickTip3.Prototype
; dbgo Primitive.Prototype
; 
; ExitApp
; 
; (QT:=QuickTip).Initialize()
; Tooltip.On QT.Initialized, 2000
; Sleep 3000
; Tooltip.On QT.__Class
; Tooltip.Off
; 
; 
; QTT:=QuickTip2()
; QTT("Hello")
; QTT.Off 2000

QT := Tooltip

ExitApp
; Sleep 3000
; tstobj:={}
; tstobj.Call := (_,a*)=>Tooltip(a*)
; tstobj "Hello"
; Sleep 1000
; tstobj