(* METADATA
{
  "v3Meta": {
    "objectGuid": "5cc73650-4fb5-4862-bb3f-59b0f18cb9f1"
  }
}
*)
ACTION A_Schnittstelle
(***************************************************************************************************)
(* SCHNITTSTELLE *)
(***************************************************************************************************)

BasisStationsParameter.bAuftragAktiv           := (   BasisStationsParameter.bAnlegen
                                                   OR BasisStationsParameter.bAbnehmen
                                                   OR BasisStationsParameter.bEintransport[cWAND_1]
                                                   OR BasisStationsParameter.bAustransport[cWAND_1]
                                                   OR BasisStationsParameter.bDurchtransport[cWAND_1]
                                                   OR BasisStationsParameter.bGlashoehenmessung
                                                   OR BasisStationsParameter.bGlaslaengenmessung
                                                      OR BasisStationsParameter.bVorabpositionieren
                                                   OR BasisStationsParameter.bVortransport[cWAND_1]
                                                   OR BasisStationsParameter.bReset
                                                   OR BasisStationsParameter.bReferenz
                                                   OR BasisStationsParameter.bCheck );

(* Hinweis:
   - Abhandlung des Ein-Aus- Transports [Setzen der Variablen das man bereit ist zum Glastransport]
*)
BasisStationsParameter.OutGlasTransport[cWAND_1].stStationsNummern          := BasisStationsParameter.stMKs.stStationsNummern;
BasisStationsParameter.OutGlasTransport[cWAND_1].wStationsTyp               := BasisStationsParameter.stMKs.eStationsTyp;
BasisStationsParameter.OutGlasTransport[cWAND_1].bFehler                    REF= BasisStationsParameter.bFehler;
BasisStationsParameter.OutGlasTransport[cWAND_1].bFreigabe                  REF= BasisStationsParameter.bFreigabe;
BasisStationsParameter.OutGlasTransport[cWAND_1].bTransportAbgeschlossen    REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bTransportRueckwaertig     REF= BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

// Handfunktionen	  
dwlHandfunktionen := BasisStationsParameter.dwHandfunktionen;
END_ACTION