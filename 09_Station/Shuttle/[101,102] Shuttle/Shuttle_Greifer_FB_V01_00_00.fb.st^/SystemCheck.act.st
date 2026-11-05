(* METADATA
{
  "v3Meta": {
    "objectGuid": "63c381b9-2c67-47de-a914-419d14940c59"
  }
}
*)
ACTION SystemCheck
//-------------------------------------------------------------------------------------------------
// AKTION: SYSTEMCHECK
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Greifer in einen sicheren Grundzustand bringen: Greifer eingefahren, Zange offen, Grundstellung,
     Glasrueckhalter eingefahren
   - Greifer ausgefahren und nur der Sensor der Greiferseite belegt (Scheibe haengt im Greifer):
     Scheibe mit gekoppeltem Glastransport fertig transportieren und quittieren
       => letzter Ablauf Austransport: Scheibe in den Faecherwagen schieben
       => sonst: Scheibe auf das Shuttle ziehen
       => Greiferzange bereits offen: Scheibe nicht gegriffen bzw. schon abgegeben, keine Quittierung
   - Greifer ausgefahren und Sensor der Gegenseite belegt: Zustand nicht automatisch loesbar -> Meldung,
     Bediener raeumt im Handbetrieb
*)
IF ( bpCheck ) THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
    steplCheck := STEP_900_E;
  END_IF

  IF ( GreiferHub.bpFehler ) THEN
    wpFehlerNr := GreiferHub.wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF

  // Ausnahmesituation: keine Greiferzange auf der Greiferseite aus der MK
  IF ( NOT blZangeSeiteVorhanden ) THEN
    wpFehlerNr := cMELDUNG_AUFTRAGSDATEN_SHUTTLE_GREIFER_AUFTRAGSTYP_UNGUELTIG;
    steplCheck := STEP_900_E;
  END_IF

  IF ( Zange[ilZange].bpFehler ) THEN
    wpFehlerNr := Zange[ilZange].wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF

  (* Hinweis:
     - Zeitueberwachung der Wartestellen: Timer bei jedem Schrittwechsel neu starten
  *)
  IF ( steplCheck <> steplCheckMerker ) THEN
    tonlUeberwachungCheck( IN := FALSE );
    steplCheckMerker := steplCheck;
  END_IF

  CASE steplCheck OF
    // SYSTEM CHECK ==============================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
         - Warten bis die Greiferachse bereit und referenziert ist
      *)
      bprtScheibe                   := FALSE;
      bpSystemCheckAbgeschlossen    := FALSE;
      bpAnforderungSlaveKopplung    := FALSE;
      bpKorrekturfahrtAnfordern     := FALSE;
      bpVorpositioniertEintransport := FALSE;
      blCheckScheibeZiehen          := FALSE;
      blCheckNichtQuittieren        := FALSE;

      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( tonlAntriebFreigegeben.Q AND Antrieb.bpIstReferenziert ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_10_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ANTRIEB_NICHT_BEREIT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK ==============================
    STEP_10_E:
      (* Hinweis:
         - Stellung des Greifers und Sensoren auswerten
      *)
      IF ( in_bGreiferEingefahren AND NOT in_bGreiferAusgefahren ) THEN
        steplCheck := STEP_800_E;

      ELSIF ( in_bGreiferAusgefahren AND NOT in_bGreiferEingefahren ) THEN
        IF ( NOT bpSensorEinlauf AND NOT bpSensorAuslauf ) THEN
          steplCheck := STEP_100_E;

        ELSIF ( blSensorSeite AND NOT blSensorGegenseite ) THEN
          // Scheibe im Greifer: letzten Auftrag beachten (Austransport -> in den Faecherwagen schieben, sonst auf das Shuttle ziehen)
          blCheckScheibeZiehen := ( pAuftrag.wAuftrag <> eStation_Austransport );
          IF ( blCheckScheibeZiehen ) THEN
            steplCheck := STEP_400_E;
          ELSE
            steplCheck := STEP_500_E;
          END_IF

        ELSE
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_GREIFER_STOESSEL_IST_ZUSTAND_NICHT_LOESBAR;
          steplCheck := STEP_900_E;
        END_IF

      ELSE
        // Zwischenstellung: Greifer einfahren
        GreiferHub.bpStartAusfahren := FALSE;
        GreiferHub.bpStartEinfahren := TRUE;
        steplCheck := STEP_20_E;

      END_IF

    // SYSTEM CHECK ==============================
    STEP_20_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone ) THEN
        GreiferHub.bpStartEinfahren := FALSE;
        steplCheck := STEP_800_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_EINGEFAHREN;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK ==============================
    STEP_100_E:
      (* Hinweis:
         - Greifer ausgefahren ohne Scheibe an den Sensoren: Zange oeffnen
      *)
      Zange[ilZange].epSollZylinderStellung  := eZylinderStellung29mm;
      Zange[ilZange].bpStartZylinderBewegung := TRUE;

      steplCheck := STEP_110_E;

    // SYSTEM CHECK ==============================
    STEP_110_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( Zange[ilZange].bpDone ) THEN
        Zange[ilZange].bpStartZylinderBewegung := FALSE;
        steplCheck := STEP_120_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GEOEFFNET;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK ==============================
    STEP_120_E:
      (* Hinweis:
         - Greiferzange aus dem Glas fahren (in Richtung Shuttle), Verfahrbereich pruefen
      *)
      rlZielPosition := Antrieb.rpIstPosition + rlRichtung * ppParameterGreifer.rGreiferAusDemGlasFahrPosition;

      IF (     ( rlZielPosition < Antrieb.rpMaxPosition )
           AND ( rlZielPosition > Antrieb.rpMinPosition ) )
      THEN
        M_Fahren( epBetriebsart     := RELATIV,
                  rpZielPosition    := rlRichtung * ppParameterGreifer.rGreiferAusDemGlasFahrPosition,
                  rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit );
        steplCheck := STEP_130_E;
      ELSE
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_GREIFER_STOESSEL_IST_ZUSTAND_NICHT_LOESBAR;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK ==============================
    STEP_130_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        GreiferHub.bpStartAusfahren := FALSE;
        GreiferHub.bpStartEinfahren := TRUE;

        steplCheck := STEP_140_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK ==============================
    STEP_140_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone ) THEN
        GreiferHub.bpStartEinfahren := FALSE;
        steplCheck := STEP_800_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_EINGEFAHREN;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE AUF DAS SHUTTLE ZIEHEN ==============================
    STEP_400_E:
      (* Hinweis:
         - Greiferzange offen: Scheibe nicht gegriffen -> trotzdem auf das Shuttle fahren, nicht quittieren
         - Greiferzange nicht offen: Scheibe gegriffen -> Zange schliessen
      *)
      IF (    ( Zange[ilZange].epStatusZylinderStellung = eZylinderStellung16mm )
           OR ( Zange[ilZange].epStatusZylinderStellung = eZylinderStellung23mm )
           OR ( Zange[ilZange].epStatusZylinderStellung = eZylinderStellung29mm ) )
      THEN
        blCheckNichtQuittieren     := TRUE;
        bpAnforderungSlaveKopplung := TRUE;
        steplCheck := STEP_420_E;
      ELSE
        Zange[ilZange].epSollZylinderStellung  := eZylinderGeschlossen;
        Zange[ilZange].bpStartZylinderBewegung := TRUE;
        steplCheck := STEP_410_E;
      END_IF

    // SYSTEM CHECK SCHEIBE AUF DAS SHUTTLE ZIEHEN ==============================
    STEP_410_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( Zange[ilZange].bpDone ) THEN
        Zange[ilZange].bpStartZylinderBewegung := FALSE;
        bpAnforderungSlaveKopplung := TRUE;
        steplCheck := STEP_420_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GESCHLOSSEN;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE AUF DAS SHUTTLE ZIEHEN ==============================
    STEP_420_E:
      (* Hinweis:
         - Warten bis der Glastransport auf die Greiferachse gekoppelt ist
         - Scheibe mit reduzierter Geschwindigkeit auf das Shuttle ziehen, hoechstens bis zur Position
           fuer uebergrosse Scheiben (Wegueberwachung)
      *)
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungKopplung );

      IF ( bpSlaveKopplungAktiv ) THEN
        IF ( blSensorSeite AND NOT blSensorGegenseite ) THEN
          M_Fahren( epBetriebsart     := ABSOLUT,
                    rpZielPosition    := rlPositionUebergrosseScheibe,
                    rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit );
          steplCheck := STEP_430_E;
        ELSE
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_GREIFER_STOESSEL_IST_ZUSTAND_NICHT_LOESBAR;
          steplCheck := STEP_900_E;
        END_IF
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_SLAVEANTRIEB_NICHT_BEREIT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE AUF DAS SHUTTLE ZIEHEN ==============================
    STEP_430_E:
      (* Hinweis:
         - Sensor der Greiferseite frei: Scheibe auf dem Shuttle, Greiferachse anhalten
         - Zielposition erreicht: Weg ausgeschoepft, die Scheibe kann noch am Sensor stehen
      *)
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( NOT toflSensorSeite.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
          steplCheck := STEP_440_E;
        END_IF

      ELSIF ( M_PositionErreicht() ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_440_E;

      END_IF

      (* Fehlerbehandlung:
         - Sensor der Gegenseite belegt
         - Zeitliche Ueberwachung
      *)
      IF ( blSensorGegenseite ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF ( epGreiferTypAktiv = eGreiferAuslaufseite ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        END_IF
        steplCheck := STEP_900_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE AUF DAS SHUTTLE ZIEHEN ==============================
    STEP_440_E:
      (* Hinweis:
         - Greiferzange oeffnen
      *)
      Zange[ilZange].epSollZylinderStellung  := elZangeOeffnung;
      Zange[ilZange].bpStartZylinderBewegung := TRUE;

      steplCheck := STEP_445_E;

    // SYSTEM CHECK SCHEIBE AUF DAS SHUTTLE ZIEHEN ==============================
    STEP_445_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( Zange[ilZange].bpDone ) THEN
        Zange[ilZange].bpStartZylinderBewegung := FALSE;
        bpAnforderungSlaveKopplung := FALSE;
        steplCheck := STEP_450_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GEOEFFNET;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE AUF DAS SHUTTLE ZIEHEN ==============================
    STEP_450_E:
      (* Hinweis:
         - Kopplung geloest: Greiferzange aus dem Glas fahren (in Zugrichtung), Verfahrbereich pruefen
      *)
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungKopplung );

      IF ( NOT bpSlaveKopplungAktiv ) THEN
        rlZielPosition := Antrieb.rpIstPosition + rlRichtung * ppParameterGreifer.rGreiferAusDemGlasFahrPosition;

        IF (     ( rlZielPosition < Antrieb.rpMaxPosition )
             AND ( rlZielPosition > Antrieb.rpMinPosition ) )
        THEN
          M_Fahren( epBetriebsart     := RELATIV,
                    rpZielPosition    := rlRichtung * ppParameterGreifer.rGreiferAusDemGlasFahrPosition,
                    rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit );
          steplCheck := STEP_460_E;
        ELSE
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_GREIFER_STOESSEL_IST_ZUSTAND_NICHT_LOESBAR;
          steplCheck := STEP_900_E;
        END_IF
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_SLAVEANTRIEB_NICHT_BEREIT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE AUF DAS SHUTTLE ZIEHEN ==============================
    STEP_460_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        GreiferHub.bpStartAusfahren := FALSE;
        GreiferHub.bpStartEinfahren := TRUE;

        steplCheck := STEP_470_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE AUF DAS SHUTTLE ZIEHEN ==============================
    STEP_470_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone ) THEN
        GreiferHub.bpStartEinfahren := FALSE;
        steplCheck := STEP_480_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_EINGEFAHREN;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE AUF DAS SHUTTLE ZIEHEN ==============================
    STEP_480_E:
      (* Hinweis:
         - Beide Sensoren frei: Scheibe vollstaendig auf dem Shuttle -> quittieren (nicht bei offener Zange)
         - Sensor noch belegt: keine Quittierung, der Systemcheck des Glastransports uebernimmt die Scheibe
         - Quittierung wird in STEP_800_E nach einem Zyklus zurueckgenommen
      *)
      IF ( NOT bpSensorEinlauf AND NOT bpSensorAuslauf ) THEN
        bprtScheibe := NOT blCheckNichtQuittieren;
      END_IF

      steplCheck := STEP_800_E;

    // SYSTEM CHECK SCHEIBE IN DEN FAECHERWAGEN SCHIEBEN ==============================
    STEP_500_E:
      (* Hinweis:
         - Greiferzange offen: Scheibe steht bereits im Faecherwagen -> ohne Quittierung in die Grundstellung
         - Greiferzange nicht offen: Scheibe gegriffen -> Zange schliessen
      *)
      IF (    ( Zange[ilZange].epStatusZylinderStellung = eZylinderStellung16mm )
           OR ( Zange[ilZange].epStatusZylinderStellung = eZylinderStellung23mm )
           OR ( Zange[ilZange].epStatusZylinderStellung = eZylinderStellung29mm ) )
      THEN
        blCheckNichtQuittieren     := TRUE;
        bpAnforderungSlaveKopplung := TRUE;
        steplCheck := STEP_550_E;
      ELSE
        Zange[ilZange].epSollZylinderStellung  := eZylinderGeschlossen;
        Zange[ilZange].bpStartZylinderBewegung := TRUE;
        steplCheck := STEP_510_E;
      END_IF

    // SYSTEM CHECK SCHEIBE IN DEN FAECHERWAGEN SCHIEBEN ==============================
    STEP_510_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( Zange[ilZange].bpDone ) THEN
        Zange[ilZange].bpStartZylinderBewegung := FALSE;
        bpAnforderungSlaveKopplung := TRUE;
        steplCheck := STEP_520_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GESCHLOSSEN;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE IN DEN FAECHERWAGEN SCHIEBEN ==============================
    STEP_520_E:
      (* Hinweis:
         - Warten bis der Glastransport auf die Greiferachse gekoppelt ist
         - Scheibe in den Faecherwagen schieben (Uebergabeposition)
      *)
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungKopplung );

      IF ( bpSlaveKopplungAktiv ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

        M_Fahren( epBetriebsart     := ABSOLUT,
                  rpZielPosition    := rlUebergabePosition,
                  rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit );

        steplCheck := STEP_530_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_SLAVEANTRIEB_NICHT_BEREIT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE IN DEN FAECHERWAGEN SCHIEBEN ==============================
    STEP_530_E:
      (* Hinweis:
         - Die erste Strecke bzw. lange Scheiben komplett mit reduzierter Geschwindigkeit,
           damit die Vorderkante sicher hinter die erste Strebe im Faecherwagen faehrt
         - Uebergabeposition erreicht: Scheibe quittieren
      *)
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF (    ( pAuftrag.rAuftragsLaenge >= ppParameterGreifer.rLaengeReduzierteGeschwindigkeit )
           OR ( ABS( Antrieb.rpIstPosition - rlPositionAntriebBeiStart ) < ppParameterGreifer.rLaengeReduzierteGeschwindigkeitAustransport ) )
      THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
      ELSE
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      END_IF

      IF ( M_PositionErreicht() ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bprtScheibe := TRUE;
        steplCheck := STEP_540_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE IN DEN FAECHERWAGEN SCHIEBEN ==============================
    STEP_540_E:
      (* Hinweis:
         - Scheibe quittiert, Greiferzange oeffnen
      *)
      bprtScheibe := FALSE;

      Zange[ilZange].epSollZylinderStellung  := elZangeOeffnung;
      Zange[ilZange].bpStartZylinderBewegung := TRUE;

      steplCheck := STEP_545_E;

    // SYSTEM CHECK SCHEIBE IN DEN FAECHERWAGEN SCHIEBEN ==============================
    STEP_545_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( Zange[ilZange].bpDone ) THEN
        Zange[ilZange].bpStartZylinderBewegung := FALSE;
        steplCheck := STEP_550_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GEOEFFNET;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK SCHEIBE IN DEN FAECHERWAGEN SCHIEBEN ==============================
    STEP_550_E:
      (* Hinweis:
         - Wie nach dem Austransport faehrt die Greiferachse mit gekoppeltem Glastransport in die
           Grundstellung; Kopplung abwarten, die Kopplung wird nach der Grundstellungsfahrt geloest
      *)
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungKopplung );

      IF ( bpSlaveKopplungAktiv ) THEN
        steplCheck := STEP_800_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_SLAVEANTRIEB_NICHT_BEREIT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK ==============================
    STEP_800_E:
      (* Hinweis:
         - Grundstellungsfahrt (faehrt den Greifer unterwegs ein)
      *)
      bprtScheibe := FALSE;

      bpStartGrundstellungsfahrt := TRUE;
      steplCheck := STEP_810_E;

    // SYSTEM CHECK ==============================
    STEP_810_E:
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( bpGrundstellungsfahrtAbgeschlossen ) THEN
        bpStartGrundstellungsfahrt := FALSE;
        bpAnforderungSlaveKopplung := FALSE;
        steplCheck := STEP_815_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        bpStartGrundstellungsfahrt := FALSE;
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ABLAUF_ZEITUEBERSCHREITUNG;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK ==============================
    STEP_815_E:
      (* Hinweis:
         - Kopplung zum Glastransport geloest, bevor der Glastransport seinen Systemcheck startet
      *)
      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungKopplung );

      IF ( NOT bpSlaveKopplungAktiv ) THEN
        steplCheck := STEP_820_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_SLAVEANTRIEB_NICHT_BEREIT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK ==============================
    STEP_820_E:
      (* Hinweis:
         - Glasrueckhalter einfahren (Federrueckstellung)
      *)
      ablRueckhalterAusfahren[cZANGE_EINLAUF] := FALSE;
      ablRueckhalterAusfahren[cZANGE_AUSLAUF] := FALSE;

      tonlUeberwachungCheck( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( bpGlasRueckhalterEingefahren ) THEN
        steplCheck := STEP_1000_E;
      END_IF

      IF ( tonlUeberwachungCheck.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GLASRUECKHALTER_NICHT_EINGEFAHREN;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK ==============================
    STEP_900_E:
      Antrieb.wpBetriebsart                  := KEINE_FUNKTION;
      GreiferHub.bpStartAusfahren            := FALSE;
      GreiferHub.bpStartEinfahren            := FALSE;
      Zange[ilZange].bpStartZylinderBewegung := FALSE;
      bpStartGrundstellungsfahrt             := FALSE;
      bpAnforderungSlaveKopplung             := FALSE;
      bprtScheibe                            := FALSE;
      bpFehler := TRUE;

    // SYSTEM CHECK ==============================
    STEP_1000_E:
      bpAnforderungSlaveKopplung := FALSE;
      bpSystemCheckAbgeschlossen := TRUE;

  // SYSTEM CHECK ==============================
  END_CASE

ELSE

  IF ( steplCheck > STEP_0_E ) THEN
    bpSystemCheckAbgeschlossen := FALSE;
    bpStartGrundstellungsfahrt := FALSE;
    bpAnforderungSlaveKopplung := FALSE;
    bprtScheibe                := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    GreiferHub.bpStartAusfahren                   := FALSE;
    GreiferHub.bpStartEinfahren                   := FALSE;
    Zange[cZANGE_EINLAUF].bpStartZylinderBewegung := FALSE;
    Zange[cZANGE_AUSLAUF].bpStartZylinderBewegung := FALSE;

    tonlUeberwachungCheck( IN := FALSE );

    steplCheck       := STEP_0_E;
    steplCheckMerker := STEP_0_E;
  END_IF

END_IF
END_ACTION