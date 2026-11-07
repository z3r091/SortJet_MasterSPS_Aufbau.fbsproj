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

  // OPTIONEN
  bpAbfrageGeoeffnetVorhanden   : BOOL := TRUE;   // Endlagensensoren geoeffnet vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  bpAbfrageGeschlossenVorhanden : BOOL := TRUE;   // Endlagensensoren geschlossen vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  tpBewegungszeit               : TIME := T#800MS; // Bewegungszeit je Richtung ohne Endlagensensor

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
  tonlBewegungszeitOeffnen         : TON; // Bewegungszeit ohne Endlagensensor geoeffnet
  tonlBewegungszeitSchliessen      : TON; // Bewegungszeit ohne Endlagensensor geschlossen

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
// BAUSTEIN: RESET / DEAKTIVIERT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Reset oder deaktiviert: Ausgaenge aus, Ketten und Timer zuruecksetzen, Done und Fehler loeschen
   - Der Baustein setzt bpReset selbst zurueck, der Aufrufer wartet nicht auf Done
   - Ein deaktivierter Baustein meldet kein Done; der Aufrufer verknuepft das Warten auf Done
     mit der Aktivierung aus der MK (z.B. Wandverstellung.bpDone OR NOT stStationsAufbau.bX)
*)
IF ( bpReset OR NOT bpAktivieren ) THEN

  out_bWandverstellungOeffnen    := FALSE;
  out_bWandverstellungSchliessen := FALSE;

  bpWandverstellungOeffnen    := FALSE;
  bpWandverstellungSchliessen := FALSE;

  steplWandverstellungOeffnen    := STEP_0_E;
  steplWandverstellungSchliessen := STEP_0_E;

  tonlEingefahrenWandEinlaufseite( IN := FALSE );
  tonlAusgefahrenWandEinlaufseite( IN := FALSE );
  tonlEingefahrenWandAuslaufseite( IN := FALSE );
  tonlAusgefahrenWandAuslaufseite( IN := FALSE );
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
WandverstellungOeffnen();
WandverstellungSchliessen();

//-------------------------------------------------------------------------------------------------
// STATUS DER WAND
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Status aus der Sensorik, soweit Endlagensensoren vorhanden sind (beide Seiten)
   - Ohne Sensor bleibt der Status, den die Schrittketten nach der Bewegungszeit setzen
*)
IF ( bpAbfrageGeoeffnetVorhanden AND bpAbfrageGeschlossenVorhanden ) THEN

  IF (     in_bWandEinlaufseiteGeschlossen AND in_bWandAuslaufseiteGeschlossen
       AND NOT in_bWandEinlaufseiteGeoeffnet AND NOT in_bWandAuslaufseiteGeoeffnet )
  THEN
    epWandStatus := eWandOeffnung_Geschlossen;
  ELSIF (     in_bWandEinlaufseiteGeoeffnet AND in_bWandAuslaufseiteGeoeffnet
          AND NOT in_bWandEinlaufseiteGeschlossen AND NOT in_bWandAuslaufseiteGeschlossen )
  THEN
    epWandStatus := eWandOeffnung_Offen;
  ELSE
    epWandStatus := eWandOeffnung_Undefiniert;
  END_IF

ELSIF ( bpAbfrageGeoeffnetVorhanden ) THEN

  IF ( in_bWandEinlaufseiteGeoeffnet AND in_bWandAuslaufseiteGeoeffnet ) THEN
    epWandStatus := eWandOeffnung_Offen;
  ELSIF ( epWandStatus = eWandOeffnung_Offen ) THEN
    epWandStatus := eWandOeffnung_Undefiniert;
  END_IF

ELSIF ( bpAbfrageGeschlossenVorhanden ) THEN

  IF ( in_bWandEinlaufseiteGeschlossen AND in_bWandAuslaufseiteGeschlossen ) THEN
    epWandStatus := eWandOeffnung_Geschlossen;
  ELSIF ( epWandStatus = eWandOeffnung_Geschlossen ) THEN
    epWandStatus := eWandOeffnung_Undefiniert;
  END_IF

END_IF
END_FUNCTION_BLOCK