

SizeWindow(wHwnd:=0, wScrGap:=8, *) {
    if !wHwnd
        wHwnd := WinExist("A")
    wTitle  := "ahk_id " wHwnd
    wWidth  := A_ScreenWidth - wScrGap*2
    wHeight := A_ScreenHeight - wScrGap*2
    RealCoordsFromSuperficial(&wRect:=0, wHwnd, wScrGap, wScrGap, wWidth, wHeight)
    WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
}

SizeWindowHalf(wHwnd:=0, wScrGap:=8, side:=0, *) {
    wHwnd   := (!wHwnd) ? WinExist("A") : (wHwnd)
    wWidth  := (A_ScreenWidth-wScrGap*2)//2
    wHeight :=  A_ScreenHeight-wScrGap*2
    wLX := wScrGap, wRX := wScrGap+wWidth
    wTitle  := "ahk_id " wHwnd
    if (side=1) or (side="left")
        wX := wLX
    else if (side=2) or (side="right")
        wX := wRX
    else {
        SuperficialCoordsFromReal(&visRect:=0, wHwnd)
        if (visRect.x=wLX) and (visRect.w=wWidth)
            wX := wRX
        else if (visRect.x=wRX) and (visRect.w=wWidth)
            wX := wLX
        else {
            if (visRect.x>(A_ScreenWidth/2))
                wX := wRX
            else if ((visRect.x+visRect.w)<=(A_ScreenWidth/2))
                wX := wLX
            else if ((((A_ScreenWidth/2)-visRect.x)/visRect.w)>0.5)
                wX := wLX
            else wX := wRX
        }
    }
    wY := wScrGap
    RealCoordsFromSuperficial(&wRect:=0, wHwnd, wX, wY, wWidth, wHeight)
    WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
}

