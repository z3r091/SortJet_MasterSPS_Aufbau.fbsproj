(* METADATA
{
	"v3Meta": {
		"objectGuid": "c6e29fd6-ba36-47ef-8c35-03485548b8fc"
	}
}
*)
FUNCTION checkSafetyCircuitsRequested : BOOL
VAR_INPUT
  StationData : REFERENCE TO StationBasisParameter_ST;
END_VAR
VAR
  arrCircuits : ARRAY[cERSTER_SICHERHEITSKREIS..cLETZTER_SICHERHEITSKREIS] OF BOOL;
  wIndex   : WORD := 0;
  wIndexMK : WORD := 0;
END_VAR

// It will checked if the safety circuit is requested

checkSafetyCircuitsRequested := TRUE;

FOR wIndex := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO
  arrCircuits[wIndex] :=         Sicherheitskreis[wIndex].bpSicherheitskreisGeschlossen
                                 AND NOT Sicherheitskreis[wIndex].bpAnforderungSKGestellt;
END_FOR

FOR wIndex := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO

  FOR wIndexMK := 0 TO cANZAHL_SICHERHEITSKREISE DO
    IF ( wIndex = StationData.stMKs.eaSicherheitskreis[wIndexMK] ) THEN
      IF NOT arrCircuits[wIndex] THEN
        checkSafetyCircuitsRequested := FALSE;
      END_IF
    END_IF
  END_FOR
END_FOR
END_FUNCTION