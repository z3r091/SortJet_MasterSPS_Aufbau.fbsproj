(* METADATA
{
	"v3Meta": {
		"objectGuid": "f525c379-17a0-48cc-ae6b-0b2e3cffb77f"
	}
}
*)
ACTION ToSLC
//-------------------------------------------------------------------------------------------------
// AKTION ToSLC
//-------------------------------------------------------------------------------------------------

// Reset EDM
bResetDurchSK := FALSE;
FOR wIndex := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO
  bResetDurchSK := bResetDurchSK OR toflSKQuittiert[wIndex].Q;
END_FOR

EV_ToSLC_bReset_EDM := NotHalt.in_bTasterNothaltQuittieren
                       OR bpVisuResetEDM
                       OR bResetDurchSK;

// Nothalt quittieren
EV_ToSLC_bReset_Nothalt := ( NotHalt.in_bTasterNothaltQuittieren AND NOT NotHalt.bpNotHaltOK )
                           OR bpVisuResetNothalt;

// Türen Freigeben
EV_ToSLC_Tueren_Freigeben := Tueren_Freigeben();

// Safety Auslösen
EV_ToSLC_SK_Ausloesen := Safety_Ausloesen();

// Meldung an SLC, NotHalt aus SPS OK
EV_ToSLC_Nothalt_OK_aus_PLC := bgNotHalt_SPS_OK;

// OP-Taster zur Quittierung der Lichtschranken
//EV_ToSLC_Taster_SK_Faecherwagen_Quittieren :=  SteuerungSicherheitskreise.in_bTasterSKFaecherwagenQuittieren OR VISU_VARS.bgVISUFWQuittierungLichtschranke[303] OR VISU_VARS.bgVISUFWQuittierungLichtschranke[302] OR VISU_VARS.bgVISUFWQuittierungLichtschranke[301];
END_ACTION