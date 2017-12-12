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

Func ResetParam()
	$aDisposal = ClearingGUICtrl($aDisposal)
	Dim $aBeen[0]
	Dim $dpng[0]
	Dim $scene
EndFunc

Func PackBrowse($folder)
	Local Const $sMessage = "Open ZIP Package"
	Local $sFileOpenDialog = FileOpenDialog($sMessage, $folder, "All (*.zip)", $FD_FILEMUSTEXIST)
	If @error Then
		$sFileOpenDialog=''
	Else
		FileChangeDir(@ScriptDir)
		$sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)
	EndIf

	if $sFileOpenDialog<>"" Then
		local $we = _Zip_UnzipAll($sFileOpenDialog, $PlayDir, 20+512)
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

Func Story_restart($inifile)
	PackClose()
	PackOpen($inifile)
EndFunc

