

SciLoad(_dll_path:="SciLexer.dll") {
    _sci_pointer := DllCall("LoadLibrary", "Str", _dll_path, "Ptr")
    Gui.Prototype.SciAdd := ((_gui, _opts:="")=>ScinChilla(_gui, _opts))
    Return _sci_pointer
}

SciFree(_sci_pointer) {
    Try
        FileAppend("Freeing the Scintilla.dll Library...`n", "*")

    DllCall("FreeLibrary", "Ptr", _sci_pointer)
}

SciSend(_msg, _wparam:=0, _lparam:=0, _hwnd:="") {
    static _init := False
         , _DirectFunction := ""
         , _DirectPointer  := ""
         , _SCI_GETDIRECTFUNCTION := 2184
         , _SCI_GETDIRECTPOINTER  := 2185

    if !_init and _hwnd {
        _init := True
        _DirectFunction := SendMessage(_SCI_GETDIRECTFUNCTION, 0, 0,, "ahk_id " _hwnd)
        _DirectPointer  := SendMessage(_SCI_GETDIRECTPOINTER , 0, 0,, "ahk_id " _hwnd)
        Return
    } else if !_init and !_hwnd
        Return

    Return DllCall(_DirectFunction
                 , "UInt", _DirectPointer
                 , "Int" , _msg
                 , "UInt", _wparam
                 , "UInt", _lparam)
}

Class ScinChilla {
    WS := { OVERLAPPED: "0x00000000",            POPUP: "0x80000000",                ;
                 CHILD: "0x40000000",         MINIMIZE: "0x20000000",                ;
               VISIBLE: "0x10000000",         DISABLED: "0x08000000",                ;
              MAXIMIZE: "0x01000000",          CAPTION: "0x00C00000",                ;
                BORDER: "0x00800000",         DLGFRAME: "0x00400000",                ;
               VSCROLL: "0x00200000",          HSCROLL: "0x00100000",                ;
               SYSMENU: "0x00080000",       THICKFRAME: "0x00040000",                ;
                 GROUP: "0x00020000",          TABSTOP: "0x00010000",                ;
           MINIMIZEBOX: "0x00020000",      MAXIMIZEBOX: "0x00010000",                ;
                 TILED: "0x00000000",           ICONIC: "0x20000000",                ;
               SIZEBOX: "0x00040000",     CLIPSIBLINGS: "0x04000000",                ;
          CLIPCHILDREN: "0x02000000",                                                ;
                    Ex: { ACCEPTFILES: "0x00000010",      APPWINDOW: "0x00040000", ; ;
                           CLIENTEDGE: "0x00000200",     COMPOSITED: "0x02000000", ; ;
                          CONTEXTHELP: "0x00000400",  CONTROLPARENT: "0x00010000", ; ;
                        DLGMODALFRAME: "0x00000001",        LAYERED: "0x00080000", ; ;
                            LAYOUTRTL: "0x00400000",           LEFT: "0x00000000", ; ;
                        LEFTSCROLLBAR: "0x00004000",     LTRREADING: "0x00000000", ; ;
                             MDICHILD: "0x00000040",     NOACTIVATE: "0x08000000", ; ;
                      NOINHERITLAYOUT: "0x00100000", NOPARENTNOTIFY: "0x00000004", ; ;
                  NOREDIRECTIONBITMAP: "0x00200000",          RIGHT: "0x00001000", ; ;
                       RIGHTSCROLLBAR: "0x00000000",     RTLREADING: "0x00002000", ; ;
                           STATICEDGE: "0x00020000",     TOOLWINDOW: "0x00000080", ; ;
                              TOPMOST: "0x00000008",    TRANSPARENT: "0x00000020", ; ;
                           WINDOWEDGE: "0x00000100"                                } }
    Options := {
        x: 5,
        y: 5,
        w: 450,
        h: 250,
        Style: this.WS.CHILD | this.WS.TABSTOP,
        Visible: False,
        ExStyle: this.WS.Ex.CLIENTEDGE,
        GuiID: 311210
    }
    
    /* @prop {Gui} gui */
    gui := {}
    
    __New(_gui, _opts:="") {
        Global sNul := ""
             , iNul := 0
        if (IsObject(_opts))
            for _prop, _def in _opts.OwnProps()
                if (this.Options.HasOwnProp(_prop))
                    this.Options.%_prop% := _def
        this.gui := _gui
        this.Create()
    }

    Create() {
        WStyle := ( (!!this.Options.Visible)                 ;
                    ? (this.Options.Style | this.WS.VISIBLE) ;
                    : this.Options.Style                     )
        this.hwnd := DllCall("CreateWindowEx"                   ;
                            ,"Uint", this.Options.ExStyle       ; Ex Style
                            ,"Str",  "Scintilla"                ; Class Name
                            ,"Str",  sNul                       ; Window Name
                            ,"UInt", WStyle                     ; Window Styles
                            ,"Int",  this.Options.x             ; x
                            ,"Int",  this.Options.y             ; y
                            ,"Int",  this.Options.w             ; Width
                            ,"Int",  this.Options.h             ; Height
                            ,"UInt", this.gui.Hwnd              ; Parent HWND
                            ,"UInt", this.Options.GuiID         ; (HMENU)GuiID
                            ,"UInt", iNul                       ; hInstance
                            ,"UInt", iNul, "UInt")              ; lpParam
        this.Send(iNul, iNul, iNul, this.hwnd)
        Return this.hwnd
    }

    Send(_msg, _wparam:=0x00, _lparam:=0x00, _hwnd:=0x00) {
        static _SCI_GETDIRECTFUNCTION := 2184, _SCI_GETDIRECTPOINTER  := 2185
             , _DirectFunction := 0x0, _DirectPointer := 0x0
             , _init := False
    
        ; If properties aren't initialized, do so
        if (!_init and _hwnd) {
            _DirectFunction := SendMessage(_SCI_GETDIRECTFUNCTION, 0, 0,, "ahk_id " _hwnd)
            _DirectPointer := SendMessage(_SCI_GETDIRECTPOINTER , 0, 0,, "ahk_id " _hwnd)
            _init := True
            Return
        } else if (!_init and !_hwnd) {  ; properties do not exist and cannot be set
            Return
        }
    
        ; Send message to Scintilla control
        Return DllCall( _DirectFunction
                      , "UInt", _DirectPointer
                      , "Int", _msg
                      , "UInt", _wparam
                      , "UInt", _lparam )
    }
}

