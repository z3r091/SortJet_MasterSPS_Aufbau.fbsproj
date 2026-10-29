(* METADATA
{
	"v3Meta": {
		"objectGuid": "07d57a24-f3c0-4742-8d44-44a8d21cf93a"
	}
}
*)
FUNCTION_BLOCK BetriebsStop_FB
VAR_INPUT
END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  abpBetriebsstop  : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;

END_VAR
VAR

  (* BOOLEAN *)
  blBetriebsstop  : BOOL; (* Merkervariable *)

  (* WORD *)
  wlIndex                    : WORD;
  wMeldungsNrInkrementieren  : WORD := 0;
  
END_VAR
(***************************************************************************************************)
(* BAUSTEIN: BETRIEBSSTATUS *)
(***************************************************************************************************)

(*Hinweis:
  - Betriebs- Stopp ausloesen 
  - Internen Betriebsstop ausloesen 
*)

blBetriebsstop := (  ( NOT bgMMIOK AND NOT bgMMIBruecken ) );


(***************************************************************************************************)
(* BAUSTEIN: MELDUNGEN *)
(***************************************************************************************************)
(* Hinweis:
   - Generieren einer Meldung
*)
wMeldungsNrInkrementieren := 0;

FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
   abpBetriebsstop[wlIndex] :=    Job_Stationen.abpFehler[wlIndex]
                               OR Job_Shuttle.abpFehler[wlIndex]
                               OR NOT StatusAnlage.abpDruckluftOK[wlIndex]
                               OR NOT StatusAnlage.bpAnlageOK
                               OR blBetriebsstop;
  WatchIo( abpBetriebsstop[wlIndex] , ( ioccBetriebsstop1 + wMeldungsNrInkrementieren ) );
  wMeldungsNrInkrementieren := wMeldungsNrInkrementieren + 1;
END_FOR
END_FUNCTION_BLOCK