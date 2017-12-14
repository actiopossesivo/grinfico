#include <ComboConstants.au3>
#include <Crypt.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <StaticConstants.au3>
#include <igf3-files.au3>

#pragma compile(Out, Compiled\Grendel.exe)
#pragma compile(Icon, C:\igf\1\grendel.ico)
#pragma compile(Compatibility, vista, win7, win8, win81, win10)
#pragma compile(FileDescription, Grinfico Encryptor and Decryptor)
#pragma compile(ProductName, Grinfico Grendel)
#pragma compile(ProductVersion, 0.1)
#pragma compile(Comments,'https://github.com/actiopossesivo/igfiction')

local $pk

Grende()

Func GetKey($pk)
	local $fo = FileOpen($pk)
	local $sk = FileReadLine($fo)
	FileClose($fo)
	local $igf_passkey = StringEncrypt(False, $sk, 'actiopossesivo')
	return $igf_passkey
Endfunc

Func CreateKey($pk,$ke)
	local $fo = FileOpen($pk,2)
	FileWriteLine ( $fo, StringEncrypt(True, $ke, 'actiopossesivo') )
	FileClose($fo)
	return $ke
Endfunc

Func Grende()
    Local $iAlgorithm = $CALG_AES_256 ; changing this will be change all
	local $top = 65;
    Local $hGUI = GUICreate("Grendel", 430, 300+$top)

	GUICtrlCreateLabel("Grinfico En/DeCryptor",0,0,430,60, $SS_CENTERIMAGE+$SS_CENTER )
	GUICtrlSetBkColor(-1,0x112233)
	GUICtrlSetColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1,18,700)

	GUICtrlCreateGroup("Key",5,$top+5,420,105 )

    GUICtrlCreateLabel("Passkey :", 15, $top+24, 80, 20,$SS_CENTERIMAGE)
		Local $passkey = GUICtrlCreateInput($pk, 90, $top+24, 275, 20 )
		Local $passkeyBrowse = GUICtrlCreateButton("...", 370, $top+24, 35, 20)

    GUICtrlCreateLabel("Secret :", 15, $top+48, 80, 20,$SS_CENTERIMAGE)
		Local $secret = GUICtrlCreateInput("", 90, $top+48, 275, 20)

	Local $idKey = GUICtrlCreateButton("New Passkey", 90, $top+72, 85, 25)

	; Encrypt

    GUICtrlCreateLabel( "ZIP :", 15, $top+120, 110, 20 ,$SS_CENTERIMAGE)
		Local $enZipInput = GUICtrlCreateInput("", 90, $top+120, 275 , 20 )
		Local $enZipBrowse = GUICtrlCreateButton("...", 370, $top+120, 35, 20)

    GUICtrlCreateLabel("IGF :", 15, $top+145, 85, 20,$SS_CENTERIMAGE )
		Local $enIgfInput = GUICtrlCreateInput("", 90, $top+145, 275, 20 )
		Local $enIgfBrowse = GUICtrlCreateButton("...", 370, $top+145, 35, 20 )

	Local $idEncrypt = GUICtrlCreateButton("Encrypt", 90, $top+170, 85, 25)

	; Decrypt

    GUICtrlCreateLabel( "IGF :", 15, $top+205, 110, 20 ,$SS_CENTERIMAGE)
		Local $deIgfInput = GUICtrlCreateInput("", 90, $top+205, 275 , 20 )
		Local $deIgfBrowse = GUICtrlCreateButton("...", 370, $top+205, 35, 20)

    GUICtrlCreateLabel("ZIP :", 15, $top+225, 85, 20,$SS_CENTERIMAGE )
		Local $deZipInput = GUICtrlCreateInput("", 90, $top+230, 275, 20 )
		Local $deZipBrowse = GUICtrlCreateButton("...", 370, $top+230, 35, 20 )

	Local $idDecrypt = GUICtrlCreateButton("Decrypt", 90, $top+255, 85, 25)

    GUISetState(@SW_SHOW, $hGUI)

    Local $sDestinationRead = "", $sFilePath = "", $sPasswordRead = "", $sSourceRead = ""

    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop

			Case $idKey
				local $ke = GUICtrlRead ( $secret )
				local $pk = InputBox("Grinfico De/en","New passkey file",@MyDocumentsDir&"\grinfico\newfile.key","",400)
				local $test = CreateKey($pk,$ke)
				local $pass = GetKey($pk)
				ConsoleWrite($pk&"---> "&$test&"=="&$pass&@CRLF)
				if $test <> $pass Then
					Msgbox (0,"","Key Failed!")
					GUICtrlSetData($passkey, "")
					GUICtrlSetData($secret,"")
				else
					GUICtrlSetData($passkey, $pk)
					GUICtrlSetData($secret,GetKey($pk))
				Endif

			Case $passkeyBrowse
                $sFilePath = FileOpenDialog("Select a passkey", "", "All files (*.key)") ; Select a file to encrypt.
                If @error Then
                    ContinueLoop
                EndIf
                GUICtrlSetData($passkey, $sFilePath) ;
				GUICtrlSetData($secret,GetKey($sFilePath))

            Case $enZipBrowse
                $sFilePath = FileOpenDialog("Select a file to encrypt.", "", "All files (*.zip)") ; Select a file to encrypt.
                If @error Then
                    ContinueLoop
                EndIf
                GUICtrlSetData($enZipInput, $sFilePath) ; Set the inputbox with the filepath.

            Case $enIgfBrowse
                $sFilePath = FileSaveDialog("Encrypt file as ...", "", "All files (*.igf)") ; Select a file to save the encrypted data to.
                If @error Then
                    ContinueLoop
                EndIf
                GUICtrlSetData($enIgfInput, $sFilePath) ; Set the inputbox with the filepath.

			Case $deIgfBrowse
                $sFilePath = FileOpenDialog("Select a file to decrypt.", "", "All files (*.igf)") ; Select a file to encrypt.
                If @error Then
                    ContinueLoop
                EndIf
                GUICtrlSetData($deIgfInput, $sFilePath) ; Set the inputbox with the filepath.

            Case $deZipBrowse
                $sFilePath = FileSaveDialog("Decrypt file as ...", "", "All files (*.zip)") ; Select a file to save the encrypted data to.
                If @error Then
                    ContinueLoop
                EndIf
                GUICtrlSetData($deZipInput, $sFilePath) ; Set the inputbox with the filepath.

            Case $idEncrypt
                $sSourceRead = GUICtrlRead($enZipInput) ; Read the source filepath input.
                $sDestinationRead = GUICtrlRead($enIgfInput) ; Read the destination filepath input.
                $sPasswordRead = GUICtrlRead($secret) ; Read the password input.
                If StringStripWS($sSourceRead, $STR_STRIPALL) <> "" And StringStripWS($sDestinationRead, $STR_STRIPALL) <> "" And StringStripWS($sPasswordRead, $STR_STRIPALL) <> "" And FileExists($sSourceRead) Then ; Check there is a file available to encrypt and a password has been set.
                    If _Crypt_EncryptFile($sSourceRead, $sDestinationRead, $sPasswordRead, $iAlgorithm) Then ; Encrypt the file.
                        MsgBox($MB_SYSTEMMODAL, "Success", "Operation succeeded.")
                    Else
                        Switch @error
                            Case 1
                                MsgBox($MB_SYSTEMMODAL, "Error", "Failed to create the key.")
                            Case 2
                                MsgBox($MB_SYSTEMMODAL, "Error", "Couldn't open the source file.")
                            Case 3
                                MsgBox($MB_SYSTEMMODAL, "Error", "Couldn't open the destination file.")
                            Case 4 Or 5
                                MsgBox($MB_SYSTEMMODAL, "Error", "Encryption error.")
                        EndSwitch
                    EndIf
                Else
                    MsgBox($MB_SYSTEMMODAL, "Error", "Please ensure the relevant information has been entered correctly.")
                EndIf

            Case $idDecrypt
                $sSourceRead = GUICtrlRead($deIgfInput) ; Read the source filepath input.
                $sDestinationRead = GUICtrlRead($deZipInput) ; Read the destination filepath input.
                $sPasswordRead = GUICtrlRead($secret) ; Read the password input.
                If StringStripWS($sSourceRead, $STR_STRIPALL) <> "" And StringStripWS($sDestinationRead, $STR_STRIPALL) <> "" And StringStripWS($sPasswordRead, $STR_STRIPALL) <> "" And FileExists($sSourceRead) Then ; Check there is a file available to decrypt and a password has been set.
                    If _Crypt_DecryptFile($sSourceRead, $sDestinationRead, $sPasswordRead, $iAlgorithm) Then ; Decrypt the file.
                        MsgBox($MB_SYSTEMMODAL, "Success", "Operation succeeded.")
                    Else
                        Switch @error
                            Case 1
                                MsgBox($MB_SYSTEMMODAL, "Error", "Failed to create the key.")
                            Case 2
                                MsgBox($MB_SYSTEMMODAL, "Error", "Couldn't open the source file.")
                            Case 3
                                MsgBox($MB_SYSTEMMODAL, "Error", "Couldn't open the destination file.")
                            Case 4 Or 5
                                MsgBox($MB_SYSTEMMODAL, "Error", "Decryption error.")
                        EndSwitch
                    EndIf
;                Else
;                    MsgBox($MB_SYSTEMMODAL, "Error", "Please ensure the relevant information has been entered correctly.")
                EndIf


        EndSwitch
    WEnd

    GUIDelete($hGUI) ; Delete the previous GUI and all controls.
EndFunc   ;==>Example
