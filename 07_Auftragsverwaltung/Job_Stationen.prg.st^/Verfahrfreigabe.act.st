(* METADATA
{
	"v3Meta": {
		"objectGuid": "947d4714-9a33-4aa6-8a4d-61239e97d0f5"
	}
}
*)
ACTION Verfahrfreigabe
//-------------------------------------------------------------------------------------------------
// VERFAHRFREIGABE STATIONEN
//-------------------------------------------------------------------------------------------------
(* Hinweis [STATIONEN]:
   - Zurueck des Auftrags  "eStation_Vorabpositionierung" wenn dieser aktiv gewesen ist
     => Verfahrlogik
*)
FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
  IF  ( starrStationBasisParameter[wlIndex].bPositionierAuftragZuruecksetzen ) THEN
    IF ( AuftragsdatenStation[wlIndex].wAuftrag = eStation_Vorabpositionierung ) THEN
      starrStationBasisParameter[wlIndex].bQuittungPositionierungZurueckgesetzt := TRUE;
      AuftragsdatenStation[wlIndex].wAuftrag := eStation_Kein_Auftrag;
    END_IF
  END_IF
END_FOR
END_ACTION