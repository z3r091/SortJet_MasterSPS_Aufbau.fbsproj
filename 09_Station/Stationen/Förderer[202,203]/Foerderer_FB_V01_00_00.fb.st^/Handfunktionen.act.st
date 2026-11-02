(* METADATA
{
  "v3Meta": {
    "objectGuid": "bb6bda0b-01cb-4311-95b6-bfa542203b8e"
  }
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// AKTION HANDFUNKTIONEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Bitverteilung aus der Oberfläche (einheitlich fuer alle Stationen, 4 Seiten zu 7 Knoepfen):
     Seite 1:  0 Geblaese, 1/2 Glastransport vor/zurueck, 5/6 Hub auf/ab
     Seite 2:  7 Kippen 84 Grad, 8 Kippen 90 Grad, 11/12/13 Querfahrt vor/zurueck/Referenz
     Seite 3:  14/15/16 Oeffnung 16/23/29 mm (Roellchenleiste und Wandverstellung)
*)
IF ( blBetriebsartHand ) THEN

  // Handfunktion:
  //   - Gebläse an / aus
  IF ( dwlHandfunktionen.0
       OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
  THEN
    Geblaese.bpStart := TRUE;

  ELSIF NOT blNachSystemcheckMerker THEN
    Geblaese.bpStart := FALSE;

  END_IF
  
  
  // Glastranspoert
  Glastransport.bpHandfahrenPlus  := (         ( dwlHandfunktionen.1 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
                                       AND NOT ( dwlHandfunktionen.2 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] ) );  // Bit 1 = Glastransport / Glastransport vor

  Glastransport.bpHandfahrenMinus := (         ( dwlHandfunktionen.2 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
                                       AND NOT ( dwlHandfunktionen.1 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] ) );  // Bit 2 = Glastransport / Glastransport zurück


  // Kippen
  IF ( dwlHandfunktionen.8 OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
     AND NOT ( dwlHandfunktionen.7 OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
  THEN
    Kippen.epZielPosition := eKippen_Position_90Grad;
    Kippen.bpPositionieren := TRUE;

  ELSIF ( dwlHandfunktionen.7 OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
        AND NOT ( dwlHandfunktionen.8 OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
  THEN
    Kippen.epZielPosition := eKippen_Position_84Grad;
    Kippen.bpPositionieren := TRUE;
  ELSE
    Kippen.bpPositionieren := FALSE;
  END_IF

  
  // Hub
  Hub.bpStartHubAuf   := ( dwlHandfunktionen.5 OR bgVISUHubW1Auf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                         AND NOT ( dwlHandfunktionen.6 OR bgVISUHubW1Ab[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] );
  Hub.bpStartHubAb   := ( dwlHandfunktionen.6 OR bgVISUHubW1Ab[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                        AND NOT ( dwlHandfunktionen.5 OR bgVISUHubW1Auf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] );

  // Röllchenleiste
  IF     ( ( dwlHandfunktionen.14 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.15 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.16 OR bgVISUGlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) )
  THEN

    Roellchenleiste.epOeffnungsStellung := eZylinderStellung16mm;
    Roellchenleiste.bpStartPneumatik    := TRUE;

  ELSIF  ( ( dwlHandfunktionen.15 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.14 OR bgVISUGlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.16 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) )
  THEN

    Roellchenleiste.epOeffnungsStellung := eZylinderStellung23mm;
    Roellchenleiste.bpStartPneumatik    := TRUE;

  ELSIF  ( ( dwlHandfunktionen.16 OR bgVISUGlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.15 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.14 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) )
  THEN

    Roellchenleiste.epOeffnungsStellung := eZylinderStellung29mm;
    Roellchenleiste.bpStartPneumatik    := TRUE;

  ELSE

    Roellchenleiste.bpStartPneumatik    := FALSE;

  END_IF
  
  // Wandverstellung
  IF     ( ( dwlHandfunktionen.14 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.15 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.16 OR bgVISUGlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) )
  THEN

    Wandverstellung.epOeffnungsStellung := eZylinderStellung16mm;
    Wandverstellung.bpStartPneumatik    := TRUE;

  ELSIF  ( ( dwlHandfunktionen.15 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.14 OR bgVISUGlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.16 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) )
  THEN

    Wandverstellung.epOeffnungsStellung := eZylinderStellung23mm;
    Wandverstellung.bpStartPneumatik    := TRUE;

  ELSIF  ( ( dwlHandfunktionen.16 OR bgVISUGlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.15 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.14 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) )
  THEN

    Wandverstellung.epOeffnungsStellung := eZylinderStellung29mm;
    Wandverstellung.bpStartPneumatik    := TRUE;

  ELSE

    Wandverstellung.bpStartPneumatik    := FALSE;

  END_IF
  
  // Handfunktionen [Querfahrt]:
  Querfahrt.bpReferenz        := ( dwlHandfunktionen.13 OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                 AND NOT ( dwlHandfunktionen.11 OR dwlHandfunktionen.12 OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] );

  Querfahrt.bpHandfahrenPlus  := ( dwlHandfunktionen.11 OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                 AND NOT ( dwlHandfunktionen.12 OR dwlHandfunktionen.13 OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] );

  Querfahrt.bpHandfahrenMinus := ( dwlHandfunktionen.12 OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                 AND NOT ( dwlHandfunktionen.11 OR dwlHandfunktionen.13 OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] );

ELSE

  Glastransport.bpHandfahrenPlus := FALSE;
  Glastransport.bpHandfahrenMinus := FALSE;

END_IF

HandfunktionenStatus();
END_ACTION