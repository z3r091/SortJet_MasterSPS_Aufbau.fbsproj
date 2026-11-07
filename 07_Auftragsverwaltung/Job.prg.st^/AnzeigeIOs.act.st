(* METADATA
{
	"v3Meta": {
		"objectGuid": "d04d52b7-1e3a-4993-9efc-188db57c982e"
	}
}
*)
ACTION AnzeigeIOs
//-------------------------------------------------------------------------------------------------
// AKTION: ANZEIGE DER SPS I/O
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Anzeige der IO´s im MMI Service  WORT 0: 1 = sichtbar / 0 = unsichtbar
*)
IF ( M_SB0_MMI_IOANZEIGE_AKTIVIEREN_DEAKTIVIEREN ) THEN
  M_SB0_MMI_IOANZEIGE_AKTIVIEREN_DEAKTIVIEREN := FALSE;

  TCPMain.bpIOAnzeigeAktivieren := tMmi2SpsInfo.wlIOsAnzeigeAktivierenDeaktivieren.0;

END_IF
END_ACTION