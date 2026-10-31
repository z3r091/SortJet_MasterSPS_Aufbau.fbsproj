(* METADATA
{
  "v3Meta": {
    "objectGuid": "a4d875f2-deb1-4181-ad49-6660bcb8c981"
  }
}
*)
METHOD ShuttleWandAuftraege
VAR_INPUT
  wStation : WORD;
  wWand    : WORD;
END_VAR

(*****************************************************9**********************************************)
(* STEUERUNG: EINTRANSPORT *)
(***************************************************************************************************)

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Eintransport ) THEN
   (* Hinweis: Aufruf der Schrittkette *)
   Eintransport[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, wWand := wWand);
   (* Hinweis: Abschluss der Schrittkette *)
   IF Eintransport[wStation, wWand].bpDone THEN
     ablEintransportGewesen[wStation, wWand] := TRUE;
     AuftragsdatenWand[wStation, wWand] := Eintransport[wStation, wWand].Auftragsdaten;
     Eintransport[wStation, wWand](bpReset := TRUE);
   END_IF
   (* Hinweis: Fehler-Auswertung *)
   blFehler[wStation, wWand] := Eintransport[wStation, wWand].bpFehler;
   IF rtlFehler[wStation, wWand].Q THEN
     AutomatikFehlerSetzen(starrShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
   END_IF
ELSE
  (* Hinweis: Reset der Schrittkette *)
  IF ( Eintransport[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Eintransport[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

(*****************************************************9**********************************************)
(* STEUERUNG: AUSTRANSPORT *)
(***************************************************************************************************)

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Austransport ) THEN
   (* Hinweis: Aufruf der Schrittkette *)
   Austransport[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, wWand := wWand);
   (* Hinweis: Abschluss der Schrittkette *)
   IF Austransport[wStation, wWand].bpDone THEN
     AuftragsdatenWand[wStation, wWand] := Austransport[wStation, wWand].Auftragsdaten;
     Austransport[wStation, wWand](bpReset := TRUE);
   END_IF
   (* Hinweis: Fehler-Auswertung *)
   blFehler[wStation, wWand] := Austransport[wStation, wWand].bpFehler;
   IF rtlFehler[wStation, wWand].Q THEN
     AutomatikFehlerSetzen(starrShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
   END_IF
ELSE
  (* Hinweis: Reset der Schrittkette *)
  IF ( Austransport[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Austransport[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

(*****************************************************9**********************************************)
(* STEUERUNG: DURCHTRANSPORT *)
(***************************************************************************************************)

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Durchtransport ) THEN
   (* Hinweis: Aufruf der Schrittkette *)
   Durchtransport[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, wWand := wWand);
   (* Hinweis: Abschluss der Schrittkette *)
   IF Durchtransport[wStation, wWand].bpDone THEN
     AuftragsdatenWand[wStation, wWand] := Durchtransport[wStation, wWand].Auftragsdaten;
     Durchtransport[wStation, wWand](bpReset := TRUE);
   END_IF
   (* Hinweis: Fehler-Auswertung *)
   blFehler[wStation, wWand] := Durchtransport[wStation, wWand].bpFehler;
   IF rtlFehler[wStation, wWand].Q THEN
     AutomatikFehlerSetzen(starrShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
   END_IF
ELSE
  (* Hinweis: Reset der Schrittkette *)
  IF ( Durchtransport[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Durchtransport[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

(*****************************************************9**********************************************)
(* STEUERUNG: VORABKOMPONENTEN *)
(***************************************************************************************************)
IF ( VorAbAuftragsDaten[wStation, wWand].wAuftrag = eStation_VorabAuftrag ) THEN
   (* Hinweis: Aufruf der Schrittkette *)
   VorabkomponentenAnsteuerung[wStation, wWand]( Auftragsdaten := VorAbAuftragsDaten[wStation, wWand],  wStation := wStation, wWand := wWand);
   (* Hinweis: Abschluss der Schrittkette *)
   IF VorabkomponentenAnsteuerung[wStation, wWand].bpDone THEN
     VorAbAuftragsDaten[wStation, wWand] := VorabkomponentenAnsteuerung[wStation, wWand].Auftragsdaten;
     VorabkomponentenAnsteuerung[wStation, wWand](bpReset := TRUE);
   END_IF
   (* Hinweis: Fehler-Auswertung *)
   blFehler[wStation, wWand] := VorabkomponentenAnsteuerung[wStation, wWand].bpFehler;
   IF rtlFehler[wStation, wWand].Q THEN
     AutomatikFehlerSetzen(starrShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
   END_IF
ELSE
  (* Hinweis: Reset der Schrittkette *)
  IF ( VorabkomponentenAnsteuerung[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    VorabkomponentenAnsteuerung[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF


(*****************************************************9**********************************************)
(* STEUERUNG: RACKSUCHE *)
(***************************************************************************************************)

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_RackSuche ) THEN
  (* Hinweis: Aufruf der Schrittkette *)
  Racksuche[wStation]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation );
  (* Hinweis: Abschluss der Schrittkette *)
  IF Racksuche[wStation].bpDone THEN
    AuftragsdatenWand[wStation, wWand] := Racksuche[wStation].Auftragsdaten;
    Racksuche[wStation](bpReset := TRUE);
  END_IF
  (* Hinweis: Fehler-Auswertung *)
  blFehler[wStation, cWAND_1] := Racksuche[wStation].bpFehler;
  IF rtlFehler[wStation, cWAND_1].Q THEN
    AutomatikFehlerSetzen(starrShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis: Reset der Schrittkette *)
  IF ( Racksuche[wStation].steplSchritt <> STEP_0_E ) THEN 
    Racksuche[wStation](bpReset := TRUE);
  END_IF
END_IF
END_METHOD