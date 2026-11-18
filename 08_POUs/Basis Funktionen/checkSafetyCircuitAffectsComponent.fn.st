(* METADATA
{
	"v3Meta": {
		"objectGuid": "b2891e00-4397-4c85-8733-7380e4011fc3"
	}
}
*)
FUNCTION checkSafetyCircuitAffectsComponent : BOOL
VAR_INPUT
  StationData  : REFERENCE TO StationBasisParameter_ST;
  SaftyCircuit : WORD;              // Sicherheitskreis
  eKomponente  : SK_Komponente_EN;  // Abgefragte Komponente (eSKKomponente_Alles = jeder SK zaehlt)
END_VAR
VAR
  wIndexMK : WORD := 0;
END_VAR
// Prueft, ob ein Sicherheitskreis die angegebene Komponente der Station abschaltet.
// - eSKKomponente_Alles: jeder SK der Station zaehlt -> TRUE
// - Standard (keine Teilabschaltung fuer diesen SK konfiguriert): SK schaltet alles ab -> TRUE
// - Mit Teilabschaltung: SK schaltet nur die markierten Komponenten ab

checkSafetyCircuitAffectsComponent := TRUE;

IF ( eKomponente = eSKKomponente_Alles ) THEN
  RETURN;
END_IF

FOR wIndexMK := 0 TO cANZAHL_SICHERHEITSKREISE DO
  IF     ( StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].eSicherheitskreis = SaftyCircuit )
     AND StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].bTeilabschaltung
  THEN
    CASE eKomponente OF
      eSKKomponente_Glastransport:   checkSafetyCircuitAffectsComponent := StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].bGlastransport;
      eSKKomponente_Geblaese:        checkSafetyCircuitAffectsComponent := StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].bGeblaese;
      eSKKomponente_Drehen:          checkSafetyCircuitAffectsComponent := StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].bDrehen;
      eSKKomponente_Kippen:          checkSafetyCircuitAffectsComponent := StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].bKippen;
      eSKKomponente_Querfahrt:       checkSafetyCircuitAffectsComponent := StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].bQuerfahrt;
      eSKKomponente_Pneumatik:       checkSafetyCircuitAffectsComponent := StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].bPneumatik;
      eSKKomponente_Greifer:         checkSafetyCircuitAffectsComponent := StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].bGreifer;
      eSKKomponente_Wandverstellung: checkSafetyCircuitAffectsComponent := StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].bWandverstellung;
      eSKKomponente_Messachse:       checkSafetyCircuitAffectsComponent := StationData.stMKs.astSicherheitskreisTeilabschaltung[wIndexMK].bMessachse;
    END_CASE
    RETURN;
  END_IF
END_FOR
END_FUNCTION