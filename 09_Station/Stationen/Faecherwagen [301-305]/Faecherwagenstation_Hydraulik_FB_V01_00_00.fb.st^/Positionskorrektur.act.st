(* METADATA
{
	"v3Meta": {
		"objectGuid": "be39eb48-ac5d-4e79-a100-3dbd5e88fbc1"
	}
}
*)
ACTION Positionskorrektur
//-------------------------------------------------------------------------------------------------
// POSITIONSKORREKTUR
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Der Hubrahmen sackt mit der Zeit ab, der Sensor oben kann dann abfallen
   - In der Beladeposition ohne Auftrag wird er nach der Wartezeit (dwgWarteZeitUeberwachungFaecherwagenPosition,
     Minuten) oder sofort beim Abfallen des Sensors oben nachgehoben
   - Nur in Automatik, damit Handfunktionen nicht gestoert werden
*)
blLadepositionOhneOben :=     NOT in_bHubrahmenOben
                          AND in_bFaecherwagenVorne
                          AND in_bZentrierungGeschlossen
                          AND blAnschlagUntenOderOhne;

tonlPositionskorrektur( IN := bpStatusStationInBeladePosition AND NOT bpAuftragAktiv AND NOT blPositionskorrekturAktiv,
                        PT := DWORD_TO_TIME( dwgWarteZeitUeberwachungFaecherwagenPosition * cMillisecToMinute ) );

rtlPositionskorrektur( CLK := tonlPositionskorrektur.Q OR blLadepositionOhneOben );

IF     rtlPositionskorrektur.Q
   AND blBetriebsartAutomatik
   AND NOT bpAuftragAktiv
   AND NOT BasisStationsParameter.stMKs.stStationsAufbau.bAGV // AGV-Betrieb ohne Hubrahmen
THEN
  blPositionskorrekturAktiv := TRUE;
END_IF

IF ( blPositionskorrekturAktiv ) THEN

  IF ( blHubrahmenHebenDone OR NOT blBetriebsartAutomatik OR bpAuftragAktiv OR BasisStationsParameter.bFehler ) THEN
    blHubrahmenHeben          := FALSE;
    blPositionskorrekturAktiv := FALSE;
  ELSE
    blHubrahmenHeben          := TRUE;
  END_IF

END_IF
END_ACTION