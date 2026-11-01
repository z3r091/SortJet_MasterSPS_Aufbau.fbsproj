(* METADATA
{
  "v3Meta": {
    "objectGuid": "3a48ce3d-a496-4a41-9121-773908032d1d"
  }
}
*)
ACTION HebeVorgang
//-------------------------------------------------------------------------------------------------
// AKTION: TRANSFERSHUTTLE HEBEN
//-------------------------------------------------------------------------------------------------
IF (  bpStarteHebeVorgang )
THEN
  CASE steplHebeVorgang OF
    // HEBE VORGANG ==============================
    STEP_0_E:
      (* Hinweis:
         - Timer zuruecksetzen
      *)
      tonlWartenAufAnheben(IN:=FALSE);
      tonlEinlaufsensorTesten(IN:= FALSE);
      tonlAuslaufsensorTesten(IN:= FALSE);
      bpDone := FALSE;


      IF ( Antrieb.bpReglerBereit )THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplHebeVorgang := STEP_10_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb [Glastransport]
      *)
      IF ( Antrieb.bpFehler )THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
        steplHebeVorgang := STEP_900_E;
      END_IF

    // HEBE VORGANG ==============================
    STEP_10_E:
      (* Hinweis:
         - Referenzieren [ Geber- Abnullen]
      *)
      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;

      steplHebeVorgang := STEP_20_E;

    // HEBE VORGANG ==============================
    STEP_20_E:
      (* Hinweis:
         - Geberposition wurde zurueck gesetzt
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplHebeVorgang := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb [Glastransport]
      *)
      IF ( Antrieb.bpFehler )THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
        steplHebeVorgang := STEP_900_E;
      END_IF

    // HEBE VORGANG ==============================
    STEP_100_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ABLAUF:  LUFTABFRAGEN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Anmerkung:
      //   - Transfershuttle heben
      //   - Einlauf- Auslauf- Sensoren heben
      //   Die Variable  << blGlastransportUndAbfragenGehoben >> wird gebildet durch:
      //   - tonlGlastransportOben.Q  | tonlKontrolleEinlaufOben.Q  | blDruckluftAuslaufSeiteOK
      //     tonlKontrolleAuslaufOben.Q | blDruckluftEinlaufSeiteOK
      out_bShuttleAnheben := TRUE;
      out_bScheibenKontrolleAuslaufseiteAuf := bpOptionSensorAuslauf;
      out_bScheibenKontrolleEinlaufseiteAuf := bpOptionSensorEinlauf;

      tonlWartenAufAnheben(IN:= NOT blBereitZumGlastransport ,PT:=t#10s);

      IF (  tonlGlastransportOben.Q
           AND ( tonlKontrolleEinlaufOben.Q OR NOT bpOptionSensorEinlauf )
           AND ( tonlKontrolleAuslaufOben.Q OR NOT bpOptionSensorAuslauf ) )
      THEN
        steplHebeVorgang := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Druckluft
         - Glastransport oben
         - Ein- Aus- Laufsensoren
      *)
      IF ( tonlWartenAufAnheben.Q ) THEN

        // Glastransport oben
        IF ( NOT blSensorGlastransportOben ) THEN
          wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_OBEN;
        // Luftsensoren oben
        ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteOben AND bpOptionSensorEinlauf ) THEN
          wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_OBEN;
        // Luftsensoren oben
        ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteOben AND bpOptionSensorAuslauf ) THEN
          wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_OBEN;
        ELSE
          wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
        END_IF

        steplHebeVorgang := STEP_900_E;
      END_IF

    // HEBE VORGANG ==============================
    STEP_900_E:
      bpFehler := TRUE;

    // HEBE VORGANG ==============================
    STEP_1000_E:
      bpDone := TRUE;

  // HEBE VORGANG ==============================
  END_CASE
ELSE
  IF ( steplHebeVorgang > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplHebeVorgang := STEP_0_E;
  END_IF
END_IF
END_ACTION