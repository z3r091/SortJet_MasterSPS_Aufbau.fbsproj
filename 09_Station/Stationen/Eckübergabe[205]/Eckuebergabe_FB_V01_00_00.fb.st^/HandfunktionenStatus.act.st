(* METADATA
{
  "v3Meta": {
    "objectGuid": "ff773ece-78bb-43ce-9bfe-9224d33f8eae"
  }
}
*)
ACTION HandfunktionenStatus
// Aktive Handfunktionen mit der Bitbelegung des MMI-Befehls zurueckmelden (siehe Aktion Handfunktionen).
IF    NOT BasisStationsParameter.stMKs.bDeaktivieren
      AND blBetriebsartHand
      AND NOT bgSimAktiv // Demo/Messe: Handbits kommen aus der Simulation -> nicht ans MMI melden
THEN
  dwpHandfunktionenReturn.1  := Glastransport_X.bpHandfahrenPlus;
  dwpHandfunktionenReturn.2  := Glastransport_X.bpHandfahrenMinus;
  dwpHandfunktionenReturn.3  := Glastransport_Y.bpHandfahrenPlus;
  dwpHandfunktionenReturn.4  := Glastransport_Y.bpHandfahrenMinus;
  dwpHandfunktionenReturn.5  := Hubrahmen.bpStartAusfahren;
  dwpHandfunktionenReturn.6  := Hubrahmen.bpStartEinfahren;
ELSE
  dwpHandfunktionenReturn := 0;
END_IF

IF ( dwpHandfunktionenReturn <> dwlHandfunktionenZuletztGesendet ) THEN
  wSps2MmiStationsNummer        := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
  dwSps2MmiHandfunktionenStatus := dwpHandfunktionenReturn;
  MsgToMmi( auftragsnr_w := SB0_SPS_HANDFUNKTION_STATUS );

  dwlHandfunktionenZuletztGesendet := dwpHandfunktionenReturn;
END_IF
END_ACTION