(* METADATA
{
  "v3Meta": {
    "objectGuid": "ba53d487-b3e7-4729-ab5c-8ab03e7357e2"
  }
}
*)
PROGRAM VisuUebersicht_PRG
VAR
  bBlink        : BOOL;
  bLernen       : BOOL;
  bSK1, bSK2    : BOOL;
  bStoerung     : BOOL;
  wAnzStoerung  : WORD;
  sKipp         : STRING(40);
  bDummy        : BOOL;
  wIdx          : WORD;
  sNr           : STRING(5);
END_VAR
// *************************************************************************************************
// DATENAUFBEREITUNG FUER DIE VISU "Anlagenuebersicht"
// - Visu verwendet ausschliesslich die Variablen aus VISU_UEBERSICHT (Texte, Farben, Pixel)
// *************************************************************************************************
bBlink  := Global_Vars.gbFlashbit05sec;
bLernen := VISU_UEBERSICHT.bSkalierungNeuLernen;
VISU_UEBERSICHT.bSkalierungNeuLernen := FALSE;

// -------------------------------------------------------------------------------------------
// KOPFZEILE
// -------------------------------------------------------------------------------------------
bSK1 := Globale_Bausteine.Sicherheitskreis[1].bpSicherheitskreisGeschlossen;
bSK2 := Globale_Bausteine.Sicherheitskreis[2].bpSicherheitskreisGeschlossen;

bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stAutomatik,      sText := SEL(Global_Vars.M_Automatik_Aktiv[1], 'HAND', 'AUTOMATIK'), bOK := Global_Vars.M_Automatik_Aktiv[1], bWarnung := TRUE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stSK1,            sText := SEL(bSK1, 'SK 1 offen', 'SK 1 zu'), bOK := bSK1, bWarnung := TRUE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stSK2,            sText := SEL(bSK2, 'SK 2 offen', 'SK 2 zu'), bOK := bSK2, bWarnung := TRUE, bNeutral := FALSE);
// Tueren: je Tuer eine Anzeige (zu = gruen, Anforderung = orange blinkend, offen = rot)
FOR wIdx := 1 TO VISU_UEBERSICHT.cMAX_TUEREN DO
  VISU_UEBERSICHT.abTuerVorhanden[wIdx] := (wIdx >= Stations_Konfig.cERSTE_TUER) AND (wIdx <= Stations_Konfig.cLETZTE_TUER);
  IF VISU_UEBERSICHT.abTuerVorhanden[wIdx] THEN
    sNr := WORD_TO_STRING(wIdx);
    IF Globale_Bausteine.aTuer[wIdx].bpStatusTuerNichtGeschlossen THEN
      VISU_UEBERSICHT.astTuer[wIdx].sText   := CONCAT(CONCAT('Tür ', sNr), ' offen');
      VISU_UEBERSICHT.astTuer[wIdx].dwFarbe := VISU_UEBERSICHT.cFARBE_ROT;
    ELSIF Globale_Bausteine.aTuer[wIdx].bpAnforderungZumTuerOffnenGestellt THEN
      VISU_UEBERSICHT.astTuer[wIdx].sText   := CONCAT(CONCAT('Tür ', sNr), ' Anford.');
      VISU_UEBERSICHT.astTuer[wIdx].dwFarbe := SEL(bBlink, VISU_UEBERSICHT.cFARBE_GRAU, VISU_UEBERSICHT.cFARBE_ORANGE);
    ELSE
      VISU_UEBERSICHT.astTuer[wIdx].sText   := CONCAT(CONCAT('Tür ', sNr), ' zu');
      VISU_UEBERSICHT.astTuer[wIdx].dwFarbe := VISU_UEBERSICHT.cFARBE_GRUEN;
    END_IF
  END_IF
END_FOR

