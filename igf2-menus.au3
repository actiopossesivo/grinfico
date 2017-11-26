Func IGF_Conf()
	local $conf = IniReadSection(@ScriptDir&"\prop\igf-conf.ini","igf")
	For $i = 1 To Ubound($conf)-1
		if $conf[$i][0] == 'dialog_bgr' Then $dialog_bgr = @ScriptDir&"\prop\"&$conf[$i][1]
		if $conf[$i][0] == 'fontname' Then $G_fontname=$conf[$i][1]
		if $conf[$i][0] == 'fontsize' Then $G_fontsize=$conf[$i][1]
	Next
EndFunc

Func PackageConf()
	local $conf = IniReadSection($pack_ini,"config")
	For $i = 1 To Ubound($conf)-1
		if $conf[$i][0] == 'width' Then $pa_width=$conf[$i][1]
		if $conf[$i][0] == 'height' Then $pa_height=$conf[$i][1]
		if $conf[$i][0] == 'vidheight' Then $pa_vidheight=$conf[$i][1]
		if $conf[$i][0] == 'title' Then $pa_title=$conf[$i][1]
		if $conf[$i][0] == 'bgcolor' Then $pa_bgcolor = $conf[$i][1]
		if $conf[$i][0] == 'tcolor' Then $pa_color = $conf[$i][1]
		if $conf[$i][0] == 'acolor' Then $a_color = $conf[$i][1]
		if $conf[$i][0] == 'bgimage' Then $pa_bgimage = $conf[$i][1]
		if $conf[$i][0] == 'keyword' Then $G_keyword=$conf[$i][1]
		if $conf[$i][0] == 'vbtn_width' Then $vbtn_width=$conf[$i][1]
		if $conf[$i][0] == 'hbtn_width' Then $hbtn_width=$conf[$i][1]
		if $conf[$i][0] == 'dialog_bgr' Then $dialog_bgr = @WorkingDir&"\"&$conf[$i][1]

		if $G_keyword=="" Then $G_keyword = StringRegExpReplace ( StringLower($pa_title), "[\s|\W]", "")

	Next
EndFunc

Func vidplay($video,$left=0,$top=0,$width=0,$height=0)
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

Func IGF_ReadMe()
	local $txt = "No Readme.txt found in this packcage"
	if FileExists("readme.txt") Then
		Local $file = FileOpen("readme.txt")
		$txt = FileRead($file)
		FileClose($file)
	Endif
	msgbox(0,'readme',$txt)
EndFunc

Func IGF_About()
	msgbox(0,"About Grinfico", _
		"Grinfico - Graphical Interactive Fictions Engine"&@CRLF&@CRLF& _
		"Engine:"&@CRLF&"https://github.com/actiopossesivo/igfiction"&@CRLF&@CRLF& _
		"Wiki:"&@CRLF&"https://goo.gl/bQW68P"&@CRLF)
EndFunc

Func Get_Dimensions($debug=False,$G_keyword='')

	if $G_fontsize>14 Then $G_fontsize=14
	if $G_fontsize<8 Then $G_fontsize=8

	local $w = $pa_width
	local $h = $pa_height

	local $fz[] = [ $G_fontsize, $G_fontsize*2, $G_fontsize*1.5, $G_fontsize*.75 ] ; fz, h, pad, hsep
	local $pa[] = [ $w-(2*$fz[2]), $h-(2*$fz[2]) ]
	local $wz[0][5] ; ref, l,t,w,h

	$D = _DesktopVisibleArea()

	_ArrayAdd($wz, "Base" &"|"& $fz[0] &"|"& $fz[1] &"|"& $fz[2] &"|"& $fz[3] )
	_ArrayAdd($wz, "Desktop" &"|"& 0 &"|"& 0 &"|"& $D[0] &"|"& $D[1] )
	_ArrayAdd($wz, "Playarea" &"|"& ($D[0]/2)-($w/2) &"|"& ($D[1]/2)-($h/2) &"|"& $w &"|"& $h )
	_ArrayAdd($wz, "Frame" &"|"& $fz[3] &"|"& $h-$fz[3] &"|"& $w-(2*$fz[3]) &"|"& $fz[1] )
	_ArrayAdd($wz, "Inside" &"|"& $fz[2] &"|"& $h-$fz[2] &"|"& $w-(2*$fz[2]) &"|"& $fz[1] )

	if $G_keyword<>"" Then
		local $i = _ArraySearch($wz, StringLower($G_keyword))
		local $found[] = [ $wz[$i][1], $wz[$i][2], $wz[$i][3], $wz[$i][4] ]
	Endif

	if $debug<>False Then _ArrayDisplay($wz)

	return $found

