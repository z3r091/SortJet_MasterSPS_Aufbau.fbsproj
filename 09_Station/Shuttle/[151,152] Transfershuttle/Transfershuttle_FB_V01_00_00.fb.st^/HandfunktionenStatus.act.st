(* METADATA
{
	"v3Meta": {
		"objectGuid": "64b2fc2c-f124-4862-8201-21bc728227d8"
	}
}
*)
ACTION HandfunktionenStatus
// Aktive Handfunktionen mit der Bitbelegung des MMI-Befehls zurueckmelden (siehe Aktion Handfunktionen).
IF    NOT BasisStationsParameter.stMKs.bDeaktivieren
      AND NOT BasisStationsParameter.bAutomatik
      AND NOT BasisStationsParameter.bReset
      AND NOT BasisStationsParameter.bCheck
      AND NOT BasisStationsParameter.bReferenz
      AND NOT bpScheibenNeuAusrichten
THEN
  dwpHandfunktionenReturn.1  := Glastransport.bpHandfahrenPlus;
  dwpHandfunktionenReturn.2  := Glastransport.bpHandfahrenMinus;
  dwpHandfunktionenReturn.5  := Glastransport.bpHandGlastransportAnheben;
  dwpHandfunktionenReturn.11 := Querfahrt.bpHandfahrenPlus;
  dwpHandfunktionenReturn.12 := Querfahrt.bpHandfahrenMinus;
  dwpHandfunktionenReturn.13 := Querfahrt.bpReferenz;
  dwpHandfunktionenReturn.17 := Zentralschmierung.bpStartSchmierungHand;
  dwpHandfunktionenReturn.21 := Glastransport.bpHandScheibenKontrolleEinlaufseiteAnheben;
  dwpHandfunktionenReturn.22 := Glastransport.bpHandScheibenKontrolleEinlaufseiteEin;
  dwpHandfunktionenReturn.23 := Glastransport.bpHandScheibenKontrolleAuslaufseiteAnheben;
  dwpHandfunktionenReturn.24 := Glastransport.bpHandScheibenKontrolleAuslaufseiteEin;
ELSE
  dwpHandfunktionenReturn := 0;
END_IF

IF ( dwpHandfunktionenReturn <> dwlHandfunktionenZuletztGesendet ) THEN
  wSps2MmiStationsNummer        := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
  dwSps2MmiHandfunktionenStatus := dwpHandfunktionenReturn;
  MsgToMmi( auftragsnr_w := SB0_SPS_SHUTTLEHANDFUNKTION_STATUS );

  dwlHandfunktionenZuletztGesendet := dwpHandfunktionenReturn;
END_IF
END_ACTION