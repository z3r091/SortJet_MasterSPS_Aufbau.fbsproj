(* METADATA
{
  "v3Meta": {
    "objectGuid": "dcab1ddf-6c10-4772-a9bc-4c92780e70eb"
  }
}
*)
FUNCTION_BLOCK Arretierung_FB_V01_00_00
VAR_INPUT

  // EINGAENGE
  in_bStatusZylinderAusgefahren : BOOL;
  in_bStatusZylinderEingefahren : BOOL;

  // BOOLEAN
  bpReset                       : BOOL;
  bpAktivieren                  : BOOL;
  bpStartAusfahren              : BOOL;
  bpStartEinfahren              : BOOL;

  // OPTIONEN
  bpAbfrageAusgefahrenVorhanden : BOOL := TRUE;   // Endlagensensor ausgefahren vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  bpAbfrageEingefahrenVorhanden : BOOL := TRUE;   // Endlagensensor eingefahren vorhanden, sonst gilt die Endlage nach tpBewegungszeit
  tpBewegungszeit               : TIME := T#800MS; // Bewegungszeit je Richtung ohne Endlagensensor

END_VAR
VAR_OUTPUT
  // AUSGAENGE
  out_bZylinderAusfahren        : BOOL;
  out_bZylinderEinfahren        : BOOL;

  // BOOLEAN
  bpFehler                      : BOOL;
  bpDone                        : BOOL;

  // WORD
  wpFehlerNr                    : WORD;

  // ENUM
  epStatusZylinder : PneumatikZylinderStatus_EN;

END_VAR
VAR

  // STEPS
  steplAusfahren   : Steps_TE;
  steplEinfahren   : Steps_TE;

  // TIMER
  tonZylinderEingefahren     : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben
  tonZylinderAusgefahren     : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlBewegungszeitEinfahren : TON; // Bewegungszeit ohne Endlagensensor eingefahren
  tonlBewegungszeitAusfahren : TON; // Bewegungszeit ohne Endlagensensor ausgefahren

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

  out_bZylinderAusfahren := FALSE;
  out_bZylinderEinfahren := FALSE;

  bpStartAusfahren := FALSE;
  bpStartEinfahren := FALSE;

  steplAusfahren := STEP_0_E;
  steplEinfahren := STEP_0_E;

  tonZylinderAusgefahren( IN := FALSE );
  tonZylinderEingefahren( IN := FALSE );
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