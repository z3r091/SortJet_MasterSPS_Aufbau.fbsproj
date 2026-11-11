(* METADATA
{
	"v3Meta": {
		"objectGuid": "a4fab899-80a6-4d8b-aad2-f00973a33795"
	}
}
*)
PROGRAM VisuHand_PRG
VAR
  b    : BOOL;
  i    : WORD;
  dwG, dwO, dwR, dwGR, dwB : DWORD;
  sKipp : STRING(30);
  dwKipp : DWORD;
  pBP  : POINTER TO StationBasisParameter_ST;
  pH   : POINTER TO VisuHand_Station_ST;

  // Reset
  afbResetSt       : ARRAY[201..208] OF VisuHand_Reset_FB;
  afbResetSh       : ARRAY[101..102] OF VisuHand_Reset_FB;
  afbResetTS       : ARRAY[151..152] OF VisuHand_Reset_FB;
  afbResetFW       : ARRAY[301..305] OF VisuHand_Reset_FB;
  rtlAnlageReset   : R_TRIG;  // Anlagen-Reset auf Flanke
  tofAnlageReset   : TOF;     // Mindestanzeige "Reset aktiv"
  bResetLaeuft     : BOOL;

  // Rolltor-Schalter (Toggle) gegenseitig ausschliessen
  artlRolltorHoch, artlRolltorRunter : ARRAY[301..305] OF R_TRIG;
END_VAR
// *************************************************************************************************
// DATENAUFBEREITUNG FUER DIE VISUS "Handbetrieb" (201 - 208) UND "Handbetrieb_Speicher"
// (Shuttle 101/102, Transfershuttle 151/152, Faecherwagen 301 - 305)
// - Taster schreiben direkt auf die vorhandenen VISU_VARS-Bits
// - hier nur: Sperre je Station + Rueckmeldetexte/-farben
// *************************************************************************************************
dwG  := VISU_UEBERSICHT.cFARBE_GRUEN;
dwO  := VISU_UEBERSICHT.cFARBE_ORANGE;
dwR  := VISU_UEBERSICHT.cFARBE_ROT;
dwGR := VISU_UEBERSICHT.cFARBE_GRAU;
dwB  := VISU_UEBERSICHT.cFARBE_BLAU;

// -------------------------------------------------------------------------------------------
// RESET
// - Anlage: wie "Stopp" vom MMI (alle Automatikkreise stoppen + Reset aller Stationen)
// - Station: BasisStationsParameter.bReset (nur ausserhalb der Automatik)
// -------------------------------------------------------------------------------------------
rtlAnlageReset(CLK := VISU_HAND.bAnlageResetTaster);
IF rtlAnlageReset.Q THEN
  MMI_Vars.tMmi2SpsInfo.wAutomatikStopArea   := Stations_Konfig.cSTOPP_ALLE_AUTOMATIKKREIS;
  MMI_Vars.M_SB0_MMI_SortierungAutomatik_Stop := TRUE;
END_IF

bResetLaeuft := FALSE;
FOR i := 201 TO 208 DO
  CASE i OF
    201: pH := ADR(VISU_HAND.st201);
    202: pH := ADR(VISU_HAND.st202);
    203: pH := ADR(VISU_HAND.st203);
    204: pH := ADR(VISU_HAND.st204);
    205: pH := ADR(VISU_HAND.st205);
    206: pH := ADR(VISU_HAND.st206);
    207: pH := ADR(VISU_HAND.st207);
    208: pH := ADR(VISU_HAND.st208);
  END_CASE
  afbResetSt[i](stBP := StationBasisParameter.starrStationBasisParameter[i], stH := pH^);
  bResetLaeuft := bResetLaeuft OR StationBasisParameter.starrStationBasisParameter[i].bReset;
