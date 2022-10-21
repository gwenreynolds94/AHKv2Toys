#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\DBT.ahk
#Include ..\GdipTest\Gdip_Custom.ahk

if !gdip_token:=Gdip_Startup() {
    MsgBox "Gdi+ failed to start."
    ExitApp
}
OnExit (*)=> Gdip_Shutdown(gdip_token)

if A_ScriptName="ConvertImageToIcon.ahk"
    stdo ImageToIcon(A_ScriptDir "\next.png", A_ScriptDir "\newNext.ico")

ImageToIcon(sourceImg, targetICO:="") {
    SplitPath sourceImg,, &_fileInDirectory,, &_fileInName
    if targetICO
        SplitPath targetICO,, &_fileOutDirectory,, &_fileOutName
    else _fileOutDirectory:=_fileInDirectory, _fileOutName:=_fileInName
    if !(FileExist(sourceImg) ~= "A|N") {
        MsgBox sourceImg " did not point to a file."
        Return 0
    }
    if !InStr(FileExist(_fileOutDirectory), "D") {
        MsgBox "Could not retrieve a valid directory from: " _fileOutDirectory
        Return 0
    }
    _hBitmap := Gdip_CreateBitmapFromFile(sourceImg)
    _hIcon := Gdip_CreateHICONFromBitmap(_hBitmap)
    _result := Gdip_SaveHIconToFile( _hIcon
                                   , _fileOutDirectory "\" _fileOutName ".ico" )
    DestroyIcon(_hIcon)
    Gdip_DisposeImage(_hBitmap)
    Return _result
}


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
;:;:;:;:;:;:;:;:;:; Added below function to Gdip_Custom.ahk ;:;:;:;:;:;:;:;:;:;:
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;

/** 
 * @param {hIcon} _hIcon icon handle
 * @param {String} _targetPath path to new .ico file
 * @return {String} Returns result of FileExist on newly created .ico file
 */

/*
 Gdip_SaveHICONToFile(_hIcon, _targetPath) {
	static IMAGE_BITMAP := 0
		 , copyFlags := (LR_COPYDELETEORG := 0x0008) | (LR_CREATEDIBSECTION := 0x2000)
         , szICONHEADER := 6
         , szICONDIRENTRY := 16
*/

         /**
          * ICONINFO
          * --------
          *     fIcon       BOOL    -> 4   Bytes
          *     xHotspot    DWORD   -> 4   Bytes
          *     yHotspot    DWORD   -> 4   Bytes
          *     padding             -> 0|4 Bytes
          *     hbmMask     HBITMAP -> 4|8 Bytes
          *     hbmColor    HBITMAP -> 4|8 Bytes
          *     --------------------------------------
          *     BOOL x1, DWORD x2, pad04 x1 HBITMAP x2
        */
/*
        , szICONINFO := 8 + A_PtrSize*3
*/
         /**
          * BITMAP
          * ------
          *     bmType        LONG   -> 4   Bytes
          *     bmWidth       LONG   -> 4   Bytes
          *     bmHeight      LONG   -> 4   Bytes
          *     bmWidthBytes  LONG   -> 4   Bytes
          *     bmPlanes      WORD   -> 2   Bytes
          *     bmBitsPixel   WORD   -> 2   Bytes
          *     padding              -> 0|4 Bytes
          *     bmBits        LPVOID -> 4|8 Bytes
          *     -------------------------------------
          *     LONG x4, WORD x2, pad04 x1, LPVOID x1
         */
/*
         , szBITMAP := (4*4) + A_PtrSize*2
*/
         /**
          * BITMAPINFOHEADER
          * ----------------
          *     biSize           DWORD  -> 4 Bytes
          *     biWidth          LONG   -> 4 Bytes
          *     biHeight         LONG   -> 4 Bytes
          *     biPlanes         WORD   -> 2 Bytes
          *     biBitCount       WORD   -> 2 Bytes
          *     biCompression    DWORD  -> 4 Bytes
          *     biSizeImage      DWORD  -> 4 Bytes
          *     biXPelsPerMeter  LONG   -> 4 Bytes
          *     biYPelsPerMeter  LONG   -> 4 Bytes
          *     biClrUsed        DWORD  -> 4 Bytes
          *     biClrImportant   DWORD  -> 4 Bytes
          *     ----------------------------------
          *     DWORD x5, LONG x4, WORD x2
         */
/*
		 , szBITMAPINFOHEADER := (5*4) + (4*4) + (2*2)
*/
         /**
          * DIBSECTION
          * ----------
          *     dsBm            BITMAP           -> 24|32 Bytes
          *     dsBMih          BITMAPINFOHEADER -> 40    Bytes
          *     dsBitfields[3]  DWORD[3]         -> 4[3]  Bytes
          *     padding                          -> 0|4   Bytes
          *     dshSection      HANDLE           -> 4|8   Bytes
          *     dsOffset        DWORD            -> 4     Bytes     
          *     padding                          -> 0|4   Bytes
          *     -------------------------------------------------------------
          *     BITMAP x1, BITMAPINFOHEADER x1, DWORD x4, HANDLE x1, pad04 x2
         */ 
/*
         , szDIBSECTION := szBITMAP + szBITMAPINFOHEADER + 8 + A_PtrSize*3

    ICONINFO := Buffer(szICONINFO, 0) ; 4 Bytes of padding offset at 12
    DllCall("GetIconInfo", "Ptr", _hIcon, "Ptr", ICONINFO.Ptr)

    h_hbmMask := NumGet(ICONINFO, 8 + A_PtrSize, "Ptr")
    if !hbmMask:=DllCall("CopyImage", "Ptr", h_hbmMask		; h 	 (handle)
                                    , "UInt", IMAGE_BITMAP	; type 	 (0|1|2, bm|cur|ico)
                                    , "Int", 0, "Int", 0	; cx, cy (width, height)
                                    , "UInt", copyFlags		; flags
                                    , "Ptr") {
        MsgBox "CopyImage failed.`nLastError: " A_LastError
        Return
    }
    h_hbmColor := NumGet(ICONINFO, 8 + A_PtrSize*2, "Ptr")
    hbmColor := DllCall("CopyImage", "Ptr", h_hbmColor      ; h
                                    , "UInt", IMAGE_BITMAP   ; type
                                    , "Int", 0, "Int", 0     ; cx, cy
                                    , "UInt", copyFlags      ; flags
                                    , "Ptr")

    maskDIB := Buffer(szDIBSECTION, 0)
    colorDIB := Buffer(szDIBSECTION, 0)
    DllCall("GetObject", "Ptr", hbmMask , "Int", szDIBSECTION, "Ptr", maskDIB.Ptr )
    DllCall("GetObject", "Ptr", hbmColor, "Int", szDIBSECTION, "Ptr", colorDIB.Ptr)

    colorWidth        := NumGet(colorDIB,  4, "UInt")
    colorHeight       := NumGet(colorDIB,  8, "UInt")
    colorBmWidthBytes := NumGet(colorDIB, 12, "UInt")
    colorBmPlanes     := NumGet(colorDIB, 16, "UShort")
    colorBmBitsPixel  := NumGet(colorDIB, 18, "UShort")
    colorBits         := NumGet(colorDIB, 16+A_PtrSize, "Ptr")
    colorDataSize     := colorBmWidthBytes * colorHeight
    colorCount        := (colorBmBitsPixel >= 8) 
                            ? 0 : 1 << (colorBmBitsPixel * colorBmPlanes)

    maskHeight       := NumGet(maskDIB,  8, "UInt")
    maskBmWidthBytes := NumGet(maskDIB, 12, "UInt")
    maskBits         := NumGet(maskDIB, 16+A_PtrSize, "Ptr")
    maskDataSize     := maskBmWidthBytes * maskHeight

    iconDataSize  := colorDataSize + maskDataSize
    dwBytesInRes  := szBITMAPINFOHEADER + iconDataSize
    dwImageOffset := szICONHEADER + szICONDIRENTRY

    ICONHEADER := Buffer(szICONHEADER, 0)
    NumPut("UShort", 1, ICONHEADER, 2)
    NumPut("UShort", 1, ICONHEADER, 4)

    ICONDIRENTRY := Buffer(szICONDIRENTRY, 0)
    NumPut("UChar" , colorWidth,       ICONDIRENTRY,  0)
    NumPut("UChar" , colorHeight,      ICONDIRENTRY,  1)
    NumPut("UChar" , colorCount,       ICONDIRENTRY,  2)
    NumPut("UShort", colorBmPlanes,    ICONDIRENTRY,  4)
    NumPut("UShort", colorBmBitsPixel, ICONDIRENTRY,  6)
    NumPut("UInt"  , dwBytesInRes,     ICONDIRENTRY,  8)
    NumPut("UInt"  , dwImageOffset,    ICONDIRENTRY, 12)

    NumPut("UInt", colorHeight*2, colorDIB, szBITMAP + 8)
    NumPut("UInt", iconDataSize, colorDIB, szBITMAP + 20)

    newICO := FileOpen(_targetPath, "w", "cp0")
    newICO.RawWrite(ICONHEADER, szICONHEADER)
    newICO.RawWrite(ICONDIRENTRY, szICONDIRENTRY)
    newICO.RawWrite(colorDIB.Ptr+szBITMAP, szBITMAPINFOHEADER)
    newICO.RawWrite(colorBits+0, colorDataSize)
    newICO.RawWrite(maskBits+0, maskDataSize)
    newICO.Close()
    
    DeleteObject(hbmColor)
    DeleteObject(hbmMask)

    Return FileExist(_targetPath)
}
*/