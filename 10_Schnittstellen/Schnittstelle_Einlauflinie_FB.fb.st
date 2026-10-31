(* METADATA
{
  "v3Meta": {
    "objectGuid": "583875e0-db52-49ee-af9c-0f6353b622c9"
  }
}
*)
{attribute 'excludefrombuild'}
FUNCTION_BLOCK Schnittstelle_Einlauflinie_FB
VAR_INPUT

  (* BOOLEAN *)
  bpReset                         : BOOL;
  bpAktivieren                    : BOOL := TRUE;
  bpSortierungInAutomatik         : BOOL; (* [STATUS] Status der Sortierung -> Automatikbetrieb *)
  bpNotHaltAusgeloest              : BOOL := FALSE;
  bpDatenformatASCII              : BOOL := TRUE;

  (* STRUCT *)
  InGlasTransport    : Interface_GlasTransport;        (* STRUKTUR: Informationen ueber den Aus- Ein- Transport WAND 1 *)
  Auftragsdaten      : Schnittstelle_Auftragsdaten_ST; (* STRUKTUR: Auftragsdaten fuer die Fremdanlage [ScheibenID , Auftragsnummer , etc. ]*)
  stStationsNummern  : Station_ST;

  (* POINTER *)
  ppParameterBaustein : REFERENCE TO Parameter_Schnittstelle;

END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpFehler      : BOOL;

  (* STRUCT *)
  OutGlasTransport   : Interface_GlasTransport; (* STRUKTUR: Informationen ueber den Aus- Ein- Transport WAND 1 *)


END_VAR
VAR

  (* BOOLEAN *)
  blErsterZyklus                          : BOOL := TRUE;  (* Initialisierung *)
  blAuftragAktiv                          : BOOL := FALSE;
  blFehlermeldungGenerierenKommunikation  : BOOL;
  blFremdanlageBereitZumTransport         : BOOL := FALSE;
  blAuftragsdatenNachrichtGenerieren      : BOOL;

  (* BYTE *)
  aInByteAuftragsdatenScheibenID_1_0     : ARRAY [0..3] OF BYTE;
  aInByteAuftragsdatenScheibenID_1_1     : ARRAY [0..3] OF BYTE;
  aInByteAuftragsdatenScheibenID_1_2     : ARRAY [0..3] OF BYTE;
  aInByteAuftragsdatenScheibenID_1_3     : ARRAY [0..3] OF BYTE;
  aInByteSwapAuftragsdatenScheibenID_1_0 : ARRAY [0..3] OF BYTE;
  aInByteSwapAuftragsdatenScheibenID_1_1 : ARRAY [0..3] OF BYTE;
  aInByteSwapAuftragsdatenScheibenID_1_2 : ARRAY [0..3] OF BYTE;
  aInByteSwapAuftragsdatenScheibenID_1_3 : ARRAY [0..3] OF BYTE;

  (* WORD *)
  wlMerkerLiveCounterSender             : WORD;
  wlLiveCounterSender                   : WORD;

  (* INT *)
  ilIndex  : INT;

  (* DWORD *)
  aInDWordAuftragsdatenScheibenID : ARRAY [0..3] OF DWORD;

  (* STRING *)
	strScheibenID : STRING;

  (* TRIGGER *)
  rtlAutomatikActiv                       : R_TRIG; 
  rtlFehlermeldungGenerierenKommunikation : R_TRIG;
  rtlAuftragsdatenPlausibel               : R_TRIG;
  ftlAuftragsdatenVorhanden               : F_TRIG;

  (* TIMER *)
  tonlUeberwachungLiveCounter            : TON; (* EINSCHALTVERZOEGERUNG *)

END_VAR
VAR

  (* HARDWARE EINGAENGE *)
  in_stSenderAuftragsdaten                      AT %I* : Schnittstelle_ScheibenIDs;  (* HINWEIS: PROFIBUS- Schnittstelle *)
  in_wSenderLiveCounter                         AT %I* : WORD;
  in_bSenderAuftragdatenVorhanden               AT %I* : BOOL; (* HINWEIS: PROFIBUS- Schnittstelle *)
  in_bsenderAuftragdatenPlausibel               AT %I* : BOOL; (* HINWEIS: PROFIBUS- Schnittstelle *)
  in_bSenderBereit                              AT %I* : BOOL; (* HINWEIS: PROFIBUS- Schnittstelle *)
  in_bSenderGlasBereit                          AT %I* : BOOL; (* HINWEIS: PROFIBUS- Schnittstelle -> Glas bereit zum Eintransport [Sortierung zur Fremdanlage] *)
  in_bSenderSensorAuslauf                       AT %I* : BOOL; (* HINWEIS: SPS- Eingang des Sensors auf die PROFIBUS- Schnittstelle schreiben [Sortierung zur Fremdanlage] *)
  in_bSenderScheibeManuellAnlegen               AT %I* : BOOL; (* HINWEIS: PROFIBUS- Schnittstelle *)
  in_wSenderAnzahlScheiben                      AT %I* : WORD := 0;

  (* HARDWARE AUSGAENGE *)
  out_wEmpfaengerLiveCounter                    AT %Q* : WORD; (* HINWEIS: ANYBUS - Schnittstelle *)
  out_stEmpfaengerAuftragsdatenGespiegelt       AT %Q* : Schnittstelle_ScheibenIDs; (* HINWEIS: PROFIBUS- Schnittstelle *)
  out_bEmpfaengerAuftragsdatenErhalten          AT %Q* : BOOL; (* HINWEIS: PROFIBUS- Schnittstelle *)
  out_bEmpfaengerGlasAbruf                      AT %Q* : BOOL;
  out_bEmpfaengerSensorEinlauf                  AT %Q* : BOOL;
  out_bEmpfaengerNotHaltAusgeloest               AT %Q* : BOOL;
  out_rEmpfaengerGeschwindigkeit                AT %Q* : REAL := REAL#0;
  out_bEmpfaengerBetriebsbereit                        : BOOL; 
  out_bEmpfaengerGlasuebernommen                       : BOOL; 

