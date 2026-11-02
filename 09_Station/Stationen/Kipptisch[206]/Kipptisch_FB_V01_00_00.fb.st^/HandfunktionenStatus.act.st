(* METADATA
{
  "v3Meta": {
    "objectGuid": "9fd530ca-90ab-4a00-91ce-3ea95e189d55"
  }
}
*)
ACTION HandfunktionenStatus
// Aktive Handfunktionen mit der Bitbelegung des MMI-Befehls zurueckmelden (siehe Aktion Handfunktionen).
IF    NOT BasisStationsParameter.stMKs.bDeaktivieren
      AND blBetriebsartHand
      AND NOT bgSimAktiv // Demo/Messe: Handbits kommen aus der Simulation -> nicht ans MMI melden
THEN
  dwpHandfunktionenReturn.1  := Glastransport.bpHandfahrenPlus;
  dwpHandfunktionenReturn.2  := Glastransport.bpHandfahrenMinus;
  dwpHandfunktionenReturn.7  := blStartePositionWaagerecht;
  dwpHandfunktionenReturn.8  := blStartePositionSenkrecht;
  dwpHandfunktionenReturn.10 := Kippen.bpReferenz;
  dwpHandfunktionenReturn.11 := Querfahrt.bpHandfahrenPlus;
  dwpHandfunktionenReturn.12 := Querfahrt.bpHandfahrenMinus;
  dwpHandfunktionenReturn.13 := Querfahrt.bpReferenz;
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