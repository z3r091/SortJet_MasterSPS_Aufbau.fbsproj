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
  bSK3, bSK4    : BOOL;
  bStoerung     : BOOL;
  wAnzStoerung  : WORD;
  sKipp         : STRING(40);
  sDreh         : STRING(20);
  sTitel        : STRING(40);
  pKarte        : POINTER TO VisuUeb_Station_ST;
  pAchse        : POINTER TO VisuUeb_Achse_ST;
  pInit         : POINTER TO BOOL;
  pMin, pMax    : POINTER TO REAL;
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
bSK3 := Globale_Bausteine.Sicherheitskreis[3].bpSicherheitskreisGeschlossen;
bSK4 := Globale_Bausteine.Sicherheitskreis[4].bpSicherheitskreisGeschlossen;

bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stAutomatik,      sText := SEL(Global_Vars.M_Automatik_Aktiv[1], 'HAND', 'AUTOMATIK'), bOK := Global_Vars.M_Automatik_Aktiv[1], bWarnung := TRUE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stSK1,            sText := SEL(bSK1, 'SK 1 offen', 'SK 1 zu'), bOK := bSK1, bWarnung := TRUE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stSK2,            sText := SEL(bSK2, 'SK 2 offen', 'SK 2 zu'), bOK := bSK2, bWarnung := TRUE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stSK3,            sText := SEL(bSK3, 'SK 3 offen', 'SK 3 zu'), bOK := bSK3, bWarnung := TRUE, bNeutral := FALSE);
bDummy := VisuUeb_Lampe(stLampe := VISU_UEBERSICHT.stSK4,            sText := SEL(bSK4, 'SK 4 offen', 'SK 4 zu'), bOK := bSK4, bWarnung := TRUE, bNeutral := FALSE);
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
IF VisuUeb_Station(stBP := StationBasisParameter.starrFremdanlageEinlaufStationBasisParameter[501], stKarte := VISU_UEBERSICHT.st501, sTitel := '501  Einlauf VSG', bBlink := bBlink, bReferenzRelevant := FALSE, bGlasZusatz := FALSE) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
VISU_UEBERSICHT.st501.sInfo1 := SEL(VISU_VARS.abgVISUFreigabeFremdanlage[501], 'Freigabe Visu: aus', 'Freigabe Visu: EIN');
VISU_UEBERSICHT.st501.sInfo2 := '';
VISU_UEBERSICHT.st501.sInfo3 := '';

// [201] - [208] Stationen der Zufuehrung: Karte, Glas und Sensoren
FOR wIdx := 201 TO 208 DO
  CASE wIdx OF
    201: pKarte := ADR(VISU_UEBERSICHT.st201); sTitel := '201  Anlegetisch';
    202: pKarte := ADR(VISU_UEBERSICHT.st202); sTitel := '202  Förderer';
    203: pKarte := ADR(VISU_UEBERSICHT.st203); sTitel := '203  Förderer';
    204: pKarte := ADR(VISU_UEBERSICHT.st204); sTitel := '204  Eckübergabe';
    205: pKarte := ADR(VISU_UEBERSICHT.st205); sTitel := '205  Anlegetisch';
    206: pKarte := ADR(VISU_UEBERSICHT.st206); sTitel := '206  Kipptisch';
    207: pKarte := ADR(VISU_UEBERSICHT.st207); sTitel := '207  Drehstation';
    208: pKarte := ADR(VISU_UEBERSICHT.st208); sTitel := '208  Anlegewand';
  END_CASE
  IF VisuUeb_Station(stBP := StationBasisParameter.starrStationBasisParameter[wIdx], stKarte := pKarte^, sTitel := sTitel, bBlink := bBlink, bReferenzRelevant := TRUE,
                      bGlasZusatz := abgStationsstatusVisu[wIdx].bSensorEinlauf[1] OR abgStationsstatusVisu[wIdx].bSensorAuslauf[1]) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
  pKarte^.dwSensorEinlauf      := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorEinlauf[1]);
  pKarte^.dwSensorEinlaufVorab := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorEinlaufVorab[1]);
  pKarte^.dwSensorAuslaufVorab := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorAuslaufVorab[1]);
  pKarte^.dwSensorAuslauf      := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorAuslauf[1]);
  pKarte^.sInfo1 := '';  pKarte^.dwInfo1Farbe := VISU_UEBERSICHT.cFARBE_TEXT;
  pKarte^.sInfo2 := '';  pKarte^.dwInfo2Farbe := VISU_UEBERSICHT.cFARBE_TEXT;
  pKarte^.sInfo3 := '';  pKarte^.dwInfo3Farbe := VISU_UEBERSICHT.cFARBE_TEXT;

  // Anlegetisch: Messachse, Anschlag, Hubrahmen, Ampel
  IF wIdx = 201 OR wIdx = 205 THEN
    pKarte^.sInfo1 := VisuUeb_MmText(sPrefix := 'Messachse ', rWert := abgStationsstatusVisu[wIdx].rMessachseIstPos);
    pKarte^.dwInfo1Farbe := SEL(abgStationsstatusVisu[wIdx].bMessachseFehler, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);
    pKarte^.sInfo2 := CONCAT(CONCAT('Anschlag ', SEL(abgStationsstatusVisu[wIdx].bAnschlagSensorAusgefahren, SEL(abgStationsstatusVisu[wIdx].bAnschlagSensorEingefahren, '?', 'unten'), 'oben')),
                             CONCAT(' | Hubrahmen ', SEL(abgStationsstatusVisu[wIdx].bHubpaletteSensorAusgefahren, SEL(abgStationsstatusVisu[wIdx].bHubpaletteSensorEingefahren, '?', 'unten'), 'oben')));
    pKarte^.dwInfo2Farbe := SEL(abgStationsstatusVisu[wIdx].bAnschlagFehler OR abgStationsstatusVisu[wIdx].bHubpaletteFehler, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);
    pKarte^.sInfo3 := CONCAT('Ampel ', SEL(abgStationsstatusVisu[wIdx].bAmpelRot, SEL(abgStationsstatusVisu[wIdx].bAmpelGruen, 'aus', 'grün'), 'rot'));
  END_IF
