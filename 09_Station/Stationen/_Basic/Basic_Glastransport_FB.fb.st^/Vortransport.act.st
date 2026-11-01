(* METADATA
{
  "v3Meta": {
    "objectGuid": "477d508e-2a87-45e6-94ab-8b02165263c1"
  }
}
*)
ACTION Vortransport
(***************************************************************************************************)
(* AKTION: VORTRANSPORT *)
(***************************************************************************************************)
IF ( bpVortransport
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplVortransport := STEP_900_E;
  END_IF
  
  IF ( Antrieb_Slave.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplVortransport := STEP_900_E;
  END_IF


  CASE steplVortransport OF
    (*VORTRANSPORT ==============================*)
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

      steplVortransport := STEP_5_E;

    (*VORTRANSPORT ==============================*)
    STEP_5_E:

      IF (  NOT bpSensorAuslaufVorAb
           AND pAuftrag.rModellVersatzVorne = 0.0 )
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

        Antrieb.wpBetriebsart     := HANDPLUS;

        steplVortransport := STEP_10_E;

      ELSE
        steplVortransport := STEP_1000_E;

      END_IF

      (* Fehlerbehandlung:
         - Sensorik
      *)
      IF ( bpSensorAuslauf ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplVortransport := STEP_900_E;
      END_IF

    (*VORTRANSPORT ==============================*)
    STEP_10_E:
      (* Hinweis:
         - Glas auf den VorStop- Sensor vorpositionieren
      *)
      IF ( bpSensorAuslaufVorAb OR bpAbbruchVortransport ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransport := STEP_20_E;
      END_IF

      (* Fehlerbehandlung:
         - Sensorik
      *)
      IF ( bpSensorAuslauf ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplVortransport := STEP_900_E;
      END_IF

    (*VORTRANSPORT ==============================*)
    STEP_20_E:
      (* Hinweis:
         - Pruefen ob das Glas zuweit gefahren wurde und den Auslaufsensor nun belegt ist.
           ggf. das Glas wider zurueck fahren
      *)
      IF (  NOT Antrieb.bpAntrieblaeuft ) THEN

        IF( bpSensorAuslauf ) THEN
          steplVortransport := STEP_30_E;
        ELSE
          steplVortransport := STEP_1000_E;
        END_IF

      END_IF

    (*VORTRANSPORT ==============================*)
    STEP_30_E:
      (* Anmerkung:
         - Versuch den Auslaufsensor frei zufahren
      *)
      IF ( NOT toflAuslaufsensor.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransport := STEP_1000_E;

      ELSE
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDMINUS;
      END_IF

      (* Fehlerbehandlung
         - Sensorik
      *)
      IF ( bpSensorEinlauf ) THEN
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplVortransport := STEP_900_E;
      END_IF

    (*VORTRANSPORT ==============================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
      bpFehler := TRUE;

    (*VORTRANSPORT ==============================*)
    STEP_1000_E:
      bpAbbruchVortransport := FALSE;
      bpDone := TRUE;

  (*VORTRANSPORT ==============================*)
  END_CASE
ELSE
  IF (steplVortransport > 0) THEN
    bpAbbruchVortransport := FALSE;
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
    steplVortransport := STEP_0_E;
  END_IF
END_IF
END_ACTION