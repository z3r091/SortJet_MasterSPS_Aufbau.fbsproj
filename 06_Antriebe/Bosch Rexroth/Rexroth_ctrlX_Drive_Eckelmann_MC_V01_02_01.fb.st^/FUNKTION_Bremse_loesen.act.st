(* METADATA
{
	"v3Meta": {
		"objectGuid": "8f122493-5427-4f74-8e27-0cfcccf91770"
	}
}
*)
ACTION FUNKTION_Bremse_loesen
IF bpBremseLoesen THEN

  CASE asteplSchritt[BREMSE_LOESEN] OF

    STEP_0_E:


      IF ppAntriebsInformationen.bpBremseLoesenFreigabe THEN
        SignalSteuerWort.15 := TRUE; // Bremse lösen
        IF bpBremseGeloest THEN
          asteplSchritt[BREMSE_LOESEN] := STEP_1000_E;        
        END_IF
      ELSE
        asteplSchritt[BREMSE_LOESEN] := STEP_900_E;
        blInternerFehler := TRUE;
        Antriebsfehler.wlBausteinFehlerNr := cKeineFreigabeZumBremseLoesen;
      END_IF

    STEP_900_E:
      ;

    STEP_1000_E:
      ;

  END_CASE


ELSE

  SignalSteuerWort.15 := FALSE;
  asteplSchritt[BREMSE_LOESEN] := STEP_0_E;

END_IF
END_ACTION