END_FOR

// [206] Kipptisch
CASE abgStationsstatusVisu[206].epKippStatus OF
  Kippen_EN.eKippen_Position_0Grad:    sKipp := '0°';
  Kippen_EN.eKippen_Position_84Grad:   sKipp := '84°';
  Kippen_EN.eKippen_Position_88_5Grad: sKipp := '88,5°';
  Kippen_EN.eKippen_Position_90Grad:   sKipp := '90°';
  Kippen_EN.eKippen_Position_96Grad:   sKipp := '96°';
  Kippen_EN.eKippen_Fehler:            sKipp := 'FEHLER';
  ELSE                                   sKipp := 'Zwischenpos.';
END_CASE
VISU_UEBERSICHT.st206.sInfo1 := CONCAT(CONCAT('Kippen ', sKipp), VisuUeb_MmText(sPrefix := '  (', rWert := abgStationsstatusVisu[206].rKippenIstPos, sEinheit := ')'));
VISU_UEBERSICHT.st206.dwInfo1Farbe := SEL(abgStationsstatusVisu[206].bKippenFehler OR NOT abgStationsstatusVisu[206].bKippenAntriebReferenziert, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);
VISU_UEBERSICHT.st206.sInfo2 := SEL(abgStationsstatusVisu[206].bKippenMinEndschalter OR abgStationsstatusVisu[206].bKippenMaxEndschalter, 'Endschalter frei', 'ENDSCHALTER BELEGT');
VISU_UEBERSICHT.st206.dwInfo2Farbe := SEL(abgStationsstatusVisu[206].bKippenMinEndschalter OR abgStationsstatusVisu[206].bKippenMaxEndschalter, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);

// [207] Drehstation
CASE abgStationsstatusVisu[207].epDrehIstPosition OF
  Drehen_EN.eDrehPosition0Grad:   sDreh := '0°';
  Drehen_EN.eDrehPosition90Grad:  sDreh := '90°';
  Drehen_EN.eDrehPosition180Grad: sDreh := '180°';
  Drehen_EN.eDrehPosition270Grad: sDreh := '270°';
  ELSE                              sDreh := 'Zwischenpos.';