END_FOR
afbResetSh[101](stBP := StationBasisParameter.starrShuttleBasisParameter[101], stH := VISU_HAND.st101);
afbResetSh[102](stBP := StationBasisParameter.starrShuttleBasisParameter[102], stH := VISU_HAND.st102);
afbResetTS[151](stBP := StationBasisParameter.starrTransfershuttleBasisParameter[151], stH := VISU_HAND.st151);
afbResetTS[152](stBP := StationBasisParameter.starrTransfershuttleBasisParameter[152], stH := VISU_HAND.st152);
FOR i := 101 TO 102 DO
  bResetLaeuft := bResetLaeuft OR StationBasisParameter.starrShuttleBasisParameter[i].bReset;
END_FOR
FOR i := 151 TO 152 DO
  bResetLaeuft := bResetLaeuft OR StationBasisParameter.starrTransfershuttleBasisParameter[i].bReset;
END_FOR
FOR i := 301 TO 305 DO
  afbResetFW[i](stBP := StationBasisParameter.starrFaecherwagenBasisParameter[i], stH := VISU_HAND.astFW[i]);
  bResetLaeuft := bResetLaeuft OR StationBasisParameter.starrFaecherwagenBasisParameter[i].bReset;
END_FOR

// Reset aktiv: min. 1 s nach Druck bzw. solange irgendeine Station ihren Reset noch nicht abgeschlossen hat
tofAnlageReset(IN := rtlAnlageReset.Q, PT := T#1S);
VISU_HAND.bAnlageResetAktiv := tofAnlageReset.Q OR bResetLaeuft;
IF VISU_HAND.bAnlageResetAktiv THEN
  VISU_HAND.sAnlageReset       := 'RESET AKTIV ...';
  VISU_HAND.dwAnlageResetFarbe := dwO;
ELSE
  VISU_HAND.sAnlageReset       := 'ANLAGE RESET';
  VISU_HAND.dwAnlageResetFarbe := dwR;
END_IF

// -------------------------------------------------------------------------------------------
// [201] - [208] STATIONEN: Sperre, Funktionszeilen laut MK-Stationsaufbau, Rueckmeldungen
// -------------------------------------------------------------------------------------------
FOR i := 201 TO 208 DO
  CASE i OF
    201: pH := ADR(VISU_HAND.st201);
    202: pH := ADR(VISU_HAND.st202);
    203: pH := ADR(VISU_HAND.st203);
    204: pH := ADR(VISU_HAND.st204);
    205: pH := ADR(VISU_HAND.st205);
    206: pH := ADR(VISU_HAND.st206);
    207: pH := ADR(VISU_HAND.st207);
    208: pH := ADR(VISU_HAND.st208);
  END_CASE
  pBP := ADR(StationBasisParameter.starrStationBasisParameter[i]);
  b := VisuHand_Sperre(stBP := pBP^, stH := pH^, bFaecherwagen := FALSE);

  // Funktionszeilen
  IF __ISVALIDREF(pBP^.stMKs) THEN
    pH^.abZeileVorhanden[1] := pBP^.stMKs.stStationsAufbau.bGlastransport[cWAND_1];
    CASE i OF
      201, 205:
        pH^.abZeileVorhanden[2] := pBP^.stMKs.stStationsAufbau.bAnschlag;
        pH^.abZeileVorhanden[3] := pBP^.stMKs.stStationsAufbau.bHubrahmen;
        pH^.abZeileVorhanden[4] := pBP^.stMKs.stStationsAufbau.bMessachse;
        pH^.abZeileVorhanden[5] := pBP^.stMKs.stStationsAufbau.bGeblase[cWAND_1];
        pH^.abZeileVorhanden[6] := pBP^.stMKs.stStationsAufbau.bGeblase[cWAND_1];
      204:
        pH^.abZeileVorhanden[2] := pBP^.stMKs.stStationsAufbau.bGlastransport[cWAND_1];
        pH^.abZeileVorhanden[3] := pBP^.stMKs.stStationsAufbau.bHubrahmen;
      206:
        pH^.abZeileVorhanden[2] := pBP^.stMKs.stStationsAufbau.bKippen[cWAND_1];
      207:
        pH^.abZeileVorhanden[2] := pBP^.stMKs.stStationsAufbau.bDrehen;
        pH^.abZeileVorhanden[3] := pBP^.stMKs.stStationsAufbau.bDrehen;
        pH^.abZeileVorhanden[4] := pBP^.stMKs.stStationsAufbau.bDrehen;
        pH^.abZeileVorhanden[5] := pBP^.stMKs.stStationsAufbau.bKippen[cWAND_1];
      208:
        pH^.abZeileVorhanden[2] := pBP^.stMKs.stStationsAufbau.bMessachse;
        pH^.abZeileVorhanden[3] := pBP^.stMKs.stStationsAufbau.bDurchlaufSperreZumNachfolger;
    END_CASE
  END_IF

  // 1 Riemen: Glas auf der Station
  b := VisuHand_Set(stH := pH^, wZeile := 1,
                     sText   := SEL(abgStationsstatusVisu[i].bSensorEinlauf[1] OR abgStationsstatusVisu[i].bSensorAuslauf[1], 'frei', 'Glas'),
                     dwFarbe := SEL(abgStationsstatusVisu[i].bSensorEinlauf[1] OR abgStationsstatusVisu[i].bSensorAuslauf[1], dwGR, dwB));

  CASE i OF
    201, 205:
      // 1 Riemen (laeuft nur bei ausgefahrenem Hubrahmen)
      IF NOT abgStationsstatusVisu[i].bHubpaletteSensorAusgefahren THEN
        b := VisuHand_Set(stH := pH^, wZeile := 1, sText := 'Hubr. unten', dwFarbe := dwO);
      END_IF
      // 2 Anschlag
      IF abgStationsstatusVisu[i].bAnschlagFehler THEN                   b := VisuHand_Set(stH := pH^, wZeile := 2, sText := 'Fehler', dwFarbe := dwR);
      ELSIF abgStationsstatusVisu[i].bAnschlagSensorAusgefahren THEN     b := VisuHand_Set(stH := pH^, wZeile := 2, sText := 'oben',   dwFarbe := dwG);
      ELSIF abgStationsstatusVisu[i].bAnschlagSensorEingefahren THEN     b := VisuHand_Set(stH := pH^, wZeile := 2, sText := 'unten',  dwFarbe := dwG);
      ELSE                                                               b := VisuHand_Set(stH := pH^, wZeile := 2, sText := '?',      dwFarbe := dwO);
      END_IF
      // 3 Hubrahmen
      IF abgStationsstatusVisu[i].bHubpaletteFehler THEN                 b := VisuHand_Set(stH := pH^, wZeile := 3, sText := 'Fehler', dwFarbe := dwR);
      ELSIF abgStationsstatusVisu[i].bHubpaletteSensorAusgefahren THEN   b := VisuHand_Set(stH := pH^, wZeile := 3, sText := 'oben',   dwFarbe := dwG);
      ELSIF abgStationsstatusVisu[i].bHubpaletteSensorEingefahren THEN   b := VisuHand_Set(stH := pH^, wZeile := 3, sText := 'unten',  dwFarbe := dwG);
      ELSE                                                               b := VisuHand_Set(stH := pH^, wZeile := 3, sText := '?',      dwFarbe := dwO);
      END_IF
      // 4 Messachse
      b := VisuHand_Set(stH := pH^, wZeile := 4,
                         sText   := VisuUeb_MmText(sPrefix := '', rWert := abgStationsstatusVisu[i].rMessachseIstPos, sEinheit := ' mm'),
                         dwFarbe := SEL(abgStationsstatusVisu[i].bMessachseFehler, SEL(pBP^.bIstReferenziert, dwO, dwG), dwR));
      // 5 Geblaese
      b := VisuHand_Set(stH := pH^, wZeile := 5, sText := SEL(abgStationsstatusVisu[i].bGeblaeseLaeuft[1], 'aus', 'EIN'), dwFarbe := SEL(abgStationsstatusVisu[i].bGeblaeseLaeuft[1], dwGR, dwB));
      // 6 Drosselklappe (Ausgang, keine Endlagenabfrage)
      b := VisuHand_Set(stH := pH^, wZeile := 6, sText := SEL(abgStationsstatusVisu[i].bDrosselklappeOffen[1], 'zu', 'auf'), dwFarbe := SEL(abgStationsstatusVisu[i].bDrosselklappeOffen[1], dwGR, dwB));

    204:
      // 2 Riemen Y: Sensoren nur fuer die X-Achse in der Visu-Schnittstelle
      b := VisuHand_Set(stH := pH^, wZeile := 2, sText := '', dwFarbe := dwGR);
      // 3 Hubrahmen (oben = Riemen X arbeitet)
      IF abgStationsstatusVisu[i].bHubpaletteFehler THEN                 b := VisuHand_Set(stH := pH^, wZeile := 3, sText := 'Fehler', dwFarbe := dwR);
      ELSIF abgStationsstatusVisu[i].bHubpaletteSensorAusgefahren THEN   b := VisuHand_Set(stH := pH^, wZeile := 3, sText := 'oben',   dwFarbe := dwG);
      ELSIF abgStationsstatusVisu[i].bHubpaletteSensorEingefahren THEN   b := VisuHand_Set(stH := pH^, wZeile := 3, sText := 'unten',  dwFarbe := dwG);
      ELSE                                                               b := VisuHand_Set(stH := pH^, wZeile := 3, sText := '?',      dwFarbe := dwO);
      END_IF

    206:
      // 2 Kippen
      CASE abgStationsstatusVisu[i].epKippStatus OF
        Kippen_EN.eKippen_Position_0Grad:    sKipp := 'waagerecht'; dwKipp := dwG;
        Kippen_EN.eKippen_Position_90Grad:   sKipp := 'senkrecht';  dwKipp := dwG;
        Kippen_EN.eKippen_Position_84Grad:   sKipp := '84°';        dwKipp := dwG;
        Kippen_EN.eKippen_Position_88_5Grad: sKipp := '88,5°';      dwKipp := dwG;
        Kippen_EN.eKippen_Position_96Grad:   sKipp := '96°';        dwKipp := dwG;
        Kippen_EN.eKippen_Fehler:            sKipp := 'Fehler';     dwKipp := dwR;
        ELSE                                   sKipp := 'Zwischen';   dwKipp := dwO;
      END_CASE
      IF abgStationsstatusVisu[i].bKippenFehler THEN dwKipp := dwR; ELSIF NOT abgStationsstatusVisu[i].bKippenAntriebReferenziert THEN dwKipp := dwO; END_IF
      b := VisuHand_Set(stH := pH^, wZeile := 2, sText := sKipp, dwFarbe := dwKipp);

    207:
      // 2 Drehen: Position
      CASE abgStationsstatusVisu[i].epDrehIstPosition OF
        Drehen_EN.eDrehPosition0Grad:   sKipp := '0°';   dwKipp := dwG;
        Drehen_EN.eDrehPosition90Grad:  sKipp := '90°';  dwKipp := dwG;
        Drehen_EN.eDrehPosition180Grad: sKipp := '180°'; dwKipp := dwG;
        Drehen_EN.eDrehPosition270Grad: sKipp := '270°'; dwKipp := dwG;
        ELSE                              sKipp := 'Zwischen'; dwKipp := dwO;
      END_CASE
      IF abgStationsstatusVisu[i].bDrehenFehler THEN sKipp := 'Fehler'; dwKipp := dwR; END_IF
      b := VisuHand_Set(stH := pH^, wZeile := 2, sText := sKipp, dwFarbe := dwKipp);
      // 3 Drehen: Referenz
      b := VisuHand_Set(stH := pH^, wZeile := 3,
                         sText   := SEL(abgStationsstatusVisu[i].bDrehenAntriebReferenziert, 'nicht ref.', 'referenz.'),
                         dwFarbe := SEL(abgStationsstatusVisu[i].bDrehenAntriebReferenziert, dwO, dwG));
      // 4 Arretierung
      IF abgStationsstatusVisu[i].bDrehenArretierungAusgefahren THEN
        b := VisuHand_Set(stH := pH^, wZeile := 4, sText := 'ausgefahren', dwFarbe := dwG);
      ELSIF abgStationsstatusVisu[i].bDrehenArretierungEingefahren THEN
        b := VisuHand_Set(stH := pH^, wZeile := 4, sText := 'eingefahren', dwFarbe := dwG);
      ELSE
        b := VisuHand_Set(stH := pH^, wZeile := 4, sText := '?', dwFarbe := dwO);
      END_IF
      // 5 Kippen
      CASE abgStationsstatusVisu[i].epKippStatus OF
        Kippen_EN.eKippen_Position_84Grad: sKipp := '84°';    dwKipp := dwG;
        Kippen_EN.eKippen_Position_90Grad: sKipp := '90°';    dwKipp := dwG;
        Kippen_EN.eKippen_Fehler:          sKipp := 'Fehler'; dwKipp := dwR;
        ELSE                                 sKipp := 'Zwischen'; dwKipp := dwO;
      END_CASE
      IF abgStationsstatusVisu[i].bKippenFehler THEN sKipp := 'Fehler'; dwKipp := dwR; END_IF
      b := VisuHand_Set(stH := pH^, wZeile := 5, sText := sKipp, dwFarbe := dwKipp);

    208:
      // 2 Messachse
      b := VisuHand_Set(stH := pH^, wZeile := 2,
                         sText   := VisuUeb_MmText(sPrefix := '', rWert := abgStationsstatusVisu[i].rMessachseIstPos, sEinheit := ' mm'),
                         dwFarbe := SEL(abgStationsstatusVisu[i].bMessachseFehler, SEL(pBP^.bIstReferenziert, dwO, dwG), dwR));
      // 3 Bewegliche Abschrankung
      IF abgStationsstatusVisu[i].bAbschrankungFehler THEN             b := VisuHand_Set(stH := pH^, wZeile := 3, sText := 'Fehler', dwFarbe := dwR);
      ELSIF abgStationsstatusVisu[i].bAbschrankungGeschlossen THEN     b := VisuHand_Set(stH := pH^, wZeile := 3, sText := 'zu',     dwFarbe := dwG);
      ELSIF abgStationsstatusVisu[i].bAbschrankungOffen THEN           b := VisuHand_Set(stH := pH^, wZeile := 3, sText := 'offen',  dwFarbe := dwO);
      ELSE                                                             b := VisuHand_Set(stH := pH^, wZeile := 3, sText := '?',      dwFarbe := dwO);
      END_IF
  END_CASE
END_FOR

// Schalter (Toggle) - ausserhalb des Handbetriebs immer zuruecksetzen
IF VISU_HAND.st201.bGesperrt THEN
  VISU_VARS.bgVISUGeblaese[201, cWAND_1] := FALSE;
  VISU_VARS.bgVISUDrosselklappeAUF[201]  := FALSE;
END_IF
IF VISU_HAND.st205.bGesperrt THEN
  VISU_VARS.bgVISUGeblaese[205, cWAND_1] := FALSE;
  VISU_VARS.bgVISUDrosselklappeAUF[205]  := FALSE;
END_IF

// -------------------------------------------------------------------------------------------
// [101] / [102] SHUTTLE
// -------------------------------------------------------------------------------------------
FOR i := 101 TO 102 DO
  IF i = 101 THEN pH := ADR(VISU_HAND.st101); ELSE pH := ADR(VISU_HAND.st102); END_IF
  pBP := ADR(StationBasisParameter.starrShuttleBasisParameter[i]);
  b := VisuHand_Sperre(stBP := pBP^, stH := pH^, bFaecherwagen := FALSE);
  IF __ISVALIDREF(pBP^.stMKs) THEN
    pH^.abZeileVorhanden[1] := pBP^.stMKs.stStationsAufbau.bGlastransport[cWAND_1];
    pH^.abZeileVorhanden[2] := pBP^.stMKs.stStationsAufbau.bGeblase[cWAND_1];
    pH^.abZeileVorhanden[3] := pBP^.stMKs.stStationsAufbau.bTransportVerstellung[cWAND_1];
    pH^.abZeileVorhanden[4] := pBP^.stMKs.stStationsAufbau.bKippen[cWAND_1];
    pH^.abZeileVorhanden[5] := pBP^.stMKs.stStationsAufbau.bQuerfahrt;
    pH^.abZeileVorhanden[6] := pBP^.stMKs.stStationsAufbau.bDLSSchmiersystem;
  END_IF
  IF pH^.bGesperrt THEN
    VISU_VARS.bgVISUGeblaese[i, cWAND_1] := FALSE;
  END_IF
  // 1 Riemen
  b := VisuHand_Set(stH := pH^, wZeile := 1,
                     sText   := SEL(abgStationsstatusVisu[i].bSensorEinlauf[1] OR abgStationsstatusVisu[i].bSensorAuslauf[1] OR abgStationsstatusVisu[i].bSensorAuslaufStopp[1], 'frei', 'Glas'),
                     dwFarbe := SEL(abgStationsstatusVisu[i].bSensorEinlauf[1] OR abgStationsstatusVisu[i].bSensorAuslauf[1] OR abgStationsstatusVisu[i].bSensorAuslaufStopp[1], dwGR, dwB));
  // 2 Geblaese
  b := VisuHand_Set(stH := pH^, wZeile := 2, sText := SEL(abgStationsstatusVisu[i].bGeblaeseLaeuft[1], 'aus', 'EIN'), dwFarbe := SEL(abgStationsstatusVisu[i].bGeblaeseLaeuft[1], dwGR, dwB));
  // 3 Oeffnung (Transportverstellung)
  CASE abgStationsstatusVisu[i].epWandverstellungStatus[1] OF
    PneumatikZylinderStatus_EN.eZylinderStellung16mm: b := VisuHand_Set(stH := pH^, wZeile := 3, sText := '16 mm', dwFarbe := dwG);
    PneumatikZylinderStatus_EN.eZylinderStellung23mm: b := VisuHand_Set(stH := pH^, wZeile := 3, sText := '23 mm', dwFarbe := dwG);
    PneumatikZylinderStatus_EN.eZylinderStellung29mm: b := VisuHand_Set(stH := pH^, wZeile := 3, sText := '29 mm', dwFarbe := dwG);
    ELSE                                                b := VisuHand_Set(stH := pH^, wZeile := 3, sText := '?',     dwFarbe := dwO);
  END_CASE
  // 4 Kippen
  CASE abgStationsstatusVisu[i].epKippStatus OF
    Kippen_EN.eKippen_Position_0Grad:    sKipp := '0°';     dwKipp := dwG;
    Kippen_EN.eKippen_Position_84Grad:   sKipp := '84°';    dwKipp := dwG;
    Kippen_EN.eKippen_Position_88_5Grad: sKipp := '88,5°';  dwKipp := dwG;
    Kippen_EN.eKippen_Position_90Grad:   sKipp := '90°';    dwKipp := dwG;
    Kippen_EN.eKippen_Position_96Grad:   sKipp := '96°';    dwKipp := dwG;
    Kippen_EN.eKippen_Fehler:            sKipp := 'Fehler'; dwKipp := dwR;
    ELSE                                   sKipp := 'Zwischen'; dwKipp := dwO;
  END_CASE
  IF abgStationsstatusVisu[i].bKippenFehler THEN dwKipp := dwR; END_IF
  b := VisuHand_Set(stH := pH^, wZeile := 4, sText := sKipp, dwFarbe := dwKipp);
  // 5 Querfahrt
  b := VisuHand_Set(stH := pH^, wZeile := 5,
                     sText   := VisuUeb_MmText(sPrefix := '', rWert := abgStationsstatusVisu[i].rQuerfahrtIstPos, sEinheit := ' mm'),
                     dwFarbe := SEL(abgStationsstatusVisu[i].bQuerfahrtFehler, SEL(abgStationsstatusVisu[i].bQuerfahrtAntriebReferenziert, dwO, dwG), dwR));
  // 6 Schmierung
  b := VisuHand_Set(stH := pH^, wZeile := 6, sText := '', dwFarbe := dwGR);
END_FOR

// -------------------------------------------------------------------------------------------
// [151] / [152] TRANSFERSHUTTLE
// -------------------------------------------------------------------------------------------
FOR i := 151 TO 152 DO
  IF i = 151 THEN pH := ADR(VISU_HAND.st151); ELSE pH := ADR(VISU_HAND.st152); END_IF
  pBP := ADR(StationBasisParameter.starrTransfershuttleBasisParameter[i]);
  b := VisuHand_Sperre(stBP := pBP^, stH := pH^, bFaecherwagen := FALSE);
  IF __ISVALIDREF(pBP^.stMKs) THEN
    pH^.abZeileVorhanden[1] := pBP^.stMKs.stStationsAufbau.bGlastransport[cWAND_1];
    pH^.abZeileVorhanden[2] := pBP^.stMKs.stStationsAufbau.bGlastransport[cWAND_1];
    pH^.abZeileVorhanden[3] := pBP^.stMKs.stStationsAufbau.bDruckluft;
    pH^.abZeileVorhanden[4] := pBP^.stMKs.stStationsAufbau.bDruckluft;
    pH^.abZeileVorhanden[5] := pBP^.stMKs.stStationsAufbau.bQuerfahrt;
    pH^.abZeileVorhanden[6] := pBP^.stMKs.stStationsAufbau.bDLSSchmiersystem;
  END_IF
  IF pH^.bGesperrt THEN
    VISU_VARS.bgVisuTFSRiemenAnheben[i]     := FALSE;
    VISU_VARS.bgVisuTFSAbfrageEinlaufAuf[i] := FALSE;
    VISU_VARS.bgVisuTFSAbfrageEinlaufEin[i] := FALSE;
    VISU_VARS.bgVisuTFSAbfrageAuslaufAuf[i] := FALSE;
    VISU_VARS.bgVisuTFSAbfrageAuslaufEin[i] := FALSE;
  END_IF
  // 1 Riemen
  b := VisuHand_Set(stH := pH^, wZeile := 1,
                     sText   := SEL(abgStationsstatusVisu[i].bSensorEinlauf[1] OR abgStationsstatusVisu[i].bSensorAuslauf[1], 'frei', 'Glas'),
                     dwFarbe := SEL(abgStationsstatusVisu[i].bSensorEinlauf[1] OR abgStationsstatusVisu[i].bSensorAuslauf[1], dwGR, dwB));
  // 2 Riemen Hub (Glastransport angehoben / abgesenkt)
  IF Globale_Bausteine.aTransfershuttles[i].in_bSensorShuttleOben AND NOT Globale_Bausteine.aTransfershuttles[i].in_bSensorShuttleUnten THEN
    b := VisuHand_Set(stH := pH^, wZeile := 2, sText := 'angehoben', dwFarbe := dwB);
  ELSIF Globale_Bausteine.aTransfershuttles[i].in_bSensorShuttleUnten AND NOT Globale_Bausteine.aTransfershuttles[i].in_bSensorShuttleOben THEN
    b := VisuHand_Set(stH := pH^, wZeile := 2, sText := 'abgesenkt', dwFarbe := dwG);
  ELSE
    b := VisuHand_Set(stH := pH^, wZeile := 2, sText := '?', dwFarbe := dwO);
  END_IF
  // 3 / 4 Scheibenabfrage Einlauf / Auslauf
  b := VisuHand_Set(stH := pH^, wZeile := 3, sText := SEL(abgStationsstatusVisu[i].bSensorEinlauf[1], 'frei', 'belegt'), dwFarbe := SEL(abgStationsstatusVisu[i].bSensorEinlauf[1], dwGR, dwB));
  b := VisuHand_Set(stH := pH^, wZeile := 4, sText := SEL(abgStationsstatusVisu[i].bSensorAuslauf[1], 'frei', 'belegt'), dwFarbe := SEL(abgStationsstatusVisu[i].bSensorAuslauf[1], dwGR, dwB));
  // 5 Querfahrt
  b := VisuHand_Set(stH := pH^, wZeile := 5,
                     sText   := VisuUeb_MmText(sPrefix := '', rWert := abgStationsstatusVisu[i].rQuerfahrtIstPos, sEinheit := ' mm'),
                     dwFarbe := SEL(abgStationsstatusVisu[i].bQuerfahrtFehler, SEL(abgStationsstatusVisu[i].bQuerfahrtAntriebReferenziert, dwO, dwG), dwR));
  // 6 Schmierung
  b := VisuHand_Set(stH := pH^, wZeile := 6, sText := '', dwFarbe := dwGR);
END_FOR

// -------------------------------------------------------------------------------------------
// [301] - [305] FAECHERWAGEN (Variante Einfach: Rolltor, Arretierung = Gegenhalter)
// -------------------------------------------------------------------------------------------
FOR i := 301 TO 305 DO
  pBP := ADR(StationBasisParameter.starrFaecherwagenBasisParameter[i]);
  b := VisuHand_Sperre(stBP := pBP^, stH := VISU_HAND.astFW[i], bFaecherwagen := TRUE);
  IF __ISVALIDREF(pBP^.stMKs) THEN
    VISU_HAND.astFW[i].abZeileVorhanden[1] := pBP^.stMKs.stStationsAufbau.bRolltor;
    VISU_HAND.astFW[i].abZeileVorhanden[2] := TRUE;
  END_IF

  // Rolltor-Schalter gegenseitig ausschliessen, ausserhalb des Handbetriebs zuruecksetzen
  artlRolltorHoch[i](CLK := VISU_VARS.bgVISUFWRolltorHoch[i]);
  artlRolltorRunter[i](CLK := VISU_VARS.bgVISUFWRolltorRunter[i]);
  IF artlRolltorHoch[i].Q THEN   VISU_VARS.bgVISUFWRolltorRunter[i] := FALSE; END_IF
  IF artlRolltorRunter[i].Q THEN VISU_VARS.bgVISUFWRolltorHoch[i]   := FALSE; END_IF
  IF VISU_HAND.astFW[i].bGesperrt THEN
    VISU_VARS.bgVISUFWRolltorHoch[i]   := FALSE;
    VISU_VARS.bgVISUFWRolltorRunter[i] := FALSE;
  END_IF

  // 1 Rolltor
  IF VISU_VARS.astgFaecherwagenstatusVisu[i].bRolltorOben THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 1, sText := 'oben',  dwFarbe := dwG);
  ELSIF VISU_VARS.astgFaecherwagenstatusVisu[i].bRolltorUnten THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 1, sText := 'unten', dwFarbe := dwG);
  ELSE
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 1, sText := '?',     dwFarbe := dwO);
  END_IF
  // 2 Gegenhalter (Arretierung): Endlage 1 = offen, 2 = geschlossen
  IF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[1] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 2, sText := 'offen', dwFarbe := dwG);
  ELSIF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[2] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 2, sText := 'zu',    dwFarbe := dwG);
  ELSE
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 2, sText := '?',     dwFarbe := dwO);
  END_IF
END_FOR
END_PROGRAM