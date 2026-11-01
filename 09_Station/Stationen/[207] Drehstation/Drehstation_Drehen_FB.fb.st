(* METADATA
{
  "v3Meta": {
    "objectGuid": "d33597a7-c9cf-45cc-8dde-219d34a826f5"
  }
}
*)
FUNCTION_BLOCK Drehstation_Drehen_FB
VAR_INPUT
  // BOOLEAN
  bpAktivieren                  : BOOL; // AKTIVIERUNG: stStationsAufbau.bDrehen
  bpStarteDrehBewegung          : BOOL; // BETRIEBSART: Station Drehen Links [Uhrzeigersinn]
  bpStarteAbsolutPositionierung : BOOL; // BETRIEBSART: Station kann Absolut auf eine gewuenschte Position verfahren werden
  bpReset                       : BOOL; // BETRIEBSART: Reset
  bpReferenz                    : BOOL; // BETRIEBSART: Referenzieren des Antriebs
  bpBetriebsartHand             : BOOL; // BETRIEBSART: Handbetrieb
  bpHandfahrenMinus             : BOOL; // Handfunktionen: Antrieb Handminus verfahren
  bpHandfahrenPlus              : BOOL; // Handfunktionen: Antrieb Handplus verfahren
  bpHandZentrierungAusfahren    : BOOL; // Handfunktionen: Zentrierung ausfahren
  bpHandZentrierungEinfahren    : BOOL; // Handfunktionen: Zentrierung einfahren
  bpFreigabe                    : BOOL; // FREIGABE: Antrieb freigegeben
  bpStarteZentrierungAusfahren  : BOOL; // BETRIEBSART: Zentrierung ausfahren
  bpStarteZentrierungEinfahren  : BOOL; // BETRIEBSART: Zentrierung einfahren
  bpAusnahmeSituationAbfangen   : BOOL := FALSE; // Status ob bestimmte Ausnahmesituationen abgearbeitet werden sollen
  bpEinlaufSensor               : BOOL; // HARDWARE EINGAENGE: SENSOREN
  bpAuslaufSensor               : BOOL; // HARDWARE EINGAENGE: SENSOREN
  
  // ENUM
  epZielPosition : Drehen_EN;

  // POINTER
  ppParameterBaustein           : REFERENCE TO Parameter_Drehen;
  ppAntriebsInformationen       : REFERENCE TO AntriebsInformationen;

  // STRUCT
  stStationsNummern             : Station_ST;

  // BAUSTEINE
  Arretierung                   : Arretierung_FB;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone                                : BOOL; // Status: Arbeits-Prozess erfolgreich abfgeschlossen
  bpFehler                              : BOOL; // Status: Fehlverhalten im Baustein
  bpDrehvorgangAktiv                    : BOOL;
  bpInReferenz                          : BOOL; // Status: Baustein/Antrieb ist referenziert
  bpVerfahrFreigabe                     : BOOL;
  bpAbsolutPositionierungAbgeschlossen  : BOOL;
  bpDrehStatusMelden                    : BOOL; // Status zum Aauslösen der Nachricht:SB0_SPS_TURNSTATIONPOSITION in der Steuerung, damit das MMI die Drehposition weiß
  bpAusnahmeSituationSensorBelegt       : BOOL; // HINWEIS: Glas hat waehrend der Drehbewegung einen Sensor belegt -> Versuchen die Situation zu bereinigen

  // WORD
  wpFehlerNr   : WORD; // Status: Fehlernummer

  // REAL
  rpAktuellePosition   : REAL ; // Status: Gibt die Aktuelle Position des Dreh-Antriebs aus
  rpOutGeschwindigkeit : REAL;

  // ENUM
  epDrehPositionsStatus : Drehen_EN;

END_VAR
VAR

  // BOOLEAN
  blErsterZyklus          : BOOL := TRUE;

  // REAL
  rpZielPositionition  : REAL;

  // TIMER
  tonlMaxWarteAufResetErfolgreich       : TON; 
  tonlEndschalterFreifahren             : TON; 
  tonlWarteSchrittEndschalterFreifahren : TON; 
  tonlFreigabeErhalten                  : TON; 
  toflReglerFreigabeErhalten            : TOF; 
  toflHardwareEndschalterFrei           : TOF; 

  // STEPS
  steplDrehBewegung          : Steps_TE;
  steplAbsolutPositionieren  : Steps_TE;
  steplReferenz              : Steps_TE;
  steplReset                 : Steps_TE;

  // TRIGGER
  rtlStartePositionierung : R_TRIG;

  // ENUM
  epDrehPositionsAlt : Drehen_EN;

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

    (* Hinweis:
       - Aktivierung Unterbausteine
    *)
    Arretierung.bpAktivieren := ppParameterBaustein.bArretierung;

  ELSE
    RETURN;
  END_IF

