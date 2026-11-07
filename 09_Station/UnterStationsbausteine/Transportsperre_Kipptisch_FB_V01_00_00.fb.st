(* METADATA
{
	"v3Meta": {
		"objectGuid": "32d63b77-62b3-4c1f-9a6d-0b9e7860b01c"
	}
}
*)
{attribute 'excludefrombuild'}
FUNCTION_BLOCK Transportsperre_Kipptisch_FB_V01_00_00
VAR_INPUT

  // BOOLEAN
  bpAktivieren        : BOOL;
  bpStartAusfahren    : BOOL; // BETRIEBTYP: Zylinder wird ausgefahren
  bpStartEinfahren    : BOOL; // BETRIEBTYP: Zylinder wird eingefahren
  bpReset             : BOOL; // BETRIEBTYP: Zylinderbaustein wird zurueckgesetzt
  bpFreigabe          : BOOL; //
  bpFreigabeEinfahren : BOOL; // Freigabe von der Folgestation, dass die Sperre runter fahren darf

  // OPTIONEN
  bpAbfrageAusgefahrenVorhanden : BOOL := TRUE;   // Endlagensensor ausgefahren vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  bpAbfrageEingefahrenVorhanden : BOOL := TRUE;   // Endlagensensor eingefahren vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  tpBewegungszeit               : TIME := T#800MS; // Bewegungszeit je Richtung ohne Endlagensensor

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFehler            : BOOL;
  bpDone              : BOOL;
  bpFreigabeKippen    : BOOL;
  bpFreigabeTransport : BOOL;

  // WORD
  wpFehlerNr       : WORD;

  // ENUM
  wpStatusZylinder : PneumatikZylinderStatus_EN;

END_VAR
VAR
  // STEPS
  steplAusfahren   : Steps_TE;
  steplEinfahren   : Steps_TE;

  // TIMER
  tonlZylinderEingefahren    : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlZylinderAusgefahren    : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlBewegungszeitEinfahren : TON; // Bewegungszeit ohne Endlagensensor eingefahren
  tonlBewegungszeitAusfahren : TON; // Bewegungszeit ohne Endlagensensor ausgefahren
  tofEinfahren               : TOF;
  tofAusfahren               : TOF;

END_VAR

VAR

  // HARDWARE EINGAENGE
  in_StatusZylinderAusgefahren   AT %I* : BOOL; // STATUS: Sensor meldt ausgfahren  [Oben]
  in_StatusZylinderEingefahren   AT %I* : BOOL; // STATUS: Sensor meldt eingefahren [Unten]

  // HARDWARE AUSGAENGE
  out_ZylinderAusfahren   AT %Q* : BOOL; // AKTION: Zylinder ausfahren
  out_ZylinderEinfahren   AT %Q* : BOOL; // AKTION: Zylinder einfahren

END_VAR
VAR CONSTANT

  // TIME
  cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER : TIME := T#15s;

END_VAR
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: RESET / DEAKTIVIERT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Reset oder deaktiviert: Ausgaenge aus, Ketten und Timer zuruecksetzen, Done und Fehler loeschen
   - Der Baustein setzt bpReset selbst zurueck, der Aufrufer wartet nicht auf Done
   - Ein deaktivierter Zylinder meldet kein Done; der Aufrufer verknuepft das Warten auf Done
     mit der Aktivierung aus der MK (z.B. Zylinder.bpDone OR NOT stStationsAufbau.bX)
*)
IF ( bpReset OR NOT bpAktivieren ) THEN

  out_ZylinderAusfahren := FALSE;
  out_ZylinderEinfahren := FALSE;

  bpStartAusfahren := FALSE;
  bpStartEinfahren := FALSE;

  steplAusfahren := STEP_0_E;
  steplEinfahren := STEP_0_E;

  tonlZylinderAusgefahren( IN := FALSE );
  tonlZylinderEingefahren( IN := FALSE );
  tonlBewegungszeitAusfahren( IN := FALSE );
  tonlBewegungszeitEinfahren( IN := FALSE );
  tofEinfahren( IN := FALSE );
  tofAusfahren( IN := FALSE );

  bpDone              := FALSE;
  bpFehler            := FALSE;
  wpFehlerNr          := cMELDUNG_NULL;
  bpFreigabeKippen    := FALSE;
  bpFreigabeTransport := FALSE;

  bpReset := FALSE;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------
Ausfahren();
Einfahren();

// Umschaltpause zwischen den Richtungen
tofEinfahren( IN := bpStartEinfahren, PT := T#1S );
tofAusfahren( IN := bpStartAusfahren, PT := T#1S );

//-------------------------------------------------------------------------------------------------
// STATUS DES ZYLINDERS
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Status aus der Sensorik, soweit Endlagensensoren vorhanden sind
   - Ohne Sensor bleibt der Status, den die Schrittketten nach der Bewegungszeit setzen
*)
IF ( bpAbfrageAusgefahrenVorhanden AND bpAbfrageEingefahrenVorhanden ) THEN

  IF (      in_StatusZylinderAusgefahren
       AND NOT in_StatusZylinderEingefahren )
  THEN
    wpStatusZylinder := eZylinder1Ausgefahren;
  ELSIF(    in_StatusZylinderEingefahren
         AND NOT in_StatusZylinderAusgefahren )
  THEN
    wpStatusZylinder := eZylinder1Eingefahren;
  ELSE
    wpStatusZylinder := eZylinderUndefiniert;
  END_IF

ELSIF ( bpAbfrageAusgefahrenVorhanden ) THEN

  IF ( in_StatusZylinderAusgefahren ) THEN
    wpStatusZylinder := eZylinder1Ausgefahren;
  ELSIF ( wpStatusZylinder = eZylinder1Ausgefahren ) THEN
    wpStatusZylinder := eZylinderUndefiniert;
  END_IF

ELSIF ( bpAbfrageEingefahrenVorhanden ) THEN

  IF ( in_StatusZylinderEingefahren ) THEN
    wpStatusZylinder := eZylinder1Eingefahren;
  ELSIF ( wpStatusZylinder = eZylinder1Eingefahren ) THEN
    wpStatusZylinder := eZylinderUndefiniert;
  END_IF

END_IF

bpFreigabeKippen    := ( wpStatusZylinder = eZylinder1Ausgefahren );
bpFreigabeTransport := ( wpStatusZylinder = eZylinder1Eingefahren );
END_FUNCTION_BLOCK