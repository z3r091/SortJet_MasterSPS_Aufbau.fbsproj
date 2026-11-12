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
     Seite 3:  14/15 Oeffnung 16/23 mm, 17 Zentralschmierung, 18/19/20 Greiferachse vor/zurueck/Referenz
     Seite 4:  21/22 Greifer ausfahren/einfahren, 23 Greiferzange schliessen, 24/25/26 Greiferzange oeffnen
               16/23/29 mm, 27 Glasrueckhalter ausfahren (Greifer nur mit stStationsAufbau.bGreifer)
*)
IF ( blBetriebsartHand ) THEN

  // Handfunktion:
  //   - Gebläse an / aus
  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO

    toflGeblaeseHandfahren[wlIndex]( IN := (    Glastransport[wlIndex].bpHandfahrenPlus
                                             OR Glastransport[wlIndex].bpHandfahrenMinus ),
                                     PT := T#15S );

  // Geblaese: Handfunktion im Geblaese-Baustein (bpHandEin, Aktion A_Geblaese)

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

  // Handfunktion [Greifer]:
  //   - Greiferachse vor / zurueck / Referenz
  //   - Greifer aus- / einfahren
  //   - Greiferzange schliessen / oeffnen 16 / 23 / 29 mm
  //   - Glasrueckhalter ausfahren
  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
    IF ( BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex] ) THEN
      // Taster: MMI-Bit oder Visu "Handbetrieb Speicher"
      blGreiferVor        := dwlHandfunktionen.18 OR bgVISUGreiferVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex];
      blGreiferZurueck    := dwlHandfunktionen.19 OR bgVISUGreiferZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex];
      blGreiferReferenz   := dwlHandfunktionen.20 OR bgVISUGreiferReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex];
      blGreiferAusfahren  := dwlHandfunktionen.21 OR bgVISUGreiferAusfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex];
      blGreiferEinfahren  := dwlHandfunktionen.22 OR bgVISUGreiferEinfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex];

      // Greiferachse vor / zurueck / Referenz (gegenseitig verriegelt)
      Greifer[wlIndex].bpHandfahrenPlus  := blGreiferVor      AND NOT ( blGreiferZurueck OR blGreiferReferenz );
      Greifer[wlIndex].bpHandfahrenMinus := blGreiferZurueck  AND NOT ( blGreiferVor     OR blGreiferReferenz );
      Greifer[wlIndex].bpFahreReferenz   := blGreiferReferenz AND NOT ( blGreiferVor     OR blGreiferZurueck  );

      // Greifer aus- / einfahren (gegenseitig verriegelt)
      Greifer[wlIndex].bpHandGreiferAusfahren := blGreiferAusfahren AND NOT blGreiferEinfahren;
      Greifer[wlIndex].bpHandGreiferEinfahren := blGreiferEinfahren AND NOT blGreiferAusfahren;

      // Greiferzange schliessen / oeffnen 16 / 23 / 29 mm
      Greifer[wlIndex].bpHandZangeSchliessen  := dwlHandfunktionen.23 OR bgVISUGreiferZangeSchliessen[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex];
      Greifer[wlIndex].bpHandZangeOeffnen16mm := dwlHandfunktionen.24 OR bgVISUGreiferZangeOeffnen16mm[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex];
      Greifer[wlIndex].bpHandZangeOeffnen23mm := dwlHandfunktionen.25 OR bgVISUGreiferZangeOeffnen23mm[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex];
      Greifer[wlIndex].bpHandZangeOeffnen29mm := dwlHandfunktionen.26 OR bgVISUGreiferZangeOeffnen29mm[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex];

      // Glasrueckhalter ausfahren
      Greifer[wlIndex].bpHandGlasRueckhalterAusfahren := dwlHandfunktionen.27 OR bgVISUGreiferGlasRueckhalterAusfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex];
    END_IF
  END_FOR

ELSE
  Zentralschmierung.bpStartSchmierungHand := FALSE;

  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
    Greifer[wlIndex].bpHandfahrenPlus               := FALSE;
    Greifer[wlIndex].bpHandfahrenMinus              := FALSE;
    Greifer[wlIndex].bpHandGreiferAusfahren         := FALSE;
    Greifer[wlIndex].bpHandGreiferEinfahren         := FALSE;
    Greifer[wlIndex].bpHandZangeSchliessen          := FALSE;
    Greifer[wlIndex].bpHandZangeOeffnen16mm         := FALSE;
    Greifer[wlIndex].bpHandZangeOeffnen23mm         := FALSE;
    Greifer[wlIndex].bpHandZangeOeffnen29mm         := FALSE;
    Greifer[wlIndex].bpHandGlasRueckhalterAusfahren := FALSE;

    // Referenzfahrt von Hand beenden (in der Betriebsart Referenz steuert die Aktion Referenz)
    IF ( NOT blBetriebsartReferenz ) THEN
      Greifer[wlIndex].bpFahreReferenz := FALSE;
    END_IF
  END_FOR

END_IF

HandfunktionenStatus();
END_ACTION