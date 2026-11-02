(* METADATA
{
  "v3Meta": {
    "objectGuid": "1b8cd41b-c6ec-4747-8cfe-b17b04789a14"
  }
}
*)
FUNCTION_BLOCK Schnittstelle_Auslauflinie_Glaston_Koppler_FB  EXTENDS Basic_Schnittstelle_FB_V01_00_00

VAR_INPUT

  // BOOL
  bpAuftragsdatenVorhanden  : BOOL;

  // STRUCT 
  Auftragsdaten             : Schnittstelle_Auftragsdaten_ST; 

END_VAR
VAR_OUTPUT

 
END_VAR
VAR

  // BOOL
  bpDatenformatASCII                      : BOOL := TRUE;
  blLiveCounterGueltig                    : BOOL;
  blFehlermeldungGenerierenKommunikation  : BOOL;
  blFehlermeldungGenerierenAuftragsdaten  : BOOL;
  bpFehlerMeldungDeaktiviert              : BOOL := FALSE;
  
  // BYTE
  aOutByteLadeID             : ARRAY [0..15] OF BYTE; // Visualisierung: Lade-ID byteweise

  // WORD 
  wlVerbindungsVersuche      : WORD;
  wlLiveCounterSortJet       : WORD;
  wlLiveCounterFremdanlage   : WORD;
  wlTempEmpfaengerSignale    : WORD;
  wlTempSenderSignale        : WORD;
  wlOutSignale               : WORD;
  wlInSignale                : WORD;

  // DWORD
  dwlGeschwindigkeit         : DWORD;                   // Geschwindigkeit des Empfaengers [mm/s], ggf. geswappt
  adwlLadeID                 : ARRAY [0..3] OF DWORD;   // Lade-ID (= Scheiben-ID 1), ggf. geswappt

  // INT
  ilIndex                    : INT;

  // TRIGGER
  ftlGlasBereit                           : F_TRIG; // Hinweis: Glas-Sender besitzt noch einen aktiven Transport-Zustand 
  ftlFremdanlageDatenVerarbeitet          : F_TRIG;
  rtlFehlermeldungGenerierenAuftragsdaten : R_TRIG;
  rtlFehlermeldungGenerierenKommunikation : R_TRIG;


  // TIMER
  tonlZeitLiveCounterNichtAequivalent     : TON; 
  tonlZeitLiveCounterInkrementieren       : TON; 
  tonlZeitAuftragsdatenNichtAequivalent   : TON; 
  tonlManuellerModus                      : TON; 
  tonlAuftragdatenVorhanden               : TON;
  
  // STRING
  strScheibenID  : STRING;

  // REFERENZ
  stlVorgaenger  : REFERENCE TO StationBasisParameter_ST; // SortJet- Station vor der Schnittstelle (SF/SB)

  
END_VAR

VAR

  // STEPS
  steplStartIsolinie                                     : Steps_TE;

  // TRIGGER
  rtlAutomatik                                           : R_TRIG;
  rtlGlasAbruf                                           : R_TRIG;
  ftlGlasAbruf                                           : F_TRIG;

  // HARDWARE EINGAENGE KOPPLER (Hegla Schnittstellenbeschreibung V4.0, Empfaenger -> Sender)
  in_wEmpfaengerLiveCounter                     AT %I*   : WORD;                  // Wort 0     LC: gespiegelter LiveCounter
  in_awEmpfaengerLadeIDGespiegelt               AT %I*   : ARRAY [1..8] OF WORD;  // Wort 1..8  ID: gespiegelte Lade-ID
  in_wEmpfaengerSignale                         AT %I*   : WORD;                  // Wort 49    Signale
  in_dwEmpfaengerGeschwindigkeit                AT %I*   : DWORD;                 // Wort 50    GE: Geschwindigkeit [mm/s]
  in_wEmpfaengerRampe                           AT %I*   : WORD;                  // Wort 52    RA [Option]: Rampe [mm/s²], nur Anzeige

  in_bEmpfaengerAuftragsdatenErhalten                    : BOOL; // 49.0 AG
  in_bEmpfaengerBereitZumEintransport                    : BOOL; // 49.1 GA
  in_bEmpfaengerNothalt                                  : BOOL; // 49.3 NA  [Option] nur Anzeige
  in_bEmpfaengerAnforderungDurchgangOeffnen              : BOOL; // 49.4 ADO [Option] nur Anzeige
  in_bEmpfaengerQuittungDurchgangOeffnen                 : BOOL; // 49.5 ADQ [Option] nur Anzeige
  in_bEmpfaengerStationFrei                              : BOOL; // 49.6 SF  [Option]
  in_bEmpfaengerStationBeladen                           : BOOL; // 49.7 SB  [Option]
  in_bEmpfaengerUebernahmeposition                       : BOOL; // 49.8 UP  [Option] nur Anzeige

  // HARDWARE AUSGAENGE KOPPLER (Hegla Schnittstellenbeschreibung V4.0, Sender -> Empfaenger)
  out_wSenderLiveCounter                     AT %Q*      : WORD;                  // Wort 0     LC: LiveCounter
  out_awSenderLadeID                         AT %Q*      : ARRAY [1..8] OF WORD;  // Wort 1..8  ID: Lade-ID (16 ASCII- Zeichen)
  out_wSenderSignale                         AT %Q*      : WORD;                  // Wort 50    Signale

  out_bSenderAuftragdatenVorhanden                       : BOOL; // 50.0 AV
  out_bSenderAuftragdatenPlausibel                       : BOOL; // 50.1 AP
  out_bSenderManuelleBeladung                            : BOOL; // 50.2 HB [Option] SortJet sendet immer mit Lade-ID
  out_bSensorAuslauf                                     : BOOL; // 50.6 SA [Option]
  out_bSenderStationFrei                                 : BOOL; // 50.7 SF [Option] Vorgaengerstation frei
  out_bSenderStationBeladen                              : BOOL; // 50.8 SB [Option] Vorgaengerstation belegt
  out_bSenderForm                                        : BOOL; // 50.9 FG [Option] Scheibe ist ein Modell

