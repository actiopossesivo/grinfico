#include-once

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPIFiles.au3>
#include <Array.au3>
#include <String.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>

#include <lib/wmp.au3>
#include <lib/Zip.au3>
#Include <lib/Icons.au3>

Opt('WINTITLEMATCHMODE', 4)
local $tbpos =_DeskTopVisibleArea()

Global $igf_ini = "scenario.ini"

Global $pa_width = 800
Global $pa_height = 480
Global $pa_vidheight = 400
Global $pa_title = "Untitled"
Global $pa_bgcolor = "333333"
Global $pa_color = "ffffff"
Global $pa_bgimage
Global $fontname = ""
Global $fontsize = 11
Global $keyword = ""

Global $win_bgrcolor = "111111"
Global $dialog_bgr = @ScriptDir&"/prop/dark-tr.png"
Global $igf_folder = @MyDocumentsDir&"\igfiction\pack"
Global $igf_saved = @MyDocumentsDir&"\igfiction\saved"

Global $win_width = $tbpos[0]
Global $win_height = $tbpos[1]

Global $igf_win
Global $igf_pa
Global $menu
Global $scene
Global $step = 0
Global $score = 0
Global $been[0]

Global $ca[0]
Global $ct[0]
Global $trna[0]

Func ReadSection($section,$saved_data)

	local $opt = IniReadSection($igf_ini,$section)
	local $Sections = IniReadSectionNames($igf_ini)
	local $current = _ArraySearch($Sections,$section)
	local $gtext[0]
	local $gpng[0][5]
	local $gbutton[0][2]
	local $gvbutton[0][2]
	local $gspot[0][5]
	local $next_page ="", $goto = ""
	local $n
	local $video

	ReDim $data_tosav[0][2]

	_ArrayAdd($been,$section)

	GUICtrlSetState($menu[8][0],$GUI_ENABLE)

	for $i = 0 to Ubound($opt)-1
		Switch StringLower($opt[$i][0])
			Case "scene"
				if $scene == 0 Then
					$scene = GUICtrlCreatePic($opt[$i][1],0,0,$pa_width,$pa_height)
					GUICtrlSetState($scene,$GUI_DISABLE)
				Else
					GUICtrlSetImage($scene,$opt[$i][1])
				Endif
			Case "score"
				; beenhere?
				local $aBeen = _ArrayUnique($been);
				local $pass= 0
				for $i = 0 to Ubound( $aBeen )-1
				   if $aBeen[$i] == $section Then $pass=1
				Next
				if $pass=0 Then $score = $score + $opt[$i][1]
			Case "next"
				$n = $current + 1
				$next_page = $Sections[$n]
			Case "back"
				$n = $current - 1
				$next_page = $Sections[$n]
			Case "spot"
				_ArrayAdd($gspot,$opt[$i][1],0,"|")
			Case "button"
				_ArrayAdd($gbutton,$opt[$i][1],0,"|")
			Case "vbutton"
				_ArrayAdd($gvbutton,$opt[$i][1],0,"|")
			Case "text"
				_ArrayAdd($gtext,$opt[$i][1])
			Case "png"
				_ArrayAdd($gpng,$opt[$i][1],0,"|")
			Case "vid"
				$video = $opt[$i][1]
			Case "goto"
				$goto = $opt[$i][1]

		EndSwitch
	Next

	if $current>=2 Then
		GUICtrlSetState($menu[6][0],$GUI_ENABLE)
		GUICtrlSetState($menu[7][0],$GUI_ENABLE)

		_ArrayAdd($data_tosav,"keyword"&"|"&$keyword)
		_ArrayAdd($data_tosav,"section"&"|"&$section)
		_ArrayAdd($data_tosav,"step"&"|"&$step)
		_ArrayAdd($data_tosav,"score"&"|"&$score)

	Endif

	if Ubound($png_obj)>-1 Then ClearingGUICtrl($png_obj)

	if $video<>"" Then
		$ovid = vidplay($video,0,0,$pa_width,$pa_vidheight)
		GUICtrlSetState($ovid,$GUI_DISABLE)
		_ArrayAdd($png_obj,$ovid)
	Endif

	if Ubound($gpng)>-1 Then
		for $i = 0 to Ubound($gpng)-1
			local $pngo = PutPNG($gpng[$i][0],$gpng[$i][1],$gpng[$i][2],$gpng[$i][3],$gpng[$i][4])
			GUICtrlSetState($pngo,$GUI_DISABLE)
			_ArrayAdd($png_obj,$pngo)
		Next
	Endif

	if Ubound($gtext)>-1 Then Texting($gtext,$goto)

	if $next_page<>"" Then ReadSection($next_page,$saved_data)

	if Ubound($gbutton)>-1 OR Ubound($gspot)>-1 OR Ubound($gvbutton)>-1 Then
		$step = $step +1
		Prompting($gbutton,$gspot,$gvbutton)
	EndIf

	if $goto <> "" Then ReadSection($goto,$saved_data)

