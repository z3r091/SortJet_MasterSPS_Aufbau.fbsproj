(* METADATA
{
	"v3Meta": {
		"objectGuid": "0769b6d9-be20-4ea2-bfb6-95784b8738dc"
	}
}
*)
ACTION HandfunktionenStatus
// Aktive Handfunktionen mit der Bitbelegung des MMI-Befehls zurueckmelden (siehe Aktion Handfunktionen).
IF    NOT BasisStationsParameter.stMKs.bDeaktivieren
      AND NOT BasisStationsParameter.bEintransport[1]
      AND NOT BasisStationsParameter.bAustransport[1]
      AND NOT blBetriebartCheck
      AND NOT bgSimAktiv // Demo/Messe: Handbits kommen aus der Simulation -> nicht ans MMI melden
THEN
  dwpHandfunktionenReturn.0  := blGegenhalterOeffnen;
  dwpHandfunktionenReturn.1  := blGegenhalterSchliessen;
  dwpHandfunktionenReturn.2  := blEntriegelungSchliessen;
  dwpHandfunktionenReturn.3  := blEntriegelungOeffnen;
  dwpHandfunktionenReturn.5  := blRolltorAuf;
  dwpHandfunktionenReturn.6  := blRolltorAb;
  dwpHandfunktionenReturn.7  := blLineareinheitVor;
  dwpHandfunktionenReturn.8  := blLineareinheitZurueck;
  dwpHandfunktionenReturn.9  := blLineareinheitShuttle;
  dwpHandfunktionenReturn.11 := blGreiferOeffnen;
  dwpHandfunktionenReturn.12 := blGreiferSchliessen;
ELSE
  dwpHandfunktionenReturn := 0;
END_IF

IF ( dwpHandfunktionenReturn <> dwlHandfunktionenZuletztGesendet ) THEN
  wSps2MmiStationsNummer        := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
  dwSps2MmiHandfunktionenStatus := dwpHandfunktionenReturn;
  MsgToMmi( auftragsnr_w := SB0_SPS_HANDFUNKTION_STATUS );

  dwlHandfunktionenZuletztGesendet := dwpHandfunktionenReturn;
END_IF
END_ACTION