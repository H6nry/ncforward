#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         H6nry <henry.anonym@gmail.com>

 Script Function:
	Counterpart of the NCForward iOS Cydia tweak. You will definitely need this, if you want to use NCForward.
	License of this code: You are allowed to learn from this but not allowed to copy this.

#ce ----------------------------------------------------------------------------

#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <windowsconstants.au3>
#include <WinAPI.au3>
#include <Color.au3>
#include <StaticConstants.au3>
#include <Constants.au3>


$current_version = "1.0d"
$debug = 0

$port=3156
$ip=@IPAddress1
$data=""


UDPShutdown() ;shutdown previous UDP stuff
UDPStartup() ;start UDP stuff
$socket = UDPBind($ip, $port) ;bind a socket to the local ip and port 3156
If @error Then ;if something went wrong
   Sleep(2000) ;wait a second (or two :P)
   $socket = UDPBind($ip, $port) ;try again.
   If @error Then
	  MsgBox(0,"NCForward", "Ouchie! Something went very wrong here! There seems to be an error and NCForward is not able to start up. Please contact the author of this program and give him the following error code: '1-" & @error & "'. Thank you!") ;We need the 1- to find out where the error is located.
	  Exit
   EndIf
EndIf

If $debug=1 Then ;This is just for debug. Set debug=1 above to see the console
   GUICreate("NCforward debug mode @ " & $ip & " : " & $port, 500, 500)
   $inp=GUICtrlCreateEdit("", 0, 0, 500, 500, $ES_READONLY)
   GUISetState()
	  
   While 1
		 $data = UDPRecv($socket, 500, 3)
		 
		 If $data <> "" Then
			GUICtrlSetData($inp, "Recieved: " & BinaryToString($data[0],4) & @CRLF & GUICtrlRead($inp)) ; sh auch http://wiki.vg/Pocket_Minecraft_Protocol
		 EndIf
		 
	  Sleep(100)
	  
	  $msg = GUIGetMsg()
	  If $msg = $GUI_EVENT_CLOSE Then Exit
	  
   WEnd
Else ;Interesting part starts here.
   Opt("TrayOnEventMode", 1)
   Opt("TrayMenuMode", 3); 1 for check
   
   #cs ;TODO: make asynchronous!!!
   $rupdate = BinaryToString(InetRead("http://h6nry.github.io/Files/NCForwardUpdate",1+2))
   If $rupdate <> "" Then
	  If $rupdate <> $current_version Then
		 TrayTip("NCForward", "An update seems to be available! Current version: '" & $current_version & "'. New version: '" & $rupdate & "'.", 10, 1)
	  EndIf
   EndIf
   #ce
   
   $bull = GUICreate("NCForward", 350, 100, 0, 100, $WS_POPUP, $WS_EX_TOOLWINDOW) ;create a GUI.
   GUISetState(@SW_HIDE) ;hide the GUI initially
   GUISetBkColor(0x3223344)
   
   $title = GUICtrlCreateLabel("",10, 10, 320, 20) ;create the title
   GUICtrlSetFont($title,12,600, 0, "", 5)
   GUICtrlSetColor ($title, 0xffffff)
   $message = GUICtrlCreateLabel("",15,30,320,60) ;create the message field
   GUICtrlSetFont($message,9,300, 0, "", 5)
   GUICtrlSetColor ($message, 0xffffff)
   $close = GUICtrlCreateLabel("x", 330, 0, 20, 20)
   GUICtrlSetFont($close,15,600, 0, "", 5)
   GUICtrlSetColor ($close, 0xffffff)
   
   TrayCreateItem("Exit")
   TrayItemSetOnEvent(-1, "ExitNCF")
   TrayCreateItem("Info")
   TrayItemSetOnEvent(-1, "ShowInfo")
   
   Dim $list[50]
   For $c = 0 To 50-1
	  $list[$c] = 0
   Next
   $shown = 0
   $timer = TimerInit() ;init a timer to timeout the notification
   $timer2 = TimerInit()
   
   While 1
	  $data = UDPRecv($socket, 500, 3) ;get some udp packets
	  
	  If $data <> "" Then ;when there are actually packets
		 $not = BinaryToString($data[0],4)
		 $splitnot = StringSplit($not, "%!", 1) ;look if you can take apart the recieved stuff
		 
		 If $splitnot[1] == "NCFV1_PV1" Then ;The protocol is right when passing this!
			ListAdd($list, $not)
		 EndIf
	  EndIf
	  
	  If $shown == 0 And ($list[0] <> 0 Or $list[0] <> "") Then ;String($list[0]) <> "" Or String($list[0]) <> "0" Then
		 $splitnot = StringSplit($list[0], "%!", 1)
		 $timer = TimerInit() ;reinit the timer to reset.
			
		 GUICtrlSetData($title,"") ;clear previous stuff
		 If $splitnot[5] <> "NULL" Then
			GUICtrlSetData($title,$splitnot[5]) ;if the field number 5 (title) is not empty, fill it in the GUI
		 EndIf
		 
		 GUICtrlSetData($message, "")
		 If $splitnot[7] <> "NULL" Then
			GUICtrlSetData($message, $splitnot[7]) ;if the field number 7 (message) is not empty, fill it in the GUI
		 EndIf
		 
		 GUISetState(@SW_SHOWNORMAL) ;finally show the gui
		 $shown = 1
	  EndIf
	  
	  If $shown And TimerDiff($timer2) > 1000 Then
		 $wbul = ListCount($list)
		 
		 If TimerDiff($timer) > 5000/$wbul Then
			GUISetState(@SW_HIDE) ;if timer ran out, hide the gui again
			ListPop($list)
			$shown = 0
		 EndIf
		 
		 $timer2 = TimerInit()
	  EndIf
	  
	  $msg = GUIGetMsg()
	  Select
	  Case $msg = $GUI_EVENT_CLOSE
		 Exit
	  Case $msg = $close
		 GUISetState(@SW_HIDE) ;does not work for some reason
		 ListPop($list)
		 $shown = 0
	  EndSelect
   WEnd
EndIf


Func _ColorBGRToRGB($BGR) ;function to make a rgb color out of bgr, not used yet!
	Local $RGB = BitShift($BGR, -16)
	$RGB += BitAND($BGR, 0xff00)
	$RGB += BitShift($BGR, 16)
	Return BitAND($RGB, 0xffffff)
 EndFunc
 
 Func ListAdd(ByRef $list, $val)
   For $c = 0 To UBound($list)-1
	  If $list[$c] == 0 Then
		 $list[$c] = $val
		 Return
	  EndIf
   Next
EndFunc

Func ListPop(ByRef $list)
   Local $val = $list[0]
   
   For $c = 0 To UBound($list)-1-1
	  $list[$c] = $list[$c+1]
   Next
   
   Return $val
EndFunc

Func ListCount($list)
   Local $d = 0
   For $c = 0 To UBound($list)-1
	  If $list[$c] <> 0 Or $list[$c] <> "" Then
		 $d = $d+1
	  EndIf
   Next
   Return $d
EndFunc

Func ExitNCF()
   UDPShutdown()
   Exit
EndFunc

Func ShowInfo()
   MsgBox(0,"NCForward","NCForward by H6nry <henry.anonym@gmail.com>" & @CRLF & "Made with love in 2015. This is the counterpart of the Cydia tweak NCForward. More info, see on my website: 'http://h6nry.github.io/'")
EndFunc