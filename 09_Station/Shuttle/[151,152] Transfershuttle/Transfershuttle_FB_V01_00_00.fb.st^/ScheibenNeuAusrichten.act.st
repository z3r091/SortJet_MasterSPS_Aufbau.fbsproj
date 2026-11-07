(* METADATA
{
	"v3Meta": {
		"objectGuid": "5e1fde93-067a-4909-aaeb-a4114bec9a0c"
	}
}
*)
ACTION ScheibenNeuAusrichten
//-------------------------------------------------------------------------------------------------
// SCHEIBEN IM SPEICHER NEU AUSRICHTEN
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Scheibe neu im Speicher ausrichten. Scheibe wird richtung Einlaufsensor gefahren und dann wieder
     zurueck auf das passende Lueckenmass
*)
IF (  bpScheibenNeuAusrichten ) THEN

  CASE steplScheibenNeuAusrichten OF

    // SCHEIBEN AUSRICHTEN ==============================
    STEP_0_E:
      (* Hinweis:
         - Variablen setzen
      *)
      steplScheibenNeuAusrichten := STEP_10_E;

    // SCHEIBEN AUSRICHTEN ==============================
    STEP_10_E:
      IF ( blZielPositionErreicht ) THEN
        steplScheibenNeuAusrichten := STEP_20_E;
      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(Querfahrt.rpAktPosition);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplScheibenNeuAusrichten := STEP_900_E;
      END_IF

    // SCHEIBEN AUSRICHTEN ==============================
    STEP_20_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONALE - ABFRAGE DES SICHERHEITSKREISES
      //
      //  Hinweis:
      //  - Sicherstellen das der Sicherheitskreis geschlossen und nicht angefordert worden ist
      // ---------------------------------------------------------------------------------------

      IF  ( Sicherheitskreis[BasisStationsParameter.stMKs.eaSicherheitskreis[0]].bpSicherheitskreisGeschlossen
            AND NOT Sicherheitskreis[BasisStationsParameter.stMKs.eaSicherheitskreis[0]].bpAnforderungSKGestellt )
      THEN
        blHinweisGenerierenSKAusgeloest := FALSE;
        steplScheibenNeuAusrichten := STEP_100_E;

      ELSE
        blHinweisGenerierenSKAusgeloest := TRUE;

      END_IF
    
    // SCHEIBEN AUSRICHTEN ==============================
    STEP_100_E:
      (* Anmerkung:
         - Starten des Aktion
      *)
      Glastransport.pAuftrag                := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpScheibenNeuAusrichten := TRUE;

      steplScheibenNeuAusrichten := STEP_110_E;

    // SCHEIBEN AUSRICHTEN ==============================
    STEP_110_E:
      (* Hinweis:
         - Resource freigeben wenn es zu keinem Fehler gekommen ist
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpScheibenNeuAusrichten := FALSE;
        steplScheibenNeuAusrichten := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpScheibenNeuAusrichten := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplScheibenNeuAusrichten := STEP_900_E;
      END_IF

    // SCHEIBEN AUSRICHTEN ==============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // SCHEIBEN AUSRICHTEN ==============================
    STEP_1000_E:
      bpScheibenNeuAusrichtenAbgeschlossen := TRUE;

  // SCHEIBEN AUSRICHTEN ==============================
  END_CASE

ELSE

  IF ( steplScheibenNeuAusrichten > STEP_0_E ) THEN

    bpScheibenNeuAusrichtenAbgeschlossen := FALSE;
    blHinweisGenerierenSKAusgeloest      := FALSE;

    Glastransport.bpScheibenNeuAusrichten  := FALSE;

    steplScheibenNeuAusrichten := STEP_0_E;
  END_IF

END_IF
END_ACTION