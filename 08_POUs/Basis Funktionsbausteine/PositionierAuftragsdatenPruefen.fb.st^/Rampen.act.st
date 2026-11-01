(* METADATA
{
  "v3Meta": {
    "objectGuid": "5f5a54a2-7101-44a8-8aaa-288e09b42753"
  }
}
*)
ACTION Rampen
//_________________________________________________________________________
// ************************ START - Rampen pruefen ***********************
//_________________________________________________________________________

(* Hinweis:
   - Pruefen das keine 0 Rampe uebergeben wird
     => Beschleunigungsrampe
*)
IF ( pPositionierAuftragsdaten.rBeschleunigungsrampe <= cNULL ) THEN

  wpgFehlerdaten[0] := pPositionierAuftragsdaten.wStationsNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(pPositionierAuftragsdaten.rBeschleunigungsrampe);
  wpgFehlerdaten[2] := REAL_TO_WORD( pAntriebsinformationen.rpMaxBeschleunigung );
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_FALSCHE_BESCHLEUNIGUNGSRAMPE,
            pPositionierAuftragsdaten.wStationsNummer,
            AutomatikkreisBestimmen(pPositionierAuftragsdaten.wStationsNummer),
            wpgFehlerdaten );

  bpErgebnis:=FALSE;
END_IF

IF ( pPositionierAuftragsdaten.rBeschleunigungsrampe > pAntriebsinformationen.rpMaxBeschleunigung ) THEN

  wpgFehlerdaten[0] := pPositionierAuftragsdaten.wStationsNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD( pPositionierAuftragsdaten.rBeschleunigungsrampe );
  wpgFehlerdaten[2] := REAL_TO_WORD( pAntriebsinformationen.rpMaxBeschleunigung );
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_FALSCHE_BESCHLEUNIGUNGSRAMPE,
            pPositionierAuftragsdaten.wStationsNummer,
            AutomatikkreisBestimmen(pPositionierAuftragsdaten.wStationsNummer),
            wpgFehlerdaten );

  bpErgebnis:=FALSE;
END_IF

(* Hinweis:
   - Pruefen das keine 0 Rampe uebergeben wird
     => Verzoegerungsrampe
*)
IF ( pPositionierAuftragsdaten.rVerzoegerungsrampe <= cNULL ) THEN

  wpgFehlerdaten[0] := pPositionierAuftragsdaten.wStationsNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(pPositionierAuftragsdaten.rVerzoegerungsrampe);
  wpgFehlerdaten[2] := REAL_TO_WORD( pAntriebsinformationen.rpMaxVerzoegerung );
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_FALSCHE_VERZOEGERUNGSRAMPE,
            pPositionierAuftragsdaten.wStationsNummer,
            AutomatikkreisBestimmen(pPositionierAuftragsdaten.wStationsNummer),
            wpgFehlerdaten );

  bpErgebnis := FALSE;
END_IF

IF ( pPositionierAuftragsdaten.rVerzoegerungsrampe > pAntriebsinformationen.rpMaxVerzoegerung ) THEN

  wpgFehlerdaten[0] := pPositionierAuftragsdaten.wStationsNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD( pPositionierAuftragsdaten.rBeschleunigungsrampe );
  wpgFehlerdaten[2] := REAL_TO_WORD( pAntriebsinformationen.rpMaxVerzoegerung );
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_FALSCHE_VERZOEGERUNGSRAMPE,
            pPositionierAuftragsdaten.wStationsNummer,
            AutomatikkreisBestimmen(pPositionierAuftragsdaten.wStationsNummer),
            wpgFehlerdaten );

  bpErgebnis:=FALSE;
END_IF

//_________________________________________________________________________
// ************************ START - Rampen pruefen ***********************
//_________________________________________________________________________
END_ACTION