(* METADATA
{
	"v3Meta": {
		"objectGuid": "93f70dca-1674-49cf-98fe-9b053c4590fe"
	}
}
*)
ACTION A_Eingaenge
//-------------------------------------------------------------------------------------------------
// HARDWARE EINGAENGE
//-------------------------------------------------------------------------------------------------
// Endlagen der Arretierung nur eindeutig auswerten (nicht durch Negieren einer einzelnen Abfrage)
blArretierungGeschlossen := in_bArretierungAusgefahren AND NOT in_bArretierungEingefahren;
blArretierungOffen       := in_bArretierungEingefahren AND NOT in_bArretierungAusgefahren;

tonlFWInBox( IN := in_bFaecherwagenVorhanden, PT := ZEIT_FW_IN_BOX );

rtlQuittierungEinschleusen( CLK := in_bStartSchleusen );

// Abrollsicherung ausgeloest: Schliessen des Rolltors sofort mit Fehler abbrechen
blRolltorAbBlockiert := NOT in_bAbrollsicherungOK;
END_ACTION