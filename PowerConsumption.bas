'--------------------------------------------------------------
'                   Thomas Jensen | uCtrl.net
'--------------------------------------------------------------
'  file: AVR_POWER_CONSUMPTION_v.1.0
'  date: 27/04/2007
'--------------------------------------------------------------
$regfile = "attiny2313.dat"
$crystal = 8000000
$baud = 9600
Config Portb.0 = Input
Config Portb.1 = Output
Config Portb.2 = Output


Dim Serialcharwaiting As Byte , Serialchar As Byte
Dim Is_active As Bit , W As Long , Kw As Long
Dim Lifesignal As Integer , Led_timer As Integer
Dim Set_kw As Long , Kw_prev As Long , Pval As Integer
Dim Eeprom As Eram Long , Eeprom2 As Eram Long , Eeprom_timer As Integer

Print "PCMU v.1.0"
Print "uCtrl Development 0704001"
Print
Print "Press 0 for help"
Print

Kw = Eeprom
W = Eeprom * 500
Kw_prev = Eeprom2

Top:
Serialcharwaiting = Ischarwaiting()

If Serialcharwaiting = 1 Then
   Serialchar = Inkey()
      Goto Myroutine
   End If

Goto Main

Myroutine:
Select Case Serialchar
Case 49
Print Kw ; " kW current usage (" ; W ; " pulses)"
Case 50
Print Kw_prev ; " kW previous usage"
Case 51
Goto Set_value
Case 52
Goto Reset_value
Case 48
Print "1 - Current usage"
Print "2 - Previous usage"
Print "3 - Enter starting point"
Print "4 - Move current to previous"
End Select



Main:
'count
If Pinb.0 = 0 And Is_active = 0 Then
   Is_active = 1
   Incr W
   Kw = W / 500
   Led_timer = 51
   If Eeprom_timer = 0 Then Eeprom_timer = 1801
   End If
If Pinb.0 = 1 Then Is_active = 0

'led_timer
If Led_timer > 0 Then Decr Led_timer
If Led_timer = 50 Then Portb.2 = 1
If Led_timer = 0 Then Portb.2 = 0

'lifesignal
If Lifesignal > 0 Then Decr Lifesignal
If Lifesignal = 500 Then Portb.1 = 1
If Lifesignal = 0 Then
   Portb.1 = 0
   If Eeprom_timer > 0 Then Decr Eeprom_timer
   If Eeprom_timer = 1 Then
      Eeprom = Kw
      Eeprom2 = Kw_prev
      End If
   Lifesignal = 2001
   End If

Waitms 1
Goto Top
End

Set_value:
Print
Print "Current usage will be deleted! (0 to cancel)"
Input "Enter starting point in kW : " , Set_kw
If Set_kw = 0 Then
   Print "Operation aborted"
   Goto Main
   End If
W = Set_kw * 500
Kw = Set_kw
Print Kw ; " kW saved"
Goto Main
End

Reset_value:
Kw_prev = Kw
Kw = 0
W = 0
Print Kw_prev ; " kW moved to previous"
Goto Main
End