(* METADATA
{
	"v3Meta": {
		"objectGuid": "073844ed-d0d8-40ec-8ede-56266aae13db"
	}
}
*)
ACTION A_Aufrufe
(***************************************************************************************************)
(* FUNKTIONSBAUSTEINE ZUWEISUNGEN UND AUFRUFE *)
(***************************************************************************************************)
// Glastransport
Glastransport( stStationsNummern                              := BasisStationsParameter.stMKs.stStationsNummern,
               bpAutomatikAktiv                               := BasisStationsParameter.bAutomatik,
               bpFreigabe                                     := BasisStationsParameter.bFreigabe,
               InGlasTransportVorgaenger                      := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1],
               InGlasTransportNachfolger                      := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1],
               stpInTransportVerbund                          := stpInTransportVerbund,
               bpHand                                         :=  (  NOT BasisStationsParameter.bAutomatik
                                                                 AND NOT BasisStationsParameter.bReset
                                                                 AND NOT BasisStationsParameter.bCheck
                                                                 AND NOT BasisStationsParameter.bReferenz
                                                                 AND NOT bpStarteSpeicherfachValidierung ),
               bpShuttleDeaktivieren                            := BasisStationsParameter.stMKs.bDeaktivieren,
               blSensorGlastransportOben                        := in_bSensorShuttleOben,
               blSensorGlastransportUnten                       := in_bSensorShuttleUnten,
               bpOptionMasterSlaveAustransport                  := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bTransportMasterSlaveAustransport );

// Default Abfragen
Glastransport.blDruckluftEinlaufSeiteOK                        := in_bDruckluftEinlaufSeiteOK;
Glastransport.blDruckluftAuslaufSeiteOK                        := in_bDruckluftAuslaufSeiteOK;


// Default Abfragen
IF BasisStationsParameter.stMKs.stStationsOptionen.stTransfershuttle.bTransferShuttleMitUltraschallSensoren THEN // Ultraschallsensoren sind keine Öffner sondern schließer - Logik negieren!
  Glastransport.bpSensorScheibenKontrolleAuslaufSeiteFrei        := NOT in_bSensorScheibenKontrolleAuslaufSeiteFrei OR NOT in_bSensorScheibenKontrolleAuslaufSeiteOben;
  Glastransport.bpSensorScheibenKontrolleEinlaufSeiteFrei        := NOT in_bSensorScheibenKontrolleEinlaufSeiteFrei OR NOT in_bSensorScheibenKontrolleEinlaufSeiteOben;
ELSE
  Glastransport.bpSensorScheibenKontrolleAuslaufSeiteFrei        := in_bSensorScheibenKontrolleAuslaufSeiteFrei;
  Glastransport.bpSensorScheibenKontrolleEinlaufSeiteFrei        := in_bSensorScheibenKontrolleEinlaufSeiteFrei;
END_IF

Glastransport.bpOptionTransfershuttleMitFaecherwagen           := BasisStationsParameter.stMKs.stStationsOptionen.stTransfershuttle.bTransferShuttleFuerFaecherwagen;

Glastransport.bpOptionSensorEinlauf                            := BasisStationsParameter.stMKs.stStationsAufbau.bSensorEinlauf;
Glastransport.bpOptionSensorAuslauf                            := BasisStationsParameter.stMKs.stStationsAufbau.bSensorAuslauf;
Glastransport.bpTransfershuttleVerbundAktiv                    := bpTransfershuttleVerbundAktiv;

Glastransport.bpOptionTransfershuttleMitUltraschallSensoren := BasisStationsParameter.stMKs.stStationsOptionen.stTransfershuttle.bTransferShuttleMitUltraschallSensoren;

(* Hinweis:
   - Die Hardware- Eingaenge werden zurueck gehalten wenn die Luftabfrage nicht verbaut wurde. 
     => Die Werte werden werden je nach Zustand im Unterbaustein (Glastransport) simuliert und duerfen aus diesem Grund hier nicht 
        ueberschrieben werden.
*)
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bSensorAuslauf ) THEN
  Glastransport.bpSensorScheibenKontrolleAuslaufSeiteOben  := in_bSensorScheibenKontrolleAuslaufSeiteOben;
  Glastransport.bpSensorScheibenKontrolleAuslaufSeiteUnten := in_bSensorScheibenKontrolleAuslaufSeiteUnten;

END_IF

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bSensorEinlauf ) THEN
  Glastransport.bpSensorScheibenKontrolleEinlaufSeiteOben  := in_bSensorScheibenKontrolleEinlaufSeiteOben;
  Glastransport.bpSensorScheibenKontrolleEinlaufSeiteUnten := in_bSensorScheibenKontrolleEinlaufSeiteUnten;

END_IF



// Querfahrt
Querfahrt(        stStationsNummern   := BasisStationsParameter.stMKs.stStationsNummern,
                  bpAutomatikAktiv    := BasisStationsParameter.bAutomatik,
                  bpFreigabe          :=   ( BasisStationsParameter.bFreigabe
                                         AND abgVerfahrfreigabeShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                         AND blShuttleKannSicherVerfahrenWerden ),
                  bpVerfahrFreigabe   :=  blShuttleKannSicherVerfahrenWerden
                                         AND Glastransport.bpBereitZumVerfahren 
                                         AND ( NOT BasisStationsParameter.stMKs.stStationsOptionen.stTransfershuttle.bTransfershuttleIstVerfahrbarerSpeicher
                                         OR  ( NOT Glastransport.InGlasTransportNachfolger.bEinlaufsensor AND NOT Glastransport.InGlasTransportVorgaenger.bAuslaufsensor)));

//Zentralschmierung
Zentralschmierung( stStationsNummern           := BasisStationsParameter.stMKs.stStationsNummern,
                   bpFreigabe                  := BasisStationsParameter.bFreigabe,
                   dipAktuelleAntriebsPosition := REAL_TO_DINT( Querfahrt.rpAktPosition ), // Übergbabe der Aktuellen Position
                   bpTeilnehmerErreichbar      := TRUE,
                   bpAktiv                     := BasisStationsParameter.stMKs.stStationsAufbau.bDLSSchmiersystem  );
END_ACTION