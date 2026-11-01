(* METADATA
{
  "v3Meta": {
    "objectGuid": "f48a605b-9249-40db-8fda-3ce82e0029e8"
  }
}
*)
ACTION Austransport
//-------------------------------------------------------------------------------------------------
// AKTION AUSTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bAustransport[cWAND_1]
     AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpAustransport             := FALSE;
    Glastransport.bpAustransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF
  
  IF ( Geblaese.bpFehler )THEN
    BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
    steplAustransport := STEP_900_E;
  END_IF

  
  CASE steplAustransport OF
    // AUSTRANSPORT =====================
    STEP_0_E:
      IF ( blGeblaeseAktiv ) THEN
        Kippen.bpPositionieren := FALSE;
        steplAustransport := STEP_10_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_10_E:
      (* Hinweis:
         -  Ansteuerung Kippen
      *)
      Kippen.epZielPosition  := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition;
      Kippen.bpPositionieren := TRUE;

      steplAustransport := STEP_20_E;

    // AUSTRANSPORT =====================
    STEP_20_E:
      IF ( Kippen.bpDone OR NOT Kippen.bpPositionieren ) THEN

        Kippen.bpPositionieren := FALSE;

        steplAustransport := STEP_100_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_100_E:
      (* Hinweis:
         - Austransport starten
      *)
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];

      Glastransport.bpAustransport             := BasisStationsParameter.bAustransport[cWAND_1] AND NOT BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      Glastransport.bpAustransportRueckwaertig := BasisStationsParameter.bAustransport[cWAND_1] AND     BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

      steplAustransport := STEP_110_E;

    // AUSTRANSPORT =====================
    STEP_110_E:
      (* Hinweis:
         - Bei letzter Scheibe und Station leer -> Kippen
      *)
      IF ( Glastransport.bpFreigabeFremdprozess
           AND BasisStationsParameter.pAuftrag[cWAND_1].bLetzteScheibe  
           AND BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsInformationen.cBIT_SRC_WALL_1_EMPTY )
      THEN

        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition_NachAustransport;
        Kippen.bpPositionieren := TRUE;

      END_IF

      (* Hinweis:
         - Austransport abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpAustransport             := FALSE;
        Glastransport.bpAustransportRueckwaertig := FALSE;

        IF ( BasisStationsParameter.pAuftrag[cWAND_1].bLetzteScheibe ) THEN
          steplAustransport := STEP_200_E;
        ELSE
          steplAustransport := STEP_1000_E;
        END_IF

      END_IF

    // AUSTRANSPORT =====================
    STEP_200_E: 
      (* Hinweis:
         - Bei letzter Scheibe und Station leer -> Kippen
      *)
      IF BasisStationsParameter.pAuftrag[cWAND_1].bLetzteScheibe  
         AND BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsInformationen.cBIT_SRC_WALL_1_EMPTY
      THEN
        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition_NachAustransport;
        Kippen.bpPositionieren := TRUE;

        steplAustransport := STEP_210_E;
      ELSE
        steplAustransport := STEP_1000_E; 
      END_IF


    // EINTRANSPORT =====================
    STEP_210_E:
      IF Kippen.bpDone OR NOT Kippen.bpPositionieren THEN
        Kippen.bpPositionieren  := FALSE;

        steplAustransport := STEP_1000_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // AUSTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := TRUE;

  // AUSTRANSPORT =====================
  END_CASE
ELSE

  IF (steplAustransport > STEP_0_E) THEN
    BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;

    Kippen.bpPositionieren := FALSE;

    Glastransport.bpAustransport              := FALSE;
    Glastransport.bpAustransportRueckwaertig  := FALSE;

    steplAustransport := STEP_0_E;
  END_IF

END_IF
END_ACTION