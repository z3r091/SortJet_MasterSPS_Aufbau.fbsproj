(* METADATA
{
  "v3Meta": {
    "objectGuid": "49e226a9-483e-4a6a-a285-cca9e251f6d7"
  }
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// AKTION HANDBETRIEB
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Bitverteilung aus der Oberfläche (einheitlich fuer alle Stationen, 4 Seiten zu 7 Knoepfen):
     Seite 1:  0 Geblaese, 1/2 Glastransport Wand 1 vor/zurueck, 3/4 Glastransport Wand 2 vor/zurueck
     Seite 2:  7 Kippen 84 Grad, 8 Kippen 90 Grad, 9 Kippen 88,5 Grad, 10 Kippen Referenz,
               11/12/13 Querfahrt vor/zurueck/Referenz
     Seite 3:  14/15 Oeffnung 16/23 mm, 17 Zentralschmierung
*)
IF ( blBetriebsartHand ) THEN

  // Handfunktion:
  //   - Gebläse an / aus
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

  // Handfunktion:
  //   - Glastransport vor / zurück
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

    // Arrays müssen existieren: bgVISUGlastransportWOeffnungMinimal[], Mittel[], Maximal[]
    // Die Handbits der Oeffnung gelten fuer alle Waende (wandweise Belegung kommt mit B1)

    IF (     ( aHand[14]
               OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] )
         AND NOT
         ( aHand[15]
           OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] ) )
    THEN
      Wandverstellung[wlIndex].epSollStellung         := eZylinderStellung16mm;
      Wandverstellung[wlIndex].bpStartePositionierung := TRUE;

    ELSIF (   ( aHand[15]
                OR bgVISUGlastransportOeffnungMittel[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] )
            AND NOT
            ( aHand[14]
              OR bgVISUGlastransportOeffnungMinimal[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] ) )
    THEN
      Wandverstellung[wlIndex].epSollStellung         := eZylinderStellung23mm;
      Wandverstellung[wlIndex].bpStartePositionierung := TRUE;

    ELSE
      Wandverstellung[wlIndex].bpStartePositionierung := FALSE;
      Wandverstellung[wlIndex].bpReferenz := FALSE;
    END_IF

  END_FOR

  // Handfunktion:
  //   - Kippen 84 Grad / 90 Grad / 88,5 Grad
  //   - Referenz
  IF (( dwlHandfunktionen.7
        OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
       AND NOT (   dwlHandfunktionen.8
                 OR dwlHandfunktionen.9
                 OR dwlHandfunktionen.10
                 OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippen_88_5_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                 OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]))
  THEN

    Kippen.epZielPosition := eKippen_Position_84Grad;
    Kippen.bpPositionieren := TRUE;

  ELSIF (( dwlHandfunktionen.8
           OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
          AND NOT (   dwlHandfunktionen.7
                    OR dwlHandfunktionen.9
                    OR dwlHandfunktionen.10
                    OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                    OR bgVISUKippen_88_5_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                    OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]))
  THEN

    Kippen.epZielPosition := eKippen_Position_90Grad;
    Kippen.bpPositionieren := TRUE;

  ELSIF (( dwlHandfunktionen.9
           OR bgVISUKippen_88_5_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
          AND NOT (   dwlHandfunktionen.7
                    OR dwlHandfunktionen.8
                    OR dwlHandfunktionen.10
                    OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                    OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                    OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]))
  THEN

    Kippen.epZielPosition := eKippen_Position_88_5Grad;
    Kippen.bpPositionieren := TRUE;

  ELSIF (( dwlHandfunktionen.10
           OR bgVISUKippenReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
          AND NOT (   dwlHandfunktionen.7
                    OR dwlHandfunktionen.8
                    OR dwlHandfunktionen.9
                    OR bgVISUKippen_84_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                    OR bgVISUKippen_90_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                    OR bgVISUKippen_88_5_Grad[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]))
  THEN
    Kippen.bpReferenz := TRUE;

  ELSE
    Kippen.bpPositionieren := FALSE;
    Kippen.bpReferenz := FALSE;
  END_IF

  // Handfunktion [Querfahrt]:
  //   - Referenz
  //   - Handplus / Handminus
  Querfahrt.bpStartReferenz := ((  dwlHandfunktionen.13
                                  OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                 AND NOT (   dwlHandfunktionen.11
                                           OR dwlHandfunktionen.12
                                           OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                           OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandplus := (( dwlHandfunktionen.11
                             OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                            AND NOT (   dwlHandfunktionen.12
                                      OR dwlHandfunktionen.13
                                      OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                      OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandminus := (( dwlHandfunktionen.12
                              OR bgVISUQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
                             AND NOT (    dwlHandfunktionen.11
                                       OR dwlHandfunktionen.13
                                       OR bgVISUQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                       OR bgVISUQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  // Starten der Zentralschmierung
  Zentralschmierung.bpStartSchmierungHand := (dwlHandfunktionen.17 OR bgVISUZentralschmierungStarten[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]);

ELSE
  Zentralschmierung.bpStartSchmierungHand := FALSE;

END_IF

HandfunktionenStatus();
END_ACTION