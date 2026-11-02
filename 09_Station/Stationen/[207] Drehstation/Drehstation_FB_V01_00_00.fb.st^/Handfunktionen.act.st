(* METADATA
{
  "v3Meta": {
    "objectGuid": "19b5fe97-040e-4886-b8ab-acf485df7ed6"
  }
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// HANDBETRIEB
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Bitverteilung aus der Oberfläche (einheitlich fuer alle Stationen, 4 Seiten zu 7 Knoepfen):
     Seite 1:  0 Geblaese, 1/2 Glastransport vor/zurueck
     Seite 2:  7 Kippen 84 Grad, 8 Kippen 90 Grad, 9 Kippen 96 Grad, 10 Kippen Referenz,
               11/12/13 Querfahrt vor/zurueck/Referenz
     Seite 3:  14/15/16 Oeffnung 16/23/29 mm (Dickenverstellung)
     Seite 4:  21/22/23/24 Drehen 0/90/180/270 Grad, 25 Drehen Referenz, 26/27 Zentrierbolzen ein/aus
*)
IF ( blBetriebsartHand and not BasisStationsParameter.bVorabpositionieren ) THEN

  // Handfunktionen:
  //   - Geblaese an/aus
  toflGeblaeseHandfahren( IN := (    Glastransport.bpHandfahrenPlus
                                  OR Glastransport.bpHandfahrenMinus ),
                          PT := t#15s );

  IF ( dwlHandfunktionen.0
       OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, cWAND_1] OR toflGeblaeseHandfahren.Q )
  THEN
    Geblaese.bpStart := TRUE;
  ELSIF NOT blNachSystemcheckMerker THEN
    Geblaese.bpStart := FALSE;
  END_IF

  // Handfunktionen:
  //   - Glastransport vor / zurück
  Glastransport.bpHandfahrenPlus  := (  ( dwlHandfunktionen.1 AND NOT dwlHandfunktionen.2 )
                                       OR ( bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, cWAND_1] AND NOT bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, cWAND_1]));

  Glastransport.bpHandfahrenMinus := (  ( dwlHandfunktionen.2 AND NOT dwlHandfunktionen.1 )
                                       OR ( bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, cWAND_1] AND NOT bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, cWAND_1]));  // Bit 2 = Glastransport / Glastransport zurück

  // Handfunktionen:
  //   - Drehbewegung zwischen 0 - 270 Grad
  IF ( bgVISUDrehen0Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.21 )
     AND NOT (    dwlHandfunktionen.22
               OR dwlHandfunktionen.23
               OR dwlHandfunktionen.24 )
  THEN
    Drehen.epZielPosition := eDrehPosition0Grad;
    Drehen.bpStarteAbsolutPositionierung := TRUE;

  ELSIF ( bgVISUDrehen90Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.22 )
        AND NOT (    dwlHandfunktionen.21
                  OR dwlHandfunktionen.23
                  OR dwlHandfunktionen.24 )
  THEN
    Drehen.epZielPosition := eDrehPosition90Grad;
    Drehen.bpStarteAbsolutPositionierung := TRUE;

  ELSIF ( bgVISUDrehen180Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.23 )
        AND NOT (    dwlHandfunktionen.21
                  OR dwlHandfunktionen.22
                  OR dwlHandfunktionen.24 )
  THEN
    Drehen.epZielPosition := eDrehPosition180Grad;
    Drehen.bpStarteAbsolutPositionierung := TRUE;

  ELSIF ( bgVISUDrehen270Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.24 )
        AND NOT (    dwlHandfunktionen.21
                  OR dwlHandfunktionen.22
                  OR dwlHandfunktionen.23 )
  THEN
    Drehen.epZielPosition := eDrehPosition270Grad;
    Drehen.bpStarteAbsolutPositionierung := TRUE;

  ELSE
    Drehen.bpStarteAbsolutPositionierung := FALSE;

  END_IF

  // Handfunktion:
  //   - Referentahrt Drehkreuz
  Drehen.bpReferenz := (         ( dwlHandfunktionen.25 OR  bgVISUDrehenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern])
                         AND NOT (    dwlHandfunktionen.21
                                   OR dwlHandfunktionen.22
                                   OR dwlHandfunktionen.23
                                   OR dwlHandfunktionen.24
                                   OR bgVISUDrehen0Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern]
                                   OR bgVISUDrehen90Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern]
                                   OR bgVISUDrehen180Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern]
                                   OR bgVISUDrehen270Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] ));

  Drehen.bpHandZentrierungEinfahren := ( bgVISUZentrierbolzenEinfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.26 ) AND NOT dwlHandfunktionen.27;
  Drehen.bpHandZentrierungAusfahren := ( bgVISUZentrierbolzenAusfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.27 ) AND NOT dwlHandfunktionen.26;

  // Handfunktionen:
  //   - Drehen ( Hand plus und minus  )
  Drehen.bpHandfahrenPlus  := FALSE;
  Drehen.bpHandfahrenMinus := FALSE;


  (* Hinweis:
     - Kippen 84 Grad / 90 Grad / 96 Grad
  *)
  IF     ( dwlHandfunktionen.7 OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
         AND NOT (    dwlHandfunktionen.8
                   OR dwlHandfunktionen.9
                   OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                   OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
  THEN

    Kippen.epZielPosition := eKippen_Position_84Grad;
    Kippen.bpPositionieren := TRUE;

  ELSIF  ( dwlHandfunktionen.8 OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
         AND NOT (    dwlHandfunktionen.7
                   OR dwlHandfunktionen.9
                   OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                   OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
  THEN

    Kippen.epZielPosition := eKippen_Position_90Grad;
    Kippen.bpPositionieren := TRUE;

  ELSIF  ( dwlHandfunktionen.9 OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
         AND NOT (    dwlHandfunktionen.7
                   OR dwlHandfunktionen.8
                   OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                   OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
  THEN

    Kippen.epZielPosition := eKippen_Position_96Grad;
    Kippen.bpPositionieren := TRUE;

  ELSE

    Kippen.bpPositionieren := FALSE;
  END_IF

  Kippen.bpReferenz := dwlHandfunktionen.10 OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

  (* Hinweis:
     - Wandverstellung
  *)
  IF     ( ( dwlHandfunktionen.14 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.15 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.16 OR bgVISUGlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) )
  THEN

    Dickenverstellung.epOeffnungsStellung := eZylinderStellung16mm;
    Dickenverstellung.bpStartPneumatik    := TRUE;

  ELSIF  ( ( dwlHandfunktionen.15 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.14 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.16 OR bgVISUGlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) )
  THEN

    Dickenverstellung.epOeffnungsStellung := eZylinderStellung23mm;
    Dickenverstellung.bpStartPneumatik    := TRUE;

  ELSIF  ( ( dwlHandfunktionen.16 OR bgVISUGlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.14 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.15 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) )
  THEN

    Dickenverstellung.epOeffnungsStellung := eZylinderStellung29mm;
    Dickenverstellung.bpStartPneumatik    := TRUE;

  ELSE

    Dickenverstellung.bpStartPneumatik    := FALSE;

  END_IF

  (* Hinweis:
     - Handfunktionen der Querfahrt
  *)
  Querfahrt.bpReferenz := (( bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                             OR dwlHandfunktionen.13 )
                            AND NOT (   dwlHandfunktionen.11
                                      OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                      OR dwlHandfunktionen.12
                                      OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandfahrenPlus := ((   bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                   OR dwlHandfunktionen.11 )
                                  AND NOT (   dwlHandfunktionen.12
                                            OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                            OR dwlHandfunktionen.13
                                            OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandfahrenMinus := ((   bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                    OR dwlHandfunktionen.12 )
                                   AND NOT (   dwlHandfunktionen.11
                                             OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                             OR dwlHandfunktionen.13
                                             OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

END_IF

HandfunktionenStatus();
END_ACTION