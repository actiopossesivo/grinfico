#NoTrayIcon

#pragma compile(Out, GPlot.exe)
#pragma compile(Icon, C:\igf\1\icon.ico)
#pragma compile(Compatibility, vista, win7, win8, win81, win10)
#pragma compile(FileDescription, Grinfico Plotter)
#pragma compile(ProductName, Grinfico Plotter)
#pragma compile(ProductVersion, 0.1)
#pragma compile(Comments,'https://github.com/actiopossesivo/igfiction')

#include <igf3-function.au3>
#include <igf3-files.au3>
#include <igf3-routine.au3>

#include <TreeViewConstants.au3>
#include <ListViewConstants.au3>
#include <GuiListView.au3>

Opt("MustDeclareVars", 1)

Global $hDev
Global $hMenu[0][4]
Global $TreeItem[0][4]
Global $Inspect, $Trees
Global $lv_disposal[0]

local $inifile

if $CmdLine[0]>0 Then
	$inifile = $CmdLine[1]
EndIf

DevMode($inifile)
DevOpen($inifile)

Exit

Func DevMode($file='')
	local $D = _DesktopVisibleArea()
	$hDev =  GUICreate("Grinfico - Plot Trees", $D[0]/2, $D[1]/2, -1, -1, BitOR($WS_SYSMENU,$WS_MAXIMIZEBOX,$WS_SIZEBOX,$WS_MINIMIZEBOX) )
	DevMenu($file)
	GUISetState(@SW_SHOW)
EndFunc

Func DevOpen($inifile)
	local $D =  WinGetPos($hDev)
	local $minres = _WinAPI_GetSystemMetrics($SM_CYCAPTION) + _WinAPI_GetSystemMetrics($SM_CYMENU) + 8
	$D[3] = $D[3]-$minres;
	Global $Inspect = GUICtrlCreateListView("Directive|Values|Op1|Op2|Op3|Op4|Op5", 1/3*$D[2], 0, 2/3*$D[2], $D[3], BitOR($LVS_REPORT,$LVS_EDITLABELS,$LVS_SHOWSELALWAYS,$LVS_AUTOARRANGE), BitOR($WS_EX_CLIENTEDGE,$LVS_EX_GRIDLINES))
	GUICtrlSendMsg($inspect, $LVM_SETCOLUMNWIDTH, 0, 120)
	GUICtrlSetResizing($inspect, $GUI_DOCKAUTO+$GUI_DOCKTOP)

	Dim $Trees = CreateTree($D, $inifile)

	While 1
		local $click = GUIGetMsg()
		if	$click == $GUI_EVENT_CLOSE Then TAppClose()
		TGuiHandle($hMenu,$click)
		TGuiHandle($TreeItem,$click)
	WEnd
EndFunc

Func DevMenu($file)
	Dim $hMenu[0][4]
	_ArrayAdd( $hMenu, GUICtrlCreateMenu("&File",-1)&"||")
	_ArrayAdd( $hMenu, GUICtrlCreateMenuItem("&Open",$hMenu[0][0]) &"|FileIniOpen|"&$file&"|" )
	_ArrayAdd( $hMenu, GUICtrlCreateMenuItem("&Reload",$hMenu[0][0]) &"|FileReload|"&$file&"|" )
	_ArrayAdd( $hMenu, GUICtrlCreateMenuItem("&Close",$hMenu[0][0]) &"|ClearingDev|"&"|" )
	_ArrayAdd( $hMenu, GUICtrlCreateMenuItem("",$hMenu[0][0]) &"|||"  )
	_ArrayAdd( $hMenu, GUICtrlCreateMenuItem("&Exit",$hMenu[0][0]) &"|TAppClose||" )
	_ArrayAdd( $hMenu, GUICtrlCreateMenu("&Info",-1) &"||")
	_ArrayAdd( $hMenu, GUICtrlCreateMenuItem("&About",$hMenu[6][0]) &"|About_This|"&$hDev&"|" )
EndFunc

