#NoTrayIcon
#include <igf3-function.au3>
#include <igf3-files.au3>
#include <igf3-routine.au3>

#pragma compile(Out, compiled\Grinfico.exe)
#pragma compile(Icon, C:\igf\1\icon.ico)
#pragma compile(Compatibility, vista, win7, win8, win81, win10)
#pragma compile(FileDescription, an Interactive Fictions Engine)
#pragma compile(ProductName, Grinfico)
#pragma compile(ProductVersion, 1.4)
#pragma compile(Comments,'https://github.com/actiopossesivo/igfiction')

Global $hWin
Global $hPA
Global $hSB
Global $hMenu[0][4]
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
Global $igf_passkey
Global $hKey[0]

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
