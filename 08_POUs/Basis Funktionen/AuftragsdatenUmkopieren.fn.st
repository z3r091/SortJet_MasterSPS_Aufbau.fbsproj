(* METADATA
{
  "v3Meta": {
    "objectGuid": "c0c5d446-5c0c-4964-91ed-f4edd34c4197"
  }
}
*)
FUNCTION AuftragsdatenUmkopieren : Auftragsdaten_ST
VAR_INPUT

  // BOOL
  bpAuswahlTransferstation_2  : BOOL := FALSE;
  bpAnwahlDurchtransport : BOOL := FALSE;

  // STRUCT
  stpAuftrag : Auftragsdaten_ST;

END_VAR
VAR

  // STRUCT
  stMerkerAuftrag  : Auftragsdaten_ST;

END_VAR
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: LOGIK
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Auftrag zwischenspeichern
*)
stMerkerAuftrag := stpAuftrag;

(* Hinweis:
   - Auftrag manipulieren
*)
IF ( NOT bpAuswahlTransferstation_2 AND NOT bpAnwahlDurchtransport ) THEN

  stMerkerAuftrag.wStationsNr            := stpAuftrag.wTransferstationsNr1;
  stMerkerAuftrag.wStationsWand          := stpAuftrag.wTransferwand;
  stMerkerAuftrag.rStationsZielposition  := stpAuftrag.rTransferposition1;
  stMerkerAuftrag.rVorabPosition         := stpAuftrag.rTransferposition1;

  stMerkerAuftrag.wTransferstationsNr1   := stpAuftrag.wStationsNr;
  stMerkerAuftrag.rTransferposition1     := stpAuftrag.rStationsZielposition;
  stMerkerAuftrag.wTransferwand          := stpAuftrag.wStationsWand;

ELSIF ( bpAnwahlDurchtransport ) THEN

  stMerkerAuftrag.wStationsNr            := stpAuftrag.wTransferstationsNr2;
  stMerkerAuftrag.wStationsWand          := stpAuftrag.wTransferwand;
  stMerkerAuftrag.rStationsZielposition  := stpAuftrag.rTransferposition2;
  stMerkerAuftrag.rVorabPosition         := stpAuftrag.rTransferposition2;

  stMerkerAuftrag.wTransferstationsNr2   := stpAuftrag.wStationsNr;
  stMerkerAuftrag.rTransferposition2     := stpAuftrag.rStationsZielposition;
  stMerkerAuftrag.wTransferwand          := stpAuftrag.wStationsWand;

ELSE
  stMerkerAuftrag.wStationsNr            := stpAuftrag.wTransferstationsNr2;
  stMerkerAuftrag.wStationsWand          := stpAuftrag.wTransferwand;
  stMerkerAuftrag.rStationsZielposition  := stpAuftrag.rTransferposition2;
  stMerkerAuftrag.rVorabPosition         := stpAuftrag.rTransferposition2;

  stMerkerAuftrag.wTransferstationsNr1   := stpAuftrag.wStationsNr;
  stMerkerAuftrag.rTransferposition1     := stpAuftrag.rStationsZielposition;
  stMerkerAuftrag.wTransferwand          := stpAuftrag.wStationsWand;

END_IF

AuftragsdatenUmkopieren := stMerkerAuftrag;
END_FUNCTION