(* METADATA
{
	"v3Meta": {
		"objectGuid": "657d7773-50f6-4a46-b86f-6fc5131c38e4"
	}
}
*)
FUNCTION AuftragsdatenPruefen : BOOL
VAR_INPUT

  // WORD
  wpMmiNummer  : WORD; // Stationsnummer von der die Auftraege geprueft werden sollen
  wpWandNr     : WORD; // Wandnummer von der die Auftraege geprueft werden sollen

  // STRUKT
  pData   : Auftragsdaten_ST;

END_VAR
VAR
  Basis : REFERENCE TO StationBasisParameter_ST;
END_VAR
Basis REF= getBasis(wpMmiNummer);
AuftragsdatenPruefen := TRUE;

// Glaslänge
IF ( pData.rAuftragsLaenge > Basis.stMKs.stGlasdaten[wpWandNr].rlMaxGlasLaenge ) THEN
  wpgFehlerdaten[0] := wpMmiNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(Basis.stMKs.stGlasdaten[wpWandNr].rlMaxGlasLaenge);
  wpgFehlerdaten[2] := REAL_TO_WORD(pData.rAuftragsLaenge);
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_GLAS_ZU_LANG,
            wpMmiNummer,
            AutomatikkreisBestimmen(wpMmiNummer),
            wpgFehlerdaten );
  AuftragsdatenPruefen:=FALSE;
END_IF

IF ( pData.rAuftragsLaenge < Basis.stMKs.stGlasdaten[wpWandNr].rlMinGlasLaenge ) THEN
  wpgFehlerdaten[0] := wpMmiNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(Basis.stMKs.stGlasdaten[wpWandNr].rlMinGlasLaenge);
  wpgFehlerdaten[2] := REAL_TO_WORD(pData.rAuftragsLaenge);
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_GLAS_ZU_KURZ,
            wpMmiNummer,
            AutomatikkreisBestimmen(wpMmiNummer),
            wpgFehlerdaten );
  AuftragsdatenPruefen:=FALSE;
END_IF

// Glashöhe
IF ( pData.rAuftragsHoehe > Basis.stMKs.stGlasdaten[wpWandNr].rlMaxGlasHoehe ) THEN
  wpgFehlerdaten[0] := wpMmiNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(Basis.stMKs.stGlasdaten[wpWandNr].rlMaxGlasHoehe);
  wpgFehlerdaten[2] := REAL_TO_WORD(pData.rAuftragsHoehe);
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_GLAS_ZU_HOCH,
            wpMmiNummer,
            AutomatikkreisBestimmen(wpMmiNummer),
            wpgFehlerdaten );
  AuftragsdatenPruefen:=FALSE;
END_IF

IF ( pData.rAuftragsHoehe <  Basis.stMKs.stGlasdaten[wpWandNr].rlMinGlasHoehe ) THEN
  wpgFehlerdaten[0] := wpMmiNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(Basis.stMKs.stGlasdaten[wpWandNr].rlMinGlasHoehe);
  wpgFehlerdaten[2] := REAL_TO_WORD(pData.rAuftragsHoehe);
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_GLAS_ZU_NIEDRIG,
            wpMmiNummer,
            AutomatikkreisBestimmen(wpMmiNummer),
            wpgFehlerdaten );
  AuftragsdatenPruefen:=FALSE;
END_IF

// Glasdicke
IF ( pData.rAuftragsDicke > Basis.stMKs.stGlasdaten[wpWandNr].rlMaxGlasDicke ) THEN
  wpgFehlerdaten[0] := wpMmiNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(Basis.stMKs.stGlasdaten[wpWandNr].rlMaxGlasDicke);
  wpgFehlerdaten[2] := REAL_TO_WORD(pData.rAuftragsDicke);
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_GLAS_ZU_DICK,
            wpMmiNummer,
            AutomatikkreisBestimmen(wpMmiNummer),
            wpgFehlerdaten );
  AuftragsdatenPruefen := FALSE;
END_IF

IF ( pData.rAuftragsDicke < Basis.stMKs.stGlasdaten[wpWandNr].rlMinGlasDicke ) THEN
  wpgFehlerdaten[0] := wpMmiNummer;
  wpgFehlerdaten[1] := REAL_TO_WORD(Basis.stMKs.stGlasdaten[wpWandNr].rlMinGlasDicke);
  wpgFehlerdaten[2] := REAL_TO_WORD(pData.rAuftragsDicke);
  SpsError( eFehler_Station,
            cMELDUNG_AUFTRAGSDATEN_GLAS_ZU_DUENN,
            wpMmiNummer,
            AutomatikkreisBestimmen(wpMmiNummer),
            wpgFehlerdaten );
  AuftragsdatenPruefen := FALSE;
END_IF
END_FUNCTION