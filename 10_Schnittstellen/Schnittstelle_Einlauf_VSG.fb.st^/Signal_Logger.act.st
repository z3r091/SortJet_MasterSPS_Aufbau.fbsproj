(* METADATA
{
	"v3Meta": {
		"objectGuid": "2c4ea876-0125-4fa6-ae89-8817d1a2f2db"
	}
}
*)
ACTION Signal_Logger
//-------------------------------------------------------------------------------------------------
// SIGNALLOGGER
//-------------------------------------------------------------------------------------------------
// Bei Signalwechsel Daten ins Log schreiben

// Eingangsignale
IF   ( in_bAutomatikBetrieb <> blTempAutomatikBetrieb ) 
     OR ( blTempSenderGlasBereit <> in_bGlasBereit)
THEN
  blTempAutomatikBetrieb := in_bAutomatikBetrieb;
  blTempSenderGlasBereit := in_bGlasBereit;
  blInLogSchreiben    := TRUE;
END_IF

IF blInLogSchreiben THEN

  slInLogString := CONCAT(WORD_TO_STRING(BasisStationsParameter.stMKs.stStationsNummern.NummerExtern), ' Fremd Auto: ');
  slInLogString := CONCAT(slInLogString, BOOL_TO_STRING(in_bAutomatikBetrieb) );
  slInLogString := CONCAT(slInLogString, ': ');
  slInLogString := CONCAT(slInLogString, 'Bereit : ');
  slInLogString := CONCAT(slInLogString, BOOL_TO_STRING(in_bGlasBereit) );
  
  SpsLogString(slInLogString);

  blInLogSchreiben := FALSE;
END_IF


// Ausganssignale
IF   ( out_bEinlaufsensor <> blTempEinlaufSensor ) 
     OR ( out_bBereitZumEintrasport <> blTempGlasAbruf ) 
THEN
  blTempEinlaufSensor := out_bEinlaufsensor;
  blTempGlasAbruf     := out_bBereitZumEintrasport;
  blOutLogSchreiben := TRUE;
END_IF

IF blOutLogSchreiben THEN

  slOutLogString := CONCAT(WORD_TO_STRING(BasisStationsParameter.stMKs.stStationsNummern.NummerExtern), ' HE Sesnor: ');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(out_bEinlaufsensor) );
  slOutLogString := CONCAT(slOutLogString, ': ');
  slOutLogString := CONCAT(slOutLogString, 'Bereit Eintransport: ');
  slOutLogString := CONCAT(slOutLogString, BOOL_TO_STRING(out_bBereitZumEintrasport) );

  SpsLogString(slOutLogString);

  blOutLogSchreiben := FALSE;
END_IF
END_ACTION