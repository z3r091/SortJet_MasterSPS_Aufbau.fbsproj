(* METADATA
{
  "v3Meta": {
    "objectGuid": "3c575514-d133-4a53-b99b-31124f37ab50"
  }
}
*)
FUNCTION_BLOCK Wandverstellung_Pneumatik_FB
VAR_INPUT

  (* BOOLEAN *)
  bpWandverstellungOeffnen    : BOOL;
  bpWandverstellungSchliessen : BOOL;
  bpReset                     : BOOL;
  bpAktivieren                : BOOL;

END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpDone    : BOOL;
  bpFehler  : BOOL;

  (* WORD *)
  wpFehlerNr  : WORD;

  (* ENUM *)

END_VAR
VAR

  (* STEPS *)
  steplWandverstellungOeffnen    : Steps_TE;
  steplWandverstellungSchliessen : Steps_TE;

  (* TIMER *)
  tonlEingefahrenWandEinlaufseite  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlAusgefahrenWandEinlaufseite  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlEingefahrenWandAuslaufseite  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlAusgefahrenWandAuslaufseite  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben *)

  (* TRIGGER *)
  ftlDeaktivieren : F_TRIG;

END_VAR
VAR

  (* HARDWARE EINGAENGE *)
  in_bWandEinlaufseiteGeoeffnet    AT %I* : BOOL; (* STATUS: Sensor meldet geöffnet *)
  in_bWandEinlaufseiteGeschlossen  AT %I* : BOOL; (* STATUS: Sensor meldet geschlossen *)
  in_bWandAuslaufseiteGeoeffnet    AT %I* : BOOL; (* STATUS: Sensor meldet geöffnet *)
  in_bWandAuslaufseiteGeschlossen  AT %I* : BOOL; (* STATUS: Sensor meldet geschlossen *)

  (* HARDWARE AUSGAENGE *)
  out_bWandverstellungOeffnen      AT %Q* : BOOL; (* AKTION: Verstellen der Wandoeffnung -> Maximal Geoeffnet *)
  out_bWandverstellungSchliessen   AT %Q* : BOOL; (* AKTION: Verstellen der Wandoeffnung -> Minimal Geoeffnet *)

END_VAR

(***************************************************************************************************)
(* BAUSTEIN: ABLAUF *)
(***************************************************************************************************)

IF ( bpReset ) THEN

  out_bWandverstellungOeffnen    := FALSE;
  out_bWandverstellungSchliessen := FALSE;


  wpFehlerNr := cMELDUNG_NULL;
  bpFehler   := FALSE;
  bpDone     := FALSE;

  bpReset := FALSE;

ELSE

  IF ( bpAktivieren ) THEN
    WandverstellungOeffnen();
    WandverstellungSchliessen();
  ELSE
    bpDone     := TRUE;
    bpFehler   := FALSE;
    wpFehlerNr := 0;
  END_IF

  (* Hinweis:
     - Deaktiveren baustein zuruecksetzen
  *)
  ftlDeaktivieren( CLK := bpAktivieren );

  IF ( ftlDeaktivieren.Q ) THEN
    bpReset := TRUE;
  END_IF

END_IF
END_FUNCTION_BLOCK