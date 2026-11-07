(* METADATA
{
	"v3Meta": {
		"objectGuid": "7781b6a3-e79b-44a6-add7-fce848d690e6"
	}
}
*)
ACTION Handfunktionen
//==================================================================================================
// AKTION HANDFUNKTIONEN
//==================================================================================================
// Hinweis (Bitverteilung einheitlich fuer alle Stationen, 4 Seiten zu 7 Knoepfen):
// - Bit 1 / 2 = Glastransport X vor / zurueck
// - Bit 3 / 4 = Glastransport Y vor / zurueck
// - Bit 5 / 6 = Hubrahmen heben / senken
IF ( blBetriebsartHand ) THEN

  // Glastransport X
  Glastransport_X.bpHandfahrenPlus  := (     ( dwlHandfunktionen.1 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
                                         AND NOT ( dwlHandfunktionen.2 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] ) );
  Glastransport_X.bpHandfahrenMinus := (     ( dwlHandfunktionen.2 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
                                         AND NOT ( dwlHandfunktionen.1 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] ) );

  // Glastransport Y
  Glastransport_Y.bpHandfahrenPlus  := dwlHandfunktionen.3 AND NOT dwlHandfunktionen.4;
  Glastransport_Y.bpHandfahrenMinus := dwlHandfunktionen.4 AND NOT dwlHandfunktionen.3;

  // Hubrahmen
  Hubrahmen.bpStartAusfahren := (     ( dwlHandfunktionen.5 OR bgVISUHubW1Auf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                  AND NOT ( dwlHandfunktionen.6 OR bgVISUHubW1Ab[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );
  Hubrahmen.bpStartEinfahren := (     ( dwlHandfunktionen.6 OR bgVISUHubW1Ab[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                  AND NOT ( dwlHandfunktionen.5 OR bgVISUHubW1Auf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );

ELSE
  Glastransport_X.bpHandfahrenPlus  := FALSE;
  Glastransport_X.bpHandfahrenMinus := FALSE;
  Glastransport_Y.bpHandfahrenPlus  := FALSE;
  Glastransport_Y.bpHandfahrenMinus := FALSE;

END_IF

HandfunktionenStatus();
END_ACTION