EndFunc

Func PutPNG($file,$pl=0,$pt=0,$pw=0,$ph=0)
	local $Picpng = GUICtrlCreatePic('',$pl,$pt,$pw,$ph,$SS_NOTIFY,$WS_EX_TOPMOST)
	GUICtrlSetCursor($Picpng,0)
	_SetImage($Picpng,$file)
	return $Picpng
EndFunc

Func ClearingGUICtrl($a)
	for $i = 0 to Ubound($a)-1
		GUICtrlDelete($a[$i])
	Next
EndFunc

Func Prompting($button, $spot, $vbutton)
	local $top = 0
	local $left = 0
	ReDim $ca[0]
	ReDim $trna[0]
	local $B = Ubound($button)
	local $S = Ubound($spot)
	local $V = Ubound($vbutton)
	local $goto[0]

	for $i = 0 to $B-1
		local $res = Prompt($button[$i][1],$top,$B)
		$top = $res[0]
		_ArrayAdd($ca,$res[1])
		_ArrayAdd($goto,$button[$i][0])
		_ArrayAdd($trna,$res[2])
	Next

	for $i = 0 to $V-1
		local $res = vPrompt($vbutton[$i][1],$left,$V)
		$left= $res[0]
		_ArrayAdd($ca,$res[1])
		_ArrayAdd($goto,$vbutton[$i][0])
		_ArrayAdd($trna,$res[2])
	Next

	for $i = 0 to $S-1
		local $sres = GUICtrlCreateLabel("",$spot[$i][1],$spot[$i][2],$spot[$i][3],$spot[$i][4])
		GUICtrlSetCursor($sres,0)
		GUICtrlSetBkColor($sres,$GUI_BKCOLOR_TRANSPARENT)
		GUICtrlSetState($sres,$GUI_ONTOP)
		_ArrayAdd($ca,$sres)
		_ArrayAdd($goto,$spot[$i][0])
	Next


	While 1
		local $click = GUIGetMsg(1)
		if $click[1] == $igf_pa Then
			for $i = 0 to Ubound($ca)-1
				if $click[0]==$ca[$i] Then
					ClearingGUICtrl($ca)
					ClearingGUICtrl($trna)
					ReadSection($goto[$i],$saved_data)
				Endif
			next
		Elseif $click[1] == $igf_win Then
			if $click[0] == $GUI_EVENT_CLOSE Then Call("IGF_Exit")
			Menu_GM($click[0])
		Endif
	WEnd

EndFunc

