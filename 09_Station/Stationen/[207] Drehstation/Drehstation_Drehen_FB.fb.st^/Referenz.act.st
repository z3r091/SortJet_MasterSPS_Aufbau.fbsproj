(* METADATA
{
  "v3Meta": {
    "objectGuid": "86b248ff-7e77-4ada-aa52-f484bfef6323"
  }
}
*)
ACTION Referenz
(***************************************************************************************************)
(* S T A R T - Referenzpunktfahrt *)
(***************************************************************************************************)

IF( bpReferenz )THEN
  CASE steplReferenz OF
    (*REFERENZ =============================*)
    STEP_0_E:
      (* Hinweis:
         - Timer zuruecksetzen
         - Abfragen ob Regler Betriebsbereit ist
      *)
      tonlEndschalterFreifahren(IN := FALSE);
      tonlWarteSchrittEndschalterFreifahren(IN := FALSE);
      toflHardwareEndschalterFrei(IN:=FALSE);

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_10_E;
      END_IF

      (* Fehlerbehandlung:
         - Schwenk- Antrieb
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplReferenz := STEP_900_E;
      END_IF

    (*REFERENZ =============================*)
    STEP_10_E:
      (* Anmerkung:
         - Loesen der Arretierung
      *)
      Arretierung.bpStartEinfahren := TRUE;
      steplReferenz := STEP_20_E;

    (*REFERENZ =============================*)
    STEP_20_E:
      (* Hinweis:
         - Arretierung ist eingefahren
      *)
      IF ( Arretierung.bpDone ) THEN
        Arretierung.bpStartEinfahren := FALSE;
        steplReferenz := STEP_30_E;
      END_IF

      (* Fehlerbehandlung
         - Arretierung [Pneumatik Zylinder]
      *)
      IF ( Arretierung.bpFehler) THEN
        Arretierung.bpStartEinfahren := FALSE;
        wpFehlerNr := Arretierung.wpFehlerNr;
        steplReferenz := STEP_900_E;
      END_IF

    (*REFERENZ =============================*)
    STEP_30_E:
      (* Hinweis:
         - Einlauf und Auslaufsensor vor dem Verfahren pruefen 
           => Vor dem Verfahren pruefen ob der Antrieb in einem Endschalter steht
      *)
      IF (  NOT bpEinlaufSensor
           AND NOT bpAuslaufSensor )
      THEN

        IF (  NOT Antrieb.bpMinSchalterBelegt
             AND NOT Antrieb.bpMaxSchalterBelegt )
        THEN
          steplReferenz := STEP_100_E;
        ELSE
          steplReferenz := STEP_40_E;
        END_IF

      ELSE
        wpFehlerNr := cMELDUNG_DREHEN_SENSOR_EINLAUF_AUSLAUF_BELEGT;
        steplReferenz := STEP_900_E;

      END_IF

    (*REFERENZ =============================*)
    STEP_40_E:
      (* Hinweis:
         - Versuchen den Endschalter frei zufahren 
      *)
      tonlEndschalterFreifahren( IN := TRUE, PT:= T#10s);

      toflHardwareEndschalterFrei( IN := ( NOT Antrieb.bpMinSchalterBelegt
                                           AND NOT Antrieb.bpMaxSchalterBelegt),
                                   PT := t#1s);

      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;

      IF (  Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDMINUS;
      END_IF

      IF (  Antrieb.bpMinschalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDPLUS;
      END_IF

      (* Hinweis:
         - Endschalter min. 1 sec freifahren
      *)
      IF ( NOT toflHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplReferenz := STEP_50_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei 
         - Antrieb
      *)
      IF ( tonlEndschalterFreifahren.Q
           AND (  Antrieb.bpMinSchalterBelegt
                 OR   Antrieb.bpMaxSchalterBelegt ))
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_DREHEN_ENDSCHALTER_NICHT_FREI;
        steplReferenz := STEP_900_E;
      END_IF

      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplReferenz := STEP_900_E;
      END_IF

    (*REFERENZ =============================*)
    STEP_50_E:
      (* Hinweis:
         - Erzwungene Pause, damit der Antrieb wieder ordnungsgemäß schaltet
      *)
      tonlWarteSchrittEndschalterFreifahren(IN := TRUE, PT:= T#2s);

      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        steplReferenz := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_MESSACHSE;
        steplReferenz := STEP_900_E;
      END_IF

    (*REFERENZ =============================*)
    STEP_100_E:
      (* Hinweis:
         - Initialisieren der Antriebsparameter
      *)
      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.rpZielposition    := 0;

      steplReferenz := STEP_110_E;

    (*REFERENZ =============================*)
    STEP_110_E:
      (* Hinweis:
         - Betriebsart absetzen
      *)
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;

      steplReferenz := STEP_120_E;

    (*REFERENZ =============================*)
    STEP_120_E:
      (* Hinweis:
         - Referenzierung abgeschlossen 
         - Setzen der Arretierung
      *)
      IF( Antrieb.bpDone )THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb 
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplReferenz := STEP_900_E;
      END_IF

    (*REFERENZ =============================*)
    STEP_200_E:
      (* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ANTRIEB NACH REFERENZ POSITIONIEREN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

         Hinweis:
         - Starten der Positionierung auf 0 Grad
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.rpZielposition    := ppParameterBaustein.rDrehposition_0_Grad;

        steplReferenz := STEP_210_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb 
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplReferenz := STEP_900_E;
      END_IF

    (*REFERENZ =============================*)
    STEP_210_E:
      (* Hinweis:
         - Positionierung abgeschlossen
      *)
      IF(  Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_220_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb 
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplReferenz := STEP_900_E;
      END_IF

    (*REFERENZ =============================*)
    STEP_220_E:
      (* Hinweis:
         -Sicherstellen das der ANtrieb sicher steht dann die Arretierung ausfahren
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Arretierung.bpStartAusfahren := TRUE;
        steplReferenz := STEP_230_E;
      END_IF

    (*REFERENZ =============================*)
    STEP_230_E:
      (* Hinweis:
         - Arretierung ist ausgefahren
      *)
      IF ( Arretierung.bpDone ) THEN
        Arretierung.bpStartAusfahren := FALSE;
        steplReferenz := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung
         - Arretierung [Pneumatik Zylinder]
      *)
      IF ( Arretierung.bpFehler ) THEN
        Arretierung.bpStartAusfahren := FALSE;
        wpFehlerNr := Arretierung.wpFehlerNr;
        steplReferenz := STEP_900_E;
      END_IF

    (*REFERENZ =============================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      bpFehler :=TRUE;

    (*REFERENZ =============================*)
    STEP_1000_E:
      bpDone := TRUE;

  (*REFERENZ =============================*)
  END_CASE

ELSE
  IF( steplReferenz > STEP_0_E )THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    Arretierung.bpStartAusfahren := FALSE;
    Arretierung.bpStartEinfahren := FALSE;


    steplReferenz := STEP_0_E;
  END_IF
END_IF
(***************************************************************************************************)
(* S T A R T - Referenzpunktfahrt *)
(***************************************************************************************************)
END_ACTION