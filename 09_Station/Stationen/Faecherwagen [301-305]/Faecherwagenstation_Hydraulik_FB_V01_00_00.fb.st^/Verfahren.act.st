(* METADATA
{
	"v3Meta": {
		"objectGuid": "1a90b67d-eadb-42b7-b00d-35bfd6d27b92"
	}
}
*)
ACTION Verfahren
//-------------------------------------------------------------------------------------------------
// FAECHERWAGEN VOR (in die Station)
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Nur bei offenem Rolltor (oder ohne Rolltor), mit offener Zentrierung und oben stehendem Hubrahmen
*)
IF     blFaecherwagenVor
   AND NOT blFaecherwagenZurueck
   AND (    NOT BasisStationsParameter.stMKs.stStationsAufbau.bRolltor
         OR in_bRolltorGeoeffnet )
   AND BasisStationsParameter.bFreigabe
THEN
  CASE steplFaecherwagenVor OF
    // FAECHERWAGEN VOR =============================
    STEP_0_E:
      blFaecherwagenVorDone := FALSE;
      tonlTimeoutVerfahren( IN := FALSE );
      tonlVerfahrenUeberfahren( IN := FALSE );

      IF in_bFaecherwagenVorne THEN
        steplFaecherwagenVor := STEP_1000_E;
      ELSE
        steplFaecherwagenVor := STEP_5_E;
      END_IF

    // FAECHERWAGEN VOR =============================
    STEP_5_E:
      // Voraussetzungen pruefen, auf das Hydraulikaggregat warten
      tonlTimeoutVerfahren( IN := NOT blHydraulikLaeuft, PT := ZEIT_TIMEOUT_HYDRAULIK );

      IF NOT in_bZentrierungOffen THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_VORFAHREN_ZENTRIERUNG_NICHT_OFFEN;
        steplFaecherwagenVor := STEP_900_E;

      ELSIF NOT in_bHubrahmenOben THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_VORFAHREN_STATION_NICHT_OBEN;
        steplFaecherwagenVor := STEP_900_E;

      ELSIF blHydraulikLaeuft THEN
        tonlTimeoutVerfahren( IN := FALSE );
        out_bFaecherwagenVor     := TRUE;
        out_bFaecherwagenZurueck := FALSE;
        steplFaecherwagenVor     := STEP_10_E;

      ELSIF tonlTimeoutVerfahren.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_HYDRAULIK_LAEUFT_NICHT;
        steplFaecherwagenVor := STEP_900_E;
      END_IF

    // FAECHERWAGEN VOR =============================
    STEP_10_E:
      out_bFaecherwagenVor     := TRUE;
      out_bFaecherwagenZurueck := FALSE;

      tonlTimeoutVerfahren( IN := NOT in_bFaecherwagenVorne, PT := ZEIT_TIMEOUT_SENSOR );
      tonlVerfahrenUeberfahren( IN := in_bFaecherwagenVorne, PT := ZEIT_SENSOR_UEBERFAHREN );

      IF tonlVerfahrenUeberfahren.Q THEN
        out_bFaecherwagenVor := FALSE;
        steplFaecherwagenVor := STEP_1000_E;
      END_IF

      // Fehler:
      //   - Zentrierung oder Hubrahmen verlassen die Endlage, Sensor vorne schaltet nicht
      IF NOT in_bZentrierungOffen THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_VORFAHREN_ZENTRIERUNG_NICHT_OFFEN;
        steplFaecherwagenVor := STEP_900_E;
      ELSIF NOT in_bHubrahmenOben THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_VORFAHREN_STATION_NICHT_OBEN;
        steplFaecherwagenVor := STEP_900_E;
      ELSIF tonlTimeoutVerfahren.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_SENSOR_VORNE_SCHALTET_NICHT;
        steplFaecherwagenVor := STEP_900_E;
      END_IF

    // FAECHERWAGEN VOR =============================
    STEP_900_E:
      // Fehler einmalig melden, Fehler bleibt bis Reset
      IF ( NOT BasisStationsParameter.bFehler ) THEN
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );
      END_IF

      out_bFaecherwagenVor := FALSE;
      BasisStationsParameter.bFehler := TRUE;

    // FAECHERWAGEN VOR =============================
    STEP_1000_E:
      blFaecherwagenVorDone := TRUE;

  // FAECHERWAGEN VOR =============================
  END_CASE
ELSE

  IF ( steplFaecherwagenVor > STEP_0_E ) THEN
    out_bFaecherwagenVor  := FALSE;
    blFaecherwagenVorDone := FALSE;
    tonlTimeoutVerfahren( IN := FALSE );
    tonlVerfahrenUeberfahren( IN := FALSE );
    steplFaecherwagenVor  := STEP_0_E;
  END_IF

