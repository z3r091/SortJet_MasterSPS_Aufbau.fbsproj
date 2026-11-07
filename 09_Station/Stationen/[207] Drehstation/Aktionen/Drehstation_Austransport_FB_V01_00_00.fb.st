(* METADATA
{
	"v3Meta": {
		"objectGuid": "a2a92850-d1dd-4edb-909d-b8b6897beb5d"
	}
}
*)
FUNCTION_BLOCK Drehstation_Austransport_FB_V01_00_00 EXTENDS Basic_Station_Austransport_FB_V01_00_00
VAR_INPUT

  // BOOL
  bpVorabDrehenAktiv : BOOL; // Status: Vorab-Drehen der Station laeuft

  // Bausteine (Kippen, Geblaese usw. kommen vom Basic-Baustein)
  Drehen            : REFERENCE TO Drehstation_Drehen_FB_V01_00_00;
  Querfahrt         : REFERENCE TO Querfahrt_FB_V01_00_00;
  Dickenverstellung : REFERENCE TO ZylinderPneumatik_3Wege_FB_V01_00_00;
  Querachse         : REFERENCE TO ZylinderPneumatik_3Wege_FB_V01_00_00;

END_VAR
//-------------------------------------------------------------------------------------------------
// AUSTRANSPORT
//-------------------------------------------------------------------------------------------------
IF (  BasisStationsParameter.bAustransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpAustransport             := FALSE;
    Glastransport.bpAustransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Drehen.bpFehler ) THEN
    Drehen.bpStarteAbsolutPositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren  := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Dickenverstellung.bpFehler ) THEN
    Dickenverstellung.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Dickenverstellung.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Querachse.bpFehler ) THEN
    Querachse.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Querachse.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // AUSTRANSPORT =====================
    STEP_0_E:
      bpFehler := FALSE;

      (* Hinweis:
         - Sicherstellen dass das Geblaese aktiv ist
      *)
      IF ( bpGeblaeseAktiv
           AND NOT bpVorabDrehenAktiv )
      THEN
        steplAktion := STEP_10_E;
      END_IF

      (* Fehlerbehandlung:
         - Geblaese
      *)
      IF ( Geblaese.bpFehler ) THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplAktion := STEP_900_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONALE - KOMPONENTEN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      // Option:
      //   - Dickenverstellung der Wand \ Scheibenfuehrung \ etc.
      Dickenverstellung.epOeffnungsStellung := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung;
      Dickenverstellung.bpStartPneumatik    := TRUE;

      (* Hinweis:
         - Ansteuerung Querachse
      *)
      Querachse.epOeffnungsStellung := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eQuerachse;
      Querachse.bpStartPneumatik    := TRUE;

      (* Hinweis:
         - Ansteuerung Kippen
      *)
      Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition;
      Kippen.bpPositionieren  := TRUE;

      (* Hinweis:
         - Ansteuerung Drehen
      *)
      IF ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition <> Drehen.epDrehPositionsStatus ) THEN
        Drehen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition;
        Drehen.bpStarteAbsolutPositionierung := TRUE;
      END_IF

      IF Drehen.epZielPosition <> eDrehPosition90Grad THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_DREHPOSITION;
        steplAktion := STEP_900_E;
      ELSE
        steplAktion := STEP_50_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_50_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONALE - KOMPONENTEN PROZESSES ABGESCHLOSSEN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF ( ( Querachse.bpDone OR NOT Querachse.bpStartPneumatik )
           AND Kippen.bpDone
           AND ( Drehen.bpDone OR NOT Drehen.bpStarteAbsolutPositionierung )
           AND ( Dickenverstellung.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[wWand] ) )
      THEN
        Dickenverstellung.bpStartPneumatik   := FALSE;
        Querachse.bpStartPneumatik           := FALSE;
        Kippen.bpPositionieren               := FALSE;
        Drehen.bpStarteAbsolutPositionierung := FALSE;

        steplAktion := STEP_100_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_100_E:
      (* Hinweis:
         - Sicherstellen das die Zielposition erreicht worden ist
      *)
      IF ( Querfahrt.bpZielPositionErreicht OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt ) THEN
        steplAktion := STEP_110_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(Querfahrt.rpAktuellePosition);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(Querfahrt.rpZielPosition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplAktion := STEP_900_E;

      END_IF

    // AUSTRANSPORT =====================
    STEP_110_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES AUSTRANSPORTS
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      Glastransport.pAuftrag                   := BasisStationsParameter.pAuftrag[wWand];
      Glastransport.bpAustransport             := NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      Glastransport.bpAustransportRueckwaertig := BasisStationsParameter.bRueckwaertsTransportieren[wWand];

      steplAktion := STEP_120_E;

    // AUSTRANSPORT =====================
    STEP_120_E:
      (* Hinweis:
         - Austransport abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpAustransport             := FALSE;
        Glastransport.bpAustransportRueckwaertig := FALSE;

        steplAktion := STEP_200_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpAustransport := FALSE;
        Glastransport.bpAustransportRueckwaertig := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplAktion := STEP_900_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  OPTION - KOMPONENTEN ANSTEUERN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Ansteuerung Kippen
      *)
      IF ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachAustransport <> eDrehPositionUndefiniert ) THEN
        Drehen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachAustransport;
        Drehen.bpStarteAbsolutPositionierung := TRUE;
      END_IF

      (* Hinweis:
         - Ansteuerung Kippen
      *)
      IF BasisStationsParameter.pAuftrag[wWand].stAuftragsInformationen.cBIT_SRCSTATION_EMPTY THEN
        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachAustransport;
        Kippen.bpPositionieren  := TRUE;
      END_IF

      steplAktion :=  STEP_210_E;

    // AUSTRANSPORT =====================
    STEP_210_E:
      (* Hinweis:
         - Drehung abgeschlossen
      *)
      IF (  ( Drehen.bpDone OR NOT Drehen.bpStarteAbsolutPositionierung )
           AND ( Kippen.bpDone OR NOT Kippen.bpPositionieren ) )
      THEN
        Kippen.bpPositionieren := FALSE;

        Drehen.bpStarteAbsolutPositionierung := FALSE;
        steplAktion :=  STEP_1000_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // AUSTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[wWand] := TRUE;

  // AUSTRANSPORT =====================
  END_CASE
ELSE

  IF (steplAktion > STEP_0_E) THEN
    bpFehler := FALSE;
    BasisStationsParameter.bAustransportAbgeschlossen[wWand] := FALSE;

    Glastransport.bpAustransport             := FALSE;
    Glastransport.bpAustransportRueckwaertig := FALSE;

    Dickenverstellung.bpStartPneumatik   := FALSE;
    Querachse.bpStartPneumatik           := FALSE;
    Kippen.bpPositionieren               := FALSE;
    Drehen.bpStarteAbsolutPositionierung := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK