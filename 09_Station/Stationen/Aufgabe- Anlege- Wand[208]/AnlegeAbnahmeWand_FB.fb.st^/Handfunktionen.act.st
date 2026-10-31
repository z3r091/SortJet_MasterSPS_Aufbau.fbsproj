(* METADATA
{
  "v3Meta": {
    "objectGuid": "2e85ff69-500f-4e34-aca6-e10e21c80ea2"
  }
}
*)
ACTION Handfunktionen
(***************************************************************************************************)
(* AKTION HANDFUNKTIONEN *)
(***************************************************************************************************)
IF ( blBetriebsartHand ) THEN

  (* Handfunktion
     - Glastransport/Glastransport - vor bzw. zurück 
  *)
  Glastransport.bpHandfahrenMinus := ( BasisStationsParameter.dwHandfunktionen.2 AND NOT BasisStationsParameter.dwHandfunktionen.1 )
                                    OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]
                                    OR in_bKnebelGlastransportZurueck;  (* Bit 2 = Glastransport / Glastransport zurück *)
  Glastransport.bpHandfahrenPlus  := ( BasisStationsParameter.dwHandfunktionen.1 AND NOT BasisStationsParameter.dwHandfunktionen.2 )
                                    OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] 
                                    OR in_bTasterGlasAngelegt
                                    OR in_bKnebelGlastransportVor;  (* Bit 2 = Glastransport / Glastransport zurück *);  (* Bit 1 = Glastransport / Glastransport vor *)


  (* Handfunktion:
     - Kippen 
  *)
  IF (BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1]) THEN

    IF ( BasisStationsParameter.dwHandfunktionen.7 OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
      AND NOT ( BasisStationsParameter.dwHandfunktionen.8 OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
    THEN
      Kippen.epZielPosition := eKippen_Position_90Grad;
      Kippen.bpPositionieren := TRUE;
    ELSIF ( BasisStationsParameter.dwHandfunktionen.8 OR bgVISUKippenW1Runter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
      AND NOT ( BasisStationsParameter.dwHandfunktionen.7 OR bgVISUKippenW1Hoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
    THEN
      Kippen.epZielPosition := eKippen_Position_84Grad;
      Kippen.bpPositionieren := TRUE;
    ELSE
      Kippen.bpPositionieren := FALSE;
  END_IF

  END_IF


  (* Handfunktion:
     - Kippen 
  *)
   Messachse.bpHandplus     := (         ( BasisStationsParameter.dwHandfunktionen.3 OR bgVISUHoehenkontrolleVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                              AND NOT (    BasisStationsParameter.dwHandfunktionen.4 
                                        OR BasisStationsParameter.dwHandfunktionen.5 
                                        OR bgVISUHoehenkontrolleZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] 
                                        OR  bgVISUHoehenkontrolleReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );
                         
   Messachse.bpHandminus    := (         ( BasisStationsParameter.dwHandfunktionen.4 OR bgVISUHoehenkontrolleZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                              AND NOT (    BasisStationsParameter.dwHandfunktionen.3
                                        OR BasisStationsParameter.dwHandfunktionen.5 
                                        OR bgVISUHoehenkontrolleVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]  
                                        OR bgVISUHoehenkontrolleReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );

   Messachse.bpHandReferenz := (         ( BasisStationsParameter.dwHandfunktionen.5 OR bgVISUHoehenkontrolleReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                              AND NOT (    BasisStationsParameter.dwHandfunktionen.3
                                        OR BasisStationsParameter.dwHandfunktionen.4
                                        OR bgVISUHoehenkontrolleVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] 
                                        OR bgVISUHoehenkontrolleZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) );
													 
													 
  
  
  
END_IF
END_ACTION