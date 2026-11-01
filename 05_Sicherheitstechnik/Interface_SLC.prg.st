(* METADATA
{
  "v3Meta": {
    "objectGuid": "ccad9978-fd7c-48d9-8d85-dc1a7581631d"
  }
}
*)
PROGRAM Interface_SLC

VAR_INPUT

  // BOOL
  bpResetOperatorAcknowledge : BOOL; 
  bpEDMFehlerAktiv           : BOOL;

END_VAR

VAR_OUTPUT

  // BOOL
  bpOperatorAcknowledgeRequested : BOOL; // HINWEIS: Mindestens ein Safety IO Modul hat einen Fehler, es ist erforderlich das der Anwender wissendlich diesen Zustand zuruecksetzt

END_VAR

VAR
  
  // BOOLEAN 
  bpVisuResetEDM                  : BOOL := FALSE;
  bpVisuResetFSoEMaster           : BOOL;
  bpVisuResetNothalt              : BOOL;  
  bResetDurchSK                   : BOOL;
  ablSKAbgefallen                 : ARRAY[1..16] OF BOOL; 
  
  // WORD
  wIndex                         : WORD := 0;
  wlbitPos                       : WORD;
  
  // TIMER
  toflResetOA                                    : TOF;
  toflSKQuittiert                                : ARRAY[cERSTER_SICHERHEITSKREIS..cLETZTER_SICHERHEITSKREIS] OF tof;
  tonlSKKomplettAbgefallen                       : ARRAY[cERSTER_SICHERHEITSKREIS..cLETZTER_SICHERHEITSKREIS] OF TON;

  // TRIGGER
  rtlMeldungQuittierungDurchBedienerErforderlich : R_TRIG;
  rtlResetOA                                     : R_TRIG;
  rtlSKQuittiert                                 : ARRAY[cERSTER_SICHERHEITSKREIS..cLETZTER_SICHERHEITSKREIS] OF R_TRIG;;

END_VAR



(***************************************************************************************************)
(* AKTIONEN *)
(***************************************************************************************************)
OperatorAcknowledge();
SK_Hilfsvariablen();
Meldungen();
ToSLC();
ToPLC();
END_PROGRAM