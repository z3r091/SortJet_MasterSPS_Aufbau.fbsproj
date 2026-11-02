(* METADATA
{
  "v3Meta": {
    "objectGuid": "8bd24ed0-de16-4e67-8106-77475cf2b6e3"
  }
}
*)
ACTION HandfunktionenStatus
// Aktive Handfunktionen mit der Bitbelegung des MMI-Befehls zurueckmelden.
IF    NOT BasisStationsParameter.stMKs.bDeaktivieren
      AND blBetriebsartHand
      AND NOT bgSimAktiv // Demo/Messe: Handbits kommen aus der Simulation -> nicht ans MMI melden
THEN
  dwpHandfunktionenReturn.0  := out_bGeblaese1Ein OR out_bGeblaese2Ein;
  dwpHandfunktionenReturn.1  := Glastransport.bpHandfahrenPlus;
  dwpHandfunktionenReturn.2  := Glastransport.bpHandfahrenMinus;
  dwpHandfunktionenReturn.5  := Hubrahmen.bpStartAusfahren;
  dwpHandfunktionenReturn.6  := Hubrahmen.bpStartEinfahren;
  dwpHandfunktionenReturn.18 := Messachse.bpHandplus;
  dwpHandfunktionenReturn.19 := Messachse.bpHandminus;
  dwpHandfunktionenReturn.20 := Messachse.bpReferenz;
  dwpHandfunktionenReturn.21 := Anschlag.bpStartAusfahren;
  dwpHandfunktionenReturn.22 := Anschlag.bpStartEinfahren;
ELSE
  dwpHandfunktionenReturn := 0;
END_IF

IF ( dwpHandfunktionenReturn <> dwlHandfunktionenZuletztGesendet ) THEN
  wSps2MmiStationsNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
  dwSps2MmiHandfunktionenStatus := dwpHandfunktionenReturn;
  MsgToMmi( auftragsnr_w := SB0_SPS_HANDFUNKTION_STATUS );

  dwlHandfunktionenZuletztGesendet := dwpHandfunktionenReturn;
END_IF
END_ACTION