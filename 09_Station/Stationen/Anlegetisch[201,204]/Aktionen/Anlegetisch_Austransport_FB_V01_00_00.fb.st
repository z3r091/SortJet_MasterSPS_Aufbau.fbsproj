(* METADATA
{
  "v3Meta": {
    "objectGuid": "29c6a30c-ea89-4d6e-bcb0-e2d154ff9fe9"
  }
}
*)
FUNCTION_BLOCK Anlegetisch_Austransport_FB_V01_00_00 EXTENDS Basic_Station_Austransport_FB_V01_00_00
(* Hinweis:
   - Austransport des Anlegetisches: Hubrahmen ausfahren, Austransport, Hubrahmen absenken, sobald die Sensorik
     frei ist, danach die Achsen des Glastransports abnullen
   - Der Rumpf ersetzt den Rumpf des Basic-Austransports, die Komponenten (Glastransport) kommen vom Basic-Baustein
*)
VAR_INPUT

  // Bausteine
  Hubrahmen : REFERENCE TO ZylinderPneumatik_Riemen_FB_V01_00_00;

END_VAR
//-------------------------------------------------------------------------------------------------
// AKTION: AUSTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bAustransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpAustransport := FALSE;
    Glastransport.bpReferenz     := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF
 
  IF ( Hubrahmen.bpFehler ) THEN
    Hubrahmen.bpStartAusfahren := FALSE;
    BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr; 
    steplAktion := STEP_900_E;
  END_IF
  
  
  CASE steplAktion OF
    // AUSTRANSPORT ==============================
    STEP_0_E:
      (* Hinweis:
         - -
      *)
      bpFehler := FALSE;
      Hubrahmen.bpStartAusfahren := NOT ( Hubrahmen.epStatusZylinder = eZylinderAusgefahren );

      steplAktion := STEP_10_E;

    // AUSTRANSPORT ==============================
    STEP_10_E:
      (* Anmerkung:
         - Hubpalette heben
      *)
      IF (  Hubrahmen.bpDone OR NOT Hubrahmen.bpStartAusfahren ) THEN
        Hubrahmen.bpStartAusfahren   := FALSE;
        Glastransport.bpAustransport := TRUE;
        steplAktion := STEP_30_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_30_E:
      (* Hinweis:
         - Hubrahmen absenken wenn die Sensorik frei geworden ist
      *)
      IF Glastransport.bpSensorAuslauf THEN
        steplAktion := STEP_40_E;
      END_IF

      IF ( Glastransport.bpDone ) THEN
        Hubrahmen.bpStartEinfahren   := TRUE;
        Glastransport.bpAustransport := FALSE;
        steplAktion := STEP_50_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_40_E:
      (* Hinweis:
         - Hubrahmen absenken wenn die Sensorik frei geworden ist
      *)
      IF (  NOT Glastransport.bpSensorAuslauf
           AND NOT BasisStationsParameter.InGlasTransportNachfolger[wWand].bEinlaufsensor )
      THEN
        Hubrahmen.bpStartEinfahren       := TRUE;
      END_IF

      IF ( Glastransport.bpDone ) THEN
        Hubrahmen.bpStartEinfahren       := TRUE;
        Glastransport.bpAustransport     := FALSE;
        steplAktion := STEP_50_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_50_E:
      (* Hinweis:
         - Austransport ist vorbei: die Achsen des Glastransports abnullen (Zaehlerueberlauf des Gebers),
           nur nach dem Austransport, nie im Eintransport
      *)
      Glastransport.bpReferenz := TRUE;

      steplAktion := STEP_60_E;

    // AUSTRANSPORT ==============================
    STEP_60_E:
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpReferenz := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_100_E:
      (* Anmerkung:
         - Hubpalette senken
      *)
      IF (  Hubrahmen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bAustransportAbgeschlossen[wWand] := FALSE;

    // AUSTRANSPORT ==============================
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[wWand] := TRUE;

  // AUSTRANSPORT ==============================
  END_CASE
ELSE

  IF ( steplAktion > STEP_0_E ) THEN

    bpFehler := FALSE;
    Glastransport.bpAustransport := FALSE;
    Glastransport.bpReferenz     := FALSE;

    Hubrahmen.bpStartEinfahren := FALSE;
    Hubrahmen.bpStartAusfahren := FALSE;

    BasisStationsParameter.bAustransportAbgeschlossen[wWand] := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