// Durchgaenge
FOR wIdx := 1 TO VISU_UEBERSICHT.cMAX_DURCHGAENGE DO
  VISU_UEBERSICHT.abDurchgangVorhanden[wIdx] := (wIdx >= Stations_Konfig.cERSTER_DURCHGANG) AND (wIdx <= Stations_Konfig.cLETZTER_DURCHGANG);
  IF VISU_UEBERSICHT.abDurchgangVorhanden[wIdx] THEN
    sNr := WORD_TO_STRING(wIdx);
    IF Globale_Bausteine.aDurchgang[wIdx].bpStatusDurchgangNichtGeschlossen THEN
      VISU_UEBERSICHT.astDurchgang[wIdx].sText   := CONCAT(CONCAT('Durchgang ', sNr), ' offen');
      VISU_UEBERSICHT.astDurchgang[wIdx].dwFarbe := VISU_UEBERSICHT.cFARBE_ROT;
    ELSIF Globale_Bausteine.aDurchgang[wIdx].bpAnforderungZumDurchgangOffnenGestellt THEN
      VISU_UEBERSICHT.astDurchgang[wIdx].sText   := CONCAT(CONCAT('Durchgang ', sNr), ' Anf.');
      VISU_UEBERSICHT.astDurchgang[wIdx].dwFarbe := SEL(bBlink, VISU_UEBERSICHT.cFARBE_GRAU, VISU_UEBERSICHT.cFARBE_ORANGE);
    ELSE
      VISU_UEBERSICHT.astDurchgang[wIdx].sText   := CONCAT(CONCAT('Durchgang ', sNr), ' zu');
      VISU_UEBERSICHT.astDurchgang[wIdx].dwFarbe := VISU_UEBERSICHT.cFARBE_GRUEN;
    END_IF
  END_IF
END_FOR
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stDruckluft,      sText := 'Druckluft',     bOK := StatusAnlage.abpDruckluftOK[1], bWarnung := FALSE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stSchaltschrank,  sText := 'Schaltschrank', bOK := StatusAnlage.bpAnlageOK, bWarnung := FALSE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stEtherCAT,       sText := 'EtherCAT',      bOK := Global_Vars.bgEtherCatOK, bWarnung := FALSE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stInit,           sText := 'Init',          bOK := Global_Vars.M_Init_Ok, bWarnung := TRUE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stMMI,            sText := 'MMI',           bOK := MMI_Vars.bgMMIOK OR Global_Vars.bgMMIBruecken, bWarnung := Global_Vars.bgMMIBruecken, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stBetriebsstop,   sText := SEL(Globale_Bausteine.Stop_Baustein.abpBetriebsstop[1], 'Betrieb', 'BETRIEBSSTOP'), bOK := NOT Globale_Bausteine.Stop_Baustein.abpBetriebsstop[1], bWarnung := FALSE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stInbetriebnahme, sText := 'IBN-Modus',     bOK := FALSE, bWarnung := TRUE, bNeutral := NOT Global_Vars.bgInbetriebnahmeBit);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stSimulation,     sText := 'Simulation',    bOK := FALSE, bWarnung := TRUE, bNeutral := NOT Global_Vars.bgSimAktiv);

// -------------------------------------------------------------------------------------------
// STATIONEN
// -------------------------------------------------------------------------------------------
wAnzStoerung := 0;

// [501] Einlauf Fremdanlage (VSG)
IF VisuUeb_Station(stBP := StationBasisParameter.starrFremdanlageEinlaufStationBasisParameter[501], stKarte := VISU_UEBERSICHT.st501, sTitel := '501  Einlauf Fremdanlage', bBlink := bBlink, bReferenzRelevant := FALSE, bGlasZusatz := FALSE) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
VISU_UEBERSICHT.st501.sInfo1 := SEL(VISU_VARS.abgVISUFreigabeFremdanlage[501], 'Freigabe Visu: aus', 'Freigabe Visu: EIN');
VISU_UEBERSICHT.st501.sInfo2 := '';
VISU_UEBERSICHT.st501.sInfo3 := '';

