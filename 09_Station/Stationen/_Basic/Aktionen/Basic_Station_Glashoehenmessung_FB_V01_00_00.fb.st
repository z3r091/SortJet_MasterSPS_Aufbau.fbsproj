(* METADATA
{
	"v3Meta": {
		"objectGuid": "6eb3a978-58c6-42ff-94c5-7df5c97bfde5"
	}
}
*)
FUNCTION_BLOCK Basic_Station_Glashoehenmessung_FB_V01_00_00 EXTENDS Basic_Station_Aktion_FB_V01_00_00
(* Hinweis:
   - Glashoehenmessung der Station mit der Hoehenkontrolle (Messachse)
   - Der Modus kommt aus dem Anlegen bzw. dem Eintransport (epTypeHoehenmessung):
     Positionieren auf Oberkante (2 Sensoren), Vermessen Oberkante (1 Sensor), Vermessen Ober- und Unterkante (2 Sensoren)
   - Am Ende vom Tisch (bMessachseAmEndeVomTisch) fragt eine fehlerhafte Hoehe den Bediener (Quittieren, Scheibe zurueckfahren)
   - Hubrahmen und Anschlag nur mit den Ausbaustufen bHubrahmen und bAnschlag, sonst muessen sie nicht uebergeben werden
   - Mit dem Vortransport (Option der Station) wird die Scheibe vor der Messung auf den Vorab-Sensor positioniert
*)
VAR_IN_OUT

  // BOOLEAN
  blAnlegenErzwingen : BOOL; // Anlegen soll erzwungen werden (Scheibe wird neu angelegt)

END_VAR
VAR_INPUT

  // BOOLEAN
  bpTasterQuittierung : BOOL; // Station: Taster Fehlmessung quittieren (steigende Flanke)
  bpKnebelZurueck     : BOOL; // Station: Knebel Scheibe zurueckfahren

  // ENUM
  epTypeHoehenmessung : ModusHoehenvermessung_EN; // Modus der Hoehenmessung aus dem Anlegen bzw. Eintransport

  // Bausteine
  Messachse : REFERENCE TO Messachse_FB_V01_00_00;
  Anschlag  : REFERENCE TO ZylinderPneumatik_Anschlag_FB_V01_00_00;
  Hubrahmen : REFERENCE TO ZylinderPneumatik_Riemen_FB_V01_00_00;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpAnlegenLampe      : BOOL; // Ampel gruen / Signal Scheibe aufgegeben
  bpSignalFehlmessung : BOOL; // Taster Fehlmessung quittieren (blinkt)
  bpBedienerEingriff  : BOOL; // Aktion wartet auf den Bediener, Handfunktionen (Knebel, Hubrahmen) muessen im Automatikbetrieb greifen

  // REAL
  rpScheibenHoehe       : REAL; // Ergebnis der Vermessung Ober- und Unterkante
  rpAbstandZurNulllinie : REAL;

END_VAR
VAR

  // BOOLEAN
  blAnschlagFehler  : BOOL;
  blHubrahmenFehler : BOOL;
  blHoeheMessbar    : BOOL; // Die Zielhoehe liegt im Messbereich der Hoehenkontrolle

END_VAR
//-------------------------------------------------------------------------------------------------
// GLASHOEHENMESSUNG
//-------------------------------------------------------------------------------------------------
blAnschlagFehler  := FALSE;
blHubrahmenFehler := FALSE;

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
  blAnschlagFehler := Anschlag.bpFehler;
END_IF

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
  blHubrahmenFehler := Hubrahmen.bpFehler;
END_IF

blHoeheMessbar := ( Messachse.Antrieb.rpMaxPosition >= ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) );

