(* METADATA
{
	"v3Meta": {
		"objectGuid": "7cf149bd-d1d2-4190-82d5-7daf21613ba4"
	}
}
*)
FUNCTION_BLOCK Basic_Station_Anlegen_FB_V01_00_00 EXTENDS Basic_Station_Aktion_FB_V01_00_00
(* Hinweis:
   - Anlegen von Hand: Die Hoehenkontrolle faehrt auf Position, ggf. Hubrahmen einfahren und Anschlaege ausfahren,
     dann wartet die Aktion auf die Quittierung des Bedieners (Taster / Fusstaster)
   - Die Aktion schreibt nichts in den Glastransport und liest nur die Sensoren
   - Ob angelegt oder eingetragen wird, entscheidet das MMI ueber die Transferstation des Auftrags
     (Transferstation 1 = eigene Station: Anlegen, Fremdanlage: Eintransport; Anlegetisch hinter einer Brechanlage)
   - Mit der VSG-Schnittstelle entscheidet die Station selbst: die Station (Eintransport Schneidlinie) uebernimmt ueber
     bpUebernahmeEintransport oder beendet das Anlegen ueber bpBetriebBeendet
   - Hubrahmen und Anschlag nur mit den Ausbaustufen bHubrahmen und bAnschlag, sonst muessen sie nicht uebergeben werden
*)
VAR_IN_OUT

  // BOOLEAN
  blAnlegenErzwingen : BOOL; // Anlegen wurde erzwungen, die Aktion nimmt die Anforderung entgegen

END_VAR
VAR_INPUT

  // BOOLEAN
  bpAnlegenQuittiert          : BOOL;        // Bediener hat angelegt (steigende Flanke Taster / Fusstaster)
  bpVoraussetzungErfuellt     : BOOL := TRUE; // Station: Voraussetzung zum Start (z.B. Kipparme frei)
  bpAnschlagAutomatischFahren : BOOL;        // Station: Anschlaege fahren automatisch aus
  bpNeustart                  : BOOL;        // Station: Anlegen von vorne beginnen (z.B. nach Umschalten der Anschlaege)
  bpUebernahmeEintransport    : BOOL;        // Station (VSG-Schnittstelle): Eintransport der Schneidlinie uebernimmt, das Anlegen gibt ab
  bpBetriebBeendet            : BOOL;        // Station (VSG-Schnittstelle): Automatikbetrieb der Schneidlinie beendet, Scheibe muss neu angelegt werden

  // Bausteine
  Messachse : REFERENCE TO Messachse_FB_V01_00_00;
  Anschlag  : REFERENCE TO ZylinderPneumatik_Anschlag_FB_V01_00_00;
  Hubrahmen : REFERENCE TO ZylinderPneumatik_Riemen_FB_V01_00_00;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpAnlegenLampe          : BOOL; // Ampel gruen / Signal Scheibe aufgegeben (blinkt, bis angelegt ist)
  bpBedienerEingriff      : BOOL; // Aktion wartet auf den Bediener, Handfunktionen (Knebel, Hubrahmen) muessen im Automatikbetrieb greifen
  bpAnlegenInVorbereitung : BOOL; // Aktion fuehrt die Vorbereitung durch (vor dem Warten auf den Bediener)
  bpAnlegenAktiv          : BOOL; // Aktion ist gestartet und noch nicht abgeschlossen
  bpAnlegenFertig         : BOOL; // Aktion hat selbst abgeschlossen (epTypeHoehenmessung gueltig)
  bpGeblaeseAnforderung   : BOOL; // Geblaese soll laufen (Vorbereitung)
  bpGeblaeseStartenSensor : BOOL; // Der Einlaufsensor darf das Geblaese starten

  // TIME
  tpZeitBereitAnzulegen   : TIME; // Zeitpunkt, ab dem die Station bereit zum Anlegen ist (Statistik)

  // ENUM
  epTypeHoehenmessung     : ModusHoehenvermessung_EN;

