(* METADATA
{
	"v3Meta": {
		"objectGuid": "ab37f234-5c30-423e-82fd-562034963c76"
	}
}
*)
ACTION Auftragsverwaltung
(***************************************************************************************************)
(* BAUSTEIN: AUFTRAGSVERWALTUNG *)
(***************************************************************************************************)
FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO

  AuftragsSpeicherStation[wlIndex]();

  IF AuftragsSpeicherStation[wlIndex].bpAuftragverfuegbar
    AND ( AuftragsdatenStation[wlIndex].wAuftrag = eStation_Kein_Auftrag
       OR AuftragsdatenStation[wlIndex].wAuftrag = eStation_Belegt
       OR AuftragsdatenStation[wlIndex].wAuftrag = eStation_Warte_Auf_Eintransport )
  THEN
    AuftragsSpeicherStation[wlIndex].bpNaechsterAuftrag := TRUE;
    AuftragsSpeicherStation[wlIndex]();
    AuftragsdatenStation[wlIndex] := AuftragsSpeicherStation[wlIndex].AktAuftrag;
  END_IF
  
  FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO

    AuftragsSpeicherWand[wlIndex, wlIndexWand]();

    IF AuftragsSpeicherWand[wlIndex, wlIndexWand].bpAuftragverfuegbar
      AND ( AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag = eStation_Kein_Auftrag
         OR AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag = eStation_Belegt
         OR AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag = eStation_Warte_Auf_Eintransport
         OR AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag = eStation_Warte_Auf_Austransport  )
    THEN
      AuftragsSpeicherWand[wlIndex, wlIndexWand].bpNaechsterAuftrag := TRUE;
      AuftragsSpeicherWand[wlIndex, wlIndexWand]();
      AuftragsdatenWand[wlIndex, wlIndexWand] := AuftragsSpeicherWand[wlIndex, wlIndexWand].AktAuftrag;
    END_IF

  END_FOR

END_FOR
END_ACTION