Endfunc


Func Texting($TXT,$goto)

	local $goto_confirm = ''

	for $i = 0 to UBound($TXT)-1
		if $i == UBound($TXT)-1 Then $goto_confirm = $goto
		Text(0,$TXT[$i],$goto_confirm)
	Next

EndFunc

Func calc_height($fz,$md,$txt='')
	local $n = Ceiling( (StringLen($txt) * $fz[0] *.65) / $md[2] )
	if $n < 2 Then $n= 2
	local $height = $n * $fz[1]
	return $height
EndFunc

Func Textis($txt)
	local $aText = _StringExplode($txt,"::")
	if Ubound($aText)>1 Then
		$aText[0] = StringRegExpReplace ( $aText[0], "\s+$", "")
		$aText[1] = StringRegExpReplace ( $aText[1], "^\s+", "")
		return $aText
	Else
		return $txt
	EndIf
EndFunc

Func Text($top,$txt,$goto="")

	;ReDim $ct[0] ; Well?
	Local $add = 0

	local $bubble = PutPNG($dialog_bgr,-$pa_width,0,0,0)
	GUICtrlSetState($bubble,$GUI_DISABLE)

	local $tpos = Get_Dimensions(false,"inside")
	local $bpos = Get_Dimensions(false,"frame")
	local $fz	= Get_Dimensions(false,"base")

	local $aTxt = Textis($txt);
	local $height = calc_height($fz,$tpos,$aTxt)
	local $vdispose[0]

	if IsArray($aTxt) Then
		$add = $fz[1]
		local $pt = GUICtrlCreateLabel($aTxt[0],$tpos[0],$tpos[1]-$height-$add,$tpos[2],$add )
		GUICtrlSetColor($pt,"0x"&$a_color)
		GUICtrlSetFont($pt,$fz[0]*.9,600)
		GUICtrlSetBkColor($pt,$GUI_BKCOLOR_TRANSPARENT )
		local $t = GUICtrlCreateLabel($aTxt[1],$tpos[0],$tpos[1]-$height,$tpos[2],$height )
		_ArrayAdd($vdispose,$pt)
		_ArrayAdd($vdispose,$t)
	Else
		local $t = GUICtrlCreateLabel($aTxt,$tpos[0],$tpos[1]-$height,$tpos[2],$height )
		_ArrayAdd($vdispose,$t)
	Endif

	GUICtrlSetColor($t,'0x'&$pa_color)
	GUICtrlSetCursor($t,0)
	GUICtrlSetFont($t,$fz[0],-1)
	GUICtrlSetBkColor($t,$GUI_BKCOLOR_TRANSPARENT)
	GuiCtrlSetState($t, $GUI_ONTOP)

	GUICtrlSetPos($bubble, $bpos[0], $bpos[1] - $height - $add-$fz[2], $bpos[2], $height+$add+$fz[2] )
	_ArrayAdd($vdispose,$bubble)
	While 1
		local $click = GUIGetMsg(1)
		if $click[1] == $igf_pa Then
			local $res = Text_GM($click[0],$t,$vdispose,$goto)
			if $res==1 Then ExitLoop
		Elseif $click[1] == $igf_win Then
			if $click[0] == $GUI_EVENT_CLOSE Then Call("IGF_Exit")
			Menu_GM($click[0])
		Endif
	WEnd

EndFunc

Func Text_GM($click,$t,$vdispose,$goto="")
	if $click == $t Then
		ClearingGUICtrl($vdispose)
		if $goto<>'' Then ReadSection($goto,$G_saved)
		return 1
	Endif
EndFunc

