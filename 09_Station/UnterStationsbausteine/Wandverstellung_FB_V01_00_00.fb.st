(* METADATA
{
  "v3Meta": {
    "objectGuid": "10dab8d5-0a44-4f93-9a62-9b59bb1a4144"
  }
}
*)
{attribute 'excludefrombuild'}
FUNCTION_BLOCK Wandverstellung_FB_V01_00_00
VAR_INPUT

  // BOOLEAN
  bpWandverstellungOeffnen    : BOOL;
  bpWandverstellungSchliessen : BOOL;
  bpReset                     : BOOL;
  bpAktivieren                : BOOL;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone    : BOOL;
  bpFehler  : BOOL;

  // WORD
  wpFehlerNr  : WORD;

  // ENUM
  epWandStatus  : WandOeffnung_EN;// Status: Gibt die Aktuelle Position des Antriebs aus

END_VAR
VAR

  // STEPS
  steplWandverstellungOeffnen    : Steps_TE;
  steplWandverstellungSchliessen : Steps_TE;

  // TIMER
  tonlEingefahrenWandEinlaufseite  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben
  tonlAusgefahrenWandEinlaufseite  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben
  tonlEingefahrenWandAuslaufseite  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben
  tonlAusgefahrenWandAuslaufseite  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben

  // TRIGGER
  ftlDeaktivieren : F_TRIG;

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bWandEinlaufseiteGeoeffnet    AT %I* : BOOL; // STATUS: Sensor meldet geöffnet
  in_bWandEinlaufseiteGeschlossen  AT %I* : BOOL; // STATUS: Sensor meldet geschlossen
  in_bWandAuslaufseiteGeoeffnet    AT %I* : BOOL; // STATUS: Sensor meldet geöffnet
  in_bWandAuslaufseiteGeschlossen  AT %I* : BOOL; // STATUS: Sensor meldet geschlossen

  // HARDWARE AUSGAENGE
  out_bWandverstellungOeffnen      AT %Q* : BOOL; // AKTION: Verstellen der Wandoeffnung -> Maximal Geoeffnet
  out_bWandverstellungSchliessen   AT %Q* : BOOL; // AKTION: Verstellen der Wandoeffnung -> Minimal Geoeffnet

END_VAR

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: ABLAUF
//-------------------------------------------------------------------------------------------------

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

(* Anmerkung:
   - Realisierung durch ein ENUM   ACHTUNG! Erweiterbar auf mehrerer Stufen nötig!!
*)
IF ( NOT in_bWandEinlaufseiteGeoeffnet AND in_bWandEinlaufseiteGeschlossen ) THEN
  epWandStatus := eWandOeffnung_Geschlossen;

ELSIF ( NOT in_bWandEinlaufseiteGeoeffnet AND in_bWandEinlaufseiteGeschlossen ) THEN
  epWandStatus := eWandOeffnung_Offen;

ELSIF ( NOT in_bWandEinlaufseiteGeoeffnet AND NOT in_bWandEinlaufseiteGeschlossen ) THEN
  epWandStatus := eWandOeffnung_Undefiniert;

ELSE
  epWandStatus := eWandOeffnung_Default;

END_IF
END_FUNCTION_BLOCK