Func vPrompt($txt,$left,$V)

	Local $width = 120
	Local $height = 1.6*$fontsize
	local $top = $pa_height - ($height*2)

	local $trnz = PutPNG($dialog_bgr,-$pa_width,0,0,0)
	if $left==0 then $left = $pa_width/2 - ((($width+32)*$V)/2)
	if $left < 0 then $left = $pa_width*.05

	local $tz = [ $left, $top, $width, $height ]
	Local $act = GUICtrlcreateLabel($txt, $tz[0],$tz[1],$tz[2],$tz[3], $SS_CENTER)
	GUICtrlSetColor($act,'0x'&$pa_color)
	GUICtrlSetFont($act,$fontsize,700)

	GUICtrlSetBkColor($act,$GUI_BKCOLOR_TRANSPARENT)
	GuiCtrlSetState($act, $GUI_ONTOP)
	GUICtrlSetCursor($act,0)
	GUICtrlSetState($trnz,$GUI_DISABLE)

	GUICtrlSetPos($trnz,$tz[0]-8,$tz[1]-8,$tz[2]+16,$tz[3]+16)

	local $res[]=[ $left+($width)+32, $act, $trnz ]
	return $res

EndFunc

Func Prompt($txt,$top,$A)

	local $aW = 300
	Local $height = 1.6*$fontsize

	local $trnz = PutPNG($dialog_bgr,-$pa_width,0,0,0)

	if $top==0 then $top = $pa_height - ($A * $height*2)

	local $tz = [ $pa_width/2-$aW/2, $top, $aW, $height ]
	Local $act = GUICtrlcreateLabel($txt, $tz[0],$tz[1],$tz[2],$tz[3], $SS_CENTER)
	GUICtrlSetColor($act,'0x'&$pa_color)
	GUICtrlSetFont($act,$fontsize,700)

	GUICtrlSetBkColor($act,$GUI_BKCOLOR_TRANSPARENT)
	GuiCtrlSetState($act, $GUI_ONTOP)
	GUICtrlSetCursor($act,0)
	GUICtrlSetState($trnz,$GUI_DISABLE)

	GUICtrlSetPos($trnz,$tz[0]-16,$tz[1]-6,$tz[2]+32,$tz[3]+12)

	local $res[]=[ $top+($height*2), $act, $trnz ]
	return $res

EndFunc

Func Texting($TXT,$goto)

	local $goto_confirm = ''

	for $i = 0 to UBound($TXT)-1
		if $i == UBound($TXT)-1 Then $goto_confirm = $goto
		Text(0,$TXT[$i],$goto_confirm)
	Next

EndFunc

Func Text($top,$txt,$goto="")

	ReDim $ct[0] ; Well?

	local $trnz = PutPNG($dialog_bgr,-$pa_width,0,0,0)
	GUICtrlSetState($trnz,$GUI_DISABLE)

	local $height = Round( Ceiling(StringLen($txt)/114) * (1.6*$fontsize) )
	local $tpos[] = [ 32,$pa_height-($height+$top)-38,$pa_width-66,$height ]
	local $t = GUICtrlCreateLabel($txt,$tpos[0],$tpos[1],$tpos[2],$tpos[3])
	GUICtrlSetColor($t,'0x'&$pa_color)
	GUICtrlSetCursor($t,0)
	GUICtrlSetBkColor($t,$GUI_BKCOLOR_TRANSPARENT)
	GuiCtrlSetState($t, $GUI_ONTOP)

	GUICtrlSetPos($trnz,$tpos[0]-16,$tpos[1]-16,$tpos[2]+32,$tpos[3]+32)

	While 1
		local $click = GUIGetMsg(1)
		if $click[1] == $igf_pa Then
			local $res = Text_GM($click[0],$t,$trnz,$goto)
			if $res==1 Then ExitLoop
		Elseif $click[1] == $igf_win Then
			if $click[0] == $GUI_EVENT_CLOSE Then Call("IGF_Exit")
			Menu_GM($click[0])
		Endif
	WEnd

	return $tpos

EndFunc

Func Text_GM($click,$t,$trnz,$goto="")
	if $click == $t Then
	GUICtrlDelete($t)
	GUICtrlDelete($trnz)
	if $goto<>'' Then ReadSection($goto,$saved_data)
	return 1
	Endif
