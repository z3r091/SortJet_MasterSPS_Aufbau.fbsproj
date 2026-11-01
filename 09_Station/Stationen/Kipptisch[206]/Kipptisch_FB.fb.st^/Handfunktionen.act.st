(* METADATA
{
  "v3Meta": {
    "objectGuid": "55298484-a1a3-451c-b458-c68b98392ec8"
  }
}
*)
ACTION Handfunktionen
(***************************************************************************************************)
(* AKTION HANDBETRIEB *)
(***************************************************************************************************)

IF ( blBetriebsartHand ) THEN

  (* Handfunktionen [Glastransport]
     - Handplus
     - Handminus
  *)
  Glastransport.bpHandfahrenPlus  := (        ( dwlHandfunktionen.0 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1])
                                       AND NOT ( dwlHandfunktionen.1 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] ) );  (* Bit 1 = Rollen / Riemen vor *)

  Glastransport.bpHandfahrenMinus := (        ( dwlHandfunktionen.1 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
                                       AND NOT ( dwlHandfunktionen.0 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] ) );  (* Bit 2 = Rollen / Riemen zurück *)

  (* Handfunktionen [Kippen]:
     - Positionieren auf Uebergabepositionen [Senkrecht 90 Grad / Waagerecht 0 Grad]
     - Referenzieren
  *)
  Kippen.bpReferenz := ((  dwlHandfunktionen.4
                          OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                         AND NOT (   dwlHandfunktionen.2
                                   OR dwlHandfunktionen.3
                                   OR bgVISUKippenUebergabePosition[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                   OR bgVISUKippenGrundstellung[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  blStartePositionWaagerecht := (( dwlHandfunktionen.2
                                   OR bgVISUKippenGrundstellung[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                   OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
                                  AND NOT (   dwlHandfunktionen.3
                                            OR dwlHandfunktionen.4
                                            OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                            OR bgVISUKippenUebergabePosition[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                            OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]));

  blStartePositionSenkrecht :=  (( dwlHandfunktionen.3
                                   OR bgVISUKippenUebergabePosition[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                   OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
                                  AND NOT (   dwlHandfunktionen.2
                                            OR dwlHandfunktionen.4
                                            OR bgVISUKippenGrundstellung[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                            OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                            OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]));


  (* Handfunktion:
     - Scheibenfuehrung \ Rollenleiste
  Rollenleiste.bpStarteOeffnen    := (        ( dwlHandfunktionen.5 OR bgVISUW1GlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
                                      AND NOT ( dwlHandfunktionen.6 OR bgVISUW1GlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]));

  Rollenleiste.bpStarteSchliessen := (        ( dwlHandfunktionen.6 OR bgVISUW1GlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
                                      AND NOT ( dwlHandfunktionen.5 OR bgVISUW1GlastransportOeffnungMaximal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]));
  *)


  (* Handfunktionen [Querfahrt]:
  *)
  Querfahrt.bpReferenz        := ( dwlHandfunktionen.9 OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                 AND NOT ( dwlHandfunktionen.7 OR dwlHandfunktionen.8 OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] );

  Querfahrt.bpHandfahrenPlus  := ( dwlHandfunktionen.7 OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                 AND NOT ( dwlHandfunktionen.8 OR dwlHandfunktionen.9 OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] );

  Querfahrt.bpHandfahrenMinus := ( dwlHandfunktionen.8 OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                 AND NOT ( dwlHandfunktionen.7 OR dwlHandfunktionen.9 OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] );


END_IF
END_ACTION