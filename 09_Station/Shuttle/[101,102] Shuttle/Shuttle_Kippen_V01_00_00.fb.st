(* METADATA
{
  "v3Meta": {
    "objectGuid": "188879d4-0bd4-40ef-906f-fea4dde7d858"
  }
}
*)
FUNCTION_BLOCK Shuttle_Kippen_V01_00_00
VAR_INPUT

  // BOOL
  bpSensorEinlauf                  : BOOL;
  bpSensorAuslauf                  : BOOL;
  bpAktivieren                     : BOOL;
  bpPositionieren                  : BOOL;
  bpReset                          : BOOL; 
  bpReferenz                       : BOOL;
  bpBetriebsartHand                : BOOL; 
  bpFreigabe                       : BOOL; 
  bpLangsamKippen                  : BOOL;
  bpTeilnehmerErreichbar           : BOOL;
  bpKippenSchuetz                  : BOOL;

  // STRUCT
  stStationsNummern      : Station_ST;
  epZielPosition         : Kippen_EN;

  // POINTER
  ppParameterBaustein     : REFERENCE TO Parameter_Kippen;
  ppAntriebsInformationen : REFERENCE TO AntriebsInformationen;

END_VAR
VAR_OUTPUT

  // BOOL
  bpDone                 : BOOL; 
  bpFehler               : BOOL;
  bpInReferenz           : BOOL;

  // WORD
  wpFehlerNr             : WORD;

  // REAL 
  rpAktuelleKippPosition : REAL;
  rpOutGeschwindigkeit   : REAL;

  // ENUM
  epKippStatus           : Kippen_EN;

END_VAR
VAR

  // BOOL
  blErsterZyklus                : BOOL := TRUE;
  blSensorEinlauf               : BOOL;
  blSensorAuslauf               : BOOL;
  bpStartAufkippen              : BOOL;
  bpStartAbkippen               : BOOL;

  // TIMER 
  tonlMaxWarteAufResetErfolgreich       : TON;
  tonlAntriebNichtFreigegeben           : TON; // Ueberwachung: Antrieb nicht betriebsbereit
  tonlEndschalterFreifahren             : TON; 
  tonlWarteSchrittEndschalterFreifahren : TON; 
  tofHardwareEndschalterFrei            : TOF; 
  toflReglerFreigabeErhalten            : TOF; 
  tonlSensorEinlauf                     : TON;
  tonlSensorAuslauf                     : TON;
  toflReset                             : TOF;
  tonlTeilnehmerErreichbar              : TON;
  tonlMaxWarteZeit                      : TON;
  toflMotorstarterOK                    : TOF;
  toflMotorSicherungOK                  : TOF;

  // STEPS
  steplPositionieren : Steps_TE;
  steplReferenz      : Steps_TE;
  steplReset         : Steps_TE;
  steplKippenSchuetz : Steps_TE; // Mit Schütz Kippen

  // Antrieb
  Antrieb : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bMotorschutzschalter_OK           AT %I* : BOOL; 
  in_bLeitungsschutzschalterBremseOK   AT %I* : BOOL;
  in_bMotorstarter_OK           : BOOL;
  in_bSensorNicht90Grad         : BOOL;
  in_bSensorNicht84Grad         : BOOL;
                                      
                                      
  // HARDWARE AUSGAENGE
  out_bKippenAbSetzen           : BOOL;
  out_bKippenAufSetzen          : BOOL;
  out_bBremseLoesen             : BOOL;
  out_bReset                    : BOOL;

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

    tonlTeilnehmerErreichbar(IN := FALSE);
    tonlMaxWarteZeit(IN := FALSE);

  ELSE
    RETURN;
  END_IF

END_IF

// Endschalter zyklisch an den Antrieb geben: 84 Grad = Min, 90 Grad = Max (Oeffner, wirkt nur bei Endschalterquelle SPS)
Antrieb.bpEndschalterMaxExtern := in_bSensorNicht90Grad;
Antrieb.bpEndschalterMinExtern := in_bSensorNicht84Grad;

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------

IF ( NOT bpAktivieren ) THEN
  bpDone     := TRUE;
  bpFehler   := FALSE;
  wpFehlerNr := 0;

  IF ( bpPositionieren AND ( epZielPosition = eKippen_Position_0Grad ) ) THEN
    epKippStatus := eKippen_Position_0Grad;
  ELSIF ( bpPositionieren AND ( epZielPosition = eKippen_Position_84Grad ) ) THEN
    epKippStatus := eKippen_Position_84Grad;
  ELSIF ( bpPositionieren AND ( epZielPosition = eKippen_Position_88_5Grad ) ) THEN
    epKippStatus := eKippen_Position_88_5Grad;
  ELSIF ( bpPositionieren AND ( epZielPosition = eKippen_Position_90Grad ) ) THEN
    epKippStatus := eKippen_Position_90Grad;
  ELSE
    epKippStatus := eKippen_Default;
  END_IF
  
  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// TIMER
//-------------------------------------------------------------------------------------------------
// Reset- Ueberwachung
tonlMaxWarteAufResetErfolgreich(IN := bpReset, pt := tgMaxWartezeitReset-T#1S);
tonlSensorEinlauf( IN := bpSensorEinlauf , pt := T#200MS );
tonlSensorAuslauf( IN := bpSensorAuslauf , pt := T#200MS );
blSensorEinlauf := tonlSensorEinlauf.Q;
blSensorAuslauf := tonlSensorAuslauf.Q;

tonlTeilnehmerErreichbar( IN := bpTeilnehmerErreichbar, PT := T#5S );
tonlMaxWarteZeit(IN:=(    ( bpStartAbKippen AND out_bKippenAbSetzen )
                       OR ( bpStartAufKippen AND out_bKippenAufSetzen ) ),
                  PT:= ppParameterBaustein.tZeitlicheUeberwachungKippen );

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
Meldungen();
Ausgaenge();
Reset();

IF ( bpKippenSchuetz ) THEN
  // Bremse lösen
  out_bBremseLoesen := out_bKippenAbSetzen OR out_bKippenAufSetzen OR bgVISUKippenBremseLoesen[stStationsNummern.NummerSPS];
  
  // Reset Motorstarter
  toflReset( IN := bpReset, PT := T#3S );
  out_bReset := toflReset.Q;
  
  Kippen_Schuetz();

ELSE
  Positionieren();
  Referenz();

  IF ( NOT bpKippenSchuetz ) THEN
    // Antriebsfreigabe:
    toflReglerFreigabeErhalten( IN := (   bpPositionieren
                                        OR bpReferenz ),
                                PT := ppParameterBaustein.tZeitAntriebsfreigabeErhalten );
    
      
    // Aufruf
    Antrieb.bpFreigabe        := bpFreigabe AND toflReglerFreigabeErhalten.Q;
    Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;
    Antrieb.stStationsNummern := stStationsNummern;
    
  END_IF
  
END_IF
END_FUNCTION_BLOCK