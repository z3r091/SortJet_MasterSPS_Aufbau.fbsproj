(* METADATA
{
  "v3Meta": {
    "objectGuid": "09973465-9aad-4b9d-978a-bbaff2c5ee48"
  }
}
*)
ACTION SystemCheck
(***************************************************************************************************)
(* AKTION SYSTEMCHECK *)
(***************************************************************************************************)
(* Hinweis:
   - SystemCheck 
*)
IF ( blBetriebartCheck ) THEN

  // Ausnahmesituation
  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO

    IF ( Glastransport[wlIndex].bpFehler ) THEN
      BasisStationsParameter.wFehlerNummer := Glastransport[wlIndex].wpFehlerNr;
      steplCheck:=STEP_900_E;
    END_IF

    IF ( Geblaese[wlIndex].bpFehler ) THEN
      BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
      steplCheck:=STEP_900_E;
    END_IF

  END_FOR

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Kippen.wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF

  CASE steplCheck OF
(*SYSTEM CHECK=========================*)
    STEP_0_E:

      BasisStationsParameter.bCheckAbgeschlossen := FALSE;

      (* Hinweis:
         - Wenn die Geblaese gestartet sind kann mit dem SystemCheck begonnen werden.           
      *)
      IF ( blGeblaeseAktiv  ) THEN
        steplCheck:=STEP_50_E;
      END_IF

(*SYSTEM CHECK=========================*)
    STEP_50_E:
      (* Hinweis:
         - Starten des SystemCheck mittels Glastransport
      *)
      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        Glastransport[wlIndex].bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[wlIndex];
        Glastransport[wlIndex].bpCheckMitVorgaenger := BasisStationsParameter.bCheckMitVorgaenger[wlIndex];
        Glastransport[wlIndex].bpRueckwaertsSystemcheck := BasisStationsParameter.bRueckwaertsTransportieren[wlIndex];
        Glastransport[wlIndex].pAuftrag := BasisStationsParameter.pAuftrag[wlIndex];
        Glastransport[wlIndex].bpCheck := TRUE;
      END_FOR

      steplCheck:=STEP_60_E;

(*SYSTEM CHECK=========================*)
    STEP_60_E:

      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        BasisStationsParameter.bStationBelegt[wlIndex] := Glastransport[wlIndex].bpStationBelegt;
      END_FOR

      blDone := TRUE;
      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        blDone := blDone AND Glastransport[wlIndex].bpDone;
      END_FOR

      IF ( blDone ) THEN
        FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
         Glastransport[wlIndex].bpCheck := FALSE;
        END_FOR
       
        IF ( NOT BasisStationsParameter.stMKs.stStationsAufbau.bKippenSchuetz ) THEN
          wSPS2MMIShuttleNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
          IF ( Kippen.epKippStatus = eKippen_Position_90Grad ) OR ( Kippen.epKippStatus = eKippen_Position_84Grad ) OR ( Kippen.epKippStatus = eKippen_Position_96Grad ) THEN
            wSPS2MMIShuttleKippenStatus := 3;
          ELSE
            wSPS2MMIShuttleKippenStatus := 0;
          END_IF
        END_IF
        steplCheck:=STEP_100_E;
      END_IF

(*SYSTEM CHECK=========================*)
    STEP_100_E:
      (* Hinweis:
         - Status des Kippen prüfen und ggf. korrigieren
      *)
      IF ( BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition <> eKippen_Default ) THEN
        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition;
        Kippen.bpPositionieren := TRUE;

        steplCheck := STEP_110_E;
     ELSE
        steplCheck := STEP_1000_E;

    END_IF

(*SYSTEM CHECK=========================*)
    STEP_110_E:
      (* Hinweis:
         - Kippen abschließen
      *)
      IF ( Kippen.bpDone ) THEN

        Kippen.bpPositionieren := FALSE;

        steplCheck:=STEP_1000_E;
      END_IF


(*SYSTEM CHECK=========================*)
    STEP_900_E:
      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
       Glastransport[wlIndex].bpCheck := FALSE;
      END_FOR

      Kippen.bpPositionieren := FALSE;

      blNachSystemcheckMerker := FALSE;

      BasisStationsParameter.bFehler := TRUE;

(*SYSTEM CHECK=========================*)
    STEP_1000_E:
      blNachSystemcheckMerker := TRUE;

      BasisStationsParameter.bCheckAbgeschlossen := TRUE;

(*SYSTEM CHECK=========================*)
  END_CASE
ELSE
  IF (steplCheck > STEP_0_E) THEN

    FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
     Glastransport[wlIndex].bpCheck := FALSE;
    END_FOR

    Kippen.bpPositionieren := FALSE;

    BasisStationsParameter.bCheckAbgeschlossen := FALSE;

    blNachSystemcheckMerker := FALSE;
    steplCheck := STEP_0_E;
  END_IF
END_IF
END_ACTION