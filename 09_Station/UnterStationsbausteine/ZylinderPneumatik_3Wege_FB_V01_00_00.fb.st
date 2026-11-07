(* METADATA
{
	"v3Meta": {
		"objectGuid": "530c17d7-3762-455b-8431-d2a354444d9d"
	}
}
*)
FUNCTION_BLOCK ZylinderPneumatik_3Wege_FB_V01_00_00
VAR_INPUT

  // BOOLEAN
  blErsterZyklus              : BOOL;
  bpAktivieren                : BOOL;
  bpStartPneumatik            : BOOL; // Starten der Zylinder
  bpReset                     : BOOL; // BETRIEBTYP: Zylinderbaustein wird zurueckgesetzt
  bpZylinderAbfragenVorhanden : BOOL := TRUE;  // Hinweis: Manche Zylinder haben keine Abfragen
  bpEinAusFahrenLogikDrehen   : BOOL := FALSE; // Hinweis: Manche Zylinder haben keine Abfragen
  tpWartezeitOhneAbfrage      : TIME := T#1S;  // Hinweis: Ohne Abfragen gilt die Stellung nach dieser Zeit als erreicht
  bpZweiterZylinderVorhanden  : BOOL := TRUE;  // Hinweis: Mit nur einem Zylinder (z.B. Rollenleiste) sind die Signale von Zylinder 2 ohne Funktion, es gibt nur Geschlossen (16 mm) und Geoeffnet (29 mm)

  // ENUM
  epOeffnungsStellung  : PneumatikZylinderStatus_EN;

END_VAR

VAR_OUTPUT

  // BOOLEAN
  bpFehler                       : BOOL;
  bpDone                         : BOOL;

  // WORD
  wpFehlerNr                     : WORD;

  // ENUM
  wpStatusZylinder               : PneumatikZylinderStatus_EN;

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bStatusZylinder1Ausgefahren   AT %I* : BOOL; // STATUS: Sensor meldet ausgfahren
  in_bStatusZylinder1Eingefahren   AT %I* : BOOL; // STATUS: Sensor meldet eingefahren
  in_bStatusZylinder2Ausgefahren   AT %I* : BOOL; // STATUS: Sensor meldet ausgfahren
  in_bStatusZylinder2Eingefahren   AT %I* : BOOL; // STATUS: Sensor meldet eingefahren

  // HARDWARE AUSGAENGE
  out_bZylinder1Ausfahren   AT %Q* : BOOL; // AKTION: Zylinder 1 ausfahren
  out_bZylinder1Einfahren   AT %Q* : BOOL; // AKTION: Zylinder 1 einfahren
  out_bZylinder2Ausfahren   AT %Q* : BOOL; // AKTION: Zylinder 2 ausfahren
  out_bZylinder2Einfahren   AT %Q* : BOOL; // AKTION: Zylinder 2 einfahren

  // BOOLEAN
  blZylinder2Ausgefahren : BOOL; // Zylinder 2 ausgefahren, bei nur einem Zylinder folgt das Signal Zylinder 1
  blZylinder2Eingefahren : BOOL; // Zylinder 2 eingefahren, bei nur einem Zylinder folgt das Signal Zylinder 1

  // ENUM
  elStellung : PneumatikZylinderStatus_EN; // Wirksame Sollstellung (Geschlossen = 16 mm, Geoeffnet = 29 mm, ein Zylinder: 23 mm = 29 mm)

  // STEPS
  steplAusfahren   : Steps_TE;

  // TIMER
  tonlZylinder1Eingefahren  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlZylinder1Ausgefahren  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlZylinder2Eingefahren  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlZylinder2Ausgefahren  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben
  tonlWarteZeitAufVentile   : TON; // EINSCHALTVERZOEGERUNG: wenn keine Abfragen verbaut sind, pauschal die Schaltung der Ventile zurücksetzen

END_VAR
//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus  ) THEN
  blErsterZyklus := FALSE;
  epOeffnungsStellung := eZylinderStellung16mm;
END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: RESET / DEAKTIVIERT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Reset oder deaktiviert: Ausgaenge aus, Kette und Timer zuruecksetzen, Done und Fehler loeschen
   - Der Baustein setzt bpReset selbst zurueck, der Aufrufer wartet nicht auf Done
   - Ein deaktivierter Zylinder meldet kein Done; der Aufrufer verknuepft das Warten auf Done
     mit der Aktivierung aus der MK (z.B. Zylinder.bpDone OR NOT stStationsAufbau.bX)
*)
IF ( bpReset OR NOT bpAktivieren ) THEN

  out_bZylinder1Ausfahren := FALSE;
  out_bZylinder1Einfahren := FALSE;
  out_bZylinder2Ausfahren := FALSE;
  out_bZylinder2Einfahren := FALSE;

  bpStartPneumatik := FALSE;

  steplAusfahren := STEP_0_E;

  tonlZylinder1Ausgefahren( IN := FALSE );
  tonlZylinder1Eingefahren( IN := FALSE );
  tonlZylinder2Ausgefahren( IN := FALSE );
  tonlZylinder2Eingefahren( IN := FALSE );
  tonlWarteZeitAufVentile( IN := FALSE );

  bpDone     := FALSE;
  bpFehler   := FALSE;
  wpFehlerNr := cMELDUNG_NULL;

  bpReset := FALSE;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Mit nur einem Zylinder folgen die Signale von Zylinder 2 denen von Zylinder 1
*)
IF ( bpZweiterZylinderVorhanden ) THEN
  blZylinder2Ausgefahren := in_bStatusZylinder2Ausgefahren;
  blZylinder2Eingefahren := in_bStatusZylinder2Eingefahren;
ELSE
  blZylinder2Ausgefahren := in_bStatusZylinder1Ausgefahren;
  blZylinder2Eingefahren := in_bStatusZylinder1Eingefahren;
END_IF

AusEinFahren();

//-------------------------------------------------------------------------------------------------
// STATUS DER ZYLINDER
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Status aus der Sensorik, wenn Abfragen vorhanden sind
   - Ohne Abfragen bleibt der Status, den die Schrittkette nach der Wartezeit setzt
*)
IF ( bpZylinderAbfragenVorhanden ) THEN

  IF NOT bpEinAusFahrenLogikDrehen THEN

    IF ( in_bStatusZylinder1Ausgefahren ) THEN
      IF (blZylinder2Ausgefahren) THEN
        wpStatusZylinder := eZylinderStellung29mm;
      ELSE
        wpStatusZylinder := eZylinderStellung23mm;
      END_IF

    ELSE
      IF (blZylinder2Ausgefahren) THEN
        wpStatusZylinder := eZylinderStellung23mm;
      ELSE
        wpStatusZylinder := eZylinderStellung16mm;
      END_IF
    END_IF

  ELSE

    IF in_bStatusZylinder1Eingefahren THEN

      IF (blZylinder2Eingefahren) THEN
        wpStatusZylinder := eZylinderStellung29mm;
      ELSE
        wpStatusZylinder := eZylinderStellung23mm;
      END_IF

    ELSE

      IF (blZylinder2Eingefahren) THEN
        wpStatusZylinder := eZylinderStellung23mm;
      ELSE
        wpStatusZylinder := eZylinderStellung16mm;
      END_IF

    END_IF

  END_IF

END_IF
END_FUNCTION_BLOCK