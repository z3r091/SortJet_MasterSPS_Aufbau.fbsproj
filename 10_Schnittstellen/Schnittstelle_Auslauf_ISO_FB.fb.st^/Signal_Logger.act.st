(* METADATA
{
	"v3Meta": {
		"objectGuid": "0429c823-dfd2-4e39-ba4a-c458002adab2"
	}
}
*)
ACTION Signal_Logger
(***************************************************************************************************)
(* SIGNALLOGGER *)
(***************************************************************************************************)
// Bei Signalwechsel Daten ins Log schreiben

// Eingangsignale
IF ( in_bGlasAbruf <> blTempGlasAbruf ) THEN
  blTempGlasAbruf := in_bGlasAbruf;
  blInLogSchreiben := TRUE;
END_IF

IF blInLogSchreiben THEN

  slInLogString := CONCAT(WORD_TO_STRING(BasisStationsParameter.stMKs.stStationsNummern.NummerExtern), ' Fremd Abruf: ');
  slInLogString := CONCAT(slInLogString, BOOL_TO_STRING(in_bGlasAbruf) );
  SpsLogString(slInLogString);

  blInLogSchreiben := FALSE;
END_IF


// Ausganssignale
IF   ( out_bSenderBereit <> blTempSenderBereit ) 
  OR ( out_bSenderGlasBereit <> blTempSenderGlasBereit ) 
THEN
  blTempSenderBereit := out_bSenderBereit;
  blTempSenderGlasBereit := out_bSenderGlasBereit;
  blOutLogSchreiben := TRUE;
END_IF

IF blOutLogSchreiben THEN

  slOutLogString := CONCAT(WORD_TO_STRING(BasisStationsParameter.stMKs.stStationsNummern.NummerExtern), ' HE Bereit: ');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(out_bSenderBereit) );
  slOutLogString := CONCAT(slOutLogString, ': ');
  slOutLogString := CONCAT(slOutLogString, 'Glas Bereit: ');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(out_bSenderGlasBereit) );

  SpsLogString(slOutLogString);

  blOutLogSchreiben := FALSE;
END_IF
END_ACTION