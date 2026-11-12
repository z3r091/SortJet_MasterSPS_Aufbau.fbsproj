(* METADATA
{
	"v3Meta": {
		"objectGuid": "622e673e-767a-4a4b-886e-31b72c44b2df"
	}
}
*)
ACTION A_Schnittstelle
//-------------------------------------------------------------------------------------------------
// SCHNITTSTELLE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Abhandlung des Ein-Aus- Transports [Setzen der Variablen das man bereit ist zum Glastransport]
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO

  BasisStationsParameter.OutGlasTransport[wlIndex].stStationsNummern          := BasisStationsParameter.stMKs.stStationsNummern;
  BasisStationsParameter.OutGlasTransport[wlIndex].wStationsTyp               := BasisStationsParameter.stMKs.eStationsTyp;
  BasisStationsParameter.OutGlasTransport[wlIndex].wAchsID                    := Glastransport[wlIndex].ppAntriebsInformationen.wAchsID;
  BasisStationsParameter.OutGlasTransport[wlIndex].rLaengeStation             := Glastransport[wlIndex].ppParameterBaustein.rLaengeStation;
  BasisStationsParameter.OutGlasTransport[wlIndex].bEinlaufsensor             REF= in_bSensorEinlauf[wlIndex];
  BasisStationsParameter.OutGlasTransport[wlIndex].bAuslaufsensor             REF= in_bSensorAuslauf[wlIndex];
  BasisStationsParameter.OutGlasTransport[wlIndex].bBereitZumAustransport     REF= Glastransport[wlIndex].bpOutBereitZumAustransport;
  BasisStationsParameter.OutGlasTransport[wlIndex].bBereitZumEintransport     REF= Glastransport[wlIndex].bpOutBereitZumEintransport;
  BasisStationsParameter.OutGlasTransport[wlIndex].rGeschwindigkeit           REF= Glastransport[wlIndex].rpOutGeschwindigkeit;
  BasisStationsParameter.OutGlasTransport[wlIndex].bFehler                    REF= BasisStationsParameter.bFehler;
  // Scheibenquittierung: Glastransport bzw. Greifer [Ausbaustufe]
  ablQuittScheibe[wlIndex] :=    Glastransport[wlIndex].bprtScheibe
                              OR ( Greifer[wlIndex].bprtScheibe AND BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex] );

  BasisStationsParameter.OutGlasTransport[wlIndex].bQuittScheibe              REF= ablQuittScheibe[wlIndex];
  BasisStationsParameter.OutGlasTransport[wlIndex].bFreigabe                  REF= BasisStationsParameter.bFreigabe;
  BasisStationsParameter.OutGlasTransport[wlIndex].bTransportAbgeschlossen    REF= bgFALSE;
  BasisStationsParameter.OutGlasTransport[wlIndex].bScheibeFaehrtUeberEinlauf REF= bgFALSE;
  BasisStationsParameter.OutGlasTransport[wlIndex].bScheibeFaehrtUeberAuslauf REF= bgFALSE;
  BasisStationsParameter.OutGlasTransport[wlIndex].bTransportRueckwaertig     REF= BasisStationsParameter.bRueckwaertsTransportieren[wlIndex];

END_FOR

// ---------------------------------------------------------------------------------------
// BAUSTEIN BASISPARAMETER
BasisStationsParameter.bIstReferenziert        := ( Querfahrt.Antrieb.bpIstReferenziert OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt )
                                              AND ( Kippen.bpInReferenz OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1] );

// Greifer [Ausbaustufe]
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  BasisStationsParameter.bIstReferenziert := BasisStationsParameter.bIstReferenziert
                                             AND ( Greifer[wlIndex].bpIstInReferenz OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex] );
END_FOR


(* Hinweis:
   - Status ob Glastransportiert wird
     => Gebrauch der Resourcen Glastransport
*)
blMerkerAuftragAktiv := FALSE;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blMerkerAuftragAktiv := blMerkerAuftragAktiv OR
                          ( BasisStationsParameter.bEintransport[wlIndex] AND ( Eintransport[wlIndex].steplAktion  > STEP_0_E) )
                          OR ( BasisStationsParameter.bAustransport[wlIndex] AND ( Austransport[wlIndex].steplAktion  > STEP_0_E) );
END_FOR

BasisStationsParameter.bAuftragAktiv :=  ( blMerkerAuftragAktiv
                                           OR ( BasisStationsParameter.bVorabpositionieren AND ( steplVorabpositionierung > STEP_0_E) )
                                           OR BasisStationsParameter.bCheck );

// Statistik
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  BasisStationsParameter.dwWartezeit[wlIndex] := Glastransport[wlIndex].dwpWartezeit;
END_FOR

dwlHandfunktionen := BasisStationsParameter.dwHandfunktionen;

// Status für die Visu
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlauf[wlIndex]          := Glastransport[wlIndex].bpSensorEinlauf;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlaufVorab[wlIndex]     := Glastransport[wlIndex].bpSensorEinlaufVorab;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslaufVorab[wlIndex]     := Glastransport[wlIndex].bpSensorAuslaufVorab;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslauf[wlIndex]          := Glastransport[wlIndex].bpSensorAuslauf;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslaufStopp[wlIndex]     := Glastransport[wlIndex].bpSensorAuslaufStopp;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].epWandverstellungStatus[wlIndex] := Wandverstellung[wlIndex].eStatusStellung;
  abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bGeblaeseLaeuft[wlIndex]         := Geblaese[wlIndex].out_bStarteGeblaese;
END_FOR

// Kippen
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bKippenFehler                :=  Kippen.bpFehler;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].epKippStatus                 :=  Kippen.epKippStatus;

// Querfahrt
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtFehler              :=  Querfahrt.bpFehler;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtMinEndschalter      :=  Querfahrt.Antrieb.bpMinSchalterBelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtMaxEndschalter      :=  Querfahrt.Antrieb.bpMaxSchalterBelegt;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rQuerfahrtIstPos              :=  Querfahrt.rpAktPosition;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bQuerfahrtAntriebReferenziert :=  Querfahrt.Antrieb.bpIstReferenziert;
END_ACTION