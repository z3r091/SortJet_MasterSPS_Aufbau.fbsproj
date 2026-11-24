(* METADATA
{
	"v3Meta": {
		"objectGuid": "691bf0f6-0a88-4d0a-9736-fcf4e429c02d"
	}
}
*)
FUNCTION setFreigabeKomponenten : BOOL
VAR_INPUT
  StationData : REFERENCE TO StationBasisParameter_ST;
END_VAR
VAR
  blSKAuswerten : BOOL; // Station hat gueltige MK, ist aktiv und hat mindestens einen SK konfiguriert
END_VAR
// Setzt alle Freigaben der Station (stFreigabe):
// - bAlles: NotHalt OK und ALLE Sicherheitskreise der Station geschlossen
// - bX    : NotHalt OK und alle SKs geschlossen, die Komponente X abschalten
//           (SK ohne Teilabschaltung schaltet alles ab, SK mit Teilabschaltung nur die markierten Komponenten)
// - Ohne konfigurierten SK (oder Station deaktiviert / keine MK): nur NotHalt
// - bgSicherheitstechnikBruecken setzt alle Freigaben

blSKAuswerten := checkSafetyCircuitsConfigured(StationData);

StationData.stFreigabe.bAlles           := ( NotHalt.bpNotHaltOK AND ( NOT blSKAuswerten OR_ELSE checkSafetyCircuitsClosed(StationData, eSKKomponente_Alles) ) )           OR bgSicherheitstechnikBruecken;
StationData.stFreigabe.bGlastransport   := ( NotHalt.bpNotHaltOK AND ( NOT blSKAuswerten OR_ELSE checkSafetyCircuitsClosed(StationData, eSKKomponente_Glastransport) ) )   OR bgSicherheitstechnikBruecken;
StationData.stFreigabe.bGeblaese        := ( NotHalt.bpNotHaltOK AND ( NOT blSKAuswerten OR_ELSE checkSafetyCircuitsClosed(StationData, eSKKomponente_Geblaese) ) )        OR bgSicherheitstechnikBruecken;
StationData.stFreigabe.bDrehen          := ( NotHalt.bpNotHaltOK AND ( NOT blSKAuswerten OR_ELSE checkSafetyCircuitsClosed(StationData, eSKKomponente_Drehen) ) )          OR bgSicherheitstechnikBruecken;
StationData.stFreigabe.bKippen          := ( NotHalt.bpNotHaltOK AND ( NOT blSKAuswerten OR_ELSE checkSafetyCircuitsClosed(StationData, eSKKomponente_Kippen) ) )          OR bgSicherheitstechnikBruecken;
StationData.stFreigabe.bQuerfahrt       := ( NotHalt.bpNotHaltOK AND ( NOT blSKAuswerten OR_ELSE checkSafetyCircuitsClosed(StationData, eSKKomponente_Querfahrt) ) )       OR bgSicherheitstechnikBruecken;
StationData.stFreigabe.bPneumatik       := ( NotHalt.bpNotHaltOK AND ( NOT blSKAuswerten OR_ELSE checkSafetyCircuitsClosed(StationData, eSKKomponente_Pneumatik) ) )       OR bgSicherheitstechnikBruecken;
StationData.stFreigabe.bGreifer         := ( NotHalt.bpNotHaltOK AND ( NOT blSKAuswerten OR_ELSE checkSafetyCircuitsClosed(StationData, eSKKomponente_Greifer) ) )         OR bgSicherheitstechnikBruecken;
StationData.stFreigabe.bWandverstellung := ( NotHalt.bpNotHaltOK AND ( NOT blSKAuswerten OR_ELSE checkSafetyCircuitsClosed(StationData, eSKKomponente_Wandverstellung) ) ) OR bgSicherheitstechnikBruecken;
StationData.stFreigabe.bMessachse       := ( NotHalt.bpNotHaltOK AND ( NOT blSKAuswerten OR_ELSE checkSafetyCircuitsClosed(StationData, eSKKomponente_Messachse) ) )       OR bgSicherheitstechnikBruecken;

setFreigabeKomponenten := StationData.stFreigabe.bAlles;
END_FUNCTION