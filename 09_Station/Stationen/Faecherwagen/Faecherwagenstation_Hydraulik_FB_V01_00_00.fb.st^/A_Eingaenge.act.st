(* METADATA
{
	"v3Meta": {
		"objectGuid": "240705b6-ae61-446d-8603-8bfdfc1bba02"
	}
}
*)
ACTION A_Eingaenge
//-------------------------------------------------------------------------------------------------
// HARDWARE EINGAENGE
//-------------------------------------------------------------------------------------------------
// Faecherwagen auf der Station: beide Muting-Sensoren belegt
blFaecherwagenErkannt := in_bMutingSensorLinks AND in_bMutingSensorRechts;
tonlMutingSensorenBelegt( IN := blFaecherwagenErkannt, PT := T#1S );

blAnschlagUntenOderOhne := in_bAnschlagUnten OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag;

tonlFWInBox( IN := in_bFWInAusrichtPosition, PT := ZEIT_FW_IN_BOX );

rtlQuittierungEinschleusen( CLK := in_bStartSchleusen );

// Rolltor: Abrollsicherung bricht das Schliessen ab (Aktion Rolltor)
blRolltorAbBlockiert :=     BasisStationsParameter.stMKs.stStationsAufbau.bRolltor
                        AND NOT in_bAbrollsicherungOK;

// RFID: Nummer des Faecherwagens bitweise vom Leser
bylRFID_Nummer.0 := in_bRFID_NR1;
bylRFID_Nummer.1 := in_bRFID_NR2;
bylRFID_Nummer.2 := in_bRFID_NR3;
bylRFID_Nummer.3 := in_bRFID_NR4;
bylRFID_Nummer.4 := in_bRFID_NR5;
bylRFID_Nummer.5 := in_bRFID_NR6;
bylRFID_Nummer.6 := in_bRFID_NR7;
bylRFID_Nummer.7 := in_bRFID_NR8;

IF ( in_bRFID_DataValid ) THEN
  wlRFID_Nummer := BYTE_TO_WORD( bylRFID_Nummer );
END_IF
END_ACTION