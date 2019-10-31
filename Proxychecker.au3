#Include <IE.au3>
#include <MsgBoxConstants.au3>
#include <InetConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <File.au3>
#include <Array.au3>

Global $sFilePath = @ScriptDir & "\GoodProxys.txt"



Proxyliste()
Global $i=0

_BrowserClose()
Disable()
Sleep(1000)
Sleep(2000)

Func Proxyliste()
    ; Read the current script file into an array using the filepath.
    Global $sProxy = FileReadToArray("Proxycheckliste.txt")
   Global $iLineCount = @extended
    Global $Anzahl = UBound($sProxy)

    If @error Then MsgBox($MB_SYSTEMMODAL, "", "There was an error reading the file. @error: " & @error & "  Bitte erstelle ein Proxycheckliste.txt Datei im selben Ordner wie das das Programm.") ; An error occurred reading the current script file
	   if $Anzahl = 0 Then Exit
	EndFunc   ;==>Example

	Func Enable()
; Enable Proxy
;ConsoleWrite("Enable")
RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable", "REG_DWORD", 1)
RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer", "REG_SZ", $sProxy[$i])
RefreshIE()
EndFunc
Func Disable()
; Disable Proxy
ConsoleWrite("Disable"& @CRLF)
RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable", "REG_DWORD", 0)
RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer")
RefreshIE()
EndFunc

ConsoleWrite("Working Proxys:" & @CRLF)
While 1
   Local $oIE = _IECreate() ;muss da sein sonnst keine ip änderung
   ;ConsoleWrite($sProxy[$i])
Enable()
Sleep(3000)
_IENavigate($oIE, "https://canyouseeme.org/")

if WinGetTitle("[ACTIVE]") == "Open Port Check Tool -- Verify Port Forwarding on Your Router - Internet Explorer" Then
   ;MsgBox(0,"weiter","geht")
   ConsoleWrite($sProxy[$i] & @CRLF)
    $f=FileOpen($sFilePath, 1)
    FileWriteLine($f,$sProxy[$i]& @CRLF )
    FileClose($f)
   EndIf
;MsgBox(0,"weiter","weiter")
_BrowserClose()
$i = $i+1
if ($i == $Anzahl ) then
   Disable()
   exit
   EndIf
WEnd

Func RefreshIE()
    DllCall('WININET.DLL', 'long', 'InternetSetOption', 'int', 0, 'long', 39, 'str', 0, 'long', 0)
    DllCall('WININET.DLL', 'long', 'InternetSetOption', 'int', 0, 'long', 37, 'str', 0, 'long', 0)
 EndFunc


 Func _BrowserClose()
    Local $aList = 0
    Local $aProcesses = StringSplit('iexplore.exe|firefox.exe|safari.exe|opera.exe', '|', $STR_NOCOUNT) ; Multiple processes
    For $i = 0 To UBound($aProcesses) - 1
        $aList = ProcessList($aProcesses[$i])
        If $aList[0][0] > 0 Then ; An array is returned and @error is NEVER set, so lets check the count.
;~         _ArrayDisplay($aList)
            Local $bIsProcessClosed = False ; Declare a variable to hold a boolean.
            For $j = 1 To $aList[0][0]
                $bIsProcessClosed = ProcessClose($aList[$j][1]) ; In AutoIt 0 or 1 can be considered boolean too. It's like a bit in SQL or in C, where 1 and 0 means true or false.
                If Not $bIsProcessClosed Then ConsoleWrite('CLOSE ERROR PID: ' & $aList[$j][1] & @CRLF)
            Next
        EndIf
    Next
 EndFunc   ;==>_BrowserClose



