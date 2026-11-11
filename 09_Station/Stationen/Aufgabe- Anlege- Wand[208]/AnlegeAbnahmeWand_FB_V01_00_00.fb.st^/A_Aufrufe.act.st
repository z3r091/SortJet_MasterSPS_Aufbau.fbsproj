(* METADATA
{
	"v3Meta": {
		"objectGuid": "f646a024-c51d-4cde-b5bf-999ca5c6e68b"
	}
}
*)
ACTION A_Aufrufe
//-------------------------------------------------------------------------------------------------
// AKTION AUFRUFE
//-------------------------------------------------------------------------------------------------
// Glastransport
Glastransport( stStationsNummern                          := BasisStationsParameter.stMKs.stStationsNummern,
               bpAutomatikAktiv                           := BasisStationsParameter.bAutomatik,
               bpFreigabe                                 := BasisStationsParameter.bFreigabe,
               InGlasTransportVorgaenger                  := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1],
               InGlasTransportNachfolger                  := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1],
               bpMessrichtungNegativ                      := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bMessrichtungNegativ,
               bpOptionMasterSlaveTransport               := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bTransportMasterSlaveAustransport,
               bpOptionbScheibenmessungSensorVorabAuslauf := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenmessungSensorVorabAuslauf );


// Messachse
Messachse( stStationsNummern           := BasisStationsParameter.stMKs.stStationsNummern,
           bpFreigabe                  := BasisStationsParameter.bFreigabe AND bpFreigabeBereichsScanner,
           bpBetriebsartHand           := blBetriebsartHand );

// Kippen
Kippen( stStationsNummern                    := BasisStationsParameter.stMKs.stStationsNummern,
        bpSensorEinlauf                      := Glastransport.bpSensorEinlauf,
        bpSensorAuslauf                      := Glastransport.bpSensorAuslauf );

// Dickenverstellung
Dickenverstellung( bpZylinderAbfragenVorhanden := TRUE,
                   bpEinAusFahrenLogikDrehen   := BasisStationsParameter.stMKs.stStationsOptionen.bVerstellungEinAusGefahrenLogikDrehen );

// Bewegliche Abschrankung zum Nachfolger
Abschrankung();
END_ACTION