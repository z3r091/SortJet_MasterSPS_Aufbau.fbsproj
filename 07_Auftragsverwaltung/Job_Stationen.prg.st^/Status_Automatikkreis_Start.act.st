(* METADATA
{
	"v3Meta": {
		"objectGuid": "48c1475d-7d1e-4064-b68a-f94b7224aadc"
	}
}
*)
ACTION Status_Automatikkreis_Start
//-------------------------------------------------------------------------------------------------
// AKTION: AUFTRAGSSTATUS SETZEN BEIM STARTEN DAS AUTOMATIKMODUS
//-------------------------------------------------------------------------------------------------

FOR wlIndexAutoStart := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  rtlStartAutomatik[wlIndexAutoStart](CLK := M_Automatik_Aktiv[wlIndexAutoStart] OR Visu_Start_Auto);

  IF ( rtlStartAutomatik[wlIndexAutoStart].Q ) THEN

    FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
      IF ( StationInAutomatikkreis(starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wlIndexAutoStart) ) THEN
      
        FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
          Job_Stationen.AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag := starrStationBasisParameter[wlIndex].pAuftragNachSystemcheck[wlIndexWand];
        END_FOR
    
      END_IF
    
    END_FOR
  
  END_IF

END_FOR
END_ACTION