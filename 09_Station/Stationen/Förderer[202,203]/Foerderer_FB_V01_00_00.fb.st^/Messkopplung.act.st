(* METADATA
{
  "v3Meta": {
    "objectGuid": "4f7395c5-5dec-4bc8-81c3-d446118647e2"
  }
}
*)
ACTION Messkopplung
//-------------------------------------------------------------------------------------------------
// AKTION MESSKOPPLUNG
//-------------------------------------------------------------------------------------------------
IF (  BasisStationsParameter.bMesskopplung[cWAND_1]
     AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation  
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpMesskopplung := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Glastransport.wpFehlerNr;
    steplMesskopplung := STEP_900_E;
  END_IF
   
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplMesskopplung := STEP_900_E;
  END_IF
   
  IF ( Roellchenleiste.bpFehler ) THEN
    Roellchenleiste.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Roellchenleiste.wpFehlerNr;
    steplMesskopplung := STEP_900_E;
  END_IF
   
  IF ( Wandverstellung.bpFehler ) THEN
    Wandverstellung.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Wandverstellung.wpFehlerNr;
    steplMesskopplung := STEP_900_E;
  END_IF


  CASE steplMesskopplung OF
    // MESSKOPPLUNG ===================================
    STEP_0_E:
      steplMesskopplung := STEP_10_E;

    // EINTRANSPORT ===============================
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob die Geblase aktiv sind
      *)
      IF ( blGeblaeseAktiv ) THEN

        Kippen.bpPositionieren := FALSE;

        Roellchenleiste.epOeffnungsStellung := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDickenverstellung;
        Roellchenleiste.bpStartPneumatik := TRUE;

        Wandverstellung.epOeffnungsStellung := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDickenverstellung;
        Wandverstellung.bpStartPneumatik := TRUE;

        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition;
        Kippen.bpPositionieren := TRUE;

        steplMesskopplung := STEP_20_E;

      END_IF

    // EINTRANSPORT ===============================
    STEP_20_E:
      IF ( ( Kippen.bpDone )
           AND ( Roellchenleiste.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bRoellchenleiste[cWAND_1] )
           AND ( Wandverstellung.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bWandverstellung[cWAND_1] ) )
      THEN
        Roellchenleiste.bpStartPneumatik := FALSE;
        Wandverstellung.bpStartPneumatik := FALSE;
        Kippen.bpPositionieren           := FALSE;

        steplMesskopplung := STEP_100_E;

      END_IF

    // MESSKOPPLUNG ===================================
    STEP_100_E:
      (* Anmerkung:
         - Starten des Prozesses
      *)
      Glastransport.bpMesskopplung := TRUE;
      steplMesskopplung := STEP_1000_E;

    // MESSKOPPLUNG ===================================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // MESSKOPPLUNG ===================================
    STEP_1000_E:
      ;

  // MESSKOPPLUNG ===================================
  END_CASE
ELSE

  IF ( steplMesskopplung > STEP_0_E ) THEN
    Glastransport.bpMesskopplung := FALSE;

    Kippen.bpPositionieren           := FALSE;
    Roellchenleiste.bpStartPneumatik := FALSE;
    Wandverstellung.bpStartPneumatik := FALSE;

    steplMesskopplung := STEP_0_E;
  END_IF

END_IF
END_ACTION