EndFunc

Func Menu_GM($click)
	For $i = 0 to Ubound($menu)-1
	if $click == $menu[$i][0] Then Call($menu[$i][1],$menu[$i][2])
	Next
EndFunc

Func _DeskTopVisibleArea()
	Local $aInfo[2]
	Local $aCPos = ControlGetPos('[CLASS:Shell_TrayWnd]', '', '')
	If IsArray($aCPos) <= 0 Then
		$aInfo[0] = @DesktopWidth
		$aInfo[1] = @DesktopHeight
	ElseIf $aCPos[2] >= @DesktopWidth Then
		$aInfo[0] = @DesktopWidth
		$aInfo[1] = @DesktopHeight - ($aCPos[3] - $aCPos[1])
	Else
		$aInfo[0] = @DesktopWidth - ($aCPos[2] - $aCPos[0])
		$aInfo[1] = @DesktopHeight
	EndIf
	Return $aInfo
 EndFunc

Func Welcome($wait=3)
	local $width = $pa_width/2
	local $height = $pa_height/2
	local $trnz
	local $wimg
	if $pa_bgimage<> "" Then
		$wimg = GUICtrlCreatePic($pa_bgimage,0,0,$pa_width,$pa_height)
		$trnz = PutPNG(@ScriptDir&"/prop/gray-tr.png",0,0,$pa_width,$pa_height)
	Endif
	GUICtrlSetData($menu[5][0],'Story: "'&$pa_title&'"')
	local $title = GUICtrlCreateLabel($pa_title,$pa_width/2-$width/2,$pa_height/2-($pa_height*.1),$width,$height,$SS_CENTER)
	GUICtrlSetColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1,$fontsize*3,700)
	GUICtrlSetBkColor(-1,$GUI_BKCOLOR_TRANSPARENT)
	Sleep($wait*1000)
	GUICtrlDelete($trnz)
	GUICtrlDelete($wimg)
	GUICtrlDelete($title)
 EndFunc

Func RunOnce()

	if FileExists(@Scriptdir&"/prop")==0 Then DirCreate(@Scriptdir&"/prop")
	if FileExists(@Scriptdir&"/play")==0 Then DirCreate(@Scriptdir&"/play")
	if FileExists(@MyDocumentsDir&"/igfiction")==0 Then DirCreate(@MyDocumentsDir&"/igfiction")
	if FileExists(@MyDocumentsDir&"/igfiction/pack")==0 Then DirCreate(@MyDocumentsDir&"/igfiction/pack")
	if FileExists(@MyDocumentsDir&"/igfiction/saved")==0 Then DirCreate(@MyDocumentsDir&"/igfiction/saved")

	FileInstall("igf-conf.ini",@ScriptDir&"/prop/igf-conf.ini",0)
	FileInstall("dark-tr.png",@ScriptDir&"/prop/dark-tr.png",0)
	FileInstall("gray-tr.png",@ScriptDir&"/prop/gray-tr.png",0)
	FileInstall("white-tr.png",@ScriptDir&"/prop/white-tr.png",0)
	FileInstall("igf-spash.jpg",@ScriptDir&"/prop/igf-splash.jpg",0)
	FileInstall("igf-bgr.jpg",@ScriptDir&"/prop/igf-bgr.jpg",0)

	IGF_Init(@ScriptDir&"/prop/igf-conf.ini")

EndFunc

