(* METADATA
{
  "v3Meta": {
    "objectGuid": "7dc1fc60-b8b1-4708-bf8f-b3cd4cac9e42"
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
THEN
  dwpHandfunktionenReturn.1 := blArretierungOeffnen;
  dwpHandfunktionenReturn.2 := blArretierungSchliessen;
  dwpHandfunktionenReturn.5 := blRolltorAuf;
  dwpHandfunktionenReturn.6 := blRolltorAb;
END_IF

IF ( dwpHandfunktionenReturn <> dwlHandfunktionenZuletztGesendet ) THEN
  wSps2MmiStationsNummer        := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
  dwSps2MmiHandfunktionenStatus := dwpHandfunktionenReturn;
  MsgToMmi( auftragsnr_w := SB0_SPS_HANDFUNKTION_STATUS );

  dwlHandfunktionenZuletztGesendet := dwpHandfunktionenReturn;
END_IF
END_ACTION