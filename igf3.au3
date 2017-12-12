#NoTrayIcon
#include <igf3-function.au3>
#include <igf3-routine.au3>

#pragma compile(Out, Grinfico.exe)
#pragma compile(Icon, C:\igf\1\icon.ico)
#pragma compile(Compatibility, vista, win7, win8, win81, win10)
#pragma compile(FileDescription, an Interactive Fictions Engine)
#pragma compile(ProductName, Grinfinco)
#pragma compile(ProductVersion, 1.3)
#pragma compile(Comments,'https://github.com/actiopossesivo/igfiction')

Global $hWin
Global $hPA
Global $hSB
Global $hMenu[0][3]
Global $aDimension[0][5]
Global $aSize[0][3]
Global $aConf[0][2]
Global $aScore[0][5]
Global $aBeen[0]
Global $aDisposal[0]
Global $dpng[0]
Global $scene
Global $Playdir
Global $Last_Section = ''

OnAutoItExitRegister ( "igf_cleanup" )

RunOnce()

Global $inifile

; Shift+F8 To Emulate $cmdline[1]
; C:\IGF\new2\scenario.ini
; @ScriptDir&"\new2\scenario.ini"

if $CmdLine[0]>0 Then
	$inifile = $CmdLine[1]
Endif

Init_Win($inifile)

if ($inifile <> "") Then PackOpen($inifile)

GUI_Function("")

Exit

Func Igf_cleanup()
	DirRemove($Playdir,1)
Endfunc


Func PackBrowse($folder)
	Local $sFileOpenDialog = FileOpenDialog("Open IGF", $folder, "All (*.igf)", $FD_FILEMUSTEXIST)
	If @error Then
		$sFileOpenDialog=''
	Else
		FileChangeDir(@ScriptDir)
		$sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)
	EndIf

	if $sFileOpenDialog<>"" Then
		FP_deCrypt($sFileOpenDialog)
		local $we = _Zip_UnzipAll($Playdir&"\_play.zip", $PlayDir, 20+512)
		;ConsoleWrite($we & " -- "& $sFileOpenDialog &"->"& $Playdir &@CRLF)
		PackOpen($PlayDir&"\scenario.ini")
	Endif
EndFunc

Func PackOpen($file)
	Dim $inifile = $file
	FileChangeDir(GetDir($inifile));
	LoadConfig($inifile);
	ResetParam()
	Init_Scorebar()
	Init_PlayArea()
	ReSize()
	WelcomeTitle()
	SectionThread("begin")
EndFunc

Func PackClose()
	ResetParam()
	GUIDelete($hSB)
	GUIDelete($hPA)
EndFunc

Func Story_restart($file)
	if $file == "" Then $file = $inifile
	PackClose()
	PackOpen($file)
EndFunc

Func Story_save()
	local $key = GetConf('keyword');
	local $data[0][2]
	local $sbeen;

	; Data Collecting

	for $i=0 to Ubound($aBeen)-1
		$sbeen = $sbeen & $aBeen[$i] & ","
	Next

	$sbeen = StringTrimRight($sbeen,1)

	for $i=0 to Ubound($aScore)-1
		ConsoleWrite($aScore[$i][0]&@CRLF)
		_ArrayAdd($data, $aScore[$i][0] &"|"& $aScore[$i][2] )
	Next

	local $stamp = @YEAR&@MON&@MDAY&@HOUR&@MIN&@SEC

	_ArrayAdd($data, "been" &"|"& $sbeen)
	_ArrayAdd($data, "section" &"|"& $Last_Section)
	_ArrayAdd($data, "Stamp" &"|"& $stamp)

	$save_file = FilesaveDialog("Grinfico - Saved Files", @MyDocumentsDir&"\grinfico\saved" ,"All (*."&$key&".ini)", $FD_PATHMUSTEXIST+$FD_PROMPTOVERWRITE)

	local $r= IniWriteSection ($save_file, "data", $data,0 )
	;if $r<>1 Then MsgBox(0,'',"Error in saving")

	FileChangeDir(GetDir($inifile));


EndFunc

Func Story_load()
	local $key = GetConf('keyword');

	Local $sFileOpenDialog = FileOpenDialog("Open Savefile", @MyDocumentsDir&"\grinfico\saved", "All (*."&$key&".ini)", $FD_FILEMUSTEXIST)
	If @error Then
		$sFileOpenDialog=''
	Else
		$sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)
	EndIf
	if $sFileOpenDialog<>"" Then
		local $data = IniReadSection($sFileOpenDialog,"data")

		; populated data
#cs
Row|Col 0|Col 1|Col 2
[0]|3||
[1]|6|PackBrowse|C:\Users\Ta Coen\Documents\grinfico\pack
[2]|7|PackClose|
[3]|8|KeyFold|
[4]|9||
[5]|10|AppClose|
[6]|4||
[7]|11|Story_load|
[8]|12|Story_save|
[9]|13|Story_restart|C:\IGF\new2\scenario.ini
[10]|5||
[11]|14|About_This|
#ce

		PackClose()

		Init_Scorebar()

		local $aS
		for $i= 0 to Ubound($aScore)-1
			local $s = $aScore[$i][0];
			local $n = _ArraySearch($data,$s)
			Scoring("set",$s,$data[$n][1])
			ConsoleWrite($n &"-->"* $i&@CRLF)
		Next

		DebugArray($aScore)

		For $i=1 to Ubound($data)-1
			;Scoring("set",$data[$i][0],$data[$i][1]) ; will skip not score?
			if $data[$i][0] == "been" Then Dim $aBeen = StringSplit($data[$i][1],",")
			if $data[$i][0] == "section" Then $goto = $data[$i][1]
		Next

		;_ArrayDisplay($data)
		FileChangeDir(GetDir($inifile));
		Init_PlayArea()
		GUICtrlSetState($hPA, $GUI_FOCUS)
		ReSize()
		SectionThread($goto)


	Endif
EndFunc
