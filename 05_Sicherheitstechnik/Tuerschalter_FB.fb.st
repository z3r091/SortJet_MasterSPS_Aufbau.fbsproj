(* METADATA
{
	"v3Meta": {
		"objectGuid": "4948c423-2ad3-469d-bcc1-6cb5d4807f3f"
	}
}
*)
FUNCTION_BLOCK Tuerschalter_FB
VAR_INPUT

  // BOOL
  bpFreigabeZumOeffnenDerTuer     : BOOL;
  bpTuerRelaisQuittiert           : BOOL;
  bpWeitereTuerenGeoeffnet        : BOOL;
  bpTuerGeschlossen               : BOOL;
  in_bTasterNothaltNichtBetaetigt : BOOL := TRUE; // Oeffner - kommt von SLC (EV_ToPLC_Tueren_Nothalt_aktiv)
  
  // WORD
  wSicherheitskreis           : WORD;
  wMeldungsnummer             : WORD;

END_VAR
VAR_OUTPUT

  // BOOL
  bpAnforderungZumTuerOffnenGestellt : BOOL;
  bpStatusTuerNichtGeschlossen       : BOOL;
  out_bTuerZuhaltungDeaktivieren     : BOOL;

END_VAR
VAR

  // TRIGGER 
  rtlTuerGeschlossen : R_TRIG;
  ftlTuerGeoeffnet   : F_TRIG;

  // TIMER
  tonlNotEinlass     : TON;

END_VAR
VAR

  // HARDWARE EINGAENGE 
  in_bTasterAnforderungTuerOeffnen             : BOOL;
  in_bTasterQuittierungTuerGeschlossen         : BOOL;

  // HARDWARE AUSGAENGE 
  out_bLeuchteFreigabeTuerOeffnen              : BOOL;
  out_bLeuchteTuerNichtGeschlossen             : BOOL;
  out_bLeuchteTuerNothaltAktiv                 : BOOL;
  
END_VAR
(* Hinweis:
   - Dieser Baustein ist für Türschalter des Herstellers Euchner
     Anmerkung:
   - Sollte Nothalt ausgeloest werden, muss die Tür mittels Not-Entriegelung [Mechanisch] geoeffnet werden
*)
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: EINSTELLUNGEN
//-------------------------------------------------------------------------------------------------
// Timer
tonlNotEinlass(IN := in_bTasterAnforderungTuerOeffnen, PT := T#7S);

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: VERWALTUNG DER TÜREN
//-------------------------------------------------------------------------------------------------
//Anforderung zum betreten des Sicherheitskreises durch die entsprechende Tür
IF( in_bTasterAnforderungTuerOeffnen ) THEN
  bpAnforderungZumTuerOffnenGestellt := TRUE;
END_IF

(* Hinweis:
   - Zuruecksetzen der Anforderung:
     => Wenn die Tuer geoeffnet wurde
     => Quittieren der Tuer
*)
IF ( in_bTasterQuittierungTuerGeschlossen ) THEN
  bpAnforderungZumTuerOffnenGestellt := FALSE;
END_IF

// Tür freigeben wenn sie geoeffnet wurde, obwohl sie nicht angefordert wurde

ftlTuerGeoeffnet( CLK := bgEtherCatOK AND bpTuerGeschlossen );

IF ( ftlTuerGeoeffnet.Q AND NOT in_bTasterQuittierungTuerGeschlossen ) THEN
  out_bTuerZuhaltungDeaktivieren := TRUE;
  bpAnforderungZumTuerOffnenGestellt := TRUE;
END_IF

// Ansteuerung der Taster-Leuchte
out_bLeuchteFreigabeTuerOeffnen := (( bpAnforderungZumTuerOffnenGestellt AND gbFlashbit05sec )
                                     OR out_bTuerZuhaltungDeaktivieren );

// Tür oeffnen
IF ( bpFreigabeZumOeffnenDerTuer
     AND bpAnforderungZumTuerOffnenGestellt ) OR tonlNotEinlass.Q
THEN
  out_bTuerZuhaltungDeaktivieren := TRUE;
END_IF


// Tür wieder schließen und zurücksetzen 
rtlTuerGeschlossen(CLK := in_bTasterQuittierungTuerGeschlossen AND bpTuerGeschlossen );

IF ( rtlTuerGeschlossen.Q  ) THEN
  out_bTuerZuhaltungDeaktivieren := FALSE;
  bpAnforderungZumTuerOffnenGestellt := FALSE;
END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Meldung ob die Tuer geschlossen und verschlossen ist
bpStatusTuerNichtGeschlossen     := NOT bpTuerGeschlossen OR NOT bpTuerRelaisQuittiert;

out_bLeuchteTuerNichtGeschlossen := NOT bpTuerRelaisQuittiert OR ( bpWeitereTuerenGeoeffnet AND gbFlashbit1sec );

out_bLeuchteTuerNothaltAktiv := NOT Nothalt.bpNotHaltOK;

// Meldungen
WatchIo( NOT in_bTasterNothaltNichtBetaetigt ,wMeldungsnummer );
END_FUNCTION_BLOCK