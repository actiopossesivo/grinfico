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

Global $G_fontname = "Tahoma"
Global $G_fontsize = 11
Global $G_keyword = ""

Global $win_bgrcolor = "030003"
Global $igf_folder = @MyDocumentsDir&"\igfiction\pack"
Global $igf_saved = @MyDocumentsDir&"\igfiction\saved"

Global $dialog_bgr = @ScriptDir&"\prop\dark-tr.png"
Global $win_width = $tbpos[0]
Global $win_height = $tbpos[1]

Global $igf_win

Global $iScene
Global $step = 0
Global $iScores
Global $score = 0
Global $been[0]

;Global $ca[0]
;Global $ct[0]
;Global $holders[0]

Func ReadSection($section,$G_saved)

	local $opt = IniReadSection($igf_ini,$section)
	local $Sections = IniReadSectionNames($igf_ini)
	local $current = _ArraySearch($Sections,$section)
	local $gtext[0]
	local $gpng[0][5]
	local $gvid[0|5]
	local $gspot[0][5]
	local $gbutton[0][2]
	local $gvbutton[0][2]
	local $next_page ="", $goto = ""
	local $n

	ReDim $G_bucket[0][2]

	GUICtrlSetState($igf_mn[7][0],$GUI_DISABLE)

	for $i = 0 to Ubound($opt)-1
		Switch StringLower($opt[$i][0])

			Case "scene"
				if $iScene == 0 Then
					$iScene = GUICtrlCreatePic($opt[$i][1],0,0,$pa_width,$pa_height)
					GUICtrlSetState($iScene,$GUI_DISABLE)
				Else
					GUICtrlSetImage($iScene,$opt[$i][1])
				Endif
				GUICtrlSetState($igf_mn[7][0],$GUI_ENABLE)

			Case "score"
				local $aBeen = _ArrayUnique($been);
				local $pass= 0
				for $o = 0 to Ubound( $aBeen )-1
					if $aBeen[$o] == $section Then $pass=1
				Next
				if $pass=0 Then
					_ArrayAdd($been,$section)
					$score = $score + $opt[$i][1]
					GUICtrlSetData($iScores,"Score: "&$score)
					GUICtrlSetState($iScores,$GUI_ONTOP)
				Endif

			Case "next"
				$n = $current + 1
				if $n>Ubound($Sections)-1 Then $n = 2
				$next_page = $Sections[$n]
				if $n == 2 Then msgbox(0,'',"The Story seem to be unfinished?")

			Case "back"
				$n = $current - 1
				if $n<2 Then $n = 2
				$next_page = $Sections[$n]
				if $n == 2 Then msgbox(0,'',"The Story seem to be unfinished?")

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
				_ArrayAdd($gvid,$opt[$i][1],0,"|")
				;$video = $opt[$i][1]
			Case "goto"
				$goto = $opt[$i][1]

		EndSwitch
	Next

	if $current>=2 Then
		; ini
		GUICtrlSetState($igf_mn[8][0],$GUI_ENABLE)
		_ArrayAdd($G_bucket,"keyword"&"|"&$G_keyword)
		_ArrayAdd($G_bucket,"section"&"|"&$section)
		_ArrayAdd($G_bucket,"step"&"|"&$step)
		_ArrayAdd($G_bucket,"score"&"|"&$score)

	Endif

	if Ubound($G_obj)>-1 Then ClearingGUICtrl($G_obj)

	if Ubound($gvid)>-1 Then
		$ovid = vidplay($gvid[0][0],$gvid[0][1],$gvid[0][2],$gvid[0][3],$gvid[0][4])
		GUICtrlSetState($ovid,$GUI_DISABLE)
		_ArrayAdd($G_obj,$ovid)
	Endif

	if Ubound($gpng)>-1 Then
		for $i = 0 to Ubound($gpng)-1
			local $pngo = PutPNG($gpng[$i][0],$gpng[$i][1],$gpng[$i][2],$gpng[$i][3],$gpng[$i][4])
			GUICtrlSetState($pngo,$GUI_DISABLE)
			_ArrayAdd($G_obj,$pngo)
		Next
	Endif

	if Ubound($gtext)>-1 Then Texting($gtext,$goto)

	;if IsString($next_page) Then ReadSection($next_page,$G_saved)
	if $next_page<>"" Then ReadSection($next_page,$G_saved)

	if Ubound($gbutton)>-1 OR Ubound($gspot)>-1 OR Ubound($gvbutton)>-1 Then
		$step = $step +1
		Prompting($gbutton,$gspot,$gvbutton)
	EndIf

	if $goto <> "" Then ReadSection($goto,$G_saved)

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
	local $ca[0]
	local $holders[0]
	local $B = Ubound($button)
	local $S = Ubound($spot)
	local $V = Ubound($vbutton)
	local $goto[0]

	for $i = 0 to $B-1
		local $res = Prompt($button[$i][1],$top,$B)
		$top = $res[0]
		_ArrayAdd($ca,$res[1])
		_ArrayAdd($goto,$button[$i][0])
		_ArrayAdd($holders,$res[2])
	Next

	for $i = 0 to $V-1
		local $res = vPrompt($vbutton[$i][1],$left,$V)
		$left= $res[0]
		_ArrayAdd($ca,$res[1])
		_ArrayAdd($goto,$vbutton[$i][0])
		_ArrayAdd($holders,$res[2])
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
					ClearingGUICtrl($holders)
					ReadSection($goto[$i],$G_saved)
				Endif
			next
		Elseif $click[1] == $igf_win Then
			if $click[0] == $GUI_EVENT_CLOSE Then Call("IGF_Exit")
			Menu_GM($click[0])
		Endif
	WEnd

EndFunc

Func vPrompt($txt,$left,$V)

	local $tpos = Get_Dimensions(false,"inside")
	local $fz	= Get_Dimensions(false,"size")
	Local $width = 150
	Local $height = $fz[1]
	local $top = $tpos[1] - $height
	if $left==0 then $left = $tpos[2]/2 - (($width*$V)/2)
	if $left < 0 then $left = $tpos[0]

	local $bubble = PutPNG($dialog_bgr,-$pa_width,0,0,0)

	local $tz = [ $left, $top, $width, $height ]
	Local $btn = GUICtrlcreateLabel($txt, $tz[0],$tz[1],$tz[2],$tz[3], $SS_CENTER)
	GUICtrlSetColor($btn,'0x'&$pa_color)
	GUICtrlSetFont($btn,$G_fontsize,700)
	GUICtrlSetBkColor($btn,$GUI_BKCOLOR_TRANSPARENT)
	GuiCtrlSetState($btn, $GUI_ONTOP)
	GUICtrlSetCursor($btn,0)

	GUICtrlSetPos($bubble,$tz[0]-$fz[3],$tz[1]-$fz[3],$tz[2]+$fz[2],$tz[3]+$fz[2])
	GUICtrlSetState($bubble,$GUI_DISABLE)

	local $res[]=[ $left+($width)+$fz[1], $btn, $bubble ]
	return $res

EndFunc

Func Prompt($txt,$top,$A)

	local $tpos = Get_Dimensions(false,"inside")
	local $fz	= Get_Dimensions(false,"size")

	local $width = Ceiling($tpos[2]/3)
	Local $height = $tpos[3]
	local $left = ($tpos[2]/2)-($width/2)
	local $bubble = PutPNG($dialog_bgr,-$pa_width,0,0,0)

	if $top==0 then $top = ($tpos[1]*.75) - ($A*($height*1.5))

	local $tz = [ $left, $top, $width, $height ]
	Local $act = GUICtrlcreateLabel($txt, $tz[0],$tz[1],$tz[2],$tz[3], $SS_CENTER)
	GUICtrlSetColor($act,'0x'&$pa_color)
	GUICtrlSetFont($act,$G_fontsize,700)

	GUICtrlSetBkColor($act,$GUI_BKCOLOR_TRANSPARENT)
	GuiCtrlSetState($act, $GUI_ONTOP)
	GUICtrlSetCursor($act,0)
	GUICtrlSetState($bubble,$GUI_DISABLE)

	GUICtrlSetPos($bubble,$tz[0]-$fz[3],$tz[1]-$fz[3],$tz[2]+$fz[3],$tz[3]+$fz[3])

	local $res[]=[ $top+($height*1.5), $act, $bubble ]
	return $res

EndFunc

Func Menu_GM($click)
	For $i = 0 to Ubound($igf_mn)-1
	if $click == $igf_mn[$i][0] Then Call($igf_mn[$i][1],$igf_mn[$i][2])
	Next
EndFunc

