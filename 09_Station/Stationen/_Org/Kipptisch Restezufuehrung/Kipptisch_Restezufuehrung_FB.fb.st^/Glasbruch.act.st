(* METADATA
{
	"v3Meta": {
		"objectGuid": "d2c474c8-e900-4170-9b90-e4f27b3bae80"
	}
}
*)
ACTION Glasbruch
(***************************************************************************************************)
(* AKTION: GLASBRUCH *)
(***************************************************************************************************)

tonlTasterGlasbruch( IN := in_bTasterGlasBruch,
                     PT := ZEITLICHE_VERZOEGERUNG_TASTER_GLASBRUCH );

rtlTasterGlasbruch(CLK := tonlTasterGlasbruch.Q );


// Nachrichten ans MMI absetzen
IF (  rtlTasterGlasbruch.Q
  AND BasisStationsParameter.bAnlegen )
THEN
  blGlasBruchMeldungSperren := TRUE;

  wSps2MmiStationsNummer      := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
  wSPS2MMIStationEventStatus := cEVENT_STATUS_GLASBRUCH;
  MsgToMmi(auftragsnr_w       := SBO_SPS_STATIONSEVENT);

END_IF

// Sicherstellen das der Taster nicht öfter und somit fälschlicherweise gedrueckt wird
rtlGlasBruchSperren( CLK := blGlasBruchMeldungSperren );

toflZeitlicheSperrungGlasbruch( IN:= rtlGlasBruchSperren.Q,
                                PT:=ZEITLICHE_SPERRUNG_TASTER_GLASBRUCH);

blGlasBruchMeldungSperren := FALSE;
END_ACTION