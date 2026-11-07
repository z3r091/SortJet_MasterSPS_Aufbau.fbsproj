(* METADATA
{
	"v3Meta": {
		"objectGuid": "85c14a01-ee4c-4a24-bcca-8fef195064c0"
	}
}
*)
{attribute 'excludefrombuild'}
FUNCTION_BLOCK Transportsperre_Foerderbaender_FB_V01_00_00
VAR_INPUT

  // HARDWARE EINGAENGE
  in_bOben            : BOOL; // STATUS: Sensor meldt ausgfahren  [Oben]

  // BOOLEAN
  bpAktivieren        : BOOL;
  bpStartRunter       : BOOL; // BETRIEBTYP: Zylinder wird ausgefahren
  bpStartHoch         : BOOL; // BETRIEBTYP: Zylinder wird eingefahren
  bpReset             : BOOL; // BETRIEBTYP: Zylinderbaustein wird zurueckgesetzt
  bpFreigabe          : BOOL;

  // OPTIONEN
  bpAbfrageObenVorhanden  : BOOL := TRUE;   // Endlagensensor oben vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  bpAbfrageUntenVorhanden : BOOL := TRUE;   // Endlagensensor unten vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  tpBewegungszeit         : TIME := T#800MS; // Bewegungszeit je Richtung ohne Endlagensensor

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFehler            : BOOL;
  bpDone              : BOOL;

  // WORD
  wpFehlerNr          : WORD;

  // ENUM
  wpStatus            : TransportsperrenStatus_EN;

END_VAR
VAR
  // STEPS
  steplHoch         : Steps_TE;
  steplRunter       : Steps_TE;

  // TIMER
  tonlOben                 : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlUnten                : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlBewegungszeitHoch    : TON; // Bewegungszeit ohne Endlagensensor oben
  tonlBewegungszeitRunter  : TON; // Bewegungszeit ohne Endlagensensor unten
  tofHoch                  : TOF;
  tofRunter                : TOF;

END_VAR

VAR

  // HARDWARE EINGAENGE
  in_bUnten     AT %I* : BOOL; // STATUS: Sensor meldt eingefahren [Unten]

  // HARDWARE AUSGAENGE
  out_bRunter   AT %Q* : BOOL; // AKTION: Zylinder einfahren

END_VAR
VAR CONSTANT

  // TIME
  cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER : TIME := T#15s;

END_VAR
(* Hinweis:
   - Ein Ausgang (Federrueckstell- Ventil): Runter haelt den Ausgang, Hoch nimmt ihn zurueck
*)

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: RESET / DEAKTIVIERT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Reset oder deaktiviert: Ausgang aus, Ketten und Timer zuruecksetzen, Done und Fehler loeschen
   - Der Baustein setzt bpReset selbst zurueck, der Aufrufer wartet nicht auf Done
   - Ein deaktivierter Baustein meldet kein Done; der Aufrufer verknuepft das Warten auf Done
     mit der Aktivierung aus der MK (z.B. Transportsperre.bpDone OR NOT stStationsAufbau.bX)
*)
IF ( bpReset OR NOT bpAktivieren ) THEN

  out_bRunter := FALSE;

  bpStartRunter := FALSE;
  bpStartHoch   := FALSE;

  steplHoch   := STEP_0_E;
  steplRunter := STEP_0_E;

  tonlOben( IN := FALSE );
  tonlUnten( IN := FALSE );
  tonlBewegungszeitHoch( IN := FALSE );
  tonlBewegungszeitRunter( IN := FALSE );
  tofHoch( IN := FALSE );
  tofRunter( IN := FALSE );

  bpDone     := FALSE;
  bpFehler   := FALSE;
  wpFehlerNr := cMELDUNG_NULL;

  bpReset := FALSE;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------
HochFahren();
RunterFahren();

// Umschaltpause zwischen den Richtungen
tofHoch( IN := bpStartHoch, PT := T#1S );
tofRunter( IN := bpStartRunter, PT := T#1S );

//-------------------------------------------------------------------------------------------------
// STATUS DER TRANSPORTSPERRE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Status aus der Sensorik, soweit Endlagensensoren vorhanden sind
   - Ohne Sensor bleibt der Status, den die Schrittketten nach der Bewegungszeit setzen
*)
IF ( bpAbfrageObenVorhanden AND bpAbfrageUntenVorhanden ) THEN

  IF (     in_bOben
       AND NOT in_bUnten )
  THEN
    wpStatus := eTransportsperreOben;
  ELSIF(   in_bUnten
         AND NOT in_bOben )
  THEN
    wpStatus := eTransportsperreUnten;
  ELSE
    wpStatus := eTransportsperreUndefiniert;
  END_IF

ELSIF ( bpAbfrageObenVorhanden ) THEN

  IF ( in_bOben ) THEN
    wpStatus := eTransportsperreOben;
  ELSIF ( wpStatus = eTransportsperreOben ) THEN
    wpStatus := eTransportsperreUndefiniert;
  END_IF

ELSIF ( bpAbfrageUntenVorhanden ) THEN

  IF ( in_bUnten ) THEN
    wpStatus := eTransportsperreUnten;
  ELSIF ( wpStatus = eTransportsperreUnten ) THEN
    wpStatus := eTransportsperreUndefiniert;
  END_IF

END_IF
END_FUNCTION_BLOCK