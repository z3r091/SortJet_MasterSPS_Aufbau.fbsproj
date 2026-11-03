(* METADATA
{
  "v3Meta": {
    "objectGuid": "4179f865-c585-4599-a4ae-b9009f1fcea7"
  }
}
*)
ACTION Austransport
//-------------------------------------------------------------------------------------------------
// AUSTRANSPORT
//-------------------------------------------------------------------------------------------------
IF (  BasisStationsParameter.bAustransport[cWAND_1]
     AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpAustransport             := FALSE;
    Glastransport.bpAustransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF ( Drehen.bpFehler ) THEN
    Drehen.bpStarteAbsolutPositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren  := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF
  
  IF ( Querachse.bpFehler ) THEN
    Querachse.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Querachse.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF


  CASE steplAustransport OF
    // AUSTRANSPORT =========================
    STEP_0_E:
      (* Hinweis:
         - Sicherstellen dass das Geblaese aktiv ist
      *)
      IF ( blGeblaeseAktiv
           AND NOT bpVorabDrehenAktiv )
      THEN
        steplAustransport := STEP_10_E;
      END_IF

      (* Fehlerbehandlung:
         - Geblaese
      *)
      IF ( Geblaese.bpFehler ) THEN
        Geblaese.bpStart := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT =========================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONALE - KOMPONENTEN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      // Option:
      //   - Dickenverstellung der Wand \ Scheibenfuehrung \ etc.
      Dickenverstellung.epOeffnungsStellung := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDickenverstellung;
      Dickenverstellung.bpStartPneumatik    := TRUE;

      (* Hinweis:
         - Ansteuerung Querachse
      *)
      Querachse.epOeffnungsStellung := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eQuerachse;
      Querachse.bpStartPneumatik    := TRUE;

      (* Hinweis:
         - Ansteuerung Kippen
      *)
      Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition;
      Kippen.bpPositionieren  := TRUE;

      (* Hinweis:
         - Ansteuerung Drehen
      *)
      IF ( BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDrehen_Sollposition <> Drehen.epDrehPositionsStatus ) THEN
        Drehen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDrehen_Sollposition;
        Drehen.bpStarteAbsolutPositionierung := TRUE;
      END_IF

      IF Drehen.epZielPosition <> eDrehPosition90Grad THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_DREHPOSITION;
        steplAustransport := STEP_900_E;
      ELSE
        steplAustransport := STEP_50_E;
      END_IF


    // AUSTRANSPORT =========================
    STEP_50_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONALE - KOMPONENTEN PROZESSES ABGESCHLOSSEN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF ( ( Querachse.bpDone OR NOT Querachse.bpStartPneumatik )
           AND Kippen.bpDone
           AND ( Drehen.bpDone OR NOT Drehen.bpStarteAbsolutPositionierung ))
      THEN
        Querachse.bpStartPneumatik           := FALSE;
        Kippen.bpPositionieren               := FALSE;
        Drehen.bpStarteAbsolutPositionierung := FALSE;

        steplAustransport := STEP_100_E;
      END_IF

    // AUSTRANSPORT ==================================================================
    STEP_100_E:
      (* Hinweis:
         - Sicherstellen das die Zielposition erreicht worden ist
      *)
      IF ( Querfahrt.bpZielPositionErreicht OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt ) THEN
        steplAustransport := STEP_110_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(Querfahrt.rpAktuellePosition);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(Querfahrt.rpZielPosition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplAustransport := STEP_900_E;

      END_IF

    // AUSTRANSPORT =========================
    STEP_110_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES AUSTRANSPORTS
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      Glastransport.pAuftrag                   := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpAustransport             := NOT BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      Glastransport.bpAustransportRueckwaertig := BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

      steplAustransport := STEP_120_E;

    // AUSTRANSPORT =========================
    STEP_120_E:
      (* Hinweis:
         - Austransport abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpAustransport             := FALSE;
        Glastransport.bpAustransportRueckwaertig := FALSE;

        steplAustransport := STEP_200_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpAustransport := FALSE;
        Glastransport.bpAustransportRueckwaertig := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT =========================
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
      IF ( BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDrehen_Sollposition_NachAustransport <> eDrehPositionUndefiniert ) THEN
        Drehen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDrehen_Sollposition_NachAustransport;
        Drehen.bpStarteAbsolutPositionierung := TRUE;
      END_IF

      (* Hinweis:
         - Ansteuerung Kippen
      *)
      IF BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsInformationen.cBIT_SRCSTATION_EMPTY THEN
        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition_NachAustransport;
        Kippen.bpPositionieren  := TRUE;
      END_IF

      steplAustransport :=  STEP_210_E;


    // AUSTRANSPORT =========================
    STEP_210_E:
      (* Hinweis:
         - Drehung abgeschlossen
      *)
      IF (  ( Drehen.bpDone OR NOT Drehen.bpStarteAbsolutPositionierung )
           AND ( Kippen.bpDone OR NOT Kippen.bpPositionieren ) )
      THEN
        Kippen.bpPositionieren := FALSE;

        Drehen.bpStarteAbsolutPositionierung := FALSE;
        steplAustransport :=  STEP_1000_E;
      END_IF

    // AUSTRANSPORT =========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // AUSTRANSPORT =========================
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := TRUE;

  // AUSTRANSPORT =========================
  END_CASE
ELSE

  IF (steplAustransport > STEP_0_E) THEN
    BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;

    Glastransport.bpAustransport             := FALSE;
    Glastransport.bpAustransportRueckwaertig := FALSE;

    Dickenverstellung.bpStartPneumatik   := FALSE;
    Querachse.bpStartPneumatik           := FALSE;
    Kippen.bpPositionieren               := FALSE;
    Drehen.bpStarteAbsolutPositionierung := FALSE;

    steplAustransport := STEP_0_E;
  END_IF

END_IF
END_ACTION