Func Welcome($wait=3)
	local $width = $pa_width/2
	local $height = $pa_height/2
	local $bubble
	local $wimg
	if $pa_bgimage<> "" Then
		$wimg = GUICtrlCreatePic($pa_bgimage,0,0,$pa_width,$pa_height)
		$bubble = PutPNG(@ScriptDir&"/prop/gray-tr.png",0,0,$pa_width,$pa_height)
	Endif
	GUICtrlSetData($igf_mn[5][0],'Story: "'&$pa_title&'"')
	local $title = GUICtrlCreateLabel($pa_title,$pa_width/2-$width/2,$pa_height/2-($pa_height*.1),$width,$height,$SS_CENTER)
	GUICtrlSetColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1,$G_fontsize*3,700)
	GUICtrlSetBkColor(-1,$GUI_BKCOLOR_TRANSPARENT)
	Sleep($wait*1000)
	GUICtrlDelete($bubble)
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
		if $conf[$i][0] == 'fontname' Then $G_fontname=$conf[$i][1]
		if $conf[$i][0] == 'fontsize' Then $G_fontsize=$conf[$i][1]
		if $conf[$i][0] == 'keyword' Then $G_keyword=$conf[$i][1]
		if $G_keyword=="" Then $G_keyword = StringRegExpReplace ( StringLower($pa_title), "[\s|\W]", "")
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

	_ArrayAdd( $igf_mn, GUICtrlCreateMenuItem($sFileOpenDialog,$igf_mn[3][0]) &"|"& "IGF_Loadfile"&"|"&$sFileOpenDialog,0,"|")

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

	local $igf_mn[][]= [ _
	[ $mf, "" ], _
	[ GUICtrlCreateMenuItem("&Open",$mf), "IGF_PakOpen","" ], _
	[ GUICtrlCreateMenuItem("&Close",$mf), "IGF_PakClose","" ], _
	[ GUICtrlCreateMenu("&Recent",$mf), "IGF_PakRecent","" ], _
	[ GUICtrlCreateMenuItem("&Exit",$mf), "IGF_Exit","" ], _
	[ $ms, "" ], _
	[ GUICtrlCreateMenuItem("&Load",$ms), "IGF_SavLoad","" ], _
	[ GUICtrlCreateMenuItem("&Save",$ms), "IGF_SavSave","" ], _
	[ GUICtrlCreateMenuItem("&Restart",$ms), "IGF_SavRestart","" ], _
	[ GUICtrlCreateMenuItem("&ReadMe",$ms), "IGF_ReadMe","" ], _
	[ GUICtrlCreateMenuItem("&About",-1), "IGF_About","" ] _
	]

	GUICtrlCreateMenuItem("",$mf,3)
	GUICtrlCreateMenuItem("",$ms,2)

	GUICtrlSetState($igf_mn[2][0],$GUI_DISABLE)
	GUICtrlSetState($igf_mn[6][0],$GUI_DISABLE)
	GUICtrlSetState($igf_mn[7][0],$GUI_DISABLE)
	GUICtrlSetState($igf_mn[8][0],$GUI_DISABLE)

#cs
Row|Col 0|Col 1|Col 2
[0]|3||
[1]|5|IGF_PakOpen|
[2]|6|IGF_PakClose|
[3]|7|IGF_PakRecent|
[4]|8|IGF_Exit|
[5]|4||
[6]|9|IGF_SavLoad|
[7]|10|IGF_SavSave|
[8]|11|IGF_SavRestart|
[9]|12|IGF_ReadMe|
[10]|13|IGF_About|
#ce

	return $igf_mn

EndFunc

Func IGF_PakOpen()
	$file = Package_Browse($igf_folder)
	if $file<>"" Then IGF_Loadfile($file)
 EndFunc

Func IGF_PakClose()
	GUICtrlSetData($igf_mn[5][0],'Story:')
	GUIDelete($igf_pa)
	IGF_PlayArea()
EndFunc

Func IGF_DirectStart($file)
	$igf_ini = $file
	FileChangeDir(GetDir($file));
	IGF_Start('begin',$G_saved)
EndFunc

Func IGF_Loadfile($file)
	FileDelete(@Scriptdir&"/play/*.*")
	FileChangeDir(@Scriptdir&"/play")
	_Zip_UnzipAll($file, @WorkingDir, 1)
	$igf_ini = "scenario.ini"
	IGF_Start('begin',$G_saved)
EndFunc

Func IGF_Start($section,$G_saved)
;	FileChangeDir(@Scriptdir&"/play")
	ReadConf()
	if $section=='begin' Then Welcome(2)
	GUICtrlSetState($igf_mn[2][0],$GUI_ENABLE)
	ReadSection($section,$G_saved)
