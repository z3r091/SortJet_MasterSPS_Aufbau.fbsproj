(* METADATA
{
	"v3Meta": {
		"objectGuid": "887b7e5f-63a1-4543-befe-d3acd4ce4d49"
	}
}
*)
{attribute 'excludefrombuild'}
FUNCTION_BLOCK Schnittstelle_Einlauf_HeglaBrechanlage_FB
VAR_INPUT

  // BOOL
  bpStarteReset                 : BOOL;
  bpAnforderungSK               : BOOL;

  // STRUCT
  InGlasTransportNachfolger     : Interface_GlasTransport;
  stStationsNummern             : Station_ST;

  // POINTER
  ppParameterBaustein : REFERENCE TO Parameter_Schnittstelle;

END_VAR
VAR_OUTPUT

  // STRUCT
  OutGlasTransport : Interface_GlasTransport; // STRUKTUR: Informationen ueber den Aus- Ein- Transport WAND 1

END_VAR
VAR

  // BOOL
  blErsterZyklus          : BOOL := TRUE;

  // TIMER
  tonlMeldungGenerierenGLassenderNichtBereit : TON;// EINSCHALTVERZOEGERUNG

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bGlasBereit                AT %I* : BOOL; // Glas auf Brechanlage bereit zum Austransport
  in_bFreigabeSK                AT %I* : BOOL; // Freigabe zum SK 2 öffnen
  in_bAnlageEingeschaltet       AT %I* : BOOL; // Signal zum Zustand der Brechanlage, ob Eingeschaltet oder nicht
  in_bSensorAuslauf             AT %I* : BOOL; // Auslaufsensor (letzter Sensor vor Übergabe) der Brechanlage
  in_bBypassMode                AT %I* : BOOL; // ByPass an Brechanlage aktiv: Übergroße Scheiben für die Brechanlage müssen ohne Analogwert gefahren werden ; Festgesetzte Geschw. 20m/min zwischen Brechanlage und SortJet

  // HARDWARE AUSGAENGE
  out_bGlasAbruf                AT %Q* : BOOL; // Glas Abruf zur Brechanlage, sofern Glas Bereit ist
  out_bAnforderungSK            AT %Q* : BOOL; // Anforderung zum öffnen des 2. SK - Brechanlage muss in sichere Stop-Position fahren und freigeben
  out_bSensorEinlauf            AT %Q* : BOOL; // Erster Sensor am RKT
  out_bReserve                  AT %Q* : BOOL; // Optional
  
  out_wSpeed                    AT %Q* : WORD;

END_VAR
IF ( blErsterZyklus ) THEN
  blErsterZyklus:=FALSE;

  (* Wichtig:
     - Pointer Initialisieren [Null-Pointer-Exception]
  *)
  InGlasTransportNachfolger  := NullReferenzGlasTransport;
  OutGlasTransport           := NullReferenzGlasTransport;

  (* Hinweis:
     - Basis- Pointer uebergeben
  *)
  ppParameterBaustein  := ADR( apgMKSchnittstelle_Einlauflinie[stStationsNummern.NummerSPS]);

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: SCHNITTSTELLE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Abhandlung des Ein-Aus- Transports [Setzen der Variablen das man bereit ist zum Glastransport]
*)
OutGlasTransport.stStationsNummern      := stStationsNummern;
OutGlasTransport.wStationsTyp           := eFremdanlage;
OutGlasTransport.bEinlaufsensor         := ADR(bgFALSE);
OutGlasTransport.bAuslaufsensor         := ADR(in_bSensorAuslauf);
OutGlasTransport.bBereitZumAustransport := ADR(in_bGlasBereit);
OutGlasTransport.bBereitZumEintransport := ADR(bgFALSE);
OutGlasTransport.bFehler                := ADR(bgFALSE);
OutGlasTransport.rGeschwindigkeit       := ADR(rgNull);




//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------

CASE ppParameterBaustein.eTypSchnittstelle OF

  eHEGLA_BREAK:
    HeglaBrechanlage_Schnittstelle();

END_CASE

// Aktion:
//   - Reset
Reset();


//-------------------------------------------------------------------------------------------------
// BAUSTEIN: MELDUNGEN
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Meldungs Sender nicht bereit
*)
tonlMeldungGenerierenGLassenderNichtBereit( IN :=  InGlasTransportNachfolger.AND NOT in_bGlasBereit,
                                            PT :=  t#30s );

WatchIo( tonlMeldungGenerierenGLassenderNichtBereit.Q , ( ppParameterBaustein.wMeldungsNummer ) );
END_FUNCTION_BLOCK