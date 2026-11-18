(* METADATA
{
	"v3Meta": {
		"objectGuid": "c808f452-cbe2-4057-9370-f651842319d4"
	}
}
*)
ACTION A_Aufrufe
//-------------------------------------------------------------------------------------------------
// ZUWEISUNGEN UND BAUSTEINAUFRUFE
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

// Drehen
Drehen( stStationsNummern                      := BasisStationsParameter.stMKs.stStationsNummern,
        bpFreigabe                             := BasisStationsParameter.stFreigabe.bDrehen,
        bpFreigabePneumatik                    := BasisStationsParameter.stFreigabe.bPneumatik,
        bpBetriebsartHand                      := blBetriebsartHand,
        bpEinlaufSensor                        := Glastransport.bpSensorEinlauf,
        bpAuslaufSensor                        := Glastransport.bpSensorAuslauf );

// Kippen
Kippen( stStationsNummern                      := BasisStationsParameter.stMKs.stStationsNummern,
        bpFreigabe                             := BasisStationsParameter.stFreigabe.bKippen,
        bpSensorEinlauf                        := Glastransport.bpSensorEinlauf,
        bpSensorAuslauf                        := Glastransport.bpSensorAuslauf );

// Querfahrt
Querfahrt( stStationsNummern                   := BasisStationsParameter.stMKs.stStationsNummern,
           bpAutomatikAktiv                    := BasisStationsParameter.bAutomatik,
           bpFreigabe                          := BasisStationsParameter.stFreigabe.bQuerfahrt,
           bpReglungAktivSchalten              := Drehen.bpDrehvorgangAktiv );

// Geblaese
Geblaese( stStationsNummern                    := BasisStationsParameter.stMKs.stStationsNummern,
          bpFreigabe                           := BasisStationsParameter.stFreigabe.bGeblaese,
          bpMotorschutzschalter_OK             := in_bMotorstarter_Geblaese_OK,
          bpIOsBoschDrive                      := TRUE );

// Querachse
Querachse( bpFreigabe                          := BasisStationsParameter.stFreigabe.bPneumatik,
           bpZylinderAbfragenVorhanden         := TRUE,
           bpEinAusFahrenLogikDrehen           := BasisStationsParameter.stMKs.stStationsOptionen.bVerstellungEinAusGefahrenLogikDrehen );

// Dickenverstellung
Dickenverstellung( bpFreigabe                  := BasisStationsParameter.stFreigabe.bPneumatik,
                   bpZylinderAbfragenVorhanden := TRUE ,
                   bpEinAusFahrenLogikDrehen   := BasisStationsParameter.stMKs.stStationsOptionen.bVerstellungEinAusGefahrenLogikDrehen );
END_ACTION