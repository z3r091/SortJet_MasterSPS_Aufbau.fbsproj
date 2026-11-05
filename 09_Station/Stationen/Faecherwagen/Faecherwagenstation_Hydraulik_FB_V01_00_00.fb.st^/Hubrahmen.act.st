(* METADATA
{
  "v3Meta": {
    "objectGuid": "e39f1903-ad72-4a04-95b7-6142509d2a1e"
  }
}
*)
ACTION Hubrahmen
//-------------------------------------------------------------------------------------------------
// HUBRAHMEN HEBEN
//-------------------------------------------------------------------------------------------------
IF     blHubrahmenHeben
   AND NOT blHubrahmenSenken
   AND BasisStationsParameter.bFreigabe
THEN
  CASE steplHubrahmenHeben OF
    // HUBRAHMEN HEBEN =============================
    STEP_0_E:
      blHubrahmenHebenDone := FALSE;
      tonlTimeoutHubrahmen( IN := FALSE );
      tonlHubrahmenUeberfahren( IN := FALSE );

      // Bei der Positionskorrektur wird auch aus der oberen Endlage nachgehoben
      IF in_bHubrahmenOben AND NOT blPositionskorrekturAktiv THEN
        steplHubrahmenHeben := STEP_1000_E;
      ELSE
        steplHubrahmenHeben := STEP_5_E;
      END_IF

    // HUBRAHMEN HEBEN =============================
    STEP_5_E:
      // Auf das Hydraulikaggregat warten
      tonlTimeoutHubrahmen( IN := NOT blHydraulikLaeuft, PT := ZEIT_TIMEOUT_HYDRAULIK );

      IF blHydraulikLaeuft THEN
        tonlTimeoutHubrahmen( IN := FALSE );
        out_bHubrahmenHeben  := TRUE;
        out_bHubrahmenSenken := FALSE;
        steplHubrahmenHeben  := STEP_10_E;
      END_IF

      // Fehler:
      //   - Hydraulikaggregat laeuft nicht
      IF tonlTimeoutHubrahmen.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_HYDRAULIK_LAEUFT_NICHT;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplHubrahmenHeben := STEP_900_E;
      END_IF

    // HUBRAHMEN HEBEN =============================
    STEP_10_E:
      out_bHubrahmenHeben  := TRUE;
      out_bHubrahmenSenken := FALSE;

      tonlTimeoutHubrahmen( IN := NOT in_bHubrahmenOben, PT := ZEIT_TIMEOUT_SENSOR );

      IF blPositionskorrekturAktiv THEN
        tonlHubrahmenUeberfahren( IN := TRUE, PT := ZEIT_POSITIONSKORREKTUR );
      ELSE
        tonlHubrahmenUeberfahren( IN := in_bHubrahmenOben, PT := ZEIT_SENSOR_UEBERFAHREN );
      END_IF

      IF tonlHubrahmenUeberfahren.Q AND in_bHubrahmenOben THEN
        out_bHubrahmenHeben := FALSE;
        steplHubrahmenHeben := STEP_1000_E;
      END_IF

      // Fehler:
      //   - Sensor oben schaltet nicht
      IF tonlTimeoutHubrahmen.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_SENSOR_OBEN_SCHALTET_NICHT;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplHubrahmenHeben := STEP_900_E;
      END_IF

    // HUBRAHMEN HEBEN =============================
    STEP_900_E:
      out_bHubrahmenHeben := FALSE;
      BasisStationsParameter.bFehler := TRUE;

    // HUBRAHMEN HEBEN =============================
    STEP_1000_E:
      blHubrahmenHebenDone := TRUE;

  // HUBRAHMEN HEBEN =============================
  END_CASE
ELSE

  IF ( steplHubrahmenHeben > STEP_0_E ) THEN
    out_bHubrahmenHeben  := FALSE;
    blHubrahmenHebenDone := FALSE;
    tonlTimeoutHubrahmen( IN := FALSE );
    tonlHubrahmenUeberfahren( IN := FALSE );
    steplHubrahmenHeben  := STEP_0_E;
  END_IF

END_IF

//-------------------------------------------------------------------------------------------------
// HUBRAHMEN SENKEN
//-------------------------------------------------------------------------------------------------
IF     blHubrahmenSenken
   AND NOT blHubrahmenHeben
   AND BasisStationsParameter.bFreigabe
THEN
  CASE steplHubrahmenSenken OF
    // HUBRAHMEN SENKEN =============================
    STEP_0_E:
      blHubrahmenSenkenDone := FALSE;
      tonlTimeoutHubrahmen( IN := FALSE );
      tonlHubrahmenUeberfahren( IN := FALSE );

      IF in_bHubrahmenUnten THEN
        steplHubrahmenSenken := STEP_1000_E;
      ELSE
        steplHubrahmenSenken := STEP_5_E;
      END_IF

    // HUBRAHMEN SENKEN =============================
    STEP_5_E:
      // Senken nur in der hinteren Position, auf das Hydraulikaggregat warten
      tonlTimeoutHubrahmen( IN := NOT blHydraulikLaeuft, PT := ZEIT_TIMEOUT_HYDRAULIK );

      IF NOT in_bFaecherwagenHinten THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_SENKEN_HINTERE_POSITION;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplHubrahmenSenken := STEP_900_E;

      ELSIF blHydraulikLaeuft THEN
        tonlTimeoutHubrahmen( IN := FALSE );
        out_bHubrahmenHeben  := FALSE;
        out_bHubrahmenSenken := TRUE;
        steplHubrahmenSenken := STEP_10_E;

      ELSIF tonlTimeoutHubrahmen.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_HYDRAULIK_LAEUFT_NICHT;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplHubrahmenSenken := STEP_900_E;
      END_IF

    // HUBRAHMEN SENKEN =============================
    STEP_10_E:
      out_bHubrahmenHeben  := FALSE;
      out_bHubrahmenSenken := TRUE;

      tonlTimeoutHubrahmen( IN := NOT in_bHubrahmenUnten, PT := ZEIT_TIMEOUT_SENSOR );
      tonlHubrahmenUeberfahren( IN := in_bHubrahmenUnten, PT := ZEIT_SENSOR_UEBERFAHREN );

      IF tonlHubrahmenUeberfahren.Q THEN
        out_bHubrahmenSenken := FALSE;
        steplHubrahmenSenken := STEP_1000_E;
      END_IF

      // Fehler:
      //   - Sensor unten schaltet nicht
      IF tonlTimeoutHubrahmen.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_SENSOR_UNTEN_SCHALTET_NICHT;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplHubrahmenSenken := STEP_900_E;
      END_IF

    // HUBRAHMEN SENKEN =============================
    STEP_900_E:
      out_bHubrahmenSenken := FALSE;
      BasisStationsParameter.bFehler := TRUE;

    // HUBRAHMEN SENKEN =============================
    STEP_1000_E:
      blHubrahmenSenkenDone := TRUE;

  // HUBRAHMEN SENKEN =============================
  END_CASE
ELSE

  IF ( steplHubrahmenSenken > STEP_0_E ) THEN
    out_bHubrahmenSenken  := FALSE;
    blHubrahmenSenkenDone := FALSE;
    tonlTimeoutHubrahmen( IN := FALSE );
    tonlHubrahmenUeberfahren( IN := FALSE );
    steplHubrahmenSenken  := STEP_0_E;
  END_IF

END_IF
END_ACTION