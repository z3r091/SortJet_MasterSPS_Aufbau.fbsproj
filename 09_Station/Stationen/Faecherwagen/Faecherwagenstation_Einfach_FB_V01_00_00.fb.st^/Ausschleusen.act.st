(* METADATA
{
  "v3Meta": {
    "objectGuid": "9b73b5b4-6bf4-48e6-b6cf-6831448b070c"
  }
}
*)
ACTION Ausschleusen
//-------------------------------------------------------------------------------------------------
// AUSSCHLEUSEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Rolltor schliessen (Option stStationsAufbau.bRolltor)
   - Arretierung einfahren, danach kann der Bediener den Faecherwagen entnehmen
*)
IF BasisStationsParameter.bAustransport[cWAND_1] AND
   ( blBetriebsartAutomatik OR
     blBetriebsartHand OR
     blBetriebartCheck )
THEN

  IF BasisStationsParameter.bFehler THEN
    steplAusschleusen := STEP_900_E;
  END_IF

  CASE steplAusschleusen OF

    // AUSSCHLEUSEN ==========================
    STEP_0_E:
      (* Hinweis:
         - Initialisierung der Variablen
      *)
      bpAusschleusenAbgeschlossen := FALSE;
      blArretierungSchliessen     := FALSE;
      blArretierungOeffnen        := FALSE;
      blRolltorAuf                := FALSE;
      blRolltorAb                 := FALSE;

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Starten_0;

      steplAusschleusen := STEP_10_E;

    // AUSSCHLEUSEN ==========================
    STEP_10_E:
      (* Hinweis:
         - Start des Ausschleusens, Rolltor schliessen
      *)
      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Rolltor_Ab_145;

      blRolltorAb       := TRUE;
      steplAusschleusen := STEP_100_E;

    // AUSSCHLEUSEN ==========================
    STEP_100_E:
      (* Hinweis:
         - Rolltor schliessen (ohne Rolltor meldet die Aktion Rolltor sofort fertig)
         - Ueberwachung der Endlage in der Aktion Rolltor
      *)
      IF ( blRolltorAbDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Arretierung_Oeffnen_110;

        blRolltorAb          := FALSE;
        blArretierungOeffnen := TRUE;
        steplAusschleusen    := STEP_110_E;
      ELSE
        blRolltorAb          := TRUE;
      END_IF

    // AUSSCHLEUSEN ==========================
    STEP_110_E:
      (* Hinweis:
         - Arretierung einfahren, der Faecherwagen wird freigegeben
         - Ueberwachung der Endlage im Arretierung_FB
      *)
      IF ( blArretierungOeffnenDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Abgeschlossen_150;

        blArretierungOeffnen := FALSE;
        steplAusschleusen    := STEP_150_E;
      ELSE
        blArretierungOeffnen := TRUE;
      END_IF

    // AUSSCHLEUSEN ==========================
    STEP_150_E:
      (* Hinweis:
         - Freigegebenen Faecherwagen dem MMI melden
      *)
      wSps2FaecherwagenStart := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
      MsgToMmi( auftragsnr_w := SB0_SPS_SortierungRackinPos );

      steplAusschleusen := STEP_1000_E;

    // AUSSCHLEUSEN ==========================
    STEP_900_E:
      blArretierungOeffnen := FALSE;
      blRolltorAb          := FALSE;

      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bAustransport[cWAND_1] := FALSE;

    // AUSSCHLEUSEN ==========================
    STEP_1000_E:
      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Abgeschlossen_InGrundstellung;

      bpAusschleusenAbgeschlossen := TRUE;
      BasisStationsParameter.bAustransport[cWAND_1] := FALSE;

  // AUSSCHLEUSEN ==========================
  END_CASE

ELSE

  IF ( steplAusschleusen > STEP_0_E ) THEN
    bpAusschleusenAbgeschlossen := FALSE;
    blArretierungSchliessen     := FALSE;
    blArretierungOeffnen        := FALSE;
    blRolltorAuf                := FALSE;
    blRolltorAb                 := FALSE;

    steplAusschleusen := STEP_0_E;
  END_IF

END_IF
END_ACTION