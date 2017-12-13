#include <WinAPIGdi.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <Array.au3>
#include <String.au3>
#include <GuiMenu.au3>
#include <Crypt.au3>

#Include <lib/Icons.au3>
#include <lib/GIFAnimation.au3>
#Include <lib/_Zip.au3>
#Include <lib/wmp.au3>

Opt('WINTITLEMATCHMODE', 4)

Func LoadConfig($file='scenario.ini',$reset=0)

	local $D = _DesktopVisibleArea()
	local $width = 800
	local $height = 480
	local $fontsize = 11
	local $vbtn_width = 320
	local $hbtn_width = 120
	local $bgdialog = @ScriptDir&"\prop\dialog.png"
	local $bgcolor = "111111"
	local $sbbgcolor = "222222"
	local $sbbgimg = @ScriptDir&"\prop\scorebar.png";
	local $tcolor = "AAAAAA"
	local $hcolor = "FFF0FF"

	if $reset=1 Then
		Dim $aConf[0][2]
		Dim $aScore[0][5]
		Dim $aDimension[0][5]
		Dim $aSize[0][3]
		Dim $aScore[0][5]
		_ArrayAdd($aScore,"lapse||0||CCCCCC")
		_ArrayAdd($aScore,"score||0|Score|FFFFFF")
		local $fontname='Clear Sans'
		local $wait = 1
	Endif

	local $title = "Untitled"
	local $cover = ""
	local $keyword = ""

	local $conf = IniReadSection($file,"config")

	FileChangeDir(GetDir($file));

	For $i = 1 To Ubound($conf)-1

		;if @Compiled==0 Then ConsoleWrite("Ini("&$conf[$i][0]&")"&@CRLF)

		Switch $conf[$i][0]

		Case 'sbbgcolor'
			$sbbgcolor = $conf[$i][1]

		Case 'sbbgimg'
			$sbbgimg = $conf[$i][1]
			if FileExists($sbbgimg) Then $sbbgimg = $conf[$i][1]
		Case 'bgcolor'
			$bgcolor = $conf[$i][1]
		Case 'tcolor'
			$tcolor = $conf[$i][1]
		Case 'hcolor'
			$hcolor = $conf[$i][1]

		case 'width'
			$width=$conf[$i][1]
		Case 'height'
			$height=$conf[$i][1]

		case 'fontname'
			local $f = @WorkingDir &"\"& $conf[$i][1] & ".ttf"
			if FileExists($f) Then
				local $s = _WinAPI_AddFontResourceEx($f, $FR_PRIVATE,False)
				$aConf = _ArrayReplace($aConf,'fontname' &"|" & $conf[$i][1] )
				; if @compiled==0 Then ConsoleWrite( "Font" & @TAB & _WinAPI_GetFontName ($conf[$i][1]) &" Loaded"& @CRLF )
			Endif
		Case 'fontsize'
			$fontsize=$conf[$i][1]

		Case 'vbtn_width'
			$vbtn_width=$conf[$i][1]
		Case 'hbtn_width'
			$hbtn_width=$conf[$i][1]

		Case 'title'
			$title = $conf[$i][1]

		Case 'cover'
			$cover = $conf[$i][1]
			if FileExists($cover) Then $aConf = _ArrayReplace($aConf,'cover' &"|" & $cover )

		Case 'welcome_wait'
			$aConf = _ArrayReplace($aConf,'wait' &"|" & $conf[$i][1] )

		case 'keyword'
			$keyword = StringRegExpReplace(StringLower($conf[$i][1]), "[\s|\W]", "")

		case 'bgdialog_img'
			local $f = @WorkingDir&"\"&$conf[$i][1]
			if FileExists($f) Then $bgdialog = @WorkingDir&"\"&$conf[$i][1]

		Case 'scores'
			$aScore = _ArrayReplace($aScore,$conf[$i][1])

		EndSwitch

			$conf[$i][1]=''
	Next

	if $keyword=="" Then $keyword = StringRegExpReplace ( StringLower($title), "[\s|\W]", "")

	$aConf = _ArrayReplace($aConf,'title' &"|" & $title )
	$aConf = _ArrayReplace($aConf,'keyword' &"|" & $keyword )
	$aConf = _ArrayReplace($aConf,'bgcolor' &"|" & $bgcolor )
	$aConf = _ArrayReplace($aConf,'sbbgcolor' &"|" & $sbbgcolor )
	$aConf = _ArrayReplace($aConf,'tcolor' &"|" & $tcolor )
	$aConf = _ArrayReplace($aConf,'hcolor' &"|" & $hcolor )

	$aConf = _ArrayReplace($aConf,'bgdialog' &"|" & $bgdialog )
	$aConf = _ArrayReplace($aConf,'sbbgimg' &"|" & $sbbgimg )

	$aSize = _ArrayReplace($aSize, "font" &"|"& $fontsize &"|"& 2*$fontsize )
	$aSize = _ArrayReplace($aSize, "prompt" &"|"& $hbtn_width &"|"& $vbtn_width )
	$aSize = _ArrayReplace($aSize, "padding" &"|"& $fontsize/2 &"|"& $fontsize/2 )

	$aDimension = _ArrayReplace($aDimension, "ScoreBar" &"|"& 20 &"|"& (130/2)-(3*$fontsize)-($fontsize/2)-30 &"|"& $width &"|"& 3*$fontsize )
	$aDimension = _ArrayReplace($aDimension, "PlayArea" &"|"& 20 &"|"& (130/2) &"|"& $width &"|"& $height )
	$aDimension = _ArrayReplace($aDimension, "Desktop" &"|"& $D[0]/2 - (80+$width)/2 &"|"& (130/2) &"|"& $width+40 &"|"& $height+130 )
	$aDimension = _ArrayReplace($aDimension, "Inside" &"|"& $fontsize*2 &"|"& $height-($fontsize*2) &"|"& $width-(4*$fontsize) &"|"& 2*$fontsize )