END_CASE
VISU_UEBERSICHT.st207.sInfo1 := CONCAT(CONCAT('Drehen ', sDreh), VisuUeb_MmText(sPrefix := '  (', rWert := abgStationsstatusVisu[207].rDrehenIstPos, sEinheit := ')'));
VISU_UEBERSICHT.st207.dwInfo1Farbe := SEL(abgStationsstatusVisu[207].bDrehenFehler OR NOT abgStationsstatusVisu[207].bDrehenAntriebReferenziert, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);
VISU_UEBERSICHT.st207.sInfo2 := CONCAT('Arretierung ', SEL(abgStationsstatusVisu[207].bDrehenArretierungAusgefahren, SEL(abgStationsstatusVisu[207].bDrehenArretierungEingefahren, '?', 'eingefahren'), 'ausgefahren'));
VISU_UEBERSICHT.st207.sInfo3 := SEL(EV_ToPLC_b207_geschlossen, 'Durchfassperre 208 OFFEN', 'Durchfassperre 208 zu');
VISU_UEBERSICHT.st207.dwInfo3Farbe := SEL(EV_ToPLC_b207_geschlossen, VISU_UEBERSICHT.cFARBE_ROT, VISU_UEBERSICHT.cFARBE_TEXT);

// [208] Anlegewand
VISU_UEBERSICHT.st208.sInfo1 := VisuUeb_MmText(sPrefix := 'Messachse ', rWert := abgStationsstatusVisu[208].rMessachseIstPos);
VISU_UEBERSICHT.st208.dwInfo1Farbe := SEL(abgStationsstatusVisu[208].bMessachseFehler, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);
VISU_UEBERSICHT.st208.sInfo2 := CONCAT('Ampel ', SEL(abgStationsstatusVisu[208].bAmpelRot, SEL(abgStationsstatusVisu[208].bAmpelGruen, 'aus', 'grün'), 'rot'));

// [101] / [102] Shuttle
FOR wIdx := 101 TO 102 DO
  IF wIdx = 101 THEN
    pKarte := ADR(VISU_UEBERSICHT.st101); pAchse := ADR(VISU_UEBERSICHT.stAchse101); sTitel := '101  Shuttle';
    pInit := ADR(VISU_UEBERSICHT.bSkalierung101Init); pMin := ADR(VISU_UEBERSICHT.rMin101); pMax := ADR(VISU_UEBERSICHT.rMax101);
  ELSE
    pKarte := ADR(VISU_UEBERSICHT.st102); pAchse := ADR(VISU_UEBERSICHT.stAchse102); sTitel := '102  Shuttle';
    pInit := ADR(VISU_UEBERSICHT.bSkalierung102Init); pMin := ADR(VISU_UEBERSICHT.rMin102); pMax := ADR(VISU_UEBERSICHT.rMax102);
  END_IF
  IF VisuUeb_Station(stBP := StationBasisParameter.starrShuttleBasisParameter[wIdx], stKarte := pKarte^, sTitel := sTitel, bBlink := bBlink, bReferenzRelevant := TRUE,
                      bGlasZusatz := abgStationsstatusVisu[wIdx].bSensorEinlauf[1] OR abgStationsstatusVisu[wIdx].bSensorAuslauf[1] OR abgStationsstatusVisu[wIdx].bSensorAuslaufStopp[1]) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
  pKarte^.dwSensorEinlauf      := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorEinlauf[1]);
  pKarte^.dwSensorEinlaufVorab := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorEinlaufVorab[1]);
  pKarte^.dwSensorAuslaufVorab := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorAuslaufVorab[1]);
  pKarte^.dwSensorAuslauf      := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorAuslauf[1]);
  pKarte^.dwSensorAuslaufStopp := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorAuslaufStopp[1]);
  CASE abgStationsstatusVisu[wIdx].epKippStatus OF
    Kippen_EN.eKippen_Position_0Grad:    sKipp := 'Kippen 0°';
    Kippen_EN.eKippen_Position_84Grad:   sKipp := 'Kippen 84°';
    Kippen_EN.eKippen_Position_88_5Grad: sKipp := 'Kippen 88,5°';
    Kippen_EN.eKippen_Position_90Grad:   sKipp := 'Kippen 90°';
    Kippen_EN.eKippen_Position_96Grad:   sKipp := 'Kippen 96°';
    Kippen_EN.eKippen_Fehler:            sKipp := 'Kippen FEHLER';
    ELSE                                   sKipp := 'Kippen Zwischenpos.';
  END_CASE
  pKarte^.sInfo1 := CONCAT(sKipp, SEL(abgStationsstatusVisu[wIdx].bGeblaeseLaeuft[1], ' | Gebläse aus', ' | Gebläse EIN'));
  pKarte^.dwInfo1Farbe := SEL(abgStationsstatusVisu[wIdx].bKippenFehler, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_ROT);

  // Fahrwegsgrenzen aus dem Antrieb (Software-Endlagen)
  IF __ISVALIDREF(Globale_Bausteine.aShuttle[wIdx].Querfahrt.Antrieb) THEN
    pMin^  := Globale_Bausteine.aShuttle[wIdx].Querfahrt.Antrieb.rpMinPosition;
    pMax^  := Globale_Bausteine.aShuttle[wIdx].Querfahrt.Antrieb.rpMaxPosition;
    pInit^ := TRUE;
  END_IF
  VisuUeb_Achse(stAchse := pAchse^, bInit := pInit^, rMin := pMin^, rMax := pMax^,
                 rIst            := abgStationsstatusVisu[wIdx].rQuerfahrtIstPos,
                 rZiel           := Globale_Bausteine.aShuttle[wIdx].Querfahrt.rpDestinationPosition,
                 rSpeed          := Globale_Bausteine.aShuttle[wIdx].Querfahrt.rpAktSpeed,
                 bPositionierung := Globale_Bausteine.aShuttle[wIdx].Querfahrt.bpPositionierungAktiv,
                 bReferenziert   := abgStationsstatusVisu[wIdx].bQuerfahrtAntriebReferenziert,
                 bFehler         := abgStationsstatusVisu[wIdx].bQuerfahrtFehler,
                 bMinEnd         := abgStationsstatusVisu[wIdx].bQuerfahrtMinEndschalter,
                 bMaxEnd         := abgStationsstatusVisu[wIdx].bQuerfahrtMaxEndschalter,
                 bNeuLernen      := bLernen,
                 bBlink          := bBlink);
  pKarte^.sInfo2 := pAchse^.sIstPos;
  pKarte^.sInfo3 := pAchse^.sZielPos;
