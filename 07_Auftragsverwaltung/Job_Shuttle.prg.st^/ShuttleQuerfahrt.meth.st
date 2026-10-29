(* METADATA
{
	"v3Meta": {
		"objectGuid": "c062f55a-4f6a-45c2-9de2-37ec00cd7b53"
	}
}
*)
METHOD INTERNAL ShuttleQuerfahrt
VAR_INPUT
  wStation : WORD;
END_VAR

(*****************************************************9**********************************************)
(* STEUERUNG: QUERFAHRT *)
(***************************************************************************************************)

IF ( AuftragsdatenStation[wStation].wAuftrag = eStation_Vorabpositionierung ) THEN
  (* Hinweis: Aufruf der Schrittkette *)
  Querfahrt[wStation]( Auftragsdaten := AuftragsdatenStation[wStation], wStation := wStation);
  (* Hinweis: Abschluss der Schrittkette *)
  IF Querfahrt[wStation].bpDone THEN
    AuftragsdatenStation[wStation] := Querfahrt[wStation].Auftragsdaten;
    Querfahrt[wStation](bpReset := TRUE);
  END_IF
  (* Hinweis: Fehler-Auswertung *)
  blFehler[wStation, cWAND_1] := Querfahrt[wStation].bpFehler;
  IF rtlFehler[wStation, cWAND_1].Q THEN
    AutomatikFehlerSetzen(starrShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis: Reset der Schrittkette *)
  IF ( Querfahrt[wStation].steplSchritt <> STEP_0_E ) THEN 
    Querfahrt[wStation](bpReset := TRUE);
  END_IF
END_IF
END_METHOD