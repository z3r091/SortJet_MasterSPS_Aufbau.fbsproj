(* METADATA
{
	"v3Meta": {
		"objectGuid": "6f69dbe7-f199-4869-a6d6-e576843588e3"
	}
}
*)
ACTION Vortransport
(***************************************************************************************************)
(* AKTION VORTRANSPORT *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bVortransport[cWAND_1]
  AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpVortransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplVortransport := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpStartKippenAuf := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplVortransport := STEP_900_E;
  END_IF


  CASE steplVortransport OF
(*VORTRANSPORT =====================*)
    STEP_0_E:
      (* Hinweis:
         - Ist der Modellversatz unter 350mm dann wird der Vortransport gestartet, ansonsten nur das Kippen !!!
      *)
      BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := FALSE;

      IF ( ABS(BasisStationsParameter.pAuftrag[cWAND_1].rModellVersatzVorne) <= 50 ) THEN
        steplVortransport := STEP_10_E;

      ELSE
        steplVortransport := STEP_1000_E;

      END_IF

(*VORTRANSPORT =====================*)
    STEP_10_E:
      (* Hinweis:
         - Starten des Vortransports
      *)
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpVortransport := TRUE;

      steplVortransport := STEP_20_E;

(*VORTRANSPORT =====================*)
    STEP_20_E:

      IF NOT Glastransport.bpSensorEinlauf THEN

        Kippen.bpStartKippenAuf := TRUE;

      END_IF

      IF (  Kippen.bpDone
        AND ( Kippen.epKippStatus = eKippen_Position_90Grad ) )
      THEN
        Kippen.bpStartKippenAuf := FALSE;
        steplVortransport := STEP_30_E;
      END_IF



(*VORTRANSPORT =====================*)
    STEP_30_E:

      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpVortransport := FALSE;
        steplVortransport := STEP_1000_E;
      END_IF


(*VORTRANSPORT =====================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*VORTRANSPORT =====================*)
    STEP_1000_E:
      BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := TRUE;

(*VORTRANSPORT =====================*)
  END_CASE
ELSE
  IF (steplVortransport > STEP_0_E) THEN
    BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := FALSE;
	
    Glastransport.bpVortransport := FALSE;
	
    Kippen.bpStartKippenAuf := FALSE;
	
    steplVortransport := STEP_0_E;
  END_IF
END_IF
END_ACTION