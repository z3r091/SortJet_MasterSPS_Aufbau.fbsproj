(* METADATA
{
  "v3Meta": {
    "objectGuid": "1fb5df76-8c01-466b-909a-7e8384e95a98"
  }
}
*)
FUNCTION_BLOCK Kipptisch_Kippen_FB
VAR_INPUT

  // BOOLEAN 
  bpAktivieren           : BOOL; // Aktivierung: stStationsAufbau.bKippen
  bpSensorEinlauf        : BOOL;
  bpSensorAuslauf        : BOOL;
  bpStartKippenAuf       : BOOL;
  bpStartKippenAb        : BOOL;
  bpReset                : BOOL; 
  bpReferenz             : BOOL; 
  bpBetriebsartHand      : BOOL; 
  bpHandfahrenMinus      : BOOL;
  bpHandfahrenPlus       : BOOL; 
  bpFreigabe             : BOOL; 
  bpLangsamKippen        : BOOL;

  // STRUCT
  stStationsNummern      : Station_ST;
  
  // POINTER
  ppParameterBaustein     : REFERENCE TO Parameter_Kippen;
  ppAntriebsInformationen : REFERENCE TO AntriebsInformationen;

END_VAR
VAR_OUTPUT

  // BOOL 
  bpDone                 : BOOL; 
  bpFehler               : BOOL;
  bpVerfahrFreigabe      : BOOL;

  // WORD
  wpFehlerNr             : WORD;

  // REAL
  rpOutGeschwindigkeit   : REAL;

  // ENUM
  epKippStatus  : Kippen_EN;

END_VAR
VAR

  // BOOLEAN
  blErsterZyklus : BOOL := TRUE;

  // TIMER
  tonlMaxWarteAufResetErfolgreich       : TON; 
  tonlEndschalterFreifahren             : TON; 
  tonlWarteSchrittEndschalterFreifahren : TON; 
  tofHardwareEndschalterFrei            : TOF; 
  toflReglerFreigabeErhalten            : TOF; 

  // STEPS 
  steplKippenAuf    : Steps_TE;
  steplKippenAb     : Steps_TE;
  steplReferenz     : Steps_TE;
  steplReset        : Steps_TE;

  // Antrieb
  Antrieb : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

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

  bpDone            := TRUE;
  bpVerfahrFreigabe := TRUE;

  bpFehler   := FALSE;
  wpFehlerNr := 0;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// TIMER
//-------------------------------------------------------------------------------------------------
tonlMaxWarteAufResetErfolgreich(IN:=bpReset,pt:=tgMaxWartezeitReset-T#1S);




//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
Aufkippen();
Abkippen();

// Basis- Aktionen
Referenz();
Reset();
Meldungen();
Handbetrieb();



//-------------------------------------------------------------------------------------------------
// FREIGABEN UND BAUSTEINAUFRUFE
//-------------------------------------------------------------------------------------------------
// Antriebsfreigabe
toflReglerFreigabeErhalten( IN := (   bpStartKippenAuf
                                    OR bpStartKippenAb
                                    OR bpReferenz
                                    OR bpHandfahrenPlus
                                    OR bpHandfahrenMinus ),
                            PT := ppParameterBaustein.tZeitAntriebsfreigabeErhalten );


// AufrufAntrieb
Antrieb.bpFreigabe        :=    ( bpFreigabe 
                                  AND bpVerfahrFreigabe
                                  AND toflReglerFreigabeErhalten.Q );
Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;
Antrieb.stStationsNummern := stStationsNummern ;




//-------------------------------------------------------------------------------------------------
// AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Verfahrfreigabe
bpVerfahrFreigabe := NOT ( bpSensorEinlauf
                           OR bpSensorAuslauf );

// Ausgabe Iis-Pos als Enum
IF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rPosition0Grad) <= ppParameterBaustein.rToleranz) THEN
  epKippStatus := eKippen_Position_0Grad;

ELSIF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rPosition90Grad) <= ppParameterBaustein.rToleranz) THEN
  epKippStatus := eKippen_Position_90Grad;

ELSE
  epKippStatus := eKippen_Fehler;

END_IF

// Aktuelle Geschwindigkeit des Antriebs
rpOutGeschwindigkeit := ABS(Antrieb.rpIstGeschwindigkeit);
END_FUNCTION_BLOCK