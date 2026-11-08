(* METADATA
{
	"v3Meta": {
		"objectGuid": "258ed8b0-5c7b-451a-bf74-4bbae9c2d54b"
	}
}
*)
ACTION Ausgaenge
//-------------------------------------------------------------------------------------------------
// AUSGAENGE
//-------------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------
// STANDART AUSGAENGE
//
// Hinweis:
// - Hydraulik-Komponenten ansteuern
// ---------------------------------------------------------------------------------------

(* Hinweis:
   - Auftrag aktiv
*)
bpAuftragAktiv := (  blBetriebartCheck 
                    OR BasisStationsParameter.bEintransport[1] 
                    OR BasisStationsParameter.bAustransport[1] );

// Leuchte Sicherheitskreis: Variante zeigt den Zustand der Lichtschranke
IF bpLichtschrankeWartetAufQuittierungAmOP THEN
  out_bSicherheitskreisAusgeloest := gbFlashbit05sec;
ELSE
  out_bSicherheitskreisAusgeloest := NOT bpLichtschranke_OK;
END_IF

(* Hinweis:
   - Baustein Schnittstelle
*)
bpOutBereitZumEintransport := bpStatusStationInBeladePosition;
bpOutBereitZumAustransport := bpStatusStationInBeladePosition;
tonlWagenInShuttleTransferposition(IN:=blLinearEinheitSH,PT:=t#1s);


// ---------------------------------------------------------------------------------------
// OPTION - DEFAULT FAECHERWAGENSTATION
//
// Hinweis:
// - Hydraulik-Komponenten
// ---------------------------------------------------------------------------------------

(* Hinweis:
   - FW in einer undefinierten Position
*)
blStationsposUndefiniert :=      NOT bpBoxInHomePosition
                                 AND NOT bpStatusStationInBeladePosition
                                 AND NOT bpAuftragAktiv;

(* Hinweis:
   - Homeposition
*)
bpBoxInHomePosition := in_bGegenhalterOffen AND
                       in_bEntriegelungGeschlossen AND
                       blLinearEinheitHinten AND
                       blGreiferOffen AND bpRolltorUnten;

(* Hinweis:
   - FW Eeingeschleust
*)
bpStatusStationInBeladePosition := blLinearEinheitSH AND blGreiferZu AND bpRolltorUnten;
END_ACTION