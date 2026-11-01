(* METADATA
{
  "v3Meta": {
    "objectGuid": "172e920b-29d9-426f-accd-100b114f0ac1"
  }
}
*)
ACTION AutarkePositionierung
//-------------------------------------------------------------------------------------------------
// AUTARKE POSITIONIERUNG
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Positionierung ohne direkte Zielvorgabe
*)
IF ( bpStarteDrehBewegung ) THEN


  (* Ausnahmefehler:
     - Sensorik
  *)
  IF ( bpAuslaufSensor AND NOT bpEinlaufSensor ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_DREHEN_SENSOR_AUSLAUF_BELEGT;
    steplDrehBewegung := STEP_900_E;

  ELSIF ( bpEinlaufSensor AND NOT bpAuslaufSensor  ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_DREHEN_SENSOR_EINLAUF_BELEGT;
    steplDrehBewegung := STEP_900_E;

  ELSIF bpEinlaufSensor AND bpAuslaufSensor THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_DREHEN_SENSOR_EINLAUF_AUSLAUF_BELEGT;
    steplDrehBewegung := STEP_900_E;

  END_IF


  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplDrehBewegung OF
    // DREHBEWEGUNG =========================
    STEP_0_E:
      (* Hinweis:
         - Variablen zurueck setzen
         - Pruefen ob der Antrieb bereit zum verfahrern ist
      *)
      bpDone := FALSE;
      bpDrehStatusMelden := FALSE;

      epDrehPositionsAlt := epDrehPositionsStatus;

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplDrehBewegung := STEP_10_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplDrehBewegung := STEP_900_E;
      END_IF

    // DREHBEWEGUNG =========================
    STEP_10_E:
      (* Anmerkung:
         - Loesen der Arretierung
      *)
      Arretierung.bpStartEinfahren := TRUE;

      steplDrehBewegung := STEP_20_E;

    // DREHBEWEGUNG =========================
    STEP_20_E:
      (* Hinweis:
         - Arretierung ist eingefahren
      *)
      IF ( Arretierung.bpDone ) THEN
        Arretierung.bpStartEinfahren := FALSE;
        steplDrehBewegung := STEP_30_E;
      END_IF

      (* Fehlerbehandlung:
         - Arretierung [Pneumatik Zylinder]
      *)
      IF ( Arretierung.bpFehler ) THEN
        Arretierung.bpStartEinfahren := FALSE;
        wpFehlerNr := Arretierung.wpFehlerNr;
        steplDrehBewegung := STEP_900_E;
      END_IF

    // DREHBEWEGUNG =========================
    STEP_30_E:
      (* Hinweis:
         - Vor dem Verfahren pruefen ob der Antrieb in einem Endschalter steht
           => Nach einer Stop- Situation
      *)
      IF (  NOT Antrieb.bpMinSchalterBelegt
           AND NOT Antrieb.bpMaxSchalterBelegt )
      THEN
        steplDrehBewegung := STEP_100_E;
      ELSE
        steplDrehBewegung := STEP_40_E;
      END_IF

    // DREHBEWEGUNG =========================
    STEP_40_E:
      (* Hinweis:
         - Versuchen den Endschalter frei zufahren
           WICHTIG [PROJEKT INTERPANE HOERDT]
         - Geschwindigkeit sehrlangsam
      *)
      tonlEndschalterFreifahren( IN := TRUE, PT:= T#10s);

      toflHardwareEndschalterFrei( IN := (     NOT Antrieb.bpMinSchalterBelegt
                                           AND NOT Antrieb.bpMaxSchalterBelegt),
                                   PT := t#1s);

      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;

      IF (  Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDMINUS;
      END_IF

      IF ( Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDPLUS;
      END_IF

      (* Hinweis:
         - Endschalter min. 1 sec freifahren
      *)
      IF ( NOT toflHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplDrehBewegung := STEP_50_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei !
         - Antrieb
      *)
      IF ( tonlEndschalterFreifahren.Q
           AND (  Antrieb.bpMinSchalterBelegt
                 OR   Antrieb.bpMaxSchalterBelegt ))
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_DREHEN_ENDSCHALTER_NICHT_FREI;
        steplDrehBewegung := STEP_900_E;
      END_IF

      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplDrehBewegung := STEP_900_E;
      END_IF

    // DREHBEWEGUNG =========================
    STEP_50_E:
      (* Hinweis:
         - Erzwungene Pause, damit der Antrieb wieder ordnungsgemaeß schaltet
      *)
      tonlWarteSchrittEndschalterFreifahren(IN := TRUE, PT:= T#2s);

      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        tonlWarteSchrittEndschalterFreifahren(IN := FALSE );
        steplDrehBewegung := STEP_100_E;
      END_IF

    // DREHBEWEGUNG =========================
    STEP_100_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ERMITTELN DER DREH- POSITION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Bestimmen der Ziel- Position
      //    => Step 100: Starten der Positionierung
      //    => Step  50: Undefinierte Positionen aufschluesseln
      steplDrehBewegung := STEP_200_E;

      CASE epDrehPositionsStatus OF

        eDrehPosition0Grad:
          rpZielPositionition := ppParameterBaustein.rDrehposition_180_Grad;

        eDrehPosition180Grad:
          rpZielPositionition := ppParameterBaustein.rDrehposition_0_Grad;

        ELSE
          steplDrehBewegung := STEP_110_E;

      END_CASE

    // DREHBEWEGUNG =========================
    STEP_110_E:
      (* Hinweis:
         - Undefinierte Position korregieren
      *)
      steplDrehBewegung := STEP_200_E;

      IF  (  ( ABS(Antrieb.rpIstPosition) < ppParameterBaustein.rDrehposition_0_Grad )) THEN
        rpZielPositionition := ppParameterBaustein.rDrehposition_0_Grad;

      ELSIF (  ( ABS(Antrieb.rpIstPosition) > ppParameterBaustein.rDrehposition_0_Grad )
              AND ( ABS(Antrieb.rpIstPosition) < ppParameterBaustein.rDrehposition_180_Grad ))
      THEN
        rpZielPositionition := ppParameterBaustein.rDrehposition_0_Grad;

      ELSIF  (  ( ABS(Antrieb.rpIstPosition) > ppParameterBaustein.rDrehposition_180_Grad )) THEN
        rpZielPositionition := ppParameterBaustein.rDrehposition_180_Grad;

      ELSE
        rpZielPositionition := ppParameterBaustein.rDrehposition_0_Grad;

      END_IF

    // DREHBEWEGUNG =========================
    STEP_200_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< STARTEN DER DREHBEWEGUNG >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Antriebsparameter initialisieren
      //     => Die Geschwindigkeit beim Drehkreuz wird in U/min uebergeben
      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.rpZielposition    := rpZielPositionition;

      steplDrehBewegung := STEP_210_E;

    // DREHBEWEGUNG =========================
    STEP_210_E:
      (* Hinweis:
         - Starten der Drehbewegung
           =>
      *)
      Antrieb.wpBetriebsart     := ABSOLUT;

      steplDrehBewegung := STEP_220_E;

    // DREHBEWEGUNG =========================
    STEP_220_E:
      (* Hinweis:
         - Drehbewegung abgeschlossen
      *)
      IF ( Antrieb.bpDone ) THEN
        bpDrehStatusMelden := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplDrehBewegung := STEP_230_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplDrehBewegung := STEP_900_E;
      END_IF

    // DREHBEWEGUNG =========================
    STEP_230_E:
      (* Anmerkung:
         - Setzen der Arretierung
      *)
      bpDrehStatusMelden := FALSE;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Arretierung.bpStartAusfahren := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplDrehBewegung := STEP_240_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplDrehBewegung := STEP_900_E;
      END_IF

    // DREHBEWEGUNG =========================
    STEP_240_E:
      (* Hinweis:
         - Arretierung ist ausgefahren
      *)
      IF ( Arretierung.bpDone ) THEN
        Arretierung.bpStartAusfahren := FALSE;

        (* Anmerkung:
           - melden der Drehposition ans MMI zur
               Datensynchronisation für den weiteren Automatikabaluf
        *)
        wgSps2MmiDrehStation       := stStationsNummern.NummerIntern;
        wgSps2MmiPosDrehStation    := epDrehPositionsStatus;
        wgSps2MmiOldPosDrehStation := epDrehPositionsAlt;
        MsgToMmi( auftragsnr_w := SB0_SPS_TURNSTATIONPOSITION );

        steplDrehBewegung := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Arretierung [Pneumatik Zylinder]
      *)
      IF ( Arretierung.bpFehler ) THEN
        Arretierung.bpStartAusfahren := FALSE;
        wpFehlerNr := Arretierung.wpFehlerNr;
        steplDrehBewegung := STEP_900_E;
      END_IF

    // DREHBEWEGUNG =========================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpFehler := TRUE;

    // DREHBEWEGUNG =========================
    STEP_1000_E: ;
      bpDone := TRUE;

  // DREHBEWEGUNG =========================
  END_CASE

END_IF

IF ( NOT bpStarteDrehBewegung ) THEN

  IF ( steplDrehBewegung > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    Arretierung.bpStartEinfahren := FALSE;
    Arretierung.bpStartAusfahren := FALSE;

    bpDrehStatusMelden := FALSE;

    steplDrehBewegung := STEP_0_E;
  END_IF

END_IF

//_________________________________________________________________________
// ************************ ENDE - Drehen ********************************
//_________________________________________________________________________

//-------------------------------------------------------------------------------------------------
// E N D E - Betriebstypen des Positionieren
//-------------------------------------------------------------------------------------------------
END_ACTION