Class WindowGrid {
    layouts :=  Map(
        1, Map(
            1 , { x:0, y:0, w:1, h:2 }
        ),
        2, Map(
            1 , { x:0, y:0, w:1, h:2 },
            2 , { x:1, y:0, w:1, h:2 }
        ),
        3, Map(
            1 , { x:0, y:0, w:1, h:2 },
            2 , { x:1, y:0, w:1, h:1 }, 
            3 , { x:1, y:1, w:1, h:1 }
        ),
        4, Map(
            1 , { x:0, y:0, w:1, h:1 },
            2 , { x:1, y:0, w:1, h:1 }, 
            3 , { x:0, y:1, w:1, h:1 }, 
            4 , { x:1, y:1, w:1, h:1 }
        )
    )
    _rows := 0
    _columns := 0
    _row_height := 0
    _col_width := 0
    outer_gap := 0
    /** @prop {WindowGridItem[]} _items_as_array */
    _items_as_array := []
    _items_by_hWnd := Map()
    _items_by_class := Map()


    __New(rows:=4, columns:=4, outer_gap:=8) {
        this.outer_gap := outer_gap
        this.Rows := rows
        this.Columns := columns
    }

    List[index_type := "hwnd"] => 
        (index_type ~=  "hwnd") ? this._items_by_hWnd  : 
        (index_type ~= "class") ? this._items_by_class :
        (index_type ~=  "flat") ? this._items_as_array : this._items_as_array

    /**
     * @param {Integer} hWnd
     * @param {(False|Object)} coords
     * @return {WindowGridItem}
     */
    Add(hWnd, coords:=False) {
        _cell_size := { w: this._row_height, h: this._col_width }
        new_grid_item := WindowGridItem(coords, _cell_size, hWnd, this.outer_gap)
        _cls := WinGetClass("ahk_id " hWnd)
        if not this._items_by_class.Has(_cls)
            this._items_by_class[_cls] := Map()
        this._items_by_class[_cls][hWnd] := new_grid_item
        this._items_by_hWnd[hwnd] := new_grid_item
        this._items_as_array.Push new_grid_item
        return new_grid_item
    }

    AddClass(wClass, layout:=False, overwrite:=False) {
        new_items := Map()
        if not overwrite and this.List["class"].Has(wClass)
            return (-1)
        wList := WinGetList("ahk_class " wClass)
        if layout {
            for index_1, map_1 in layout
                for index_2, map_2 in map_1
                    _:=_
        }
        for _i, _hWnd in wList
            if layout and _i <= layout.Count
                new_coords := 
            new_items[_i] := this.Add(_hWnd)
        return new_items
    }

    Rows {
        Get => this._rows
        Set {
            this._rows := Value
            this._row_height := ((A_ScreenHeight - this.outer_gap*2) // this._rows)
        }
    }

    Columns {
        Get => this._columns
        Set {
            this._columns := Value
            this._col_width := ((A_ScreenWidth - this.outer_gap*2) // this._columns)
        }
    }

    ApplyToClass(wClass:=False, recalc:=True) {
        if not wClass
            wClass := WinGetClass("ahk_id " WinExist("A"))
        if this._items_by_class.Has(wClass) ; maybe add handling of new classes that can be accessed here
            for _hwnd, _item in this._items_by_class[wClass]
                _item.ApplyRealCoords(recalc)
    }
}

Class WindowGridItem {
    HWND := 0x0,
    _cell_size := {},
    _cell_coords := {},
    _pixel_coords := {},
    _real_coords := {},
    outer_gap := 0

    /**
     * @param {Object} cell_coords
     * @param {Object} cell_size
     * @param {Integer} hWnd
     * @param {Integer} outer_gap
     */
    __New(cell_coords:=False, cell_size:=False, hWnd:=0x0, outer_gap:=8) {
        this.outer_gap := outer_gap
        this._cell_coords := cell_coords ? cell_coords : this._cell_coords
        this._cell_size := (cell_size) ? (cell_size) : {}
        this.HWND := hWnd
    }

    RealCoords[calculate:=True] => (calculate) ? (
        pCoord := this.Coords["pixel"], RealCoordsFromSuperficial( 
            &realCoords:=0, this.HWND, pCoord.x, pCoord.y, pCoord.w, pCoord.h
        ), this._real_coords := realCoords) : this._real_coords

    ApplyRealCoords(recalculate:=True) {
        rCoords := this.RealCoords[recalculate]
        WinMove(rCoords.x, rCoords.y, rCoords.w, rCoords.h, "ahk_id " this.HWND)
    }

    IsCoords(_obj, _coord_names*) {
        _needed_names := _coord_names.Length ? _coord_names : ["x","y","w","h"]
        for _i, _nm in _needed_names
            if ( not _obj.HasProp(_nm) ) or 
               ( not _obj.%_nm% is Number )
                return false
        return True
    }

    CellSize {
        Get => this._cell_size
        Set {
            if not (Value and (Value is Number) and 
                    this.IsCoords(ccrd:=this._cell_coords))
                return
            this._cell_size := Value
            this._pixel_coords := { 
                x: (ccrd.x * Value)  +  (this.outer_gap),
                y: (ccrd.y * Value)  +  (this.outer_gap),
                w: (ccrd.w * Value), h: (ccrd.h * Value) }
        }
    }

    Coords[ units:="cells", cell_size:=False ] {
        Get => ( units ~=  "cells" ) ?  this._cell_coords : 
               ( units ~= "pixels" ) ? this._pixel_coords : False
        Set { 
            if not this.IsCoords(Value)
                return
            if ( units ~= "cells" )
                this._cell_coords := Value, this.CellSize := cell_size
            else if ( units ~= "pixels" )
                this._pixel_coords := Value
        }
    }
}

Class WinGridItem {
    _rows := 0,
    _columns := 0,
    _row_height := 0,
    _column_width := 0,
    _row_pos := 0,
    _column_pos := 0,
    _row_size := 0,
    _column_size := 0,
    changed := True,
    wScrGap := 0,
    x := 0,
    y := 0,
    w := 0,
    h := 0,
    real := {},
    HWND := 0x0

    __New(columns, rows, column_pos, row_pos, column_size:=1, row_size:=1, wScrGap:=8) {
        this.wScrGap := wScrGap
        this.Columns := columns
        this.Rows := rows
        this.ColumnPos := column_pos
        this.RowPos := row_pos
        this.ColumnSize := column_size
        this.RowSize := row_size
    }

    Columns {
        Get => this._columns
        Set {
            this._column_width := (A_ScreenWidth - (this.wScrGap * 2)) // Value
            this._columns := Value
            this.changed := True
            if (
                ((this._column_pos + this._row_pos) >= 2) and 
                ((this._column_size + this._row_size) > 0)
            ) {
                this.EvalGrid()
            }
            return this._columns
        }
    }

    Rows {
        Get => this._rows
        Set {
            this._row_height := (A_ScreenHeight - (this.wScrGap * 2)) // Value
            this._rows := Value
            this.changed := True
            if (
                ((this._column_pos + this._row_pos) >= 2) and 
                ((this._column_size + this._row_size) > 0)
            ) {
                this.EvalGrid()
            }
            return this._rows
        }
    }

    ColumnWidth {
        Get => this._column_width
        Set => (this._column_width := Value, this.changed := True)
    }

    RowHeight {
        Get => this._row_height
        Set => (this._row_height := Value, this.changed := True)
    }

    ColumnPos {
        Get => this._column_pos
        Set {
            this._column_pos := Value
            this.x := this.wScrGap + ((this._column_pos - 1) * this._column_width)
            this.changed := True
            return this._column_pos
        }
    }

    RowPos {
        Get => this._row_pos
        Set {
            this._row_pos := Value
            this.y := this.wScrGap + ((this._row_pos - 1) * this._row_height)
            this.changed := True
            return this._row_pos
        }
    }

    ColumnSize {
        Get => this._column_size
        Set {
            this._column_size := Value
            this.w := this._column_width * this._column_size
            this.changed := True
            return this._column_size
        }
    }

    RowSize {
        Get => this._row_size
        Set {
            this._row_size := Value
            this.h := this._row_height * this._row_size
            this.changed := True
            return this._row_size
        }
    }

    Raw[dimens:=False] {
        Get =>  (dimens ~= "^[xywh]$") ? (this.%dimens%) : 
                { x:this.x, y:this.y, w:this.w, h:this.h }
        Set =>  (dimens ~= "i)^[xywh]$") ? (
                this.%dimens% := Value, 
                this.changed := True) : (
                (dimens.HasOwnProp("x"))   and 
                (dimens.HasOwnProp("y"))   and 
                (dimens.HasOwnProp("y"))   and 
                (dimens.HasOwnProp("h"))) ? (
                (this.x := dimens.x),
                (this.y := dimens.y),
                (this.w := dimens.w),
                (this.h := dimens.h),
                (this.changed := True)) : False
    }

    EvalGrid() {
        this.ColumnPos := this._column_pos
        this.RowPos := this._row_pos
        this.ColumnSize := this._column_size
        this.RowSize := this._row_size
    }

    EvalReal() {
        if (not this.HWND) or (not WinExist("ahk_id " this.HWND))
            return
        RealCoordsFromSuperficial(&_rc:=0, this.HWND, this.x, this.y, this.w, this.h)
        this.real.x := _rc.x
        this.real.y := _rc.y
        this.real.w := _rc.w
        this.real.h := _rc.h
        this.changed := False
        return {x:_rc.x, y:_rc.y, w:_rc.w, h:_rc.h}
    }

    Place(_activate := True) {
        if this.changed
            this.EvalReal()
        if not WinExist("ahk_id " this.HWND)
            return False
        if _activate 
            WinActivate("ahk_id " this.HWND)
        WinMove(this.real.x, this.real.y, this.real.w, this.real.h, "ahk_id " this.HWND)
        return True
    }
}

; TODO ; Resize Active Grid Column+Row

Class WinGrid {
    rows := Map()
    columns := Map()
    rowsflat := []
    columnsflat := []
    rowcnt := 0
    colcnt := 0
    increments := { Y:16, X: 32 }
    outergap := 0
    _HWNDs := []
    _fill := "Y"
    
    __New(col_cnt := 2, row_cnt := 2, outer_gap := 8, fill:="Y") {
        this.outergap := outer_gap
        this.colcnt := col_cnt
        this.rowcnt := row_cnt
        Loop col_cnt
            this.columns[A_Index] := Map()
        Loop row_cnt
            this.rows[A_Index] := Map()
        Loop col_cnt {
            ci := A_Index
            Loop row_cnt {
                ri := A_Index
                _grid := WinGridItem(col_cnt, row_cnt, ci, ri, 1, 1, outer_gap)
                this.rows[ri][ci] := this.columns[ci][ri] := _grid
                this.columnsflat.Push _grid
            }
        }
        for ri, row in this.rows
            for ci, itm in row
                this.rowsflat.Push itm
        this._fill := fill
    }

    Bisect() {
        for _i, _item in this.rowsflat {
            _item.Columns *= 2
            _item.Rows *= 2
            _item.RowSize *= 2
            _item.ColumnSize *= 2
            _item.RowPos *= 2
            _item.ColumnPos *= 2
        }
    }

    Resize(column, row, width_incr, height_incr) {
        
    }

    PlaceAll() {
        for _i, _item in this.rowsflat
            _item.Place()
    }

    Resetcoords() {
        for ci, column in this.columns {
            for ri, _item in column {
                _item.ColumnPos := ci
                _item.RowPos := ri
                _item.RowSize := _item.ColumnSize := 1
            }
        }
    }

    HWNDs[by_column:=False] {
        Get {
            _hwnd_map := Map()
            for _i, _item in this.rowsflat
                if _item.HWND
                    _hwnd_map[_item.HWND] := _item
            return _hwnd_map
        }
        Set {
            if (Type(Value) != "Array")
                return False
            _hwnd_map := Map()
            _outer := by_column ? this.columnsflat : this.rowsflat
            for _oi, _item in _outer
                if _oi <= Value.Length
                    _hwnd_map[(_item.HWND := Value[_oi])] := _item
            return _hwnd_map
        }
    }
;|- 
;|- x, y := 6, 16
;|- ┌────────┬────────┐    ┌──────┬──────────┐
;|- │     8,3│     8,3│    │   6,1│      10,1│
;|- │        │        │    ├──────┼──────────┤
;|- │        │        │    │   6,5│A     10,5│
;|- ├────────┼────────┤    │      │          │
;|- │     8,3│A    8,3│    │      │          │
;|- │        │  x+=2  │    │      │   x+=2   │
;|- │        │  y+=2  │    │      │   y+=2   │
;|- └────────┴────────┘    └──────┴──────────┘
;|- 
;|- x, y := 30, 9
;|- ┌───────────────┬───────────────┐    ┌──────────────────┬────────────┐   
;|- │           15,3│           15,3│    │              18,2│        12,2│   
;|- │            1,1│           16,1│    │               1,1│        19,1│   
;|- │               │               │    ├──────────────────┼────────────┤   
;|- ├───────────────┼───────────────┤    │A             18,5│        12,5│   
;|- │A          15,3│4          15,3│    │               1,3│        19,3│   
;|- │     x+=3   1,4│           16,4│    │                  │            │   
;|- │     y+=2      │               │    │       x+=3       │            │   
;|- ├───────────────┼───────────────┤    │       y+=2       │            │   
;|- │           15,3│7          15,3│    ├──────────────────┼────────────┤   
;|- │            1,7│           16,7│    │              18,2│        12,2│   
;|- │               │               │    │               1,8│        19,8│   
;|- └───────────────┴───────────────┘    └──────────────────┴────────────┘   

    ExpandY(rownr, hincr:=20) {
               gap := this.outergap, workheight := (A_ScreenHeight - 2*gap)
              rcnt := this.rowcnt   , inactcnt   := (rcnt - 1)
         inactincr := (hincr // inactcnt)
             hincr := (inactincr * inactcnt)
        hhalflower := (hincr // 2), hhalfofst := Mod(hincr, 2)
            blwcnt := Abs(rownr - rcnt)
            abvcnt := inactcnt - blwcnt
        for _i, _item in this.rows[1]
            _item.RowHeight += (abvcnt ? inactincr : hincr)
        Loop abvcnt {
            aidx := A_Index
            if aidx == 1
                continue
            for _i, _item in this.rows[aidx] {
                _prev_item := this.rows[(aidx - 1)][_i]
                _item.RowHeight += inactincr
                ;--- ?? FIXME ??
                ;--- may need to add to _item.y if gaps are uneven
                _item.y += (_prev_item.y + _prev_item.RowHeight)
            }
        }
        for _i, _item in this.rows[rownr] {
            _item.RowHeight += hincr
            if rownr > 1 {
                _prev_item := this.rows[rownr][_i]
                _item.y += (_prev_item.y + _prev_item.RowHeight)
            }
        }
        Loop blwcnt {
            aidx := A_Index + abvcnt + 1
            for _i, _item in this.rows[aidx] {
                _prev_item := this.rows[(aidx - 1)][_i]
                _item.RowHeight += inactincr
                _item.y += (_prev_item.y + _prev_item.RowHeight)
            }
        }
        ;--- for _i, _item in this.rows[rownr]
            ;--- _item.RowHeight += hhalfofst
        ;--- this.Resetcoords()
        for _i, _item in this.rowsflat {
            _item.changed := True
            _item.Place()
        }
        ;--- for _i, _item in this.rows[1]
        ;---     _item.RowHeight += inactincr
        ;--- for _i, _item in this.rows[rcnt] {
        ;---     _item.RowHeight
        ;--- }
        ;--- allynew := []
        ;|- for _i, _item in this.rows[rownr]
        ;|-     _item.RowHeight += hincr
        ;|- ;|- for _i, _item in this.rowsflat {
        ;|-     if _item.RowPos == rownr
        ;|- }
        ;|- Loop abvcnt
        ;|-     for _i, _item in this.rows[abvcnt]
        ;|-         _item.RowHeight += inactincr
        ;--- Loop  {
        ;---     aidx := A_Index
        ;---     _ofst := (aidx - rownr)
        ;---     for _i, _item in this.rows[rcnt] {
        ;---         _item.y += (aidx < rownr) ? 
        ;---                     ((aidx - 1)*inactincr*(-1))
        ;---     }
        ;---     _rnewincrs := (A_Index < rownr) ? 
        ;---                     {y:((A_Index-1)*inactincr*(-1)), h:inactincr} :
        ;---                  () ? {} : {}
        ;---     if A_Index < rownr {
        ;---         for _i, _item in this.rows[A_Index]
        ;---             _item.y += 
        ;---     } else if A_Index > rownr {
        ;---         
        ;---     } else {
        ;---         
        ;---     }
        ;--- }
        ;|- Loop abvcnt {
        ;|-     
        ;|-     allynew.Push (
        ;|-             this.columns[1][A_Index].y + ((A_Index - 1) * inactincr)
        ;|-         )
        ;|- }
             ;|- tincr := (hhalflower + Mod(hincr, 2))
             ;|- bincr := hhalflower
        ;--- actynew := this.rows[rownr][1].y
        ;--- Loop abvcnt
        ;---     
        ;---     
        ;---     
        ;|- abvincr := 
        ;|- for _ri, _row in this.rows {
        ;|-     _isact := (_ri == rownr)
        ;|-     _actoffset := _ri - rownr
        ;|-     _edge := (_ri == -1) ? 1 : (_ri == rcnt) ? (1) : False
        ;|-     _rhincr := (_isact) ? hincr : ()
        ;|-     if _ri == rownr {
        ;|-         _rhincr := hincr
        ;|-     } else {
        ;|-         if (_ri > rownr)
        ;|-             
        ;|-         _rhincr := inactincr
        ;|-     }
        ;|-     if _edge == -1
        ;|-         _ryincr := 0
        ;|-     else if _edge == 1
        ;|-         _ryincr := _isact ? ((-1)*hincr) : inactincr
        ;|-     else if _isact
        ;|-         _ryincr := (-1)*tincr
        ;|-     for _ii, _item in _row {
        ;|-         _item.RowHeight += _rhincr
        ;|-         
        ;|-     }
        ;|- }
                
    }

    ExpandX(colnr, wincr:=20) {
        gap   := this.outergap, workwidth := (A_ScreenWidth - 2*gap)
        ccnt  := this.colcnt   , inactcnt  := ccnt - 1
        wincr := (wincr // inactcnt) * inactcnt
        edge  := (colnr == 1) ? 1 : (colnr == ccnt) ? ccnt : False
        whalflower := (wincr // 2)
        lincr := whalflower + Mod(wincr, 2)
        rincr := whalflower
    }

    ShrinkY(rownr) {
    }

    ShrinkX(rownr) {
    }

    SizeActiveY(row_pos, shrink := False) {
        db_str := ""
        for _i, _item in this.rows[row_pos]
            db_str .=   
                "▼▼▼▼▼" row_pos . "▼▼▼▼▼" _i . "▼▼▼▼▼`n" .
                stdo([
                    "x: " _item.x, 
                    "y: " _item.y, 
                    "w: " _item.w, 
                    "h: " _item.h
                ], {__opts: {noprint: True}})
        MsgBox db_str
        if (row_pos < 1)
            row_pos := 1
        else if (row_pos > this.rowcnt)
            row_pos := this.rowcnt
        row_heights := []
        row_positions := []
        sum_heights := 0
        pre_actv_sum := 0
        post_actv_sum := 0
        pre_actv_cnt := 0
        post_actv_cnt := 0
        for ri, _row in this.rows {
            sum_heights += _row[1].h
            if ri < row_pos {
                pre_actv_sum += _row[1].h
                pre_actv_cnt += 1
            } else if ri > row_pos {
                post_actv_sum += _row[1].h
                post_actv_cnt += 1
            }
            row_heights.Push _row[1].h
            row_positions.Push _row[1].y
        }
        polarity := (shrink ? (-1) : 1)
        actv_row_incr := this.increments.Y * polarity
        row_incr := actv_row_incr // (this.rowcnt - 1)
        actv_row_incr := row_incr * (this.rowcnt - 1)
        actv_row_incr_half := Round((actv_row_incr * polarity) / 2) * polarity
        ;| pre_actv_incr := (pre_actv_cnt) ? (row_incr * ) : 0
        ;| post_actv_incr := (post_actv_cnt) ? (post_actv_sum // post_actv_cnt) : 0
        Loop this.rowcnt {
            ri := A_Index
            if ri == row_pos {
                for ci, _grid_item in this.rows[ri] {
                    _grid_item.h += actv_row_incr
                    if (ri == this.rowcnt)
                        _grid_item.y += actv_row_incr
                    else if (ri > 1)
                        _grid_item.y += actv_row_incr_half
                }
            } else {
                for ci, _grid_item in this.rows[ri] {
                    _grid_item.h -= row_incr
                    if (ri > row_pos)
                        _grid_item.y -= row_incr
                    else
                        _grid_item.y += row_incr
                }
            }
        }
        db_str := ""
        for _i, _item in this.rows[row_pos]
            db_str .=   
                "▼▼▼▼▼" row_pos . "▼▼▼▼▼" _i . "▼▼▼▼▼`n" .
                stdo([
                    "x: " _item.x, 
                    "y: " _item.y, 
                    "w: " _item.w, 
                    "h: " _item.h
                ], {__opts: {noprint: True}})
        MsgBox db_str
    }

    Layout {
        Get {
            _layout := Map()
            
        }
    }
    
    SetHWNDs(_HWNDList, by_column := False) {
        outer := (by_column) ? this.columns : this.rows
        HWNDIndex := 1
        for _oi, _oa in outer {
            for _ii, _item in _oa {
                if HWNDIndex <= _HWNDList.Length
                    _item.HWND := _HWNDList[HWNDIndex]
                else
                    _item.HWND := 0
                HWNDIndex += 1
            }
        }
    }
}
    ;|- SetHWNDs(_HWNDList, by_column := False) {
    ;|-     FillY() {
    ;|-     }
    ;|-     FillX() {
    ;|-     }
    ;|-     FillNone() {
    ;|-     }
    ;|-     outer := (by_column) ? this.columns : this.rows
    ;|-     HWNDIndex := 1
    ;|-     for _oi, _oa in outer {
    ;|-         for _ii, _item in _oa {
    ;|-             if HWNDIndex <= _HWNDList.Length
    ;|-                 _item.HWND := _HWNDList[HWNDIndex]
    ;|-             else
    ;|-                 _item.HWND := 0
    ;|-             HWNDIndex += 1
    ;|-         }
    ;|-     }
    ;|-
    ;|-     if not by_column {
    ;|-         for ri, row in this.rows {
    ;|-             for ci, itm in row {
    ;|-                 if HWNDIndex <= _HWNDList.Length
    ;|-                     itm.HWND := _HWNDList[HWNDIndex]
    ;|-                 else
    ;|-                     itm.HWND := 0
    ;|-                 HWNDIndex += 1
    ;|-             }
    ;|-         }
    ;|-     } else {
    ;|-         for ci, col in this.columns {
    ;|-             for ri, itm in col {
    ;|-                 if HWNDIndex <= _HWNDList.Length
    ;|-                     itm.HWND := _HWNDList[HWNDIndex]
    ;|-                 else
    ;|-                     itm.HWND := 0
    ;|-                 HWNDIndex += 1
    ;|-             }
    ;|-         }
    ;|-     }
    ;|- }

;|- /**
;|-  * @param {Integer} columns
;|-  * @param {Integer} rows
;|-  * @param {Integer} wScrGap
;|-  */
;|- GetWinGrid(columns:=2, rows:=2, wScrGap:=8, *) {
;|-     wGrid := []
;|-     Loop columns {
;|-         _row := []
;|-         ci := A_Index
;|-         Loop rows {
;|-             ri := A_Index
;|-             _row.Push WinGridItem(columns, rows, ci, ri, 1, 1, wScrGap)
;|-         }
;|-         wGrid.Push _row
;|-     }
;|-     return wGrid
;|- }

GetWindowMarginsRect(&win, wHwnd) {
    win := {}
    newWinRect := Buffer(16)
    DllCall("GetWindowRect", "Ptr", wHwnd, "Ptr", newWinRect.Ptr)
    win.x := NumGet(newWinRect,  0, "Int")
    win.y := NumGet(newWinRect,  4, "Int")
    win.w := NumGet(newWinRect,  8, "Int")
    win.h := NumGet(newWinRect, 12, "Int")
}

GetWindowVisibleRect(&frame, wHwnd) {
    DWMWA_EXTENDED_FRAME_BOUNDS := 9
    newFrameRect := Buffer(16)
    rectSize := 16
    frame := {}
    DllCall("Dwmapi.dll\DwmGetWindowAttribute"
          , "Ptr" , wHwnd
          , "Uint", DWMWA_EXTENDED_FRAME_BOUNDS
          , "Ptr" , newFrameRect.Ptr
          , "Uint", rectSize)
    frame.x := NumGet(newFrameRect,  0, "Int")
    frame.y := NumGet(newFrameRect,  4, "Int")
    frame.w := NumGet(newFrameRect,  8, "Int")
    frame.h := NumGet(newFrameRect, 12, "Int")
}

SuperficialCoordsFromReal(&outCoords, wHwnd) {
    WinGetPos &wX, &wY, &wW, &wH, "ahk_id " wHwnd
    GetWindowMarginsRect( &win , wHwnd)
    GetWindowVisibleRect(&frame, wHwnd)
    offSetLeft   := frame.x - win.x
    offSetRight  := win.w - frame.w
    offSetBottom := win.h - frame.h
    outCoords    := {}
    outCoords.y  := wY
    outCoords.x  := wX + offSetLeft
    outCoords.h  := wH - offSetBottom
    outCoords.w  := wW - (offSetRight * 2)
    return outCoords
}

RealCoordsFromSuperficial(&outCoords, wHwnd, wX, wY, wW, wH) {
    GetWindowMarginsRect( &win , wHwnd)
    GetWindowVisibleRect(&frame, wHwnd)
    offSetLeft   := frame.x - win.x
    offSetRight  := win.w - frame.w
    offSetBottom := win.h - frame.h
    outCoords    := {}
    outCoords.y  := wY
    outCoords.x  := wX - offSetLeft
    outCoords.h  := wH + offSetBottom
    outCoords.w  := wW + (offSetRight * 2)
    return outCoords
}
