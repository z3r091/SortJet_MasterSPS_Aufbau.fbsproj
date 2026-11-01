(* METADATA
{
  "v3Meta": {
    "objectGuid": "46804bb7-71c6-4285-b15f-60ef185f7615"
  }
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// AKTION RESET
//-------------------------------------------------------------------------------------------------
tonlMaxWarteAufResetErfolgreich(IN:=(BasisStationsParameter.bReset AND (steplReset < STEP_900_E)),pt:=tgMaxWartezeitReset);

IF ( BasisStationsParameter.bReset ) THEN
  CASE steplReset OF
    // RESET ==============================
    STEP_0_E:
      Glastransport.bpAustransport := FALSE;
      Glastransport.bpEintransport := FALSE;
      Glastransport.bpVortransport := FALSE;

      blHinweisGenerierenSKAusgeloest := FALSE;

      ReservierungsStatus := TS_KEINE_RESERVIERUNG;

      BasisStationsParameter.bQuittungPositionierungZurueckgesetzt := FALSE;

      steplReset := STEP_10_E;

    // RESET ==============================
    STEP_10_E:
      (* Hinweis:
         - Baustein- Betriebsarten zuruecksetzen
      *)
      BasisStationsParameter.bEintransport[cWAND_1] := FALSE;
      BasisStationsParameter.bAustransport[cWAND_1] := FALSE;
      BasisStationsParameter.bVortransport[cWAND_1] := FALSE;

      steplReset := STEP_20_E;

    // RESET ==============================
    STEP_20_E:
      // Hinwies:
      //   - Bausteine zuruecksetzen
      Glastransport.bpReset     := TRUE;
      Querfahrt.bpReset  := TRUE;
      Zentralschmierung.bpReset := TRUE;

      steplReset := STEP_30_E;

    // RESET ==============================
    STEP_30_E:
      (* Hinweis:
         - Bausteinreset abgeschlossen
      *)
      IF (  Glastransport.bpDone
           AND Querfahrt.bpDone )
      THEN
        Glastransport.bpReset := FALSE;
        Querfahrt.bpReset  := FALSE;

        steplReset := STEP_1000_E;
      END_IF

      (* Hinweis:
         - Rest wurde nicht in der definierten Zeit abgeschlossen
      *)
      IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN

        Glastransport.bpReset            := FALSE;
        Querfahrt.bpReset  := FALSE;

        BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_NICHT_ZURUECKGESETZT;
        SpsError( eFehler_Station,
                  cMELDUNG_STATION_NICHT_ZURUECKGESETZT,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerSPS,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsparameter.awFehlerInformationen );

        steplReset := STEP_900_E;

        IF ( NOT Glastransport.bpDone OR Glastransport.bpFehler ) THEN
          Glastransport.bpReset := TRUE;
          BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
          SpsError( eFehler_Station,
                    BasisStationsParameter.wFehlerNummer,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerSPS,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    BasisStationsparameter.awFehlerInformationen );
        END_IF

        IF ( NOT Querfahrt.bpDone OR Querfahrt.bpFehler ) THEN
          Querfahrt.bpReset := FALSE;
          BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
          SpsError( eFehler_Station,
                    BasisStationsParameter.wFehlerNummer,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerSPS,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    BasisStationsparameter.awFehlerInformationen );
        END_IF

      END_IF

    // RESET ==============================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bReset := FALSE;

    // RESET ==============================
    STEP_1000_E:
      BasisStationsParameter.wFehlerNummer := cMELDUNG_NULL;
      BasisStationsParameter.bFehler := FALSE;
      BasisStationsParameter.bReset := FALSE;

  // RESET ==============================
  END_CASE
ELSE
  // Reset wegen Abbruch der Schrittkette
  IF( steplReset > STEP_0_E )THEN

    Glastransport.bpReset     := FALSE;
    Querfahrt.bpReset  := FALSE;

    Zentralschmierung.bpReset := FALSE;
    tonlMaxWarteAufResetErfolgreich( IN := FALSE );
    steplReset := STEP_0_E;
  END_IF
END_IF
END_ACTION