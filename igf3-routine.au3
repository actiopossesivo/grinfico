Func SectionThread($section, $param='')

	if $param == 1 Then
		$aDisposal = ClearingGUICtrl($aDisposal)
	Endif

	local $opt = IniReadSection($inifile,$section)
	local $Sections = IniReadSectionNames($inifile)
	local $current = _ArraySearch($Sections,$section)
	local $d = GetDimension_of('Playarea')
	local $next_page = ""
	local $gtext[0]
	local $gpng[0][5]
	local $gvid[0][5]
	local $ggif[0][5]
	local $gspot[0][5]
	local $ghbutton[0][2]
	local $gvbutton[0][2]
	local $shake=0
	local $wait=0

	if @compiled==0 Then ConsoleWrite("Section"&@TAB&"= "&$Section&"("&$current&"/"&Ubound($Sections)-1&")"&@CRLF)

	for $i = 0 to Ubound($opt)-1
		Switch StringLower($opt[$i][0])

			Case "shake"
				$shake=$opt[$i][1]

			Case "wait"
				$wait=$opt[$i][1]

			Case "condition"
				local $cond = StringSplit($opt[$i][1],"|")
				if ( Scoring('get',$cond[1]) < $cond[2] ) Then  SectionThread($cond[3])

			Case "next"
				$n = $current + 1
				if $n>Ubound($Sections)-1 Then $n = 2
				$next_page = $Sections[$n]

			Case "prev"
				$n = $current - 1
				if $n<2 Then $n = 2
				$next_page = $Sections[$n]

			Case "goto"
				$next_page = $opt[$i][1]

			Case "scene"
				$dpng = ClearingGUICtrl($dpng)
				GUICtrlDelete($scene)
				$scene = PNG($opt[$i][1], 0,0,$d[2],$d[3],0)

			Case "png"
				_ArrayAdd($gpng,$opt[$i][1],0,"|")
			Case "text"
				_ArrayAdd($gtext,$opt[$i][1])

			Case "button"
				_ArrayAdd($gvbutton,$opt[$i][1],0,"|")
			Case "hbutton"
				_ArrayAdd($ghbutton,$opt[$i][1],0,"|")
			Case "spot"
				_ArrayAdd($gspot,$opt[$i][1],0,"|")

			Case "score"
				Local $value = $opt[$i][1]
				local $addto = "score"
				$aa = StringSplit($opt[$i][1],"|",2)
				if ubound($aa)>1 Then
					$addto = $aa[1]
					$value = $aa[0]
				Endif

				if CheckBeen($section)==false Then
					_ArrayAdd($aBeen,$section)
					if @compiled==0 Then ConsoleWrite( "+++ Score(" & $addto &"/"& $section &") : "& $value & @CRLF )
					Scoring("set",$addto,$value)
				Endif

		EndSwitch
	Next

	DebugArray($aScore,3)

	if Ubound($gpng)>0 Then
		$dpng = ClearingGUICtrl($dpng)
		for $i = 0 to Ubound($gpng)-1
			local $pic = PNG($gpng[$i][0],$gpng[$i][1],$gpng[$i][2],$gpng[$i][3],$gpng[$i][4],0)
			_ArrayAdd($dpng,$pic)
		Next
	Endif

	local $nonpage=0
	if Ubound($ghbutton)>-1 OR Ubound($gvbutton)>-1 OR Ubound($gspot)>-1 Then $nonpage=1

	if $shake>0 then ShakePlayarea($shake)
	if $wait>0 then Sleep($wait*1000)

	if Ubound($gtext)>-1 Then
		local $r
		local $next =""
		for $i = 0 to UBound($gtext)-1
			if $i == UBound($gtext)-1 Then $next = $next_page
			if $nonpage=0==1 then $next = ""
			$r = Text(0,$gtext[$i],$next)
		Next
	Endif

	if Ubound($ghbutton)>-1 OR Ubound($gvbutton)>-1 OR Ubound($gspot)>-1 Then
		$r = Prompting($ghbutton, $gvbutton, $gspot)
	Endif

	exit

EndFunc

