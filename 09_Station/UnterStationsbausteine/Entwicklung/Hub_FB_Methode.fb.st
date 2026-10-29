(* METADATA
{
	"v3Meta": {
		"objectGuid": "edcc4463-460d-49b8-9b6c-0b51cf9d081d"
	}
}
*)
{attribute 'excludefrombuild'}
FUNCTION_BLOCK Hub_FB_Methode
VAR_INPUT

  // BOOLEAN
  bpAktivieren               : BOOL; 
  bpStartHubAuf              : BOOL;
  bpStartHubAb               : BOOL;
  bpReset                    : BOOL;
  bpSensorEinlaufNachfolger  : BOOL; 
  bpSensorAuslaufVorgaenger  : BOOL; 
  bpSensorEinlauf            : BOOL; 
  bpSensorAuslauf            : BOOL;

  // STRUCT
  stStationsNummern          : Station_ST;

  // POINTER *)
  //ppParameterBaustein        : REFERENCE TO Parameter_Hub; // Zeiger auf Parameterfeld

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFehler        : BOOL;
  bpDone          : BOOL;
  bpResourceAktiv : BOOL;

  // WORD
  wpFehlerNr : Fehlerkonstanten_EN;

  // ENUM 
  epHubStatus  : Hub_EN; // Status: Gibt die Aktuelle Position des Antriebs aus

END_VAR

VAR

  // BOOLEAN 
  blErsterZyklus        : BOOL := TRUE;

  // TIMER
  tonlMaxWarteZeit                        : TON;
  tonlHubAntriebOK                        : TON;
  tonlMaximaleWartezeitAufReset           : TON;
  tonlFehlermeldungUnterdrueckenAntriebOK : TON;
  tonlReset                               : TON;


  // TRIGGER
  ftrigFehlerAmSteuerteil : F_TRIG;


  // STEPS
  steplHubAb    : Steps_TE;
  steplHubAuf   : Steps_TE;
  steplReset    : Steps_TE;
  
  Motorstarter : Motorstarter_FB;

END_VAR

VAR
  // HARDWARE EINGÄNGE 
  in_bSensorNichtUnten             AT%I* : BOOL;
  in_bSensorNichtOben              AT%I* : BOOL;
  in_bMotorstarter_OK              AT%I* : BOOL; 
  in_bLSBremse_OK                  AT%I* : BOOL; 
  in_bLS400V_OK                    AT%I* : BOOL; 

  // HARDWARE AUSGÄNGE
  out_bHubAbSetzen                 AT%Q* : BOOL;
  out_bHubAufSetzen                AT%Q* : BOOL;
  out_bReset                       AT%Q* : BOOL;
  out_bBremseLoesen                AT%Q* : BOOL;

END_VAR

VAR CONSTANT

  // TIME 
  ZEITWERT_RESOURCE_AKTIV_AUSSCHALT_VERZOEGERN : TIME := T#25ms;

END_VAR

(***************************************************************************************************)
(* BAUSTEIN: INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN
  blErsterZyklus := FALSE;

  (* Hinweis:
     - Timer initialisieren
  *)
  tonlHubAntriebOK(IN:=TRUE);
  tonlMaxWarteZeit(IN:=FALSE);
  tonlFehlermeldungUnterdrueckenAntriebOK( IN := FALSE );


END_IF



(***************************************************************************************************)
(* BAUSTEIN: AKTIONEN *)
(***************************************************************************************************)
IF ( bpAktivieren ) THEN
  Motorstarter();

  IF bpReset THEN
    wpFehlerNr := cMELDUNG_NULL;
    bpFehler   := FALSE;
    Motorstarter.Reset();
	
  ELSIF bpFehler THEN
	  ;
  
  ELSIF bpStartHubAuf THEN
    bpDone := Motorstarter.Linkslauf();
	
  ELSIF  bpStartHubAb THEN
    bpDone := Motorstarter.Rechtslauf();
	
  END_IF

  Ausgaenge();
  Meldungen();
  Timer();

ELSE

  bpDone   := TRUE;
  bpFehler := FALSE;

  IF (bpStartHubAb AND NOT bpStartHubAuf) THEN
    epHubStatus := eHub_Unten;
  ELSIF (bpStartHubAuf AND NOT bpStartHubAb) THEN
    epHubStatus := eHub_Oben;
  ELSIF (bpStartHubAb AND NOT bpStartHubAuf) THEN
    epHubStatus := eHub_Undefiniert;
  END_IF

END_IF
END_FUNCTION_BLOCK