(* METADATA
{
	"v3Meta": {
		"objectGuid": "6c95a149-8c38-4015-950a-c97a2b708553"
	}
}
*)
ACTION Systemcheck
//-------------------------------------------------------------------------------------------------
// SYSTEMCHECK
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Ein unterbrochenes Ein- oder Ausschleusen wird ab dem gemerkten Schritt (eLetzterStatus) fortgesetzt
   - In Ruhe, nach Neustart, nach Handfunktion oder nach Fehler ist nichts zu tun
*)
IF blBetriebartCheck THEN

  CASE steplCheck OF

    // SYSTEMCHECK ============================================================================
    STEP_0_E:
      bpDone := FALSE;

      CASE eLetzterStatus OF

        eLetzter_FW_Status.eEinschleusen_Arretierung_Schliessen_110:
          IF bpFaecherwagenVorhanden AND BasisStationsParameter.bFreigabe THEN
            steplEinschleusen := STEP_110_E;
            BasisStationsParameter.bEintransport[cWAND_1] := TRUE;
            steplCheck := STEP_100_E;
          ELSE
            BasisStationsParameter.wFehlerNummer := cMELDUNG_FAECHERWAGEN_SYSTEMCHECK_NICHT_MOEGLICH;
            steplCheck := STEP_900_E;
          END_IF

        eLetzter_FW_Status.eEinschleusen_Rolltor_Oeffnen_120:
          IF bpFaecherwagenVorhanden AND BasisStationsParameter.bFreigabe THEN
            steplEinschleusen := STEP_120_E;
            BasisStationsParameter.bEintransport[cWAND_1] := TRUE;
            steplCheck := STEP_100_E;
          ELSE
            BasisStationsParameter.wFehlerNummer := cMELDUNG_FAECHERWAGEN_SYSTEMCHECK_NICHT_MOEGLICH;
            steplCheck := STEP_900_E;
          END_IF

        eLetzter_FW_Status.eEinschleusen_Auswertung_180:
          IF bpFaecherwagenVorhanden AND BasisStationsParameter.bFreigabe THEN
            steplEinschleusen := STEP_180_E;
            BasisStationsParameter.bEintransport[cWAND_1] := TRUE;
            steplCheck := STEP_100_E;
          ELSE
            BasisStationsParameter.wFehlerNummer := cMELDUNG_FAECHERWAGEN_SYSTEMCHECK_NICHT_MOEGLICH;
            steplCheck := STEP_900_E;
          END_IF

        eLetzter_FW_Status.eAusschleusen_Rolltor_Ab_145:
          IF BasisStationsParameter.bFreigabe THEN
            steplAusschleusen := STEP_100_E;
            BasisStationsParameter.bAustransport[cWAND_1] := TRUE;
            steplCheck := STEP_200_E;
          ELSE
            BasisStationsParameter.wFehlerNummer := cMELDUNG_FAECHERWAGEN_SYSTEMCHECK_NICHT_MOEGLICH;
            steplCheck := STEP_900_E;
          END_IF

        eLetzter_FW_Status.eAusschleusen_Arretierung_Oeffnen_110:
          IF BasisStationsParameter.bFreigabe THEN
            steplAusschleusen := STEP_110_E;
            BasisStationsParameter.bAustransport[cWAND_1] := TRUE;
            steplCheck := STEP_200_E;
          ELSE
            BasisStationsParameter.wFehlerNummer := cMELDUNG_FAECHERWAGEN_SYSTEMCHECK_NICHT_MOEGLICH;
            steplCheck := STEP_900_E;
          END_IF

        eLetzter_FW_Status.eAusschleusen_Abgeschlossen_150:
          IF BasisStationsParameter.bFreigabe THEN
            steplAusschleusen := STEP_150_E;
            BasisStationsParameter.bAustransport[cWAND_1] := TRUE;
            steplCheck := STEP_200_E;
          ELSE
            BasisStationsParameter.wFehlerNummer := cMELDUNG_FAECHERWAGEN_SYSTEMCHECK_NICHT_MOEGLICH;
            steplCheck := STEP_900_E;
          END_IF

      ELSE
        // Ruhe, Neustart, Handfunktion oder Fehler: nichts fortzusetzen
        steplCheck := STEP_1000_E;
      END_CASE

    // SYSTEMCHECK ============================================================================
    STEP_100_E:
      // Fortgesetztes Einschleusen abwarten (Ueberwachung in der Kette)
      IF bpEinschleusenAbgeschlossen THEN
        BasisStationsParameter.bEintransport[cWAND_1] := FALSE;
        steplCheck := STEP_1000_E;
      END_IF

    // SYSTEMCHECK ============================================================================
    STEP_200_E:
      // Fortgesetztes Ausschleusen abwarten (Ueberwachung in der Kette)
      IF bpAusschleusenAbgeschlossen THEN
        BasisStationsParameter.bAustransport[cWAND_1] := FALSE;
        steplCheck := STEP_1000_E;
      END_IF

    // SYSTEMCHECK ============================================================================
    STEP_900_E:
      // Fehlerzustand setzen und Fehlerdaten bereitstellen
      BasisStationsParameter.bFehler := TRUE;

      wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
      wpgFehlerdaten[1] := 0;

      steplCheck := STEP_910_E;

    // SYSTEMCHECK ============================================================================
    STEP_910_E:
      // Fehler bleibt aktiv bis Reset
      ;

    // SYSTEMCHECK ============================================================================
    STEP_1000_E:
      BasisStationsParameter.bCheckAbgeschlossen := TRUE;
      bpDone := TRUE;

  END_CASE

ELSE

  IF steplCheck > STEP_0_E THEN
    steplCheck := STEP_0_E;
    BasisStationsParameter.bCheckAbgeschlossen := FALSE;
    bpDone := FALSE;
  END_IF

END_IF
END_ACTION