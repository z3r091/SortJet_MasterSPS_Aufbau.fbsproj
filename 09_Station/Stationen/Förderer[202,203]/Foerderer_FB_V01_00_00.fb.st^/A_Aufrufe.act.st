(* METADATA
{
	"v3Meta": {
		"objectGuid": "4dd89375-5bd4-48ba-8dfb-4eb09e5d28d2"
	}
}
*)
ACTION A_Aufrufe
//-------------------------------------------------------------------------------------------------
// AKTION AUFRUFE
//-------------------------------------------------------------------------------------------------
// Glastransport
Glastransport( stStationsNummern                       := BasisStationsParameter.stMKs.stStationsNummern,
               bpAutomatikAktiv                        := BasisStationsParameter.bAutomatik,
               bpFreigabe                              := BasisStationsParameter.stFreigabe.bGlastransport,
               InGlasTransportVorgaenger               := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1],
               InGlasTransportNachfolger               := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1],
               bpMessrichtungNegativ                   := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bMessrichtungNegativ,
               bpOptionMessungSystemCheckAktiv         := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibenVermessenSystemCheck,
               bpOptionMasterSlaveTransport            := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bTransportMasterSlaveAustransport,
               bpOptionAustransportISOLinie            := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bAustransportISOLinie,
               bpOptionScheibenmessungEintransport     := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenmessungEintransport,
               bpOptionNachSystemcheckAufAuslaufsensor := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibeNachSystemcheckAufAuslauf,
               bpOptionSlaveAntrieb                    := BasisStationsParameter.stMKs.stStationsAufbau.bSlaveAntrieb );

// Geblaese
Geblaese( stStationsNummern                        := BasisStationsParameter.stMKs.stStationsNummern,
          bpFreigabe                               := BasisStationsParameter.stFreigabe.bGeblaese, );

// Kippen
Kippen( stStationsNummern                          := BasisStationsParameter.stMKs.stStationsNummern,
        bpSensorEinlauf                            := Glastransport.bpSensorEinlauf,
        bpSensorAuslauf                            := Glastransport.bpSensorAuslauf,
        bpTeilnehmerErreichbar                     := TRUE );

// Hub
Hub( stStationsNummern                             := BasisStationsParameter.stMKs.stStationsNummern,
     bpSensorEinlauf                               := Glastransport.bpSensorEinlauf,
     bpSensorAuslauf                               := Glastransport.bpSensorAuslauf );

// Roellchenleiste
Roellchenleiste( bpFreigabe                      := BasisStationsParameter.stFreigabe.bPneumatik,
                 bpZylinderAbfragenVorhanden     := TRUE,
                 bpEinAusFahrenLogikDrehen       := BasisStationsParameter.stMKs.stStationsOptionen.bVerstellungEinAusGefahrenLogikDrehen );

// Wandverstellung
Wandverstellung( bpFreigabe                      := BasisStationsParameter.stFreigabe.bPneumatik,
                 bpZylinderAbfragenVorhanden     := TRUE,
                 bpEinAusFahrenLogikDrehen       := BasisStationsParameter.stMKs.stStationsOptionen.bVerstellungEinAusGefahrenLogikDrehen );

// Querfahrt
Querfahrt( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern,
           bpFreigabe        := BasisStationsParameter.stFreigabe.bQuerfahrt,
           bpSensorEinlauf   := Glastransport.bpSensorEinlauf,
           bpSensorAuslauf   := Glastransport.bpSensorAuslauf );
END_ACTION