END_IF

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF ( NOT bpAktivieren ) THEN

  bpDone                               := TRUE;
  bpInReferenz                         := TRUE;
  bpVerfahrFreigabe                    := TRUE;
  bpAbsolutPositionierungAbgeschlossen := TRUE;

  bpFehler   := FALSE;
  wpFehlerNr := 0;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// IO ZUWEISUNG
//-------------------------------------------------------------------------------------------------

// Arretierung
Arretierung.in_bStatusZylinderEingefahren := Antrieb.udipEingaengeUmrichter.cXG37_3_I_5;
Arretierung.in_bStatusZylinderAusgefahren := Antrieb.udipEingaengeUmrichter.cXG37_4_I_6;

Antrieb.wpAusgaengeUmrichter.cXG37_O_5 := Arretierung.out_bZylinderEinfahren;
Antrieb.wpAusgaengeUmrichter.cXG37_O_6 := Arretierung.out_bZylinderAusfahren;

//-------------------------------------------------------------------------------------------------
// TIMER, SETTINGS, ETC.
//-------------------------------------------------------------------------------------------------
// Timer:
//   - Reset- Ueberwachung
tonlMaxWarteAufResetErfolgreich(IN:=bpReset, PT := tgMaxWartezeitReset-t#1s);

(* Hinweis:
   - Freigabe des Antriebs erhalten
*)
tonlFreigabeErhalten( IN := bpFreigabe, PT := T#1s );



//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Betriebstypen
     => AbsolutPositionierung:;
   - Positionieren mit Zielvorgabe
     => AutarkePositionierung
   - Positionierung ohen Zielvorgabe
*)
AbsolutPositionierung();

//AutarkePositionierung();
(* Hinweis:
   - Basis- Aktion
*)
Reset();
Referenz();
Meldungen();
Handfunktionen();



//-------------------------------------------------------------------------------------------------
// S T A R T - Zuweisung und Bausteinaufrufe
//-------------------------------------------------------------------------------------------------
// Antriebsfreigabe:
//   - Antrieb [Drehen]
toflReglerFreigabeErhalten( IN := (   bpStarteDrehBewegung
                                    OR bpStarteAbsolutPositionierung
                                    OR bpHandfahrenMinus
                                    OR bpHandfahrenPlus
                                    OR bpReferenz ),
                            PT := tgZeitAutoabschaltungEnergiesparModus );

Antrieb.bpFreigabe         := (     toflReglerFreigabeErhalten.Q
                                AND Arretierung.in_bStatusZylinderEingefahren
                                AND bpFreigabe
                                AND bpVerfahrFreigabe );
Antrieb.rpRuckzeit         := ppAntriebsInformationen.rpMaxRuckzeit;
Antrieb.stStationsNummern  := stStationsNummern; 

// Bausteinaufruf:
//   - Drehantrieb
//   - Arretierung
Arretierung();



//-------------------------------------------------------------------------------------------------
// AUSGAENGE
//-------------------------------------------------------------------------------------------------
bpDrehvorgangAktiv :=  ( bpStarteAbsolutPositionierung 
                         OR bpStarteDrehBewegung );
(* Hinweis:
   - Aktuelle Position des Antriebs
*)
rpAktuellePosition := Antrieb.rpIstPosition;

(* Hinweis:
   - Aktuelle Geschwindigkeit
*)
rpOutGeschwindigkeit := ABS(Antrieb.rpIstGeschwindigkeit);

(* Hinweis:
   - Drehantrieb befindet sich in Referenz
*)
bpInReferenz := Antrieb.bpIstReferenziert;

(* Hinweis:
   - Verfahrfreigabe
*)
bpVerfahrFreigabe :=     NOT bpEinlaufSensor
                         AND NOT bpAuslaufSensor;

(* Hinweis:
   - Positions-Status des Antriebs
*)
IF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rDrehposition_0_Grad) < ppParameterBaustein.rToleranz )AND bpInReferenz THEN
  epDrehPositionsStatus := eDrehPosition0Grad;

ELSIF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rDrehposition_90_Grad) < ppParameterBaustein.rToleranz )AND bpInReferenz THEN
  epDrehPositionsStatus := eDrehPosition90Grad;

ELSIF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rDrehposition_180_Grad) < ppParameterBaustein.rToleranz )AND bpInReferenz THEN
  epDrehPositionsStatus := eDrehPosition180Grad;

ELSIF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rDrehposition_270_Grad) < ppParameterBaustein.rToleranz )AND bpInReferenz THEN
  epDrehPositionsStatus := eDrehPosition270Grad;

ELSE
  epDrehPositionsStatus := eDrehPositionUndefiniert;

END_IF
END_FUNCTION_BLOCK