Func ReadConf()
	local $conf = IniReadSection($igf_ini,"config")
	For $i = 1 To Ubound($conf)-1
		if $conf[$i][0] == 'width' Then $pa_width=$conf[$i][1]
		if $conf[$i][0] == 'height' Then $pa_height=$conf[$i][1]
		if $conf[$i][0] == 'vidheight' Then $pa_vidheight=$conf[$i][1]
		if $conf[$i][0] == 'title' Then $pa_title=$conf[$i][1]
		if $conf[$i][0] == 'bgcolor' Then $pa_bgcolor = $conf[$i][1]
		if $conf[$i][0] == 'color' Then $pa_color = $conf[$i][1]
		if $conf[$i][0] == 'bgimage' Then $pa_bgimage = $conf[$i][1]
		if $conf[$i][0] == 'fontname' Then $fontname=$conf[$i][1]
		if $conf[$i][0] == 'fontsize' Then $fontsize=$conf[$i][1]
		if $conf[$i][0] == 'keyword' Then $keyword=$conf[$i][1]
		if $keyword=="" Then $keyword = StringRegExpReplace ( StringLower($pa_title), "[\s|\W]", "")
	Next
EndFunc

Func Package_Browse($folder)
	Local Const $sMessage = "Open IGF zip Package"
	Local $sFileOpenDialog = FileOpenDialog($sMessage, $folder, "All (*.zip)", $FD_FILEMUSTEXIST)
	If @error Then
		$sFileOpenDialog=''
	Else
		FileChangeDir(@ScriptDir)
		$sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)
	EndIf

	_ArrayAdd( $menu, GUICtrlCreateMenuItem($sFileOpenDialog,$menu[3][0]) &"|"& "IGF_Loadfile"&"|"&$sFileOpenDialog,0,"|")

	return $sFileOpenDialog
EndFunc

Func IGF_Init($ini)
	local $conf = IniReadSection($ini,"config")
	For $i = 1 To Ubound($conf)-1
		if $conf[$i][0] == 'bgcolor' Then $win_bgrcolor=$conf[$i][1]
		if $conf[$i][0] == 'dialogbgr' Then $dialog_bgr=$conf[$i][1]
		if $conf[$i][0] == 'igf_folder' Then $igf_folder=$conf[$i][1]
	Next
EndFunc

Func IGF_Win()
	$igf_win = GUICreate("IgFE", $win_width,$win_height,0,0,$WS_SYSMENU+$WS_MAXIMIZE+$WS_MINIMIZEBOX)
	GUISetBkColor("0x"&$win_bgrcolor,$igf_win)
	GUISetState(@SW_SHOW,$igf_win)

	local $mf = GUICtrlCreateMenu("&File")
	local $ms = GUICtrlCreateMenu('&Story')

	local $menu[][]= [ _
	[ $mf, "" ], _
	[ GUICtrlCreateMenuItem("&Open",$mf), "IGF_PakOpen","" ], _
	[ GUICtrlCreateMenuItem("&Close",$mf), "IGF_PakClose","" ], _
	[ GUICtrlCreateMenu("&Recent",$mf), "IGF_PakRecent","" ], _
	[ GUICtrlCreateMenuItem("&Exit",$mf), "IGF_Exit","" ], _
	[ $ms, "" ], _
	[ GUICtrlCreateMenuItem("&Load",$ms), "IGF_SavLoad","" ], _
	[ GUICtrlCreateMenuItem("&Save",$ms), "IGF_SavSave","" ], _
	[ GUICtrlCreateMenuItem("&ReadMe",$ms), "IGF_ReadMe","" ], _
	[ GUICtrlCreateMenuItem("&About",-1), "IGF_About","" ] _
	]

	GUICtrlCreateMenuItem("",$mf,3)
	GUICtrlCreateMenuItem("",$ms,2)

	GUICtrlSetState($menu[6][0],$GUI_DISABLE)
	GUICtrlSetState($menu[7][0],$GUI_DISABLE)
	GUICtrlSetState($menu[8][0],$GUI_DISABLE)
	GUICtrlSetState($menu[2][0],$GUI_DISABLE)

	return $menu

EndFunc

Func IGF_PakOpen()
	$file = Package_Browse($igf_folder)
	if $file<>"" Then IGF_Loadfile($file)
 EndFunc

