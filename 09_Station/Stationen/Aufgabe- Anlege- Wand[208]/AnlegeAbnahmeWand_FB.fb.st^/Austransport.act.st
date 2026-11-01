(* METADATA
{
  "v3Meta": {
    "objectGuid": "4e6207e0-a6e7-4e9b-b71d-039e9f22cc6d"
  }
}
*)
ACTION Austransport
(***************************************************************************************************)
(* AUSTRANSPORT *)
(***************************************************************************************************)
IF (  BasisStationsParameter.bAustransport[cWAND_1]
     AND blBetriebsartAutomatik )
THEN
  (* Fehlerbehandlung
    - Glastransport
    - Kippbaustein
    - Hoehenkontrolle
  *)      
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpAustransport := FALSE;
    out_bDrosselklappeOeffnen := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF
  
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF
      
  IF ( Messachse.bpFehler ) THEN
    Messachse.bpPositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF

  CASE steplAustransport OF
    (*AUSTRANSPORT ==========================*)
    STEP_0_E:
      (* Hinweis:
         - Freigabe durch Quittierten Si-Kreis da ?
      *)
      IF ( tonlFreigabeErhalten.Q ) THEN
        steplAustransport := STEP_5_E;
      END_IF

    (*AUSTRANSPORT ==========================*)
    STEP_5_E:
      (* Hinweis:
         - Pruefen ob das Geblase aktiv ist
           => Sicherung nicht ausgeloest
      *)
      BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;

      IF ( in_bMotorschutzGeblaese_Ok ) THEN
        out_bDrosselklappeOeffnen := TRUE;
        steplAustransport := STEP_10_E;

      ELSE
        out_bDrosselklappeOeffnen := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplAustransport := STEP_900_E;

      END_IF

    (*AUSTRANSPORT ==========================*)
    STEP_10_E:
      (* Anmerkung:
         - Position Hoehenkontrolle übergeben
      *)
      IF ( ((BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset )
             >= Messachse.Antrieb.rpMaxPosition ) )
      THEN
        Messachse.rpZielPosition := Messachse.Antrieb.rpMaxPosition ;
      ELSE
        Messachse.rpZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset;
      END_IF

      steplAustransport := STEP_20_E;

    (*AUSTRANSPORT ==========================*)
    STEP_20_E:
      (* Hinweis:
         - Kippen und Höhenkontrollle nur wenn Si-Kreis geschlossen ist 
      *)
      IF tonlFreigabeErhalten.Q THEN
        Kippen.epZielPosition := eKippen_Position_90Grad;
        Kippen.bpPositionieren := TRUE;

        Messachse.bpPositionierung := TRUE;
      ELSE
        Kippen.bpPositionieren     := FALSE;
        Messachse.bpPositionierung := FALSE;
      END_IF

      (* Hinweis:
         - Hoehenkontrolle und Kippantrieb sind verfahren
      *)
      IF (  Messachse.bpDone
           AND Kippen.bpDone )
      THEN
        Kippen.bpPositionieren     := FALSE;
        Messachse.bpPositionierung := FALSE;
        steplAustransport := STEP_30_E;
      END_IF

    (*AUSTRANSPORT ==========================*)
    STEP_30_E:
      (* Anmerkung:
         - Starten des Austransports auf die Folgestation
      *) 
      Glastransport.pAuftrag                   := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpAustransport             := BasisStationsParameter.bAustransport[cWAND_1] AND NOT BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      Glastransport.bpAustransportRueckwaertig := BasisStationsParameter.bAustransport[cWAND_1] AND     BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

      steplAustransport := STEP_40_E;

    (*AUSTRANSPORT ==========================*)
    STEP_40_E:
      (* Hinweis:
         - Austransport abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpAustransport := FALSE;
        steplAustransport := STEP_100_E;
      END_IF

    (*AUSTRANSPORT ==========================*)
    STEP_100_E:
      (* Hinweis:
         - Hoehenkontrolle ist auf Position gefahren
         - 90 Grad gekippt
      *)
      IF ( tonlFreigabeErhalten.Q ) THEN
        Kippen.epZielPosition := eKippen_Position_84Grad;
        Kippen.bpPositionieren := TRUE;
      ELSE
        Kippen.bpPositionieren := FALSE;
      END_IF

      IF (Kippen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1]) THEN
        Kippen.bpPositionieren := FALSE;
        steplAustransport := STEP_1000_E;
      END_IF

    (*AUSTRANSPORT ==========================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    (*AUSTRANSPORT ==========================*)
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := TRUE;

  (*AUSTRANSPORT ==========================*)
  END_CASE
ELSE
  IF (steplAustransport > STEP_0_E) THEN
    BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;

    Messachse.bpPositionierung   := FALSE;
    Kippen.bpPositionieren       := FALSE;
    Glastransport.bpAustransport := FALSE;

    steplAustransport := STEP_0_E;
  END_IF
END_IF
END_ACTION