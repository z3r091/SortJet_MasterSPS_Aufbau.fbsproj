(* METADATA
{
	"v3Meta": {
		"objectGuid": "4c6bfe8f-2c46-4487-a0af-6173b7bdb3e5"
	}
}
*)
ACTION VorabDrehen
(***************************************************************************************************)
(* DREHEN  *)
(***************************************************************************************************)

IF ( BasisStationsParameter.bVorabDrehen ) THEN

  // Ausnahmesituation
  IF ( Drehen.bpFehler ) THEN
    Drehen.bpStarteAbsolutPositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
    steplVorabDrehen := STEP_900_E;
  END_IF

  CASE steplVorabDrehen OF

(* Vorab Drehen ========================= *)
    STEP_0_E:
      (* Hinweis:
         - Sicherstellen dass das Geblaese aktiv ist
      *)
      steplVorabDrehen := STEP_100_E;

(* Vorab Drehen =========================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  BEWEGUNG STARTEN
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)

      Drehen.epZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eDrehen_Sollposition;
      Drehen.bpStarteAbsolutPositionierung := TRUE;

      steplVorabDrehen := STEP_110_E;

(* Vorab Drehen =========================*)
    STEP_110_E:
      IF ( Drehen.bpAbsolutPositionierungAbgeschlossen ) THEN
        Drehen.bpStarteAbsolutPositionierung := FALSE;

        steplVorabDrehen := STEP_1000_E;
      END_IF

(* Vorab Drehen =========================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(* Vorab Drehen =========================*)
    STEP_1000_E:
      BasisStationsParameter.bVorabDrehenAbgeschlossen := TRUE;

(* Vorab Drehen =========================*)
  END_CASE

ELSIF (steplVorabDrehen > STEP_0_E) THEN
	
    BasisStationsParameter.bVorabDrehenAbgeschlossen := FALSE;

    Drehen.bpStarteAbsolutPositionierung := FALSE;

    steplVorabDrehen := STEP_0_E;

END_IF
END_ACTION