END_FOR

// [151] / [152] Transfershuttle
FOR wIdx := 151 TO 152 DO
  IF wIdx = 151 THEN
    pKarte := ADR(VISU_UEBERSICHT.st151); pAchse := ADR(VISU_UEBERSICHT.stAchse151); sTitel := '151  Transfershuttle';
    pInit := ADR(VISU_UEBERSICHT.bSkalierung151Init); pMin := ADR(VISU_UEBERSICHT.rMin151); pMax := ADR(VISU_UEBERSICHT.rMax151);
  ELSE
    pKarte := ADR(VISU_UEBERSICHT.st152); pAchse := ADR(VISU_UEBERSICHT.stAchse152); sTitel := '152  Transfershuttle';
    pInit := ADR(VISU_UEBERSICHT.bSkalierung152Init); pMin := ADR(VISU_UEBERSICHT.rMin152); pMax := ADR(VISU_UEBERSICHT.rMax152);
  END_IF
  IF VisuUeb_Station(stBP := StationBasisParameter.starrTransfershuttleBasisParameter[wIdx], stKarte := pKarte^, sTitel := sTitel, bBlink := bBlink, bReferenzRelevant := TRUE,
                      bGlasZusatz := abgStationsstatusVisu[wIdx].bSensorEinlauf[1] OR abgStationsstatusVisu[wIdx].bSensorAuslauf[1]) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
  pKarte^.dwSensorEinlauf      := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorEinlauf[1]);
  pKarte^.dwSensorEinlaufVorab := VisuUeb_Sensor(FALSE, FALSE);
  pKarte^.dwSensorAuslaufVorab := VisuUeb_Sensor(FALSE, FALSE);
  pKarte^.dwSensorAuslauf      := VisuUeb_Sensor(abgStationsstatusVisu[wIdx].bSensorAuslauf[1]);
  pKarte^.sInfo1 := SEL(Global_Vars.abgVerfahrfreigabeShuttle[wIdx], 'Verfahrfreigabe: NEIN', 'Verfahrfreigabe: ja');
  pKarte^.dwInfo1Farbe := SEL(Global_Vars.abgVerfahrfreigabeShuttle[wIdx], VISU_UEBERSICHT.cFARBE_ORANGE, VISU_UEBERSICHT.cFARBE_TEXT);

  // Fahrwegsgrenzen aus dem Antrieb (Software-Endlagen)
  IF __ISVALIDREF(Globale_Bausteine.aTransfershuttles[wIdx].Querfahrt.Antrieb) THEN
    pMin^  := Globale_Bausteine.aTransfershuttles[wIdx].Querfahrt.Antrieb.rpMinPosition;
    pMax^  := Globale_Bausteine.aTransfershuttles[wIdx].Querfahrt.Antrieb.rpMaxPosition;
    pInit^ := TRUE;
  END_IF
  VisuUeb_Achse(stAchse := pAchse^, bInit := pInit^, rMin := pMin^, rMax := pMax^,
                 rIst            := abgStationsstatusVisu[wIdx].rQuerfahrtIstPos,
                 rZiel           := Globale_Bausteine.aTransfershuttles[wIdx].Querfahrt.rpDestinationPosition,
                 rSpeed          := Globale_Bausteine.aTransfershuttles[wIdx].Querfahrt.rpAktSpeed,
                 bPositionierung := Globale_Bausteine.aTransfershuttles[wIdx].Querfahrt.bpPositionierungAktiv,
                 bReferenziert   := abgStationsstatusVisu[wIdx].bQuerfahrtAntriebReferenziert,
                 bFehler         := abgStationsstatusVisu[wIdx].bQuerfahrtFehler,
                 bMinEnd         := abgStationsstatusVisu[wIdx].bQuerfahrtMinEndschalter,
                 bMaxEnd         := abgStationsstatusVisu[wIdx].bQuerfahrtMaxEndschalter,
                 bNeuLernen      := bLernen,
                 bBlink          := bBlink);
  pKarte^.sInfo2 := pAchse^.sIstPos;
  pKarte^.sInfo3 := CONCAT(CONCAT(pAchse^.sZielPos, '   '), pAchse^.sSpeed);
