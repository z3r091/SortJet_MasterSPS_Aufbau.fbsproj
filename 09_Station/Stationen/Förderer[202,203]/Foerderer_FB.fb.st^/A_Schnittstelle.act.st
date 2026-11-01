(* METADATA
{
  "v3Meta": {
    "objectGuid": "9d86dc52-bfe4-443c-b83a-950e6825872d"
  }
}
*)
ACTION A_Schnittstelle
//-------------------------------------------------------------------------------------------------
// AKTION SCHNITTSTELLE
//-------------------------------------------------------------------------------------------------

SUPER^.A_Schnittstelle();

// ---------------------------------------------------------------------------------------

(* Hinweis:
   - Abhandlung des Ein-Aus- Transports [Setzen der Variablen das man bereit ist zum Glastransport]
*)
BasisStationsParameter.OutGlasTransport[cWAND_1].wAchsID                    := Glastransport.ppAntriebsInformationen.wAchsID;
BasisStationsParameter.OutGlasTransport[cWAND_1].bEinlaufsensor             REF= Glastransport.bpSensorEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bAuslaufsensor             REF= Glastransport.bpSensorAuslauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport     REF= Glastransport.bpOutBereitZumAustransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumEintransport     REF= Glastransport.bpOutBereitZumEintransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].rGeschwindigkeit           REF= Glastransport.rpOutGeschwindigkeit;
BasisStationsParameter.OutGlasTransport[cWAND_1].bQuittScheibe              REF= Glastransport.bprtScheibe;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf REF= Glastransport.bpScheibeFaehrtUeberEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf REF= Glastransport.bpScheibeFaehrtUeberAuslauf;
// ---------------------------------------------------------------------------------------

BasisStationsParameter.bIstReferenziert := Querfahrt.bpInReferenz;

BasisStationsParameter.rAktuellePositionQuerfahrt := Querfahrt.rpAktuellePosition;

// SK Freigeben obwohl Auftrag aktiv
BasisStationsParameter.bSKFreigabeBeiAktivemAuftrag := ( BasisStationsParameter.bAnlegen
                                                         OR BasisStationsParameter.bAbnehmen );

// SK Blockieren z.B. Sensor belegt
BasisStationsParameter.bSKOeffnenBlockierenDurchgang    := BasisStationsParameter.stMKs.stStationsAufbau.bDurchgang AND 
                                                           ( Glastransport.bpSensorEinlauf
                                                             OR Glastransport.bpSensorAuslauf 
                                                             OR bDurchgangBelegt
                                                             OR ( ( Glastransport.bpSensorEinlaufVorab 
                                                                    OR Glastransport.bpSensorAuslaufVorab ) AND BasisStationsParameter.stMKs.stStationsOptionen.bSKBlockierenDurchVorabSensoren ) );

// Statistik
BasisStationsParameter.dwWartezeit[cWAND_1] := Glastransport.dwpWartezeit;

// Status für die Visu
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlauf[1]          := Glastransport.bpSensorEinlauf;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlaufVorab[1]     := Glastransport.bpSensorEinlaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslaufVorab[1]     := Glastransport.bpSensorAuslaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslauf[1]          := Glastransport.bpSensorAuslauf;

abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].epKippStatus               := Kippen.epKippStatus;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bKippenFehler              := Kippen.bpFehler;

abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].epWandverstellungStatus[1] := Roellchenleiste.wpStatusZylinder;

// Querfahrt
IF BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt THEN
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtFehler              :=  Querfahrt.bpFehler;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtMinEndschalter      :=  Querfahrt.Antrieb.bpMinSchalterBelegt;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtMaxEndschalter      :=  Querfahrt.Antrieb.bpMaxSchalterBelegt;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rQuerfahrtIstPos              :=  Querfahrt.rpAktuellePosition;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtAntriebReferenziert :=  Querfahrt.Antrieb.bpIstReferenziert;
END_IF
END_ACTION