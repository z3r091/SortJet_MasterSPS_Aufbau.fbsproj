(* METADATA
{
  "v3Meta": {
    "objectGuid": "e42a6d8e-4c5c-4e5e-8154-c3d3b5b625c7"
  }
}
*)
ACTION A_Aufrufe
(***************************************************************************************************)
(* AKTION AUFRUFE *)
(***************************************************************************************************)
// Glastransport
Glastransport( stStationsNummern                         := BasisStationsParameter.stMKs.stStationsNummern,
               bpAutomatikAktiv                          := BasisStationsParameter.bAutomatik,
               bpFreigabe                                := BasisStationsParameter.bFreigabe,
               InGlasTransportVorgaenger                 := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1],
               InGlasTransportNachfolger                 := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1],
               bpOptionMessungSystemCheckAktiv           := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibenVermessenSystemCheck,
               bpOptionMasterSlaveTransport              := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bTransportMasterSlaveAustransport,
               bpOptionAustransportISOLinie            := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bAustransportISOLinie,
               bpOptionScheibenmessungEintransport       := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenmessungEintransport,
               bpOptionNachSystemcheckAufAuslaufsensor   := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibeNachSystemcheckAufAuslauf,
               bpOptionSlaveAntrieb                      := BasisStationsParameter.stMKs.stStationsAufbau.bSlaveAntrieb );


// Kippen

Kippen( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern,
        bpFreigabe        := BasisStationsParameter.bFreigabe,  
        bpBetriebsartHand := blBetriebsartHand,
        bpSensorEinlauf   := Glastransport.bpSensorEinlauf,
        bpSensorAuslauf   := Glastransport.bpSensorAuslauf );

// Querfahrt
Querfahrt( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern,
           bpFreigabe        := BasisStationsParameter.bFreigabe,
           bpSensorEinlauf   := Glastransport.bpSensorEinlauf,
           bpSensorAuslauf   := Glastransport.bpSensorAuslauf );

// Rollenleiste
Rollenleiste();
END_ACTION