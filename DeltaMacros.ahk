#SingleInstance,Force
#NoEnv
 
Gui, Add, ListBox, w300 h200 hwndhOutput
Gui, Add, Text, xm w300 center, Hit F9 to toggle on / off
Gui, Show,, Game Macro Recorder/Writer

RecordInitialMousePos := False				;ENABLING THIS OPTION CAUSES ISSUES WITH GAMES. Feel free to enable it if recording a script that's NOT for a game. 
LineArray := []
HighAccuracy := True
MacroOn := 0
md := new MouseDelta("MouseEvent")
ih := InputHook("V")
ih.KeyOpt("{All}","N")
ih.KeyOpt("{F9}","E")
ih.NotifyNonText := True
ih.OnKeyUp := Func("IHKU")
ih.OnKeyDown := Func("IHKD")
filenumber := 0
LastTime := 0
StateArray := Object()
Q := DllCall("QueryPerformanceFrequency", "int64*", F)


return
 

GuiClose:
	md.Delete()
	md := ""
	ExitApp

F9::
	QPC(1)
	MacroOn := !MacroOn
	md.SetState(MacroOn)
	if (MacroOn == True)
	{
		text := "RECORDING START"
		GuiControl, , % hOutput, % text
		sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
		filename := A_ScriptDir "\currentscript_" filenumber ".ahk"
		while FileExist(filename)
			{
				filenumber := filenumber+1
				filename := A_ScriptDir "\currentscript_" filenumber ".ahk"
			}
		file := FileOpen(filename,"w")
		LineArray.Push("#SingleInstance,Force")
		LineArray.Push("SetWorkingDir %A_ScriptDir%")
		LineArray.Push("SetTitleMatchMode 2")
		LineArray.Push("#WinActivateForce")
		LineArray.Push("SetControlDelay 1")
		LineArray.Push("SetWinDelay 0")
		LineArray.Push("SetKeyDelay -1")
		LineArray.Push("SetMouseDelay -1")
		LineArray.Push("SetBatchLines -1")
		LineArray.Push("")
		llmouselib =
		(
			;---------------------------------------------------------------------------
SendMouse_LeftClick() { ; send fast left mouse clicks
;---------------------------------------------------------------------------
    DllCall("mouse_event", "UInt", 0x02) ; left button down
    DllCall("mouse_event", "UInt", 0x04) ; left button up
}


;---------------------------------------------------------------------------
SendMouse_RightClick() { ; send fast right mouse clicks
;---------------------------------------------------------------------------
    DllCall("mouse_event", "UInt", 0x08) ; right button down
    DllCall("mouse_event", "UInt", 0x10) ; right button up
}


;---------------------------------------------------------------------------
SendMouse_MiddleClick() { ; send fast middle mouse clicks
;---------------------------------------------------------------------------
    DllCall("mouse_event", "UInt", 0x20) ; middle button down
    DllCall("mouse_event", "UInt", 0x40) ; middle button up
}


;---------------------------------------------------------------------------
SendMouse_RelativeMove(x, y) { ; send fast relative mouse moves
;---------------------------------------------------------------------------
    DllCall("mouse_event", "UInt", 0x01, "UInt", x, "UInt", y) ; move
}


;---------------------------------------------------------------------------
SendMouse_AbsoluteMove(x, y) { ; send fast absolute mouse moves
;---------------------------------------------------------------------------
    ; Absolute coords go from 0..65535 so we have to change to pixel coords
    ;-----------------------------------------------------------------------
    static SysX, SysY
    If (SysX = "")
        SysX := 65535//A_ScreenWidth, SysY := 65535//A_ScreenHeight
    DllCall("mouse_event", "UInt", 0x8001, "UInt", x*SysX, "UInt", y*SysY)
}


;---------------------------------------------------------------------------
SendMouse_Wheel(w) { ; send mouse wheel movement, pos=forwards neg=backwards
;---------------------------------------------------------------------------
    DllCall("mouse_event", "UInt", 0x800, "UInt", 0, "UInt", 0, "UInt", w)
}

QPC_Sleep(S)
{
    global Q,F
    DllCall("QueryPerformanceCounter", "int64*", C1)
    while (((C2 - C1) / F) < S)
        DllCall("QueryPerformanceCounter", "int64*", C2)
    return true
}
QPC(R := 0)
{
	global Q,F
    static P := 0
    return !DllCall("QueryPerformanceCounter", "int64*", Q) + (R ? (P := Q) / F : (Q - P) / F) 
}
		)
		
		

		LineArray.Push(llmouselib)		;Credit to evilC for the LLmouse library too
		LineArray.Push("")
		LineArray.Push("!F12::")
		LineArray.Push("ExitApp")
		LineArray.Push("return")
		LineArray.Push("")
		LineArray.Push("F4::")
		LineArray.Push("Q := DllCall(""QueryPerformanceFrequency"", ""int64*"", F)")
		LineArray.Push("QPC(1)")
		if (RecordInitialMousePos == True )
		{
			MouseGetPos,xpos,ypos
			LineArray.Push("MouseMove, " xpos ", " ypos)
		}
		LastTime := QPC(0)
		ih.Start()
	}
	if (MacroOn == False)
	{
		LineArray.Push("return")
		
		;WRITE ALL TO FILE HERE
		for index, element in LineArray 
		{
			file.writeline(element)
		}
		
		LineArray := []
		
		Loop, 7
			GuiControl, , % hOutput, `n
		sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
		text := "Waiting for script to exit (F4 to play it back, ALT-F12 to quit)"
		GuiControl, , % hOutput, % text
		Loop, 7
			GuiControl, , % hOutput, `n
		sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
		filename := A_ScriptDir "\currentscript_" filenumber ".ahk"
		ih.Stop()
		file.close()
		runwait %filename%
		Loop, 15
			GuiControl, , % hOutput, `n
		sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
	}
	return

~LButton::
	
	if (MacroOn == False)
		return
	t := QPC(0)
	LineArray.Push("QPC_Sleep(" (t-LastTime) ")")
	LineArray.Push("Send,{LButton Down}")
	;GuiControl, , % hOutput, % text
	;sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
	LastTime := t
return

~LButton Up::
	
	if (MacroOn == False)
		return
	t := QPC(0)
	LineArray.Push("QPC_Sleep(" (t-LastTime) ")")

	LineArray.Push("Send,{LButton Up}")
	;GuiControl, , % hOutput, % text
	;sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
	LastTime := t
return

~RButton::
	
	if (MacroOn == False)
		return
	t := QPC(0)
	LineArray.Push("QPC_Sleep(" (t-LastTime) ")")

	LineArray.Push("Send,{RButton Down}")
	;GuiControl, , % hOutput, % text
	;sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
	LastTime := t
return

~RButton Up::
	
	if (MacroOn == False)
		return
	t := QPC(0)
	LineArray.Push("QPC_Sleep(" (t-LastTime) ")")
		
	LineArray.Push("Send,{RButton Up}")
	;GuiControl, , % hOutput, % text
	;sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
	LastTime := t
return

~MButton::
	
	if (MacroOn == False)
		return
	t := QPC(0)
	LineArray.Push("QPC_Sleep(" (t-LastTime) ")")
	LineArray.Push("Send,{MButton Down}")
	;GuiControl, , % hOutput, % text
	;sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
	LastTime := t
return

~MButton Up::
	if (MacroOn == False)
		return
	t := QPC(0)
	LineArray.Push("QPC_Sleep(" (t-LastTime) ")")

	LineArray.Push("Send,{MButton Up}")
	;GuiControl, , % hOutput, % text
	;sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
	LastTime := t
return

IHKD(ih,VK,SC)
{
	global hOutput
	;static text := ""
	global LineArray
	global LastTime
	global StateArray
	
	
	t := QPC(0)   
	
	if (StateArray[VK] == 0)
	{
		return
	}
		
	StateArray[VK] := 0
	;text := "Delta time " (t - LastTime)*1000 " ms : Send,{" GetKeyName(Format("vk{:X}sc{:X}", VK, SC)) " Down}"
	LineArray.Push("QPC_Sleep(" (t-LastTime) ")")

	LineArray.Push("Send,{" Format("vk{:02X}",VK) " Down}")
	;GuiControl, , % hOutput, % text
	;sendmessage, 0x115, 7, 0,, % "ahk_id " hOutputt
	LastTime := t
}

IHKU(ih,VK,SC)
{
	global hOutput
	static text := ""
	global LineArray
	global LastTime
	global StateArray
	
	
	t := QPC(0)  	
	if (VK == 120)
		return
	
	StateArray[VK] := 1
	
	;text := "Delta time " (t - LastTime)*1000 " ms : Send,{vk" VK " Up}"
	LineArray.Push("QPC_Sleep(" (t-LastTime) ")")

	LineArray.Push("Send,{" Format("vk{:02X}",VK) " Up}")
	;GuiControl, , % hOutput, % text
	;sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
	LastTime := t
}

; Gets called when mouse moves
; x and y are DELTA moves (Amount moved since last message), NOT coordinates.
MouseEvent(MouseID, x := 0, y := 0){
	global LineArray
	;global hOutput
	
	;static text := ""
	global LastTime
	
	
	;if (x==0 && y == 0)
	;	return	;Click input
	
	t := QPC(0)
	LineArray.Push("QPC_Sleep(" (t-LastTime) ")")

	LineArray.Push("SendMouse_RelativeMove(" x "," y ")")
	;text := "x: " x ", y: " y (LastTime ? (", Delta Time: " (t - LastTime)*1000 " ms, MouseID: " MouseID) : "")
	;GuiControl, , % hOutput, % text
	;sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
	LastTime := t
}



;QPC code - Credit to @SKAN and @jNizM
QPC_Sleep(S)
{
	global Q,F
    DllCall("QueryPerformanceCounter", "int64*", C1)
    while (((C2 - C1) / F) < S)
        DllCall("QueryPerformanceCounter", "int64*", C2)
    return true
}

QPC(R := 0)
{
	global Q,F
    static P := 0
    return !DllCall("QueryPerformanceCounter", "int64*", Q) + (R ? (P := Q) / F : (Q - P) / F) 
}



;MouseDelta library - Credit to @evilC

; Instantiate this class and pass it a func name or a Function Object
; The specified function will be called with the delta move for the X and Y axes
; Normally, there is no windows message "mouse stopped", so one is simulated.
; After 10ms of no mouse movement, the callback is called with 0 for X and Y
Class MouseDelta {
	State := 0
	__New(callback){
		;~ this.TimeoutFn := this.TimeoutFunc.Bind(this)
		this.MouseMovedFn := this.MouseMoved.Bind(this)

		this.Callback := callback
	}

	Start(){
		static DevSize := 8 + A_PtrSize, RIDEV_INPUTSINK := 0x00000100
		; Register mouse for WM_INPUT messages.
		VarSetCapacity(RAWINPUTDEVICE, DevSize)
		NumPut(1, RAWINPUTDEVICE, 0, "UShort")
		NumPut(2, RAWINPUTDEVICE, 2, "UShort")
		NumPut(RIDEV_INPUTSINK, RAWINPUTDEVICE, 4, "Uint")
		; WM_INPUT needs a hwnd to route to, so get the hwnd of the AHK Gui.
		; It doesn't matter if the GUI is showing, it still exists
		Gui +hwndhwnd
		NumPut(hwnd, RAWINPUTDEVICE, 8, "Uint")
 
		this.RAWINPUTDEVICE := RAWINPUTDEVICE
		DllCall("RegisterRawInputDevices", "Ptr", &RAWINPUTDEVICE, "UInt", 1, "UInt", DevSize )
		OnMessage(0x00FF, this.MouseMovedFn)
		this.State := 1
		return this	; allow chaining
	}
	
	Stop(){
		static RIDEV_REMOVE := 0x00000001
		static DevSize := 8 + A_PtrSize
		OnMessage(0x00FF, this.MouseMovedFn, 0)
		RAWINPUTDEVICE := this.RAWINPUTDEVICE
		NumPut(RIDEV_REMOVE, RAWINPUTDEVICE, 4, "Uint")
		DllCall("RegisterRawInputDevices", "Ptr", &RAWINPUTDEVICE, "UInt", 1, "UInt", DevSize )
		this.State := 0
		return this	; allow chaining
	}
	
	SetState(state){
		if (state && !this.State)
			this.Start()
		else if (!state && this.State)
			this.Stop()
		return this	; allow chaining
	}

	Delete(){
		this.Stop()
		;~ this.TimeoutFn := ""
		this.MouseMovedFn := ""
	}
	
	; Called when the mouse moved.
	; Messages tend to contain small (+/- 1) movements, and happen frequently (~20ms)
	MouseMoved(wParam, lParam){
		Critical
		; RawInput statics
		static DeviceSize := 2 * A_PtrSize, iSize := 0, sz := 0, pcbSize:=8+2*A_PtrSize, offsets := {x: (20+A_PtrSize*2), y: (24+A_PtrSize*2)}, uRawInput
 
		static axes := {x: 1, y: 2}
 
		; Get hDevice from RAWINPUTHEADER to identify which mouse this data came from
		VarSetCapacity(header, pcbSize, 0)
		If (!DllCall("GetRawInputData", "UPtr", lParam, "uint", 0x10000005, "UPtr", &header, "Uint*", pcbSize, "Uint", pcbSize) or ErrorLevel)
			Return 0
		ThisMouse := NumGet(header, 8, "UPtr")

		; Find size of rawinput data - only needs to be run the first time.
		if (!iSize){
			r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", 0, "UInt*", iSize, "UInt", 8 + (A_PtrSize * 2))
			VarSetCapacity(uRawInput, iSize)
		}
		sz := iSize	; param gets overwritten with # of bytes output, so preserve iSize
		; Get RawInput data
		r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", &uRawInput, "UInt*", sz, "UInt", 8 + (A_PtrSize * 2))
 
		x := 0, y := 0	; Ensure we always report a number for an axis. Needed?
		x := NumGet(&uRawInput, offsets.x, "Int")
		y := NumGet(&uRawInput, offsets.y, "Int")
 
		this.Callback.(ThisMouse, x, y)
 
		;~ ; There is no message for "Stopped", so simulate one
		;~ fn := this.TimeoutFn
		;~ SetTimer, % fn, -50
	}
 
	;~ TimeoutFunc(){
		;~ this.Callback.("", 0, 0)
	;~ }
 
}