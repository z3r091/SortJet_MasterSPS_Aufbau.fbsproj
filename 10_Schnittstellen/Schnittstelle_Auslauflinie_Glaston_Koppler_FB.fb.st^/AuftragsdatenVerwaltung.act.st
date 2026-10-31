(* METADATA
{
  "v3Meta": {
    "objectGuid": "86a4b348-be43-49c3-bb2a-544e8bc38faa"
  }
}
*)
ACTION AuftragsdatenVerwaltung
(***************************************************************************************************)
(* AUFTRAGSDATENVERWALTUNG *)
(***************************************************************************************************)
(* Hinweis:
   - Auftragsdaten wurden verarbeitet - Bereit für einen weiteren Auftrag       
*)
ftlGlasBereit( CLK := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bBereitZumAustransport );

IF ( ftlGlasBereit.Q ) THEN
  BasisStationsParameter.bAuftragAktiv := FALSE;
END_IF

(* Hinweis:
    - Auslesen des naechsten Wertes aus dem FIFO (Warteschlange)
      => Schreiben auf die IO- Schnittstelle bzw. DP\DP - Schnittstelle
*)
IF (  NOT AuftragsSpeicher.bpWarteschlangeLeer
  AND NOT BasisStationsParameter.bAuftragAktiv
  AND NOT bpAuftragsdatenVorhanden )
THEN
  BasisStationsParameter.bAuftragAktiv := TRUE;
  bpAuftragsdatenVorhanden := TRUE;

  AuftragsSpeicher(bpWertAuslesen := TRUE);
  Auftragsdaten := AuftragsSpeicher.ppAusgabeWert;

END_IF

(***************************************************************************************************)
(* AUFTRAGSDATEN *)
(***************************************************************************************************)
IF ( bpAuftragsdatenVorhanden ) THEN

  (* Hinweis:
     - Lade-ID auf den Bus schreiben (Hegla V4.0: eine Lade-ID = Scheiben-ID 1, 16 ASCII- Zeichen)
  *)
  IF ( BasisStationsParameter.stMKs.stFremdanlage.bWerteSwappen ) THEN

    FOR ilIndex := 0 TO 3 DO
      adwlLadeID[ilIndex] := SWAP_DWORD_SIEMENS( dwpWert := Auftragsdaten.stScheibenID.adwScheibenID_1[ilIndex] );
    END_FOR

  ELSE
    adwlLadeID := Auftragsdaten.stScheibenID.adwScheibenID_1;
  END_IF

  SysMemCpy( ADR( out_awSenderLadeID ), ADR( adwlLadeID ), SIZEOF( out_awSenderLadeID ) );


  tonlAuftragdatenVorhanden( IN := TRUE, PT := t#500ms);
  out_bSenderAuftragdatenVorhanden := tonlAuftragdatenVorhanden.Q;


  (* Hinweis:
     - Validieren der Auftragsdaten
  *)
  IF ( in_bEmpfaengerAuftragsdatenErhalten ) THEN

      IF( SysMemCmp( ADR( out_awSenderLadeID ), ADR( in_awEmpfaengerLadeIDGespiegelt ), SIZEOF( out_awSenderLadeID ) ) = 0 )THEN
        out_bSenderAuftragdatenPlausibel := TRUE ;
      
      ELSE
        out_bSenderAuftragdatenPlausibel := FALSE ;
      
      END_IF

  END_IF

  (* Hinweis:
     - Warten das die Daten von der Fremdanlage quittiert werden
       => <blFremdanlageAuftragsdatenErhalten> Signal muss von FALSE auf TRUE und dann wieder auf FALSE wechseln
         - TRUE  : Daten werden gelesen 
         - FALSE : Daten wurden verarbeitet
  *)
  ftlFremdanlageDatenVerarbeitet(CLK:= in_bEmpfaengerAuftragsdatenErhalten );

  IF ( ftlFremdanlageDatenVerarbeitet.Q ) THEN
    bpAuftragsdatenVorhanden := FALSE;

    IF NOT out_bSenderAuftragdatenPlausibel THEN
        blFehlermeldungGenerierenAuftragsdaten := TRUE;
    END_IF

  END_IF

END_IF

IF ( NOT bpAuftragsdatenVorhanden ) THEN

  (* Hinweis:
     - Ausgaenge zurueck setzen
     - Trigger zurueck setzen
  *)
  out_bSenderAuftragdatenPlausibel := FALSE;
  out_bSenderAuftragdatenVorhanden := FALSE;

  ftlFremdanlageDatenVerarbeitet(CLK:= FALSE );
  tonlAuftragdatenVorhanden( IN := FALSE );

END_IF


(* Hinweis:
   - Fehlverhalten feststellen [Auftragsdaten]
*)
IF ( tonlZeitAuftragsdatenNichtAequivalent.Q ) THEN
  tonlZeitAuftragsdatenNichtAequivalent( IN := FALSE );

  blFehlermeldungGenerierenAuftragsdaten := TRUE;

END_IF
END_ACTION