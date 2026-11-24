(* METADATA
{
	"v3Meta": {
		"objectGuid": "696e4787-fd05-46bc-b8d0-f801ca5a2601"
	}
}
*)
ACTION Ausschleusen
//-------------------------------------------------------------------------------------------------
// AUSSCHLEUSEN
//-------------------------------------------------------------------------------------------------

// Optimierung: Nach dem letzten Rausschieben (STEP_125) und Greifer offen (STEP_135) faehrt das Rolltor
// schon runter, waehrend die Lineareinheit zurueckfaehrt (STEP_140).
blRolltorAbBeiLinZurueck :=     BasisStationsParameter.bAustransport[1]
                            AND ( steplAusschleusen = STEP_140_E )
                            AND blLineareinheitZurueck
                            AND blGreiferOffen;

IF BasisStationsParameter.bAustransport[1] AND
   ( blBetriebsartAutomatik OR
     blBetriebsartHand OR
     blBetriebartCheck )
THEN

  IF BasisStationsParameter.bFehler THEN
    steplAusschleusen := STEP_900_E;
  END_IF

  CASE steplAusschleusen OF

    // AUSSCHLEUSEN ============================================================================
    STEP_0_E:
      // Anlage in Grundzustand setzen und alle Aktoren zurücknehmen
      blLineareinheitVor          := FALSE;
      blLineareinheitZurueck      := FALSE;
      blLineareinheitShuttle      := FALSE;
      blEntriegelungOeffnen       := FALSE;
      blEntriegelungSchliessen    := FALSE;
      blGegenhalterOeffnen        := FALSE;
      blGegenhalterSchliessen     := FALSE;
      blGreiferOeffnen            := FALSE;
      blGreiferSchliessen         := FALSE;
      blRolltorAuf                := FALSE;
      blRolltorAb                 := FALSE;

      bpAusschleusenAbgeschlossen := FALSE;

      tonlFreigabeZumAusschleusen( IN := FALSE );

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Starten_0;

      steplAusschleusen := STEP_10_E;

    // AUSSCHLEUSEN ============================================================================
    STEP_10_E:
      // Startbedingungen prüfen und Sicherungsfunktionen aktivieren

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Warten_Auf_Start_10;

      tonlFreigabeZumAusschleusen( IN := in_bStartSchleusen, PT := T#100MS );

      IF bpUntergestellErkannt AND bpLichtschranke_OK THEN
        blRolltorAuf            := TRUE;
        blEntriegelungOeffnen   := TRUE;
        blGegenhalterSchliessen := TRUE;
        steplAusschleusen       := STEP_100_E;
      END_IF


    // AUSSCHLEUSEN ============================================================================
    STEP_100_E:
      // Rolltor öffnen, Verriegelung öffnen und Wagen sichern

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Rolltor_Auf_Entriegeln_Festhalten_100;

      IF blRolltorAufDone AND blGegenhalterSchliessenDone AND blEntriegelungOeffnenDone THEN
        blRolltorAuf            := FALSE;
        blEntriegelungOeffnen   := FALSE;
        blGegenhalterSchliessen := FALSE;
        steplAusschleusen       := STEP_105_E;
      ELSE
        blRolltorAuf            := TRUE;
        blEntriegelungOeffnen   := TRUE;
        blGegenhalterSchliessen := TRUE;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_105_E:
      // Lineareinheit nach vorne fahren

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Lineareinheit_Vor_105;

      IF blLineareinheitVorDone THEN
        blLineareinheitVor := FALSE;
        blGreiferOeffnen   := TRUE;
        steplAusschleusen  := STEP_110_E;
      ELSE
        blLineareinheitVor := TRUE;
        blGreiferOeffnen   := FALSE;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_110_E:
      // Greifer öffnen

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Greifer_Oeffnen_110;

      IF blGreiferOeffnenDone THEN
        blGreiferOeffnen       := FALSE;
        blLineareinheitZurueck := TRUE;
        steplAusschleusen      := STEP_115_E;
      ELSE
        blGreiferOeffnen := TRUE;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_115_E:
      // Lineareinheit nach hinten fahren

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Lineareinheit_Zurueck_115;

      IF blLineareinheitZurueckDone THEN
        blLineareinheitZurueck := FALSE;
        blGreiferSchliessen    := TRUE;
        steplAusschleusen      := STEP_120_E;
      ELSE
        blLineareinheitZurueck := TRUE;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_120_E:
      // Greifer schließen

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Greifer_Schliessen_120;

      IF blGreiferSchliessenDone THEN
        blGreiferSchliessen := FALSE;
        blLineareinheitVor  := TRUE;
        steplAusschleusen   := STEP_125_E;
      ELSE
        blGreiferSchliessen := TRUE;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_125_E:
      // Lineareinheit nach vorne fahren

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Lineareinheit_Vor_125;

      IF blLineareinheitVorDone THEN
        blLineareinheitVor       := FALSE;
        blEntriegelungSchliessen := TRUE;
        steplAusschleusen        := STEP_130_E;
      ELSE
        blLineareinheitVor       := TRUE;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_130_E:
      // Verriegelung schließen

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Entrieglung_Schliessen_130;

      IF blEntriegelungSchliessenDone THEN
        blEntriegelungSchliessen := FALSE;
        blGreiferOeffnen         := TRUE;
        steplAusschleusen        := STEP_135_E;
      ELSE
        blEntriegelungSchliessen := TRUE;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_135_E:
      // Greifer öffnen

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Greifer_Oeffnen_135;

      IF blGreiferOeffnenDone THEN
        blGreiferOeffnen       := FALSE;
        blLineareinheitZurueck := TRUE;
        blRolltorAb            := TRUE; // Rolltor schon runter, parallel zum Zurueckfahren der Lineareinheit
        steplAusschleusen      := STEP_140_E;
      ELSE
        blGreiferOeffnen := TRUE;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_140_E:
      // Lineareinheit nach hinten fahren

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Lineareinheit_Zurueck_140;

      IF blLineareinheitZurueckDone THEN
        blLineareinheitZurueck := FALSE;
        IF tofTagPresent.Q THEN
          blRolltorAb            := TRUE;
          steplAusschleusen      := STEP_145_E;
        ELSE
          blRolltorAb            := FALSE; // Oberwagen evtl. nicht in Pos -> Rolltor stoppen bis Bediener quittiert (STEP_145 faehrt weiter)
          steplAusschleusen      := STEP_143_E;

          SpsWarnung( eFehler_Station,
                      cMELDUNG_FAECHERWAGEN_OBERWAGEN_INPOS_VERLOREN,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
        END_IF
      ELSE
        blLineareinheitZurueck := TRUE;
      END_IF


    // AUSSCHLEUSEN ============================================================================
    STEP_143_E:
      // Sonderfall Oberwagen womöglich nicht in Pos
      //   - Bedienereingriff erforderlich
      bpHinweisEingriffErforderlich := TRUE;


      IF rtlQuittierungEinschleusen.Q  OR tonlFWInBox.Q THEN
        steplAusschleusen := STEP_145_E;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_145_E:
      // Rolltor schließen

      bpHinweisEingriffErforderlich := FALSE;

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Rolltor_Ab_145;

      IF blRolltorAbDone THEN
        blRolltorAb          := FALSE;
        blGegenhalterOeffnen := TRUE;
        steplAusschleusen    := STEP_150_E;
      ELSE
        blRolltorAb          := TRUE;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_150_E:
      // Gegenhalter öffnen und Abschlussmeldung vorbereiten

      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Abgeschlossen_150;

      IF blGegenhalterOeffnenDone THEN
        blGegenhalterOeffnen := FALSE;

        wSps2FaecherwagenStart :=
                                 BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;

        MsgToMmi( auftragsnr_w := SB0_SPS_SortierungRackinPos );

        steplAusschleusen := STEP_1000_E;
      ELSE
        blGegenhalterOeffnen := TRUE;
      END_IF

    // AUSSCHLEUSEN ============================================================================
    STEP_900_E:
      // Fehlerzustand setzen und Ablauf stoppen
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bAustransport[1] := FALSE;

    // AUSSCHLEUSEN ============================================================================
    STEP_1000_E:
      // Ablauf abgeschlossen und Anlage in Grundstellung
      eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Abgeschlossen_InGrundstellung;

      bpAusschleusenAbgeschlossen := TRUE;
      BasisStationsParameter.bAustransport[1] := FALSE;

  END_CASE

ELSE

  IF steplAusschleusen > STEP_0_E THEN
    // Aktoren zurücksetzen und Ablauf stoppen
    bpAusschleusenAbgeschlossen := FALSE;

    blLineareinheitVor          := FALSE;
    blLineareinheitZurueck      := FALSE;
    blLineareinheitShuttle      := FALSE;
    blEntriegelungOeffnen       := FALSE;
    blEntriegelungSchliessen    := FALSE;
    blGegenhalterOeffnen        := FALSE;
    blGegenhalterSchliessen     := FALSE;
    blGreiferOeffnen            := FALSE;
    blGreiferSchliessen         := FALSE;
    blRolltorAuf                := FALSE;
    blRolltorAb                 := FALSE;

    tonlFreigabeZumAusschleusen( IN := FALSE );
    bpHinweisEingriffErforderlich := FALSE; // Bedienereingriff (STEP_143) nur fuer diese Kette

    steplAusschleusen := STEP_0_E;
  END_IF

END_IF
END_ACTION