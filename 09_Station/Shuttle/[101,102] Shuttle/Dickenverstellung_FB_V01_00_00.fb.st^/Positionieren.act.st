(* METADATA
{
  "v3Meta": {
    "objectGuid": "c05de6d0-e5f5-4b15-a7fe-b0ef310a90ee"
  }
}
*)
ACTION Positionieren
//-------------------------------------------------------------------------------------------------
// POSITIONIEREN
//-------------------------------------------------------------------------------------------------
(* Anmerkung:
   - -
*)
IF( bpStartePositionierung ) THEN


  (* Hinweis:
     - Ausnahmefehler
  *)
  IF ( Antrieb.bpFehler
       AND bpOptionMotorischAktivieren )
  THEN
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB;
    steplPositionieren := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplPositionieren OF
    // POSITIONIEREN ====================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
         - Pruefen ob der Umrichter bereit zum verfahren ist
      *)
      bpDone := FALSE;

      tonlEndschalterFreifahren(IN := FALSE);
      tonlWarteSchrittEndschalterFreifahren(IN := FALSE);
      tofHardwareEndschalterFrei(IN:=FALSE);

      IF ( Antrieb.bpReglerBereit
           OR NOT bpOptionMotorischAktivieren )
      THEN
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpGeschwindigkeit  := REAL#0;

        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;

        IF (  Antrieb.bpMinSchalterBelegt ) THEN
          steplPositionieren := STEP_10_E;
        ELSE
          steplPositionieren := STEP_100_E;
        END_IF

      END_IF

    // POSITIONIEREN ====================
    STEP_10_E:
      tonlEndschalterFreifahren(IN := TRUE, PT:= T#10s);

      tofHardwareEndschalterFrei( IN := (    Antrieb.bpMinSchalterBelegt
                                          OR Antrieb.bpMaxSchalterBelegt ),
                                  PT := t#1s);

      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;

      IF (  Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDPLUS;
      END_IF

      IF (  Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDMINUS;
      END_IF


      (* Hinweis:
         - Endschalter min. 1 sec freifahren
      *)
      IF ( NOT tofHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplPositionieren := STEP_20_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei !
         - Antrieb
      *)
      IF ( tonlEndschalterFreifahren.Q
           AND ( Antrieb.bpMaxSchalterBelegt
                 OR Antrieb.bpMinSchalterBelegt ))
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_QUERFAHRT_ENDSCHALTER_NICHT_FREI;
        steplPositionieren := STEP_900_E;
      END_IF

    // POSITIONIEREN ====================
    STEP_20_E:
      (* Hinweis:
         - Erzwungene Pause, damit der Lenze Antrieb wieder ordnungsgemäß schaltet
      *)
      tonlWarteSchrittEndschalterFreifahren(IN := TRUE, PT:= T#2s);

      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        steplPositionieren := STEP_100_E;
      END_IF

    // POSITIONIEREN ====================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  AUFTRAGSDATEN PRUEFEN [STELLUNG]
      //
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpMaxGeschwindigkeit;

      CASE epSollStellung OF

          eZylinderStellung16mm,
            eZylinderUndefiniert:
          rlZielPosition := ppParameterBaustein.rPosition_Minimal;
          steplPositionieren := STEP_110_E;

        eZylinderStellung23mm:
          rlZielPosition := ppParameterBaustein.rPosition_Mittel;
          steplPositionieren := STEP_110_E;


        eZylinderStellung29mm:
          rlZielPosition := ppParameterBaustein.rPosition_Maximal;
          steplPositionieren := STEP_110_E;

        ELSE
          rlZielPosition := ppParameterBaustein.rPosition_Minimal;

          wpgFehlerdaten[0] := stStationsNummern.NummerExtern;
          SpsHinweis( eFehler_Station,
                      cMELDUNG_GLASFUEHRUNG_ZIEL_STELLUNG_UNGUELTIG,
                      stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(stStationsNummern.NummerSPS),
                      wpgFehlerdaten );

          steplPositionieren := STEP_900_E;
      END_CASE



    // POSITIONIEREN ====================
    STEP_110_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DER POSITIONIERUNG
      //
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------
      IF bpOptionMotorischAktivieren THEN
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpMaxGeschwindigkeit;

        Antrieb.rpZielposition     := rlZielPosition;
        Antrieb.wpBetriebsart      := ABSOLUT ;

        steplPositionieren := STEP_120_E;
      ELSE
        steplPositionieren := STEP_120_E;

      END_IF

    // POSITIONIEREN ====================
    STEP_120_E:
      IF ( Antrieb.bpDone OR NOT bpOptionMotorischAktivieren ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplPositionieren := STEP_1000_E;
      END_IF

    // POSITIONIEREN ====================
    STEP_900_E:
      bpFehler := TRUE;

    // POSITIONIEREN ====================
    STEP_1000_E:
      bpDone := TRUE;

  // POSITIONIEREN ====================
  END_CASE
ELSE
  IF( steplPositionieren > STEP_0_E )THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    steplPositionieren := STEP_0_E;
  END_IF
END_IF
END_ACTION