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

; Score/puzzle

