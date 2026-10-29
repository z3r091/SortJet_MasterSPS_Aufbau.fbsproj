(* METADATA
{
	"v3Meta": {
		"objectGuid": "6f861453-b458-4238-88ac-910015f45ae7"
	}
}
*)
ACTION Taster
(***************************************************************************************************)
(* AKTION: TASTER *)
(***************************************************************************************************)

tonlTasterGlasbruch( IN := in_bTasterGlasBruch,
                     PT := ZEITLICHE_VERZOEGERUNG_TASTER_GLASBRUCH );

rtlTasterGlasbruch(CLK := tonlTasterGlasbruch.Q );


(* Hinweis:
   - Nachrichten ans MMI absetzen .
*)
IF (  rtlTasterGlasbruch.Q
  AND BasisStationsParameter.bAnlegen )
THEN
  blGlasBruchMeldungSperren := TRUE;

  wSps2MmiStationsNummer      := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
  wSPS2MMIStationEventStatus := cEVENT_STATUS_GLASBRUCH;
  MsgToMmi(auftragsnr_w       := SBO_SPS_STATIONSEVENT);

END_IF

(* Hinweis:
   - Sicherstellen das der Taster nicht oefter und somit faelschlicherweise gedrueckt wird
*)
rtlGlasBruchSperren( CLK := blGlasBruchMeldungSperren );

toflZeitlicheSperrungGlasbruch( IN:= rtlGlasBruchSperren.Q,
                                PT:=ZEITLICHE_SPERRUNG_TASTER_GLASBRUCH);

blGlasBruchMeldungSperren := FALSE;


(***************************************************************************************************)
(* AKTION: GLAS-Inspiziert *)
(***************************************************************************************************)
(* Hinweis:
   - Eingangsauswertung des Tasters "GlasAbgenommen"
*)
tonlTasterGlasInspiziert( IN := in_bTasterQuittierungGlasAbgenommen,
                          PT := ZEITLICHE_VERZOEGERUNG_TASTER_GLASABGENOMMEN );

rtlTasterGlasInspiziert(CLK := tonlTasterGlasInspiziert.Q );


(* Hinweis:
   - Nachrichten ans MMI absetzen .
*)
IF (  rtlTasterGlasInspiziert.Q ) THEN

  wSps2MmiStationsNummer      := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
  // TODO Neues Event für Scheibe inspiziert machen wSPS2MMIStationsStatusWord1 := cEVENT_STATUS_GLASABGENOMMEN;
  MsgToMmi(auftragsnr_w := SB0_SPS_STATIONSTATUS);

END_IF
END_ACTION