END_IF

//-------------------------------------------------------------------------------------------------
// FAECHERWAGEN ZURUECK (aus der Station)
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Nur mit offener Zentrierung und oben stehendem Hubrahmen
*)
IF     blFaecherwagenZurueck
   AND NOT blFaecherwagenVor
   AND BasisStationsParameter.bFreigabe
THEN
  CASE steplFaecherwagenZurueck OF
    // FAECHERWAGEN ZURUECK =============================
    STEP_0_E:
      blFaecherwagenZurueckDone := FALSE;
      tonlTimeoutVerfahren( IN := FALSE );
      tonlVerfahrenUeberfahren( IN := FALSE );

      IF in_bFaecherwagenHinten THEN
        steplFaecherwagenZurueck := STEP_1000_E;
      ELSE
        steplFaecherwagenZurueck := STEP_5_E;
      END_IF

    // FAECHERWAGEN ZURUECK =============================
    STEP_5_E:
      // Voraussetzungen pruefen, auf das Hydraulikaggregat warten
      tonlTimeoutVerfahren( IN := NOT blHydraulikLaeuft, PT := ZEIT_TIMEOUT_HYDRAULIK );

      IF NOT in_bZentrierungOffen THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_ZURUECKFAHREN_ZENTRIERUNG_NICHT_OFFEN;
        steplFaecherwagenZurueck := STEP_900_E;

      ELSIF NOT in_bHubrahmenOben THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_ZURUECKFAHREN_STATION_NICHT_OBEN;
        steplFaecherwagenZurueck := STEP_900_E;

      ELSIF blHydraulikLaeuft THEN
        tonlTimeoutVerfahren( IN := FALSE );
        out_bFaecherwagenVor     := FALSE;
        out_bFaecherwagenZurueck := TRUE;
        steplFaecherwagenZurueck := STEP_10_E;

      ELSIF tonlTimeoutVerfahren.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_HYDRAULIK_LAEUFT_NICHT;
        steplFaecherwagenZurueck := STEP_900_E;
      END_IF

    // FAECHERWAGEN ZURUECK =============================
    STEP_10_E:
      out_bFaecherwagenVor     := FALSE;
      out_bFaecherwagenZurueck := TRUE;

      tonlTimeoutVerfahren( IN := NOT in_bFaecherwagenHinten, PT := ZEIT_TIMEOUT_SENSOR );
      tonlVerfahrenUeberfahren( IN := in_bFaecherwagenHinten, PT := ZEIT_SENSOR_UEBERFAHREN );

      IF tonlVerfahrenUeberfahren.Q THEN
        out_bFaecherwagenZurueck := FALSE;
        steplFaecherwagenZurueck := STEP_1000_E;
      END_IF

      // Fehler:
      //   - Zentrierung oder Hubrahmen verlassen die Endlage, Sensor hinten schaltet nicht
      IF NOT in_bZentrierungOffen THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_ZURUECKFAHREN_ZENTRIERUNG_NICHT_OFFEN;
        steplFaecherwagenZurueck := STEP_900_E;
      ELSIF NOT in_bHubrahmenOben THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_ZURUECKFAHREN_STATION_NICHT_OBEN;
        steplFaecherwagenZurueck := STEP_900_E;
      ELSIF tonlTimeoutVerfahren.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_SENSOR_HINTEN_SCHALTET_NICHT;
        steplFaecherwagenZurueck := STEP_900_E;
      END_IF

    // FAECHERWAGEN ZURUECK =============================
    STEP_900_E:
      // Fehler einmalig melden, Fehler bleibt bis Reset
      IF ( NOT BasisStationsParameter.bFehler ) THEN
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );
      END_IF

      out_bFaecherwagenZurueck := FALSE;
      BasisStationsParameter.bFehler := TRUE;

    // FAECHERWAGEN ZURUECK =============================
    STEP_1000_E:
      blFaecherwagenZurueckDone := TRUE;

  // FAECHERWAGEN ZURUECK =============================
  END_CASE
ELSE

  IF ( steplFaecherwagenZurueck > STEP_0_E ) THEN
    out_bFaecherwagenZurueck  := FALSE;
    blFaecherwagenZurueckDone := FALSE;
    tonlTimeoutVerfahren( IN := FALSE );
    tonlVerfahrenUeberfahren( IN := FALSE );
    steplFaecherwagenZurueck  := STEP_0_E;
  END_IF

END_IF
END_ACTION