END_VAR
VAR

  // BOOLEAN
  blAnschlagFehler       : BOOL;
  blAnschlagAusgefahren  : BOOL; // Anschlag ausgefahren oder nicht vorhanden
  blAnschlagFertig       : BOOL; // Anschlag fertig oder nicht vorhanden
  blHubrahmenFehler      : BOOL;
  blHubrahmenEingefahren : BOOL; // Hubrahmen eingefahren oder nicht vorhanden
  blSensorAnlegeseite    : BOOL; // Scheibe liegt an (Einlaufsensor belegt, Auslaufsensor frei)
  blSensorAuslaufBelegt  : BOOL;
  blModellscheibe        : BOOL;

END_VAR
//-------------------------------------------------------------------------------------------------
// ANLEGEN
//-------------------------------------------------------------------------------------------------
blAnschlagFehler       := FALSE;
blAnschlagAusgefahren  := TRUE;
blAnschlagFertig       := TRUE;
blHubrahmenFehler      := FALSE;
blHubrahmenEingefahren := TRUE;

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
  blAnschlagFehler      := Anschlag.bpFehler;
  blAnschlagAusgefahren := ( Anschlag.epStatusZylinder = eZylinderAusgefahren ) OR NOT bpAnschlagAutomatischFahren;
  blAnschlagFertig      := Anschlag.bpDone;
END_IF

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
  blHubrahmenFehler      := Hubrahmen.bpFehler;
  blHubrahmenEingefahren := ( Hubrahmen.epStatusZylinder = eZylinderEingefahren );
END_IF

// Scheibe liegt an: Einlaufsensor belegt, auf der Gegenseite frei (mit Vorab-Sensor, wenn die Station damit misst)
IF ( BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenmessungSensorVorabAuslauf ) THEN
  blSensorAuslaufBelegt := Glastransport.bpSensorAuslaufVorAb;
ELSE
  blSensorAuslaufBelegt := Glastransport.bpSensorAuslauf;
END_IF
blSensorAnlegeseite := Glastransport.bpSensorEinlauf AND NOT blSensorAuslaufBelegt;

blModellscheibe := ( BasisStationsParameter.wGlastyp[cWAND_1] = eScheibe_Modell );

IF( BasisStationsParameter.bAnlegen
    AND NOT BasisStationsParameter.bEintransport[cWAND_1]
    AND bpAutomatikAktiv )
