(* METADATA
{
	"v3Meta": {
		"objectGuid": "c97c67c9-5e06-4086-aebd-8e091471f135"
	}
}
*)
FUNCTION_BLOCK Scheibenmessung_FB
VAR_INPUT

  // BOOL
  bpReset                             : BOOL;
  bpGlasvermessung                    : BOOL;
  bpDrehrichtungsumkehrMessung        : BOOL; // FALSE = Positive Drehrichtung , TRUE = Negative Drehrichtung
  bpAuswahlSensorVorabScheibenmessung : BOOL;

  // REAL 
  rpMessstrecke               : REAL;
  rpErwarteteScheibenLaenge   : REAL;
  rpFaktorBremswegverlaengern : REAL := 1.5;

  // POINTER
  ppAntrieb               : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_01;
  pbpEinlaufSensor        : REFERENCE TO BOOL;
  pbpVorstopSensor        : REFERENCE TO BOOL;
  ppAntriebsInformationen : REFERENCE TO AntriebsInformationen;

  // STRUCT
  stStationsNummern       : Station_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFehler                   : BOOL;
  bpGlasmessungAbgeschlossen : BOOL;

  // WORD
  wpFehlerNr                 : Fehlerkonstanten_EN;

  // REAL
  rpGemesseneGlaslaenge      : REAL;

END_VAR
VAR

  // REAL
  rlPositionAntriebBeiStart         : REAL;
  rlScheibenmessungErgebnis         : REAL;
  rlBremsWeg                        : REAL;
  rlMessergebnisMerker              : REAL;
  rlGefahrenerWeg                   : REAL;

  // STEPS
  steplGlasvermessung               : Steps_TE;

  // TRIGGER
  rtlMessung_OK                     : R_TRIG;



END_VAR

(***************************************************************************************************)
(* BAUSTEIN: SCHEIBENMESSUNG (LAENGE) *)
(***************************************************************************************************)
(* Hinweis:
   - Reset setzt alles zurueck
*)
IF ( bpReset ) THEN
  bpGlasvermessung := FALSE;
  bpReset          := FALSE;

  wpFehlerNr := 0;
  bpFehler   := FALSE;

  bpGlasmessungAbgeschlossen := FALSE;

ELSE
  Messung();

END_IF
END_FUNCTION_BLOCK