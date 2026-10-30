(* METADATA
{
	"v3Meta": {
		"objectGuid": "c7d4a448-ff07-49ee-a1d0-2c7d2efb26a5"
	}
}
*)
ACTION A_Schnittstelle
(***************************************************************************************************)
(* SCHNITTSTELLE *)
(***************************************************************************************************)
(* Hinweis:
   - Abhandlung des Ein-Aus- Transports [Setzen der Variablen das man bereit ist zum Glastransport]
*)
BasisStationsParameter.OutGlasTransport[cWAND_1].stStationsNummern          := BasisStationsParameter.stMKs.stStationsNummern;
BasisStationsParameter.OutGlasTransport[cWAND_1].wStationsTyp               := BasisStationsParameter.stMKs.eStationsTyp;
BasisStationsParameter.OutGlasTransport[cWAND_1].wAchsID                    := Glastransport.ppAntriebsInformationen.wAchsID;
BasisStationsParameter.OutGlasTransport[cWAND_1].bEinlaufsensor             REF= Glastransport.bpSensorEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bAuslaufsensor             REF= Glastransport.bpSensorAuslauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport     REF= Glastransport.bpOutBereitZumAustransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumEintransport     REF= Glastransport.bpOutBereitZumEintransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].rGeschwindigkeit           REF= Glastransport.rpOutGeschwindigkeit;
BasisStationsParameter.OutGlasTransport[cWAND_1].bFehler                    REF= BasisStationsParameter.bFehler;
BasisStationsParameter.OutGlasTransport[cWAND_1].bQuittScheibe              REF= Glastransport.bprtScheibe;
BasisStationsParameter.OutGlasTransport[cWAND_1].bFreigabe                  REF= BasisStationsParameter.bFreigabe;
BasisStationsParameter.OutGlasTransport[cWAND_1].bTransportAbgeschlossen    REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf REF= Glastransport.bpScheibeFaehrtUeberEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf REF= Glastransport.bpScheibeFaehrtUeberAuslauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bTransportRueckwaertig     REF= BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

(* Hinweis:
   - Transportverbund- Interface unter den Transfershuttle
*)
stpOutTransportVerbund := Glastransport.stpOutTransportVerbund;


(* --------------------------------------------------------------------------------------- *)
(* BAUSTEIN BASISPARAMETER *)
BasisStationsParameter.bIstReferenziert        := Querfahrt.Antrieb.bpIstReferenziert;
BasisStationsParameter.bAuftragAktiv           := (   BasisStationsParameter.bAnlegen
                                                   OR BasisStationsParameter.bAbnehmen
                                                   OR BasisStationsParameter.bEintransport[cWAND_1]
                                                   OR BasisStationsParameter.bAustransport[cWAND_1]
                                                   OR BasisStationsParameter.bDurchtransport[cWAND_1]
                                                   OR BasisStationsParameter.bVorabpositionieren
                                                   OR BasisStationsParameter.bGlaslaengenmessung
                                                   OR BasisStationsParameter.bTransportkopplung[cWAND_1]
                                                   OR BasisStationsParameter.bVortransport[cWAND_1]
                                                   OR BasisStationsParameter.bReset
                                                   OR BasisStationsParameter.bReferenz
                                                   OR BasisStationsParameter.bCheck );

dwlHandfunktionen                               := BasisStationsParameter.dwHandfunktionen;

// Status für die Visu

// Wand 1
IF BasisStationsParameter.stMKs.stStationsOptionen.stTransfershuttle.bTransferShuttleMitUltraschallSensoren THEN // Ultraschallsensoren sind keine Öffner sondern schließer - Logik negieren!
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlauf[1] := NOT in_bSensorScheibenKontrolleEinlaufSeiteFrei;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslauf[1] := NOT in_bSensorScheibenKontrolleAuslaufSeiteFrei;
ELSE
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlauf[1] := in_bSensorScheibenKontrolleEinlaufSeiteFrei;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslauf[1] := in_bSensorScheibenKontrolleAuslaufSeiteFrei;
END_IF

//Wand 2

// Querfahrt
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtFehler              := Querfahrt.bpFehler;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtMinEndschalter      := Querfahrt.Antrieb.bpMinSchalterBelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtMaxEndschalter      := Querfahrt.Antrieb.bpMaxSchalterBelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rQuerfahrtIstPos              := Querfahrt.rpAktPosition;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtAntriebReferenziert := Querfahrt.Antrieb.bpIstReferenziert;
END_ACTION