// [201] Anlegetisch
IF VisuUeb_Station(stBP := StationBasisParameter.starrStationBasisParameter[201], stKarte := VISU_UEBERSICHT.st201, sTitel := '201  Anlegetisch', bBlink := bBlink, bReferenzRelevant := TRUE,
                    bGlasZusatz := abgStationsstatusVisu[201].bSensorEinlauf[1] OR abgStationsstatusVisu[201].bSensorAuslauf[1]) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
VISU_UEBERSICHT.st201.dwSensorEinlauf      := VisuUeb_Sensor(abgStationsstatusVisu[201].bSensorEinlauf[1]);
VISU_UEBERSICHT.st201.dwSensorEinlaufVorab := VisuUeb_Sensor(abgStationsstatusVisu[201].bSensorEinlaufVorab[1]);
VISU_UEBERSICHT.st201.dwSensorAuslaufVorab := VisuUeb_Sensor(abgStationsstatusVisu[201].bSensorAuslaufVorab[1]);
VISU_UEBERSICHT.st201.dwSensorAuslauf      := VisuUeb_Sensor(abgStationsstatusVisu[201].bSensorAuslauf[1]);
VISU_UEBERSICHT.st201.sInfo1 := VisuUeb_MmText(sPrefix := 'Messachse ', rWert := abgStationsstatusVisu[201].rMessachseIstPos);
VISU_UEBERSICHT.st201.dwInfo1Farbe := SEL(abgStationsstatusVisu[201].bMessachseFehler, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);
VISU_UEBERSICHT.st201.sInfo2 := CONCAT(CONCAT('Anschlag ', SEL(abgStationsstatusVisu[201].bAnschlagSensorAusgefahren, SEL(abgStationsstatusVisu[201].bAnschlagSensorEingefahren, '?', 'unten'), 'oben')),
                                        CONCAT('  |  Hubrahmen ', SEL(abgStationsstatusVisu[201].bHubpaletteSensorAusgefahren, SEL(abgStationsstatusVisu[201].bHubpaletteSensorEingefahren, '?', 'unten'), 'oben')));
VISU_UEBERSICHT.st201.dwInfo2Farbe := SEL(abgStationsstatusVisu[201].bAnschlagFehler OR abgStationsstatusVisu[201].bHubpaletteFehler, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);
VISU_UEBERSICHT.st201.sInfo3 := CONCAT(SEL(abgStationsstatusVisu[201].bGeblaeseLaeuft[1], 'Gebläse aus', 'Gebläse EIN'),
                                        SEL(abgStationsstatusVisu[201].bDrosselklappeOffen[1], '  |  Klappe zu', '  |  Klappe auf'));
VISU_UEBERSICHT.st201.dwInfo3Farbe := SEL(abgStationsstatusVisu[201].bGeblaeseLaeuft[1], VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_BLAU);

// [202] Kipptisch
IF VisuUeb_Station(stBP := StationBasisParameter.starrStationBasisParameter[202], stKarte := VISU_UEBERSICHT.st202, sTitel := '202  Kipptisch', bBlink := bBlink, bReferenzRelevant := TRUE,
                    bGlasZusatz := abgStationsstatusVisu[202].bSensorEinlauf[1] OR abgStationsstatusVisu[202].bSensorAuslauf[1]) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
VISU_UEBERSICHT.st202.dwSensorEinlauf      := VisuUeb_Sensor(abgStationsstatusVisu[202].bSensorEinlauf[1]);
VISU_UEBERSICHT.st202.dwSensorEinlaufVorab := VisuUeb_Sensor(abgStationsstatusVisu[202].bSensorEinlaufVorab[1]);
VISU_UEBERSICHT.st202.dwSensorAuslaufVorab := VisuUeb_Sensor(abgStationsstatusVisu[202].bSensorAuslaufVorab[1]);
VISU_UEBERSICHT.st202.dwSensorAuslauf      := VisuUeb_Sensor(abgStationsstatusVisu[202].bSensorAuslauf[1]);
CASE abgStationsstatusVisu[202].epKippStatus OF
  Kippen_EN.eKippen_Position_0Grad:    sKipp := '0°';
  Kippen_EN.eKippen_Position_84Grad:   sKipp := '84°';
  Kippen_EN.eKippen_Position_88_5Grad: sKipp := '88,5°';
  Kippen_EN.eKippen_Position_90Grad:   sKipp := '90°';
  Kippen_EN.eKippen_Position_96Grad:   sKipp := '96°';
  Kippen_EN.eKippen_Fehler:            sKipp := 'FEHLER';
  ELSE                                   sKipp := 'Zwischenpos.';
