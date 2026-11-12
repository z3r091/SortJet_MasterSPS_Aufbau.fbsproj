(* METADATA
{
	"v3Meta": {
		"objectGuid": "ad382906-41ff-48e9-a081-ed27d36bc901"
	}
}
*)
FUNCTION_BLOCK Drehstation_Eintransport_FB_V01_00_00 EXTENDS Basic_Station_Eintransport_FB_V01_00_00
VAR_INPUT

  // BOOL
  bpVorabDrehenAktiv : BOOL; // Status: Vorab-Drehen der Station laeuft

  // Bausteine (Kippen, Geblaese usw. kommen vom Basic-Baustein)
  Drehen            : REFERENCE TO Drehstation_Drehen_FB_V01_00_00;
  Querfahrt         : REFERENCE TO Querfahrt_FB_V01_00_00;
  Querachse         : REFERENCE TO ZylinderPneumatik_3Wege_FB_V01_00_00;

END_VAR
//-------------------------------------------------------------------------------------------------
// EINTRANSPORT
//-------------------------------------------------------------------------------------------------
IF (  BasisStationsParameter.bEintransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;
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
    // EINTRANSPORT =====================
    STEP_0_E:
      bpFehler := FALSE;

      (* Hinweis:
         - Variablen zurueck setzen
         - Sicherstellen dass das Geblaese aktiv ist
      *)
      IF ( bpGeblaeseAktiv AND NOT bpVorabDrehenAktiv ) THEN

        steplAktion := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Geblaese
      *)
      IF ( Geblaese.bpFehler ) THEN

        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;

        steplAktion := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  ANSTEUERUNG DER BAUSTEIN-KOMPONENTEN
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
      IF Drehen.epZielPosition <> eDrehPosition0Grad THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_DREHPOSITION;
        steplAktion := STEP_900_E;
      ELSE
        steplAktion := STEP_110_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_110_E:
      (* Hinweis:
         - Drehung abgeschlossen [Drehen von 0- 180 Grad ; 180 - 0 Grad ]
      *)
      IF ( ( Drehen.bpDone OR NOT Drehen.bpStarteAbsolutPositionierung )
           AND Kippen.bpDone
           AND ( Querachse.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerachse )
           AND ( Dickenverstellung.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[wWand] ) )
      THEN
        Dickenverstellung.bpStartPneumatik   := FALSE;
        Querachse.bpStartPneumatik           := FALSE;
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        Kippen.bpPositionieren               := FALSE;

        steplAktion := STEP_120_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_120_E:
      (* Hinweis:
         - Sicherstellen das die Zielposition erreicht worden ist
      *)
      IF ( Querfahrt.bpZielPositionErreicht OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt ) THEN
        steplAktion := STEP_200_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(Querfahrt.rpAktuellePosition);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(Querfahrt.rpZielPosition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplAktion := STEP_900_E;

      END_IF

    // EINTRANSPORT =====================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES GLAS-TRANSPORTS [EINTRANSPORT]
      //
      //  Hinweis:
      //  - Anhand der Drehposition bestimmen um welchen Eintransport-Typ es sich handelt
      //    => Position 0 Grad   : Transport ueber den Einlaufsensor
      //    => Position 180 Grad : Transport ueber den Auslaufsensor
      // ---------------------------------------------------------------------------------------

      Glastransport.pAuftrag                   := BasisStationsParameter.pAuftrag[wWand];
      Glastransport.bpScheibentrennen          := BasisStationsParameter.bScheibentrennen[wWand];
      Glastransport.bpEintransport             := NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      Glastransport.bpEintransportRueckwaertig := BasisStationsParameter.bRueckwaertsTransportieren[wWand];

      IF BasisStationsParameter.pAuftrag[wWand].bLetzteScheibe THEN
        steplAktion := STEP_400_E;
      ELSE
        steplAktion := STEP_300_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_300_E:
      // ---------------------------------------------------------------------------------------
      //  OPTION - EINTRANSPORT BIT LETZTE SCHEIBE = FALSE [KEINE DREH-BEWEGUNG]
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      BasisStationsParameter.dwWartezeit[wWand] := Glastransport.dwpWartezeit;

      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpEintransport             := FALSE;
        Glastransport.bpEintransportRueckwaertig := FALSE;

        steplAktion := STEP_1000_E;
      END_IF

    // EINTRANSPORT =====================
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
      BasisStationsParameter.dwWartezeit[wWand] := Glastransport.dwpWartezeit;

      // => Glastransport gibt die Freigabe zum Drehen \ Kippen \ etc.
      IF ( Glastransport.bpFreigabeFremdprozess
           AND BasisStationsParameter.pAuftrag[wWand].bLetzteScheibe )
      THEN
        Drehen.epZielPosition :=  BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport;
        Drehen.bpStarteAbsolutPositionierung := TRUE;

        CASE BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport OF
          eDrehPosition0Grad:
            Querachse.epOeffnungsStellung := eZylinderStellung16mm;
            Querachse.bpStartPneumatik    := TRUE;

          eDrehPosition180Grad:
            IF ( BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke13mm ) THEN
              Querachse.epOeffnungsStellung := eZylinderStellung16mm;
              Querachse.bpStartPneumatik    := TRUE;
            ELSIF (BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke19mm ) THEN
              Querachse.epOeffnungsStellung := eZylinderStellung23mm;
              Querachse.bpStartPneumatik    := TRUE;
            ELSIF (BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke24mm ) THEN
              Querachse.epOeffnungsStellung := eZylinderStellung29mm;
              Querachse.bpStartPneumatik    := TRUE;
            END_IF

        END_CASE

        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachEintransport;
        Kippen.bpPositionieren := TRUE;

      END_IF

      // => Glastransport hat seinen Eintransport abgeschlossen
      IF ( Glastransport.bpDone ) THEN

        Glastransport.bpEintransport             := FALSE;
        Glastransport.bpEintransportRueckwaertig := FALSE;

        IF ( NOT Drehen.bpStarteAbsolutPositionierung ) THEN
          steplAktion := STEP_410_E;
        ELSE

          CASE BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport OF
            eDrehPosition0Grad:
              Querachse.epOeffnungsStellung := eZylinderStellung16mm;
              Querachse.bpStartPneumatik    := TRUE;

            eDrehPosition180Grad:
              IF ( BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke13mm ) THEN
                Querachse.epOeffnungsStellung := eZylinderStellung16mm;
                Querachse.bpStartPneumatik    := TRUE;
              ELSIF (BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke19mm ) THEN
                Querachse.epOeffnungsStellung := eZylinderStellung23mm;
                Querachse.bpStartPneumatik    := TRUE;
              ELSIF (BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke24mm ) THEN
                Querachse.epOeffnungsStellung := eZylinderStellung29mm;
                Querachse.bpStartPneumatik    := TRUE;
              END_IF

          END_CASE

          steplAktion := STEP_420_E;

        END_IF

      END_IF

    // EINTRANSPORT =====================
    STEP_410_E:
      (* Hinweis:
         - Ansteuerung Drehen und Kippen nur bei der letzten Scheibe
      *)
      IF BasisStationsParameter.pAuftrag[wWand].bLetzteScheibe THEN
        Drehen.epZielPosition :=  BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport;
        Drehen.bpStarteAbsolutPositionierung := TRUE;

        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachEintransport;
        Kippen.bpPositionieren  := TRUE;
      END_IF

      (* Hinweis:
         - Ansteuerung Vortransport
      *)
      CASE BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eGlastransport OF

        eGlastransport_AufEinlaufVorab:
          Glastransport.bpVortransportRueckwaertig := TRUE;

        eGlastransport_AufAuslaufVorab:
          Glastransport.bpVortransport := TRUE;

      END_CASE

      CASE BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport OF
        eDrehPosition0Grad:
          Querachse.epOeffnungsStellung := eZylinderStellung16mm;
          Querachse.bpStartPneumatik    := TRUE;

        eDrehPosition180Grad:
          IF ( BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke13mm ) THEN
            Querachse.epOeffnungsStellung := eZylinderStellung16mm;
            Querachse.bpStartPneumatik    := TRUE;
          ELSIF (BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke19mm ) THEN
            Querachse.epOeffnungsStellung := eZylinderStellung23mm;
            Querachse.bpStartPneumatik    := TRUE;
          ELSIF (BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke <= Allgemeine_MKs.wgMKScheibenDicke24mm ) THEN
            Querachse.epOeffnungsStellung := eZylinderStellung29mm;
            Querachse.bpStartPneumatik    := TRUE;
          END_IF

      END_CASE

      steplAktion := STEP_420_E;

    // EINTRANSPORT =====================
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
           AND ( Kippen.bpDone OR NOT Kippen.bpPositionieren )
           AND NOT Glastransport.bpVortransport AND NOT Glastransport.bpVortransportRueckwaertig )
      THEN
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        Kippen.bpPositionieren := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

      // Ausnahmesituation:
      //   - Drehen
      IF ( Drehen.bpFehler ) THEN
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
        steplAktion := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // EINTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bEintransportAbgeschlossen[wWand] := TRUE;

  // EINTRANSPORT =====================
  END_CASE

ELSE

  IF (steplAktion > STEP_0_E) THEN
    bpFehler := FALSE;
    BasisStationsParameter.bEintransportAbgeschlossen[wWand] := FALSE;

    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;

    Dickenverstellung.bpStartPneumatik   := FALSE;
    Querachse.bpStartPneumatik           := FALSE;
    Kippen.bpPositionieren               := FALSE;
    Drehen.bpStarteAbsolutPositionierung := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK