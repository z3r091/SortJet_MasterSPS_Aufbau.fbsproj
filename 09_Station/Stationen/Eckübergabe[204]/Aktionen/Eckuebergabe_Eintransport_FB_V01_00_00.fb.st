(* METADATA
{
  "v3Meta": {
    "objectGuid": "b3b83d22-15dc-44d1-82f1-6860a5f4b14c"
  }
}
*)
FUNCTION_BLOCK Eckuebergabe_Eintransport_FB_V01_00_00 EXTENDS Basic_Station_Eintransport_FB_V01_00_00
VAR_IN_OUT

  // Anforderung an den Hubrahmen der Station
  blHubrahmenPositionieren : BOOL;
  elHubrahmenZielAchse     : Achsrichtung_EN;

END_VAR
VAR_INPUT

  // BOOL
  bpHubrahmenInPosition : BOOL; // Hubrahmen steht auf der angeforderten Achse

  // ENUM
  elAchseEintransport : Achsrichtung_EN; // Achse des aktuellen Eintransports (Auftrag)
  elAchseAustransport : Achsrichtung_EN; // Achse fuer den Austransport (Schnittstellendaten)

  // Bausteine
  Glastransport_X  : REFERENCE TO Eckuebergabe_Glastransport_FB_V01_00_00;
  Glastransport_Y  : REFERENCE TO Eckuebergabe_Glastransport_FB_V01_00_00;
  GlastransportEin : REFERENCE TO Eckuebergabe_Glastransport_FB_V01_00_00; // Achse des aktuellen Eintransports
  GlastransportAus : REFERENCE TO Eckuebergabe_Glastransport_FB_V01_00_00; // Austransport-Achse
  Hubrahmen        : REFERENCE TO ZylinderPneumatik_FB_V01_00_00;

END_VAR
//-------------------------------------------------------------------------------------------------
// EINTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bEintransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport_X.bpFehler ) THEN
    Glastransport_X.bpEintransport             := FALSE;
    Glastransport_X.bpEintransportRueckwaertig := FALSE;
    Glastransport_X.bpVortransport             := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_X.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Glastransport_Y.bpFehler ) THEN
    Glastransport_Y.bpEintransport             := FALSE;
    Glastransport_Y.bpEintransportRueckwaertig := FALSE;
    Glastransport_Y.bpVortransport             := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_Y.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Hubrahmen.bpFehler ) THEN
    blHubrahmenPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // EINTRANSPORT =====================
    STEP_0_E:
      (* Hinweis:
         - Hubrahmen auf die Eintransport-Achse stellen
      *)
      bpFehler := FALSE;

      elHubrahmenZielAchse     := elAchseEintransport;
      blHubrahmenPositionieren := TRUE;

      steplAktion := STEP_10_E;

    // EINTRANSPORT =====================
    STEP_10_E:
      IF ( bpHubrahmenInPosition ) THEN
        blHubrahmenPositionieren := FALSE;

        steplAktion := STEP_100_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES EINTRANSPORTS
      //
      //  Hinweis:
      //  - Eintransport ueber die Achse aus dem Auftrag
      // ---------------------------------------------------------------------------------------
      GlastransportEin.bpScheibentrennen          := BasisStationsParameter.bScheibentrennen[wWand];
      GlastransportEin.pAuftrag                   := BasisStationsParameter.pAuftrag[wWand];
      GlastransportEin.bpEintransport             := BasisStationsParameter.bEintransport[wWand] AND NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      GlastransportEin.bpEintransportRueckwaertig := BasisStationsParameter.bEintransport[wWand] AND     BasisStationsParameter.bRueckwaertsTransportieren[wWand];

      steplAktion := STEP_110_E;

    // EINTRANSPORT =====================
    STEP_110_E:
      IF ( GlastransportEin.bpDone ) THEN
        GlastransportEin.bpEintransport             := FALSE;
        GlastransportEin.bpEintransportRueckwaertig := FALSE;

        IF ( elAchseEintransport = elAchseAustransport ) THEN
          steplAktion := STEP_1000_E;
        ELSE
          steplAktion := STEP_200_E;
        END_IF
      END_IF

    // EINTRANSPORT =====================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  UEBERGABE AN DIE AUSTRANSPORT-ACHSE
      //
      //  Hinweis:
      //  - Hubrahmen auf die Austransport-Achse stellen
      // ---------------------------------------------------------------------------------------
      elHubrahmenZielAchse     := elAchseAustransport;
      blHubrahmenPositionieren := TRUE;

      steplAktion := STEP_210_E;

    // EINTRANSPORT =====================
    STEP_210_E:
      IF ( bpHubrahmenInPosition ) THEN
        blHubrahmenPositionieren := FALSE;

        steplAktion := STEP_220_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_220_E:
      (* Hinweis:
         - Austransport-Achse uebernimmt die Scheibe und faehrt sie auf den VorStop- Sensor
      *)
      GlastransportAus.pAuftrag       := BasisStationsParameter.pAuftrag[wWand];
      GlastransportAus.bpVortransport := TRUE;

      steplAktion := STEP_230_E;

    // EINTRANSPORT =====================
    STEP_230_E:
      IF ( GlastransportAus.bpDone ) THEN
        GlastransportAus.bpVortransport := FALSE;

        steplAktion := STEP_1000_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // EINTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bEintransportAbgeschlossen[wWand] := TRUE;

  // EINTRANSPORT =====================
  END_CASE
ELSE

  IF ( steplAktion > STEP_0_E ) THEN
    bpFehler := FALSE;
    BasisStationsParameter.bEintransportAbgeschlossen[wWand] := FALSE;

    Glastransport_X.bpEintransport             := FALSE;
    Glastransport_X.bpEintransportRueckwaertig := FALSE;
    Glastransport_X.bpVortransport             := FALSE;
    Glastransport_Y.bpEintransport             := FALSE;
    Glastransport_Y.bpEintransportRueckwaertig := FALSE;
    Glastransport_Y.bpVortransport             := FALSE;
    blHubrahmenPositionieren                   := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK