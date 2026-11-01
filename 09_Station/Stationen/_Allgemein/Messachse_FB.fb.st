(* METADATA
{
  "v3Meta": {
    "objectGuid": "ee8fce2f-1a3c-411c-afad-25d0a39b52dd"
  }
}
*)
FUNCTION_BLOCK Messachse_FB
VAR_INPUT

  // BOOL
  bpAktivieren                             : BOOL;
  bpPositionierung                         : BOOL;
  bpVermessen_OberUndUnterkante_2_Sensoren : BOOL;
  bpVermessen_Oberkante_1_Sensor           : BOOL;
  bpReset                                  : BOOL;
  bpReferenz                               : BOOL;
  bpFreigabe                               : BOOL;
  bpHandplus                               : BOOL;
  bpHandminus                              : BOOL;
  bpHandReferenz                           : BOOL;
  bpBetriebsartHand                        : BOOL;
  bpFusstaster                             : BOOL;

  // REAL
  rpZielPosition                           : REAL;
  rpErwarteteScheibenHoehe                 : REAL;

  // STRUCT
  stStationsNummern                        : Station_ST;

  // POINTER
  ppAntriebsInformationen                  : REFERENCE TO AntriebsInformationen;
  ppParameterBaustein                      : REFERENCE TO Parameter_Messachse;

END_VAR
VAR_OUTPUT

  // BOOL
  bpDone                    : BOOL;
  bpFehler                  : BOOL;
  bpInReferenz              : BOOL;
  bprtScheibe               : BOOL;
  bpVermessenAbgeschlossen  : Bool;

  // WORD
  wpFehlerNr                : Fehlerkonstanten_EN;

  // REAL
  rpIstPosition             : REAL;
  rlScheibenunterkante      : REAL;
  rlScheibenoberkante       : REAL;
  rlMessErgebnis            : REAL;
  rlPositionAntriebBeiStart : REAL;
  rlBremsWeg                : REAL;

  // ENUM
  epGlashoehenTyp      : GlasHoehenTyp_EN;
  epGlashoehenTypMode2 : GlasHoehenTyp_EN;

END_VAR
VAR

  // BOOL
  blErsterZyklus                         : BOOL := TRUE;

  // REAL
  rlBremsPos                             : REAL;
  rlOffsetMinimumFrueherBremsen          : REAL := 150;
  rlOffsetMaximumFrueherBremsen          : REAL := 300;

  // TIMER
  tonlEndschalterFreifahren              : TON;
  tonlWarteSchrittEndschalterFreifahren  : TON;
  tonlMaxWarteAufResetErfolgreich        : TON;
  tonlTimeoutUnterkante                  : TON;
  toflHardwareEndschalterFrei            : TOF;
  toflReglerFreigabeErhalten             : TOF;

  // STEPS
  steplPositionieren                     : Steps_TE;
  steplReferenz                          : Steps_TE;
  steplReset                             : Steps_TE;
  steplOberkante_1_Sensor                : Steps_TE;
  steplOberUndUnterkante_2_Sensoren      : Steps_TE;

  // Antrieb
  Antrieb : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

END_VAR

VAR_INPUT

  // HARDWARE EINGAENGE
  in_bSensorUnten                        : BOOL;
  in_bSensorOben                         : BOOL;
  in_bSensorUnterkante                   : BOOL;
  in_bEndschalterMin                     : BOOL; // Oeffner (TRUE = frei), gemappt; zum Umrichter ueber Signal-Steuerwort Bit 10, wirkt nur bei Endschalterquelle SPS

END_VAR
VAR CONSTANT

  // REAL
  cUEBERWACHUNG_WEGSTRECKE  : REAL := 40.0;

END_VAR

//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN

  IF ( __ISVALIDREF(ppAntriebsInformationen) ) THEN

    blErsterZyklus := FALSE;

    Antrieb REF= pgAntriebe[ppAntriebsInformationen.wAchsID];

    (* Hinweis:
       - Initialisierung Antriebsinformationen
    *)
    Antrieb.ppAntriebsInformationen REF= ppAntriebsInformationen;

    (* Hinweis:
       - Für die Zielpunktkontrolle muss im ersten Zyklus die Zielposition initialisiert werden
    *)
    Antrieb.rpZielPosition := Antrieb.rpIstPosition;

    (* Hinweis:
       - Antriebswerte vorinitialisieren
    *)
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
    Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
    Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
    Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;

  ELSE
    RETURN;
  END_IF

END_IF

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF ( NOT bpAktivieren ) THEN

  bpDone := TRUE;

  (* Hinweis:
     - Ausnahmesituationen
  *)
  bpInReferenz := TRUE;
  bpFehler   := FALSE;
  wpFehlerNr := WORD#0;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// IO's
//-------------------------------------------------------------------------------------------------
in_bSensorOben       := Antrieb.udipEingaengeUmrichter.cXG31_2_I_2;
in_bSensorUnten      := Antrieb.udipEingaengeUmrichter.cXG31_1_I_1;
in_bSensorUnterkante := Antrieb.udipEingaengeUmrichter.cXG37_4_I_6;
Antrieb.bpEndschalterMinExtern := in_bEndschalterMin;

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------

Positionieren();
Vermessen_Oberkante_1_Sensor();
Vermessen_OberUndUnterkante_2_Sensoren();
Reset();
Referenz();
Handfunktion();


//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Ausgabe der Aktuellen Position
rpIstPosition := Antrieb.rpIstPosition;
bpInReferenz := Antrieb.bpIstReferenziert;

(* Hinweis:
   - Scheibenhoehe kontrollieren
*)
IF ( in_bSensorUnten AND NOT in_bSensorOben ) THEN
  epGlashoehenTyp := eGlasHoeheOK;

ELSE

  IF ( NOT in_bSensorUnten AND NOT in_bSensorOben ) THEN
    epGlashoehenTyp := eGlasZuNiedrig;

  ELSIF ( in_bSensorUnten AND  in_bSensorOben ) THEN
    epGlashoehenTyp := eGlasZuHoch;

  END_IF

END_IF


//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUFRUFE
//-------------------------------------------------------------------------------------------------
toflReglerFreigabeErhalten( IN := (   bpPositionierung
                                    OR bpReferenz
                                    OR bpHandReferenz
                                    OR bpHandplus
                                    OR bpHandminus
                                    OR bpVermessen_OberUndUnterkante_2_Sensoren
                                    OR bpVermessen_Oberkante_1_Sensor
                                    OR bpReset ),
                            PT := tgZeitAutoabschaltungEnergiesparModus );

Antrieb.bpFreigabe        := ( bpFreigabe AND toflReglerFreigabeErhalten.Q );
Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;
Antrieb.stStationsNummern := stStationsNummern;

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUSNAHMESITUATIONEN
//-------------------------------------------------------------------------------------------------
IF ( Antrieb.bpFehler
     AND NOT ( steplPositionieren = STEP_900_E
               OR steplOberUndUnterkante_2_Sensoren = STEP_900_E
               OR steplOberkante_1_Sensor = STEP_900_E
               OR steplReferenz    = STEP_900_E
               OR steplReset       = STEP_900_E ) )
THEN
  wpFehlerNR := cMELDUNG_ANTRIEB_MESSACHSE;
  bpFehler := TRUE;
END_IF
END_FUNCTION_BLOCK