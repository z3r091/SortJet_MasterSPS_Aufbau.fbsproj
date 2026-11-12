(* METADATA
{
	"v3Meta": {
		"objectGuid": "0a358cd0-8f58-4807-b849-09cdc2c4a6a4"
	}
}
*)
ACTION A_Schnittstelle
//-------------------------------------------------------------------------------------------------
// SCHNITTSTELLE
//-------------------------------------------------------------------------------------------------

SUPER^.A_Schnittstelle();

// ---------------------------------------------------------------------------------------

BasisStationsParameter.bIstReferenziert        := ( Messachse.bpInReferenz OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bMessachse );

(* Hinweis:
   - Abhandlung des Ein-Aus- Transports [Setzen der Variablen das man bereit ist zum Glastransport]
*)
BasisStationsParameter.OutGlasTransport[cWAND_1].wAchsID                    := Glastransport.ppAntriebsInformationen.wAchsID;
BasisStationsParameter.OutGlasTransport[cWAND_1].rLaengeStation             := Glastransport.ppParameterBaustein.rLaengeStation;
BasisStationsParameter.OutGlasTransport[cWAND_1].bEinlaufsensor             REF= Glastransport.bpSensorEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bAuslaufsensor             REF= Glastransport.bpSensorAuslauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport     REF= Glastransport.bpOutBereitZumAustransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumEintransport     REF= Glastransport.bpOutBereitZumEintransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].rGeschwindigkeit           REF= Glastransport.rpOutGeschwindigkeit;
BasisStationsParameter.OutGlasTransport[cWAND_1].bQuittScheibe              REF= Glastransport.bprtScheibe;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf REF= Glastransport.bpScheibeFaehrtUeberEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf REF= Glastransport.bpScheibeFaehrtUeberAuslauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bTransportRueckwaertig     REF= BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];


// Statistik
BasisStationsParameter.dwWartezeit[cWAND_1] := Glastransport.dwpWartezeit;

// Status für die Visu
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlauf[1]            := Glastransport.bpSensorEinlauf;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlaufVorab[1]       := Glastransport.bpSensorEinlaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslaufVorab[1]       := Glastransport.bpSensorAuslaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslauf[1]            := Glastransport.bpSensorAuslauf;

abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bMessachseFehler             :=  Messachse.bpFehler;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bMessachseSensorOben         :=  Messachse.in_bSensorOben;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bMessachseSensorUnten        :=  Messachse.in_bSensorUnten;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bMessachseMinEndschalter     :=  Messachse.Antrieb.bpMinSchalterBelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rMessachseIstPos             :=  Messachse.rpIstPosition;

abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAbschrankungFehler          :=  Abschrankung.bpFehler;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAbschrankungOffen           :=  Abschrankung.in_bStatusZylinderEingefahren;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAbschrankungGeschlossen     :=  Abschrankung.in_bStatusZylinderAusgefahren;

abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAmpelRot                    :=  out_bAmpelSignalRot;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAmpelGruen                  :=  out_bAmpelSignalGruen;
END_ACTION