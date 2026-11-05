(* METADATA
{
  "v3Meta": {
    "objectGuid": "7279c1d1-30d2-402b-85b2-2c9975b7161f"
  }
}
*)
ACTION HandfunktionenStatus
// Aktive Handfunktionen mit der Bitbelegung des MMI-Befehls zurueckmelden (siehe Aktion Handfunktionen).
IF    NOT BasisStationsParameter.stMKs.bDeaktivieren
      AND blBetriebsartHand
      AND NOT bgSimAktiv // Demo/Messe: Handbits kommen aus der Simulation -> nicht ans MMI melden
THEN
  dwpHandfunktionenReturn := 0;

  dwpHandfunktionenReturn.0  := Geblaese[cWAND_1].bpStart;

  // Glastransport je Wand: Wand 1 = Bit 1/2, Wand 2 = Bit 3/4
  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
    IF ( Glastransport[wlIndex].bpHandfahrenPlus ) THEN
      dwpHandfunktionenReturn := dwpHandfunktionenReturn OR SHL( DWORD#1, (wlIndex - 1) * 2 + 1 );
    END_IF
    IF ( Glastransport[wlIndex].bpHandfahrenMinus ) THEN
      dwpHandfunktionenReturn := dwpHandfunktionenReturn OR SHL( DWORD#1, (wlIndex - 1) * 2 + 2 );
    END_IF
  END_FOR

  dwpHandfunktionenReturn.7  := Kippen.bpPositionieren AND ( Kippen.epZielPosition = eKippen_Position_84Grad );
  dwpHandfunktionenReturn.8  := Kippen.bpPositionieren AND ( Kippen.epZielPosition = eKippen_Position_90Grad );
  dwpHandfunktionenReturn.9  := Kippen.bpPositionieren AND ( Kippen.epZielPosition = eKippen_Position_88_5Grad );
  dwpHandfunktionenReturn.10 := Kippen.bpReferenz;
  dwpHandfunktionenReturn.11 := Querfahrt.bpHandplus;
  dwpHandfunktionenReturn.12 := Querfahrt.bpHandminus;
  dwpHandfunktionenReturn.13 := Querfahrt.bpStartReferenz;
  dwpHandfunktionenReturn.14 := Wandverstellung[cWAND_1].bpStartePositionierung AND ( Wandverstellung[cWAND_1].epSollStellung = eZylinderStellung16mm );
  dwpHandfunktionenReturn.15 := Wandverstellung[cWAND_1].bpStartePositionierung AND ( Wandverstellung[cWAND_1].epSollStellung = eZylinderStellung23mm );
  dwpHandfunktionenReturn.17 := Zentralschmierung.bpStartSchmierungHand;

  // Greifer [Ausbaustufe]: Bit 18..27
  IF ( BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[cWAND_1] ) THEN
    dwpHandfunktionenReturn.18 := Greifer[cWAND_1].bpHandfahrenPlus;
    dwpHandfunktionenReturn.19 := Greifer[cWAND_1].bpHandfahrenMinus;
    dwpHandfunktionenReturn.20 := Greifer[cWAND_1].bpFahreReferenz;
    dwpHandfunktionenReturn.21 := Greifer[cWAND_1].bpHandGreiferAusfahren;
    dwpHandfunktionenReturn.22 := Greifer[cWAND_1].bpHandGreiferEinfahren;
    dwpHandfunktionenReturn.23 := Greifer[cWAND_1].bpHandZangeSchliessen;
    dwpHandfunktionenReturn.24 := Greifer[cWAND_1].bpHandZangeOeffnen16mm;
    dwpHandfunktionenReturn.25 := Greifer[cWAND_1].bpHandZangeOeffnen23mm;
    dwpHandfunktionenReturn.26 := Greifer[cWAND_1].bpHandZangeOeffnen29mm;
    dwpHandfunktionenReturn.27 := Greifer[cWAND_1].bpHandGlasRueckhalterAusfahren;
  END_IF
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