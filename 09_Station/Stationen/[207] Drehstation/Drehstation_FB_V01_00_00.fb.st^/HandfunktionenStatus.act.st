(* METADATA
{
	"v3Meta": {
		"objectGuid": "ca6aa052-a1c4-4350-9351-9af6d0e12aba"
	}
}
*)
ACTION HandfunktionenStatus
// Aktive Handfunktionen mit der Bitbelegung des MMI-Befehls zurueckmelden (siehe Aktion Handfunktionen).
IF    NOT BasisStationsParameter.stMKs.bDeaktivieren
      AND blBetriebsartHand
      AND NOT BasisStationsParameter.bVorabpositionieren
      AND NOT bgSimAktiv // Demo/Messe: Handbits kommen aus der Simulation -> nicht ans MMI melden
THEN
  dwpHandfunktionenReturn.0  := Geblaese.bpStart;
  dwpHandfunktionenReturn.1  := Glastransport.bpHandfahrenPlus;
  dwpHandfunktionenReturn.2  := Glastransport.bpHandfahrenMinus;
  dwpHandfunktionenReturn.7  := Kippen.bpPositionieren AND ( Kippen.epZielPosition = eKippen_Position_84Grad );
  dwpHandfunktionenReturn.8  := Kippen.bpPositionieren AND ( Kippen.epZielPosition = eKippen_Position_90Grad );
  dwpHandfunktionenReturn.9  := Kippen.bpPositionieren AND ( Kippen.epZielPosition = eKippen_Position_96Grad );
  dwpHandfunktionenReturn.10 := Kippen.bpReferenz;
  dwpHandfunktionenReturn.11 := Querfahrt.bpHandfahrenPlus;
  dwpHandfunktionenReturn.12 := Querfahrt.bpHandfahrenMinus;
  dwpHandfunktionenReturn.13 := Querfahrt.bpReferenz;
  dwpHandfunktionenReturn.14 := Dickenverstellung.bpStartPneumatik AND ( Dickenverstellung.epOeffnungsStellung = eZylinderStellung16mm );
  dwpHandfunktionenReturn.15 := Dickenverstellung.bpStartPneumatik AND ( Dickenverstellung.epOeffnungsStellung = eZylinderStellung23mm );
  dwpHandfunktionenReturn.16 := Dickenverstellung.bpStartPneumatik AND ( Dickenverstellung.epOeffnungsStellung = eZylinderStellung29mm );
  dwpHandfunktionenReturn.21 := Drehen.bpStarteAbsolutPositionierung AND ( Drehen.epZielPosition = eDrehPosition0Grad );
  dwpHandfunktionenReturn.22 := Drehen.bpStarteAbsolutPositionierung AND ( Drehen.epZielPosition = eDrehPosition90Grad );
  dwpHandfunktionenReturn.23 := Drehen.bpStarteAbsolutPositionierung AND ( Drehen.epZielPosition = eDrehPosition180Grad );
  dwpHandfunktionenReturn.24 := Drehen.bpStarteAbsolutPositionierung AND ( Drehen.epZielPosition = eDrehPosition270Grad );
  dwpHandfunktionenReturn.25 := Drehen.bpReferenz;
  dwpHandfunktionenReturn.26 := Drehen.bpHandZentrierungEinfahren;
  dwpHandfunktionenReturn.27 := Drehen.bpHandZentrierungAusfahren;
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