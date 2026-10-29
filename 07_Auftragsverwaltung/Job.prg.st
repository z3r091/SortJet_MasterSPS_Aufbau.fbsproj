(* METADATA
{
	"v3Meta": {
		"objectGuid": "d795aefc-c30c-4a59-9340-fdd22ca20f71"
	}
}
*)
PROGRAM Job
VAR
 
  (* BOOLEAN *)
  blMerkerMmiNichtOk        : BOOL;
  blMerkerNachrichtabsetzen : BOOL;
  blSendJobStatus           : BOOL;
  ablFehlerAktiv            : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;

  (* WORD *)
  wlMinutenMmiNichtOk       : WORD;
  wlSekundenMmiNichtOk      : WORD;
  wlMilliSekundenMmiNichtOk : WORD;
  wlIndex                   : WORD := 0;
  wlSubIndex                : WORD := 0;
  wlIndexStationen          : WORD := 0;
  wIndexReset               : WORD := 0;
  wIndexCheck               : WORD := 0;

  (* LREAL *)
  lrlAktuelleZeit : LREAL;
  lrlMmiNichtOk   : LREAL;

  (* TIMER *)
  timelMmiNichtOk       : TIME;
  tonlNachrichtAbsetzen : TON;
  tonlMmiOk             : TON;

  (* TRIGGER *)
  rtlMmiOk                  : R_TRIG;
  ftlMmiOk                  : F_TRIG;
  ftlNotHaltAusgeloest      : F_TRIG;
  rtlFehlerAutomatikkreis   : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF R_TRIG;

 // Check Betriebsart
 i        : WORD;
 mask     : WORD;
 newValue : BOOL;
 oldValue : BOOL;

END_VAR
(***************************************************************************************************)
(* STOPPEN DES AUTOMATIK- BETRIEBS [NOT-AUS]  *)
(***************************************************************************************************)
(* Anmerkung:
   - Automatikkreise stoppen sollte Notaus
*)
IF ( NOT NotHalt.bpNotHaltOK AND NOT bgSicherheitstechnikBruecken )
  OR ( NOT bgMMIOK AND NOT bgMMIBruecken )
THEN
  FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
    M_Automatik_Aktiv[wlIndex]   := FALSE;
  END_FOR
  M_Automatik_Aktiv[cAUTOMATIKKREIS_TRANSFERSHUTTLE] := FALSE;

END_IF

FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
  tonAutomatik_Aktiv[wlIndex]( IN := M_Automatik_Aktiv[wlIndex] AND NOT Stop_Baustein.abpBetriebsstop[wlIndex], PT := t#1s );
END_FOR

(***************************************************************************************************)
(* AKTIONEN  *)
(***************************************************************************************************)
FehlerAktiv();
CheckBetriebsart();
Check_MMI_Verbindung();
SendBetriebsart();
SetHandfunktionen();
Job_Shuttle();
Job_Stationen();
Job_Fremdanlage();
Job_SystemCheck();
Job_Verfahrlogik();
Job_Speicherfachvalidierung();
Job_Faecherwagen();
AutomatikStop();
AutomatikStart();
StartCheck();
Hornsignal();
Ampelsignal();
AnzeigeIOs();
Zuweisung_Automatik();
END_PROGRAM