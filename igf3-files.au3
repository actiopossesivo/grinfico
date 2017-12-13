Func RunOnce()

	if Not FileExists(@Scriptdir&"/prop") Then DirCreate(@Scriptdir&"/prop")

	if Not FileExists(@ScriptDir&"\prop\scorebar.png") Then FileInstall("1\scorebar.pn_",@ScriptDir&"\prop\scorebar.png",0)
	if Not FileExists(@ScriptDir&"\prop\grinfico.jpg") Then FileInstall("1\grinfico.jp_",@ScriptDir&"\prop\grinfico.jpg",0)
	if Not FileExists(@ScriptDir&"\prop\dialog.png") Then FileInstall("1\dialog.pn_",@ScriptDir&"\prop\dialog.png",0)
	if Not FileExists(@ScriptDir&"\prop\Clear Sans.ttf") Then FileInstall("1\Clear Sans.tt_",@ScriptDir&"\prop\Clear Sans.ttf",0)
	if Not FileExists(@ScriptDir&"\prop\global.ini") Then FileInstall("1\global.in_",@ScriptDir&"\prop\global.ini",0)

	if Not FileExists(@TempDir&"\grinfico") Then
		DirCreate(@TempDir&"\grinfico")
	Else
		DirRemove(@TempDir&"\grinfico",1)
		DirCreate(@TempDir&"\grinfico")
	EndIf

	Dim $Playdir = @TempDir&"\grinfico"

	if Not FileExists(@MyDocumentsDir&"\grinfico") Then DirCreate(@MyDocumentsDir&"\grinfico")
	FileInstall("1\possesive_pose.ke_",@MyDocumentsDir&"\grinfico\possesive_pose.key",0)

	if Not FileExists(@MyDocumentsDir&"\grinfico\pack") Then DirCreate(@MyDocumentsDir&"\grinfico\pack")
	if Not FileExists(@MyDocumentsDir&"\grinfico\saved") Then DirCreate(@MyDocumentsDir&"\grinfico\saved")

	LoadConfig(@ScriptDir&"\prop\global.ini",1)

EndFunc

func igf_keylist()
	$root = GetMenuGui('keys')
	Dim $hKey[0]
	local $n=0
	$aKeys = _FileListToArray (@MyDocumentsDir&"\grinfico","*.key")
	for $k = 1 to Ubound($aKeys)-1
		local $fname = StringSplit($aKeys[$k],".")
		local $keymenu = GUICtrlCreateMenuItem($fname[1],$root);
		_ArrayAdd( $hMenu, "key"&$k &"|"& $keymenu &"|"&"SetKey"&"|"& "key"&$k &"="& $aKeys[$k] )
		_ArrayAdd ($hKey, $keymenu);
	next
Endfunc