EndFunc

Func GetMenuGUI($subject)
	local $found =''
	if IsArray($hMenu) Then
		if $subject<>"" Then
			local $i = _ArraySearch($hMenu, StringLower($subject))
			if $i>-1 Then $found = $hMenu[$i][1]
		Endif
		return $found
	Endif
EndFunc

Func GetConf($subject='fontname')
	local $found=""
	if IsArray($aConf) Then
		if $subject<>"" Then
			local $i = _ArraySearch($aConf, StringLower($subject))
			if $i>-1 Then  $found = $aConf[$i][1]
		Endif
	Endif
	return $found
EndFunc

Func GetSize_of($subject='font')
	Local $found[0]
	if IsArray($aSize) Then
	if $subject<>"" Then
		local $i = _ArraySearch($aSize, StringLower($subject))
		if $i>-1 Then Dim $found[] = [ $aSize[$i][1], $aSize[$i][2] ]
	Endif
	Endif
	return $found
EndFunc

Func GetDimension_of($subject='Desktop')
	Local $found[0]
	if IsArray($aDimension) Then
	if $subject<>"" Then
		local $i = _ArraySearch($aDimension, StringLower($subject))
		if $i>-1 Then Dim $found[] = [ $aDimension[$i][1], $aDimension[$i][2], $aDimension[$i][3], $aDimension[$i][4] ]
	Endif
	EndIf
	return $found
EndFunc

Func ResetParam()
	$aDisposal = ClearingGUICtrl($aDisposal)
	Dim $dpng[0]
	Dim $scene
EndFunc

Func _ArrayReplace($array, $values)

	local $s = StringSplit($values,"|")
	local $i = _ArraySearch($array, StringStripWS($s[1],7),0,0 )
	if $i>-1 Then _ArrayDelete($array,$i)

	_ArrayAdd($array,$values)

	return $array

Endfunc

Func calc_height($fz,$md,$txt='')
	local $n = Ceiling( StringLen($txt) / 110)
	if $n < 1 Then $n=1
	local $height = $n * $fz
	return $height
EndFunc

Func ClearingGUICtrl($dismiss)
	for $i = 0 to Ubound($dismiss)-1
		GUICtrlDelete($dismiss[$i])
	Next
	local $d[0]
	return $d
EndFunc

