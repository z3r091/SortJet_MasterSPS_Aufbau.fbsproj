(* METADATA
{
	"v3Meta": {
		"objectGuid": "3f00ae04-0e21-4ef9-a3e8-3063ce3cc60e"
	}
}
*)
ACTION Eintransport
(***************************************************************************************************)
(* EINTRANSPORT  *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bEintransport[cWAND_1]
  AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
      Glastransport.bpEintransport             := FALSE;
      Glastransport.bpEintransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
	  
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF ( Hub.bpFehler ) THEN
    Hub.bpStartHubAb  := FALSE;
    Hub.bpStartHubAuf := FALSE;
    BasisStationsParameter.wFehlerNummer := Hub.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF

  IF ( Roellchenleiste.bpFehler ) THEN
    Roellchenleiste.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Roellchenleiste.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF  

  IF ( Wandverstellung.bpFehler ) THEN
    Wandverstellung.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Wandverstellung.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF ( Geblaese.bpFehler ) THEN
    BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
    steplEintransport := STEP_900_E;
  END_IF


  CASE steplEintransport OF
(* EINTRANSPORT ===============================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen 
      *)
      atonlUeberwachungEintransport( IN := FALSE);

      steplEintransport := STEP_10_E;

(* EINTRANSPORT ===============================*)
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob die Geblase aktiv sind
         - Pruefen ob aktuel ein VorAb-Auftrag aktiv ist
           => Sonst warten bis dieser Beendet wurde
      *)
      IF ( blGeblaeseAktiv ) THEN

        Roellchenleiste.epOeffnungsStellung := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDickenverstellung;
        Roellchenleiste.bpStartPneumatik := TRUE;

        Wandverstellung.epOeffnungsStellung := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDickenverstellung;
        Wandverstellung.bpStartPneumatik := TRUE;

        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition;
        Kippen.bpPositionieren := TRUE;

        steplEintransport := STEP_20_E;

      END_IF

(* EINTRANSPORT ===============================*)
    STEP_20_E:
      IF ( ( Kippen.bpDone ) 
       AND ( Roellchenleiste.bpDone )
       AND ( Wandverstellung.bpDone ) ) 
      THEN
        Roellchenleiste.bpStartPneumatik := FALSE;
        Wandverstellung.bpStartPneumatik := FALSE;
        Kippen.bpPositionieren           := FALSE;

        steplEintransport := STEP_100_E;

      END_IF

      (* Hinweis:
         - Ueberwachung des Schritts
      *)
      atonlUeberwachungEintransport( IN := TRUE,
                                     PT := ZEIT_UEBERWACHUNG_EINZELSCHRITT );

      IF ( atonlUeberwachungEintransport.Q ) THEN

        IF ( NOT ( Kippen.epKippStatus = eKippen_Position_90Grad )) THEN
          ;
          (* TO DO: ggf nochmal kippen oder eine Meldung generieren das hier was nicht stimmt *)
        END_IF

      END_IF

(*EINTRANSPORT =====================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  STARTEN DES EINTRANSPORTS
      //         
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------*)

      Glastransport.bpScheibentrennen          := BasisStationsParameter.bScheibentrennen[cWAND_1];
      Glastransport.pAuftrag                   := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpEintransport             := BasisStationsParameter.bEintransport[cWAND_1] AND NOT BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      Glastransport.bpEintransportRueckwaertig := BasisStationsParameter.bEintransport[cWAND_1] AND     BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

      steplEintransport := STEP_110_E;

(*EINTRANSPORT =====================*)
    STEP_110_E:
      IF  ( Glastransport.bpFreigabeFremdprozess
        AND BasisStationsParameter.pAuftrag[cWAND_1].bLetzteScheibe )
      THEN

        (* Hinweis:
           - Richtung ist Invertiert zur Eintransport- Position
        *)
        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition_NachEintransport;
        Kippen.bpPositionieren := TRUE;

      END_IF

      IF ( Glastransport.bpDone ) THEN

        Glastransport.bpEintransport             := FALSE;
        Glastransport.bpEintransportRueckwaertig := FALSE;

        IF ( BasisStationsParameter.pAuftrag[cWAND_1].bLetzteScheibe) THEN
          steplEintransport := STEP_200_E;
        ELSE
          steplEintransport := STEP_1000_E;
        END_IF

      END_IF

(*EINTRANSPORT =====================*)
    STEP_200_E:
      (* ---------------------------------------------------------------------------------------
      //  OPTIONAL - KOMPONENTEN STEUERUNG 
      //         
      //  Hinweis:
      //  - Ausrichtung der Station fuer den Austransport
      // ---------------------------------------------------------------------------------------*)

      (* Hinweis:
         - Richtung ist Invertiert zur Eintransport- Position
      *)
      Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition_NachEintransport;
      Kippen.bpPositionieren := TRUE;
		
      steplEintransport := STEP_210_E;

(*EINTRANSPORT =====================*)
    STEP_210_E:
      IF Kippen.bpDone OR NOT Kippen.bpPositionieren THEN
		  
        Kippen.bpPositionieren  := FALSE;

        steplEintransport := STEP_1000_E;
      END_IF

(*EINTRANSPORT =====================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*EINTRANSPORT =====================*)
    STEP_1000_E:
      BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := TRUE;

(*EINTRANSPORT =====================*)
  END_CASE
ELSE

  IF (steplEintransport > STEP_0_E) THEN
    BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;

    Roellchenleiste.bpStartPneumatik         := FALSE;
    Wandverstellung.bpStartPneumatik         := FALSE;
    Kippen.bpPositionieren                   := FALSE;
    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;
    Hub.bpStartHubAb                         := FALSE;
    Hub.bpStartHubAuf                        := FALSE;

    steplEintransport := STEP_0_E;
  END_IF

END_IF
END_ACTION