END_FOR

// [301] - [305] Faecherwagen
FOR wIdx := 301 TO 305 DO
  CASE wIdx OF
    301: pKarte := ADR(VISU_UEBERSICHT.st301);
    302: pKarte := ADR(VISU_UEBERSICHT.st302);
    303: pKarte := ADR(VISU_UEBERSICHT.st303);
    304: pKarte := ADR(VISU_UEBERSICHT.st304);
    305: pKarte := ADR(VISU_UEBERSICHT.st305);
  END_CASE
  sTitel := CONCAT(WORD_TO_STRING(wIdx), '  Fächerwagen');
  IF VisuUeb_Station(stBP := StationBasisParameter.starrFaecherwagenBasisParameter[wIdx], stKarte := pKarte^, sTitel := sTitel, bBlink := bBlink, bReferenzRelevant := FALSE,
                      bGlasZusatz := VISU_VARS.astgFaecherwagenstatusVisu[wIdx].bStatusStationInBeladePosition) THEN wAnzStoerung := wAnzStoerung + 1; END_IF
  pKarte^.sInfo1 := CONCAT(SEL(VISU_VARS.astgFaecherwagenstatusVisu[wIdx].bWagenErkannt, 'Kein Fächerwagen', 'Fächerwagen vorhanden'),
                           SEL(VISU_VARS.astgFaecherwagenstatusVisu[wIdx].bRolltorUnten, SEL(VISU_VARS.astgFaecherwagenstatusVisu[wIdx].bRolltorOben, ' | Rolltor ?', ' | Rolltor oben'), ' | Rolltor unten'));
  pKarte^.dwInfo1Farbe := VISU_UEBERSICHT.cFARBE_TEXT;
  IF VISU_VARS.astgFaecherwagenstatusVisu[wIdx].bAuftragAktiv THEN
    pKarte^.sInfo2 := 'Ein-/Ausschleusen aktiv';
    pKarte^.dwInfo2Farbe := VISU_UEBERSICHT.cFARBE_BLAU;
  ELSE
    pKarte^.sInfo2 := SEL(VISU_VARS.astgFaecherwagenstatusVisu[wIdx].bStatusStationInBeladePosition, 'Wagen nicht in Beladeposition', 'Wagen in Beladeposition');
    pKarte^.dwInfo2Farbe := SEL(VISU_VARS.astgFaecherwagenstatusVisu[wIdx].bStatusStationInBeladePosition, VISU_UEBERSICHT.cFARBE_TEXT, VISU_UEBERSICHT.cFARBE_GRUEN);
  END_IF
END_FOR

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