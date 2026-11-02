(* METADATA
{
  "v3Meta": {
    "objectGuid": "97af2700-c40f-4fdd-8191-020abad55f4e"
  }
}
*)
ACTION Austransport
//-------------------------------------------------------------------------------------------------
// AKTION: AUSTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bAustransport[cWAND_1]
     AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpAustransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF
 
  IF ( Hubrahmen.bpFehler ) THEN
    Hubrahmen.bpStartAusfahren := FALSE;
    BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr; 
    steplAustransport := STEP_900_E;
  END_IF
  
  
  CASE steplAustransport OF
    // AUSTRANSPORT ==============================
    STEP_0_E:
      (* Hinweis:
         - -
      *)
      blMerkerDrosselklappeAuf := FALSE;
      Hubrahmen.bpStartAusfahren := NOT ( Hubrahmen.epStatusZylinder = eZylinderAusgefahren );

      steplAustransport := STEP_10_E;

    // AUSTRANSPORT ==============================
    STEP_10_E:
      (* Anmerkung:
         - Hubpalette heben
      *)
      IF (  Hubrahmen.bpDone OR NOT Hubrahmen.bpStartAusfahren ) THEN
        Hubrahmen.bpStartAusfahren   := FALSE;
        Glastransport.bpAustransport := TRUE;
        steplAustransport := STEP_30_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_30_E:
      (* Hinweis:
         - Hubrahmen absenken wenn die Sensorik frei geworden ist
      *)
      IF Glastransport.bpSensorAuslauf THEN
        steplAustransport := STEP_40_E;
      END_IF

      IF ( Glastransport.bpDone ) THEN
        Hubrahmen.bpStartEinfahren   := TRUE;
        Glastransport.bpAustransport := FALSE;
        steplAustransport := STEP_1000_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_40_E:
      (* Hinweis:
         - Hubrahmen absenken wenn die Sensorik frei geworden ist
      *)
      IF (  NOT Glastransport.bpSensorAuslauf
           AND NOT BasisStationsParameter.InGlasTransportNachfolger[cWAND_1].bEinlaufsensor )
      THEN
        Hubrahmen.bpStartEinfahren       := TRUE;
      END_IF

      IF ( Glastransport.bpDone ) THEN
        Hubrahmen.bpStartEinfahren       := TRUE;
        Glastransport.bpAustransport     := FALSE;
        steplAustransport := STEP_1000_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_100_E:
      (* Anmerkung:
         - Hubpalette senken
      *)
      IF (  Hubrahmen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        steplAustransport := STEP_1000_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;

    // AUSTRANSPORT ==============================
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := TRUE;

  // AUSTRANSPORT ==============================
  END_CASE
ELSE

  IF ( steplAustransport > STEP_0_E ) THEN

    Glastransport.bpAustransport := FALSE;

    Hubrahmen.bpStartEinfahren := FALSE;
    Hubrahmen.bpStartAusfahren := FALSE;

    BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;

    steplAustransport := STEP_0_E;
  END_IF

END_IF
END_ACTION