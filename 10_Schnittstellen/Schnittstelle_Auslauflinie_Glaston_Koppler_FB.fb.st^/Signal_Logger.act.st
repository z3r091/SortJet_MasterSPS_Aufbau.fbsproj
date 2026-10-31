(* METADATA
{
  "v3Meta": {
    "objectGuid": "ff5f9f2b-b260-4559-82ff-659fa60e9f74"
  }
}
*)
ACTION Signal_Logger
(***************************************************************************************************)
(* SIGNALLOGGER *)
(***************************************************************************************************)
// Bei Signalwechsel Daten ins Log schreiben

// Eingangsignale
IF in_wEmpfaengerSignale <> wlTempEmpfaengerSignale THEN
  wlTempEmpfaengerSignale := in_wEmpfaengerSignale;
  blInLogSchreiben := TRUE;
END_IF

IF blInLogSchreiben THEN

  slInLogString := CONCAT(WORD_TO_STRING(BasisStationsParameter.stMKs.stStationsNummern.NummerExtern), ' Fremd 49.0 Erhalten: ');
  slInLogString := CONCAT(slInLogString, BOOL_TO_STRING(in_bEmpfaengerAuftragsdatenErhalten) );
  slInLogString := CONCAT(slInLogString, ': ');
  slInLogString := CONCAT(slInLogString, '49.1 Bereit: ');
  slInLogString := CONCAT(slInLogString, BOOL_TO_STRING(in_bEmpfaengerBereitZumEintransport) );

  SpsLogString(slInLogString);

  blInLogSchreiben := FALSE;
END_IF


// Ausganssignale
IF out_wSenderSignale <> wlTempSenderSignale THEN
  wlTempSenderSignale := out_wSenderSignale;
  blOutLogSchreiben := TRUE;
END_IF

IF blOutLogSchreiben THEN

  slOutLogString := CONCAT(WORD_TO_STRING(BasisStationsParameter.stMKs.stStationsNummern.NummerExtern), ' HE 50.0 Dat: ');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(out_bSenderAuftragdatenVorhanden) );
  slOutLogString := CONCAT(slOutLogString, ': ');
  slOutLogString := CONCAT(slOutLogString, '50.1 Plaus: ');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(out_bSenderAuftragdatenPlausibel) );
  slOutLogString := CONCAT(slOutLogString, ': ');
  slOutLogString := CONCAT(slOutLogString, '50_4: Glas');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(blSenderGlasBereit) );

  SpsLogString(slOutLogString);

  blOutLogSchreiben := FALSE;
END_IF
END_ACTION