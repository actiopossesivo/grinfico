#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPIFiles.au3>
#include <Array.au3>
#include <String.au3>
#include <GuiScrollBars.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <MsgBoxConstants.au3>
#include <wmp.au3>

#include <Zip.au3>
#include <FileConstants.au3>

Opt("GUIOnEventMode", 0)
Opt("GUICoordMode", 1)
Opt('WINTITLEMATCHMODE', 4)

local $tbpos = ControlGetPos("classname=Shell_TrayWnd", "","")
Global $win_width = @DesktopWidth
Global $win_height = @DesktopHeight-$tbpos[3]
Global $pic_height = 9/16 * $win_width
Global $wintitle = "Untitled"
Global $fontsize = 14
Global $default_pic = "00.jpg"

Func ReadConf()
	local $conf = IniReadSection($igf_ini,"config");
	For $i = 1 To $conf[0][0]
		if $conf[$i][0] == 'width' Then $win_width=$conf[$i][1]
		if $conf[$i][0] == 'height' Then $win_height=$conf[$i][1]
		if $conf[$i][0] == 'pic_height' Then $pic_height=$conf[$i][1]
		if $conf[$i][0] == 'title' Then $win_title=$conf[$i][1]
		if $conf[$i][0] == 'fontsize' Then $fontsize=$conf[$i][1]
		if $conf[$i][0] == 'default_pic' Then $default_pic=$conf[$i][1]
	Next
EndFunc

Func Text($nsep,$text)
	if $nsep == 0 Then $nsep = 20
	Dim $fz = $fontsize -2;
	local $bpost[4]
	$bpost[0]= $win_width - 32 ; Width
	$l = Ceiling( StringLen($text) / ($bpost[0]/10) );
	$bpost[1]= $l * ($fz*1.5)	; height
	$bpost[2]= $pic_height+$nsep ; top
	$bpost[3]= 16 ; left
	$ntop = $bpost[1] + $nsep + 24

    local $btn = GUICtrlCreateLabel($text,$bpost[3],$bpost[2],$bpost[0],$bpost[1],-1)
	GUICtrlSetBkColor($btn,$GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetFont($btn, $fz, 400, 0)
	GUICtrlSetColor($btn,0xC0C0C0)
	GUICtrlSetCursor($btn,0)

	_ArrayAdd($adis,$btn);

	local $res[2]
	$res[1] = $btn
	$res[0] = $ntop

	return $res

EndFunc

Func ActButton($nsep,$text)
	if $nsep == 0 Then $nsep = 20
	local $bpost[4]
	$bpost[0]= $win_width - 32 ; Width
	$l = Ceiling( StringLen($text) / ($bpost[0]/10) );
	$bpost[1]= $l * ($fontsize*1.5)	; height
	$bpost[2]= $pic_height+$nsep ; top
	$bpost[3]= 16 ; left
	$ntop = $bpost[1] + $nsep + 24

	local $dis = GUICtrlCreateLabel("",$bpost[3]-8,$bpost[2]-8,$bpost[0]+16,$bpost[1]+16,$SS_WHITEFRAME)
	GUICtrlSetState($dis, $GUI_DISABLE)
	_ArrayAdd($adis,$dis);
	local $btn = GUICtrlCreateLabel($text,$bpost[3],$bpost[2],$bpost[0],$bpost[1],-1)
	GUICtrlSetBkColor($btn,$GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetFont($btn, $fontsize, 400, 0)
	GUICtrlSetColor($btn,0xFFFFFF)
	GUICtrlSetCursor($btn,0)

	local $res[2]
	$res[1] = $btn
	$res[0] = $ntop

	return $res

EndFunc

Func PageButton($btnname)

	if $btnname == "prev" Then
		local $btn_prop[2]
		$btn_prop[0] = 'ç'
		$btn_prop[1] = 0
	Else
		local $btn_prop[2]
		$btn_prop[0] = 'è'
		$btn_prop[1] = $win_width-40
	Endif

	local $btn = GUICtrlCreateLabel($btn_prop[0],$btn_prop[1], 0,40,$pic_height,$SS_CENTER+$SS_CENTERIMAGE,$WS_EX_TOPMOST)
	GUICtrlSetFont($btn, 16, 700,0,'Wingdings',4)
	GUICtrlSetColor($btn,0xFFFFFF)
	GUICtrlSetBkColor($btn,$GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetCursor($btn,0)

	return $btn


EndFunc

Func DisplayVideo($vid)
	$wmp = _wmpcreate(1,40, 0,$win_width-80, $pic_height)
	_wmpvalue( $wmp, "nocontrols" );hides controls
	_wmploadmedia( $wmp,	$vid);loads media
	return $wmp;
EndFunc

Func DisplayPic($pic)
	Local $idPic = GUICtrlCreatePic($pic, 0, 0,$win_width, $pic_height)
	GUICtrlSetState($idPic, $GUI_DISABLE)
	GUICtrlSetResizing($idPic, 1)
	return $idpic
EndFunc

Func GetSection($section,$w)
	$aS = IniReadSectionNames($igf_ini)
	$i = _ArraySearch($aS,$section)
	if $w == 'prev' Then
		$s = $i-1
	Else
		$s = $i+1
	EndIf
	return $aS[$s]
 EndFunc

 Func Welcome()
   local $welcome = GUICreate("iGF",600,300)
   GUICtrlCreatePic('igf-open.jpg',0,0,600,120)
   $browse = GUICtrlCreateButton("Open",490,130,100)
   GUISetState(@SW_SHOW)

   While 1
	  local $click = GUIGetMsg()
	  Select
		 Case $click = $GUI_EVENT_CLOSE
			igf_exit()
		 Case $click = $browse
			$igf_file = browse($welcome)
			GUIDelete($welcome)
			exitloop
	  EndSelect
   WEnd

   return $igf_file
EndFunc

Func browse($w)
   Local Const $sMessage = "Open IGF zip Package"
   Local $sFileOpenDialog = FileOpenDialog($sMessage, @WorkingDir & "\games\", "All (*.zip)", $FD_FILEMUSTEXIST)
   If @error Then
		FileChangeDir(@ScriptDir)
		GUIDelete($w)
		Welcome()
   Else
        FileChangeDir(@ScriptDir)
        $sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)
   EndIf

   return $sFileOpenDialog

EndFunc