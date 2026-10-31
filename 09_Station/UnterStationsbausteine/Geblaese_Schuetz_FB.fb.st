(* METADATA
{
  "v3Meta": {
    "objectGuid": "c9895c16-daf8-42f8-8f64-ac96a02bd793"
  }
}
*)
FUNCTION_BLOCK Geblaese_Schuetz_FB
VAR_INPUT

  // BOOLEAN
  bpAktivieren              : BOOL;
  bpStart                   : BOOL;
  bpReset                   : BOOL;
  bpFreigabe                : BOOL;
  bpTeilnehmerErreichbar    : BOOL := TRUE;
  bpIOsBoschDrive               : BOOL;

  // EINGÄNGE
  bpMotorschutzschalter_OK  : BOOL; 

  // STRUKT
  stStationsNummern       : Station_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFehler                 : BOOL;
  bpDone                   : BOOL;
  bpStarteGeblaese         : BOOL;

  // WORD 
  wpFehlerNr : WORD;

END_VAR
VAR

  // BOOLEAN 
  blErsterZyklus           : BOOL := TRUE; // Initialisierung
  blMeldungAbgesetzt       : BOOL := FALSE;
  blMotorschutzschalter_OK : BOOL;

  // ARRAY 
  awlErrorAdditional : ARRAY [0..25]  OF WORD;

  (* STEPS *)
  steplStart      : Steps_TE;

  // TIMER
  tonlStartGeblaese          : TON; 
  tonlWarteAufGeblaeseLaeuft : TON; 
  toflWarteAufWiederAnlauf   : TOF; 
  toflMotorschutz            : TOF;

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bMotorschutzschalter_OK    AT %I* : BOOL; 
  
  // HARDWARE AUSGAENGE 
  out_bStarteGeblaese           AT %Q* : BOOL;

END_VAR

VAR CONSTANT

  // TIME 
  WARTEZEIT_BIS_WIEDERANLAUF          : TIME := T#7000MS;
  WARTEZEIT_BIS_GEBLAESE_HOCHGELAUFEN : TIME := T#2000MS;

END_VAR

(***************************************************************************************************)
(* BAUSTEIN: INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN
  blErsterZyklus:=FALSE;

  (* Hinweis:
     - Timer initialisieren
  *)
  toflWarteAufWiederAnlauf(IN:=FALSE);
  tonlWarteAufGeblaeseLaeuft(IN:=FALSE);

END_IF
// IO Zuweisung
IF ( bpIOsBoschDrive ) THEN
  blMotorschutzschalter_OK  := bpMotorschutzschalter_OK;
  bpStarteGeblaese          := out_bStarteGeblaese;
ELSE
  blMotorschutzschalter_OK  := in_bMotorschutzschalter_OK;
END_IF


(***************************************************************************************************)
(* BAUSTEIN: DEAKTIVIEREN *)
(***************************************************************************************************)
IF ( NOT bpAktivieren ) THEN
  bpDone     := TRUE;
  bpFehler   := FALSE;
  wpFehlerNr := 0;

  RETURN;

END_IF


(***************************************************************************************************)
(* BAUSTEIN: TIMER *)
(***************************************************************************************************)
toflWarteAufWiederAnlauf(IN :=     out_bStarteGeblaese,
                         PT := WARTEZEIT_BIS_WIEDERANLAUF);

tonlWarteAufGeblaeseLaeuft(IN :=     out_bStarteGeblaese,
                           PT := WARTEZEIT_BIS_GEBLAESE_HOCHGELAUFEN );

toflMotorschutz( IN := blMotorschutzschalter_OK, PT := T#5S );

(* Hinweis:
   - Einschaltverzoegerung
*)
tonlStartGeblaese(IN :=     bpStart
                        AND bpFreigabe
                        AND NOT toflWarteAufWiederAnlauf.Q
                        AND NOT bpReset,
                  PT := T#0S);



(***************************************************************************************************)
(* BAUSTEIN: STEUERUNG *)
(***************************************************************************************************)
IF ( bpReset ) THEN

  bpStart   := FALSE;
  bpDone    := FALSE;
  bpReset   := FALSE;
  bpFehler  := FALSE;

  blMeldungAbgesetzt := FALSE;

  wpFehlerNr := cMELDUNG_NULL;

  out_bStarteGeblaese := FALSE;

ELSE
  Start();
  Meldungen();

END_IF
END_FUNCTION_BLOCK