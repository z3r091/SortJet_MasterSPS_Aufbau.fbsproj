(* METADATA
{
	"v3Meta": {
		"objectGuid": "9e804bc8-ba24-4b22-9406-1dd459fada6f"
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
BasisStationsParameter.OutGlasTransport[cWAND_1].rLaengeStation             := Glastransport.ppParameterBaustein.rLaengeStation;
BasisStationsParameter.OutGlasTransport[cWAND_1].bEinlaufsensor             REF= Glastransport.bpSensorEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bAuslaufsensor             REF= Glastransport.bpSensorAuslauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport     REF= Glastransport.bpOutBereitZumAustransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumEintransport     REF= Glastransport.bpOutBereitZumEintransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].rGeschwindigkeit           REF= Glastransport.rpOutGeschwindigkeit;
BasisStationsParameter.OutGlasTransport[cWAND_1].bQuittScheibe              REF= Glastransport.bprtScheibe;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bTransportRueckwaertig     REF= BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

// ---------------------------------------------------------------------------------------
// BAUSTEIN BASISPARAMETER
BasisStationsParameter.bIstReferenziert        := Messachse.bpInReferenz OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bMessachse;

// SK Freigeben obwohl Auftrag aktiv
BasisStationsParameter.bSKFreigabeBeiAktivemAuftrag := ( BasisStationsParameter.bAnlegen
                                                         OR BasisStationsParameter.bAbnehmen );

// Status für die Visu
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlauf[1]            := Glastransport.bpSensorEinlauf;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlaufVorab[1]       := Glastransport.bpSensorEinlaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslaufVorab[1]       := Glastransport.bpSensorAuslaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslauf[1]            := Glastransport.bpSensorAuslauf;

abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bMessachseFehler             := Messachse.bpFehler;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bMessachseSensorOben         := Messachse.in_bSensorOben;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bMessachseSensorUnten        := Messachse.in_bSensorUnten;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bMessachseMinEndschalter     := Messachse.Antrieb.bpMinSchalterBelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rMessachseIstPos             := Messachse.rpIstPosition;
                                                                                                                
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAnschlagFehler              := Anschlag.bpFehler;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAnschlagSensorAusgefahren   := Anschlag.in_bStatusZylinderAusgefahren;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAnschlagSensorEingefahren   := Anschlag.in_bStatusZylinderEingefahren;
                                                                                                                
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bHubpaletteFehler            := Hubrahmen.bpFehler;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bHubpaletteSensorAusgefahren := Hubrahmen.in_bStatusZylinderAusgefahren;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bHubpaletteSensorEingefahren := Hubrahmen.in_bStatusZylinderEingefahren;
                                                                                                                
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAmpelRot                    := out_bAmpelSignalRot OR abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bOutAmpelRot;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAmpelGruen                  := out_bAmpelSignalGruenScheibeAnlegen OR abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bOutAmpelGruen;
                                                                                                                
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bInTasterGlasAngelegt        := in_bTasterGlasAngelegt OR in_bFussschalterGlasAngelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bInTasterGeblaese            := in_bTasterGeblaese1Ein;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bInTasterFehlmessung         := in_bTasterQuittierungScheibenmessung;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bInTasterGlasbruch           := in_bTasterGlasBruch;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bInTasterFehlmessung         := in_bKnebelRiemenZurueck;

// Ausgang:
//   - Meldeleuchte für die ausgelöste Schaltleiste
out_bSchaltleisteAusgeloest := in_bSchaltleisteAusgeloest OR in_bSchaltleisteAusgeloest_Safety;
out_bLeuchteKipptischOffen := out_bLeuchteKipptischOffen_OP := NOT in_bSensorKipptischUnten;

(* Hinweis:
   - Ampelsignal "Rot" für den Bediener wenn Betriebsstop ausgeloest worden ist
*)
out_bAmpelSignalRot  := gbFlashbit03sec AND Stop_Baustein.blBetriebsstop;
out_bSignalTasterScheibeAnlegen := out_bAmpelSignalGruenScheibeAnlegen;
out_bAmpelSignalGlastransportAktiv := ( Glastransport.Antrieb.wpBetriebsart <> AntriebsBetriebsart_EN.KEINE_FUNKTION 
                                        AND Glastransport.Antrieb.wpBetriebsart <> AntriebsBetriebsart_EN.REFERENZ 
                                        AND Glastransport.Antrieb.wpBetriebsart <> AntriebsBetriebsart_EN.RESET ) 
                                      OR ( Messachse.Antrieb.wpBetriebsart <> AntriebsBetriebsart_EN.KEINE_FUNKTION
                                           AND Messachse.Antrieb.wpBetriebsart <> AntriebsBetriebsart_EN.REFERENZ 
                                           AND Messachse.Antrieb.wpBetriebsart <> AntriebsBetriebsart_EN.RESET );
END_ACTION