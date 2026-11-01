(* METADATA
{
  "v3Meta": {
    "objectGuid": "bed50409-0266-4f1d-9f24-93cebecabd19"
  }
}
*)
ACTION A_Schnittstelle
(***************************************************************************************************)
(* AKTION SCHNITTSTELLE *)
(***************************************************************************************************)

SUPER^.A_Schnittstelle();

(* --------------------------------------------------------------------------------------- *)

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

(* --------------------------------------------------------------------------------------- *)

BasisStationsParameter.bIstReferenziert := Kippen.Antrieb.bpIstReferenziert
                                           AND Querfahrt.bpInReferenz;

BasisStationsParameter.rAktuellePositionQuerfahrt := Querfahrt.rpAktuellePosition;
                                       
BasisStationsParameter.bAuftragAktiv    := (   BasisStationsParameter.bAnlegen
                                             OR BasisStationsParameter.bAbnehmen
                                             OR BasisStationsParameter.bEintransport[cWAND_1]
                                             OR BasisStationsParameter.bAustransport[cWAND_1]
                                             OR BasisStationsParameter.bDurchtransport[cWAND_1]
                                             OR BasisStationsParameter.bMesskopplung[cWAND_1]
                                             OR BasisStationsParameter.bGlashoehenmessung
                                             OR BasisStationsParameter.bGlaslaengenmessung
                                             OR BasisStationsParameter.bReset
                                             OR BasisStationsParameter.bReferenz
                                             OR BasisStationsParameter.bCheck );

// Statistik
BasisStationsParameter.dwWartezeit[cWAND_1] := Glastransport.dwpWartezeit;

// Status für die Visu
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlauf[1]      := Glastransport.bpSensorEinlauf;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlaufVorab[1] := Glastransport.bpSensorEinlaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslaufVorab[1] := Glastransport.bpSensorAuslaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslauf[1]      := Glastransport.bpSensorAuslauf;

abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bKippenFehler              :=  Kippen.bpFehler;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bKippenMinEndschalter      :=  Kippen.Antrieb.bpMinSchalterBelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bKippenMaxEndschalter      :=  Kippen.Antrieb.bpMaxSchalterBelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rKippenIstPos              :=  Kippen.Antrieb.rpIstPosition;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bKippenAntriebReferenziert :=  Kippen.Antrieb.bpIstReferenziert;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].epKippStatus               :=  Kippen.epKippStatus;
END_ACTION