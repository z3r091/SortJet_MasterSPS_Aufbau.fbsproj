(* METADATA
{
  "v3Meta": {
    "objectGuid": "1a45708a-46ce-48f5-a3b2-b0c20261c8e1",
    "properties": {
      "_3S.CoDeSys.CFCObject.CFCProperty": "<?xml version=\"1.0\" encoding=\"utf-8\"?><Single xml:space=\"preserve\" Type=\"{97c1f2ea-5995-48b9-abd5-a3ab983c5def}\" Method=\"IArchivable\"><Single Name=\"UseExplicitExecutionOrder\" Type=\"bool\">False</Single></Single>"
    }
  }
}
*)
FUNCTION checkSafetyCircuitsClosed : BOOL
VAR_INPUT
  StationData : REFERENCE TO StationBasisParameter_ST;
END_VAR
VAR
  arrCircuits : ARRAY[cERSTER_SICHERHEITSKREIS..cLETZTER_SICHERHEITSKREIS] OF BOOL;
  wIndex   : WORD := 0;
  wIndexMK : WORD := 0;
END_VAR
// It will checked if the safety circuit is activ

checkSafetyCircuitsClosed := TRUE;

FOR wIndex := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO
  arrCircuits[wIndex] := Sicherheitskreis[wIndex].bpSicherheitskreisGeschlossen;
END_FOR

FOR wIndex := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO
  FOR wIndexMK := 0 TO cANZAHL_SICHERHEITSKREISE DO
    IF ( wIndex = StationData.stMKs.eaSicherheitskreis[wIndexMK] ) THEN
      IF NOT arrCircuits[wIndex] THEN
        checkSafetyCircuitsClosed := FALSE;
      END_IF
    END_IF
  END_FOR
END_FOR
END_FUNCTION