END_CASE
VISU_UEBERSICHT.st202.sInfo1 := CONCAT(CONCAT('Kippen ', sKipp), VisuUeb_MmText(sPrefix := '  (', rWert := abgStationsstatusVisu[202].rKippenIstPos, sEinheit := ')'));
VISU_UEBERSICHT.st202.dwInfo1Farbe := SEL(abgStationsstatusVisu[202].bKippenFehler OR NOT abgStationsstatusVisu[202].bKippenAntriebReferenziert, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);
VISU_UEBERSICHT.st202.sInfo2 := VisuUeb_MmText(sPrefix := 'Querfahrt ', rWert := abgStationsstatusVisu[202].rQuerfahrtIstPos);
VISU_UEBERSICHT.st202.dwInfo2Farbe := SEL(abgStationsstatusVisu[202].bQuerfahrtFehler OR NOT abgStationsstatusVisu[202].bQuerfahrtAntriebReferenziert, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);
VISU_UEBERSICHT.st202.sInfo3 := SEL(abgStationsstatusVisu[202].bKippenMinEndschalter OR abgStationsstatusVisu[202].bKippenMaxEndschalter OR abgStationsstatusVisu[202].bQuerfahrtMinEndschalter OR abgStationsstatusVisu[202].bQuerfahrtMaxEndschalter,
                                     'Endschalter frei', 'ENDSCHALTER BELEGT');
VISU_UEBERSICHT.st202.dwInfo3Farbe := SEL(VISU_UEBERSICHT.st202.sInfo3 = 'Endschalter frei', VISU_UEBERSICHT.cFARBE_ROT, VISU_UEBERSICHT.cFARBE_TEXT);
// Kipptisch ohne Querfahrt (MK-Stationsaufbau): Querfahrt-Infos ausblenden
IF __ISVALIDREF(StationBasisParameter.starrStationBasisParameter[202].stMKs) THEN
  IF NOT StationBasisParameter.starrStationBasisParameter[202].stMKs.stStationsAufbau.bQuerfahrt THEN
    VISU_UEBERSICHT.st202.sInfo2 := '';
    VISU_UEBERSICHT.st202.sInfo3 := SEL(abgStationsstatusVisu[202].bKippenMinEndschalter OR abgStationsstatusVisu[202].bKippenMaxEndschalter, 'Endschalter frei', 'ENDSCHALTER BELEGT');
  END_IF
END_IF

// [101] Shuttle
IF VisuUeb_Station(stBP := StationBasisParameter.starrShuttleBasisParameter[101], stKarte := VISU_UEBERSICHT.st101, sTitel := '101  Shuttle', bBlink := bBlink, bReferenzRelevant := TRUE,
                    bGlasZusatz := abgStationsstatusVisu[101].bSensorEinlauf[1] OR abgStationsstatusVisu[101].bSensorAuslauf[1] OR abgStationsstatusVisu[101].bSensorAuslaufStopp[1]) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
