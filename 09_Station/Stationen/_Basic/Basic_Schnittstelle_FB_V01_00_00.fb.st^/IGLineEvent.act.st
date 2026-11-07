(* METADATA
{
	"v3Meta": {
		"objectGuid": "eb410a9f-4f2d-4b91-9b42-1e80fc6ee1dd"
	}
}
*)
ACTION IGLineEvent
//-------------------------------------------------------------------------------------------------
// IG LINE EVENT
//-------------------------------------------------------------------------------------------------
bpISOLineEventAktiv := blUebergabeGlas;
(* Hinweis:
   - Ausgaenge setzen
*)
out_bLeuchteGlasbruch :=( blUebergabeGlas AND ((wpAuftragsTyp = 1) OR (wpAuftragsTyp = 4) OR ((wpAuftragsTyp = 5) AND gbFlashbit05sec))) ;
out_bLeuchteSpezial   :=( blUebergabeGlas AND ((wpAuftragsTyp = 2) OR ((wpAuftragsTyp = 3) AND gbFlashbit02sec )));

out_bAmpelEventAktiv := (blUebergabeGlas);

//-------------------------------------------------------------------------------------------------
// STEUERUNG:  ISO Line EVENT abhandeln
//-------------------------------------------------------------------------------------------------
IF ( bpStarteIGEvent
     AND NOT blUebergabeGlas )
THEN
  blUebergabeGlas := TRUE;
  bpStarteIGEvent := FALSE;
  steplUebergabeGlas := STEP_0_E;
END_IF

(* Hinweis:
   - wpAuftragsTyp:
   - case 0: //Kein Ereignis
   - case 1: //Scheibe von Isolinie abnehmen!
   - case 2: //Einschleusen von Sonderscheibe!
   - case 3: //Laufende!
   - case 4: //Alle Scheiben der Isoeinheit sind Bruch!
   - case 5: //Eine Scheibe der Einheit ist Bruch!
*)
IF ( blUebergabeGlas ) THEN
  CASE steplUebergabeGlas OF
    // GLASUEBERGABE ========================
    STEP_0_E:

      dwpWartezeit := 0;

      tlWarteZeiteAufnahme := TIME(); // Starten der Wartezeitenermittlung

      CASE wpAuftragsTyp OF
        0:
          steplUebergabeGlas:=STEP_1000_E;

        1,2,3,4,5:
          Horn.bpHornAktivieren := TRUE;
          Horn.wpStatusArt      := wpAuftragsTyp;
          Horn.tpHornZeit       := BasisStationsParameter.stMKs.stFremdanlage.tZeitHornAktiv;

          steplUebergabeGlas:=STEP_10_E;

        ELSE
          steplUebergabeGlas:=STEP_1000_E;
      END_CASE

    // GLASUEBERGABE ========================
    STEP_10_E:
      rtlTasterSpezial( CLK := in_bTasterSpezial );
      rtlTasterGlasbruch( CLK := in_bTasterGlasbruch );


      IF ((wpAuftragsTyp = 1) OR (wpAuftragsTyp = 4) OR (wpAuftragsTyp = 5))
         AND rtlTasterGlasbruch.CLK
      THEN
        steplUebergabeGlas:=STEP_100_E;
      END_IF

      IF ((wpAuftragsTyp = 2) OR (wpAuftragsTyp = 3))
         AND rtlTasterSpezial.Q
      THEN
        steplUebergabeGlas:=STEP_100_E;
      END_IF

    // GLASUEBERGABE ========================
    STEP_100_E:
      (* Hinweis:
         - Nachrichtabsetzen
      *)
      dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeiteAufnahme);
      wSps2MmiQuittISOLineNr   := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
      dwSps2MmiWartezeit       := dwpWartezeit;
      MsgToMmi(auftragsnr_w    := SB0_SPS_SORTIERUNGQUITTUNGVONISOLINIE );

      steplUebergabeGlas:=STEP_1000_E;

    // GLASUEBERGABE ========================
    STEP_1000_E:
      steplUebergabeGlas:=STEP_0_E;
      blUebergabeGlas:=FALSE;
      dwpWartezeit := 0;

  // GLASUEBERGABE ========================
  END_CASE
END_IF


//-------------------------------------------------------------------------------------------------
// STEUERUNG: Abbruch eines ISO Line Events
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Abbruch des ISO-Linie Event per MMI Nachricht [Cancel- Event]
   - Abbruch nach einem Stopp da das ISO-Linie Event nochmal geschickt wird
*)
IF ( bpResetISOLinieEvent ) THEN
  bpResetISOLinieEvent := FALSE;
  bpStarteIGEvent      := FALSE;
  blUebergabeGlas      := FALSE;
END_IF
END_ACTION