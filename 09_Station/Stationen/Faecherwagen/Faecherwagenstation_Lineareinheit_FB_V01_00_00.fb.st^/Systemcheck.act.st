(* METADATA
{
	"v3Meta": {
		"objectGuid": "57a87972-c3e9-4904-9fd6-abd6b6702c90"
	}
}
*)
ACTION Systemcheck
//-------------------------------------------------------------------------------------------------
// SYSTEMCHECK
//-------------------------------------------------------------------------------------------------

IF blBetriebartCheck THEN

  CASE steplCheck OF

    // SYSTEMCHECK ============================================================================
    STEP_0_E:
      // Initialisieren und auf Freigabe warten
      bpDone := FALSE;

      IF ( eLetzterStatus = eLetzter_FW_Status.eKeine_Info ) OR
         ( eLetzterStatus = eLetzter_FW_Status.eEinschleusen_Starten_0 ) OR
         ( eLetzterStatus = eLetzter_FW_Status.eEinschleusen_Warte_Auf_Faecherwagen_In_Box_100 ) OR
         ( eLetzterStatus = eLetzter_FW_Status.eEinschleusen_Warten_Auf_Lichtschranke_Und_Quittierung_105 ) OR
         ( eLetzterStatus = eLetzter_FW_Status.eEinschleusen_Fehler ) OR
         ( eLetzterStatus = eLetzter_FW_Status.eEinschleusen_Abgeschlossen_InBeladeposition ) OR
         ( eLetzterStatus = eLetzter_FW_Status.eAusschleusen_Starten_0 ) OR
         ( eLetzterStatus = eLetzter_FW_Status.eAusschleusen_Warten_Auf_Start_10 ) OR
         ( eLetzterStatus = eLetzter_FW_Status.eAusschleusen_Abgeschlossen_InGrundstellung ) OR
         ( eLetzterStatus = eLetzter_FW_Status.eAusschleusen_Fehler )
      THEN

        steplCheck := STEP_1000_E;

      ELSIF bpUntergestellErkannt AND bpLichtschranke_OK AND BasisStationsParameter.bFreigabe THEN

        CASE eLetzterStatus OF

          eLetzter_FW_Status.eEinschleusen_Gegenhalter_Schliessen_110:
            steplEinschleusen := STEP_110_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_RFID_Auslesen_Gegenhalter_Schliessen_115:
            steplEinschleusen := STEP_115_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Rolltor_Oeffnen_120:
            steplEinschleusen := STEP_120_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Greifer_Oeffnen_125:
            steplEinschleusen := STEP_125_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Lineareinheit_Vor_130:
            steplEinschleusen := STEP_130_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Greifer_Schliessen_135:
            steplEinschleusen := STEP_135_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Entrieglung_Oeffnen_140:
            steplEinschleusen := STEP_140_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Lineareinheit_zurueck_145:
            steplEinschleusen := STEP_145_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Greifer_Oeffnen_150:
            steplEinschleusen := STEP_150_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Lineareinheit_Vor_155:
            steplEinschleusen := STEP_155_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Greifer_Schliessen_160:
            steplEinschleusen := STEP_160_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Lineareinheit_Shuttle_165:
            steplEinschleusen := STEP_165_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Rolltor_Ab_170:
            steplEinschleusen := STEP_170_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eEinschleusen_Auswertung_180:
            steplEinschleusen := STEP_180_E;
            BasisStationsParameter.bEintransport[1] := TRUE;
            steplCheck := STEP_100_E;

          eLetzter_FW_Status.eAusschleusen_Rolltor_Auf_Entriegeln_Festhalten_100:
            steplAusschleusen := STEP_100_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          eLetzter_FW_Status.eAusschleusen_Lineareinheit_Vor_105:
            steplAusschleusen := STEP_105_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          eLetzter_FW_Status.eAusschleusen_Greifer_Oeffnen_110:
            steplAusschleusen := STEP_110_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          eLetzter_FW_Status.eAusschleusen_Lineareinheit_Zurueck_115:
            steplAusschleusen := STEP_115_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          eLetzter_FW_Status.eAusschleusen_Greifer_Schliessen_120:
            steplAusschleusen := STEP_120_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          eLetzter_FW_Status.eAusschleusen_Lineareinheit_Vor_125:
            steplAusschleusen := STEP_125_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          eLetzter_FW_Status.eAusschleusen_Entrieglung_Schliessen_130:
            steplAusschleusen := STEP_130_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          eLetzter_FW_Status.eAusschleusen_Greifer_Oeffnen_135:
            steplAusschleusen := STEP_135_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          eLetzter_FW_Status.eAusschleusen_Lineareinheit_Zurueck_140:
            steplAusschleusen := STEP_140_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          eLetzter_FW_Status.eAusschleusen_Rolltor_Ab_145:
            steplAusschleusen := STEP_145_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          eLetzter_FW_Status.eAusschleusen_Abgeschlossen_150:
            steplAusschleusen := STEP_150_E;
            BasisStationsParameter.bAustransport[1] := TRUE;
            steplCheck := STEP_200_E;

          ELSE
            BasisStationsParameter.wFehlerNummer := cMELDUNG_FAECHERWAGEN_SYSTEMCHECK_NICHT_MOEGLICH;
            steplCheck := STEP_900_E;
        END_CASE

      ELSE
        BasisStationsParameter.wFehlerNummer := cMELDUNG_FAECHERWAGEN_SYSTEMCHECK_NICHT_MOEGLICH;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEMCHECK ============================================================================
    STEP_100_E:
      IF bpEinschleusenAbgeschlossen THEN
        BasisStationsParameter.bEintransport[1] := FALSE;
        steplCheck := STEP_1000_E;
      END_IF

    // SYSTEMCHECK ============================================================================
    STEP_200_E:
      IF bpAusschleusenAbgeschlossen THEN
        BasisStationsParameter.bAustransport[1] := FALSE;
        steplCheck := STEP_1000_E;
      END_IF

    // SYSTEMCHECK ============================================================================
    STEP_900_E:
      // Fehlerzustand setzen und Fehlerdaten bereitstellen

      BasisStationsParameter.bFehler := TRUE;

      wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
      wpgFehlerdaten[1] := 0;

      // Fehlerauswertung extern
      steplCheck := STEP_910_E;

    // SYSTEMCHECK ============================================================================
    STEP_910_E:
      // Fehler bleibt aktiv bis Reset
      ;

    // SYSTEMCHECK ============================================================================
    STEP_1000_E:
      // Check abgeschlossen melden
      BasisStationsParameter.bCheckAbgeschlossen := TRUE;
      bpDone := TRUE;

  END_CASE

ELSE

  IF steplCheck > STEP_0_E THEN
    // Ablauf stoppen und Aktoren zurücksetzen

    steplCheck := STEP_0_E;
    BasisStationsParameter.bCheckAbgeschlossen := FALSE;

    blEntriegelungSchliessen := FALSE;
    bpDone := FALSE;
  END_IF

END_IF
END_ACTION