EndFunc

Func IGF_Exit($w = "")
	if ($w=="") AND (Ubound($G_bucket)>0) Then
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
	local $tpos = Get_Dimensions(false,"playarea")
	; Playarea|283|124|800|480
	$igf_pa = GUICreate("", $tpos[2], $tpos[3], $tpos[0] , $tpos[1], $WS_CHILD,0, $igf_win)
	GUISetFont($G_fontsize,0,0,$G_fontname,$igf_pa,5)
	GUISetBkColor("0x"&$pa_bgcolor,$igf_pa)
	$iScene = GUICtrlCreatePic($pa_bgimage,0,0,$pa_width,$pa_height)
	GUICtrlSetState($iScene,$GUI_DISABLE)
	GUISetState(@SW_SHOW,$igf_pa)
	return $igf_pa
EndFunc

Func IGF_ScoreBar()
	local $tpos = Get_Dimensions(false,"playarea")
	local $fz = Get_Dimensions(false,"size")
	;Size|12|24|18|9
	$igf_sb = GUICreate("", $tpos[2], $fz[1]+ $fz[2], $tpos[0] , $tpos[1]-($fz[1]+$fz[2] + 2 ), $WS_CHILD, 0, $igf_win)
	$iScores = GUICtrlCreateLabel("Score",$fz[3],$fz[3]+.5*$fz[3],$tpos[2]-$fz[3],$fz[1]);
	GUISetBkColor(0x220022,$igf_sb)
	GUICtrlSetColor($iScores,0xFFFFFF)
	GUICtrlSetBkColor($iScores,$GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetFont($iScores,$fz[0],700)
	GUICtrlSetState($iScores,$GUI_ONTOP)
	GUISetState(@SW_SHOW,$igf_sb)
	return $igf_sb
EndFunc

Func IGF_SavSave()
	$save_file = FilesaveDialog($pa_title & " Saved Files",$igf_saved,"All (*."&$G_keyword&".ini)", $FD_PATHMUSTEXIST+$FD_PROMPTOVERWRITE)
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
		_ArrayAdd($G_bucket,"been"&"|"&$sBeen)

		IniWriteSection ( $save_file, "data", $G_bucket,0 )

		Global $been[0]

	Endif
	FileChangeDir(@Scriptdir&"/play")
	return ""
EndFunc

Func IGF_SavLoad()
	local $section
	$save_file = FileOpenDialog($pa_title & " Saved Files",$igf_saved,"All (*."&$G_keyword&".ini)", $FD_FILEMUSTEXIST)
	If @error Then
		return ""
	Else
		$G_saved = IGF_SavRead($save_file)
		if $G_keyword == $G_saved[1][1] Then
			$section = $G_saved[2][1]
			$step = $G_saved[3][1]
			$abeen = $G_saved[5][1]
			$score = $G_saved[4][1]
		Endif

		global $been[] = _StringExplode ( $aBeen, "," )

		; Jus like restart playarea

		FileChangeDir(@Scriptdir&"/play")

		GUIDelete($igf_pa)
		IGF_PlayArea()
		GUICtrlSetData($iScores,"Score: "&$score)
		IGF_Start($section,$G_saved)

	Endif
EndFunc

Func IGF_SavRestart($file)
	Global_ResetVar()
	GUIDelete($igf_pa)
	GUIDelete($igf_sb)
	IGF_ScoreBar()
	IGF_PlayArea()
	IGF_Start('begin',$G_saved)
EndFunc

Func IGF_SavRead($sfn)
	return IniReadSection($sfn,"data")
EndFunc

Func Global_ResetVar()
	Global $been[0]
	Global $score = 0
	Global $been[0]
	Global $step = 0
	Global $iScene
	Global $iScores
	Global $G_obj[0]
	Global $G_saved[0][2]
	Global $G_bucket[0][2]
EndFunc

Func GetDir($sFilePath)

	Local $aFolders = StringSplit($sFilePath, "\")
	Local $iArrayFoldersSize = UBound($aFolders)
	Local $FileDir = ""

	If (Not IsString($sFilePath)) Then
		Return SetError(1, 0, -1)
	EndIf

	$aFolders = StringSplit($sFilePath, "\")
	$iArrayFoldersSize = UBound($aFolders)

	For $i = 1 To ($iArrayFoldersSize - 2)
		$FileDir &= $aFolders[$i] & "\"
	Next

	Return $FileDir

EndFunc	;==>GetDir

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
