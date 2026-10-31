(* METADATA
{
  "v3Meta": {
    "objectGuid": "f52d17e5-da1d-48ff-94ba-7591f9f34af9"
  }
}
*)
ACTION Signal_Logger
(***************************************************************************************************)
(* SIGNALLOGGER *)
(***************************************************************************************************)
// Bei Signalwechsel Daten ins Log schreiben

// Eingangsignale
IF   ( blTempSenderGlasBereit <> in_bGlasAufgestellt) THEN
  blTempSenderGlasBereit := in_bGlasAufgestellt;
  blInLogSchreiben    := TRUE;
END_IF

IF blInLogSchreiben THEN

  slInLogString := CONCAT(WORD_TO_STRING(BasisStationsParameter.stMKs.stStationsNummern.NummerExtern), ' Aufgestellt: ');
  slInLogString := CONCAT(slInLogString, BOOL_TO_STRING(in_bGlasAufgestellt) );
  
  SpsLogString(slInLogString);

  blInLogSchreiben := FALSE;
END_IF


// Ausganssignale
IF  ( out_bBereitZumAufstellen <> blTempGlasAbruf ) THEN
  blTempGlasAbruf     := out_bBereitZumAufstellen;
  blOutLogSchreiben := TRUE;
END_IF

IF blOutLogSchreiben THEN

  slOutLogString := CONCAT(WORD_TO_STRING(BasisStationsParameter.stMKs.stStationsNummern.NummerExtern), 'Bereit Aufstellen: ');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(out_bBereitZumAufstellen) );

  SpsLogString(slOutLogString);

  blOutLogSchreiben := FALSE;
END_IF
END_ACTION