THEN

  bpAnlegenAktiv := TRUE;

  // Ausnahmesituation
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

  IF ( Messachse.bpFehler ) THEN
    Messachse.bpPositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( bpNeustart ) THEN
    steplAktion := STEP_0_E;
  END_IF

  CASE steplAktion OF
    // ANLEGEN ==================================
    STEP_0_E:
      (* Hinweis:
         - Variablen initalisieren
         - Starten des Anlegevorgangs
         - Voraussetzung der Station muss erfuellt sein, der Motorschutz des Geblaeses muss in Ordnung sein
      *)
      bpFehler                := FALSE;
      bpGeblaeseStartenSensor := FALSE;

      // Auftrag nach Status neu setzen. Bei Wiederholung (z.B. Messung fehlerhaft) will die Scheibe neu angelegt werden
      IF ( BasisStationsParameter.eStatusAuftrag = eAuftragWiederholen ) THEN
        BasisStationsParameter.eStatusAuftrag := eAuftragAktivWiederholen;
      ELSE
        BasisStationsParameter.eStatusAuftrag := eAuftragAktiv;
      END_IF

      IF ( bpGeblaeseFehler ) THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplAktion := STEP_900_E;

      ELSIF ( bpVoraussetzungErfuellt ) THEN
        bpAnlegenLampe := FALSE;

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
          Anschlag.bpStartEinfahren := FALSE;
          Anschlag.bpStartAusfahren := FALSE;
        END_IF

        IF ( bpUebernahmeEintransport ) THEN
          steplAktion := STEP_200_E;
        ELSE
          blAnlegenErzwingen := FALSE;
          steplAktion := STEP_10_E;
        END_IF

      END_IF

    // ANLEGEN ==============================
    STEP_10_E:
      (* Hinweis:
         - Hubrahmen einfahren sofern er es nicht ist
         - Anschlag Ausfahren sofern gefordert
         - Hoehenkontrolle auf Position fahren
      *)
      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
        Hubrahmen.bpStartEinfahren := NOT blHubrahmenEingefahren;
      END_IF

      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
        Anschlag.bpStartAusfahren := bpAnschlagAutomatischFahren;
      END_IF

      IF ( BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen ) THEN
        IF ( Messachse.Antrieb.rpMaxPosition < ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) ) THEN
          Messachse.rpZielPosition := Messachse.Antrieb.rpMaxPosition;
        ELSE
          Messachse.rpZielPosition := ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset );
        END_IF
      ELSE
        Messachse.rpZielPosition := BasisStationsParameter.stMKs.stGlasdaten[cWAND_1].rlMinGlasHoehe;
      END_IF
      Messachse.bpPositionierung := TRUE;

      steplAktion := STEP_20_E;

    // ANLEGEN ==============================
    STEP_20_E:
      (* Anmerkung:
         - Korrekte Stati der Zylinder und Achsen abfragen
         - Das Geblaese laeuft in der Vorbereitung
      *)
      bpGeblaeseAnforderung := TRUE;

      IF (     blHubrahmenEingefahren
           AND blAnschlagAusgefahren
           AND ( Messachse.bpDone OR NOT BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen ) )
      THEN
        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
          Hubrahmen.bpStartEinfahren := FALSE;
        END_IF

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
          Anschlag.bpStartAusfahren := FALSE;
        END_IF

        Messachse.bpPositionierung := FALSE;
        bpGeblaeseAnforderung      := FALSE;

        // Anschlaege fahren nicht automatisch aus: erst auf den Taster warten, sonst direkt anlegen
        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag AND NOT bpAnschlagAutomatischFahren ) THEN
          steplAktion := STEP_30_E;
        ELSE
          tpZeitBereitAnzulegen  := TIME();
          bpDrosselklappeOeffnen := TRUE;
          steplAktion := STEP_100_E;
        END_IF

      END_IF

    // ANLEGEN ==============================
    STEP_30_E:
      (* Anmerkung:
         - Anschlaege fahren nicht automatisch aus, der Bediener faehrt sie mit dem Taster aus
         - Handfunktionen (Knebel, Hubrahmen) greifen im Automatikbetrieb
      *)
      bpAnlegenLampe := gbFlashbit05sec;

      // VSG-Schnittstelle: Automatikbetrieb beendet bzw. Eintransport wird uebernommen
      IF ( bpBetriebBeendet ) THEN
        BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
        bpAnlegenLampe := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

      IF ( bpUebernahmeEintransport ) THEN
        steplAktion := STEP_200_E;
      END_IF

      IF ( bpAnlegenQuittiert ) THEN
        Anschlag.bpStartAusfahren := TRUE;
        bpAnlegenLampe := FALSE;
        steplAktion := STEP_40_E;
      END_IF

      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
        IF ( blHubrahmenFehler ) THEN
          Hubrahmen.bpStartEinfahren := FALSE;
          Hubrahmen.bpStartAusfahren := FALSE;

          BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
          BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;

          steplAktion := STEP_900_E;
        END_IF
      END_IF

    // ANLEGEN ==============================
    STEP_40_E:
      (* Anmerkung:
         - Anschlaege ausfahren
      *)
      IF ( blAnschlagFertig
           AND blAnschlagAusgefahren )
      THEN
        tpZeitBereitAnzulegen := TIME();

        Anschlag.bpStartAusfahren := FALSE;

        bpDrosselklappeOeffnen  := TRUE;
        bpAnlegenLampe          := TRUE;
        bpGeblaeseStartenSensor := TRUE;

        steplAktion := STEP_100_E;
      END_IF

    // ANLEGEN ==============================
    STEP_100_E:
      (* Anmerkung:
         - Warten bis der Bediener die Scheibe angelegt und quittiert hat
         - Geblaese starten wenn dieses nicht schon gestartet ist
           => Belegen des Einlaufsensors
         - Handfunktionen (Knebel, Hubrahmen) greifen im Automatikbetrieb
      *)
      IF ( blSensorAnlegeseite
           OR blModellscheibe )
      THEN
        bpAnlegenLampe := TRUE;
      ELSE
        bpAnlegenLampe := gbFlashbit05sec;
      END_IF

      bpGeblaeseStartenSensor := TRUE;

      // VSG-Schnittstelle: Automatikbetrieb beendet bzw. Eintransport wird uebernommen
      IF ( bpBetriebBeendet ) THEN
        BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
        bpAnlegenLampe := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

      IF ( bpUebernahmeEintransport ) THEN
        steplAktion := STEP_200_E;
      END_IF

      // Scheibe wurde angelegt
      IF ( bpAnlegenQuittiert
           AND ( blSensorAnlegeseite
                 OR blModellscheibe ) )
      THEN
        bpAnlegenLampe          := FALSE;
        bpGeblaeseStartenSensor := FALSE;

        BasisStationsParameter.dwWartezeit[cWAND_1] := TIME_TO_DWORD( TIME() - tpZeitBereitAnzulegen );

        bpDrosselklappeOeffnen := FALSE;

        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

        // Wenn Modellscheibe -> Anschlaege einfahren
        IF ( blModellscheibe
             AND BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag )
        THEN
          Anschlag.bpStartEinfahren := TRUE;
          Anschlag.bpStartAusfahren := FALSE;
          steplAktion := STEP_300_E;
        ELSE
          steplAktion := STEP_1000_E;
        END_IF

      END_IF

      (* Hinweis:
         - Der Auslauf- Sensor muss frei sein, um mit dem Einschleusen des Glases zu beginnen
      *)
      IF ( blSensorAuslaufBelegt
           AND bpAnlegenQuittiert
           AND NOT blModellscheibe )
      THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_ANLEGEN_SENSOR_AUSLAUF_BELEGT,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                    wpgFehlerdaten );
      END_IF

      (* Hinweis:
         - Der Einlaufsensor muss belegt sein
      *)
      IF ( NOT Glastransport.bpSensorEinlauf
           AND bpAnlegenQuittiert
           AND NOT blModellscheibe )
      THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_ANLEGEN_SENSOR_EINLAUF_NICHT_BELEGT,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                    wpgFehlerdaten );
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

    // ANLEGEN ==================================
    STEP_200_E:
      (* Anmerkung:
         - Die Station (Eintransport Schneidlinie) hat uebernommen: Glastransport, Hubrahmen, Anschlaege und
           Hoehenkontrolle gehoeren jetzt der Station, das Anlegen wartet bis der Auftrag beendet ist
      *)
      bpAnlegenLampe := FALSE;

    // ANLEGEN ==================================
    STEP_300_E:
      (* Anmerkung:
         - Anschlaege gesenkt
      *)
      IF ( blAnschlagFertig ) THEN
        Anschlag.bpStartEinfahren := FALSE;

        steplAktion := STEP_1000_E;
      END_IF

    // ANLEGEN ==================================
    STEP_900_E:
      BasisStationsParameter.eStatusAuftrag := eAuftragFehler;

      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // ANLEGEN ==================================
    STEP_1000_E:
      epTypeHoehenmessung := Modus_Positionieren_Auf_Oberkante_2_Sensoren;
      bpAnlegenFertig     := TRUE;

      BasisStationsParameter.bAnlegenAbgeschlossen := TRUE;

  // ANLEGEN ==================================
  END_CASE

  (* Hinweis:
     - Ausgaenge fuer die Station: Bediener-Eingriff (Handfunktionen im Automatikbetrieb) und Vorbereitung
  *)
  bpBedienerEingriff      := ( steplAktion = STEP_30_E ) OR ( steplAktion = STEP_100_E );
  bpAnlegenInVorbereitung := ( steplAktion <= STEP_20_E );
  bpAnlegenAktiv          := ( steplAktion <= STEP_100_E );

ELSE

  bpBedienerEingriff      := FALSE;
  bpAnlegenInVorbereitung := FALSE;
  bpAnlegenAktiv          := FALSE;

  IF( steplAktion > STEP_0_E ) THEN

    BasisStationsParameter.bAnlegenAbgeschlossen := FALSE;
    bpFehler                     := FALSE;
    bpAnlegenFertig              := FALSE;
    bpAnlegenLampe               := FALSE;
    bpGeblaeseAnforderung        := FALSE;
    bpGeblaeseStartenSensor      := FALSE;
    bpDrosselklappeOeffnen       := FALSE;
    Messachse.bpPositionierung   := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK