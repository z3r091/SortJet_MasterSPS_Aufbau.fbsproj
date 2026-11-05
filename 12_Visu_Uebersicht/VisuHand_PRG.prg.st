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

  // Reset
  fbReset201, fbReset202, fbReset101, fbReset151 : VisuHand_Reset_FB;
  afbResetFW       : ARRAY[301..302] OF VisuHand_Reset_FB;
  rtlAnlageReset   : R_TRIG;  // Anlagen-Reset auf Flanke
  tofAnlageReset   : TOF;     // Mindestanzeige "Reset aktiv"

  // Rolltor-Schalter (Toggle) gegenseitig ausschliessen
  artlRolltorHoch, artlRolltorRunter : ARRAY[301..302] OF R_TRIG;
END_VAR
// *************************************************************************************************
// DATENAUFBEREITUNG FUER DIE VISU "Handbetrieb"
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
// Reset aktiv: min. 1 s nach Druck bzw. solange irgendeine Station ihren Reset noch nicht abgeschlossen hat
tofAnlageReset(IN := rtlAnlageReset.Q, PT := T#1S);
VISU_HAND.bAnlageResetAktiv := tofAnlageReset.Q
                               OR StationBasisParameter.starrStationBasisParameter[201].bReset
                               OR StationBasisParameter.starrStationBasisParameter[202].bReset
                               OR StationBasisParameter.starrShuttleBasisParameter[101].bReset
                               OR StationBasisParameter.starrTransfershuttleBasisParameter[151].bReset
                               OR StationBasisParameter.starrFaecherwagenBasisParameter[301].bReset
                               OR StationBasisParameter.starrFaecherwagenBasisParameter[302].bReset;
IF VISU_HAND.bAnlageResetAktiv THEN
  VISU_HAND.sAnlageReset       := 'RESET AKTIV ...';
  VISU_HAND.dwAnlageResetFarbe := dwO;
ELSE
  VISU_HAND.sAnlageReset       := 'ANLAGE RESET';
  VISU_HAND.dwAnlageResetFarbe := dwR;
END_IF

fbReset201(stBP := StationBasisParameter.starrStationBasisParameter[201],     stH := VISU_HAND.st201);
fbReset202(stBP := StationBasisParameter.starrStationBasisParameter[202],     stH := VISU_HAND.st202);
fbReset101(stBP := StationBasisParameter.starrShuttleBasisParameter[101],     stH := VISU_HAND.st101);
fbReset151(stBP := StationBasisParameter.starrTransfershuttleBasisParameter[151], stH := VISU_HAND.st151);
FOR i := 301 TO 302 DO
  afbResetFW[i](stBP := StationBasisParameter.starrFaecherwagenBasisParameter[i], stH := VISU_HAND.astFW[i]);
END_FOR

// -------------------------------------------------------------------------------------------
// FUNKTIONSZEILEN LAUT MK-STATIONSAUFBAU
// -------------------------------------------------------------------------------------------
IF __ISVALIDREF(StationBasisParameter.starrStationBasisParameter[201].stMKs) THEN
  VISU_HAND.st201.abZeileVorhanden[1] := StationBasisParameter.starrStationBasisParameter[201].stMKs.stStationsAufbau.bGlastransport[cWAND_1];
  VISU_HAND.st201.abZeileVorhanden[2] := StationBasisParameter.starrStationBasisParameter[201].stMKs.stStationsAufbau.bAnschlag;
  VISU_HAND.st201.abZeileVorhanden[3] := TRUE; // Hubrahmen (Riemen-Hubpalette) gehoert fest zum Anlegetisch
  VISU_HAND.st201.abZeileVorhanden[4] := StationBasisParameter.starrStationBasisParameter[201].stMKs.stStationsAufbau.bMessachse;
  VISU_HAND.st201.abZeileVorhanden[5] := StationBasisParameter.starrStationBasisParameter[201].stMKs.stStationsAufbau.bGeblase[cWAND_1];
  VISU_HAND.st201.abZeileVorhanden[6] := StationBasisParameter.starrStationBasisParameter[201].stMKs.stStationsAufbau.bGeblase[cWAND_1];
END_IF
IF __ISVALIDREF(StationBasisParameter.starrStationBasisParameter[202].stMKs) THEN
  VISU_HAND.st202.abZeileVorhanden[1] := StationBasisParameter.starrStationBasisParameter[202].stMKs.stStationsAufbau.bGlastransport[cWAND_1];
  VISU_HAND.st202.abZeileVorhanden[2] := StationBasisParameter.starrStationBasisParameter[202].stMKs.stStationsAufbau.bKippen[cWAND_1];
  VISU_HAND.st202.abZeileVorhanden[3] := StationBasisParameter.starrStationBasisParameter[202].stMKs.stStationsAufbau.bQuerfahrt;
END_IF
IF __ISVALIDREF(StationBasisParameter.starrShuttleBasisParameter[101].stMKs) THEN
  VISU_HAND.st101.abZeileVorhanden[1] := StationBasisParameter.starrShuttleBasisParameter[101].stMKs.stStationsAufbau.bGlastransport[cWAND_1];
  VISU_HAND.st101.abZeileVorhanden[2] := StationBasisParameter.starrShuttleBasisParameter[101].stMKs.stStationsAufbau.bGeblase[cWAND_1];
  VISU_HAND.st101.abZeileVorhanden[3] := StationBasisParameter.starrShuttleBasisParameter[101].stMKs.stStationsAufbau.bTransportVerstellung[cWAND_1];
  VISU_HAND.st101.abZeileVorhanden[4] := StationBasisParameter.starrShuttleBasisParameter[101].stMKs.stStationsAufbau.bKippen[cWAND_1];
  VISU_HAND.st101.abZeileVorhanden[5] := StationBasisParameter.starrShuttleBasisParameter[101].stMKs.stStationsAufbau.bQuerfahrt;
  VISU_HAND.st101.abZeileVorhanden[6] := StationBasisParameter.starrShuttleBasisParameter[101].stMKs.stStationsAufbau.bDLSSchmiersystem;
END_IF
IF __ISVALIDREF(StationBasisParameter.starrTransfershuttleBasisParameter[151].stMKs) THEN
  VISU_HAND.st151.abZeileVorhanden[1] := StationBasisParameter.starrTransfershuttleBasisParameter[151].stMKs.stStationsAufbau.bGlastransport[cWAND_1];
  VISU_HAND.st151.abZeileVorhanden[2] := StationBasisParameter.starrTransfershuttleBasisParameter[151].stMKs.stStationsAufbau.bGlastransport[cWAND_1];
  VISU_HAND.st151.abZeileVorhanden[3] := StationBasisParameter.starrTransfershuttleBasisParameter[151].stMKs.stStationsAufbau.bDruckluft;
  VISU_HAND.st151.abZeileVorhanden[4] := StationBasisParameter.starrTransfershuttleBasisParameter[151].stMKs.stStationsAufbau.bDruckluft;
  VISU_HAND.st151.abZeileVorhanden[5] := StationBasisParameter.starrTransfershuttleBasisParameter[151].stMKs.stStationsAufbau.bQuerfahrt;
  VISU_HAND.st151.abZeileVorhanden[6] := StationBasisParameter.starrTransfershuttleBasisParameter[151].stMKs.stStationsAufbau.bDLSSchmiersystem;
END_IF

// -------------------------------------------------------------------------------------------
// SCHALTER (TOGGLE) - ausserhalb des Handbetriebs immer zuruecksetzen
// -------------------------------------------------------------------------------------------
IF VISU_HAND.st201.bGesperrt THEN
  VISU_VARS.bgVISUGeblaese[201, cWAND_1] := FALSE;
  VISU_VARS.bgVISUDrosselklappeAUF[201]  := FALSE;
END_IF
IF VISU_HAND.st101.bGesperrt THEN
  VISU_VARS.bgVISUGeblaese[101, cWAND_1] := FALSE;
END_IF
IF VISU_HAND.st151.bGesperrt THEN
  VISU_VARS.bgVisuTFSRiemenAnheben[151]     := FALSE;
  VISU_VARS.bgVisuTFSAbfrageEinlaufAuf[151] := FALSE;
  VISU_VARS.bgVisuTFSAbfrageEinlaufEin[151] := FALSE;
  VISU_VARS.bgVisuTFSAbfrageAuslaufAuf[151] := FALSE;
  VISU_VARS.bgVisuTFSAbfrageAuslaufEin[151] := FALSE;
END_IF
FOR i := 301 TO 302 DO
  artlRolltorHoch[i](CLK := VISU_VARS.bgVISUFWRolltorHoch[i]);
  artlRolltorRunter[i](CLK := VISU_VARS.bgVISUFWRolltorRunter[i]);
  IF artlRolltorHoch[i].Q THEN   VISU_VARS.bgVISUFWRolltorRunter[i] := FALSE; END_IF
  IF artlRolltorRunter[i].Q THEN VISU_VARS.bgVISUFWRolltorHoch[i]   := FALSE; END_IF
  IF VISU_HAND.astFW[i].bGesperrt THEN
    VISU_VARS.bgVISUFWRolltorHoch[i]   := FALSE;
    VISU_VARS.bgVISUFWRolltorRunter[i] := FALSE;
  END_IF
END_FOR

// -------------------------------------------------------------------------------------------
// [201] ANLEGETISCH
// -------------------------------------------------------------------------------------------
b := VisuHand_Sperre(stBP := StationBasisParameter.starrStationBasisParameter[201], stH := VISU_HAND.st201, bFaecherwagen := FALSE);
// 1 Riemen (laeuft nur bei ausgefahrenem Hubrahmen)
b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 1,
                   sText   := SEL(abgStationsstatusVisu[201].bHubpaletteSensorAusgefahren, 'Hubr. unten', SEL(abgStationsstatusVisu[201].bSensorEinlauf[1] OR abgStationsstatusVisu[201].bSensorAuslauf[1], 'frei', 'Glas')),
                   dwFarbe := SEL(abgStationsstatusVisu[201].bHubpaletteSensorAusgefahren, dwO, dwG));
// 2 Anschlag
IF abgStationsstatusVisu[201].bAnschlagFehler THEN                   b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 2, sText := 'Fehler', dwFarbe := dwR);
ELSIF abgStationsstatusVisu[201].bAnschlagSensorAusgefahren THEN     b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 2, sText := 'oben',   dwFarbe := dwG);
ELSIF abgStationsstatusVisu[201].bAnschlagSensorEingefahren THEN     b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 2, sText := 'unten',  dwFarbe := dwG);
ELSE                                                                 b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 2, sText := '?',      dwFarbe := dwO);
END_IF
// 3 Hubrahmen
IF abgStationsstatusVisu[201].bHubpaletteFehler THEN                 b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 3, sText := 'Fehler', dwFarbe := dwR);
ELSIF abgStationsstatusVisu[201].bHubpaletteSensorAusgefahren THEN   b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 3, sText := 'oben',   dwFarbe := dwG);
ELSIF abgStationsstatusVisu[201].bHubpaletteSensorEingefahren THEN   b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 3, sText := 'unten',  dwFarbe := dwG);
ELSE                                                                 b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 3, sText := '?',      dwFarbe := dwO);
END_IF
// 4 Messachse
b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 4,
                   sText   := VisuUeb_MmText(sPrefix := '', rWert := abgStationsstatusVisu[201].rMessachseIstPos, sEinheit := ' mm'),
                   dwFarbe := SEL(abgStationsstatusVisu[201].bMessachseFehler, SEL(StationBasisParameter.starrStationBasisParameter[201].bIstReferenziert, dwO, dwG), dwR));
// 5 Geblaese
b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 5, sText := SEL(abgStationsstatusVisu[201].bGeblaeseLaeuft[1], 'aus', 'EIN'), dwFarbe := SEL(abgStationsstatusVisu[201].bGeblaeseLaeuft[1], dwGR, dwB));
// 6 Drosselklappe
b := VisuHand_Set(stH := VISU_HAND.st201, wZeile := 6, sText := SEL(abgStationsstatusVisu[201].bDrosselklappeOffen[1], 'zu', 'auf'), dwFarbe := SEL(abgStationsstatusVisu[201].bDrosselklappeOffen[1], dwGR, dwB));

// -------------------------------------------------------------------------------------------
// [202] KIPPTISCH
// -------------------------------------------------------------------------------------------
b := VisuHand_Sperre(stBP := StationBasisParameter.starrStationBasisParameter[202], stH := VISU_HAND.st202, bFaecherwagen := FALSE);
b := VisuHand_Set(stH := VISU_HAND.st202, wZeile := 1,
                   sText   := SEL(abgStationsstatusVisu[202].bSensorEinlauf[1] OR abgStationsstatusVisu[202].bSensorAuslauf[1], 'frei', 'Glas'),
                   dwFarbe := SEL(abgStationsstatusVisu[202].bSensorEinlauf[1] OR abgStationsstatusVisu[202].bSensorAuslauf[1], dwGR, dwB));
CASE abgStationsstatusVisu[202].epKippStatus OF
  Kippen_EN.eKippen_Position_0Grad:    sKipp := 'waagerecht'; dwKipp := dwG;
  Kippen_EN.eKippen_Position_90Grad:   sKipp := 'senkrecht';  dwKipp := dwG;
  Kippen_EN.eKippen_Position_84Grad:   sKipp := '84°';        dwKipp := dwG;
  Kippen_EN.eKippen_Position_88_5Grad: sKipp := '88,5°';      dwKipp := dwG;
  Kippen_EN.eKippen_Position_96Grad:   sKipp := '96°';        dwKipp := dwG;
  Kippen_EN.eKippen_Fehler:            sKipp := 'Fehler';     dwKipp := dwR;
  ELSE                                   sKipp := 'Zwischen';   dwKipp := dwO;
END_CASE
IF abgStationsstatusVisu[202].bKippenFehler THEN dwKipp := dwR; ELSIF NOT abgStationsstatusVisu[202].bKippenAntriebReferenziert THEN dwKipp := dwO; END_IF
b := VisuHand_Set(stH := VISU_HAND.st202, wZeile := 2, sText := sKipp, dwFarbe := dwKipp);
b := VisuHand_Set(stH := VISU_HAND.st202, wZeile := 3,
                   sText   := VisuUeb_MmText(sPrefix := '', rWert := abgStationsstatusVisu[202].rQuerfahrtIstPos, sEinheit := ' mm'),
                   dwFarbe := SEL(abgStationsstatusVisu[202].bQuerfahrtFehler, SEL(abgStationsstatusVisu[202].bQuerfahrtAntriebReferenziert, dwO, dwG), dwR));

// -------------------------------------------------------------------------------------------
// [101] SHUTTLE
// -------------------------------------------------------------------------------------------
b := VisuHand_Sperre(stBP := StationBasisParameter.starrShuttleBasisParameter[101], stH := VISU_HAND.st101, bFaecherwagen := FALSE);
b := VisuHand_Set(stH := VISU_HAND.st101, wZeile := 1,
                   sText   := SEL(abgStationsstatusVisu[101].bSensorEinlauf[1] OR abgStationsstatusVisu[101].bSensorAuslauf[1] OR abgStationsstatusVisu[101].bSensorAuslaufStopp[1], 'frei', 'Glas'),
                   dwFarbe := SEL(abgStationsstatusVisu[101].bSensorEinlauf[1] OR abgStationsstatusVisu[101].bSensorAuslauf[1] OR abgStationsstatusVisu[101].bSensorAuslaufStopp[1], dwGR, dwB));
b := VisuHand_Set(stH := VISU_HAND.st101, wZeile := 2, sText := SEL(abgStationsstatusVisu[101].bGeblaeseLaeuft[1], 'aus', 'EIN'), dwFarbe := SEL(abgStationsstatusVisu[101].bGeblaeseLaeuft[1], dwGR, dwB));
CASE abgStationsstatusVisu[101].epWandverstellungStatus[1] OF
  PneumatikZylinderStatus_EN.eZylinderStellung16mm: b := VisuHand_Set(stH := VISU_HAND.st101, wZeile := 3, sText := '16 mm', dwFarbe := dwG);
  PneumatikZylinderStatus_EN.eZylinderStellung23mm: b := VisuHand_Set(stH := VISU_HAND.st101, wZeile := 3, sText := '23 mm', dwFarbe := dwG);
  PneumatikZylinderStatus_EN.eZylinderStellung29mm: b := VisuHand_Set(stH := VISU_HAND.st101, wZeile := 3, sText := '29 mm', dwFarbe := dwG);
  ELSE                                                b := VisuHand_Set(stH := VISU_HAND.st101, wZeile := 3, sText := '?',     dwFarbe := dwO);
END_CASE
CASE abgStationsstatusVisu[101].epKippStatus OF
  Kippen_EN.eKippen_Position_0Grad:    sKipp := '0°';     dwKipp := dwG;
  Kippen_EN.eKippen_Position_84Grad:   sKipp := '84°';    dwKipp := dwG;
  Kippen_EN.eKippen_Position_88_5Grad: sKipp := '88,5°';  dwKipp := dwG;
  Kippen_EN.eKippen_Position_90Grad:   sKipp := '90°';    dwKipp := dwG;
  Kippen_EN.eKippen_Position_96Grad:   sKipp := '96°';    dwKipp := dwG;
  Kippen_EN.eKippen_Fehler:            sKipp := 'Fehler'; dwKipp := dwR;
  ELSE                                   sKipp := 'Zwischen'; dwKipp := dwO;
END_CASE
IF abgStationsstatusVisu[101].bKippenFehler THEN dwKipp := dwR; END_IF
b := VisuHand_Set(stH := VISU_HAND.st101, wZeile := 4, sText := sKipp, dwFarbe := dwKipp);
b := VisuHand_Set(stH := VISU_HAND.st101, wZeile := 5,
                   sText   := VisuUeb_MmText(sPrefix := '', rWert := abgStationsstatusVisu[101].rQuerfahrtIstPos, sEinheit := ' mm'),
                   dwFarbe := SEL(abgStationsstatusVisu[101].bQuerfahrtFehler, SEL(abgStationsstatusVisu[101].bQuerfahrtAntriebReferenziert, dwO, dwG), dwR));
b := VisuHand_Set(stH := VISU_HAND.st101, wZeile := 6, sText := '', dwFarbe := dwGR);

// -------------------------------------------------------------------------------------------
// [151] TRANSFERSHUTTLE
// -------------------------------------------------------------------------------------------
b := VisuHand_Sperre(stBP := StationBasisParameter.starrTransfershuttleBasisParameter[151], stH := VISU_HAND.st151, bFaecherwagen := FALSE);
b := VisuHand_Set(stH := VISU_HAND.st151, wZeile := 1,
                   sText   := SEL(abgStationsstatusVisu[151].bSensorEinlauf[1] OR abgStationsstatusVisu[151].bSensorAuslauf[1], 'frei', 'Glas'),
                   dwFarbe := SEL(abgStationsstatusVisu[151].bSensorEinlauf[1] OR abgStationsstatusVisu[151].bSensorAuslauf[1], dwGR, dwB));
// 2 Riemen Hub (Glastransport angehoben / abgesenkt)
IF Globale_Bausteine.aTransfershuttles[151].in_bSensorShuttleOben AND NOT Globale_Bausteine.aTransfershuttles[151].in_bSensorShuttleUnten THEN
  b := VisuHand_Set(stH := VISU_HAND.st151, wZeile := 2, sText := 'angehoben', dwFarbe := dwB);
ELSIF Globale_Bausteine.aTransfershuttles[151].in_bSensorShuttleUnten AND NOT Globale_Bausteine.aTransfershuttles[151].in_bSensorShuttleOben THEN
  b := VisuHand_Set(stH := VISU_HAND.st151, wZeile := 2, sText := 'abgesenkt', dwFarbe := dwG);
ELSE
  b := VisuHand_Set(stH := VISU_HAND.st151, wZeile := 2, sText := '?', dwFarbe := dwO);
END_IF
b := VisuHand_Set(stH := VISU_HAND.st151, wZeile := 3, sText := SEL(abgStationsstatusVisu[151].bSensorEinlauf[1], 'frei', 'belegt'), dwFarbe := SEL(abgStationsstatusVisu[151].bSensorEinlauf[1], dwGR, dwB));
b := VisuHand_Set(stH := VISU_HAND.st151, wZeile := 4, sText := SEL(abgStationsstatusVisu[151].bSensorAuslauf[1], 'frei', 'belegt'), dwFarbe := SEL(abgStationsstatusVisu[151].bSensorAuslauf[1], dwGR, dwB));
b := VisuHand_Set(stH := VISU_HAND.st151, wZeile := 5,
                   sText   := VisuUeb_MmText(sPrefix := '', rWert := abgStationsstatusVisu[151].rQuerfahrtIstPos, sEinheit := ' mm'),
                   dwFarbe := SEL(abgStationsstatusVisu[151].bQuerfahrtFehler, SEL(abgStationsstatusVisu[151].bQuerfahrtAntriebReferenziert, dwO, dwG), dwR));
b := VisuHand_Set(stH := VISU_HAND.st151, wZeile := 6, sText := '', dwFarbe := dwGR);

// -------------------------------------------------------------------------------------------
// [301] / [302] FAECHERWAGEN
// - Status aus VISU_VARS.astgFaecherwagenstatusVisu; Zeilen 2-5 zeigen die Endlagen der Variante
//   Lineareinheit (abEndlage, Index = Bit der Handfunktion)
// -------------------------------------------------------------------------------------------
FOR i := 301 TO 302 DO
  b := VisuHand_Sperre(stBP := StationBasisParameter.starrFaecherwagenBasisParameter[i], stH := VISU_HAND.astFW[i], bFaecherwagen := TRUE);
  // 1 Rolltor
  IF VISU_VARS.astgFaecherwagenstatusVisu[i].bRolltorOben THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 1, sText := 'oben',  dwFarbe := dwG);
  ELSIF VISU_VARS.astgFaecherwagenstatusVisu[i].bRolltorUnten THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 1, sText := 'unten', dwFarbe := dwG);
  ELSE
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 1, sText := '?',     dwFarbe := dwO);
  END_IF
  // 2 Lineareinheit
  IF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[7] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 2, sText := 'vorne',   dwFarbe := dwG);
  ELSIF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[8] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 2, sText := 'hinten',  dwFarbe := dwG);
  ELSIF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[9] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 2, sText := 'Shuttle', dwFarbe := dwG);
  ELSE
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 2, sText := '?',       dwFarbe := dwO);
  END_IF
  // 3 Greifer
  IF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[11] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 3, sText := 'offen', dwFarbe := dwG);
  ELSIF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[12] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 3, sText := 'zu',    dwFarbe := dwG);
  ELSE
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 3, sText := '?',     dwFarbe := dwO);
  END_IF
  // 4 Entriegelung
  IF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[3] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 4, sText := 'offen', dwFarbe := dwG);
  ELSIF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[2] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 4, sText := 'zu',    dwFarbe := dwG);
  ELSE
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 4, sText := '?',     dwFarbe := dwO);
  END_IF
  // 5 Gegenhalter
  IF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[0] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 5, sText := 'offen', dwFarbe := dwG);
  ELSIF VISU_VARS.astgFaecherwagenstatusVisu[i].abEndlage[1] THEN
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 5, sText := 'zu',    dwFarbe := dwG);
  ELSE
    b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 5, sText := '?',     dwFarbe := dwO);
  END_IF
  // 6 Lichtschranke
  b := VisuHand_Set(stH := VISU_HAND.astFW[i], wZeile := 6,
                     sText   := SEL(VISU_VARS.astgFaecherwagenstatusVisu[i].bLichtschrankeOK, 'ausgelöst', 'ok'),
                     dwFarbe := SEL(VISU_VARS.astgFaecherwagenstatusVisu[i].bLichtschrankeOK, dwR, dwG));
END_FOR
END_PROGRAM