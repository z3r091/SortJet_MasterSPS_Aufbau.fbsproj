(* METADATA
{
  "v3Meta": {
    "objectGuid": "67868d6b-541a-45ac-89e3-ed05617015a3"
  }
}
*)
ACTION A_Baustein_Initialisierung
//==================================================================================================
// AKTION INITIALISIERUNG
//==================================================================================================
// Antriebsparameter zuweisen
Glastransport_X.ppAntriebsInformationen      REF= BasisStationsParameter.stAntriebsparameter.stGlastransport[1];
Glastransport_X.ppAntriebsInformationenSlave REF= BasisStationsParameter.stAntriebsparameter.stGlastransportSlave[1];
Glastransport_Y.ppAntriebsInformationen      REF= BasisStationsParameter.stAntriebsparameter.stGlastransportY[1];
Glastransport_Y.ppAntriebsInformationenSlave REF= BasisStationsParameter.stAntriebsparameter.stGlastransportYSlave[1];

// Stationsparameter zuweisen
Glastransport_X.ppParameterBaustein REF= BasisStationsParameter.stParameterStationskomponenten.stGlastransport[1];
Glastransport_Y.ppParameterBaustein REF= BasisStationsParameter.stParameterStationskomponenten.stGlastransportY[1];

// ---------------------------------------------------------------------------------------
//  INITIALISIERUNG DES BAUSTEIN AUFBAUS
//
//  Hinweis:
//  - Komponenten aktivieren bzw. deaktivieren
// ---------------------------------------------------------------------------------------
Glastransport_X.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bGlastransport[cWAND_1];
Glastransport_Y.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bGlastransport[cWAND_1];
Hubrahmen.bpAktivieren       := BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen;

// ---------------------------------------------------------------------------------------
//  ACHSEN FESTLEGEN
//
//  Hinweis:
//  - Riemenachse aus der MK, Default = Y
//  - Austransport-Achse aus den Schnittstellendaten (es darf nur eine Achse austransportieren),
//    Default = X
// ---------------------------------------------------------------------------------------
IF ( BasisStationsParameter.stMKs.stStationsOptionen.stEckuebergabe.eRiemenAchse = eAchsrichtung_X ) THEN
  elRiemenAchse := eAchsrichtung_X;
ELSE
  elRiemenAchse := eAchsrichtung_Y;
END_IF

elAchseAustransport := eAchsrichtung_X;

FOR wlIndex := cERSTES_SHUTTLE TO cLETZTE_FREMDANLAGE_EINLAUF DO
  IF (  BasisStationsParameter.stMKs.stSchnittstellendaten.aAustransporte.Station[wlIndex] <> TransportRichtung_EN.Default
    AND BasisStationsParameter.stMKs.stSchnittstellendaten.aAustransporte.Achsrichtung[wlIndex] <> eAchsrichtung_Default )
  THEN
    elAchseAustransport := BasisStationsParameter.stMKs.stSchnittstellendaten.aAustransporte.Achsrichtung[wlIndex];
  END_IF
END_FOR

elAchseEintransport  := elAchseAustransport;
elAchseSchnittstelle := elAchseAustransport;
elHubrahmenZielAchse := elAchseAustransport;

GlastransportEin           REF= Glastransport_X;
GlastransportAus           REF= Glastransport_X;
GlastransportSchnittstelle REF= Glastransport_X;

// Hinweis:
// - Einige Bausteine einmalig aufrufen damit die Referenz auf Antriebe geschrieben wird
Glastransport_X( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
Glastransport_Y( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
END_ACTION