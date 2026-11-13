(* METADATA
{
	"v3Meta": {
		"objectGuid": "db133b7b-c5ef-4a5f-a67a-e8a200ede397"
	}
}
*)
ACTION Zentrierung
//-------------------------------------------------------------------------------------------------
// ZENTRIERUNG OEFFNEN
//-------------------------------------------------------------------------------------------------
IF     blZentrierungOeffnen
   AND NOT blZentrierungSchliessen
   AND BasisStationsParameter.bFreigabe
THEN
  CASE steplZentrierungOeffnen OF
    // ZENTRIERUNG OEFFNEN =============================
    STEP_0_E:
      blZentrierungOeffnenDone := FALSE;
      tonlTimeoutZentrierung( IN := FALSE );
      tonlZentrierungUeberfahren( IN := FALSE );

      IF in_bZentrierungOffen THEN
        steplZentrierungOeffnen := STEP_1000_E;
      ELSE
        steplZentrierungOeffnen := STEP_5_E;
      END_IF

    // ZENTRIERUNG OEFFNEN =============================
    STEP_5_E:
      // Auf das Hydraulikaggregat warten
      tonlTimeoutZentrierung( IN := NOT blHydraulikLaeuft, PT := ZEIT_TIMEOUT_HYDRAULIK );

      IF blHydraulikLaeuft THEN
        tonlTimeoutZentrierung( IN := FALSE );
        out_bZentrierungOeffnen    := TRUE;
        out_bZentrierungSchliessen := FALSE;
        steplZentrierungOeffnen    := STEP_10_E;

      ELSIF tonlTimeoutZentrierung.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_HYDRAULIK_LAEUFT_NICHT;
        steplZentrierungOeffnen := STEP_900_E;
      END_IF

    // ZENTRIERUNG OEFFNEN =============================
    STEP_10_E:
      out_bZentrierungOeffnen    := TRUE;
      out_bZentrierungSchliessen := FALSE;

      tonlTimeoutZentrierung( IN := NOT in_bZentrierungOffen, PT := ZEIT_TIMEOUT_SENSOR );
      tonlZentrierungUeberfahren( IN := in_bZentrierungOffen, PT := ZEIT_SENSOR_UEBERFAHREN );

      IF tonlZentrierungUeberfahren.Q THEN
        out_bZentrierungOeffnen := FALSE;
        steplZentrierungOeffnen := STEP_1000_E;
      END_IF

      // Fehler:
      //   - Zentrierung nicht in der Zeit offen
      IF tonlTimeoutZentrierung.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_UEBERWACHUNG_ZENTRIERUNG_OEFFNEN;
        steplZentrierungOeffnen := STEP_900_E;
      END_IF

    // ZENTRIERUNG OEFFNEN =============================
    STEP_900_E:
      // Fehler einmalig melden, Fehler bleibt bis Reset
      IF ( NOT BasisStationsParameter.bFehler ) THEN
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );
      END_IF

      out_bZentrierungOeffnen := FALSE;
      BasisStationsParameter.bFehler := TRUE;

    // ZENTRIERUNG OEFFNEN =============================
    STEP_1000_E:
      blZentrierungOeffnenDone := TRUE;

  // ZENTRIERUNG OEFFNEN =============================
  END_CASE
ELSE

  IF ( steplZentrierungOeffnen > STEP_0_E ) THEN
    out_bZentrierungOeffnen  := FALSE;
    blZentrierungOeffnenDone := FALSE;
    tonlTimeoutZentrierung( IN := FALSE );
    tonlZentrierungUeberfahren( IN := FALSE );
    steplZentrierungOeffnen  := STEP_0_E;
  END_IF

END_IF

//-------------------------------------------------------------------------------------------------
// ZENTRIERUNG SCHLIESSEN
//-------------------------------------------------------------------------------------------------
IF     blZentrierungSchliessen
   AND NOT blZentrierungOeffnen
   AND BasisStationsParameter.bFreigabe
THEN
  CASE steplZentrierungSchliessen OF
    // ZENTRIERUNG SCHLIESSEN =============================
    STEP_0_E:
      blZentrierungSchliessenDone := FALSE;
      tonlTimeoutZentrierung( IN := FALSE );
      tonlZentrierungUeberfahren( IN := FALSE );

      IF in_bZentrierungGeschlossen THEN
        steplZentrierungSchliessen := STEP_1000_E;
      ELSE
        steplZentrierungSchliessen := STEP_5_E;
      END_IF

    // ZENTRIERUNG SCHLIESSEN =============================
    STEP_5_E:
      // Auf das Hydraulikaggregat warten
      tonlTimeoutZentrierung( IN := NOT blHydraulikLaeuft, PT := ZEIT_TIMEOUT_HYDRAULIK );

      IF blHydraulikLaeuft THEN
        tonlTimeoutZentrierung( IN := FALSE );
        out_bZentrierungOeffnen    := FALSE;
        out_bZentrierungSchliessen := TRUE;
        steplZentrierungSchliessen := STEP_10_E;

      ELSIF tonlTimeoutZentrierung.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_HYDRAULIK_LAEUFT_NICHT;
        steplZentrierungSchliessen := STEP_900_E;
      END_IF

    // ZENTRIERUNG SCHLIESSEN =============================
    STEP_10_E:
      out_bZentrierungOeffnen    := FALSE;
      out_bZentrierungSchliessen := TRUE;

      tonlTimeoutZentrierung( IN := NOT in_bZentrierungGeschlossen, PT := ZEIT_TIMEOUT_SENSOR );
      tonlZentrierungUeberfahren( IN := in_bZentrierungGeschlossen, PT := ZEIT_SENSOR_UEBERFAHREN );

      IF tonlZentrierungUeberfahren.Q THEN
        out_bZentrierungSchliessen := FALSE;
        steplZentrierungSchliessen := STEP_1000_E;
      END_IF

      // Fehler:
      //   - Zentrierung nicht in der Zeit geschlossen
      IF tonlTimeoutZentrierung.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_UEBERWACHUNG_ZENTRIERUNG_SCHLIESSEN;
        steplZentrierungSchliessen := STEP_900_E;
      END_IF

    // ZENTRIERUNG SCHLIESSEN =============================
    STEP_900_E:
      // Fehler einmalig melden, Fehler bleibt bis Reset
      IF ( NOT BasisStationsParameter.bFehler ) THEN
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );
      END_IF

      out_bZentrierungSchliessen := FALSE;
      BasisStationsParameter.bFehler := TRUE;

    // ZENTRIERUNG SCHLIESSEN =============================
    STEP_1000_E:
      blZentrierungSchliessenDone := TRUE;

  // ZENTRIERUNG SCHLIESSEN =============================
  END_CASE
ELSE

  IF ( steplZentrierungSchliessen > STEP_0_E ) THEN
    out_bZentrierungSchliessen  := FALSE;
    blZentrierungSchliessenDone := FALSE;
    tonlTimeoutZentrierung( IN := FALSE );
    tonlZentrierungUeberfahren( IN := FALSE );
    steplZentrierungSchliessen  := STEP_0_E;
  END_IF

END_IF
END_ACTION