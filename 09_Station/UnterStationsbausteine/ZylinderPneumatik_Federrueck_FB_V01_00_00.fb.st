(* METADATA
{
  "v3Meta": {
    "objectGuid": "b2af587c-0d32-447c-a5c9-96380651afc9"
  }
}
*)
FUNCTION_BLOCK ZylinderPneumatik_Federrueck_FB_V01_00_00
VAR_INPUT

  // BOOLEAN
  bpAktivieren     : BOOL;
  bpStartAusfahren : BOOL; // BETRIEBTYP: Zylinder wird ausgefahren
  bpStartEinfahren : BOOL; // BETRIEBTYP: Zylinder wird eingefahren
  bpReset          : BOOL; // BETRIEBTYP: Zylinderbaustein wird zurueckgesetzt

  // OPTIONEN
  bpAbfrageAusgefahrenVorhanden : BOOL := TRUE;   // Endlagensensor ausgefahren vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  bpAbfrageEingefahrenVorhanden : BOOL := TRUE;   // Endlagensensor eingefahren vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  tpBewegungszeit               : TIME := T#800MS; // Bewegungszeit je Richtung ohne Endlagensensor

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFehler   : BOOL;
  bpDone     : BOOL;

  // WORD
  wpFehlerNr : WORD;

  // ENUM
  epStatusZylinder : PneumatikZylinderStatus_EN;

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bStatusZylinderAusgefahren   AT %I* : BOOL; // STATUS: Sensor meldt ausgfahren
  in_bStatusZylinderEingefahren   AT %I* : BOOL; // STATUS: Sensor meldt eingefahren

  // HARDWARE AUSGAENGE
  out_bZylinderAusfahren          AT %Q* : BOOL; // AUSGANG: (in Glasflussrichtung) Signal zum Ausfahren  [Federrueckstell- Ventiel]

  // STEPS
  steplAusfahren   : Steps_TE;
  steplEinfahren   : Steps_TE;

  // TIMER
  tonlZylinderEingefahren    : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlZylinderAusgefahren    : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlBewegungszeitEinfahren : TON; // Bewegungszeit ohne Endlagensensor eingefahren
  tonlBewegungszeitAusfahren : TON; // Bewegungszeit ohne Endlagensensor ausgefahren

END_VAR
VAR CONSTANT

  // TIME
  cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER : TIME := T#5s;

END_VAR
(* Hinweis:
   - Es handelt sich bei diesem Baustein um eine Ansteuerung fuer ein Federrueckstell- Ventiel
     => Der Ausgang bleibt nach dem Ausfahren gesetzt, Einfahren nimmt ihn zurueck
*)

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: RESET / DEAKTIVIERT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Reset oder deaktiviert: Ausgang aus, Ketten und Timer zuruecksetzen, Done und Fehler loeschen
   - Der Baustein setzt bpReset selbst zurueck, der Aufrufer wartet nicht auf Done
   - Ein deaktivierter Zylinder meldet kein Done; der Aufrufer verknuepft das Warten auf Done
     mit der Aktivierung aus der MK (z.B. Zylinder.bpDone OR NOT stStationsAufbau.bX)
*)
IF ( bpReset OR NOT bpAktivieren ) THEN

  out_bZylinderAusfahren := FALSE;

  bpStartAusfahren := FALSE;
  bpStartEinfahren := FALSE;

  steplAusfahren := STEP_0_E;
  steplEinfahren := STEP_0_E;

  tonlZylinderAusgefahren( IN := FALSE );
  tonlZylinderEingefahren( IN := FALSE );
  tonlBewegungszeitAusfahren( IN := FALSE );
  tonlBewegungszeitEinfahren( IN := FALSE );

  bpDone     := FALSE;
  bpFehler   := FALSE;
  wpFehlerNr := cMELDUNG_NULL;

  bpReset := FALSE;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------
Ausfahren();
Einfahren();

//-------------------------------------------------------------------------------------------------
// STATUS DES ZYLINDERS
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Status aus der Sensorik, soweit Endlagensensoren vorhanden sind
   - Ohne Sensor bleibt der Status, den die Schrittketten nach der Bewegungszeit setzen
*)
IF ( bpAbfrageAusgefahrenVorhanden AND bpAbfrageEingefahrenVorhanden ) THEN

  IF (      in_bStatusZylinderAusgefahren
       AND NOT in_bStatusZylinderEingefahren )
  THEN
    epStatusZylinder := eZylinderAusgefahren;
  ELSIF(    in_bStatusZylinderEingefahren
         AND NOT in_bStatusZylinderAusgefahren )
  THEN
    epStatusZylinder := eZylinderEingefahren;
  ELSE
    epStatusZylinder := eZylinderUndefiniert;
  END_IF

ELSIF ( bpAbfrageAusgefahrenVorhanden ) THEN

  IF ( in_bStatusZylinderAusgefahren ) THEN
    epStatusZylinder := eZylinderAusgefahren;
  ELSIF ( epStatusZylinder = eZylinderAusgefahren ) THEN
    epStatusZylinder := eZylinderUndefiniert;
  END_IF

ELSIF ( bpAbfrageEingefahrenVorhanden ) THEN

  IF ( in_bStatusZylinderEingefahren ) THEN
    epStatusZylinder := eZylinderEingefahren;
  ELSIF ( epStatusZylinder = eZylinderEingefahren ) THEN
    epStatusZylinder := eZylinderUndefiniert;
  END_IF

END_IF
END_FUNCTION_BLOCK