VISU_UEBERSICHT.st101.dwSensorEinlauf      := VisuUeb_Sensor(abgStationsstatusVisu[101].bSensorEinlauf[1]);
VISU_UEBERSICHT.st101.dwSensorEinlaufVorab := VisuUeb_Sensor(abgStationsstatusVisu[101].bSensorEinlaufVorab[1]);
VISU_UEBERSICHT.st101.dwSensorAuslaufVorab := VisuUeb_Sensor(abgStationsstatusVisu[101].bSensorAuslaufVorab[1]);
VISU_UEBERSICHT.st101.dwSensorAuslauf      := VisuUeb_Sensor(abgStationsstatusVisu[101].bSensorAuslauf[1] OR abgStationsstatusVisu[101].bSensorAuslaufStopp[1]);
CASE abgStationsstatusVisu[101].epKippStatus OF
  Kippen_EN.eKippen_Position_0Grad:    sKipp := 'Kippen 0°';
  Kippen_EN.eKippen_Position_84Grad:   sKipp := 'Kippen 84°';
  Kippen_EN.eKippen_Position_88_5Grad: sKipp := 'Kippen 88,5°';
  Kippen_EN.eKippen_Position_90Grad:   sKipp := 'Kippen 90°';
  Kippen_EN.eKippen_Position_96Grad:   sKipp := 'Kippen 96°';
  Kippen_EN.eKippen_Fehler:            sKipp := 'Kippen FEHLER';
  ELSE                                   sKipp := 'Kippen Zwischenpos.';
END_CASE
VISU_UEBERSICHT.st101.sInfo1 := CONCAT(sKipp, SEL(abgStationsstatusVisu[101].bGeblaeseLaeuft[1], '  |  Gebläse aus', '  |  Gebläse EIN'));
VISU_UEBERSICHT.st101.dwInfo1Farbe := SEL(abgStationsstatusVisu[101].bKippenFehler, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);

// Fahrwegsgrenzen aus dem Antrieb (Software-Endlagen)
IF __ISVALIDREF(Globale_Bausteine.aShuttle[101].Querfahrt.Antrieb) THEN
  VISU_UEBERSICHT.rMin101            := Globale_Bausteine.aShuttle[101].Querfahrt.Antrieb.rpMinPosition;
  VISU_UEBERSICHT.rMax101            := Globale_Bausteine.aShuttle[101].Querfahrt.Antrieb.rpMaxPosition;
  VISU_UEBERSICHT.bSkalierung101Init := TRUE;
END_IF
VisuUeb_Achse(stAchse := VISU_UEBERSICHT.stAchse101, bInit := VISU_UEBERSICHT.bSkalierung101Init, rMin := VISU_UEBERSICHT.rMin101, rMax := VISU_UEBERSICHT.rMax101,
               rIst            := abgStationsstatusVisu[101].rQuerfahrtIstPos,
               rZiel           := Globale_Bausteine.aShuttle[101].Querfahrt.rpDestinationPosition,
               rSpeed          := Globale_Bausteine.aShuttle[101].Querfahrt.rpAktSpeed,
               bPositionierung := Globale_Bausteine.aShuttle[101].Querfahrt.bpPositionierungAktiv,
               bReferenziert   := abgStationsstatusVisu[101].bQuerfahrtAntriebReferenziert,
               bFehler         := abgStationsstatusVisu[101].bQuerfahrtFehler,
               bMinEnd         := abgStationsstatusVisu[101].bQuerfahrtMinEndschalter,
               bMaxEnd         := abgStationsstatusVisu[101].bQuerfahrtMaxEndschalter,
               bNeuLernen      := bLernen,
               bBlink          := bBlink);
VISU_UEBERSICHT.st101.sInfo2 := VISU_UEBERSICHT.stAchse101.sIstPos;
VISU_UEBERSICHT.st101.sInfo3 := VISU_UEBERSICHT.stAchse101.sZielPos;
VISU_UEBERSICHT.sLblMin101 := VisuUeb_MmText(sPrefix := '', rWert := VISU_UEBERSICHT.rMin101);
VISU_UEBERSICHT.sLblMax101 := VisuUeb_MmText(sPrefix := '', rWert := VISU_UEBERSICHT.rMax101);

// [151] Transfershuttle
IF VisuUeb_Station(stBP := StationBasisParameter.starrTransfershuttleBasisParameter[151], stKarte := VISU_UEBERSICHT.st151, sTitel := '151  Transfershuttle', bBlink := bBlink, bReferenzRelevant := TRUE,
                    bGlasZusatz := abgStationsstatusVisu[151].bSensorEinlauf[1] OR abgStationsstatusVisu[151].bSensorAuslauf[1]) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
