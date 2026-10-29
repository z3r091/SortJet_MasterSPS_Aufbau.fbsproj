(* METADATA
{
	"v3Meta": {
		"objectGuid": "d31da620-9df0-4563-ab06-3d7039f98cd3"
	}
}
*)
FUNCTION VisuHand_Sperre : BOOL
VAR_IN_OUT
  stBP : StationBasisParameter_ST;
  stH  : VisuHand_Station_ST;
END_VAR
VAR_INPUT
  bFaecherwagen : BOOL; // FW-Handfunktionen sind im FB nicht an die Betriebsart gebunden -> hier zusaetzlich bei Automatik sperren
END_VAR
VAR
  bDeaktiviert : BOOL;
END_VAR
IF __ISVALIDREF(stBP.stMKs) THEN
  bDeaktiviert := stBP.stMKs.bDeaktivieren;
END_IF

IF bDeaktiviert THEN
  stH.bGesperrt := TRUE;  stH.sSperrgrund := 'Gesperrt: Station deaktiviert';
ELSIF stBP.bAutomatik AND (bFaecherwagen OR NOT Global_Vars.bgSimAktiv) THEN
  stH.bGesperrt := TRUE;  stH.sSperrgrund := 'Gesperrt: Automatik aktiv';
ELSIF stBP.bReset THEN
  stH.bGesperrt := TRUE;  stH.sSperrgrund := 'Gesperrt: Reset läuft';
ELSIF stBP.bReferenz THEN
  stH.bGesperrt := TRUE;  stH.sSperrgrund := 'Gesperrt: Referenzfahrt läuft';
ELSIF stBP.bCheck THEN
  stH.bGesperrt := TRUE;  stH.sSperrgrund := 'Gesperrt: Systemcheck läuft';
ELSIF bFaecherwagen AND (stBP.bEintransport[cWAND_1] OR stBP.bAustransport[cWAND_1]) THEN
  stH.bGesperrt := TRUE;  stH.sSperrgrund := 'Gesperrt: Ein-/Ausschleusen aktiv';
ELSE
  stH.bGesperrt := FALSE;
  stH.sSperrgrund := SEL(stBP.bFreigabe, 'Hand frei - keine Sicherheitsfreigabe', 'Handbetrieb freigegeben');
END_IF

IF stH.bGesperrt THEN
  stH.dwSperrFarbe := VISU_UEBERSICHT.cFARBE_GRAU;
ELSIF NOT stBP.bFreigabe THEN
  stH.dwSperrFarbe := VISU_UEBERSICHT.cFARBE_ORANGE;
ELSE
  stH.dwSperrFarbe := VISU_UEBERSICHT.cFARBE_GRUEN;
END_IF
VisuHand_Sperre := stH.bGesperrt;
END_FUNCTION