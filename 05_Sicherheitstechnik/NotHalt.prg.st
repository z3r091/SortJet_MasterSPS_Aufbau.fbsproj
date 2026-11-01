(* METADATA
{
  "v3Meta": {
    "objectGuid": "69a82f5e-5606-42e6-b3a3-559b5ec715fe"
  }
}
*)
PROGRAM NotHalt
VAR_INPUT
  
  // BOOL
  bpEingangNotHaltOK        : BOOL; // Not-Halt ok von SLC  
  
  // WORD
  wMeldungsnummer           : WORD;
  
END_VAR
VAR_OUTPUT

  // BOOLE
  bpNotHaltOK               : BOOL; 
  bpTasterNothaltQuittieren : BOOL;

END_VAR
VAR

  // BOOL
  blResetNotHalt     : BOOL := FALSE;
    
  // RS-FLIP FLOP 
  NotHaltAusgeloest : SR;
  NotHaltQuittieren : RS;

  // TIMER 
  tonlNotHaltAusgeloest : TON; 

END_VAR
VAR
  // HARDWARE EINGAENGE 
  in_bTasterNothaltQuittieren             AT %I* : BOOL; // Taster zum Quittieren des Nothalts und Reset der Safety-Module

  
  // HARDWARE AUSGAENGE 
  out_bLeuchtdruckTasterNotHaltAusgeloest  AT %Q* : BOOL; 
  

END_VAR
VAR CONSTANT

  // TIME VALUE 
  cZEIT_NOTAUS_VERZOEGERUNG : TIME := T#100MS;

END_VAR
(***************************************************************************************************)
(* Taster  *)
(***************************************************************************************************)

// Leuchtdruck Taster am CAB
out_bLeuchtdruckTasterNotHaltAusgeloest := NOT bpNotHaltOK OR ( Interface_SLC.bpEDMFehlerAktiv AND gbFlashbit05sec );
bpTasterNothaltQuittieren := in_bTasterNothaltQuittieren OR Interface_SLC.bpVisuResetNothalt;

(***************************************************************************************************)
(* BAUSTEIN: AKTIONEN   *)
(***************************************************************************************************)
Meldungen();

(***************************************************************************************************)
(* BAUSTEIN: LOGIK   *)
(***************************************************************************************************)
// Kurze Verzoegerung das alle Signale durchgeschaltet haben 
tonlNotHaltAusgeloest( IN := ( NOT bpEingangNotHaltOK OR bgSicherheitstechnikBruecken ),
                       PT := cZEIT_NOTAUS_VERZOEGERUNG );
                      
// NotHalt OK bilden
bpNotHaltOK := (   NOT NotHaltAusgeloest.Q1
                 OR Visu_Notaus_OK 
                 OR bgSicherheitstechnikBruecken );
                
(* Hinweis:
   - Merker das der Notaus ausgeloest wurde
     => Bistabiele Funktion in der das  "set" dominant ist
*)
NotHaltAusgeloest( SET1 := tonlNotHaltAusgeloest.Q,
                   RESET:= blResetNotHalt );

(* Hinweis:
   - Merker das der Taster "Quittierung Notaus" betaetigt wurde
     => Bistabiele Funktion in der das  "reset" dominant ist
*)
NotHaltQuittieren( SET   := ( in_bTasterNothaltQuittieren OR Interface_SLC.bpVisuResetNothalt ) ,
                   RESET1:= NOT NotHaltAusgeloest.Q1); 


IF ( NotHaltQuittieren.Q1 
     AND NOT tonlNotHaltAusgeloest.Q ) 
THEN
  blResetNotHalt := TRUE;
ELSE
  blResetNotHalt := FALSE;
END_IF
END_PROGRAM