VISU_UEBERSICHT.st151.dwSensorEinlauf      := VisuUeb_Sensor(abgStationsstatusVisu[151].bSensorEinlauf[1]);
VISU_UEBERSICHT.st151.dwSensorEinlaufVorab := VisuUeb_Sensor(FALSE, FALSE);
VISU_UEBERSICHT.st151.dwSensorAuslaufVorab := VisuUeb_Sensor(FALSE, FALSE);
VISU_UEBERSICHT.st151.dwSensorAuslauf      := VisuUeb_Sensor(abgStationsstatusVisu[151].bSensorAuslauf[1]);
VISU_UEBERSICHT.st151.sInfo1 := SEL(Global_Vars.abgVerfahrfreigabeShuttle[151], 'Verfahrfreigabe: NEIN', 'Verfahrfreigabe: ja');
VISU_UEBERSICHT.st151.dwInfo1Farbe := SEL(Global_Vars.abgVerfahrfreigabeShuttle[151], VISU_UEBERSICHT.cFARBE_ORANGE, VISU_UEBERSICHT.cFARBE_TEXT);

// Fahrwegsgrenzen aus dem Antrieb (Software-Endlagen)
IF __ISVALIDREF(Globale_Bausteine.aTransfershuttles[151].Querfahrt.Antrieb) THEN
  VISU_UEBERSICHT.rMin151            := Globale_Bausteine.aTransfershuttles[151].Querfahrt.Antrieb.rpMinPosition;
  VISU_UEBERSICHT.rMax151            := Globale_Bausteine.aTransfershuttles[151].Querfahrt.Antrieb.rpMaxPosition;
  VISU_UEBERSICHT.bSkalierung151Init := TRUE;
END_IF
VisuUeb_Achse(stAchse := VISU_UEBERSICHT.stAchse151, bInit := VISU_UEBERSICHT.bSkalierung151Init, rMin := VISU_UEBERSICHT.rMin151, rMax := VISU_UEBERSICHT.rMax151,
               rIst            := abgStationsstatusVisu[151].rQuerfahrtIstPos,
               rZiel           := Globale_Bausteine.aTransfershuttles[151].Querfahrt.rpDestinationPosition,
               rSpeed          := Globale_Bausteine.aTransfershuttles[151].Querfahrt.rpAktSpeed,
               bPositionierung := Globale_Bausteine.aTransfershuttles[151].Querfahrt.bpPositionierungAktiv,
               bReferenziert   := abgStationsstatusVisu[151].bQuerfahrtAntriebReferenziert,
               bFehler         := abgStationsstatusVisu[151].bQuerfahrtFehler,
               bMinEnd         := abgStationsstatusVisu[151].bQuerfahrtMinEndschalter,
               bMaxEnd         := abgStationsstatusVisu[151].bQuerfahrtMaxEndschalter,
               bNeuLernen      := bLernen,
               bBlink          := bBlink);
VISU_UEBERSICHT.st151.sInfo2 := VISU_UEBERSICHT.stAchse151.sIstPos;
VISU_UEBERSICHT.st151.sInfo3 := VISU_UEBERSICHT.stAchse151.sZielPos;
VISU_UEBERSICHT.sLblMin151 := VisuUeb_MmText(sPrefix := '', rWert := VISU_UEBERSICHT.rMin151);
VISU_UEBERSICHT.sLblMax151 := VisuUeb_MmText(sPrefix := '', rWert := VISU_UEBERSICHT.rMax151);

// [301] / [302] Faecherwagen
IF VisuUeb_Station(stBP := StationBasisParameter.starrFaecherwagenBasisParameter[301], stKarte := VISU_UEBERSICHT.st301, sTitel := '301  Fächerwagen', bBlink := bBlink, bReferenzRelevant := FALSE,
                    bGlasZusatz := VISU_VARS.astgFaecherwagenstatusVisu[301].bStatusStationInBeladePosition) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
