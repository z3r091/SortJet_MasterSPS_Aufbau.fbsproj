(* METADATA
{
  "v3Meta": {
    "objectGuid": "ab2e7824-0de2-4503-86ea-6459379a5b65"
  }
}
*)
ACTION A_Aufrufe
(***************************************************************************************************)
(* AKTION AUFRUFE *)
(***************************************************************************************************)
(* Aufruf
   - Glastransport - Wand 1
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO

  (* Aufruf:
     - Glastransport Zuweisung:
  *)
  Glastransport[wlIndex]( stStationsNummern                        := BasisStationsParameter.stMKs.stStationsNummern,
                          wpWandNr                                 := wlIndex,
                          bpAutomatikAktiv                         := BasisStationsParameter.bAutomatik,
                          bpFreigabe                               := BasisStationsParameter.bFreigabe,
                          eStationsTyp                              := BasisStationsParameter.stMKs.eStationsTyp,
                          InGlasTransportVorgaenger                := BasisStationsParameter.InGlasTransportVorgaenger[wlIndex],
                          InGlasTransportNachfolger                := BasisStationsParameter.InGlasTransportNachfolger[wlIndex],
                          bpSensorEinlauf                          := in_bSensorEinlauf[wlIndex],
                          bpSensorEinlaufVorab                     := in_bSensorEinlaufVorab[wlIndex],
                          bpSensorAuslaufVorab                     := in_bSensorAuslaufVorab[wlIndex],
                          bpSensorAuslauf                          := in_bSensorAuslauf[wlIndex],
                          bpSensorAuslaufStopp                     := in_bSensorAuslaufStopp[wlIndex],
                          bpTeilnehmerErreichbar                   := blShuttleErreichbar,
                          bpMessungSystemCheckAktiv                  := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibenVermessenSystemCheck,
                          bpScheibeNachSystemcheckAufAuslaufsensor   := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibeNachSystemcheckAufAuslauf,
                          bpSlaveAntriebVorhanden                    := BasisStationsParameter.stMKs.stStationsAufbau.bGlastransportSlaveVorhanden,
                          bpOptionMasterSlaveTransport               := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bTransportMasterSlaveAustransport);

  (* Aufruf:
     - Glas-Dickenverstellung [Wand | Scheibenfuehrung]
  *)
  Wandverstellung[wlIndex]( bpFreigabe                                     := BasisStationsParameter.bFreigabe,
                            stStationsNummern                              := BasisStationsParameter.stMKs.stStationsNummern,
                            bpOptionMotorischAktivieren                    := BasisStationsParameter.stMKs.stStationsAufbau.bWandverstellungMotorisch );

  (* Aufruf:
     - Geblaese Zuweisung:
  *)
  Geblaese[wlIndex]( bpFreigabe := BasisStationsParameter.bFreigabe,
                     stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern,
                     bpTeilnehmerErreichbar := blShuttleErreichbar );

END_FOR

(* Aufruf [Verfahrauftraege]:
   - Querfahrt
*)
Querfahrt( stStationsNummern              := BasisStationsParameter.stMKs.stStationsNummern,
           bpAutomatikAktiv               := BasisStationsParameter.bAutomatik,
           bpLangsamfahrtNockenAktivieren := BasisStationsParameter.stMKs.stStationsOptionen.bLangsamfahrtNockenQuerfahrtAktivieren,
           bpTeilnehmerErreichbar         := blShuttleErreichbar,
           rpMinPosSwEsEingrenzung        := rpMinPosSwEsEingrenzung,
           rpMaxPosSwEsEingrenzung        := rpMaxPosSwEsEingrenzung,
           bpFreigabe                     := BasisStationsParameter.bFreigabe AND abgVerfahrfreigabeShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS],
           bpVerfahrfreigabe              :=(    blAlleVerfahrfreigaben
                                                    AND NOT bpShuttleAnhalten ) );
											  
(* Aufruf:
   - Kippen
*)
Kippen( bpKippenSchuetz        := BasisStationsParameter.stMKs.stStationsAufbau.bKippenSchuetz,
        bpTeilnehmerErreichbar := blShuttleErreichbar,
        stStationsNummern      := BasisStationsParameter.stMKs.stStationsNummern,
        bpBetriebsartHand      := blBetriebsartHand,
        bpSensorEinlauf        := blAlleEinlaufSensoren,
        bpSensorAuslauf        := blAlleAuslaufStoppSensoren,
        bpFreigabe             := ( BasisStationsParameter.bFreigabe 
                                    AND blAlleVerfahrfreigaben
                                    AND NOT bpShuttleAnhalten
                                  ));

// Zentralschmierung
Zentralschmierung( stStationsNummern           := BasisStationsParameter.stMKs.stStationsNummern,
                   bpFreigabe                  := BasisStationsParameter.bFreigabe,
                   dipAktuelleAntriebsPosition := REAL_TO_DINT( Querfahrt.rpAktPosition ), // Übergbabe der Aktuellen Position
                   bpTeilnehmerErreichbar      := blShuttleErreichbar );
END_ACTION