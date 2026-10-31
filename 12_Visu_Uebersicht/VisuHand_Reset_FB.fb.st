(* METADATA
{
  "v3Meta": {
    "objectGuid": "8e79010e-8dea-435f-8304-0b4307ea198e"
  }
}
*)
FUNCTION_BLOCK VisuHand_Reset_FB
(* Stations-Reset aus der Visu:
   - setzt BasisStationsParameter.bReset (die Station fuehrt ihre eigene Reset-Aktion aus und setzt bReset selbst zurueck)
   - nur ausserhalb der Automatik, nicht wenn die Station deaktiviert ist oder bereits ein Reset laeuft
*)
VAR_IN_OUT
  stBP : StationBasisParameter_ST;
  stH  : VisuHand_Station_ST;
END_VAR
VAR
  rtlTaster    : R_TRIG;
  bDeaktiviert : BOOL;
END_VAR
bDeaktiviert := FALSE;
IF __ISVALIDREF(stBP.stMKs) THEN
  bDeaktiviert := stBP.stMKs.bDeaktivieren;
END_IF

stH.bResetGesperrt := bDeaktiviert OR stBP.bAutomatik OR stBP.bReset OR stBP.bReferenz OR stBP.bCheck;

rtlTaster(CLK := stH.bResetTaster);
IF rtlTaster.Q AND NOT stH.bResetGesperrt THEN
  stBP.bReset := TRUE;
END_IF
END_FUNCTION_BLOCK