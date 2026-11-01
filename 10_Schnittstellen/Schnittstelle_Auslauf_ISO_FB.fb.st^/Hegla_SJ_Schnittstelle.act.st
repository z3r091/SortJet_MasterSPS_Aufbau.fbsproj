(* METADATA
{
  "v3Meta": {
    "objectGuid": "e33a3794-f653-4ea0-a385-1b274df6831c"
  }
}
*)
ACTION Hegla_SJ_Schnittstelle
(* Ausgang 1:
   - Sender Bereit = Sortierung bzw. Quadrowand-Senkrechtfoerderer befindet sich in keinem Fehler
*)
blSenderGlasBereit := ( ( BasisStationsParameter.bAutomatik )
                        AND NOT BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bFehler ) 
                      AND ( BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bBereitZumAustransport 
                            OR BasisStationsParameter.bCheckMitVorgaenger[cWAND_1] 
                            OR BasisStationsParameter.bCheckMitNachfolger[cWAND_1] );
END_ACTION