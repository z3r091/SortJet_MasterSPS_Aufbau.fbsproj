(* METADATA
{
	"v3Meta": {
		"objectGuid": "50b45b59-5893-4c9c-b524-1732205d1fb3"
	}
}
*)
FUNCTION_BLOCK Greiferzange_FB_V01_00_00
VAR_INPUT

  // BOOLEAN
  bpReset                     : BOOL;
  bpAktivieren                : BOOL;
  bpStartZylinderBewegung     : BOOL; // BETRIEBTYP: Greiferzange in die Soll-Stellung bewegen
  bpZylinderAbfragenVorhanden : BOOL := FALSE; // Hinweis: Endlagenabfragen der Zylinder vorhanden

  // TIME
  tpBewegungszeit             : TIME := T#700MS; // Bewegungszeit je Stellung ohne Abfragen bzw. beim Schliessen auf Glas

  // ENUM
  epSollZylinderStellung      : PneumatikZylinderStatus_EN; // eZylinderGeschlossen, eZylinderStellung16mm, eZylinderStellung23mm, eZylinderStellung29mm

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFehler                    : BOOL;
  bpDone                      : BOOL;

  // WORD
  wpFehlerNr                  : WORD;

  // ENUM
  epStatusZylinderStellung    : PneumatikZylinderStatus_EN;

END_VAR
VAR

  // STEPS
  steplZylinderStellung       : Steps_TE;

  // TIMER
  tonlUeberwachungStellung      : TON; // EINSCHALTVERZOEGERUNG: Ueberwachung der Soll-Stellung mit Abfragen
  tonlWartezeitZylinderStellung : TON; // EINSCHALTVERZOEGERUNG: Bewegungszeit ohne Abfragen

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bStatusZylinder_Alle_Eingefahren AT %I* : BOOL; // STATUS: Zylinderabfrage [Eingefahren] Zange geschlossen
  in_bStatusZylinder_1_Ausgefahren    AT %I* : BOOL; // STATUS: Zylinderabfrage [Ausgefahren] Oeffnung 16 mm
  in_bStatusZylinder_2_Ausgefahren    AT %I* : BOOL; // STATUS: Zylinderabfrage [Ausgefahren] Oeffnung 23 mm
  in_bStatusZylinder_3_Ausgefahren    AT %I* : BOOL; // STATUS: Zylinderabfrage [Ausgefahren] Oeffnung 29 mm

  // HARDWARE AUSGAENGE
  out_bZylinder_1_Einfahren           AT %Q* : BOOL; // Impuls Zylinder 1 einfahren
  out_bZylinder_2_Einfahren           AT %Q* : BOOL; // Impuls Zylinder 2 einfahren
  out_bZylinder_3_Einfahren           AT %Q* : BOOL; // Impuls Zylinder 3 einfahren
  out_bZylinder_1_Ausfahren           AT %Q* : BOOL; // Impuls Zylinder 1 ausfahren [16 mm]
  out_bZylinder_2_Ausfahren           AT %Q* : BOOL; // Impuls Zylinder 2 ausfahren [23 mm]
  out_bZylinder_3_Ausfahren           AT %Q* : BOOL; // Impuls Zylinder 3 ausfahren [29 mm]

END_VAR
VAR CONSTANT

  // TIME
  cZEIT_UEBERWACHUNG_STELLUNG : TIME := T#5S;

END_VAR
(* Anmerkung:
   - Greiferzange mit drei Zylindern: geschlossen, Oeffnung 16 mm, 23 mm oder 29 mm
   - Vor dem Oeffnen werden alle Zylinder eingefahren, danach faehrt der Zylinder der Soll-Oeffnung aus
*)
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: RESET / DEAKTIVIERT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Reset oder deaktiviert: Ausgaenge aus, Kette und Timer zuruecksetzen, Done und Fehler loeschen
   - Der Baustein setzt bpReset selbst zurueck, der Aufrufer wartet nicht auf Done
   - Ein deaktivierter Baustein meldet kein Done; der Aufrufer verknuepft das Warten auf Done
     mit der Aktivierung aus der MK (z.B. Greiferzange.bpDone OR NOT stStationsAufbau.bGreifer[wWand])
*)
IF ( bpReset OR NOT bpAktivieren ) THEN

  out_bZylinder_1_Einfahren := FALSE;
  out_bZylinder_2_Einfahren := FALSE;
  out_bZylinder_3_Einfahren := FALSE;
  out_bZylinder_1_Ausfahren := FALSE;
  out_bZylinder_2_Ausfahren := FALSE;
  out_bZylinder_3_Ausfahren := FALSE;

  bpStartZylinderBewegung := FALSE;

  steplZylinderStellung := STEP_0_E;

  tonlUeberwachungStellung( IN := FALSE );
  tonlWartezeitZylinderStellung( IN := FALSE );

  bpDone     := FALSE;
  bpFehler   := FALSE;
  wpFehlerNr := cMELDUNG_NULL;

  bpReset := FALSE;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------
ZylinderBewegung();

//-------------------------------------------------------------------------------------------------
// STATUS DER ZYLINDER
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Status aus der Sensorik, wenn Abfragen vorhanden sind
   - Ohne Abfragen bleibt der Status, den die Schrittkette nach der Bewegungszeit setzt
*)
IF ( bpZylinderAbfragenVorhanden ) THEN

  IF ( in_bStatusZylinder_3_Ausgefahren ) THEN
    epStatusZylinderStellung := eZylinderStellung29mm;

  ELSIF ( in_bStatusZylinder_2_Ausgefahren ) THEN
    epStatusZylinderStellung := eZylinderStellung23mm;

  ELSIF ( in_bStatusZylinder_1_Ausgefahren ) THEN
    epStatusZylinderStellung := eZylinderStellung16mm;

  ELSIF ( in_bStatusZylinder_Alle_Eingefahren ) THEN
    epStatusZylinderStellung := eZylinderGeschlossen;

  ELSE
    epStatusZylinderStellung := eZylinderUndefiniert;

  END_IF

END_IF
END_FUNCTION_BLOCK