VISU_UEBERSICHT.st301.sInfo1 := SEL(VISU_VARS.astgFaecherwagenstatusVisu[301].bStatusStationInBeladePosition, 'Wagen nicht in Beladeposition', 'Wagen in Beladeposition');
VISU_UEBERSICHT.st301.dwInfo1Farbe := SEL(VISU_VARS.astgFaecherwagenstatusVisu[301].bStatusStationInBeladePosition, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_GRUEN);
VISU_UEBERSICHT.st301.sInfo2 := SEL(VISU_VARS.astgFaecherwagenstatusVisu[301].bBoxInHomePosition, 'Box nicht in Home', 'Box in Home');
VISU_UEBERSICHT.st301.sInfo3 := SEL(VISU_VARS.astgFaecherwagenstatusVisu[301].bAuftragAktiv, '', 'Ein-/Ausschleusen aktiv');
VISU_UEBERSICHT.st301.dwInfo3Farbe := VISU_UEBERSICHT.cFARBE_BLAU;

IF VisuUeb_Station(stBP := StationBasisParameter.starrFaecherwagenBasisParameter[302], stKarte := VISU_UEBERSICHT.st302, sTitel := '302  Fächerwagen', bBlink := bBlink, bReferenzRelevant := FALSE,
                    bGlasZusatz := VISU_VARS.astgFaecherwagenstatusVisu[302].bStatusStationInBeladePosition) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
VISU_UEBERSICHT.st302.sInfo1 := SEL(VISU_VARS.astgFaecherwagenstatusVisu[302].bStatusStationInBeladePosition, 'Wagen nicht in Beladeposition', 'Wagen in Beladeposition');
VISU_UEBERSICHT.st302.dwInfo1Farbe := SEL(VISU_VARS.astgFaecherwagenstatusVisu[302].bStatusStationInBeladePosition, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_GRUEN);
VISU_UEBERSICHT.st302.sInfo2 := SEL(VISU_VARS.astgFaecherwagenstatusVisu[302].bBoxInHomePosition, 'Box nicht in Home', 'Box in Home');
VISU_UEBERSICHT.st302.sInfo3 := SEL(VISU_VARS.astgFaecherwagenstatusVisu[302].bAuftragAktiv, '', 'Ein-/Ausschleusen aktiv');
VISU_UEBERSICHT.st302.dwInfo3Farbe := VISU_UEBERSICHT.cFARBE_BLAU;

// [401] Auslauf Fremdanlage
IF VisuUeb_Station(stBP := StationBasisParameter.starrFremdanlageAuslaufStationBasisParameter[401], stKarte := VISU_UEBERSICHT.st401, sTitel := '401  Auslauf Fremdanlage', bBlink := bBlink, bReferenzRelevant := FALSE, bGlasZusatz := FALSE) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
VISU_UEBERSICHT.st401.sInfo1 := SEL(VISU_VARS.abgVISUFreigabeFremdanlage[401], 'Freigabe Visu: aus', 'Freigabe Visu: EIN');
VISU_UEBERSICHT.st401.sInfo2 := '';
VISU_UEBERSICHT.st401.sInfo3 := '';

// -------------------------------------------------------------------------------------------
// SAMMELMELDUNG
// -------------------------------------------------------------------------------------------
bStoerung := wAnzStoerung > 0;
IF bStoerung THEN
  VISU_UEBERSICHT.sStoerungen       := CONCAT(WORD_TO_STRING(wAnzStoerung), SEL(wAnzStoerung = 1, ' Stationen in Störung', ' Station in Störung'));
  VISU_UEBERSICHT.dwStoerungenFarbe := SEL(bBlink, 16#FFA83232, VISU_UEBERSICHT.cFARBE_ROT);
ELSE
  VISU_UEBERSICHT.sStoerungen       := 'Keine Störung';
  VISU_UEBERSICHT.dwStoerungenFarbe := VISU_UEBERSICHT.cFARBE_GRUEN;
END_IF
END_PROGRAM