(* METADATA
{
	"v3Meta": {
		"objectGuid": "2e85ff69-500f-4e34-aca6-e10e21c80ea2"
	}
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// AKTION HANDFUNKTIONEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Bitverteilung aus der Oberfläche (einheitlich fuer alle Stationen, 4 Seiten zu 7 Knoepfen):
     Seite 1:  0 Geblaese (Aktion Geblaese), 1/2 Glastransport vor/zurueck
     Seite 2:  7 Kippen 84 Grad, 8 Kippen 90 Grad
     Seite 3:  18/19/20 Messachse vor/zurueck/Referenz
     Seite 4:  21/22 Abschrankung oeffnen/schliessen
*)
IF ( blBetriebsartHand ) THEN

  // Handfunktion
  //   - Glastransport/Glastransport - vor bzw. zurück
  Glastransport.bpHandfahrenMinus := ( BasisStationsParameter.dwHandfunktionen.2 AND NOT BasisStationsParameter.dwHandfunktionen.1 )
                                     OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]
                                     OR in_bKnebelGlastransportZurueck;  // Bit 2 = Glastransport / Glastransport zurück
  Glastransport.bpHandfahrenPlus  := ( BasisStationsParameter.dwHandfunktionen.1 AND NOT BasisStationsParameter.dwHandfunktionen.2 )
                                     OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] 
                                     OR in_bTasterGlasAngelegt
                                     OR in_bKnebelGlastransportVor;  (* Bit 2 = Glastransport / Glastransport zurück *);  // Bit 1 = Glastransport / Glastransport vor


  // Handfunktion:
  //   - Kippen
  IF (BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1]) THEN

    IF ( BasisStationsParameter.dwHandfunktionen.8 OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
       AND NOT ( BasisStationsParameter.dwHandfunktionen.7 OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
    THEN
      Kippen.epZielPosition := eKippen_Position_90Grad;
      Kippen.bpPositionieren := TRUE;
    ELSIF ( BasisStationsParameter.dwHandfunktionen.7 OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
          AND NOT ( BasisStationsParameter.dwHandfunktionen.8 OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
    THEN
      Kippen.epZielPosition := eKippen_Position_84Grad;
      Kippen.bpPositionieren := TRUE;
    ELSE
      Kippen.bpPositionieren := FALSE;
    END_IF

  END_IF


  // Handfunktion:
  //   - Kippen
  Messachse.bpHandplus     := (         ( BasisStationsParameter.dwHandfunktionen.18 OR bgVISUHoehenkontrolleVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                AND NOT (    BasisStationsParameter.dwHandfunktionen.19 
                                          OR BasisStationsParameter.dwHandfunktionen.20 
                                          OR bgVISUHoehenkontrolleZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] 
                                          OR  bgVISUHoehenkontrolleReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );
                         
  Messachse.bpHandminus    := (         ( BasisStationsParameter.dwHandfunktionen.19 OR bgVISUHoehenkontrolleZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                AND NOT (    BasisStationsParameter.dwHandfunktionen.18
                                          OR BasisStationsParameter.dwHandfunktionen.20 
                                          OR bgVISUHoehenkontrolleVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]  
                                          OR bgVISUHoehenkontrolleReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );

  Messachse.bpHandReferenz := (         ( BasisStationsParameter.dwHandfunktionen.20 OR bgVISUHoehenkontrolleReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                AND NOT (    BasisStationsParameter.dwHandfunktionen.18
                                          OR BasisStationsParameter.dwHandfunktionen.19
                                          OR bgVISUHoehenkontrolleVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] 
                                          OR bgVISUHoehenkontrolleZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );


  // Handfunktion:
  //   - Bewegliche Abschrankung zum Nachfolger oeffnen (einfahren) bzw. schliessen (ausfahren)
  IF ( BasisStationsParameter.stMKs.stStationsAufbau.bDurchlaufSperreZumNachfolger ) THEN
    Abschrankung.bpStartEinfahren := (         ( BasisStationsParameter.dwHandfunktionen.21 OR bgVISUZylinder1Einfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                       AND NOT ( BasisStationsParameter.dwHandfunktionen.22 OR bgVISUZylinder1Ausfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );

    Abschrankung.bpStartAusfahren := (         ( BasisStationsParameter.dwHandfunktionen.22 OR bgVISUZylinder1Ausfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                       AND NOT ( BasisStationsParameter.dwHandfunktionen.21 OR bgVISUZylinder1Einfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );
  END_IF

END_IF

HandfunktionenStatus();
END_ACTION