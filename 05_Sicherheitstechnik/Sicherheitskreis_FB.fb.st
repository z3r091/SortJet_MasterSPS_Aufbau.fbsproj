(* METADATA
{
	"v3Meta": {
		"objectGuid": "054ec8d1-7d35-45dd-8fed-1d9f4cdd4ae8"
	}
}
*)
FUNCTION_BLOCK Sicherheitskreis_FB
VAR_INPUT

  // BOOLEAN
  bpFreigabeStationen                   : BOOL;
  bpAnforderungSicherheitkreisAusloesen : BOOL;
  bpSicherheitskreisGeschlossenSafety   : BOOL;

END_VAR
VAR_OUTPUT

  // BOOL
  bpAnforderungSKGestellt                    : BOOL;
  bpStationenBlocken                         : BOOL;
  bpSicherheitskreisGeschlossen              : BOOL; // Hinweis: [Zeitverzoegert 2 Sekunden] Variable gibt an ob der Sicherheitskreisgeschlossen ist
  bpFreigabeZumBetretenDesSicherheitskreises : BOOL;
  bpFreigabeSafetyAusloesen                  : BOOL;
  bpFreigabeTuerenOeffnen                    : BOOL;
  
  // TIMER
  tonlSKFreigabe                             : TON;
  
END_VAR
VAR

  // TRIGGER
  rtlSKGeschlossen        : R_TRIG;
  ftlAnforderung          : F_TRIG;

  // TIMER 
  tonlStationenFreigabeSK : TON;
  tonlSKGeschlossen       : TON;

END_VAR
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: TIMER
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Ueberwachung das der Sicherheitskreis wirklich geschlossen meldet
*)
tonlSKGeschlossen(IN := bpSicherheitskreisGeschlossenSafety AND NOT bpFreigabeZumBetretenDesSicherheitskreises, PT := T#2S);
tonlSKFreigabe(IN := bpFreigabeZumBetretenDesSicherheitskreises, PT := T#2S);

bpFreigabeTuerenOeffnen   := NOT bpSicherheitskreisGeschlossenSafety;//AND bpFreigabeZumBetretenDesSicherheitskreises;
bpFreigabeSafetyAusloesen := tonlSKFreigabe.Q;

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: STEUERUNG SICHERHEITSKREIS
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Anforderung zum betreten des SK
*)
bpAnforderungSKGestellt := bpAnforderungSicherheitkreisAusloesen;

tonlStationenFreigabeSK( IN:= (bpAnforderungSKGestellt AND bpFreigabeStationen ),
                         PT := t#1s);

IF ( tonlStationenFreigabeSK.Q ) THEN
  bpFreigabeZumBetretenDesSicherheitskreises := TRUE;
END_IF

ftlAnforderung( CLK := bpAnforderungSKGestellt );
IF ftlAnforderung.Q THEN
  IF bpFreigabeZumBetretenDesSicherheitskreises THEN
    bpFreigabeZumBetretenDesSicherheitskreises := FALSE;
  END_IF
END_IF

(* Hinweis:
   - Sicherheitskreis wieder schließen und zurücksetzen
*)
rtlSKGeschlossen(CLK := bpSicherheitskreisGeschlossenSafety );

IF ( rtlSKGeschlossen.Q ) THEN
  bpAnforderungSKGestellt := FALSE;
  bpFreigabeZumBetretenDesSicherheitskreises := FALSE;
END_IF

// *************************************************************************************************
// BAUSTEIN: AUSGAENGE
// *************************** **********************************************************************
(* Hinweis:
   - Ausgaenge
*)
bpStationenBlocken                  := ( bpAnforderungSKGestellt OR NOT bpSicherheitskreisGeschlossen );
bpSicherheitskreisGeschlossen       := tonlSKGeschlossen.Q; // Die Stationen dürfen erst aktiv werden, wenn alle Regler durchgeschaltet haben
END_FUNCTION_BLOCK