Func GIF($file,$left=0,$top=0,$width=-1,$height=-1)
	local $hGIF = _GUICtrlCreateGIF($file, "", $left, $top, $width, $height,1)
	return $hGif
EndFunc

Func VID($video,$left=0,$top=0,$width=0,$height=0)
	if $width == 0 Then $width = $pa_width
	if $height == 0 Then $height = $pa_vidheight
	local $res = _wmpcreate(1, $left, $top, $width, $height)
	$ovid = $res[0]
	$oovid = $res[1]
	_wmpvalue($ovid, "nocontrols")
	_wmploadmedia($ovid, $video)
	With $ovid
		.windowlessVideo = True
		.stretchToFit = True
	EndWith
	return $oovid
EndFunc

Func PNG($file,$pl=0,$pt=0,$pw=0,$ph=0,$tm=1)
	local $extm = Default
	local $stm = $SS_CENTERIMAGE
	if $tm==1 Then
		$extm = $WS_EX_TOPMOST
		$stm = $SS_NOTIFY
	Endif

	local $Picpng = GUICtrlCreatePic('',$pl,$pt,$pw,$ph,$stm,$extm)
	_SetImage($Picpng,$file)

	if $tm==1 Then
		GUICtrlSetCursor($Picpng,0)
	Else
		GUICtrlSetState($Picpng,$GUI_DISABLE)
	EndIf
	return $Picpng
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

Func ReSize($m=0)
	local $s = GetDimension_of('ScoreBar')
	local $f = GetSize_of('font')
	local $d = GetDimension_of('PlayArea')
	local $p = WinGetPos($hWin)
	if $d[2]=="" Then $d[2] = 800
	if $d[3]=="" Then $d[3] = 480
	$d[0] = $p[2]/2 - $d[2]/2
	$d[1] = $p[3]/2 - $d[3]/2 - 16
	if $d[0]<0 Then $d[0]=0
	if $d[1]<0 Then $d[1]=0
	if $hSB<>"" Then
		WinMove ( $hSB,"",$d[0],$d[1]-(3*$f[0])-($f[0]/2))
	Endif
	if $hPA<>"" Then
		WinMove ( $hPA,"",$d[0],$d[1])
		GUICtrlSetState($hPA, $GUI_FOCUS)
	Endif

EndFunc

Func AppClose()
	GUIDelete($hWin)
	Exit
EndFunc

Func About_This()
	local $txt = _
		FileGetVersion(@AutoItExe, $FV_PRODUCTNAME)  & _
		FileGetVersion(@AutoItExe, $FV_PRODUCTVERSION) & @CRLF & _
		FileGetVersion(@AutoItExe, $FV_FILEDESCRIPTION) & @CRLF & @CRLF & _
		FileGetVersion(@AutoItExe, $FV_COMMENTS) & @CRLF & @CRLF & _
		"Made with AutoIt "& @AutoItVersion & _
		""
	Msgbox($MB_TASKMODAL,'Grinfico',$txt,0,$hWin)
EndFunc

Func DebugArray($array,$n=1)
	if @Compiled==0 Then
	for $i=0 to UBound($array)-1
		ConsoleWrite($array[$i][0] & @TAB&"= ")
		local $res =''
		for $c=1 to $n
			$res = $res & $array[$i][$c] & ","
		Next
		$res = StringTrimRight($res,1)
		ConsoleWrite($res&@CRLF)
	Next
	ConsoleWrite(@CRLF)
	Endif
EndFunc

Func WelcomeTitle()
	local $d = GetDimension_of('PlayArea')
	local $cover = GetConf('cover')
	local $f = GetSize_of('font')
	local $wimg
	local $wtitle
	if $cover <> "" Then
		$wimg = PNG($cover,0,0,$d[2],$d[3])
	Else
		$wtitle = GUICtrlCreateLabel( _StringProper (GetConf('title')) ,0,0,$d[2],$d[3], $SS_CENTER + $SS_CENTERIMAGE)
		GUICtrlSetColor($wtitle,0xCBCBCB)
		GUICtrlSetFont($wtitle,$f[0]*2,700)
		GUICtrlSetBkColor($wtitle,"0x"&GetConf('bgcolor'))
	Endif
		Sleep(GetConf('wait')*1000)
		if $wtitle<>0 Then GUICtrlDelete($wtitle)
		if $wimg<>0 Then GUICtrlDelete($wimg)
