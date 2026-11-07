(* METADATA
{
	"v3Meta": {
		"objectGuid": "2557be95-ee2a-456a-af6d-111008a105f8"
	}
}
*)
ACTION A_Aufrufe
//-------------------------------------------------------------------------------------------------
// AUFRUFE
//-------------------------------------------------------------------------------------------------
// Glastransport
Glastransport( stStationsNummern              := BasisStationsParameter.stMKs.stStationsNummern,
               bpFreigabe                     := BasisStationsParameter.bFreigabe AND NOT ( in_bTasterAnforderungKippen OR in_bTasterAnforderungKippen_OP ),
               bpAutomatikAktiv               := BasisStationsParameter.bAutomatik,
               InGlasTransportVorgaenger      := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1],
               InGlasTransportNachfolger      := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1],
               bpOptionMasterSlaveTransport   := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bTransportMasterSlaveAustransport,
               bpMessrichtungNegativ          := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bMessrichtungNegativ,
               bpOptionSlaveAntrieb           := BasisStationsParameter.stMKs.stStationsAufbau.bSlaveAntrieb );

// Höhenkontrolle
Messachse( bpFreigabe                   := BasisStationsParameter.bFreigabe AND NOT ( in_bTasterAnforderungKippen OR in_bTasterAnforderungKippen_OP ),
           stStationsNummern            := BasisStationsParameter.stMKs.stStationsNummern,
           bpBetriebsartHand            := blBetriebsartHand,
           bpFusstaster                 := rtlFussleisteStart.Q );

// Hubrahmen
Hubrahmen();

// Anschlag
Anschlag();
END_ACTION