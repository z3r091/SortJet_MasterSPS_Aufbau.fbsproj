(* METADATA
{
	"v3Meta": {
		"objectGuid": "feabb690-b005-4f7f-843c-885a6c6a91aa"
	}
}
*)
ACTION A_Aufrufe
//==================================================================================================
// AKTION AUFRUFE
//==================================================================================================
// Glastransport X
Glastransport_X( stStationsNummern                       := BasisStationsParameter.stMKs.stStationsNummern,
                 bpAutomatikAktiv                        := BasisStationsParameter.bAutomatik,
                 bpFreigabe                              := BasisStationsParameter.bFreigabe,
                 InGlasTransportVorgaenger               := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1],
                 InGlasTransportNachfolger               := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1],
                 bpMessrichtungNegativ                   := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bMessrichtungNegativ,
                 bpOptionMessungSystemCheckAktiv         := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibenVermessenSystemCheck,
                 bpOptionMasterSlaveTransport            := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bTransportMasterSlaveAustransport,
                 bpOptionAustransportISOLinie            := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bAustransportISOLinie,
                 bpOptionScheibenmessungEintransport     := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenmessungEintransport,
                 bpOptionNachSystemcheckAufAuslaufsensor := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibeNachSystemcheckAufAuslauf,
                 bpOptionSlaveAntrieb                    := FALSE );

// Glastransport Y
Glastransport_Y( stStationsNummern                       := BasisStationsParameter.stMKs.stStationsNummern,
                 bpAutomatikAktiv                        := BasisStationsParameter.bAutomatik,
                 bpFreigabe                              := BasisStationsParameter.bFreigabe,
                 InGlasTransportVorgaenger               := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1],
                 InGlasTransportNachfolger               := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1],
                 bpMessrichtungNegativ                   := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bMessrichtungNegativ,
                 bpOptionMessungSystemCheckAktiv         := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibenVermessenSystemCheck,
                 bpOptionMasterSlaveTransport            := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bTransportMasterSlaveAustransport,
                 bpOptionAustransportISOLinie            := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bAustransportISOLinie,
                 bpOptionScheibenmessungEintransport     := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenmessungEintransport,
                 bpOptionNachSystemcheckAufAuslaufsensor := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibeNachSystemcheckAufAuslauf,
                 bpOptionSlaveAntrieb                    := FALSE );

// Hubrahmen
Hubrahmen();
END_ACTION