(* METADATA
{
	"v3Meta": {
		"objectGuid": "5f1f0da8-cf3b-48f8-8847-27368cceb88c"
	}
}
*)
ACTION AuftragsdatenVerwaltung
(***************************************************************************************************)
(* AUFTRAGSDATENVERWALTUNG *)
(***************************************************************************************************)

(* Hinweis:
   - Auftragsdaten nochmal an die HMI melden nach einer Stopp-Start- Situation  
*)
rtlAutomatikActiv(CLK := bpSortierungInAutomatik );

IF ( rtlAutomatikActiv.Q ) THEN

  IF  ( blFremdanlageBereitZumTransport ) THEN 
    rtlAuftragsdatenPlausibel( CLK := FALSE ); 
  END_IF

END_IF



(* Hinweis:
   - Auftragsdaten werden zurueck auf die Schnittstelle geschrieben. Der Glas-Sender wird nun
     die gespiegelten Daten validierung  
*)
IF ( in_bSenderAuftragdatenVorhanden
  AND NOT in_bsenderAuftragdatenPlausibel )
THEN
  out_stEmpfaengerAuftragsdatenGespiegelt := in_stSenderAuftragsdaten;
  out_bEmpfaengerAuftragsdatenErhalten    := TRUE;

END_IF


(* Hinweis:
   - Die gespiegelten Daten sind gleich und koennen nun verarbeitet werden  
*)
rtlAuftragsdatenPlausibel( CLK := in_bsenderAuftragdatenPlausibel );

IF ( rtlAuftragsdatenPlausibel.Q ) THEN


  (* Hinweis:
     - Drehen der Bytes auf Grund der Sendereihenfolge [Sender => Siemens- PLC] 
  *)
  FOR ilIndex := 0 TO 3 DO
    Auftragsdaten.stScheibenID.adwScheibenID_1[ilIndex] := SWAP_DWORD_SIEMENS(dwpWert := in_stSenderAuftragsdaten.adwScheibenID_1[ilIndex] );
    Auftragsdaten.stScheibenID.adwScheibenID_2[ilIndex] := SWAP_DWORD_SIEMENS(dwpWert := in_stSenderAuftragsdaten.adwScheibenID_2[ilIndex] );
    Auftragsdaten.stScheibenID.adwScheibenID_3[ilIndex] := SWAP_DWORD_SIEMENS(dwpWert := in_stSenderAuftragsdaten.adwScheibenID_3[ilIndex] );
    Auftragsdaten.stScheibenID.adwScheibenID_4[ilIndex] := SWAP_DWORD_SIEMENS(dwpWert := in_stSenderAuftragsdaten.adwScheibenID_4[ilIndex] );
    Auftragsdaten.stScheibenID.adwScheibenID_5[ilIndex] := SWAP_DWORD_SIEMENS(dwpWert := in_stSenderAuftragsdaten.adwScheibenID_5[ilIndex] );
    Auftragsdaten.stScheibenID.adwScheibenID_6[ilIndex] := SWAP_DWORD_SIEMENS(dwpWert := in_stSenderAuftragsdaten.adwScheibenID_6[ilIndex] );
  END_FOR

  Auftragsdaten.wScheibenAnzahl := in_wSenderAnzahlScheiben;

  out_bEmpfaengerAuftragsdatenErhalten := FALSE;
  blAuftragsdatenNachrichtGenerieren   := TRUE;

END_IF


(* Hinweis:
   - Daten auf der Schnittstelle zuruecksetzen  
*)
ftlAuftragsdatenVorhanden( CLK := in_bSenderAuftragdatenVorhanden );

IF ( ftlAuftragsdatenVorhanden.Q ) THEN
  out_stEmpfaengerAuftragsdatenGespiegelt := NullReferenzAuftragsdatenFremdanlage.stScheibenID;
END_IF



(* Hinweis:
   - Auftragsdaten an die HMI senden
*)
IF ( blAuftragsdatenNachrichtGenerieren ) THEN

  blAuftragsdatenNachrichtGenerieren := FALSE;

  IF ( Auftragsdaten.wScheibenAnzahl <= 3 ) THEN

    wSps2Mmi_SationsNummer      := stStationsNummern.NummerSPS;
    wSps2Mmi_NachrichtenIndex   := 1;
    wSps2Mmi_NachrichtenAnzahl  := 1;
    wSps2Mmi_AnzahlScheiben     := Auftragsdaten.wScheibenAnzahl;
    adwSps2Mmi_Daten_1          := Auftragsdaten.stScheibenID.adwScheibenID_1;
    adwSps2Mmi_Daten_2          := Auftragsdaten.stScheibenID.adwScheibenID_2;
    adwSps2Mmi_Daten_3          := Auftragsdaten.stScheibenID.adwScheibenID_3;

    MsgToMmi(auftragsnr_w := SB0_SPS_SCHNITTSTELLENDATENFREMDANLAGE );

  ELSE

    wSps2Mmi_SationsNummer      := stStationsNummern.NummerSPS;
    wSps2Mmi_NachrichtenIndex   := 1;
    wSps2Mmi_NachrichtenAnzahl  := 2;
    wSps2Mmi_AnzahlScheiben     := Auftragsdaten.wScheibenAnzahl;
    adwSps2Mmi_Daten_1          := Auftragsdaten.stScheibenID.adwScheibenID_1;
    adwSps2Mmi_Daten_2          := Auftragsdaten.stScheibenID.adwScheibenID_2;
    adwSps2Mmi_Daten_3          := Auftragsdaten.stScheibenID.adwScheibenID_3;

    MsgToMmi(auftragsnr_w := SB0_SPS_SCHNITTSTELLENDATENFREMDANLAGE );


    wSps2Mmi_SationsNummer      := stStationsNummern.NummerSPS;
    wSps2Mmi_NachrichtenIndex   := 2;
    wSps2Mmi_NachrichtenAnzahl  := 2;
    wSps2Mmi_AnzahlScheiben     := Auftragsdaten.wScheibenAnzahl;
    adwSps2Mmi_Daten_1          := Auftragsdaten.stScheibenID.adwScheibenID_4;
    adwSps2Mmi_Daten_2          := Auftragsdaten.stScheibenID.adwScheibenID_5;
    adwSps2Mmi_Daten_3          := Auftragsdaten.stScheibenID.adwScheibenID_6;

    MsgToMmi(auftragsnr_w := SB0_SPS_SCHNITTSTELLENDATENFREMDANLAGE );

  END_IF

END_IF
END_ACTION