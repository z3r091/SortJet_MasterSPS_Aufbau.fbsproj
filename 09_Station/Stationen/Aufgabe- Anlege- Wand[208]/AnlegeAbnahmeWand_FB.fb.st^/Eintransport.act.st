(* METADATA
{
	"v3Meta": {
		"objectGuid": "01653b67-d593-42b2-865c-32e33e2f42a4"
	}
}
*)
ACTION Eintransport
(***************************************************************************************************)
(* AKTION: EINTRANSPORT *)
(***************************************************************************************************)
IF (  BasisStationsParameter.bEintransport[cWAND_1]
  AND blBetriebsartAutomatik )
THEN
 (* Fehlerbehandlung
    - Glastransport
    - Kippbaustein
    - Hoehenkontrolle
  *)      
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;
    out_bDrosselklappeOeffnen := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
      
  IF ( Messachse.bpFehler ) THEN
    Messachse.bpPositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF ( Dickenverstellung.bpFehler ) THEN
    Dickenverstellung.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Dickenverstellung.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF  
  
  CASE steplEintransport OF
(*EINTRANSPORT ==================================*)
    STEP_0_E:
      (* Hinweis:
         - Freigabe durch Quittierten Si-Kreis da ?
      *)
       BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;

       IF ( tonlFreigabeErhalten.Q ) THEN
        steplEintransport := STEP_5_E;
       END_IF

(*EINTRANSPORT ==================================*)
    STEP_5_E:
      (* Hinweis:
         - Pruefen ob das Geblase aktiv ist
           => Sicherung nicht ausgeloest
      *)
      IF ( in_bMotorschutzGeblaese_Ok ) THEN
        out_bDrosselklappeOeffnen := TRUE;
        steplEintransport := STEP_10_E;

      ELSE
        out_bDrosselklappeOeffnen := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplEintransport := STEP_900_E;

      END_IF

(*EINTRANSPORT ==================================*)
    STEP_10_E:
      (* Hoehenkontrolle auf Position fahren
         - Es findet keine Messung statt Station kippen
         - Kippen auf 90 Grad [ Uebergabe zum Shuttle]
      *)
      IF (BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[cWAND_1]) THEN

        IF ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= wgMKScheibenDicke13mm ) THEN
           Dickenverstellung.epOeffnungsStellung := (* eZylinderStellung16mm *) eZylinderStellung29mm; (* Immer auf 29 mm öffnen *);

        ELSIF ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= wgMKScheibenDicke19mm ) THEN
          Dickenverstellung.epOeffnungsStellung := (* eZylinderStellung23mm *)eZylinderStellung29mm; (* Immer auf 29 mm öffnen *)

        ELSIF ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= wgMKScheibenDicke23mm ) THEN
          Dickenverstellung.epOeffnungsStellung := eZylinderStellung29mm;

        ELSE
          Dickenverstellung.epOeffnungsStellung := eZylinderStellung29mm;

        END_IF

        Dickenverstellung.bpStartPneumatik := TRUE;
      END_IF

      Messachse.rpZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset;
      Messachse.bpPositionierung := TRUE;

      Kippen.epZielPosition := eKippen_Position_90Grad;
      Kippen.bpPositionieren := TRUE;

      steplEintransport := STEP_20_E;

(*EINTRANSPORT ==================================*)
    STEP_20_E:
      (* Hinweis:
         - Hoehenkontrolle ist auf Position gefahren
         - 90 Grad gekippt
      *)
      IF ( ( Messachse.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bMessachse )
        AND ( Dickenverstellung.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[cWAND_1] )
        AND ( Kippen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1] ) )
      THEN
        Dickenverstellung.bpStartPneumatik := FALSE;
        Messachse.bpPositionierung         := FALSE;
        Kippen.bpPositionieren             := FALSE;
        steplEintransport := STEP_30_E;
      END_IF

(*EINTRANSPORT ==================================*)
    STEP_30_E:
      (* Anmerkung:
         - Abhandlung des Eintransport auf die Station ueber den Antriebs-Baustein 
      *)
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpScheibenTrennen :=  BasisStationsParameter.bScheibenTrennen[cWAND_1];

      Glastransport.bpEintransport             := BasisStationsParameter.bEintransport[cWAND_1] AND NOT BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      Glastransport.bpEintransportRueckwaertig := BasisStationsParameter.bEintransport[cWAND_1] AND     BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

      steplEintransport := STEP_40_E;

(*EINTRANSPORT ==================================*)
    STEP_40_E:
      (* Hinweis:
         - Eintransport abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpEintransport := FALSE;
        out_bDrosselklappeOeffnen := FALSE;
        steplEintransport := STEP_100_E;
      END_IF

(*EINTRANSPORT ==================================*)
    STEP_100_E:
      (* Hinweis:
         - Station nach dem Eintransport abkippen
      *)
      Kippen.epZielPosition := eKippen_Position_84Grad;
	  Kippen.bpPositionieren := TRUE;

      steplEintransport := STEP_110_E;

(*EINTRANSPORT ==================================*)
    STEP_110_E:

      IF ( (Kippen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1]) ) THEN
        Kippen.bpPositionieren := FALSE;
        steplEintransport := STEP_1000_E;
      END_IF

(*EINTRANSPORT ==================================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*EINTRANSPORT ==================================*)
    STEP_1000_E:
      BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := TRUE;

(*EINTRANSPORT ==================================*)
  END_CASE
ELSE
  IF ( steplEintransport > STEP_0_E ) THEN
    out_bDrosselklappeOeffnen := FALSE;

    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;
    Kippen.bpPositionieren                   := FALSE;
    Dickenverstellung.bpStartPneumatik       := FALSE;
    Messachse.bpPositionierung               := FALSE;

    BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;
    steplEintransport := STEP_0_E;
  END_IF
END_IF
END_ACTION