EndFunc

Func Init_Win($file)
	local $d = GetDimension_of('Desktop')
	$hWin = GUICreate("Grinfico",$d[2],$d[3],$d[0],$d[1],$WS_SYSMENU+$WS_MINIMIZEBOX+$WS_MAXIMIZEBOX+$WS_SIZEBOX)
	GUISetBkColor("0x"&GetConf('bgcolor'),$hWin)
	GUISetFont(11,400,Default,"Tahoma",$hWin,5)

	$hMenu = igf_menus($file)
	$label = GUICtrlCreatePic(@Scriptdir&"\prop\grinfico.jpg",$d[2]/2-75,$d[3]/2-110,150,220)
	_ArrayAdd($aDisposal, $label)

	GUICtrlSetState(GetMenuGUI('save'),$GUI_DISABLE)
	GUICtrlSetState(GetMenuGUI('load'),$GUI_DISABLE)
	GUICtrlSetState(GetMenuGUI('restart'),$GUI_DISABLE)

	GuiSetState(@SW_SHOW,$hWin)

EndFunc

Func Init_ScoreBar()
	local $d = GetDimension_of('ScoreBar')
	local $f = GetSize_of('font')
	$hSB = GUICreate("ScoreBar",$d[2],$d[3],$d[0],$d[1], BitOR($WS_CHILD,$WS_BORDER),$WS_EX_TOPMOST, $hWin)
	GUISetBkColor("0x"&GetConf('sbbgcolor'),$hSB)
	GUISetFont($f[0]*.85,700,Default,GetConf('fontname'),$hSB,5)
	PNG(GetConf('sbbgimg'),0,0,$d[2],$d[3],0)
	local $cw = 40
	local $cp = $cw/8
	local $n=0
	for $i=0 to Ubound($aScore)-1
		if  $aScore[$i][3] <> "" Then
			$n =$n+1
			AttachScore_GUI($aScore[$i][0], GUICtrlCreateLabel("", $d[2]-($n*($cw+$cp)), 5, $cw, $f[1], $SS_CENTERIMAGE+$SS_CENTER) )
			GUICtrlSetBkColor(-1,$GUI_BKCOLOR_TRANSPARENT )
			GUICtrlSetTip(-1,$aScore[$i][3],'',0,1)
			GUICtrlSetColor(-1, "0x"&$aScore[$i][4])
		Endif
	Next

	GuiSetState(@SW_SHOW,$hSB)

EndFunc

Func Init_PlayArea()
	if not isHWnd($hPA) Then Global $hPA
	local $d = GetDimension_of('Playarea')
	local $f = GetSize_of('font')
	$hPA =GUICreate("PlayArea",$d[2], $d[3], $d[0], $d[1], BitOR($WS_CHILD,$WS_BORDER), BitOR($WS_EX_TOPMOST, $WS_EX_TRANSPARENT), $hWin )
	GUISetFont($f[0],400,Default,GetConf('fontname'),$hPA,5)
	GuiSetState(@SW_SHOW,$hPA)
EndFunc

Func ShakePlayarea($n=2)
	local $i =0
	local $d = GetDimension_of('PlayArea')
	local $p = WinGetPos($hWin)
	$d[0] = $p[2]/2 - $d[2]/2
	$d[1] = $p[3]/2 - $d[3]/2 - 16
	if $d[0]<0 Then $d[0]=0
	if $d[1]<0 Then $d[1]=0
	if $n< 2 Then $n = 2

	while $i <= $n
		WinMove($hPA,"",$d[0]-2,$d[1],$d[2],$d[3],1)
		WinMove($hPA,"",$d[0]+2,$d[1],$d[2],$d[3],1)
		$i  = $i+1
	WEnd
	WinMove($hPA,"",$d[0],$d[1],$d[2],$d[3])
	GUICtrlSetState($hPA, $GUI_FOCUS)

Endfunc