Func CreateTree($C, $file)

	Dim $TreeItem[0][4]

	Dim $Trees = GUICtrlCreateTreeView(0, 0, $C[2]/3, $C[3] )
	GUICtrlSetResizing($Trees, $GUI_DOCKTOP)

	if $file<>'' Then

	local $section = IniReadSectionNames($file)

	local $stack = false
	local $root  = Treeing("Begin","begin",$Trees, $file)
	Treeing("End","end",$Trees, $file)
	local $parent = $root

	for $s = 2 to Ubound($section)-1

		if $stack == false Then
			$root = Treeing($section[$s],$section[$s],$root, $file)
			$parent = $root
		Else
			$root = Treeing($section[$s],$section[$s],$parent, $file)
			$stack = false
		Endif

		Dim $opt = IniReadSection($file, $section[$s])
		Dim $branch[0][2]
		local $goto = ""
		local $ctitle = ""
		for $i = 0 to Ubound($opt)-1

			local $d = StringLower($opt[$i][0])

			if $d == "next" Then $stack=true

			if $d == "spot" OR $d == "button" OR $d == "hbutton" Then
				local $ar = StringSplit($opt[$i][1],"|");
				_ArrayAdd($branch,$d&"|"&$ar[1])
			Endif

			if $d == "goto" Then $goto = $opt[$i][1]

			if $d == "condition" then
				local $ar = StringSplit($opt[$i][1],"|");
				local $ctitle = "if ("&$ar[1]&"<"&$ar[2]&") goto "&$ar[3]
			Endif

		next

		local $thisroot = $root

		if $ctitle<>'' Then
			Treeing($ctitle,$ar[3],$thisroot,$file,1,0x006600 )
		endif

		for $b = 0 to Ubound($branch)-1
			Treeing($branch[$b][0]&": "&$branch[$b][1],$branch[$b][1],$thisroot,$file, 1)
		next

		if $goto<>"" Then
			Treeing("Goto: "&$goto, $goto, $thisroot, $file, 1)
		Endif

	Next

	EndIf

	return $Trees;

EndFunc

Func Treeing($title,$node,$root,$file, $forced=0, $ccolor=0x990000)
	local $Find = _ArraySearch($TreeItem, $node, 0, 0, 0, 0, 1, 2)
	if $Find == -1 Then
		local $Item = GUICtrlCreateTreeViewItem($title, $root )
		_ArrayAdd($TreeItem, $Item &"|DevPeek|"& $node &"|"& $file )
		if ($ccolor <> 0x990000) Then GUICtrlSetColor($Item,$ccolor)
		return $Item
	Else
		local $finded = $TreeItem[$Find][0]
		if $Forced == 1 Then
			GUICtrlSetColor($finded,0x000066)
			local $Item = GUICtrlCreateTreeViewItem($title, $root )
			_ArrayAdd($TreeItem, $Item &"|DevSeek|"& $finded &"|"& $file )
			GUICtrlSetColor($Item,0x990000)
		Endif
		return $finded
	endif
EndFunc

Func TGuiHandle($handle,$click)
	local $res
	for $i = 0 to UBound($handle)-1
		if $click == $handle[$i][0] Then
			$res = Call($handle[$i][1], $handle[$i][2], $handle[$i][3] )
		Endif
	Next
	return $res
EndFunc

Func TGuiKillHandle($handle)
	local $res
	for $i = 0 to UBound($handle)-1
		GUICtrlDelete($handle[$i][0])
	Next
EndFunc

Func DevSeek($param1='',$param2='')
	GUICtrlSetState ($param1,$GUI_FOCUS)
Endfunc

Func DevPeek($param1='',$param2='')
	local $opt = IniReadSection($param2, $param1)
	for $n = 0 to Ubound($lv_disposal)-1
		GUICtrlDelete($lv_disposal[$n])
	Next
	for $i = 1 to Ubound($opt)-1
		local $Item = GUICtrlCreateListViewItem($opt[$i][0]&"|"& $opt[$i][1],$Inspect)
		_ArrayAdd( $lv_disposal, $Item )
	next
Endfunc

Func TAppClose($param1='',$param2='')
	ClearingDev()
	GUIDelete()
	Exit
EndFunc

Func ClearingDev($param1='',$param2='')
	TGuiKillHandle($Treeitem)
	GUICtrlDelete($Trees)
	GUICtrlDelete($Inspect)
Endfunc

Func FileReload($file="",$param2='')
	ClearingDev()
	DevOpen($file)
EndFunc

Func FileIniOpen($file="",$param2='')
	$file = TFileBrowse(@WorkingDir)
	ClearingDev()
	DevOpen($file)
EndFunc

Func TFileBrowse($folder='')
	if $folder=='' Then $folder=@WorkingDir

	Local $sFileOpenDialog = FileOpenDialog("Open Scenario", $folder, "All (*.ini)", $FD_FILEMUSTEXIST)
	If @error Then
		$sFileOpenDialog=''
	Else
		$sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)
	EndIf
	FileChangeDir(@WorkingDir)
	return $sFileOpenDialog
EndFunc