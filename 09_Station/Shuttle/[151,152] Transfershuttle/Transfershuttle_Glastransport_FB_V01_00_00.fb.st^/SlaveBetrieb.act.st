(* METADATA
{
	"v3Meta": {
		"objectGuid": "481cd5e1-14f2-42df-8279-da4cfd4d1111"
	}
}
*)
ACTION SlaveBetrieb
// @TEXT_IMPLEMENTATION := 'ST'
//-------------------------------------------------------------------------------------------------
// AKTION: SLAVE-BETRIEB
//-------------------------------------------------------------------------------------------------
IF (  bpSlaveKopplung
     AND NOT bpReset
     AND NOT bpFahreReferenz )
THEN

  // Fehlerauswertung:
  //   - Antrieb
  //   - Sicherstellen das der Slavekopplung aktiv ist
  IF ( Antrieb.bpFehler ) THEN
    bpSlaveAktiv := FALSE;
    blSchnittstelle_bBereitZumTransportVerbund := FALSE;
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplSlave := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplSlave OF
    // SLAVE BETRIEB ==================================
    STEP_0_E:
      (* Hinweis:
         - Variablen initialisieren
      *)
      tonlWartenAufSenken(IN:=FALSE);
      bpSlaveAktiv := FALSE;
      blSchnittstelle_bBereitZumTransportVerbund := FALSE;
      tonlWartenAufAnheben(IN := FALSE );
      tonlUberwachungSlaveAktiv( IN := FALSE);

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplSlave := STEP_5_E;
      END_IF

    // SLAVE BETRIEB ==============================
    STEP_5_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
      steplSlave := STEP_6_E;

    // SLAVE BETRIEB ==============================
    STEP_6_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplSlave := STEP_10_E;
      END_IF

    // SLAVE BETRIEB ==================================
    STEP_10_E:
      (* Hinweis:
         - Antrieb in Slavemode schalten
      *)
      IF ( stpInTransportVerbund.bAnforderungTransportVerbund
           OR bpAnforderungTransportkopplung )
      THEN
        Antrieb.wpMaster  := stMasterSlaveConfig.wSlaveNrVorgaengerWand1;
        Antrieb.wpBetriebsart         := SYNC_AUF_MASTER;

        steplSlave := STEP_100_E;

      END_IF

    // SLAVE BETRIEB ==================================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  DEFAULT LUFTABFRAGEN HEBEN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      out_bShuttleAnheben                   := TRUE;
      out_bScheibenKontrolleAuslaufSeiteAuf := TRUE;
      out_bScheibenKontrolleEinlaufSeiteAuf := TRUE;

      IF (  tonlGlastransportOben.Q
           AND tonlKontrolleEinlaufOben.Q
           AND tonlKontrolleAuslaufOben.Q  )
      THEN

        IF ( Antrieb.bpDone ) THEN
          bpSlaveAktiv := TRUE;
          blSchnittstelle_bBereitZumTransportVerbund := TRUE;
          steplSlave := STEP_300_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
         - Zeitliche Ueberwachung
      *)
      tonlWartenAufAnheben( IN := TRUE,
                            PT := T#10s );


      IF ( tonlWartenAufAnheben.Q ) THEN

        // Glastransport oben
        IF ( NOT blSensorGlastransportOben ) THEN
          wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_OBEN;
        // Luftsensoren oben
        ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteOben ) THEN
          wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_OBEN;
        ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteOben ) THEN
          wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_OBEN;
        // Druckluft Ok
        ELSIF ( NOT blDruckluftAuslaufSeiteOK ) THEN
          wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_AUSLAUF_NICHT_OK;
        ELSE
          wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
        END_IF

        steplSlave := STEP_900_E;
      END_IF

    // SLAVE BETRIEB ==================================
    STEP_300_E:
      // ---------------------------------------------------------------------------------------
      // ABSCHLUSS DER KOPPLUNG
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------
      IF ( NOT stpInTransportVerbund.bAnforderungTransportVerbund ) THEN
        blSchnittstelle_bBereitZumTransportVerbund := FALSE;
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        steplSlave := STEP_310_E;
      END_IF

      (* Anmerkung:
         - Überwachung ob die Achsen synchron laufen
      *)
      tonlUberwachungSlaveAktiv( IN := NOT Antrieb.bpAchseSychron,
                                 PT := cZEIT_UEBERWACHUNG_SLAVE_AKTIV );


      IF ( tonlUberwachungSlaveAktiv.Q ) THEN
        bpSlaveAktiv := FALSE;
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_SLAVE_NICHT_AKTIV;
        steplSlave := STEP_900_E;
      END_IF

    // SLAVE BETRIEB ==================================
    STEP_310_E:
      // ---------------------------------------------------------------------------------------
      //  LUFTABFRAGEN SENKEN \ TRANSFERSHUTTLE SENKEN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      bpSlaveAktiv := FALSE;

      out_bShuttleAnheben := FALSE;

      out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
      blScheibenKontrolleAuslaufseiteEin    := FALSE;
      out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
      blScheibenKontrolleEinlaufseiteEin    := FALSE;

      tonlWartenAufSenken( IN:= NOT bpBereitZumVerfahren , PT:=T#10S);

      IF ( bpBereitZumVerfahren ) THEN
        steplSlave := STEP_1000_E;
      END_IF


      (* Fehlerbehandlung:
         - Glastransport unten
         - Ein- Aus- Laufsensoren
      *)
      IF ( tonlWartenAufSenken.Q ) THEN
        // Glastransport unten
        IF ( NOT blSensorGlastransportUnten ) THEN
          wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_UNTEN;
        // Luftsensoren unten
        ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteUnten ) THEN
          wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_UNTEN;
        // Luftsensoren unten
        ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteUnten ) THEN
          wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_UNTEN;
        ELSE
          wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
        END_IF

        steplSlave := STEP_900_E;

      END_IF

    // SLAVE BETRIEB ==================================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      blSchnittstelle_bBereitZumTransportVerbund := FALSE;
      Antrieb.wpBetriebsart:= KEINE_FUNKTION;
      bpFehler := TRUE;

    // SLAVE BETRIEB ==================================
    STEP_1000_E:
      ;

  // SLAVE BETRIEB ==================================
  END_CASE
ELSE

  IF (steplSlave > STEP_0_E) THEN
    tonlUberwachungSlaveAktiv( IN := FALSE );
    bpSlaveAktiv        := FALSE;
    out_bShuttleAnheben := FALSE;
    blSchnittstelle_bBereitZumTransportVerbund := FALSE;
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;
    steplSlave := STEP_0_E;
  END_IF

END_IF
END_ACTION