Func IGF_PakClose()
	GUICtrlSetData($menu[5][0],'Story:')
	GUIDelete($igf_pa)
	$playarea = IGF_PlayArea()
EndFunc

Func IGF_Loadfile($file)
	FileDelete(@Scriptdir&"/play/*.*")
	FileChangeDir(@Scriptdir&"/play")
	_Zip_UnzipAll($file, @WorkingDir, 1)
	$igf_ini = "scenario.ini"
	IGF_Start('begin',$saved_data)
EndFunc

Func IGF_Start($section,$saved_data)
	FileChangeDir(@Scriptdir&"/play")
	ReadConf()
	if $section=='begin' Then Welcome(2)
	GUICtrlSetState($menu[2][0],$GUI_ENABLE)
	ReadSection($section,$saved_data)
EndFunc

Func IGF_Exit($w = "")
	if ($w=="") AND (Ubound($data_tosav)>0) Then
		Switch MsgBox($MB_YESNO + $MB_TASKMODAL, 'Quit from Interactive Grapical Fictions', 'Are you sure?')
			Case $IDYES
			GUIDelete($igf_win)
			Exit
			Case $IDNO
				return ''
			EndSwitch
	Else
		GUIDelete($igf_win)
		Exit
	Endif

EndFunc

Func IGF_PlayArea()
	local $cz = WinGetClientSize("IgFE")
	$igf_pa = GUICreate("", $pa_width, $pa_height, ($cz[0]/2-($pa_width/2)) , ($cz[1]/4-($pa_height/4)), $WS_POPUP, $WS_EX_MDICHILD, $igf_win)
	GUISetFont($fontsize,0,0,$fontname,$igf_pa,5)
	GUISetBkColor("0x"&$pa_bgcolor,$igf_pa)
	$scene = GUICtrlCreatePic($pa_bgimage,0,0,$pa_width,$pa_height)
	GUICtrlSetState($scene,$GUI_DISABLE)
	GUISetState(@SW_SHOW,$igf_pa)
	return $igf_pa
EndFunc

Func IGF_SavSave()
	$save_file = FilesaveDialog($pa_title & " Saved Files",$igf_saved,"All (*."&$keyword&".ini)", $FD_PATHMUSTEXIST+$FD_PROMPTOVERWRITE)
	If @error Then
		ConsoleWrite("IGF_SavSave Error:"&$Save_file&" - "&@error)
	Else
		; been
		local $aBeen = _ArrayUnique($been);
		local $sBeen = ""
		for $i = 1 to Ubound( $aBeen )-1
			$sBeen = $aBeen[$i] & "," & $sBeen
		Next
		$sBeen = StringTrimRight($sBeen,1)
		;_ArrayDisplay($aBeen)
		;msgbox(0,'',$sBeen)
		_ArrayAdd($data_tosav,"been"&"|"&$sBeen)

		IniWriteSection ( $save_file, "data", $data_tosav,0 )

		Global $been[0]

	Endif
	FileChangeDir(@Scriptdir&"/play")
	return ""
EndFunc

Func IGF_SavLoad()
	local $section
	$save_file = FileOpenDialog($pa_title & " Saved Files",$igf_saved,"All (*."&$keyword&".ini)", $FD_FILEMUSTEXIST)
	If @error Then
		return ""
	Else
		$saved_data = IGF_SavRead($save_file)
		if $keyword == $saved_data[1][1] Then
			$section = $saved_data[2][1]
			$step = $saved_data[3][1]
			$abeen = $saved_data[5][1]
			$score = $saved_data[4][1]
		Endif

		global $been[] = _StringExplode ( $aBeen, "," )

		; Jus like restart playarea

		GUIDelete($igf_pa)
		IGF_PlayArea()
		IGF_Start($section,$saved_data)

	Endif
EndFunc

Func IGF_SavRead($sfn)
	return IniReadSection($sfn,"data")
EndFunc