Func SetKey($s)
	for $i= 0 to Ubound($hKey)-1
		GUICtrlSetState($hKey[$i],$GUI_UNCHECKED)
	Next
	local $n = StringSplit($s,"=")
	local $sn = GetMenuGUI($n[1])
	GUICtrlSetState($sn,$GUI_CHECKED)
	local $fo = FileOpen(@MyDocumentsDir&"\grinfico\"&$n[2])
	local $sk = FileReadLine($fo)
	FileClose($fo)
	Dim $igf_passkey = StringEncrypt(False, $sk, 'actiopossesivo')
	if @Compiled==0 Then ConsoleWrite("key"&@TAB&"= "&$igf_passkey&@CRLF)
EndFunc

#cs
Row|Col 0|Col 1|Col 2|Col 3
[0]|file|3||
[1]|open|6|PackBrowse|C:\Users\Ta Coen\Documents\grinfico\pack
[2]|close|7|PackClose|
[3]||8||
[4]|keys|9|Keys|
[5]||10||
[6]|exit|11|AppClose|
[7]||4||
[8]|load|12|Story_load|C:\Users\Ta Coen\Documents\grinfico\saved
[9]|save|13|Story_save|C:\Users\Ta Coen\Documents\grinfico\saved
[10]|restart|14|Story_restart|
[11]||5||
[12]|about|15|About_This|
[13]|key1|16|SetKey|key1=possesive_pose.key
[14]|key2|17|SetKey|key2=taikucing.key
#ce

func igf_menus($file)
	Dim $hMenu[0][4]
	local $menu_file = GUICtrlCreateMenu("&File",-1)
	local $menu_book = GUICtrlCreateMenu("&Story",-1)
	local $menu_help = GUICtrlCreateMenu("&Info",-1)
	_ArrayAdd( $hMenu, "file"&"|"& $menu_file &"|"& "" &"|"& "" )
	_ArrayAdd( $hMenu, "open"&"|"& GUICtrlCreateMenuItem("&Open",$menu_file)&"|"&"PackBrowse"&"|"& @MyDocumentsDir&"\grinfico\pack")
	_ArrayAdd( $hMenu, "close"&"|"& GUICtrlCreateMenuItem("&Close",$menu_file)&"|"&"PackClose"&"|"& "" )
	_ArrayAdd( $hMenu, ""&"|"& GUICtrlCreateMenuItem("",$menu_file)&"|"&""&"|"& "" )
	_ArrayAdd( $hMenu, "keys"&"|"& GUICtrlCreateMenu("&Keys",$menu_file)&"|"&"Keys"&"|"& "" )
	_ArrayAdd( $hMenu, ""&"|"& GUICtrlCreateMenuItem("",$menu_file)&"|"&""&"|"& "" )
	_ArrayAdd( $hMenu, "exit"&"|"& GUICtrlCreateMenuItem("E&xit",$menu_file)&"|"&"AppClose"&"|"& "" )
	_ArrayAdd( $hMenu, "" &"|"& $menu_book &"|"& "" &"|"& "" )
	_ArrayAdd( $hMenu, "load" &"|"& GUICtrlCreateMenuItem("&Load",$menu_book)&"|"&"Story_load"&"|"& @MyDocumentsDir&"\grinfico\saved" )
	_ArrayAdd( $hMenu, "save" &"|"& GUICtrlCreateMenuItem("&Save",$menu_book)&"|"&"Story_save"&"|"& @MyDocumentsDir&"\grinfico\saved" )
	_ArrayAdd( $hMenu, "restart" &"|"& GUICtrlCreateMenuItem("&Restart",$menu_book)&"|"&"Story_restart"&"|"& $file )
	_ArrayAdd( $hMenu, "" &"|"& $menu_help &"|"& "" &"|"& "" )
	_ArrayAdd( $hMenu, "about" &"|"& GUICtrlCreateMenuItem("&About",$menu_help)&"|"&"About_This"&"|"& "" )
	igf_keylist()
	return $hMenu
EndFunc

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
		local $res = FP_deCrypt($sFileOpenDialog)
		if $res == true Then
			local $we = _Zip_UnzipAll($Playdir&"\_play.zip", $PlayDir, 20+512)
			PackOpen($PlayDir&"\scenario.ini")
		Endif
	Endif
EndFunc

Func PackOpen($file)
	Dim $inifile = $file
	FileChangeDir(GetDir($inifile));
	GUICtrlSetState(GetMenuGUI('save'),$GUI_ENABLE)
	GUICtrlSetState(GetMenuGUI('load'),$GUI_ENABLE)
	GUICtrlSetState(GetMenuGUI('restart'),$GUI_ENABLE)
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
	local $stamp = @YEAR&@MON&@MDAY&@HOUR&@MIN&@SEC

	; Data Collecting

	for $i=0 to Ubound($aBeen)-1
		$sbeen = $sbeen & $aBeen[$i] & ","
	Next

	$sbeen = StringTrimRight($sbeen,1)

	for $i=0 to Ubound($aScore)-1
		_ArrayAdd($data, $aScore[$i][0] &"|"& $aScore[$i][2] )
	Next

	_ArrayAdd($data, "been" &"|"& $sbeen)
	_ArrayAdd($data, "section" &"|"& $Last_Section)
	_ArrayAdd($data, "stamp" &"|"& $stamp)

	$save_file = FilesaveDialog("Grinfico - Saved Files", @MyDocumentsDir&"\grinfico\saved" ,"All (*."&$key&".ini)", $FD_PATHMUSTEXIST+$FD_PROMPTOVERWRITE)

	if $save_file <> "" Then
		local $r= IniWriteSection ($save_file, "data", $data,0 )
	Endif

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
		local $aS

		; populated data

		PackClose()
		Init_Scorebar()
		for $i= 0 to Ubound($aScore)-1
			local $s = $aScore[$i][0];
			local $n = _ArraySearch($data,$s)
			Scoring("set",$s,$data[$n][1])
		Next

		For $i=1 to Ubound($data)-1
			if $data[$i][0] == "been" Then Dim $aBeen = StringSplit($data[$i][1],",")
			if $data[$i][0] == "section" Then $goto = $data[$i][1]
		Next

		FileChangeDir(GetDir($inifile));
		Init_PlayArea()
		GUICtrlSetState($hPA, $GUI_FOCUS)
		ReSize()
		SectionThread($goto)

	Endif
EndFunc

Func FP_deCrypt($sSourceRead)
	local $res
	If _Crypt_DecryptFile($sSourceRead, $PlayDir&"\_play.zip", $igf_passkey , $CALG_AES_256) Then ; Decrypt the file.
		$res=true
	Else
		$res=false
		Switch @error
			Case 1
				MsgBox($MB_SYSTEMMODAL, "Grinfico - Error", "Failed to create the key.")
			Case 2
				MsgBox($MB_SYSTEMMODAL, "Grinfico - Error", "Couldn't open the source file.")
			Case 3
				MsgBox($MB_SYSTEMMODAL, "Grinfico - Error", "Couldn't open the destination file.")
			Case 4 Or 5
				MsgBox($MB_SYSTEMMODAL, "Grinfico - Error", "Decryption error.")
		EndSwitch
	EndIf
	return $res
Endfunc

Func StringEncrypt($bEncrypt, $sData, $sPassword)
	_Crypt_Startup() ; Start the Crypt library.
	Local $sReturn = ''
	If $bEncrypt Then ; If the flag is set to True then encrypt, otherwise decrypt.
		$sReturn = _Crypt_EncryptData($sData, $sPassword, $CALG_AES_128)
	Else
		$sReturn = BinaryToString(_Crypt_DecryptData($sData, $sPassword, $CALG_AES_128))
	EndIf
	_Crypt_Shutdown() ; Shutdown the Crypt library.
	Return $sReturn
EndFunc