IF( BasisStationsParameter.bGlashoehenmessung )THEN

  // Ausnahmesituation
  IF ( Messachse.bpFehler ) THEN
    Messachse.bpPositionierung := FALSE;
    Messachse.bpVermessen_Oberkante_1_Sensor := FALSE;
    Messachse.bpVermessen_OberUndUnterkante_2_Sensoren := FALSE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
    IF ( blAnschlagFehler ) THEN
      Anschlag.bpStartAusfahren := FALSE;
      Anschlag.bpStartEinfahren := FALSE;
      BasisStationsParameter.wFehlerNummer := Anschlag.wpFehlerNr;
      steplAktion := STEP_900_E;
    END_IF
  END_IF

  IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
    IF ( blHubrahmenFehler ) THEN
      Hubrahmen.bpStartAusfahren := FALSE;
      Hubrahmen.bpStartEinfahren := FALSE;
      BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
      steplAktion := STEP_900_E;
    END_IF
  END_IF

  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpVortransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // HOEHENMESSUNG ==================================
    STEP_0_E:
      (* Hinweis:
         - Variablen initalisieren
      *)
      bpFehler := FALSE;
      BasisStationsParameter.eStatusAuftrag := eAuftragAktiv;
      BasisStationsParameter.bGlashoehenmessungAbgeschlossen := FALSE;

      rpScheibenHoehe       := 0.0;
      rpAbstandZurNulllinie := 0.0;

      IF ( BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bVortransport ) THEN
        Glastransport.bpVortransport := TRUE;
        steplAktion := STEP_10_E;
      ELSE
        steplAktion := STEP_20_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_10_E:
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpVortransport := FALSE;
        steplAktion := STEP_20_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_20_E:
      (* Hinweis:
         - Fuer die Steuerschrittkette muessen wir einmal kurz in eAuftragAktiv wechseln bevor
           in Schritt 800 dann eAuftrakErfolgreich gesetzt werden kann
         - Ohne Hoehenkontrolle wird nicht gemessen
      *)
      IF ( BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen
           AND BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
        steplAktion := STEP_100_E;
      ELSE
        steplAktion := STEP_800_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_100_E:
      (* Hinweis:
         - Je nach gesetzten Modi aus dem Anlegen/Eintransport wird nun entsprechend die Hoehe gemessen
      *)
      CASE epTypeHoehenmessung OF

        Modus_Vermessen_Oberkante_1_Sensor:
          steplAktion := STEP_400_E;

        Modus_Vermessen_OberUndUnterkante_2_Sensoren:
          steplAktion := STEP_600_E;

        ELSE
          // Modus_Positionieren_Auf_Oberkante_2_Sensoren
          steplAktion := STEP_200_E;

      END_CASE

    // HOEHENMESSUNG ==================================
    STEP_200_E:
      (* Hinweis:
         - Messachse nochmal auf Position fahren
      *)
      IF ( Messachse.Antrieb.rpMaxPosition < ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) ) THEN
        Messachse.rpZielPosition := Messachse.Antrieb.rpMaxPosition;
      ELSE
        Messachse.rpZielPosition := ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset );
      END_IF
      Messachse.bpPositionierung := TRUE;

      steplAktion := STEP_210_E;

    // HOEHENMESSUNG ==================================
    STEP_210_E:
      IF ( Messachse.bpDone ) THEN
        Messachse.bpPositionierung := FALSE;
        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachseAmEndeVomTisch ) THEN
          steplAktion := STEP_310_E;
        ELSE
          steplAktion := STEP_300_E;
        END_IF
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_300_E:
      (* Hinweis:
         - Auswertung der Sensorik
      *)
      IF ( blHoeheMessbar ) THEN
        CASE Messachse.epGlashoehenTyp OF

          eGlasHoeheOK:
            steplAktion := STEP_800_E;

          eGlasZuHoch:
            BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe );
            SpsWarnung( eFehler_Station,
                        cMELDUNG_MESSUNG_SCHEIBE_ZU_HOCH,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                        BasisStationsParameter.awFehlerInformationen );

            BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
            steplAktion := STEP_1000_E;

          eGlasZuNiedrig:
            BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe );
            SpsWarnung( eFehler_Station,
                        cMELDUNG_MESSUNG_SCHEIBE_ZU_NIEDRIG,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                        BasisStationsParameter.awFehlerInformationen );

            BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
            steplAktion := STEP_1000_E;

        END_CASE
      ELSE
        steplAktion := STEP_800_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_310_E:
      (* Hinweis:
         - Auswertung der Sensorik, Messachse am Ende vom Tisch: bei fehlerhafter Hoehe fragt die Station den Bediener
      *)
      IF ( blHoeheMessbar ) THEN
        CASE Messachse.epGlashoehenTyp OF

          eGlasHoeheOK:
            steplAktion := STEP_800_E;

          eGlasZuHoch:
            BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe );
            SpsWarnung( eFehler_Station,
                        cMELDUNG_MESSUNG_SCHEIBE_ZU_HOCH,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                        BasisStationsParameter.awFehlerInformationen );

            steplAktion := STEP_320_E;

          eGlasZuNiedrig:
            BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe );
            SpsWarnung( eFehler_Station,
                        cMELDUNG_MESSUNG_SCHEIBE_ZU_NIEDRIG,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                        BasisStationsParameter.awFehlerInformationen );

            steplAktion := STEP_320_E;

        END_CASE
      ELSE
        steplAktion := STEP_800_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_320_E:
      (* Anmerkung:
         - Ampel
         - Moeglichkeit Fehlmessung quittieren --> Scheibe freigegeben zum Austransport
         - Knebelschalter Glas zurueck auf die Station fahren (Handfunktionen greifen im Automatikbetrieb)
         - Quittiern
      *)
      bpSignalFehlmessung := gbFlashbit05sec;
      bpAnlegenLampe      := gbFlashbit05sec;

      IF ( bpTasterQuittierung ) THEN
        bpAnlegenLampe      := FALSE;
        bpSignalFehlmessung := FALSE;

        steplAktion := STEP_800_E;
      END_IF

      (* Hinweis:
         - Scheibe zurueck fahren [Anlegen wiederholen]
      *)
      IF ( bpKnebelZurueck ) THEN
        steplAktion := STEP_330_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_330_E:
      (* Hinweis:
         - Knebel und Hubrahmen werden von den Handfunktionen der Station bedient
      *)
      bpAnlegenLampe := FALSE;

      IF ( NOT Glastransport.bpSensorAuslauf ) THEN
        bpSignalFehlmessung := TRUE;
      ELSE
        bpSignalFehlmessung := gbFlashbit05sec;
      END_IF

      IF ( bpTasterQuittierung ) THEN
        bpAnlegenLampe      := FALSE;
        bpSignalFehlmessung := FALSE;

        blAnlegenErzwingen := TRUE;

        BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;

        steplAktion := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Hubpalette senkt / hebt nicht in der vorgeschriebenen Zeit bzw. Sensor schaltet nicht
      *)
      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
        IF ( blHubrahmenFehler ) THEN
          Hubrahmen.bpStartEinfahren := FALSE;
          Hubrahmen.bpStartAusfahren := FALSE;

          BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
          BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;

          steplAktion := STEP_900_E;
        END_IF
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_400_E:
      (* Hinweis:
         - Messachse auf Position fahren
      *)
      Messachse.rpZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe - Messachse.ppParameterBaustein.rStreckePositionieren;
      Messachse.bpPositionierung := TRUE;

      steplAktion := STEP_410_E;

    // HOEHENMESSUNG ==================================
    STEP_410_E:
      IF ( Messachse.bpDone ) THEN
        Messachse.bpPositionierung := FALSE;
        steplAktion := STEP_420_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_420_E:
      (* Hinweis:
         - Messung starten
      *)
      Messachse.rpZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe;
      Messachse.bpVermessen_Oberkante_1_Sensor := TRUE;

      steplAktion := STEP_430_E;

    // HOEHENMESSUNG ==================================
    STEP_430_E:
      (* Hinweis:
         - Messende abwarten
      *)
      IF ( Messachse.bpDone ) THEN
        Messachse.bpVermessen_Oberkante_1_Sensor := FALSE;
        steplAktion := STEP_500_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_500_E:
      (* Hinweis:
         - Auswertung der Messung
      *)
      IF ( blHoeheMessbar ) THEN
        CASE Messachse.epGlashoehenTypMode2 OF

          eGlasHoeheOK:
            steplAktion := STEP_800_E;

          eGlasZuHoch:
            BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe );
            SpsWarnung( eFehler_Station,
                        cMELDUNG_MESSUNG_SCHEIBE_ZU_HOCH,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                        BasisStationsParameter.awFehlerInformationen );

            BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
            steplAktion := STEP_1000_E;

          eGlasZuNiedrig:
            BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe );
            SpsWarnung( eFehler_Station,
                        cMELDUNG_MESSUNG_SCHEIBE_ZU_NIEDRIG,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                        BasisStationsParameter.awFehlerInformationen );

            BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
            steplAktion := STEP_1000_E;

        END_CASE
      ELSE
        steplAktion := STEP_800_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_600_E:
      (* Hinweis:
         - Messachse verfahren lassen um Scheibenkanten zu suchen
      *)
      Messachse.rpErwarteteScheibenHoehe := BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe;
      Messachse.bpVermessen_OberUndUnterkante_2_Sensoren := TRUE;

      steplAktion := STEP_610_E;

    // HOEHENMESSUNG ==================================
    STEP_610_E:
      (* Hinweis:
         - Scheibenkantensuche abgeschlossen
      *)
      IF ( Messachse.bpVermessenAbgeschlossen ) THEN
        Messachse.bpVermessen_OberUndUnterkante_2_Sensoren := FALSE;

        rpScheibenHoehe       := Messachse.rlMessErgebnis;
        rpAbstandZurNulllinie := Messachse.rlScheibenunterkante - Messachse.ppParameterBaustein.rAbstandSensorenOberUndUnterkante;

        steplAktion := STEP_700_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_700_E:
      (* Hinweis:
         - Auswertung der Scheibenkantensuche
      *)
      IF ( blHoeheMessbar ) THEN
        CASE Messachse.epGlashoehenTypMode2 OF

          eGlasHoeheOK:
            steplAktion := STEP_800_E;

          eGlasZuHoch:
            BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe );
            SpsWarnung( eFehler_Station,
                        cMELDUNG_MESSUNG_SCHEIBE_ZU_HOCH,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                        BasisStationsParameter.awFehlerInformationen );

            BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
            steplAktion := STEP_1000_E;

          eGlasZuNiedrig:
            BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe );
            SpsWarnung( eFehler_Station,
                        cMELDUNG_MESSUNG_SCHEIBE_ZU_NIEDRIG,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                        BasisStationsParameter.awFehlerInformationen );

            BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
            steplAktion := STEP_1000_E;

          // Die Glasvermessung war fehlerhaft. Scheibe neu anlegen.
          eGlasMessungWiederholen:
            BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe );
            SpsWarnung( eFehler_Station,
                        cMELDUNG_MESSUNG_FEHLMESSUNG,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                        BasisStationsParameter.awFehlerInformationen );

            BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
            steplAktion := STEP_1000_E;

        END_CASE

      ELSE
        steplAktion := STEP_800_E;
      END_IF

    // HOEHENMESSUNG ==================================
    STEP_800_E:
      (* Hinweis:
         - Auftragsstatus setzen und beenden
      *)
      BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

      steplAktion := STEP_1000_E;

    // HOEHENMESSUNG ==================================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.eStatusAuftrag := eAuftragFehler;

      BasisStationsParameter.bFehler := TRUE;

    // HOEHENMESSUNG ==================================
    STEP_1000_E:
      BasisStationsParameter.bGlashoehenmessungAbgeschlossen := TRUE;

  // HOEHENMESSUNG ==================================
  END_CASE

  // Waehrend ein fehlerhaftes Messergebnis quittiert oder die Scheibe zurueckgefahren wird: Handfunktionen greifen
  bpBedienerEingriff := ( steplAktion = STEP_320_E ) OR ( steplAktion = STEP_330_E );

ELSE

  bpBedienerEingriff := FALSE;

  IF( steplAktion > STEP_0_E )THEN

    Messachse.bpPositionierung := FALSE;
    Messachse.bpVermessen_Oberkante_1_Sensor := FALSE;
    Messachse.bpVermessen_OberUndUnterkante_2_Sensoren := FALSE;

    Glastransport.bpVortransport := FALSE;

    bpFehler            := FALSE;
    bpAnlegenLampe      := FALSE;
    bpSignalFehlmessung := FALSE;

    BasisStationsParameter.bGlashoehenmessungAbgeschlossen := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK