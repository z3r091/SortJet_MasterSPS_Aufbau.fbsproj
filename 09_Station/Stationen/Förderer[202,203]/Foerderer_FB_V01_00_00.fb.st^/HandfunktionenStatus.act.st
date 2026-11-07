(* METADATA
{
	"v3Meta": {
		"objectGuid": "5c78d456-4b9b-4706-9ca6-5ff79f9455e9"
	}
}
*)
ACTION HandfunktionenStatus
// Aktive Handfunktionen mit der Bitbelegung des MMI-Befehls zurueckmelden (siehe Aktion Handfunktionen).
IF    NOT BasisStationsParameter.stMKs.bDeaktivieren
      AND blBetriebsartHand
      AND NOT bgSimAktiv // Demo/Messe: Handbits kommen aus der Simulation -> nicht ans MMI melden
THEN
  dwpHandfunktionenReturn.0  := Geblaese.bpStart;
  dwpHandfunktionenReturn.1  := Glastransport.bpHandfahrenPlus;
  dwpHandfunktionenReturn.2  := Glastransport.bpHandfahrenMinus;
  dwpHandfunktionenReturn.5  := Hub.bpStartHubAuf;
  dwpHandfunktionenReturn.6  := Hub.bpStartHubAb;
  dwpHandfunktionenReturn.7  := Kippen.bpPositionieren AND ( Kippen.epZielPosition = eKippen_Position_84Grad );
  dwpHandfunktionenReturn.8  := Kippen.bpPositionieren AND ( Kippen.epZielPosition = eKippen_Position_90Grad );
  dwpHandfunktionenReturn.11 := Querfahrt.bpHandfahrenPlus;
  dwpHandfunktionenReturn.12 := Querfahrt.bpHandfahrenMinus;
  dwpHandfunktionenReturn.13 := Querfahrt.bpReferenz;
  dwpHandfunktionenReturn.14 :=    ( Roellchenleiste.bpStartPneumatik AND ( Roellchenleiste.epOeffnungsStellung = eZylinderStellung16mm ) )
                                OR ( Wandverstellung.bpStartPneumatik AND ( Wandverstellung.epOeffnungsStellung = eZylinderStellung16mm ) );
  dwpHandfunktionenReturn.15 :=    ( Roellchenleiste.bpStartPneumatik AND ( Roellchenleiste.epOeffnungsStellung = eZylinderStellung23mm ) )
                                OR ( Wandverstellung.bpStartPneumatik AND ( Wandverstellung.epOeffnungsStellung = eZylinderStellung23mm ) );
  dwpHandfunktionenReturn.16 :=    ( Roellchenleiste.bpStartPneumatik AND ( Roellchenleiste.epOeffnungsStellung = eZylinderStellung29mm ) )
                                OR ( Wandverstellung.bpStartPneumatik AND ( Wandverstellung.epOeffnungsStellung = eZylinderStellung29mm ) );
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