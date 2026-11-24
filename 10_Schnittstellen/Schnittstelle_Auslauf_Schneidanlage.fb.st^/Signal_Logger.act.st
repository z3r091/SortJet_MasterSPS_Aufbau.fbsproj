(* METADATA
{
	"v3Meta": {
		"objectGuid": "1d419e81-f13f-44c0-9146-2da4202aa602"
	}
}
*)
ACTION Signal_Logger
//-------------------------------------------------------------------------------------------------
// SIGNALLOGGER
//-------------------------------------------------------------------------------------------------
// Bei Signalwechsel Daten ins Log schreiben

// Eingangsignale
IF ( in_bGlasAbruf <> blTempGlasAbruf )
   OR ( in_bAnforderungSK <> blTempAnforderungSK )
THEN
  blTempGlasAbruf     := in_bGlasAbruf;
  blTempAnforderungSK := in_bAnforderungSK;
  blInLogSchreiben := TRUE;
END_IF

IF blInLogSchreiben THEN

  slInLogString := CONCAT(WORD_TO_STRING(BasisStationsParameter.stMKs.stStationsNummern.NummerExtern), ' Fremd Abruf: ');
  slInLogString := CONCAT(slInLogString, BOOL_TO_STRING(in_bGlasAbruf) );
  slInLogString := CONCAT(slOutLogString, ': ');
  slInLogString := CONCAT(slOutLogString, 'SK Af.: ');
  slInLogString := CONCAT(slInLogString, BOOL_TO_STRING(in_bAnforderungSK) );
  SpsLogString(slInLogString);

  blInLogSchreiben := FALSE;
END_IF


// Ausganssignale
IF   ( out_bSenderBereit <> blTempSenderBereit )
     OR ( out_bSenderGlasBereit <> blTempSenderGlasBereit )
     OR ( blTempFreigabeSK <> out_bFreigabeSK )
THEN
  blTempSenderBereit     := out_bSenderBereit;
  blTempSenderGlasBereit := out_bSenderGlasBereit;
  blTempFreigabeSK       := out_bFreigabeSK;
  blOutLogSchreiben := TRUE;
END_IF

IF blOutLogSchreiben THEN

  slOutLogString := CONCAT(WORD_TO_STRING(BasisStationsParameter.stMKs.stStationsNummern.NummerExtern), ' HE Bereit: ');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(out_bSenderBereit) );
  slOutLogString := CONCAT(slOutLogString, ': ');
  slOutLogString := CONCAT(slOutLogString, 'Glas Bereit: ');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(out_bSenderGlasBereit) );
  slOutLogString := CONCAT(slOutLogString, ': ');
  slOutLogString := CONCAT(slOutLogString, 'SK Fg: ');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(out_bFreigabeSK) );

  SpsLogString(slOutLogString);

  blOutLogSchreiben := FALSE;
END_IF
END_ACTION