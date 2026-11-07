(* METADATA
{
	"v3Meta": {
		"objectGuid": "04449e84-691b-4e69-833a-86a17a5f4911"
	}
}
*)
FUNCTION_BLOCK Basic_Station_Messkopplung_FB_V01_00_00 EXTENDS Basic_Station_Aktion_FB_V01_00_00
VAR_INPUT

  // Bausteine
  Kippen          : REFERENCE TO Kippen_FB_V01_00_00;
  Hub             : REFERENCE TO Hub_FB_V01_00_00;
  Roellchenleiste : REFERENCE TO ZylinderPneumatik_3Wege_FB_V01_00_00;
  Wandverstellung : REFERENCE TO ZylinderPneumatik_3Wege_FB_V01_00_00;

END_VAR
//-------------------------------------------------------------------------------------------------
// MESSKOPPLUNG
//-------------------------------------------------------------------------------------------------
IF (  BasisStationsParameter.bMesskopplung[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpMesskopplung := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Hub.bpFehler ) THEN
    Hub.bpStartHubAuf := FALSE;
    Hub.bpStartHubAb  := FALSE;
    BasisStationsParameter.wFehlerNummer := Hub.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Roellchenleiste.bpFehler ) THEN
    Roellchenleiste.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Roellchenleiste.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Wandverstellung.bpFehler ) THEN
    Wandverstellung.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Wandverstellung.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // MESSKOPPLUNG ===================================
    STEP_0_E:
      bpFehler := FALSE;
      BasisStationsParameter.bMesskopplungAbgeschlossen[wWand] := FALSE;
      steplAktion := STEP_10_E;

    // MESSKOPPLUNG ===================================
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob die Geblase aktiv sind
      *)
      IF ( bpGeblaeseAktiv ) THEN
        Kippen.bpPositionieren := FALSE;

        Roellchenleiste.epOeffnungsStellung := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung;
        Roellchenleiste.bpStartPneumatik := TRUE;

        Wandverstellung.epOeffnungsStellung := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung;
        Wandverstellung.bpStartPneumatik := TRUE;

        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition;
        Kippen.bpPositionieren := TRUE;

        (* Hinweis:
           - Hub auf die Sollposition des Auftrags fahren (nur Oben / Unten, sonst keine Bewegung)
        *)
        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHub ) THEN
          Hub.bpStartHubAuf := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub = eHub_Oben );
          Hub.bpStartHubAb  := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub = eHub_Unten );
        END_IF

        steplAktion := STEP_20_E;
      END_IF

    // MESSKOPPLUNG ===================================
    STEP_20_E:
      IF ( ( Kippen.bpDone )
           AND ( Roellchenleiste.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bRoellchenleiste[wWand] )
           AND ( Wandverstellung.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bWandverstellung[wWand] )
           AND ( Hub.bpDone OR NOT ( Hub.bpStartHubAuf OR Hub.bpStartHubAb ) OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHub ) )
      THEN
        Roellchenleiste.bpStartPneumatik := FALSE;
        Wandverstellung.bpStartPneumatik := FALSE;
        Kippen.bpPositionieren           := FALSE;
        Hub.bpStartHubAuf                := FALSE;
        Hub.bpStartHubAb                 := FALSE;
        steplAktion := STEP_100_E;
      END_IF

    // MESSKOPPLUNG ===================================
    STEP_100_E:
      (* Anmerkung:
         - Starten des Prozesses
      *)
      Glastransport.bpMesskopplung := TRUE;
      steplAktion := STEP_1000_E;

    // MESSKOPPLUNG ===================================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // MESSKOPPLUNG ===================================
    STEP_1000_E:
      BasisStationsParameter.bMesskopplungAbgeschlossen[wWand] := TRUE;

  // MESSKOPPLUNG ===================================
  END_CASE
ELSE

  IF ( steplAktion > STEP_0_E ) THEN
    bpFehler := FALSE;
    BasisStationsParameter.bMesskopplungAbgeschlossen[wWand] := FALSE;
    Glastransport.bpMesskopplung     := FALSE;
    Kippen.bpPositionieren           := FALSE;
    Roellchenleiste.bpStartPneumatik := FALSE;
    Wandverstellung.bpStartPneumatik := FALSE;
    Hub.bpStartHubAuf                := FALSE;
    Hub.bpStartHubAb                 := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK