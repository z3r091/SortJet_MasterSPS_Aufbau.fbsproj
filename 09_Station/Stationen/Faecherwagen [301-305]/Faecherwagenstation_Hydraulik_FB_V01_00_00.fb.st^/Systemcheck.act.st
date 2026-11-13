(* METADATA
{
	"v3Meta": {
		"objectGuid": "815af4e0-9593-4e46-8d2e-ae7704b81a94"
	}
}
*)
ACTION Systemcheck
//-------------------------------------------------------------------------------------------------
// SYSTEMCHECK
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Ein unterbrochenes Ein- oder Ausschleusen wird ab dem gemerkten Schritt (eLetzterStatus) fortgesetzt,
     wenn der Faecherwagen erkannt wird und die Freigabe da ist
   - In Ruhe, nach Neustart, nach Handfunktion oder nach Fehler ist nichts zu tun
     (Option AGV: Anschlag passend zum Rolltor stellen)
   - Danach Status der Station uebernehmen (Beladen, Muting)
*)
IF blBetriebartCheck THEN

  CASE steplCheck OF

    // SYSTEMCHECK ============================================================================
    STEP_0_E:
      bpDone := FALSE;

      CASE eLetzterStatus OF

        eLetzter_FW_Status.eEinschleusen_Hubrahmen_Heben_110,
        eLetzter_FW_Status.eEinschleusen_Rolltor_Oeffnen_120,
        eLetzter_FW_Status.eEinschleusen_Anschlag_Auf_140,
        eLetzter_FW_Status.eEinschleusen_Faecherwagen_Vor_150,
        eLetzter_FW_Status.eEinschleusen_Anschlag_Ab_160,
        eLetzter_FW_Status.eEinschleusen_Zentrierung_Schliessen_170,
        eLetzter_FW_Status.eEinschleusen_Auswertung_180:

          IF blFaecherwagenErkannt AND BasisStationsParameter.bFreigabe THEN

            CASE eLetzterStatus OF
              eLetzter_FW_Status.eEinschleusen_Hubrahmen_Heben_110:
                steplEinschleusen := STEP_110_E;
              eLetzter_FW_Status.eEinschleusen_Rolltor_Oeffnen_120:
                steplEinschleusen := STEP_130_E;
              eLetzter_FW_Status.eEinschleusen_Anschlag_Auf_140:
                steplEinschleusen := STEP_140_E;
              eLetzter_FW_Status.eEinschleusen_Faecherwagen_Vor_150:
                steplEinschleusen := STEP_150_E;
              eLetzter_FW_Status.eEinschleusen_Anschlag_Ab_160:
                steplEinschleusen := STEP_160_E;
              eLetzter_FW_Status.eEinschleusen_Zentrierung_Schliessen_170:
                steplEinschleusen := STEP_170_E;
            ELSE
              steplEinschleusen := STEP_180_E;
            END_CASE

            BasisStationsParameter.bEintransport[cWAND_1] := TRUE;
            steplCheck := STEP_100_E;

          ELSE
            BasisStationsParameter.wFehlerNummer := cMELDUNG_FAECHERWAGEN_SYSTEMCHECK_NICHT_MOEGLICH;
            steplCheck := STEP_900_E;
          END_IF

        eLetzter_FW_Status.eAusschleusen_Anschlag_Ab_100,
        eLetzter_FW_Status.eAusschleusen_Zentrierung_Oeffnen_110,
        eLetzter_FW_Status.eAusschleusen_Faecherwagen_Zurueck_120,
        eLetzter_FW_Status.eAusschleusen_Rolltor_Ab_145,
        eLetzter_FW_Status.eAusschleusen_Hubrahmen_Senken_140,
        eLetzter_FW_Status.eAusschleusen_Abgeschlossen_150:

          IF BasisStationsParameter.bFreigabe THEN

            CASE eLetzterStatus OF
              eLetzter_FW_Status.eAusschleusen_Anschlag_Ab_100:
                steplAusschleusen := STEP_100_E;
              eLetzter_FW_Status.eAusschleusen_Zentrierung_Oeffnen_110:
                steplAusschleusen := STEP_110_E;
              eLetzter_FW_Status.eAusschleusen_Faecherwagen_Zurueck_120:
                steplAusschleusen := STEP_120_E;
              eLetzter_FW_Status.eAusschleusen_Rolltor_Ab_145:
                steplAusschleusen := STEP_130_E;
              eLetzter_FW_Status.eAusschleusen_Hubrahmen_Senken_140:
                steplAusschleusen := STEP_140_E;
            ELSE
              steplAusschleusen := STEP_150_E;
            END_CASE

            BasisStationsParameter.bAustransport[cWAND_1] := TRUE;
            steplCheck := STEP_200_E;

          ELSE
            BasisStationsParameter.wFehlerNummer := cMELDUNG_FAECHERWAGEN_SYSTEMCHECK_NICHT_MOEGLICH;
            steplCheck := STEP_900_E;
          END_IF

      ELSE
        // Ruhe, Neustart, Handfunktion oder Fehler: nichts fortzusetzen
        IF (     BasisStationsParameter.stMKs.stStationsAufbau.bAGV
             AND BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
          steplCheck := STEP_300_E;
        ELSE
          steplCheck := STEP_310_E;
        END_IF
      END_CASE

    // SYSTEMCHECK ============================================================================
    STEP_100_E:
      // Fortgesetztes Einschleusen abwarten (Ueberwachung in der Kette)
      IF bpEinschleusenAbgeschlossen THEN
        BasisStationsParameter.bEintransport[cWAND_1] := FALSE;
        steplCheck := STEP_310_E;
      END_IF

    // SYSTEMCHECK ============================================================================
    STEP_200_E:
      // Fortgesetztes Ausschleusen abwarten (Ueberwachung in der Kette)
      IF bpAusschleusenAbgeschlossen THEN
        BasisStationsParameter.bAustransport[cWAND_1] := FALSE;
        steplCheck := STEP_310_E;
      END_IF

    // SYSTEMCHECK ============================================================================
    STEP_300_E:
      (* Hinweis:
         - Option AGV: Anschlag passend zum Rolltor stellen (Rolltor unten: Anschlag hoch, sonst ab)
         - Ueberwachung im ZylinderPneumatik_FB (Fehler -> STEP_900_E)
      *)
      blAnschlagAuf := bpRolltorUnten;
      blAnschlagAb  := NOT bpRolltorUnten;

      IF ( BasisStationsParameter.bFehler ) THEN
        blAnschlagAuf := FALSE;
        blAnschlagAb  := FALSE;
        steplCheck    := STEP_900_E;
      ELSIF ( blAnschlagAufDone OR blAnschlagAbDone ) THEN
        blAnschlagAuf := FALSE;
        blAnschlagAb  := FALSE;
        steplCheck    := STEP_310_E;
      END_IF

    // SYSTEMCHECK ============================================================================
    STEP_310_E:
      (* Hinweis:
         - Status der Station uebernehmen
         - Rolltor unten: kein Faecherwagen eingeschleust, Muting zuruecksetzen (Option AGV)
      *)
      blStationBeladen := bpStatusStationInBeladePosition;

      IF ( bpRolltorUnten ) THEN
        blMutingAusschalten := TRUE;
      END_IF

      steplCheck := STEP_1000_E;

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
    IF ( steplCheck = STEP_300_E ) THEN
      blAnschlagAuf := FALSE;
      blAnschlagAb  := FALSE;
    END_IF
    steplCheck := STEP_0_E;
    BasisStationsParameter.bCheckAbgeschlossen := FALSE;
    bpDone := FALSE;
  END_IF

END_IF
END_ACTION