(* METADATA
{
  "v3Meta": {
    "objectGuid": "0b920cd1-6025-440f-829e-4e9db02c5679"
  }
}
*)
ACTION Eintransport
//-------------------------------------------------------------------------------------------------
// EINTRANSPORT
//-------------------------------------------------------------------------------------------------
IF (  BasisStationsParameter.bEintransport[cWAND_1]
     AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF

  IF ( Drehen.bpFehler ) THEN
    Drehen.bpStarteAbsolutPositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren  := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF ( Dickenverstellung.bpFehler ) THEN
    Dickenverstellung.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Dickenverstellung.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF  
  
  IF ( Querachse.bpFehler ) THEN
    Querachse.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Querachse.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF


  CASE steplEintransport OF
    // EINTRANSPORT ==================================================================
    STEP_0_E:
      (* Hinweis:
         - Variablen zurueck setzen
         - Sicherstellen dass das Geblaese aktiv ist
      *)
      IF ( blGeblaeseAktiv AND NOT bpVorabDrehenAktiv ) THEN

        steplEintransport := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Geblaese
      *)
      IF ( Geblaese.bpFehler ) THEN
        Geblaese.bpStart := FALSE;

        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;

        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==================================================================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  ANSTEUERUNG DER BAUSTEIN-KOMPONENTEN
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
      IF Drehen.epZielPosition <> eDrehPosition0Grad THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_DREHPOSITION;
        steplEintransport := STEP_900_E;
      ELSE
        steplEintransport := STEP_110_E;
      END_IF


    // EINTRANSPORT ==================================================================
    STEP_110_E:
      (* Hinweis:
         - Drehung abgeschlossen [Drehen von 0- 180 Grad ; 180 - 0 Grad ]
      *)
      IF ( ( Drehen.bpDone OR NOT Drehen.bpStarteAbsolutPositionierung )
           AND Kippen.bpDone
           AND ( Querachse.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerachse )
           AND ( Dickenverstellung.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[cWAND_1] ) )
      THEN
        Dickenverstellung.bpStartPneumatik   := FALSE;
        Querachse.bpStartPneumatik           := FALSE;
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        Kippen.bpPositionieren               := FALSE;

        steplEintransport := STEP_120_E;
      END_IF

    // EINTRANSPORT ==================================================================
    STEP_120_E:
      (* Hinweis:
         - Sicherstellen das die Zielposition erreicht worden ist
      *)
      IF ( Querfahrt.bpZielPositionErreicht OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt ) THEN
        steplEintransport := STEP_200_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(Querfahrt.rpAktuellePosition);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(Querfahrt.rpZielPosition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplEintransport := STEP_900_E;

      END_IF


    // EINTRANSPORT ==================================================================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES GLAS-TRANSPORTS [EINTRANSPORT]
      //
      //  Hinweis:
      //  - Anhand der Drehposition bestimmen um welchen Eintransport-Typ es sich handelt
      //    => Position 0 Grad   : Transport ueber den Einlaufsensor
      //    => Position 180 Grad : Transport ueber den Auslaufsensor
      // ---------------------------------------------------------------------------------------

      Glastransport.pAuftrag                   := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpScheibentrennen          := BasisStationsParameter.bScheibentrennen[cWAND_1];
      Glastransport.bpEintransport             := NOT BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      Glastransport.bpEintransportRueckwaertig := BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

      IF BasisStationsParameter.pAuftrag[cWAND_1].bLetzteScheibe THEN
        steplEintransport := STEP_400_E;
      ELSE
        steplEintransport := STEP_300_E;
      END_IF

    // EINTRANSPORT ==================================================================
    STEP_300_E:
      // ---------------------------------------------------------------------------------------
      //  OPTION - EINTRANSPORT BIT LETZTE SCHEIBE = FALSE [KEINE DREH-BEWEGUNG]
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      BasisStationsParameter.dwWartezeit[cWAND_1] := Glastransport.dwpWartezeit;

      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpEintransport             := FALSE;
        Glastransport.bpEintransportRueckwaertig := FALSE;

        steplEintransport := STEP_1000_E;
      END_IF

    // EINTRANSPORT ==================================================================
    STEP_400_E:
      // ---------------------------------------------------------------------------------------
      //  OPTION - EINTRANSPORT BIT LETZTE SCHEIBE = TRUE [DREH-BEWEGUNG]
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------
      (* Hinweis:
         - Eintransport abgeschlossen
      *)
      BasisStationsParameter.dwWartezeit[cWAND_1] := Glastransport.dwpWartezeit;

      // => Glastransport gibt die Freigabe zum Drehen \ Kippen \ etc.
      IF ( Glastransport.bpFreigabeFremdprozess ) THEN
        Drehen.epZielPosition :=  BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport;
        Drehen.bpStarteAbsolutPositionierung := TRUE;


        CASE BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport OF
          eDrehPosition0Grad:
            Querachse.epOeffnungsStellung := eZylinderStellung16mm;
            Querachse.bpStartPneumatik    := TRUE;

          eDrehPosition180Grad:
            IF ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke13mm ) THEN
              Querachse.epOeffnungsStellung := eZylinderStellung16mm;
              Querachse.bpStartPneumatik    := TRUE;
            ELSIF (BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke19mm ) THEN
              Querachse.epOeffnungsStellung := eZylinderStellung23mm;
              Querachse.bpStartPneumatik    := TRUE;
            ELSIF (BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke24mm ) THEN
              Querachse.epOeffnungsStellung := eZylinderStellung29mm;
              Querachse.bpStartPneumatik    := TRUE;
            END_IF

        END_CASE

        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition_NachEintransport;
        Kippen.bpPositionieren := TRUE;

      END_IF

      // => Glastransport hat seinen Eintransport abgeschlossen
      IF ( Glastransport.bpDone ) THEN

        Glastransport.bpEintransport             := FALSE;
        Glastransport.bpEintransportRueckwaertig := FALSE;

        IF ( NOT Drehen.bpStarteAbsolutPositionierung ) THEN
          steplEintransport := STEP_410_E;
        ELSE

          CASE BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport OF
            eDrehPosition0Grad:
              Querachse.epOeffnungsStellung := eZylinderStellung16mm;
              Querachse.bpStartPneumatik    := TRUE;

            eDrehPosition180Grad:
              IF ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke13mm ) THEN
                Querachse.epOeffnungsStellung := eZylinderStellung16mm;
                Querachse.bpStartPneumatik    := TRUE;
              ELSIF (BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke19mm ) THEN
                Querachse.epOeffnungsStellung := eZylinderStellung23mm;
                Querachse.bpStartPneumatik    := TRUE;
              ELSIF (BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke24mm ) THEN
                Querachse.epOeffnungsStellung := eZylinderStellung29mm;
                Querachse.bpStartPneumatik    := TRUE;
              END_IF

          END_CASE

          steplEintransport := STEP_420_E;

        END_IF

      END_IF

    // EINTRANSPORT ==================================================================
    STEP_410_E:
      (* Hinweis:
         - Ansteuerung Drehen
      *)
      Drehen.epZielPosition :=  BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport;
      Drehen.bpStarteAbsolutPositionierung := TRUE;


      (* Hinweis:
         - Ansteuerung Kippen
      *)
      Kippen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition_NachEintransport;
      Kippen.bpPositionieren  := TRUE;


      (* Hinweis:
         - Ansteuerung Vortransport
      *)
      CASE BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eGlastransport OF

        eGlastransport_AufEinlaufVorab:
          Glastransport.bpVortransportRueckwaertig := TRUE;

        eGlastransport_AufAuslaufVorab:
          Glastransport.bpVortransport := TRUE;

      END_CASE

      CASE BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport OF
        eDrehPosition0Grad:
          Querachse.epOeffnungsStellung := eZylinderStellung16mm;
          Querachse.bpStartPneumatik    := TRUE;

        eDrehPosition180Grad:
          IF ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke13mm ) THEN
            Querachse.epOeffnungsStellung := eZylinderStellung16mm;
            Querachse.bpStartPneumatik    := TRUE;
          ELSIF (BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke19mm ) THEN
            Querachse.epOeffnungsStellung := eZylinderStellung23mm;
            Querachse.bpStartPneumatik    := TRUE;
          ELSIF (BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke24mm ) THEN
            Querachse.epOeffnungsStellung := eZylinderStellung29mm;
            Querachse.bpStartPneumatik    := TRUE;
          END_IF

      END_CASE

      steplEintransport := STEP_420_E;


    // EINTRANSPORT ==================================================================
    STEP_420_E:

      // => Betriebsart des Vortransport abloeschen
      IF ( Glastransport.bpDone
           AND ( Glastransport.bpVortransport OR Glastransport.bpVortransportRueckwaertig ) )
           AND ( Querachse.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerachse )
      THEN
        Glastransport.bpVortransport             := FALSE;
        Glastransport.bpVortransportRueckwaertig := FALSE;
      END_IF

      (* Hinweis:
         - Drehung abgeschlossen [Drehen von 0- 180 Grad ; 180 - 0 Grad ]
      *)
      IF (  ( Drehen.bpDone OR NOT Drehen.bpStarteAbsolutPositionierung )
           AND Kippen.bpDone 
           AND NOT Glastransport.bpVortransport AND NOT Glastransport.bpVortransportRueckwaertig )
      THEN
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        Kippen.bpPositionieren := FALSE;
        steplEintransport := STEP_1000_E;
      END_IF

      // Ausnahmesituation:
      //   - Drehen
      IF ( Drehen.bpFehler ) THEN
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==================================================================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // EINTRANSPORT ==================================================================
    STEP_1000_E:
      BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := TRUE;

  // EINTRANSPORT ==================================================================
  END_CASE

ELSE

  IF (steplEintransport > STEP_0_E) THEN
    BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;

    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;

    Dickenverstellung.bpStartPneumatik   := FALSE;
    Querachse.bpStartPneumatik           := FALSE;
    Kippen.bpPositionieren               := FALSE;
    Drehen.bpStarteAbsolutPositionierung := FALSE;

    steplEintransport := STEP_0_E;
  END_IF

END_IF
END_ACTION