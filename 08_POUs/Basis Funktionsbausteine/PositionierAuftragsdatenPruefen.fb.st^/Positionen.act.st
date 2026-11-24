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

IF ( rpSollPosition > getRealShuttleMaxPos(wpStationsNummer) ) THEN

  wpgFehlerdaten[0] := wpStationsNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(getRealShuttleMaxPos(wpStationsNummer));
  wpgFehlerdaten[2] := REAL_TO_WORD(rpSollPosition);
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_ZIELPOSITION_ZU_GROSS,
            wpStationsNummer,
            AutomatikkreisBestimmen(wpStationsNummer),
            wpgFehlerdaten );

  bpErgebnis:=FALSE;
END_IF

IF ( rpSollPosition < getRealShuttleMinPos(wpStationsNummer) ) THEN

  wpgFehlerdaten[0] := wpStationsNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(getRealShuttleMinPos(wpStationsNummer));
  wpgFehlerdaten[2] := REAL_TO_WORD(rpSollPosition);
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_ZIELPOSITION_ZU_KLEIN,
            wpStationsNummer,
            AutomatikkreisBestimmen(wpStationsNummer),
            wpgFehlerdaten );

  bpErgebnis := FALSE;
END_IF

//_________________________________________________________________________
// ************************ ENDE - Position pruefen **********************
//_________________________________________________________________________
END_ACTION