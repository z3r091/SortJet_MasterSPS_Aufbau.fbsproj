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
               bpFreigabe                              := BasisStationsParameter.bFreigabe,
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
        bpFreigabe                             := BasisStationsParameter.bFreigabe,
        bpBetriebsartHand                      := blBetriebsartHand,
        bpEinlaufSensor                        := Glastransport.bpSensorEinlauf,
        bpAuslaufSensor                        := Glastransport.bpSensorAuslauf );

// Kippen
Kippen( stStationsNummern                      := BasisStationsParameter.stMKs.stStationsNummern,
        bpFreigabe                             := BasisStationsParameter.bFreigabe,
        bpSensorEinlauf                        := Glastransport.bpSensorEinlauf,
        bpSensorAuslauf                        := Glastransport.bpSensorAuslauf );

// Querfahrt
Querfahrt( stStationsNummern                   := BasisStationsParameter.stMKs.stStationsNummern,
           bpAutomatikAktiv                    := BasisStationsParameter.bAutomatik,
           bpFreigabe                          := BasisStationsParameter.bFreigabe,
           bpReglungAktivSchalten              := Drehen.bpDrehvorgangAktiv );    

// Geblaese
Geblaese( stStationsNummern                    := BasisStationsParameter.stMKs.stStationsNummern,
          bpFreigabe                           := BasisStationsParameter.bFreigabe,
          bpMotorschutzschalter_OK             := in_bMotorstarter_Geblaese_OK,
          bpIOsBoschDrive                      := TRUE );

// Querachse
Querachse( bpZylinderAbfragenVorhanden         := TRUE,
           bpEinAusFahrenLogikDrehen           := BasisStationsParameter.stMKs.stStationsOptionen.bVerstellungEinAusGefahrenLogikDrehen );

// Dickenverstellung
Dickenverstellung( bpZylinderAbfragenVorhanden := TRUE , 
                   bpEinAusFahrenLogikDrehen   := BasisStationsParameter.stMKs.stStationsOptionen.bVerstellungEinAusGefahrenLogikDrehen );
END_ACTION