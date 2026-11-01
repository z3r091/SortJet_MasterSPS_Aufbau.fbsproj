(* METADATA
{
  "v3Meta": {
    "objectGuid": "19b5fe97-040e-4886-b8ab-acf485df7ed6"
  }
}
*)
ACTION Handfunktionen
(***************************************************************************************************)
(* HANDBETRIEB *)
(***************************************************************************************************)

IF ( blBetriebsartHand and not BasisStationsParameter.bVorabpositionieren ) THEN

  (* Handfunktionen:
     - Geblaese an/aus
  *)
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

  (* Handfunktionen:
     - Glastransport vor / zurück
  *)
  Glastransport.bpHandfahrenPlus  := (  ( dwlHandfunktionen.1 AND NOT dwlHandfunktionen.2 )
                                       OR ( bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, cWAND_1] AND NOT bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, cWAND_1]));

  Glastransport.bpHandfahrenMinus := (  ( dwlHandfunktionen.2 AND NOT dwlHandfunktionen.1 )
                                       OR ( bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, cWAND_1] AND NOT bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, cWAND_1]));  (* Bit 2 = Glastransport / Glastransport zurück *)

  (* Handfunktionen:
     - Drehbewegung zwischen 0 - 180 Grad 
  *)
  IF ( bgVISUDrehen0Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.7 )
     AND NOT (    dwlHandfunktionen.8
               OR dwlHandfunktionen.9
               OR dwlHandfunktionen.10 )
  THEN
    Drehen.epZielPosition := eDrehPosition0Grad;
    Drehen.bpStarteAbsolutPositionierung := TRUE;

  ELSIF ( bgVISUDrehen90Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.8 )
        AND NOT (    dwlHandfunktionen.7
                  OR dwlHandfunktionen.9
                  OR dwlHandfunktionen.10 )
  THEN
    Drehen.epZielPosition := eDrehPosition90Grad;
    Drehen.bpStarteAbsolutPositionierung := TRUE;

  ELSIF ( bgVISUDrehen180Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.9 )
        AND NOT (    dwlHandfunktionen.7
                  OR dwlHandfunktionen.8
                  OR dwlHandfunktionen.10 )
  THEN
    Drehen.epZielPosition := eDrehPosition180Grad;
    Drehen.bpStarteAbsolutPositionierung := TRUE;

  ELSIF ( bgVISUDrehen270Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.10 )
        AND NOT (    dwlHandfunktionen.7
                  OR dwlHandfunktionen.8
                  OR dwlHandfunktionen.9 )
  THEN
    Drehen.epZielPosition := eDrehPosition270Grad;
    Drehen.bpStarteAbsolutPositionierung := TRUE;

  ELSE
    Drehen.bpStarteAbsolutPositionierung := FALSE;

  END_IF

  (* Handfunktion:
     - Referentahrt Drehkreuz 
   *)
  Drehen.bpReferenz := (         ( dwlHandfunktionen.11 OR  bgVISUDrehenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern])
                         AND NOT (    dwlHandfunktionen.7
                                   OR dwlHandfunktionen.8
                                   OR dwlHandfunktionen.9
                                   OR dwlHandfunktionen.10
                                   OR bgVISUDrehen0Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern]
                                   OR bgVISUDrehen90Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern]
                                   OR bgVISUDrehen180Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern]
                                   OR bgVISUDrehen270Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] ));

  Drehen.bpHandZentrierungEinfahren := ( bgVISUZentrierbolzenEinfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.12 ) AND NOT dwlHandfunktionen.13;
  Drehen.bpHandZentrierungAusfahren := ( bgVISUZentrierbolzenAusfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerIntern] OR dwlHandfunktionen.13 ) AND NOT dwlHandfunktionen.12;

  (* Handfunktionen:
     - Drehen ( Hand plus und minus  )
  *)
  Drehen.bpHandfahrenPlus  := FALSE;
  Drehen.bpHandfahrenMinus := FALSE;


  (* Hinweis:
     - Kippen
  *)
  IF ( ( dwlHandfunktionen.6 OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT ( dwlHandfunktionen.5 OR dwlHandfunktionen.16 OR dwlHandfunktionen.15 OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) ) THEN

    Kippen.epZielPosition := eKippen_Position_84Grad;
    Kippen.bpPositionieren := TRUE;

  ELSIF ( ( dwlHandfunktionen.15 OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT ( dwlHandfunktionen.15 OR dwlHandfunktionen.16 OR dwlHandfunktionen.5 OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) ) THEN

    Kippen.epZielPosition := eKippen_Position_96Grad;
    Kippen.bpPositionieren := TRUE;

  ELSIF ( ( dwlHandfunktionen.5 OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT ( dwlHandfunktionen.6 OR dwlHandfunktionen.15 OR dwlHandfunktionen.6 OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) ) THEN

    Kippen.epZielPosition := eKippen_Position_90Grad;
    Kippen.bpPositionieren := TRUE;

  ELSE

    Kippen.bpPositionieren := FALSE;
  END_IF

  Kippen.bpReferenz := dwlHandfunktionen.17 OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

  (* Hinweis:
     - Wandverstellung
  *)
  IF     ( ( dwlHandfunktionen.3 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) 
           AND NOT ( dwlHandfunktionen.4 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])  )
  THEN

    Dickenverstellung.epOeffnungsStellung := eZylinderStellung16mm;
    Dickenverstellung.bpStartPneumatik    := TRUE;

  ELSIF  ( ( dwlHandfunktionen.4 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
           AND NOT ( dwlHandfunktionen.3 OR bgVISUGlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])  ) 
  THEN

    Dickenverstellung.epOeffnungsStellung := eZylinderStellung23mm;
    Dickenverstellung.bpStartPneumatik    := TRUE;

  ELSIF  ( ( dwlHandfunktionen.4 OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) 
           AND NOT ( dwlHandfunktionen.3 OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) ) 
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
                             OR dwlHandfunktionen.16 )
                            AND NOT (   dwlHandfunktionen.14
                                      OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                      OR dwlHandfunktionen.15
                                      OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandfahrenPlus := ((   bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                   OR dwlHandfunktionen.14 )
                                  AND NOT (   dwlHandfunktionen.15
                                            OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                            OR dwlHandfunktionen.16
                                            OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandfahrenMinus := ((   bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                    OR dwlHandfunktionen.15 )
                                   AND NOT (   dwlHandfunktionen.14
                                             OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                             OR dwlHandfunktionen.16
                                             OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

(*
  (* Hinweis:
     - Querachse
  *)
IF     ( ( dwlHandfunktionen.5 OR bgVISUW1QuerverstellungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
         AND NOT ( dwlHandfunktionen.6 OR bgVISUW1QuerverstellungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
         AND NOT ( dwlHandfunktionen.30 OR bgVISUW1QuerverstellungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]) )
THEN

  Querachse.epOeffnungsStellung := eZylinderStellung16mm;
  Querachse.bpStartPneumatik    := TRUE;

ELSIF  ( ( dwlHandfunktionen.6 OR bgVISUW1QuerverstellungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
         AND NOT ( dwlHandfunktionen.5 OR bgVISUW1QuerverstellungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
         AND NOT ( dwlHandfunktionen.30 OR bgVISUW1QuerverstellungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]) )
THEN

  Querachse.epOeffnungsStellung := eZylinderStellung23mm;
  Querachse.bpStartPneumatik    := TRUE;

ELSIF  ( ( dwlHandfunktionen.30 OR bgVISUW1QuerverstellungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
         AND NOT ( dwlHandfunktionen.5 OR bgVISUW1QuerverstellungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
         AND NOT ( dwlHandfunktionen.6 OR bgVISUW1QuerverstellungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]) )
THEN

  Querachse.epOeffnungsStellung := eZylinderStellung29mm;
  Querachse.bpStartPneumatik    := TRUE;

ELSE

  Querachse.bpStartPneumatik    := FALSE;

END_IF
*)
END_IF
END_ACTION