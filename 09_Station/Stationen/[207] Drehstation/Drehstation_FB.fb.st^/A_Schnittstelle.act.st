(* METADATA
{
	"v3Meta": {
		"objectGuid": "28dc34b5-a949-4abd-88fa-d598ed2a7c6a"
	}
}
*)
ACTION A_Schnittstelle
(***************************************************************************************************)
(* SCHNITTSTELLE *)
(***************************************************************************************************)

SUPER^.A_Schnittstelle();

(* --------------------------------------------------------------------------------------- *)

(* Hinweis:
   - Abhandlung des Ein-Aus- Transports [Setzen der Variablen das man bereit ist zum Glastransport]
*)
BasisStationsParameter.OutGlasTransport[cWAND_1].wAchsID                    := Glastransport.ppAntriebsInformationen.wAchsID;

// Je nach Drehpos die Sensoren ausgeben
IF ( Drehen.epDrehPositionsStatus = eDrehPosition180Grad ) THEN
  BasisStationsParameter.OutGlasTransport[cWAND_1].bEinlaufsensor           REF= Glastransport.bpSensorAuslauf;
  BasisStationsParameter.OutGlasTransport[cWAND_1].bAuslaufsensor           REF= Glastransport.bpSensorEinlauf;
ELSE
BasisStationsParameter.OutGlasTransport[cWAND_1].bEinlaufsensor             REF= Glastransport.bpSensorEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bAuslaufsensor             REF= Glastransport.bpSensorAuslauf;
END_IF

BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport     REF= Glastransport.bpOutBereitZumAustransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumEintransport     REF= Glastransport.bpOutBereitZumEintransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].rGeschwindigkeit           REF= Glastransport.rpOutGeschwindigkeit;
BasisStationsParameter.OutGlasTransport[cWAND_1].bQuittScheibe              REF= Glastransport.bprtScheibe;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf REF= Glastransport.bpScheibeFaehrtUeberEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf REF= Glastransport.bpScheibeFaehrtUeberAuslauf;


(* --------------------------------------------------------------------------------------- *)
(* BAUSTEIN BASISPARAMETER *)
BasisStationsParameter.rAktuellePositionQuerfahrt := Querfahrt.rpAktuellePosition;
BasisStationsParameter.rAktuellePositionDrehen    := Drehen.rpAktuellePosition;
BasisStationsParameter.eDrehPositionsStatus       := Drehen.epDrehPositionsStatus;

BasisStationsParameter.bIstReferenziert           := ( Drehen.bpInReferenz OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bDrehen ) 
                                                 AND ( Kippen.bpInReferenz OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1] )
															    AND ( Querfahrt.bpInReferenz OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt );

bpVorabDrehenAktiv := BasisStationsParameter.bVorabpositionieren OR ( steplVorabDrehen <> STEP_0_E );

// Status für die Visu
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlauf[1]            := Glastransport.bpSensorEinlauf;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlaufVorab[1]       := Glastransport.bpSensorEinlaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslaufVorab[1]       := Glastransport.bpSensorAuslaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslauf[1]            := Glastransport.bpSensorAuslauf;

// Drehen
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bDrehenFehler                 :=  Drehen.bpFehler;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bDrehenMinEndschalter         :=  Drehen.Antrieb.bpMinSchalterBelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bDrehenMaxEndschalter         :=  Drehen.Antrieb.bpMaxSchalterBelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].epDrehIstPosition             :=  Drehen.epDrehPositionsStatus;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bDrehenAntriebReferenziert    :=  Drehen.Antrieb.bpIstReferenziert;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rDrehenIstPos                 :=  Drehen.Antrieb.rpIstPosition;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bDrehenArretierungEingefahren :=  Drehen.Arretierung.in_bStatusZylinderEingefahren;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bDrehenArretierungAusgefahren :=  Drehen.Arretierung.in_bStatusZylinderAusgefahren;

// Querfahrt
IF BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt THEN
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtFehler              :=  Querfahrt.bpFehler;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtMinEndschalter      :=  Querfahrt.Antrieb.bpMinSchalterBelegt;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtMaxEndschalter      :=  Querfahrt.Antrieb.bpMaxSchalterBelegt;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rQuerfahrtIstPos              :=  Querfahrt.rpAktuellePosition;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtAntriebReferenziert :=  Querfahrt.Antrieb.bpIstReferenziert;
END_IF

// Dickenverstellung
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].epWandverstellungStatus[1] := Dickenverstellung.wpStatusZylinder;
END_ACTION