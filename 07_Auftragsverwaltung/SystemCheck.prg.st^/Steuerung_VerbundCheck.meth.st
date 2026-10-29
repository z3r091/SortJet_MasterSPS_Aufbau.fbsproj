(* METADATA
{
	"v3Meta": {
		"objectGuid": "2106329f-ce22-4754-a4e1-a7a15d593805"
	}
}
*)
METHOD PRIVATE Steuerung_VerbundCheck : BOOL
VAR_INPUT
  wpAutomatikkreis : WORD;
  wpZyklus         : WORD;
END_VAR

IF wpAutomatikkreis = cAUTOMATIKKREIS_1 THEN
 
 ; 
  
ELSIF wpAutomatikkreis = cAUTOMATIKKREIS_2 THEN
  // Verbund 205 und 204
  IF    starrStationBasisParameter[cSTATION_205].OutGlasTransport[cWAND_1].bEinlaufsensor
    AND starrStationBasisParameter[cSTATION_204].OutGlasTransport[cWAND_1].bAuslaufsensor
    AND NOT starrStationBasisParameter[cSTATION_205].bCheckMitNachfolger[cWAND_1]
  THEN
    starrStationBasisParameter[cSTATION_204].bCheckMitNachfolger[cWAND_1] := TRUE;
    starrStationBasisParameter[cSTATION_205].bCheckMitVorgaenger[cWAND_1] := TRUE;
  END_IF
  
  // Verbund 207 und 206
  IF    starrStationBasisParameter[cSTATION_207].OutGlasTransport[cWAND_1].bEinlaufsensor
    AND starrStationBasisParameter[cSTATION_206].OutGlasTransport[cWAND_1].bAuslaufsensor
    AND ( (starrStationBasisParameter[cSTATION_206].pAuftrag[cWAND_1].wAnzahlScheiben > 0 ) OR (starrStationBasisParameter[cSTATION_207].pAuftrag[cWAND_1].wAnzahlScheiben > 0 ))
    AND NOT starrStationBasisParameter[cSTATION_207].bCheckMitNachfolger[cWAND_1]
  THEN
    starrStationBasisParameter[cSTATION_206].bCheckMitNachfolger[cWAND_1] := TRUE;
    starrStationBasisParameter[cSTATION_207].bCheckMitVorgaenger[cWAND_1] := TRUE;
  END_IF
    
  // Verbund 208 und 207
  IF    starrStationBasisParameter[cSTATION_206].OutGlasTransport[cWAND_1].bEinlaufsensor
    AND starrStationBasisParameter[cSTATION_205].OutGlasTransport[cWAND_1].bAuslaufsensor
    AND NOT starrStationBasisParameter[cSTATION_206].bCheckMitNachfolger[cWAND_1]
  THEN
    starrStationBasisParameter[cSTATION_205].bCheckMitNachfolger[cWAND_1] := TRUE;
    starrStationBasisParameter[cSTATION_206].bCheckMitVorgaenger[cWAND_1] := TRUE;
  END_IF
  
ELSIF wpAutomatikkreis = cAUTOMATIKKREIS_3 THEN
  
  // Verbund 202 und 201
  IF    starrStationBasisParameter[cSTATION_202].OutGlasTransport[cWAND_1].bEinlaufsensor
    AND starrStationBasisParameter[cSTATION_201].OutGlasTransport[cWAND_1].bAuslaufsensor
    AND ( (starrStationBasisParameter[cSTATION_201].pAuftrag[cWAND_1].wAnzahlScheiben > 0 ) OR (starrStationBasisParameter[cSTATION_202].pAuftrag[cWAND_1].wAnzahlScheiben > 0 ))
    AND NOT starrStationBasisParameter[cSTATION_202].bCheckMitNachfolger[cWAND_1]
  THEN
    starrStationBasisParameter[cSTATION_201].bCheckMitNachfolger[cWAND_1] := TRUE;
    starrStationBasisParameter[cSTATION_202].bCheckMitVorgaenger[cWAND_1] := TRUE;
  END_IF

    
END_IF

Steuerung_VerbundCheck := TRUE;
END_METHOD