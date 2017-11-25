Func vidplay($video,$left,$top,$width,$height)
	$res = _wmpcreate(1, $left, $top, $width, $height)
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
; ----------------------

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
	msgbox(0,"About IgFE", _
		"Interactive Graphical Fictions Engine"&@CRLF&@CRLF& _
		"Engine:"&@CRLF&"https://github.com/actiopossesivo/igfiction"&@CRLF&@CRLF& _
		"Wiki:"&@CRLF&"https://goo.gl/bQW68P"&@CRLF)
EndFunc

Func Get_Dimensions($debug=False,$keyword='',$z=12,$w=800,$h=480)

	if $z>14 Then $z=14
	if $z<8 Then $z=8

	local $fz[] = [ $z, $z*2, $z*1.5, $z*.75 ] ; fz, h, pad, hsep
	local $pa[] = [ $w-(2*$fz[2]), $h-(2*$fz[2]) ]
	local $wz[0][5] ;  ref, l,t,w,h

	$D = _DesktopVisibleArea()

	_ArrayAdd($wz, "Size" &"|"& $fz[0] &"|"& $fz[1] &"|"& $fz[2] &"|"& $fz[3] )
	_ArrayAdd($wz, "Desktop" &"|"& 0 &"|"& 0 &"|"& $D[0] &"|"& $D[1] )
	_ArrayAdd($wz, "Playarea" &"|"& ($D[0]/2)-($w/2) &"|"& ($D[1]/2)-($h/2) &"|"& $w &"|"& $h )
	_ArrayAdd($wz, "Frame" &"|"& $fz[3] &"|"& $h-$fz[3] &"|"& $w-(2*$fz[3]) &"|"& $fz[1] )
	_ArrayAdd($wz, "Inside" &"|"& $fz[2] &"|"& $h-$fz[2] &"|"& $w-(2*$fz[2]) &"|"& $fz[1] )

	if $keyword<>"" Then
		local $i = _ArraySearch($wz, StringLower($keyword))
		local $found[] = [ $wz[$i][1], $wz[$i][2], $wz[$i][3], $wz[$i][4] ]
	Endif

   if $debug<>False Then _ArrayDisplay($wz)

   return $found

Endfunc
