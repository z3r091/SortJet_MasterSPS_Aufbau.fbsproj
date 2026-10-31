(* METADATA
{
  "v3Meta": {
    "objectGuid": "2c7452d1-eabd-4c4a-95fd-5aca04df1ee1"
  }
}
*)
FUNCTION_BLOCK Dickenverstellung_Schuetz_FB
VAR_INPUT

  // BOOL
  bpAktivieren               : BOOL;
  bpVerstellungOeffnen       : BOOL;
  bpVerstellungSchliessen    : BOOL;
  bpReset                    : BOOL;

END_VAR
VAR_OUTPUT

  // BOOL
  bpFehler        : BOOL;
  bpDone          : BOOL;
  bpResourceAktiv : BOOL;

  // WORD 
  wpFehlerNr      : WORD;

END_VAR

VAR

  // BOOL
  blErsterZyklus        : BOOL := TRUE;

  // TIMER
  tonlMaxWarteZeit                        : TON;
  tonlAntriebOK                           : TON;
  tonlMaximaleWartezeitAufReset           : TON;
  tonlFehlermeldungUnterdrueckenAntriebOK : TON;

  // STEPS 
  steplVerstellungOeffnen      : Steps_TE;
  steplVerstellungSchliessen   : Steps_TE;
  steplReset                   : Steps_TE;

END_VAR

VAR
  // HARDWARE EINGÄNGE
  in_bVerstellungGeoeffnet         AT %I* : BOOL;
  in_bVerstellungGeschlossen       AT %I* : BOOL;
  in_bMotorstarter_OK              AT %I* : BOOL; (* Sicherung des Kippantriebs ÖFFNER KONTAKT !! *)
  in_bBremseOK                     AT %I* : BOOL; (* Sicherung des Kippantriebs ÖFFNER KONTAKT !! *)
  in_bSicherungMotorOK             AT %I* : BOOL;
  
  // HARDWARE AUSGÄNGE 
  out_bVerstellungSchliessen       AT %Q* : BOOL;
  out_bVerstellungOeffnen          AT %Q* : BOOL;
  out_bBremseOeffnen               AT %Q* : BOOL;
  out_bMotorstarterReset           AT %Q* : BOOL;

END_VAR

(***************************************************************************************************)
(* BAUSTEIN: INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN
  blErsterZyklus := FALSE;

  (* Hinweis:
     - Timer initialisieren
  *)
  tonlAntriebOK(IN:=TRUE);
  tonlMaxWarteZeit(IN:=FALSE);
  tonlFehlermeldungUnterdrueckenAntriebOK( IN := FALSE );

END_IF



(***************************************************************************************************)
(* BAUSTEIN: AKTIONEN *)
(***************************************************************************************************)
(* Hinweis:
   - Aktionen
*)
IF ( bpReset ) THEN

  bpReset                 := FALSE;
  bpVerstellungOeffnen    := FALSE;
  bpVerstellungSchliessen := FALSE;

  bpFehler        := FALSE;
  bpDone          := FALSE;
  bpResourceAktiv := FALSE;

  wpFehlerNr := 0;

  out_bVerstellungSchliessen  := FALSE;
  out_bVerstellungOeffnen := FALSE;

ELSE

  IF ( bpAktivieren ) THEN

    VerstellungSchliessen();
    VerstellungOeffnen();
	
	out_bBremseOeffnen := out_bVerstellungOeffnen OR out_bVerstellungSchliessen;

    Meldungen();
    Timer();

  ELSE

    bpDone   := TRUE;
    bpFehler := FALSE;

  END_IF (* => bpAktiv *)

END_IF(* => bpReset *)
END_FUNCTION_BLOCK