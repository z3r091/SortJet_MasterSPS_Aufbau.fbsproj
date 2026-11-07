(* METADATA
{
	"v3Meta": {
		"objectGuid": "c906ee2b-01ea-4766-9242-81080c10df91"
	}
}
*)
ACTION HandfunktionenStatus
// Aktive Handfunktionen mit der Bitbelegung des MMI-Befehls zurueckmelden (siehe Aktion Handfunktionen).
IF    NOT BasisStationsParameter.stMKs.bDeaktivieren
      AND blBetriebsartHand
      AND NOT bgSimAktiv // Demo/Messe: Handbits kommen aus der Simulation -> nicht ans MMI melden
THEN
  dwpHandfunktionenReturn.0  := out_bGeblaeseEin;
  dwpHandfunktionenReturn.1  := Glastransport.bpHandfahrenPlus;
  dwpHandfunktionenReturn.2  := Glastransport.bpHandfahrenMinus;
  dwpHandfunktionenReturn.7  := Kippen.bpPositionieren AND ( Kippen.epZielPosition = eKippen_Position_84Grad );
  dwpHandfunktionenReturn.8  := Kippen.bpPositionieren AND ( Kippen.epZielPosition = eKippen_Position_90Grad );
  dwpHandfunktionenReturn.18 := Messachse.bpHandplus;
  dwpHandfunktionenReturn.19 := Messachse.bpHandminus;
  dwpHandfunktionenReturn.20 := Messachse.bpHandReferenz;
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