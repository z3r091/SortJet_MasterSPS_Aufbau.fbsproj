(* METADATA
{
  "v3Meta": {
    "objectGuid": "022b70db-7bed-4ac9-bb06-78f98fbfa2ed"
  }
}
*)
ACTION Laengenmessung
(***************************************************************************************************)
(* AKTION LÄNGENVERMESSUNG  *)
(***************************************************************************************************)
IF ( bpGlaslaengenmessung
  AND bpAutomatikAktiv)
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_Glastransport;
    steplGlaslaengenMessung := STEP_900_E;
  END_IF

  CASE steplGlaslaengenMessung OF
(* GLASLAENGENMESSUNG =============================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen initialisieren
         - Pruefen ob der Antrieb bereit zum verfahren ist
      *)
      rpGemesseneGlaslaenge     := 0.0;

      bpScheibeQuittiert        := FALSE;
      bpScheibeFreigegeben      := FALSE;
      bpAnforderungMessergebnis := FALSE;


      Antrieb.rpGeschwindigkeit := 0.0;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.wpBetriebsart     := KEINE_FUNKTION;

      steplGlaslaengenMessung := STEP_10_E;

(* GLASLAENGENMESSUNG =============================*)
    STEP_10_E:
      (* Hinweis:
         - Referenz
      *)
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
      IF ( Antrieb.bpDone ) THEN
         Antrieb.wpBetriebsart := KEINE_FUNKTION;
         steplGlaslaengenMessung := STEP_30_E;
      END_IF


(* GLASLAENGENMESSUNG =============================*)
    STEP_30_E:
      (* Hinweis:
         - Scheibenmessung starten
      *)
      rpGemesseneGlaslaenge := 0.0;

      Scheibenmessung.rpErwarteteScheibenLaenge := pAuftrag.rAuftragsLaenge;
      Scheibenmessung.bpGlasvermessung          := TRUE;

      IF ( Scheibenmessung.bpGlasmessungAbgeschlossen ) THEN
        Scheibenmessung.bpGlasvermessung := FALSE;
        rpGemesseneGlaslaenge := Scheibenmessung.rpGemesseneGlaslaenge;

        steplGlaslaengenMessung := STEP_40_E;
      END_IF

      // Fehlerbehandlung
      IF ( Scheibenmessung.bpFehler ) THEN
        Scheibenmessung.bpGlasvermessung := FALSE;
        wpFehlerNr := Scheibenmessung.wpFehlerNr;
        steplGlaslaengenMessung := STEP_900_E;
      END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_40_E:
      (* Hinweis:
         - Sobald der Antrieb nicht mehr laeuft Vorstop- Sensor pruefen
           => BELEGT : Eintransport / Laengenmessung erfolgreich
           => FREI   : Pruefen was mit dem Glas ist
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( bpSensorAuslaufVorab ) THEN
          bpAnforderungMessergebnis := TRUE;
          steplGlaslaengenMessung := STEP_200_E;

        ELSE
          wpFehlerNr := cMELDUNG_SENSOR_AUSLAUFVORAB_SCHALTET_NICHT;
          steplGlaslaengenMessung := STEP_900_E;

        END_IF

      END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_100_E:
      (* Hinweis:
         - Auslaufsensor freifahren
      *)
      IF (  NOT Antrieb.bpAntrieblaeuft
        AND NOT toflAuslaufsensor.Q )
      THEN
        bpScheibeFaehrtUeberAuslauf := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplGlaslaengenMessung := STEP_40_E;
      END_IF

      IF ( toflAuslaufsensor.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      // Fehlerbehandlung
      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_BELEGT;
        steplGlaslaengenMessung := STEP_900_E;
      END_IF

      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ( ppParameterBaustein.rLaengeStation )) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_NICHT_FREI;
        steplGlaslaengenMessung := STEP_900_E;
      END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_200_E:
      (* Hinweis:
         - Auf Messergebis warten
      *)
      IF ( bpScheibeQuittiert
        OR bpScheibeFreigegeben )
      THEN
        bpAnforderungMessergebnis := FALSE;
        steplGlaslaengenMessung := STEP_800_E;
      END_IF

      IF ( bpScheibeZurueckFahren ) THEN
        bpAnforderungMessergebnis := FALSE;
        steplGlaslaengenMessung := STEP_210_E;
      END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_210_E:
      (* ---------------------------------------------------------------------------------------
      //  KNEBEL SCHEIBE ZURUECK FAHREN
      //         
      //  Hinweis:
      //  - Scheibe wird zurueck Richtung Bediener gefahren. Die Schabe muss nach dem zurueck 
      //    fahren neu angelegt werden
      // ---------------------------------------------------------------------------------------*)

      IF ( bpScheibeZurueckFahren ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit20;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      IF ( bpScheibeQuittiert
        AND NOT bpSensorAuslaufVorab )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplGlaslaengenMessung := STEP_800_E;
      END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_800_E:
       IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
         Antrieb.wpBetriebsart := KEINE_FUNKTION;
         steplGlaslaengenMessung := STEP_1000_E;
       END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_900_E:
      bpFehler := TRUE;

(* GLASLAENGENMESSUNG =============================*)
    STEP_1000_E:
      bpDone := TRUE;

(* GLASLAENGENMESSUNG =============================*)
  END_CASE
ELSE

  IF (steplGlaslaengenMessung > STEP_0_E) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    Scheibenmessung.bpGlasvermessung := FALSE;
    steplGlaslaengenMessung := STEP_0_E;
  END_IF

END_IF
END_ACTION