(* METADATA
{
	"v3Meta": {
		"objectGuid": "459e7662-b525-457a-b096-99449b215dc1"
	}
}
*)
ACTION A_ScheibenDeaktivierteStationMelden
//-------------------------------------------------------------------------------------------------
// DEAKTIVIERTE STATION: SCHEIBEN AN MMI MELDEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Im Systemcheck meldet eine deaktivierte Station keine Scheiben auf der Station
   - Abgeleitete Bausteine ohne Scheibenverwaltung ueberschreiben diese Aktion
*)
IF ( BasisStationsParameter.bCheck ) THEN
  rSps2MmiMessungScheibenlaenge   := 0;
  wSps2MmiMessungStationNummer    := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
  wSps2MmiMessungSlotNummer       := 1;
  iSps2MmiMessungScheibenanzahl   := 0;

  MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );
END_IF
END_ACTION