END_VAR
VAR CONSTANT

  // WORD
  cVERBINDUNGSVERSUCHE_BIS_FEHLER  : WORD := 5;         // WICHTIG: Aenderung an diesem Wert veraendert das Verhalten ab wieviel Kommunikations-Versuchen wann ein Fehler ausgegeben wird
  
  // INT
  cWERTEBREICH_INT                 : INT  := 32767; // WICHTIG: Aenderung an diesem Wert aendert den Wertebereich eines INTs [positiver Wertebereich]
  cWERTEBREICH_WORD                : WORD := 32767; // WICHTIG: Aenderung an diesem Wert aendert den Wertebereich eines INTs [positiver Wertebereich]

  // TIME
  cZEIT_AUFTRAGSDATEN_GUELTIG                : TIME :=T#5s;         // WICHTIG: Aenderung an diesem Wert aendert die Zeit ab wann ein Fehlergeneriert wird [s]
  cZEIT_GESPIEGELTE_AUFTRAGSDATEN_UNGUELTIG  : TIME :=T#5s;         // WICHTIG: Aenderung an diesem Wert aendert die Zeit ab wann ein Fehlergeneriert wird [s]
  cZEIT_MANUELLER_MODUS_SIGNAL               : TIME :=T#10s;
  cZEIT_LIVECOUNTER_INKREMENTIEREN           : TIME :=T#250ms;
  cZEIT_LIVECOUNTER_NICHT_GUELTIG            : TIME :=T#1500ms;

END_VAR
//-------------------------------------------------------------------------------------------------
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
SUPER^(BasisStationsParameter := BasisStationsParameter);

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus  ) THEN
  blErsterZyklus := FALSE;

  bpAuftragsdatenVorhanden      := FALSE;
  AuftragsSpeicher.bpAktivieren := TRUE;
    
END_IF

//-------------------------------------------------------------------------------------------------
// TIMER
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Zeitlicheueberwachung der Kommunikation
*)
tonlZeitLiveCounterNichtAequivalent( IN := NOT blLiveCounterGueltig,
                                     PT := cZEIT_LIVECOUNTER_NICHT_GUELTIG );


//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
LiveCounter();
Meldungen();
AuftragsdatenVerwaltung();
Auswertung();
Signalverarbeitung();
M_GeschwindigkeitGlaetten( rpMindestGeschwindigkeitsAenderung   := BasisStationsParameter.stMKs.stFremdanlage.rMindestGeschwindigkeitsAenderung,
                           tpMindestZeitZwischenGeschwAenderung := BasisStationsParameter.stMKs.stFremdanlage.tMindestZeitZwischenGeschwAenderung );
Status_ISO_Linie();

IF BasisStationsParameter.stMKs.stFremdanlage.bSignaleLoggen THEN
  Signal_Logger();
END_IF

//-------------------------------------------------------------------------------------------------
// RESET
//-------------------------------------------------------------------------------------------------
// Fehlverhalten:
//   - Anstehenden Fehler zuruecksetzen
IF ( BasisStationsParameter.bReset ) THEN

  out_bSenderAuftragdatenPlausibel := FALSE;
  out_bSenderAuftragdatenVorhanden := FALSE;

  bpAuftragsdatenVorhanden               := FALSE;
  blFehlermeldungGenerierenKommunikation := FALSE;
  blFehlermeldungGenerierenAuftragsdaten := FALSE;

  BasisStationsParameter.bReset := FALSE;

  // TODO   
  Auftragsdaten.wScheibenAnzahl := 0;
  Auftragsdaten.stScheibenID.adwScheibenID_1[0] := 0;
  Auftragsdaten.stScheibenID.adwScheibenID_1[1] := 0;
  Auftragsdaten.stScheibenID.adwScheibenID_1[2] := 0;
  Auftragsdaten.stScheibenID.adwScheibenID_1[3] := 0;

END_IF


//-------------------------------------------------------------------------------------------------
// Aufrufe
//-------------------------------------------------------------------------------------------------
Horn( bpAktiv := bgHornAktivieren );
END_FUNCTION_BLOCK