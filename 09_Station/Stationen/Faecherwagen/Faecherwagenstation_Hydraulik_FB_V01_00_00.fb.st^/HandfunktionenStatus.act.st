(* METADATA
{
	"v3Meta": {
		"objectGuid": "d09201a0-2e91-45c0-8710-c7eebfea65f3"
	}
}
*)
ACTION HandfunktionenStatus
// Aktive Handfunktionen mit der Bitbelegung des MMI-Befehls zurueckmelden (siehe Aktion Handfunktionen).
dwpHandfunktionenReturn := 0;

IF    NOT BasisStationsParameter.stMKs.bDeaktivieren
      AND NOT BasisStationsParameter.bEintransport[cWAND_1]
      AND NOT BasisStationsParameter.bAustransport[cWAND_1]
      AND NOT blBetriebartCheck
      AND NOT blPositionskorrekturAktiv
THEN
  dwpHandfunktionenReturn.0  := blHubrahmenHeben;
  dwpHandfunktionenReturn.1  := blHubrahmenSenken;
  dwpHandfunktionenReturn.2  := blFaecherwagenVor;
  dwpHandfunktionenReturn.3  := blFaecherwagenZurueck;
  dwpHandfunktionenReturn.5  := blRolltorAuf;
  dwpHandfunktionenReturn.6  := blRolltorAb;
  dwpHandfunktionenReturn.7  := blAnschlagAuf;
  dwpHandfunktionenReturn.8  := blAnschlagAb;
  dwpHandfunktionenReturn.9  := blAnschlagVor;
  dwpHandfunktionenReturn.10 := blAnschlagZurueck;
  dwpHandfunktionenReturn.11 := blZentrierungOeffnen;
  dwpHandfunktionenReturn.12 := blZentrierungSchliessen;
END_IF

IF ( dwpHandfunktionenReturn <> dwlHandfunktionenZuletztGesendet ) THEN
  wSps2MmiStationsNummer        := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
  dwSps2MmiHandfunktionenStatus := dwpHandfunktionenReturn;
  MsgToMmi( auftragsnr_w := SB0_SPS_HANDFUNKTION_STATUS );

  dwlHandfunktionenZuletztGesendet := dwpHandfunktionenReturn;
END_IF
END_ACTION