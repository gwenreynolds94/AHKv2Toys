#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>


class CursorGetterSetter {
    __Get(Name, Params){
        cPOINT := Buffer(8)
        DllCall "GetCursorPos", "Ptr", cPOINT
        cx := NumGet(cPOINT, 0, "Int"), cy := NumGet(cPOINT, 4, "Int")
        if Name="pos"{
            Return { x: cx, y: cy }
        } else if Name="x" {
            Return cx
        } else if Name="y" {
            Return cy
        } else Return 0
    }
    __Set(Name, Params, Value) {
        if Name="pos" {
            if Value.HasOwnProp("x") and Value.HasOwnProp("y") {
                DllCall "SetCursorPos", "Int", Value.x, "Int", Value.y
                Return 1
            }
            Return 0
        } else if Name="x" {
            if IsNumber(Value) {
                cPOINT := Buffer(8)
                DllCall "GetCursorPos", "Ptr", cPOINT
                cy := NumGet(cPOINT, 4, "Int")
                DllCall "SetCursorPos", "Int", Value, "Int", cy
                Return 1
            }
            Return 0
        } else if Name="y" {
            if IsNumber(Value) {
                cPOINT := Buffer(8)
                DllCall "GetCursorPos", "Ptr", cPOINT
                cx := NumGet(cPOINT, 0, "Int")
                DllCall "SetCursorPos", "Int", cx, "Int", Value
                Return 1
            }
            Return 0
        } else Return 0
    }
}
