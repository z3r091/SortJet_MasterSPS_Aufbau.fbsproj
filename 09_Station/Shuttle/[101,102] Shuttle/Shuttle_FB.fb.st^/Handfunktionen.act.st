(* METADATA
{
	"v3Meta": {
		"objectGuid": "49e226a9-483e-4a6a-a285-cca9e251f6d7"
	}
}
*)
ACTION Handfunktionen
(***************************************************************************************************)
(* AKTION HANDBETRIEB *)
(***************************************************************************************************)
(* Hinweis:
   - Bitverteilung aus der Oberfläche:
*)
IF ( blBetriebsartHand ) THEN

  (* Handfunktion:
     - Gebläse an / aus 
  *)
  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO

    toflGeblaeseHandfahren[wlIndex]( IN := (    Glastransport[wlIndex].bpHandfahrenPlus
                                             OR Glastransport[wlIndex].bpHandfahrenMinus ),
                                     PT := T#15S );
  
    IF ( dwlHandfunktionen.0
      OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex]
      OR toflGeblaeseHandfahren[wlIndex].Q)
    THEN
      Geblaese[wlIndex].bpStart := TRUE;
  
    ELSIF ( NOT blNachSystemcheckMerker ) THEN
      Geblaese[wlIndex].bpStart := FALSE;
  
    END_IF

  END_FOR

  (* Handfunktion:
     - Glastransport vor / zurück
  *)
  FOR i := 0 TO 31 DO
      aHand[i] := (dwlHandfunktionen AND SHL(DWORD#1, i)) <> 0;
  END_FOR

  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  
      Glastransport[wlIndex].bpHandfahrenPlus :=
          (    aHand[(wlIndex - 1) * 2 + 1]
            OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] )
          AND NOT
          (    aHand[(wlIndex - 1) * 2 + 2]
            OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] );
  
      Glastransport[wlIndex].bpHandfahrenMinus :=
          (    aHand[(wlIndex - 1) * 2 + 2]
            OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] )
          AND NOT
          (    aHand[(wlIndex - 1) * 2 + 1]
            OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] );

      (* Arrays müssen existieren: bgVISUGlastransportWOeffnungMinimal[], Mittel[], Maximal[] *)
  
      IF (     ( aHand[21 + (wlIndex - 1) * 2]
              OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] )
         AND NOT
                ( aHand[22 + (wlIndex - 1) * 2]
              OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] ) )
      THEN
          Wandverstellung[wlIndex].epSollStellung         := eZylinderStellung16mm;
          Wandverstellung[wlIndex].bpStartePositionierung := TRUE;
  
      ELSIF (   ( aHand[22 + (wlIndex - 1) * 2]
               OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] )
          AND NOT
                 ( aHand[21 + (wlIndex - 1) * 2]
               OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] ) )
      THEN
          Wandverstellung[wlIndex].epSollStellung         := eZylinderStellung23mm;
          Wandverstellung[wlIndex].bpStartePositionierung := TRUE;
  
      ELSE
          Wandverstellung[wlIndex].bpStartePositionierung := FALSE;
          Wandverstellung[wlIndex].bpReferenz := FALSE;
      END_IF

  END_FOR

  (* Handfunktion:
     - Kippen 
  *)
  
  IF (( dwlHandfunktionen.5
        OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
        AND NOT (   dwlHandfunktionen.10
                 OR dwlHandfunktionen.6
                 OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]))
  THEN
  
    Kippen.epZielPosition := eKippen_Position_90Grad;
    Kippen.bpPositionieren := TRUE;
  
  ELSIF (( dwlHandfunktionen.6
        OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
        AND NOT (   dwlHandfunktionen.10
                 OR dwlHandfunktionen.5
                 OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]))
  THEN
  
    Kippen.epZielPosition := eKippen_Position_84Grad;
    Kippen.bpPositionieren := TRUE;
    
  ELSIF (( dwlHandfunktionen.10
        OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
        AND NOT (   dwlHandfunktionen.6
                 OR dwlHandfunktionen.5
                 OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]))
  THEN
      Kippen.bpReferenz := TRUE;
  
  ELSE
    Kippen.bpPositionieren := FALSE;
    Kippen.bpReferenz := FALSE;
  END_IF


  (* Handfunktionen [Kippen]:
     - Positionieren auf Uebergabepositionen [Senkrecht 90 Grad / Waagerecht 0 Grad]
     - Referenzieren
  *)
  (*
  IF ((  dwlHandfunktionen.6
      OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
      AND NOT (   dwlHandfunktionen.4
               OR dwlHandfunktionen.5
                 OR dwlHandfunktionen.3
                 OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippen_0_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
               OR bgVISUKippenUebergabePosition[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
               OR bgVISUKippenGrundstellung[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )))
  THEN
  
    Kippen.bpReferenz := TRUE;
  
  ELSIF (( dwlHandfunktionen.5
        OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
        AND NOT (   dwlHandfunktionen.4
                 OR dwlHandfunktionen.6
                 OR dwlHandfunktionen.3
                 OR bgVISUKippen_0_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]))
  THEN
  
    Kippen.epZielPosition := eKippen_Position_84Grad;
    Kippen.bpPositionieren := TRUE;
  
  ELSIF (( dwlHandfunktionen.4
        OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
        AND NOT (   dwlHandfunktionen.5
                 OR dwlHandfunktionen.6
                 OR dwlHandfunktionen.3
                 OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippen_0_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]))
  THEN
  
    Kippen.epZielPosition := eKippen_Position_90Grad;
    Kippen.bpPositionieren := TRUE;
  
  ELSIF (( dwlHandfunktionen.3
        OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
        AND NOT (   dwlHandfunktionen.5
                 OR dwlHandfunktionen.6
                 OR dwlHandfunktionen.4
                 OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippen_0_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]))
  THEN
  
    Kippen.epZielPosition := eKippen_Position_84Grad;
    Kippen.bpPositionieren := TRUE;
  
  ELSE
    Kippen.bpPositionieren := FALSE;
    Kippen.bpReferenz := FALSE;
  END_IF
*)

  (* Handfunktion [Querfahrt]:
     - Referenz
     - Handplus / Handminus 
  *)
  Querfahrt.bpStartReferenz := ((  dwlHandfunktionen.9
                                       OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                       AND NOT (   dwlHandfunktionen.7
                                                OR dwlHandfunktionen.8
                                                OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                                OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandplus := (( dwlHandfunktionen.7
                                 OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                 AND NOT (   dwlHandfunktionen.8
                                          OR dwlHandfunktionen.9
                                          OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                          OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandminus := (( dwlHandfunktionen.8
                                  OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
                                  AND NOT (    dwlHandfunktionen.7
                                            OR dwlHandfunktionen.9
                                            OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                            OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  // Starten der Zentralschmierung
  Zentralschmierung.bpStartSchmierungHand := (dwlHandfunktionen.13 OR bgVISUZentralschmierungStarten[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]);
  
ELSE
  Zentralschmierung.bpStartSchmierungHand := FALSE;

END_IF
END_ACTION