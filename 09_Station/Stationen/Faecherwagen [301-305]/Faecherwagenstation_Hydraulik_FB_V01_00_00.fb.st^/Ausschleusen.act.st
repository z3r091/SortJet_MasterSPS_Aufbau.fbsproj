(* METADATA
{
	"v3Meta": {
		"objectGuid": "b8318e71-33b4-4378-bb26-1a25eb83808f"
	}
}
*)
ACTION Ausschleusen
//-------------------------------------------------------------------------------------------------
// AUSSCHLEUSEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Anschlag ab (Option bAnschlag), Zentrierung oeffnen, Faecherwagen aus der Station schieben
   - Rolltor schliessen (Option bRolltor), Hubrahmen senken, danach kann der Bediener den Wagen entnehmen
   - Zwischen Zentrierung oeffnen und Faecherwagen zurueck das Umlaufventil kurz zuruecknehmen
   - Option AGV (Schritte 200..230): Rolltor schliessen und Anschlag hoch, das AGV holt den Faecherwagen ab
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
      blHubrahmenHeben            := FALSE;
      blHubrahmenSenken           := FALSE;
      blFaecherwagenVor           := FALSE;
      blFaecherwagenZurueck       := FALSE;
      blZentrierungOeffnen        := FALSE;
      blZentrierungSchliessen     := FALSE;
      blAnschlagAuf               := FALSE;
      blAnschlagAb                := FALSE;
      blAnschlagVor               := FALSE;
      blAnschlagZurueck           := FALSE;
      blRolltorAuf                := FALSE;
      blRolltorAb                 := FALSE;
      blStationBeladen            := FALSE;
      bpUmlaufVentilPause         := FALSE;
      tonlUmlaufventilPause( IN := FALSE );

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Starten_0;

      steplAusschleusen := STEP_10_E;

    // AUSSCHLEUSEN ==========================
    STEP_10_E:
      (* Hinweis:
         - Start des Ausschleusens
      *)
      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAGV ) THEN
        blRolltorAb       := TRUE;
        blAnschlagAuf     := TRUE;
        steplAusschleusen := STEP_200_E;
      ELSIF NOT blHydraulikAuftragFreigabe THEN
        // Warten, bis die Hydraulikstation einen weiteren Auftrag zulaesst (begrenzte Anzahl gleichzeitiger Auftraege)
        blHydraulikAuftragAnfrage := TRUE;
      ELSIF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
        blHydraulikAuftragAktiv := TRUE;
        eLetzterStatus    := eLetzter_FW_Status.eAusschleusen_Anschlag_Ab_100;
        blAnschlagAb      := TRUE;
        steplAusschleusen := STEP_100_E;
      ELSE
        blHydraulikAuftragAktiv := TRUE;
        eLetzterStatus       := eLetzter_FW_Status.eAusschleusen_Zentrierung_Oeffnen_110;
        blZentrierungOeffnen := TRUE;
        steplAusschleusen    := STEP_110_E;
      END_IF

    // AUSSCHLEUSEN ==========================
    STEP_100_E:
      (* Hinweis:
         - Anschlag ab (Ueberwachung im ZylinderPneumatik_FB)
      *)
      IF ( blAnschlagAbDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Zentrierung_Oeffnen_110;

        blAnschlagAb         := FALSE;
        blZentrierungOeffnen := TRUE;
        steplAusschleusen    := STEP_110_E;
      ELSE
        blAnschlagAb         := TRUE;
      END_IF

    // AUSSCHLEUSEN ==========================
    STEP_110_E:
      (* Hinweis:
         - Zentrierung oeffnen (Ueberwachung in der Aktion Zentrierung)
      *)
      IF ( blZentrierungOeffnenDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Faecherwagen_Zurueck_120;

        blZentrierungOeffnen  := FALSE;
        bpUmlaufVentilPause   := TRUE;
        tonlUmlaufventilPause( IN := FALSE );
        steplAusschleusen     := STEP_115_E;
      ELSE
        blZentrierungOeffnen  := TRUE;
      END_IF

    // AUSSCHLEUSEN ==========================
    STEP_115_E:
      (* Hinweis:
         - Umlaufventil kurz zuruecknehmen, bevor der Faecherwagen zurueck faehrt (feste Wartezeit)
      *)
      tonlUmlaufventilPause( IN := TRUE, PT := ZEIT_UMLAUFVENTIL_PAUSE );

      IF ( tonlUmlaufventilPause.Q ) THEN
        tonlUmlaufventilPause( IN := FALSE );
        bpUmlaufVentilPause   := FALSE;
        blFaecherwagenZurueck := TRUE;
        steplAusschleusen     := STEP_120_E;
      END_IF

    // AUSSCHLEUSEN ==========================
    STEP_120_E:
      (* Hinweis:
         - Faecherwagen aus der Station schieben (Ueberwachung in der Aktion Verfahren)
      *)
      IF ( blFaecherwagenZurueckDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Rolltor_Ab_145;

        blFaecherwagenZurueck := FALSE;
        blRolltorAb           := TRUE;
        steplAusschleusen     := STEP_130_E;
      ELSE
        blFaecherwagenZurueck := TRUE;
      END_IF

    // AUSSCHLEUSEN ==========================
    STEP_130_E:
      (* Hinweis:
         - Rolltor schliessen (ohne Rolltor meldet die Aktion Rolltor sofort fertig)
      *)
      IF ( blRolltorAbDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Hubrahmen_Senken_140;

        blRolltorAb       := FALSE;
        blHubrahmenSenken := TRUE;
        steplAusschleusen := STEP_140_E;
      ELSE
        blRolltorAb       := TRUE;
      END_IF

    // AUSSCHLEUSEN ==========================
    STEP_140_E:
      (* Hinweis:
         - Hubrahmen senken (Ueberwachung in der Aktion Hubrahmen)
      *)
      IF ( blHubrahmenSenkenDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Abgeschlossen_150;

        blHubrahmenSenken := FALSE;
        steplAusschleusen := STEP_150_E;
      ELSE
        blHubrahmenSenken := TRUE;
      END_IF

    // AUSSCHLEUSEN ==========================
    STEP_150_E:
      (* Hinweis:
         - Freigegebenen Faecherwagen dem MMI melden
      *)
      wSps2FaecherwagenStart := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
      MsgToMmi( auftragsnr_w := SB0_SPS_SortierungRackinPos );

      steplAusschleusen := STEP_1000_E;

    // AUSSCHLEUSEN AGV ======================
    STEP_200_E:
      (* Hinweis:
         - Option AGV: Rolltor schliessen und Anschlag hoch (Ueberwachung in der Aktion Rolltor bzw. im
           ZylinderPneumatik_FB, ohne Rolltor/Anschlag sofort fertig)
      *)
      IF ( blRolltorAbDone AND blAnschlagAufDone ) THEN
        blRolltorAb       := FALSE;
        blAnschlagAuf     := FALSE;
        steplAusschleusen := STEP_230_E;
      ELSE
        blRolltorAb       := TRUE;
        blAnschlagAuf     := TRUE;
      END_IF

    // AUSSCHLEUSEN AGV ======================
    STEP_230_E:
      (* Hinweis:
         - Freigegebenen Faecherwagen dem MMI melden
      *)
      wSps2FaecherwagenStart := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
      MsgToMmi( auftragsnr_w := SB0_SPS_SortierungRackinPos );

      steplAusschleusen := STEP_1000_E;

    // AUSSCHLEUSEN ==========================
    STEP_900_E:
      blHubrahmenSenken     := FALSE;
      blFaecherwagenZurueck := FALSE;
      blZentrierungOeffnen  := FALSE;
      blAnschlagAuf         := FALSE;
      blAnschlagAb          := FALSE;
      blRolltorAb           := FALSE;
      bpUmlaufVentilPause   := FALSE;
      tonlUmlaufventilPause( IN := FALSE );

      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bAustransport[cWAND_1] := FALSE;

    // AUSSCHLEUSEN ==========================
    STEP_1000_E:
      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Abgeschlossen_InGrundstellung;

      // Kein Faecherwagen mehr eingeschleust: Muting zuruecksetzen (Option AGV)
      blMutingAusschalten         := TRUE;
      bpAusschleusenAbgeschlossen := TRUE;
      BasisStationsParameter.bAustransport[cWAND_1] := FALSE;

  // AUSSCHLEUSEN ==========================
  END_CASE

ELSE

  IF ( steplAusschleusen > STEP_0_E ) THEN
    bpAusschleusenAbgeschlossen := FALSE;
    blHubrahmenHeben            := FALSE;
    blHubrahmenSenken           := FALSE;
    blFaecherwagenVor           := FALSE;
    blFaecherwagenZurueck       := FALSE;
    blZentrierungOeffnen        := FALSE;
    blZentrierungSchliessen     := FALSE;
    blAnschlagAuf               := FALSE;
    blAnschlagAb                := FALSE;
    blRolltorAuf                := FALSE;
    blRolltorAb                 := FALSE;
    bpUmlaufVentilPause         := FALSE;
    tonlUmlaufventilPause( IN := FALSE );

    steplAusschleusen := STEP_0_E;
  END_IF

END_IF
END_ACTION