Func Scoring($sw='set',$subject='score', $value=0)
	local $i = _ArraySearch($aScore, StringLower($subject))
	Switch $sw
		case "set"
			$aScore[$i][2]=$aScore[$i][2] + $value
			if $aScore[$i][1]<>"" Then
				GUICtrlSetData($aScore[$i][1], $aScore[$i][2])
				if $subject=='score' Then beep(888,200)
				return $aScore[$i][2]
			Endif
		case "get"
			return $aScore[$i][2]
	EndSwitch

EndFunc

Func CheckBeen($section)
	local $been = _ArrayUnique($aBeen)
	local $pass = false
	if  _ArraySearch($been,$section) > 1 Then  $pass=true
	return $pass
EndFunc


Func Text($top,$txt,$goto)
	local $tb = PNG(GetConf('bgdialog'),-1,-1,1,1,1)
	local $d = GetDimension_of('inside')
	local $f = GetSize_of('font')
	local $handle[0][4]
	local $add = 0

	$d[3] = calc_height($f[1], $d, $txt)
	$d[1] = $d[1] - $top - $d[3] - $f[0]

	local $aTxt = Text_isArray($txt)

	if IsArray($aTxt) Then
		$add = $f[1]
		if FileExists($aTxt[0]&"-head.png") Then
			$ah = PNG($aTxt[0]&"-head.png",$d[0]-$f[0],$d[1]-$add-64-$f[0],64,64,0)
			_ArrayAdd($aDisposal,$ah)
		Endif
		local $ta = GUICtrlCreateLabel($aTxt[0], $d[0], $d[1]-$add, $d[2], $d[3]+$add )
		GUICtrlSetColor($ta,0xFF00FF)
		GUICtrlSetFont($ta,$f[0]*.9,700)
		GUICtrlSetBkColor($ta,$GUI_BKCOLOR_TRANSPARENT )
		$txt = StringStripWS($aTxt[1],3)
		_ArrayAdd($aDisposal,$ta)
	Else
		$txt = $aTxt
	Endif

	local $th = GUICtrlCreateLabel($txt,$d[0],$d[1],$d[2],$d[3])
	GUICtrlSetColor($th,0xFFFFFF)
	GUICtrlSetBkColor($th,$GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetFont($th,$f[0],400)
	_ArrayAdd($aDisposal,$th)

	GUICtrlSetPos($tb, $d[0]-$f[0], ($d[1]-$f[0])-$add, $d[2]+$f[0]*2, $d[3]+($f[1])+$add )
	_ArrayAdd($aDisposal,$tb)

	GuiCtrlSetState($th, $GUI_ONTOP)
	if $goto=="" Then
		_ArrayAdd($handle, $tb &"|"& "Text_Next" &"|"& "" &"|"& "")
	Else
		_ArrayAdd($handle, $tb &"|"& "SectionThread" &"|"& $goto &"|"& 1)
	Endif

	local $res = GUI_Function($handle)
	return $res

Endfunc

Func Prompting($hbutton,$vbutton,$spot)

	local $B = Ubound($hbutton)
	local $V = Ubound($vbutton)
	local $S = Ubound($spot)
	local $pos = 0
	local $handle[0][4]

	if $B>0 Then
		for $i = 0 to $B-1
			local $res = Prompt("h",$hbutton[$i][1], $pos, $B)
			$pos = $res[0]
			_ArrayAdd( $handle, $res[1] &"|"& "SectionThread" &"|"& $hbutton[$i][0] &"|"& 1 )
		Next
	Endif

	if $V>0 Then
		for $i = 0 to $V-1
			local $res = Prompt("v",$vbutton[$i][1], $pos, $V)
			$pos = $res[0]
			_ArrayAdd( $handle, $res[1] &"|"& "SectionThread" &"|"& $vbutton[$i][0] &"|"& 1 )
		Next
	Endif

	if $S>0 Then
		for $i = 0 to $S-1
			local $sres = GUICtrlCreateLabel("",$spot[$i][1],$spot[$i][2],$spot[$i][3],$spot[$i][4])
			GUICtrlSetCursor($sres,0)
			GUICtrlSetBkColor($sres,$GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState($sres,$GUI_ONTOP)
			_ArrayAdd( $handle, $sres &"|"& "SectionThread" &"|"& $spot[$i][0] &"|"& 1 )
			_ArrayAdd($aDisposal,$sres)
		Next
	Endif

	Scoring("set","lapse",1)

	local $res = GUI_Function($handle)

	return $res

EndFunc


Func Prompt($type,$prompt,$pos,$total)

	local $d = GetDimension_of('inside')
	local $f = GetSize_of('font')
	local $height = $f[1]
	local $w = GetSize_of('prompt')

	Switch $type

	Case "h"
		local $width = $w[0]
		$top = $d[1] - $height
		if $pos == 0 Then $pos = ($d[2] - ($width*$total))/2
		if $pos <= 0 Then $pos = $d[0]
		local $tb = PNG(GetConf('bgdialog'), $pos, $top, $width, $height+3, 1)
		Local $btn = GUICtrlcreateLabel($prompt, $pos+3, $top+1, $width-3, $height, $SS_CENTER+$SS_CENTERIMAGE)
		GUICtrlSetColor($btn,0xFFFFFF)
		GUICtrlSetFont($btn,$f[0],700)
		GUICtrlSetBkColor($btn,$GUI_BKCOLOR_TRANSPARENT)
		GuiCtrlSetState($btn, $GUI_ONTOP)
		_ArrayAdd($aDisposal,$btn)
		_ArrayAdd($aDisposal,$tb)
		local $new_pos = $pos + ($width*1.05)

	Case "v"
		local $width = $w[1]
		local $left = ($d[2]- $width)/2
		if $pos==0 Then $pos = $d[1] - (($height*1.25)*$total)
		local $tb = PNG(GetConf('bgdialog'), $left, $pos, $width, $height+3, 1)
		Local $btn = GUICtrlcreateLabel($prompt, $left+3, $pos+1, $width-3, $height, $SS_CENTER+$SS_CENTERIMAGE)
		GUICtrlSetColor($btn,0xFFFFFF)
		GUICtrlSetFont($btn,$f[0],700)
		GUICtrlSetBkColor($btn,$GUI_BKCOLOR_TRANSPARENT)
		GuiCtrlSetState($btn, $GUI_ONTOP)
		_ArrayAdd($aDisposal,$btn)
		_ArrayAdd($aDisposal,$tb)
		local $new_pos = $pos + ($height*1.25)
	EndSwitch

	local $res[]=[ $new_pos, $tb ]

	return $res

EndFunc

Func GUI_Function($handle)

	While 1
		local $click = GUIGetMsg(1)
		if $click[1] == $hPA Then
			local $res = GUIHandle("pa",$click, $handle)
			if $res==2 Then return $res
		Endif
		if $click[1] == $hWin Then
			local $res = GUIHandle("win",$click)
		Endif
	WEnd
EndFunc

Func GUIHandle($sw,$click,$handle='')

	local $res

	Switch $sw

	case "pa"

		if not IsArray($handle) Then
			MsgBox(0,'',"Handle must in array")
		Endif

		for $i = 0 to UBound($handle)-1
			if $click[0] == $handle[$i][0] Then
				$res = Call($handle[$i][1], $handle[$i][2], $handle[$i][3] )
			Endif
		Next

	Case "win"
		if	$click[0] == $GUI_EVENT_CLOSE Then AppClose()
		if 	$click[0] == $GUI_EVENT_RESIZED OR _
			$click[0] == $GUI_EVENT_MAXIMIZE OR _
			$click[0] == $GUI_EVENT_RESTORE Then
			ReSize()
		EndIf
		Menu_GetMsg($click[0])

	EndSwitch

	return $res

EndFunc

Func AttachScore_GUI($subject,$cgui)
	if isArray($aScore) Then
		local $i = _ArraySearch($aScore, $subject)
		$aScore[$i][1] = $cgui
		GUICtrlSetColor($cgui,'0x'&$aScore[$i][4])
	Endif
EndFunc

Func Menu_GetMsg($click)
	For $i = 0 to Ubound($hMenu)-1
		if $click == $hMenu[$i][0] Then
			Call($hMenu[$i][1],$hMenu[$i][2])
		Endif
	Next
EndFunc
