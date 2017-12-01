#include <igf2-function.au3>
#include <igf2-menus.au3>

Opt("GUIOnEventMode", 0)
Opt("GUICoordMode", 1)
Opt('WINTITLEMATCHMODE', 4)

RunOnce()
IGF_Conf()

Global $igf_mn = IGF_Win()
Global $G_obj[0]
Global $G_saved[0][2]
Global $G_bucket[0][2]
Global $igf_sb
Global $igf_pa

local $top = 0

;C:\IGF\SRC\Scenario.ini

;GUIRegisterMsg(15, "_Refresh"); WM_PAINT

if IniRead(@ScriptDir&"\prop\igf-conf.ini","igf","splash",1) == 1 Then
	SplashImageOn("",@Scriptdir&"\prop\igf-splash.jpg",500,300,-1,-1, $DLG_NOTITLE )
	Sleep(2000)
	SplashOff()
EndIf

if $CmdLine[0]>0 Then
	IGF_DirectStart($CmdLine[1])
Endif

While 1
	local $click = GUIGetMsg()
	if $click == $GUI_EVENT_CLOSE Then
		IGF_Exit('go')
	Else
		Menu_GM($click)
	Endif
WEnd

Exit