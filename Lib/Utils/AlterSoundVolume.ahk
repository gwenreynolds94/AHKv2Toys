
/**
 * @param {Integer | String} _volume
 *
 * `0-100` Set volume level
 * 
 * `+n` Increment volume level
 * 
 * `-n` Decremement volume level
 *
 * `toggle` Toggle mute/unmute
 *
 * `mute` Mute if not muted
 *
 * `unmute` Unmute if not unmuted
 */
AlterSound__ShowInfo(_volume:="", _guiWidth:=35, _guiHeight:=100
                                , _guiDuration:=2000, _guiOpacity:=200) {
    static   sound_gui :={}
         ,     AW_HIDE :=0x00010000
         , AW_ACTIVATE :=0x00020000
         ,    AW_BLEND :=0x00080000
    if !(sound_gui is Gui)
        _Initialize_Sound_Gui()
    
    _Show_Sound_Gui()
    SetTimer _Hide_Sound_Gui, -2000

    _Show_Sound_Gui(*) {
        DllCall( "AnimateWindow", "Ptr", sound_gui.Hwnd
                                , "Int", 250
                                , "UInt", AW_ACTIVATE|AW_BLEND )
    }
    _Hide_Sound_Gui(*){
        DllCall( "AnimateWindow", "Ptr", sound_gui.Hwnd
                                , "Int", 250
                                , "UInt", AW_HIDE|AW_BLEND )
    }
    _Initialize_Sound_Gui(*) {
        ; @type {String} ExStyle, prevents window getting focus
        WS_EX_NOACTIVATE:="E0x08000000"
        sound_gui := Gui("+AlwaysOnTop -Caption +" WS_EX_NOACTIVATE)
        sound_gui.MarginX := sound_gui.MarginY := 0
        sound_gui.Add("Text", "x0 y0 w35 h100")
        sound_gui.SetFont("s14 cc35166", "Cousine")
        sound_gui.Show("x" 10 " y" (A_ScreenHeight-10-_guiHeight) " w" _guiWidth " h" _guiHeight " Hide NA")
    }
}
