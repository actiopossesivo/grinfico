#include <igf2-function.au3>
#include <igf2-menus.au3>

Opt("GUIOnEventMode", 0)
Opt("GUICoordMode", 1)
Opt('WINTITLEMATCHMODE', 4)

RunOnce()

Global $menu = IGF_Win()
Global $igf_sb = IGF_ScoreBar()
Global $igf_pa = IGF_PlayArea()
local $top = 0
Global $png_obj[0]
Global $saved_data[0][2]
Global $data_tosav[0][2]

;C:\IGF\SRC\Scenario.ini

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