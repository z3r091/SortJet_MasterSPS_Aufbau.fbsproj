(* METADATA
{
  "v3Meta": {
    "objectGuid": "2a669734-5300-48d4-88ee-f5d086977bb5"
  }
}
*)
ACTION Vortransport_Rueck
(***************************************************************************************************)
(* AKTION: VORTRANSPORT RÜCKWÄRTIG *)
(***************************************************************************************************)
IF ( bpVortransportRueckwaertig
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplVortransportRueckwaertig := STEP_900_E;
  END_IF
  
  IF ( Antrieb_Slave.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplVortransportRueckwaertig := STEP_900_E;
  END_IF


  CASE steplVortransportRueckwaertig OF
    (*VORTRANSPORT RÜCKWÄRTIG ==============================*)
    STEP_0_E:
      (* Hinweis:
         - 
      *)
      bpAbbruchVortransport := FALSE;
      bpDone := FALSE;

      rlGlasgewicht := ( GlasGewichtErmitteln( rpGlaslaenge  := pAuftrag.rAuftragsLaenge,
                                               rpGlasbreite  := pAuftrag.rAuftragsHoehe,
                                               rpGlasstaerke := pAuftrag.rAuftragsDicke ) );

      blReduzierteGeschwindigkeit := ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht );

      steplVortransportRueckwaertig := STEP_5_E;

    (*VORTRANSPORT RÜCKWÄRTIG ==============================*)
    STEP_5_E:

      IF (  NOT bpSensorEinlaufVorAb
           AND pAuftrag.rModellVersatzHinten = 0.0 )
      THEN

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit20;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDMINUS;

        steplVortransportRueckwaertig := STEP_10_E;

      ELSE
        steplVortransportRueckwaertig := STEP_1000_E;

      END_IF

      (* Fehlerbehandlung:
         - Sensorik
      *)
      IF ( bpSensorEinlauf ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplVortransportRueckwaertig := STEP_900_E;
      END_IF

    (*VORTRANSPORT RÜCKWÄRTIG ==============================*)
    STEP_10_E:
      (* Hinweis:
         - Glas auf den VorStop- Sensor vorpositionieren
      *)
      IF ( bpSensorEinlaufVorAb OR bpAbbruchVortransport ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransportRueckwaertig := STEP_20_E;
      END_IF

      (* Fehlerbehandlung:
         - Sensorik
      *)
      IF ( bpSensorEinlauf ) THEN
        bpScheibeFaehrtUeberEinlauf := TRUE;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplVortransportRueckwaertig := STEP_900_E;
      END_IF

    (*VORTRANSPORT RÜCKWÄRTIG ==============================*)
    STEP_20_E:
      (* Hinweis:
         - Pruefen ob das Glas zuweit gefahren wurde und den Auslaufsensor nun belegt ist.
           ggf. das Glas wider zurueck fahren
      *)
      IF (  NOT Antrieb.bpAntrieblaeuft ) THEN

        IF( bpSensorEinlauf ) THEN
          steplVortransportRueckwaertig := STEP_30_E;
        ELSE
          steplVortransportRueckwaertig := STEP_1000_E;
        END_IF

      END_IF

    (*VORTRANSPORT RÜCKWÄRTIG ==============================*)
    STEP_30_E:
      (* Anmerkung:
         - Versuch den Auslaufsensor frei zufahren
      *)
      IF ( NOT toflEinlaufsensor.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransportRueckwaertig := STEP_1000_E;

      ELSE
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDPLUS;
      END_IF

      (* Fehlerbehandlung
         - Sensorik
      *)
      IF ( bpSensorAuslauf ) THEN
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplVortransportRueckwaertig := STEP_900_E;
      END_IF

    (*VORTRANSPORT RÜCKWÄRTIG ==============================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
      bpFehler := TRUE;

    (*VORTRANSPORT RÜCKWÄRTIG ==============================*)
    STEP_1000_E:
      bpAbbruchVortransport := FALSE;
      bpDone := TRUE;

  (*VORTRANSPORT RÜCKWÄRTIG ==============================*)
  END_CASE
ELSE
  IF (steplVortransportRueckwaertig > 0) THEN
    bpAbbruchVortransport := FALSE;
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
    steplVortransportRueckwaertig := STEP_0_E;
  END_IF
END_IF
END_ACTION