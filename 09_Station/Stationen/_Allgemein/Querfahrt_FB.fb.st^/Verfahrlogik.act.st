(* METADATA
{
  "v3Meta": {
    "objectGuid": "51231008-b5e0-439f-bcdb-1707bd2a2c2a"
  }
}
*)
ACTION Verfahrlogik
//-------------------------------------------------------------------------------------------------
// VERFAHRLOGIK
//-------------------------------------------------------------------------------------------------
IF (    blVerfahrfreigabe
     AND blAbbruchPositionierung
     AND bpQuittungAuftragsstatusZurueckgesetzt )
THEN
  blAbbruchPositionierung := FALSE;
  bpAuftragsstatusZuruecksetzen := FALSE;
  bpQuittungAuftragsstatusZurueckgesetzt := FALSE;

  wSps2MmiStationsNummer := stStationsNummern.NummerSPS;
  rSps2MmiShuttlePosition[0] := Antrieb.rpIstPosition;
  MsgToMmi(SB0_SPS_SHUTTLEVORABPOSITIONIERUNGREADY);

END_IF
END_ACTION