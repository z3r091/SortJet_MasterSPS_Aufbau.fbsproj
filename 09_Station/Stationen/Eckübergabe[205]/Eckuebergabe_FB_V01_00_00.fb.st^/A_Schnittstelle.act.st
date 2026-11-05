(* METADATA
{
  "v3Meta": {
    "objectGuid": "5adbd17f-cff5-44a9-bdee-a68d82a475b0"
  }
}
*)
ACTION A_Schnittstelle
//==================================================================================================
// AKTION SCHNITTSTELLE
//==================================================================================================
SUPER^.A_Schnittstelle();

// ---------------------------------------------------------------------------------------
//  AKTIVE ACHSEN BESTIMMEN
//
//  Hinweis:
//  - Eintransport-Achse kommt aus dem Auftrag (Basis-Schrittkette Station_Eintransport)
//  - Waehrend des Eintransports gehen die Signale der Eintransport-Achse an die Nachbarn,
//    sonst die der Austransport-Achse
// ---------------------------------------------------------------------------------------
IF ( BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eAchsrichtung = eAchsrichtung_Y ) THEN
  elAchseEintransport := eAchsrichtung_Y;
ELSIF ( BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eAchsrichtung = eAchsrichtung_X ) THEN
  elAchseEintransport := eAchsrichtung_X;
ELSE
  elAchseEintransport := elAchseAustransport;
END_IF

IF ( BasisStationsParameter.bEintransport[cWAND_1] ) THEN
  elAchseSchnittstelle := elAchseEintransport;
ELSE
  elAchseSchnittstelle := elAchseAustransport;
END_IF

IF ( elAchseEintransport = eAchsrichtung_Y ) THEN
  GlastransportEin REF= Glastransport_Y;
ELSE
  GlastransportEin REF= Glastransport_X;
END_IF

IF ( elAchseAustransport = eAchsrichtung_Y ) THEN
  GlastransportAus REF= Glastransport_Y;
ELSE
  GlastransportAus REF= Glastransport_X;
END_IF

IF ( elAchseSchnittstelle = eAchsrichtung_Y ) THEN
  GlastransportSchnittstelle REF= Glastransport_Y;
ELSE
  GlastransportSchnittstelle REF= Glastransport_X;
END_IF

// ---------------------------------------------------------------------------------------
//  SCHNITTSTELLE ZU DEN NACHBARSTATIONEN
//
//  Hinweis:
//  - Abhandlung des Ein-Aus- Transports [Setzen der Variablen das man bereit ist zum Glastransport]
// ---------------------------------------------------------------------------------------
BasisStationsParameter.OutGlasTransport[cWAND_1].wAchsID                    := GlastransportSchnittstelle.ppAntriebsInformationen.wAchsID;
BasisStationsParameter.OutGlasTransport[cWAND_1].rLaengeStation             := GlastransportSchnittstelle.ppParameterBaustein.rLaengeStation;
BasisStationsParameter.OutGlasTransport[cWAND_1].bEinlaufsensor             REF= GlastransportSchnittstelle.bpSensorEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bAuslaufsensor             REF= GlastransportSchnittstelle.bpSensorAuslauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport     REF= GlastransportSchnittstelle.bpOutBereitZumAustransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumEintransport     REF= GlastransportSchnittstelle.bpOutBereitZumEintransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].rGeschwindigkeit           REF= GlastransportSchnittstelle.rpOutGeschwindigkeit;
BasisStationsParameter.OutGlasTransport[cWAND_1].bQuittScheibe              REF= GlastransportSchnittstelle.bprtScheibe;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf REF= GlastransportSchnittstelle.bpScheibeFaehrtUeberEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf REF= GlastransportSchnittstelle.bpScheibeFaehrtUeberAuslauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bTransportRueckwaertig     REF= BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

// Keine Querfahrt
BasisStationsParameter.bIstReferenziert := TRUE;

// Statistik
BasisStationsParameter.dwWartezeit[cWAND_1] := GlastransportSchnittstelle.dwpWartezeit;

// Status fuer die Visu (Sensoren der X-Achse)
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlauf[1]      := Glastransport_X.bpSensorEinlauf;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorEinlaufVorab[1] := Glastransport_X.bpSensorEinlaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslaufVorab[1] := Glastransport_X.bpSensorAuslaufVorab;
abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bSensorAuslauf[1]      := Glastransport_X.bpSensorAuslauf;
END_ACTION