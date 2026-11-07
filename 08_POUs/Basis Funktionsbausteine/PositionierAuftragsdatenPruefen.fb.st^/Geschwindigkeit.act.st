(* METADATA
{
	"v3Meta": {
		"objectGuid": "8852f6a0-b6e7-46f8-b500-7c90b457b163"
	}
}
*)
ACTION Geschwindigkeit
//_________________________________________________________________________
// ************************ START - Geschwindigkeit pruefen **************
//_________________________________________________________________________

(* Hinweis:
   - Pruefen der uebergebenen Geschwindigkeit
*)
IF ( pPositionierAuftragsdaten.rSollGeschwindigkeit > cNULL ) THEN

  wpgFehlerdaten[0] := pPositionierAuftragsdaten.wStationsNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(pPositionierAuftragsdaten.rSollGeschwindigkeit);
  wpgFehlerdaten[2] := REAL_TO_WORD( pAntriebsinformationen.rpMaxGeschwindigkeit );
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_FALSCHE_GESCHWINDIGKEIT,
            pPositionierAuftragsdaten.wStationsNummer,
            AutomatikkreisBestimmen(pPositionierAuftragsdaten.wStationsNummer),
            wpgFehlerdaten );

  bpErgebnis:=FALSE;
END_IF

IF ( pPositionierAuftragsdaten.rSollGeschwindigkeit <= pAntriebsinformationen.rpMaxGeschwindigkeit ) THEN

  wpgFehlerdaten[0] := pPositionierAuftragsdaten.wStationsNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD( pPositionierAuftragsdaten.rSollGeschwindigkeit );
  wpgFehlerdaten[2] := REAL_TO_WORD( pAntriebsinformationen.rpMaxGeschwindigkeit );
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_FALSCHE_GESCHWINDIGKEIT,
            pPositionierAuftragsdaten.wStationsNummer,
            AutomatikkreisBestimmen(pPositionierAuftragsdaten.wStationsNummer),
            wpgFehlerdaten );

  bpErgebnis:=FALSE;
END_IF

//_________________________________________________________________________
// ************************ ENDE - Geschwindigkeit pruefen ***************
//_________________________________________________________________________
END_ACTION