#include <igf-function.au3>

Global $direct = 0
Global $owDir = @WorkingDir

if $CmdLine[0]>0 Then
   $igf_ini = $CmdLine[1]
   $wDir = GetDir($igf_ini)
   FileChangeDir($wDir);
Else
   $direct = 0
   $igf_pack = Welcome()
   if FileExists(@WorkingDir&"/play/")==1 Then DirRemove(@WorkingDir&"/play/",1)
   DirCreate(@WorkingDir&"/play/")
   FileChangeDir ( @WorkingDir&"/play/" )
    _Zip_UnzipAll($igf_pack, @WorkingDir, 1)
   $igf_ini = "igf.ini"
Endif

ReadConf()
igf_main()
igf_exit($direct)

Func igf_main()

	local $h = GUICreate("iGFiction : "& $wintitle, $win_width, $win_height, 0, 0, BitOR($WS_MINIMIZEBOX, $WS_SYSMENU),$WS_EX_APPWINDOW)
	GUISetBkColor(0x000022)
	Local $wSize = WinGetClientSize($h)
	$win_width = $wSize[0]
	$pic_height = 9/16*$wSize[0]

	Global $i_pic=0;
	Global $i_vid=0;

	OpenSection("title","init")

EndFunc

Func igf_exit($d)
    if $d == 1 Then
	  GUIDelete()
	  Exit
   Else
	  Welcome()
   Endif
EndFunc

Func OpenSection($section,$s)

	local $res[1]
	$res[0] = 20

	if $s=="init" Then
		Global $act[0]
		Global $act_param[0]
		Global $adis[0]
		$video =0;
	Else
		For $n = 0 to UBound($act)-1
			GUICtrlDelete($act[$n])
		Next
		For $n = 0 to UBound($adis)-1
			GUICtrlDelete($adis[$n])
		Next
		Dim $act[0]
		Dim $act_param[0]

		if $i_vid>0 Then GUICtrlDelete($i_vid)
		$video =0;
	EndIf

	local $ini = IniReadSection($igf_ini,$section);

	For $i = 1 To $ini[0][0]
		if $ini[$i][0] == 'vid' Then
			GUICtrlDelete($i_pic)
			$i_vid = DisplayVideo($ini[$i][1])
			$video = 1;
		EndIf
		if $ini[$i][0] == 'pic' Then
		if $video==0 Then
			GUICtrlDelete($i_pic)
			$i_pic = DisplayPic($ini[$i][1])
		Endif
		EndIf
		if $ini[$i][0] == 'next' Then
			_ArrayAdd($act, PageButton('next'))
			_ArrayAdd($act_param,GetSection($section,'next'))
		Endif
		if $ini[$i][0] == 'prev' Then
			_ArrayAdd($act, PageButton('prev'))
			_ArrayAdd($act_param,GetSection($section,'prev'))
		Endif
		if $ini[$i][0] == 'text' Then
			$p = $ini[$i][1]
			$res = Text($res[0],$p)
		Endif
		if $ini[$i][0] == 'act' Then
			$p = _StringExplode ( $ini[$i][1], "|"); 0 - section, 1 - text
			$res = ActButton($res[0],$p[1])
			_ArrayAdd($act, $res[1])
			_ArrayAdd($act_param,$p[0])
		Endif
	Next

	GUISetState(@SW_SHOW)

	While 1
		$click = GUIGetMsg()
		If $click == $GUI_EVENT_CLOSE Then igf_exit($direct)
		For $n = 0 to UBound($act)-1
			If $click == $act[$n] Then
			OpenSection($act_param[$n],1)
			EndIf
		Next
	WEnd

 EndFunc

;	_ArrayDisplay($act, "$act")
;	_ArrayDisplay($act_param, "$act_param")

