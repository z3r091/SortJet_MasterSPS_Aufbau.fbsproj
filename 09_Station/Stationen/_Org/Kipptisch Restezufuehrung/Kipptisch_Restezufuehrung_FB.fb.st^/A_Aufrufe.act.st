(* METADATA
{
	"v3Meta": {
		"objectGuid": "e78b20ff-de9c-4062-8959-b175164ebaf1"
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
               bpOptionScheibenmessungEintransport       := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenmessungEintransport,
               bpOptionNachSystemcheckAufAuslaufsensor   := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibeNachSystemcheckAufAuslauf,
               bpOptionSlaveAntrieb                      := BasisStationsParameter.stMKs.stStationsAufbau.bSlaveAntrieb );


// Kippen

Kippen( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern,
        bpFreigabe        := BasisStationsParameter.bFreigabe,  
        bpBetriebsartHand := blBetriebsartHand,
        bpSensorEinlauf   := FALSE, //Glastransport.bpSensorEinlauf, Nicht beachten, da belegt sein muss!!!
        bpSensorAuslauf   := Glastransport.bpSensorAuslauf );

// Querfahrt
Querfahrt( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern,
           bpFreigabe        := BasisStationsParameter.bFreigabe,
           bpSensorEinlauf   := Glastransport.bpSensorEinlauf,
           bpSensorAuslauf   := Glastransport.bpSensorAuslauf,  
           bpAktivieren      := BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt );

// Rollenleiste
Rollenleiste( bpAktivieren  := BasisStationsParameter.stMKs.stStationsAufbau.bRoellchenleiste[cWAND_1]);
END_ACTION