; ; ; ; /**
; ; ; ;  * SciLoad uses the **LoadLibrary** function from **libloaderapi.h**
; ; ; ;  *      to load the Scintilla DLL library and bind a method named **`SciAdd`**
; ; ; ;  *      to the prototype of the global Gui class. **SciAdd** takes one
; ; ; ;  *      argument, the options parameter associated with **`Gui.Add`**. The
; ; ; ;  *      control returned from **SciAdd** owns a **`Send`** method used for
; ; ; ;  *      sending messages directly to the control via DLL calls, which takes
; ; ; ;  *      a *message*, optional *wparam*, and optional *lparam* as arguments.
; ; ; ;  *
; ; ; ;  *
; ; ; ;  * @param {`String`} _dll_path If left blank, "Scintilla.dll" will be searched
; ; ; ;  *                              for in the current working directory.
; ; ; ;  * @return {`Pointer`} A pointer to the Scintilla.dll Library
; ; ; ;  */
; ; ; ; SciLoad(_dll_path:="") {
; ; ; ;     ; Load Scintilla library and obtain pointer
; ; ; ;     _sci_pointer := DllCall( "LoadLibrary"                                    ;
; ; ; ;                            , "Str", !!_dll_path ? _dll_path : "Scintilla.dll" ;
; ; ; ;                            , "Ptr"                                            )
; ; ; ; 
; ; ; ;     /**
; ; ; ;      * Function to be attached to *`Gui.Prototype`*, allowing for a custom
; ; ; ;      *      Scintilla control to be added with a **`Send`** method for sending
; ; ; ;      *      messages to the control directly with DLL calls
; ; ; ;      */
; ; ; ;     SciAdd(_gui, _opts:="") {
; ; ; ;         ctrl := _gui.Add("Custom", "ClassScintilla " _opts)
; ; ; ;         ctrl.Send := SciCtrlSend
; ; ; ;         ctrl.Send(0, 0, 0, ctrl.Hwnd)
; ; ; ;         Return ctrl
; ; ; ;     }
; ; ; ; 
; ; ; ;     ; Set SciAdd method for global Gui class
; ; ; ;     Gui.Prototype.SciAdd := SciAdd
; ; ; ; 
; ; ; ;     ; Return pointer to Scintilla library
; ; ; ;     Return _sci_pointer
; ; ; ; }
; ; ; ; 
; ; ; ; /**
; ; ; ;  * SciFree uses the **FreeLibrary** function from **libloaderapi.h** in System Services
; ; ; ;  * @param {`Pointer`} _sci_pointer A Pointer to the Scintilla.dll library
; ; ; ;  */
; ; ; ; SciFree(_sci_pointer) {
; ; ; ;     Try
; ; ; ;         FileAppend("Freeing the Scintilla.dll Library...`n", "*")
; ; ; ; 
; ; ; ;     DllCall("FreeLibrary", "Ptr", _sci_pointer)
; ; ; ; }
; ; ; ; 
; ; ; ; /**
; ; ; ;  * Retrieve direct references to a Scintilla function and pointer and store
; ; ; ;  *      them in static variables so as to avoid the overhead associated with
; ; ; ;  *      using SendMessage. The hwnd is stored in a static variable after first
; ; ; ;  *      usage (and subsequents).
; ; ; ;  * @param {Int} _msg
; ; ; ;  * @param {UInt} _wparam
; ; ; ;  * @param {UInt} _lparam
; ; ; ;  * @param {hWnd} _hwnd
; ; ; ;  */
; ; ; ; SciSend(_msg, _wparam:=0, _lparam:=0, _hwnd:="") {
; ; ; ;     static _init := False
; ; ; ;          , _DirectFunction := ""
; ; ; ;          , _DirectPointer  := ""
; ; ; ;          , _SCI_GETDIRECTFUNCTION := 2184
; ; ; ;          , _SCI_GETDIRECTPOINTER  := 2185
; ; ; ;     if !_init and _hwnd {
; ; ; ;         _init := True
; ; ; ;         _DirectFunction := SendMessage(_SCI_GETDIRECTFUNCTION, 0, 0,, "ahk_id " _hwnd)
; ; ; ;         _DirectPointer  := SendMessage(_SCI_GETDIRECTPOINTER , 0, 0,, "ahk_id " _hwnd)
; ; ; ;         Return
; ; ; ;     } else if !_init and !_hwnd
; ; ; ;         Return
; ; ; ;     Return DllCall(_DirectFunction
; ; ; ;                  , "UInt", _DirectPointer
; ; ; ;                  , "Int" , _msg
; ; ; ;                  , "UInt", _wparam
; ; ; ;                  , "UInt", _lparam)
; ; ; ; }
; ; ; ; 
; ; ; ; /**
; ; ; ;  * If **_hwnd** is present and the *`_DirectFunction`* or *`_DirectPointer`*
; ; ; ;  *      property is not already set for **_ctrl**, a direct reference to a
; ; ; ;  *      Scintilla function and pointer are retrieved and stored as said
; ; ; ;  *      properties of **_ctrl**. Subsequent calls use the function and pointer
; ; ; ;  *      to send messages via DLL calls to the Scintilla ctrl without the
; ; ; ;  *      overhead associated with SendMessage.
; ; ; ;  *
; ; ; ;  *
; ; ; ;  * This function is meant to be bound to a *`Gui.Custom`* Scintilla control,
; ; ; ;  *      and as such would pass a hidden **this** variable
; ; ; ;  *      into the first parameter (**_ctrl**), leaving only the remaining
; ; ; ;  *      parameters to be passed when calling.
; ; ; ;  *
; ; ; ;  * @param {Gui.Custom} _ctrl
; ; ; ;  * @param {Any} _msg
; ; ; ;  * @param {Integer} _wparam
; ; ; ;  * @param {Integer} _lparam
; ; ; ;  * @param {Hwnd} _hwnd
; ; ; ;  */
; ; ; ; SciCtrlSend(_ctrl, _msg, _wparam:=0x00, _lparam:=0x00, _hwnd:=0x00) {
; ; ; ;     static _SCI_GETDIRECTFUNCTION := 2184
; ; ; ;          , _SCI_GETDIRECTPOINTER  := 2185
; ; ; ; 
; ; ; ;     ; Check for existence of function/pointer properties in _ctrl
; ; ; ;     if !(_ctrl.HasOwnProp("_DirectFunction")) or !(_ctrl.HasOwnProp("_DirectPointer"))
; ; ; ;         _init := false
; ; ; ;     else _init := true
; ; ; ; 
; ; ; ;     ; If properties aren't initialized, do so
; ; ; ;     if (!_init and _hwnd) {
; ; ; ;         _ctrl.DefineProp("_DirectFunction", {
; ; ; ;             Value: SendMessage(_SCI_GETDIRECTFUNCTION, 0, 0,, "ahk_id " _hwnd)
; ; ; ;         })
; ; ; ;         _ctrl.DefineProp("_DirectPointer", {
; ; ; ;             Value: SendMessage(_SCI_GETDIRECTPOINTER , 0, 0,, "ahk_id " _hwnd)
; ; ; ;         })
; ; ; ;         Return
; ; ; ;     } else if (!_init and !_hwnd) {  ; properties do not exist and cannot be set
; ; ; ;         Return
; ; ; ;     }
; ; ; ; 
; ; ; ;     ; Send message to Scintilla control
; ; ; ;     Return DllCall( _ctrl._DirectFunction
; ; ; ;                   , "UInt", _ctrl._DirectPointer
; ; ; ;                   , "Int", _msg
; ; ; ;                   , "UInt", _wparam
; ; ; ;                   , "UInt", _lparam )
; ; ; ; }