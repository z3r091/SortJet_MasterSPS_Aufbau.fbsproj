(* METADATA
{
	"v3Meta": {
		"objectGuid": "cfc81180-2ca7-4dd6-ae2b-44694cd50cb5"
	}
}
*)
ACTION Positionen
//_________________________________________________________________________
// ************************ START - Position pruefen *********************
//_________________________________________________________________________

IF ( pPositionierAuftragsdaten.rSollPosition > getRealShuttleMaxPos(pPositionierAuftragsdaten.wStationsNummer) ) THEN

  wpgFehlerdaten[0] := pPositionierAuftragsdaten.wStationsNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(getRealShuttleMaxPos(pPositionierAuftragsdaten.wStationsNummer));
  wpgFehlerdaten[2] := REAL_TO_WORD(pPositionierAuftragsdaten.rSollPosition);
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_ZIELPOSITION_ZU_GROSS,
            pPositionierAuftragsdaten.wStationsNummer,
            AutomatikkreisBestimmen(pPositionierAuftragsdaten.wStationsNummer),
            wpgFehlerdaten );

  bpErgebnis:=FALSE;
END_IF

IF ( pPositionierAuftragsdaten.rSollPosition < getRealShuttleMinPos(pPositionierAuftragsdaten.wStationsNummer) ) THEN

  wpgFehlerdaten[0] := pPositionierAuftragsdaten.wStationsNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(getRealShuttleMinPos(pPositionierAuftragsdaten.wStationsNummer));
  wpgFehlerdaten[2] := REAL_TO_WORD(pPositionierAuftragsdaten.rSollPosition);
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_ZIELPOSITION_ZU_KLEIN,
            pPositionierAuftragsdaten.wStationsNummer,
            AutomatikkreisBestimmen(pPositionierAuftragsdaten.wStationsNummer),
            wpgFehlerdaten );

  bpErgebnis := FALSE;
END_IF

//_________________________________________________________________________
// ************************ ENDE - Position pruefen **********************
//_________________________________________________________________________
END_ACTION