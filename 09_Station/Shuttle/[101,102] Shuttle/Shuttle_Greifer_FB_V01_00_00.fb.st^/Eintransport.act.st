(* METADATA
{
  "v3Meta": {
    "objectGuid": "a17ee781-6d01-4413-9103-a68db1909852"
  }
}
*)
ACTION Eintransport
//-------------------------------------------------------------------------------------------------
// AKTION: EINTRANSPORT [SCHEIBE AUS DEM FAECHERWAGEN AUF DAS SHUTTLE ZIEHEN]
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Greiferseite und Richtungen aus BAUSTEIN: GREIFERSEITE (rlRichtung, ilZange, blSensorSeite, ...)
   - Der Glastransport ist waehrend des Ziehens auf die Greiferachse gekoppelt
*)
IF (     bpStarteEintransport
     AND bpFreigabe
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
    steplEintransport := STEP_900_E;
  END_IF

  IF ( GreiferHub.bpFehler ) THEN
    wpFehlerNr := GreiferHub.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF

  // Ausnahmesituation: keine Greiferzange auf der aktiven Greiferseite
  IF ( NOT blZangeSeiteVorhanden ) THEN
    wpFehlerNr := cMELDUNG_AUFTRAGSDATEN_SHUTTLE_GREIFER_AUFTRAGSTYP_UNGUELTIG;
    steplEintransport := STEP_900_E;
  END_IF

  IF ( Zange[ilZange].bpFehler ) THEN
    wpFehlerNr := Zange[ilZange].wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF

  (* Hinweis:
     - Zeitueberwachung der Wartestellen: Timer bei jedem Schrittwechsel neu starten
  *)
  IF ( steplEintransport <> steplEintransportMerker ) THEN
    tonlUeberwachungEintransport( IN := FALSE );
    steplEintransportMerker := steplEintransport;
  END_IF

  CASE steplEintransport OF
    // EINTRANSPORT ==============================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
         - Warten bis die Greiferachse bereit und referenziert ist
         - Kopplung des Glastransports auf die Greiferachse anfordern
      *)
      bprtScheibe                   := FALSE;
      bpEintransportAbgeschlossen   := FALSE;
      bpVorpositioniertEintransport := FALSE;
      bpKorrekturfahrtAnfordern     := FALSE;
      blReduzierteGeschwindigkeit   := FALSE;

      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( tonlAntriebFreigegeben.Q AND Antrieb.bpIstReferenziert ) THEN
        Antrieb.wpBetriebsart      := KEINE_FUNKTION;
        bpAnforderungSlaveKopplung := TRUE;
        steplEintransport := STEP_10_E;
      END_IF

      (* Fehlerbehandlung:
         - Greiferachse nicht bereit
      *)
      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ANTRIEB_NICHT_BEREIT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_10_E:
      (* Hinweis:
         - Glasrueckhalter der Greiferseite ausfahren
         - Greifer ausfahren und Greiferzange auf die Auftragsoeffnung stellen
      *)
      ablRueckhalterAusfahren[ilZange] := TRUE;

      GreiferHub.bpStartEinfahren := FALSE;
      GreiferHub.bpStartAusfahren := TRUE;

      Zange[ilZange].epSollZylinderStellung  := elZangeOeffnung;
      Zange[ilZange].bpStartZylinderBewegung := TRUE;

      steplEintransport := STEP_100_E;

    // EINTRANSPORT ==============================
    STEP_100_E:
      (* Hinweis:
         - Greifer ausgefahren, Greiferzange offen und Glastransport gekoppelt
           => Greiferachse zur Uebernahmeposition im Faecherwagen fahren
      *)
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungKopplung );

      IF (     GreiferHub.bpDone
           AND Zange[ilZange].bpDone
           AND bpSlaveKopplungAktiv )
      THEN
        GreiferHub.bpStartAusfahren            := FALSE;
        Zange[ilZange].bpStartZylinderBewegung := FALSE;

        M_Fahren( epBetriebsart     := ABSOLUT,
                  rpZielPosition    := rlUebernahmePosition,
                  rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit );

        steplEintransport := STEP_120_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitueberwachung Greifer / Greiferzange / Kopplung
      *)
      IF ( tonlUeberwachungEintransport.Q ) THEN
        IF ( NOT GreiferHub.bpDone ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_AUSGEFAHREN;
        ELSIF ( NOT Zange[ilZange].bpDone ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GEOEFFNET;
        ELSE
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_SLAVEANTRIEB_NICHT_BEREIT;
        END_IF
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_120_E:
      (* Hinweis:
         - Uebernahmeposition erreicht
      *)
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( M_PositionErreicht() ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_130_E;
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_130_E:
      (* Hinweis:
         - Greiferzange schliessen (Scheibe greifen)
      *)
      Zange[ilZange].epSollZylinderStellung  := eZylinderGeschlossen;
      Zange[ilZange].bpStartZylinderBewegung := TRUE;

      steplEintransport := STEP_135_E;

    // EINTRANSPORT ==============================
    STEP_135_E:
      (* Hinweis:
         - Glas zwischen den Backen: die Greiferzange meldet nach der Bewegungszeit geschlossen
      *)
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( Zange[ilZange].bpDone ) THEN
        Zange[ilZange].bpStartZylinderBewegung := FALSE;
        steplEintransport := STEP_140_E;
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GESCHLOSSEN;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_140_E:
      (* Hinweis:
         - Scheibe auf das Shuttle ziehen
           => Normale Scheibe: Weg bis zum Sensor der Greiferseite + Auftragslaenge + Offset
           => Uebergrosse Scheibe: nur bis rPositionUebergrosseScheibe, den Rest zieht der Glastransport
         - Zielposition gegen den Verfahrbereich pruefen
      *)
      rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

      IF ( blUebergrosseScheibe ) THEN
        rlZielPosition := rlPositionUebergrosseScheibe;
      ELSE
        rlZielPosition := rlWegBisZumSensor + rlRichtung * ( pAuftrag.rAuftragsLaenge + rlEintransportOffset );
      END_IF

      IF (     ( rlZielPosition < ppParameterGreifer.rMaximalPosition )
           AND ( rlZielPosition > ppParameterGreifer.rMinimalPosition ) )
      THEN

        (* Hinweis:
           - Schwere Scheiben mit reduzierter Geschwindigkeit ziehen, damit das Glas nicht aus der Zange rutscht
        *)
        rlGlasgewicht := GlasGewichtErmitteln( rpGlaslaenge  := pAuftrag.rAuftragsLaenge,
                                               rpGlasbreite  := pAuftrag.rAuftragsHoehe,
                                               rpGlasstaerke := SEL( pAuftrag.rAuftragsDicke > wgUnterteilerMinMaxGlasdicke, GLASSTAERKE_DEFAULT_MIN, GLASSTAERKE_DEFAULT_MAX ) );

        blReduzierteGeschwindigkeit := ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht );

        IF ( blReduzierteGeschwindigkeit ) THEN
          M_Fahren( epBetriebsart     := ABSOLUT,
                    rpZielPosition    := rlZielPosition,
                    rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit );
          Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        ELSE
          M_Fahren( epBetriebsart     := ABSOLUT,
                    rpZielPosition    := rlZielPosition,
                    rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit );
        END_IF

        steplEintransport := STEP_150_E;

      ELSE
        awpFehlerInformationen[0] := stStationsNummern.NummerExtern;
        awpFehlerInformationen[1] := REAL_TO_WORD( rlZielPosition );
        awpFehlerInformationen[2] := REAL_TO_WORD( ppParameterGreifer.rMinimalPosition );
        awpFehlerInformationen[3] := REAL_TO_WORD( ppParameterGreifer.rMaximalPosition );
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_VERFAHRBEREICH;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_150_E:
      (* Hinweis:
         - Nach rWegSensorUeberwachungEintransport muss die Scheibe den Sensor der Greiferseite belegen,
           sonst hat der Greifer keine Scheibe
      *)
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( ABS( Antrieb.rpIstPosition - rlPositionAntriebBeiStart ) > ppParameterGreifer.rWegSensorUeberwachungEintransport ) THEN
        IF ( blSensorSeite ) THEN
          steplEintransport := STEP_160_E;
        ELSE
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_KEINE_GLAS_EINTRANSPORT;
          steplEintransport := STEP_900_E;
        END_IF
      END_IF

      (* Fehlerbehandlung:
         - Sensor der Gegenseite belegt
         - Zeitueberwachung
      *)
      IF ( blSensorGegenseite ) THEN
        IF ( epGreiferTypAktiv = eGreiferAuslaufseite ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        END_IF
        steplEintransport := STEP_900_E;
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_160_E:
      (* Hinweis:
         - Liegt die Scheibe zum Teil auf dem Shuttle, wieder mit voller Geschwindigkeit ziehen
         - Zielposition erreicht
      *)
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF (     blReduzierteGeschwindigkeit
           AND ( ABS( Antrieb.rpIstPosition - rlPositionAntriebBeiStart ) > ppParameterGreifer.rLaengeReduzierteGeschwindigkeitEintransport ) )
      THEN
        blReduzierteGeschwindigkeit := FALSE;
        Antrieb.rpGeschwindigkeit   := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      END_IF

      IF ( M_PositionErreicht() ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_170_E;
      END_IF

      (* Fehlerbehandlung:
         - Sensor der Gegenseite belegt
         - Zeitueberwachung
      *)
      IF ( blSensorGegenseite ) THEN
        IF ( epGreiferTypAktiv = eGreiferAuslaufseite ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        END_IF
        steplEintransport := STEP_900_E;
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_170_E:
      (* Hinweis:
         - Sensor der Greiferseite pruefen
           => Uebergrosse Scheibe: der Sensor bleibt belegt, Rest zieht der Glastransport
           => Sensor frei: Scheibe quittieren
           => Sensor belegt: Korrekturfahrt der Greiferachse
      *)
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        IF ( blUebergrosseScheibe ) THEN
          steplEintransport := STEP_190_E;
        ELSIF ( NOT toflSensorSeite.Q ) THEN
          bprtScheibe := TRUE;
          steplEintransport := STEP_190_E;
        ELSE
          rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
          steplEintransport := STEP_180_E;
        END_IF
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_180_E:
      // ---------------------------------------------------------------------------------------
      //  KORREKTURFAHRT [SENSOR DER GREIFERSEITE BELEGT]
      //
      //  Hinweis:
      //  - Scheibe langsam weiter auf das Shuttle ziehen, bis der Sensor frei ist
      // ---------------------------------------------------------------------------------------
      IF ( toflSensorSeite.Q ) THEN
        IF ( rlRichtung > 0.0 ) THEN
          M_Fahren( epBetriebsart := HANDPLUS, rpZielPosition := 0.0, rpGeschwindigkeit := rgGeschwindigkeitVerySlow );
        ELSE
          M_Fahren( epBetriebsart := HANDMINUS, rpZielPosition := 0.0, rpGeschwindigkeit := rgGeschwindigkeitVerySlow );
        END_IF
      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
          bprtScheibe := TRUE;
          steplEintransport := STEP_190_E;
        END_IF
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Endschalter in Zugrichtung
         - Sensor der Gegenseite
      *)
      IF ( ABS( Antrieb.rpIstPosition - rlPositionAntriebBeiStart ) >= ppParameterGreifer.rMaximalerWegSensorFreiFahren ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_SENSOR_WIRD_NICHT_FREI;
        steplEintransport := STEP_900_E;
      END_IF

      IF (    ( ( rlRichtung > 0.0 ) AND Antrieb.bpMaxSchalterBelegt )
           OR ( ( rlRichtung < 0.0 ) AND Antrieb.bpMinSchalterBelegt ) )
      THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ENDSCHALTER_NICHT_FREI;
        steplEintransport := STEP_900_E;
      END_IF

      IF ( blSensorGegenseite ) THEN
        IF ( epGreiferTypAktiv = eGreiferAuslaufseite ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        END_IF
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_190_E:
      (* Hinweis:
         - Greiferzange oeffnen
      *)
      bprtScheibe := FALSE;

      Zange[ilZange].epSollZylinderStellung  := elZangeOeffnung;
      Zange[ilZange].bpStartZylinderBewegung := TRUE;

      steplEintransport := STEP_195_E;

    // EINTRANSPORT ==============================
    STEP_195_E:
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( Zange[ilZange].bpDone ) THEN
        Zange[ilZange].bpStartZylinderBewegung := FALSE;
        steplEintransport := STEP_200_E;
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GEOEFFNET;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_200_E:
      (* Hinweis:
         - Kopplung zum Glastransport loesen, damit der Greifer aus dem Glas fahren kann
      *)
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungKopplung );

      bpAnforderungSlaveKopplung := FALSE;

      IF ( NOT bpSlaveKopplungAktiv ) THEN
        steplEintransport := STEP_210_E;
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_SLAVEANTRIEB_NICHT_BEREIT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_210_E:
      (* Hinweis:
         - Greiferzange aus dem Glas fahren (in Zugrichtung)
      *)
      M_Fahren( epBetriebsart     := RELATIV,
                rpZielPosition    := rlRichtung * ppParameterGreifer.rGreiferAusDemGlasFahrPosition,
                rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit );

      steplEintransport := STEP_220_E;

    // EINTRANSPORT ==============================
    STEP_220_E:
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_230_E;
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_230_E:
      (* Hinweis:
         - Greifer einfahren
      *)
      GreiferHub.bpStartAusfahren := FALSE;
      GreiferHub.bpStartEinfahren := TRUE;

      steplEintransport := STEP_235_E;

    // EINTRANSPORT ==============================
    STEP_235_E:
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone ) THEN
        GreiferHub.bpStartEinfahren := FALSE;
        IF ( blUebergrosseScheibe ) THEN
          steplEintransport := STEP_240_E;
        ELSE
          steplEintransport := STEP_270_E;
        END_IF
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_EINGEFAHREN;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_240_E:
      // ---------------------------------------------------------------------------------------
      //  UEBERGROSSE SCHEIBE: KORREKTURFAHRT DES GLASTRANSPORTS
      //
      //  Hinweis:
      //  - Steht der Greifer in Zugrichtung hinter der Grundstellung der Gegenseite, zuerst dorthin
      //    zurueckfahren, damit er die Sensoren der Gegenseite nicht belegt
      // ---------------------------------------------------------------------------------------
      bpKorrekturfahrtAnfordern := TRUE;

      IF ( rlRichtung * ( Antrieb.rpIstPosition - rlGrundstellungGegenseite ) < 0.0 ) THEN
        steplEintransport := STEP_260_E;
      ELSE
        M_Fahren( epBetriebsart     := ABSOLUT,
                  rpZielPosition    := rlGrundstellungGegenseite,
                  rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit );
        steplEintransport := STEP_250_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_250_E:
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( M_PositionErreicht() ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_260_E;
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_260_E:
      (* Hinweis:
         - Der Glastransport hat die Scheibe komplett auf das Shuttle gezogen
      *)
      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( bpKorrekturfahrtBeendet ) THEN
        bpKorrekturfahrtAnfordern := FALSE;
        bprtScheibe := TRUE;
        steplEintransport := STEP_270_E;
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ABLAUF_ZEITUEBERSCHREITUNG;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_270_E:
      (* Hinweis:
         - Glasrueckhalter einfahren (Federrueckstellung)
      *)
      bprtScheibe := FALSE;

      ablRueckhalterAusfahren[ilZange] := FALSE;

      tonlUeberwachungEintransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( bpGlasRueckhalterEingefahren ) THEN
        steplEintransport := STEP_1000_E;
      END_IF

      IF ( tonlUeberwachungEintransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GLASRUECKHALTER_NICHT_EINGEFAHREN;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_900_E:
      (* Fehlerbehandlung:
         - Fahrbefehle und Pneumatik-Starts beenden
      *)
      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      GreiferHub.bpStartAusfahren            := FALSE;
      GreiferHub.bpStartEinfahren            := FALSE;
      Zange[ilZange].bpStartZylinderBewegung := FALSE;

      bprtScheibe                := FALSE;
      bpAnforderungSlaveKopplung := FALSE;
      bpKorrekturfahrtAnfordern  := FALSE;
      bpFehler                   := TRUE;

    // EINTRANSPORT ==============================
    STEP_1000_E:
      bpAnforderungSlaveKopplung  := FALSE;
      bpEintransportAbgeschlossen := TRUE;

  // EINTRANSPORT ==============================
  END_CASE

ELSE

  IF ( steplEintransport > STEP_0_E ) THEN

    bprtScheibe                 := FALSE;
    bpEintransportAbgeschlossen := FALSE;
    bpAnforderungSlaveKopplung  := FALSE;
    bpKorrekturfahrtAnfordern   := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    GreiferHub.bpStartAusfahren                   := FALSE;
    GreiferHub.bpStartEinfahren                   := FALSE;
    Zange[cZANGE_EINLAUF].bpStartZylinderBewegung := FALSE;
    Zange[cZANGE_AUSLAUF].bpStartZylinderBewegung := FALSE;

    ablRueckhalterAusfahren[cZANGE_EINLAUF] := FALSE;
    ablRueckhalterAusfahren[cZANGE_AUSLAUF] := FALSE;

    tonlUeberwachungEintransport( IN := FALSE );

    steplEintransport       := STEP_0_E;
    steplEintransportMerker := STEP_0_E;

  END_IF

END_IF
END_ACTION