(* METADATA
{
	"v3Meta": {
		"objectGuid": "1b8cd41b-c6ec-4747-8cfe-b17b04789a14"
	}
}
*)
FUNCTION_BLOCK Schnittstelle_Auslauflinie_Glaston_Koppler_FB  EXTENDS Basic_Schnittstelle_FB

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
  blAuftragdatenPlausibel                 : BOOL;
  blFehlermeldungGenerierenKommunikation  : BOOL;
  blFehlermeldungGenerierenAuftragsdaten  : BOOL;
  bpFehlerMeldungDeaktiviert              : BOOL := TRUE;
  
  // BYTE
  aOutByteAuftragsdatenScheibenID_1_0 : ARRAY [0..3] OF BYTE;
  aOutByteAuftragsdatenScheibenID_1_1 : ARRAY [0..3] OF BYTE;
  aOutByteAuftragsdatenScheibenID_1_2 : ARRAY [0..3] OF BYTE;
  aOutByteAuftragsdatenScheibenID_1_3 : ARRAY [0..3] OF BYTE;

  // WORD 
  wlVerbindungsVersuche      : WORD;
  wlLiveCounterSortJet       : WORD;
  wlLiveCounterFremdanlage   : WORD;
  wlTempEmpfaengerSignale    : WORD;
  wlTempSenderSignale        : WORD;
  wlOutSignale               : WORD;
  wlInSignale                : WORD;

  (* DWORD *)
  dwlGeschwindigkeit         : DWORD;

  (* INT *)
  ilIndex                    : INT;

  (* TRIGGER *)
  ftlGlasBereit                           : F_TRIG; // Hinweis: Glas-Sender besitzt noch einen aktiven Transport-Zustand 
  ftlFremdanlageDatenVerarbeitet          : F_TRIG;
  rtlFehlermeldungGenerierenAuftragsdaten : R_TRIG;
  rtlFehlermeldungGenerierenKommunikation : R_TRIG;
	

  (* TIMER *)
  tonlZeitLiveCounterNichtAequivalent     : TON; 
  tonlZeitLiveCounterInkrementieren       : TON; 
  tonlZeitAuftragsdatenNichtAequivalent   : TON; 
  tonlManuellerModus                      : TON; 
  tonlAuftragdatenVorhanden               : TON;
  
  (*  STRING *)
  strScheibenID  : STRING;

  
END_VAR

VAR

  // STEPS
  steplStartIsolinie                                     : Steps_TE;

  // TRIGGER
  rtlAutomatik                                           : R_TRIG;
  rtlGlasAbruf                                           : R_TRIG;
  ftlGlasAbruf                                           : F_TRIG;

  // HARDWARE EINGAENGE KOPPLER
  in_stEmpfaengerAuftragsdatenGespiegelt        AT %I*   : Schnittstelle_ScheibenIDs; // Buskoppler Signale 
  wlMerkerAuftragsdatenGespiegeltIn                      : Schnittstelle_ScheibenIDs;
  in_wEmpfaengerLiveCounter                     AT %I*   : WORD; // Buskoppler Signale
  in_wEmpfaengerSignale                         AT %I*   : WORD; // Buskoppler Signale
  in_rEmpfaengerGeschwindigkeit                 AT %I*   : REAL; // Buskoppler Signale

  in_bEmpfaengerInAutomatik                              : BOOL; // Buskoppler Signale 
  in_bEmpfaengerBereitZumEintransport                    : BOOL; // Buskoppler Signale
  in_bEmpfaengerAuftragsdatenErhalten                    : BOOL; // Buskoppler Signale
  in_bEmpfaengerStationFrei                              : BOOL; // Buskoppler Signale 
  in_bEmpfaengerStationBeladen                           : BOOL; // Buskoppler Signale

  // HARDWARE AUSGAENGE KOPPLER
  out_stSenderAuftragsdaten                  AT %Q*      : Schnittstelle_ScheibenIDs; // Buskoppler Signale  
  out_wSenderLiveCounter                     AT %Q*      : WORD; // Buskoppler Signale
  out_wSenderAnzahlScheiben                  AT %Q*      : WORD; // Buskoppler Signale
  out_wSenderSignale                         AT %Q*      : WORD; // Buskoppler Signale

  out_bSenderAuftragdatenVorhanden                       : BOOL; // Buskoppler Signale
  out_bSenderAuftragdatenPlausibel                       : BOOL; // Buskoppler Signale
  out_bSensorAuslauf                                     : BOOL; // Buskoppler Signale
  
END_VAR
VAR CONSTANT

  (* WORD *)
  cVERBINDUNGSVERSUCHE_BIS_FEHLER  : WORD := 5; 	    (* WICHTIG: Aenderung an diesem Wert veraendert das Verhalten ab wieviel Kommunikations-Versuchen wann ein Fehler ausgegeben wird  *)
  
  (* INT *)
  cWERTEBREICH_INT                 : INT  := 32767;	(* WICHTIG: Aenderung an diesem Wert aendert den Wertebereich eines INTs [positiver Wertebereich] *)
  cWERTEBREICH_WORD                : WORD := 32767;	(* WICHTIG: Aenderung an diesem Wert aendert den Wertebereich eines INTs [positiver Wertebereich] *)

  (* TIME *)
  cZEIT_AUFTRAGSDATEN_GUELTIG                : TIME :=T#5s; 	    (* WICHTIG: Aenderung an diesem Wert aendert die Zeit ab wann ein Fehlergeneriert wird [s] *)
  cZEIT_GESPIEGELTE_AUFTRAGSDATEN_UNGUELTIG  : TIME :=T#5s; 	    (* WICHTIG: Aenderung an diesem Wert aendert die Zeit ab wann ein Fehlergeneriert wird [s] *)
  cZEIT_MANUELLER_MODUS_SIGNAL               : TIME :=T#10s;
  cZEIT_LIVECOUNTER_INKREMENTIEREN           : TIME :=T#250ms;
  cZEIT_LIVECOUNTER_NICHT_GUELTIG            : TIME :=T#1500ms;

END_VAR
(***************************************************************************************************)
(* MASTER AUFRUFEN *)
(***************************************************************************************************)
SUPER^(BasisStationsParameter := BasisStationsParameter);

(***************************************************************************************************)
(* BAUSTEIN: INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus  ) THEN
  blErsterZyklus := FALSE;

  bpAuftragsdatenVorhanden      := FALSE;
  AuftragsSpeicher.bpAktivieren := TRUE;
    
END_IF

(***************************************************************************************************)
(*  TIMER *)
(***************************************************************************************************)
(* Hinweis:
   - Zeitlicheueberwachung der Kommunikation
*)
tonlZeitLiveCounterNichtAequivalent( IN := NOT blLiveCounterGueltig,
                                     PT := cZEIT_LIVECOUNTER_NICHT_GUELTIG );


(***************************************************************************************************)
(* AKTIONEN *)
(***************************************************************************************************)
LiveCounter();
Meldungen();
AuftragsdatenVerwaltung();
Auswertung();
Signalverarbeitung();
M_GeschwindigkeitGlaetten();
Status_ISO_Linie();

IF BasisStationsParameter.stMKs.stFremdanlage.bSignaleLoggen THEN
  Signal_Logger();
END_IF

(***************************************************************************************************)
(*  RESET *)
(***************************************************************************************************)
(* Fehlverhalten:
   - Anstehenden Fehler zuruecksetzen
*)
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


(***************************************************************************************************)
(*  Aufrufe *)
(***************************************************************************************************)
Horn( bpAktiv := bgHornAktivieren );
END_FUNCTION_BLOCK