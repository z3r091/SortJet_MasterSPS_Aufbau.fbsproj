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
// Hinweis:
// - Bit 0 / 1 = Glastransport X vor / zurueck
// - Bit 2 / 3 = Glastransport Y vor / zurueck
// - Bit 4 / 5 = Hubrahmen heben / senken
IF ( blBetriebsartHand ) THEN

  // Glastransport X
  Glastransport_X.bpHandfahrenPlus  := (     ( dwlHandfunktionen.0 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
                                         AND NOT ( dwlHandfunktionen.1 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] ) );
  Glastransport_X.bpHandfahrenMinus := (     ( dwlHandfunktionen.1 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
                                         AND NOT ( dwlHandfunktionen.0 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] ) );

  // Glastransport Y
  Glastransport_Y.bpHandfahrenPlus  := dwlHandfunktionen.2 AND NOT dwlHandfunktionen.3;
  Glastransport_Y.bpHandfahrenMinus := dwlHandfunktionen.3 AND NOT dwlHandfunktionen.2;

  // Hubrahmen
  Hubrahmen.bpStartAusfahren := (     ( dwlHandfunktionen.4 OR bgVISUHubW1Auf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                  AND NOT ( dwlHandfunktionen.5 OR bgVISUHubW1Ab[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );
  Hubrahmen.bpStartEinfahren := (     ( dwlHandfunktionen.5 OR bgVISUHubW1Ab[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                  AND NOT ( dwlHandfunktionen.4 OR bgVISUHubW1Auf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );

ELSE
  Glastransport_X.bpHandfahrenPlus  := FALSE;
  Glastransport_X.bpHandfahrenMinus := FALSE;
  Glastransport_Y.bpHandfahrenPlus  := FALSE;
  Glastransport_Y.bpHandfahrenMinus := FALSE;

END_IF
END_ACTION