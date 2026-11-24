(* METADATA
{
	"v3Meta": {
		"objectGuid": "5621efb7-cd40-4c15-9d03-482a92cbc1a2"
	}
}
*)
ACTION FUNKTION_Absolut_setzen
IF bpAbsolutSetzen THEN

  CASE asteplSchritt[ABSOLUT_SETZEN] OF

    STEP_0_E:
      bpAbsolutSetzenDone := FALSE;
      blReferenzLoeschen := TRUE; // Referenz ablöschen
      IF NOT bpIstReferenziert THEN
        blReferenzLoeschen := FALSE; // Referenz ablöschen
        asteplSchritt[ABSOLUT_SETZEN] := STEP_10_E;
      END_IF

    STEP_10_E:
      blReferenzSetzen := TRUE; //Referenz setzen
      IF bpIstReferenziert THEN
        blReferenzSetzen := FALSE;
        asteplSchritt[ABSOLUT_SETZEN] := STEP_1000_E;
      END_IF

    STEP_900_E:
      ;

    STEP_1000_E:
      bpAbsolutSetzenDone := TRUE;

  END_CASE


ELSE
  bpAbsolutSetzenDone := FALSE;
  blReferenzLoeschen := FALSE;
  blReferenzSetzen   := FALSE;
  asteplSchritt[ABSOLUT_SETZEN] := STEP_0_E;

END_IF
END_ACTION