END_VAR
VAR CONSTANT

  (* TIME *)
  cZEIT_UEBERWACHUNG_LIVECOUNTER    : TIME :=T#5s; (* WICHTIG: Aenderung an diesem Wert aendert die Zeit ab wann ein Fehlergeneriert wird [s] *)

END_VAR
(* HINWEIS:
   - Dieser Baustein bildet das Interface zu einer Fremdanlage
     => Verarbeitung der Signale [ Bereit zum Eintransport | Bereit zum Austransport ] 
        
*)

(***************************************************************************************************)
(* BAUSTEIN: INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus  ) THEN
  blErsterZyklus := FALSE;

  (* Hinweis[OPTIONAL]:
     - Auftragsdaten nullen
  *)
  out_stEmpfaengerAuftragsdatenGespiegelt := NullReferenzAuftragsdatenFremdanlage.stScheibenID;

  (* WICHTIG:
     - Pointer Initialisieren [Null-Pointer-Exception] 
  *)
  InGlasTransport := NullReferenzGlasTransport;

  (* Hinweis:
     - Basis- Pointer uebergeben
  *)
  ppParameterBaustein  := ADR( apgMKSchnittstelle_Einlauflinie[stStationsNummern.NummerSPS]);

END_IF




(***************************************************************************************************)
(* SCHNITTSTELLE *)
(***************************************************************************************************)
(* Hinweis:
   - Abhandlung des Ein-Aus- Transports [Setzen der Variablen das man bereit ist zum Glastransport]
*)
OutGlasTransport.stStationsNummern      := stStationsNummern;
OutGlasTransport.wStationsTyp           := eFremdanlage;
OutGlasTransport.bEinlaufsensor         := ADR( bgFalse );
OutGlasTransport.bAuslaufsensor         := ADR( in_bSenderSensorAuslauf );
OutGlasTransport.bBereitZumAustransport := ADR( blFremdanlageBereitZumTransport );
OutGlasTransport.bBereitZumEintransport := ADR( blFremdanlageBereitZumTransport );
OutGlasTransport.rGeschwindigkeit       := ADR( rgMkAutoGeschwindigkeitFremdanlage );
OutGlasTransport.bFehler                := ADR( bpFehler );




(***************************************************************************************************)
(* Deaktivierung *)
(***************************************************************************************************)
IF ( NOT bpAktivieren ) THEN
  RETURN;
END_IF




(***************************************************************************************************)
(* SIGNALVERARBEITUNG [HARDWARE EIN- AUS- GAENGE | ETC. ] *)
(***************************************************************************************************)
(* Hinweis:
   - Signal das der Sender bereit fuer den Transport ist 
*)
blFremdanlageBereitZumTransport := (     in_bSenderBereit
                                     AND in_bSenderGlasBereit );


(* Hinweis:
   - Glas Abrufen von der Fremdanlage
*)
out_bEmpfaengerGlasAbruf := (         InGlasTransport.bBereitZumEintransport^
                              AND NOT bgVisu_Schnittstelle_Force_EmpfaengerFreiInGlasTransport.bFehler^ );



(* Hinweis:
   - Geschwindigkeit 
*)
out_rEmpfaengerGeschwindigkeit := InGlasTransport.rGeschwindigkeit;



(* Hinweis:
   - Der Auslaufsensor der Vorgaengerstation uebergeben
*)
out_bEmpfaengerSensorEinlauf := InGlasTransport.bEinlaufsensor;



(* Hinweis:
   - NotAus 
*)
out_bEmpfaengerNotHaltAusgeloest := bpNotHaltAusgeloest;



(***************************************************************************************************)
(* AKTIONEN *)
(***************************************************************************************************)
(* Hinweis:
   - Baustein-Aktionen
*)
LiveCounter();
Ausnahmesituation();
AuftragsdatenVerwaltung();
Auswertung();



(***************************************************************************************************)
(*  RESET *)
(***************************************************************************************************)
(* Fehlverhalten:
   - Anstehenden Fehler zuruecksetzen
*)
IF ( bpReset ) THEN

  bpFehler       := FALSE;
  blAuftragAktiv := FALSE;

  blFehlermeldungGenerierenKommunikation := FALSE;

  bpReset := FALSE;

END_IF
END_FUNCTION_BLOCK