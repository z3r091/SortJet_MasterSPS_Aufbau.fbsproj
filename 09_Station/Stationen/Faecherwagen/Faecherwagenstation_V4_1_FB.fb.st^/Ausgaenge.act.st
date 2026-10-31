(* METADATA
{
  "v3Meta": {
    "objectGuid": "258ed8b0-5c7b-451a-bf74-4bbae9c2d54b"
  }
}
*)
ACTION Ausgaenge
(***************************************************************************************************)
(* AUSGAENGE *)
(***************************************************************************************************)


(* ---------------------------------------------------------------------------------------
// STANDART AUSGAENGE 
//         
// Hinweis:
// - Hydraulik-Komponenten ansteuern 
// ---------------------------------------------------------------------------------------*)

(* Hinweis:
   - Auftrag aktiv
*)
bpAuftragAktiv := (  blBetriebsartCheck 
                  OR BasisStationsParameter.bEintransport[1] 
                  OR BasisStationsParameter.bAustransport[1] );

IF bpLichtschrankeWartetAufQuittierungAmOP THEN
  out_bSafetyLichtschrankeAusgeloest := gbFlashbit05sec;
ELSE
  out_bSafetyLichtschrankeAusgeloest := NOT bpLichtschranke_OK;
END_IF

(* Hinweis:
   - Baustein Schnittstelle
*)
bpOutBereitZumEintransport := bpStatusStationInBeladePosition;
bpOutBereitZumAustransport := bpStatusStationInBeladePosition;
tonlWagenInShuttleTransferposition(IN:=blLinearEinheitSH,PT:=t#1s);

ResetSchmersal();

(* ---------------------------------------------------------------------------------------
// OPTION - DEFAULT FAECHERWAGENSTATION 
//         
// Hinweis:
// - Hydraulik-Komponenten  
// ---------------------------------------------------------------------------------------*)

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
                       blGreiferOffen AND blRolltorUnten;

(* Hinweis:
   - FW Eeingeschleust 
*)
bpStatusStationInBeladePosition := blLinearEinheitSH AND blGreiferZu AND blRolltorUnten;
END_ACTION