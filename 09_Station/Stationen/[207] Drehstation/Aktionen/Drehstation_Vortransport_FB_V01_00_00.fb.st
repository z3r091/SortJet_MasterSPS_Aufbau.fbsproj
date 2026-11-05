(* METADATA
{
  "v3Meta": {
    "objectGuid": "64fb0dc5-1160-4980-b132-1d54e53c3073"
  }
}
*)
FUNCTION_BLOCK Drehstation_Vortransport_FB_V01_00_00 EXTENDS Basic_Station_Vortransport_FB_V01_00_00
VAR_INPUT

  // Bausteine
  Drehen : REFERENCE TO Drehstation_Drehen_FB_V01_00_00;

END_VAR
//-------------------------------------------------------------------------------------------------
// AKTION VORTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bVortransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpVortransport := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // VORTRANSPORT =====================
    STEP_0_E:
      bpFehler := FALSE;
      BasisStationsParameter.bVortransportAbgeschlossen[wWand] := FALSE;
      steplAktion := STEP_10_E;

    // VORTRANSPORT =====================
    STEP_10_E:
      (* Hinweis:
         - Starten des Vortransports
      *)
      CASE Drehen.epDrehPositionsStatus OF

        eDrehPosition0Grad:
          Glastransport.bpVortransport := TRUE;

        eDrehPosition180Grad:
          Glastransport.bpVortransportRueckwaertig := TRUE;

      END_CASE

      steplAktion := STEP_20_E;

    // VORTRANSPORT =====================
    STEP_20_E:
      (* Anmerkung:
         - Vortransport abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpVortransport := FALSE;
        Glastransport.bpVortransportRueckwaertig := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

    // VORTRANSPORT =====================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // VORTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bVortransportAbgeschlossen[wWand] := TRUE;

  // VORTRANSPORT =====================
  END_CASE
ELSE
  IF (steplAktion > STEP_0_E) THEN
    bpFehler := FALSE;
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;

    BasisStationsParameter.bVortransportAbgeschlossen[wWand] := FALSE;

    steplAktion := STEP_0_E;
  END_IF
END_IF
END_FUNCTION_BLOCK