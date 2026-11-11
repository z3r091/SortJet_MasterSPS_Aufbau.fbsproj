(* METADATA
{
	"v3Meta": {
		"objectGuid": "4b81b4a3-bc49-4a0d-8ff1-d84de9c8f53e"
	}
}
*)
FUNCTION_BLOCK Station_Glashoehenmessung
VAR_INPUT

  // BOOLEAN
  bpReset                : BOOL;
  bpAbbruchAnlegeauftrag : BOOL;

  // WORD
  wStation               : WORD;

  // STRUKTUR
  Auftragsdaten          : Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone                 : BOOL;
  bpFehler               : BOOL;

END_VAR
VAR

  // STEPS
  steplSchritt           : STEPS_TE;

END_VAR

//-------------------------------------------------------------------------------------------------
// STEUERUNG ANLEGEN
//-------------------------------------------------------------------------------------------------
IF ( Auftragsdaten.wAuftrag = eStation_Hoehenmessung ) THEN
  CASE steplSchritt OF
    // HÖHENMESSUNG ==================================================
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation]) THEN
        steplSchritt := STEP_10_E;
      END_IF

      (* Hinweis:
         - Abbruch des Anlegens
      *)
      IF ( bpAbbruchAnlegeauftrag ) THEN
        bpAbbruchAnlegeauftrag := FALSE;
        bpDone := TRUE;
        Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;
      END_IF

    // HÖHENMESSUNG ==================================================
    STEP_10_E:
      (* Hinweis:
         - Starten des Messvorgangs
      *)
      starrStationBasisParameter[wStation].pAuftrag[cWAND_1] := Auftragsdaten;
      starrStationBasisParameter[wStation].bGlashoehenmessung := TRUE;

      steplSchritt := STEP_20_E;

    // HÖHENMESSUNG ==================================================
    STEP_20_E:
      (* Hinweis:
         - Prüfen dass der Auftragsstatus sich geändert hat
      *)
      IF ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragAktiv ) THEN
        steplSchritt := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Station
      *)
      IF ( starrStationBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrStationBasisParameter[wStation].wFehlerNummer,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                  starrStationBasisParameter[wStation].awFehlerInformationen );
        starrStationBasisParameter[wStation].bGlashoehenmessung := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

    // HÖHENMESSUNG ==================================================
    STEP_100_E:
      (* Hinweis:
         - Starten des Messvorgangs
      *)
      IF ( starrStationBasisParameter[wStation].bGlashoehenmessungAbgeschlossen ) THEN
        starrStationBasisParameter[wStation].bGlashoehenmessung := FALSE;

        steplSchritt := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Station
      *)
      IF ( starrStationBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrStationBasisParameter[wStation].wFehlerNummer,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                  starrStationBasisParameter[wStation].awFehlerInformationen );

        starrStationBasisParameter[wStation].bGlashoehenmessung := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

    // HÖHENMESSUNG ==================================================
    STEP_900_E:
      bpFehler := TRUE;

    // HÖHENMESSUNG ==================================================
    STEP_1000_E:
      (* Hinweis:
         - Entsprechend dem Auftragsergebnis den Folgeauftrag zuweisen
      *)
      bpDone := TRUE;

      IF ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragErfolgreich ) THEN
        Auftragsdaten.wAuftrag := eStation_Messfahrt;

      ELSIF ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragWiederholen ) THEN
        Auftragsdaten.wAuftrag := eStation_Anlegen;

      END_IF

  // HÖHENMESSUNG ==================================================
  END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpReset := FALSE;
  bpDone := FALSE;
  steplSchritt := STEP_0_E;
  starrStationBasisParameter[wStation].bGlashoehenmessung := FALSE;
END_IF
END_FUNCTION_BLOCK