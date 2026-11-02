(* METADATA
{
  "v3Meta": {
    "objectGuid": "03480e68-cdc5-4531-b68c-8ecf9892ea12"
  }
}
*)
FUNCTION_BLOCK Rollenleiste_FB_V01_00_00
VAR_INPUT

  // BOOLEAN
  bpStarteOeffnen    : BOOL;
  bpStarteSchliessen : BOOL;
  bpReset            : BOOL;
  bpAktivieren       : BOOL;

  // OPTIONEN
  bpAbfrageGeoeffnetVorhanden   : BOOL := TRUE;   // Endlagensensor geoeffnet vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  bpAbfrageGeschlossenVorhanden : BOOL := TRUE;   // Endlagensensor geschlossen vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  tpBewegungszeit               : TIME := T#800MS; // Bewegungszeit je Richtung ohne Endlagensensor

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone    : BOOL;
  bpFehler  : BOOL;

  // WORD
  wpFehlerNr  : WORD;

END_VAR
VAR

  // STEPS
  steplSchrittketteOeffnen    : Steps_TE;
  steplSchrittketteSchliessen : Steps_TE;

  // TIMER
  tonlRollenleisteGeoeffnet    : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben
  tonlRollenleisteGeschlossen  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben
  tonlBewegungszeitOeffnen     : TON; // Bewegungszeit ohne Endlagensensor geoeffnet
  tonlBewegungszeitSchliessen  : TON; // Bewegungszeit ohne Endlagensensor geschlossen

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bGeoeffnet     AT %I* : BOOL; // STATUS: Sensor meldet geöffnet
  in_bGeschlossen   AT %I* : BOOL; // STATUS: Sensor meldet geschlossen

  // HARDWARE AUSGAENGE
  out_bOeffnen      AT %Q* : BOOL; // AKTION: Verstellen der Wandoeffnung -> Maximal Geoeffnet
  out_bSchliessen   AT %Q* : BOOL; // AKTION: Verstellen der Wandoeffnung -> Minimal Geoeffnet

END_VAR
VAR CONSTANT

  // TIME
  cZEITWERT_UEBERWACHUNG_BEWEGUNG : TIME := T#5s;

END_VAR

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: RESET / DEAKTIVIERT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Reset oder deaktiviert: Ausgaenge aus, Ketten und Timer zuruecksetzen, Done und Fehler loeschen
   - Der Baustein setzt bpReset selbst zurueck, der Aufrufer wartet nicht auf Done
   - Ein deaktivierter Baustein meldet kein Done; der Aufrufer verknuepft das Warten auf Done
     mit der Aktivierung aus der MK (z.B. Rollenleiste.bpDone OR NOT stStationsAufbau.bX)
*)
IF ( bpReset OR NOT bpAktivieren ) THEN

  out_bOeffnen    := FALSE;
  out_bSchliessen := FALSE;

  bpStarteOeffnen    := FALSE;
  bpStarteSchliessen := FALSE;

  steplSchrittketteOeffnen    := STEP_0_E;
  steplSchrittketteSchliessen := STEP_0_E;

  tonlRollenleisteGeoeffnet( IN := FALSE );
  tonlRollenleisteGeschlossen( IN := FALSE );
  tonlBewegungszeitOeffnen( IN := FALSE );
  tonlBewegungszeitSchliessen( IN := FALSE );

  wpFehlerNr := cMELDUNG_NULL;
  bpFehler   := FALSE;
  bpDone     := FALSE;

  bpReset := FALSE;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------
Oeffnen();
Schliessen();
END_FUNCTION_BLOCK