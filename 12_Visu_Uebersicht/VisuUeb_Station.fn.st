(* METADATA
{
	"v3Meta": {
		"objectGuid": "2a69d02d-507f-4a31-bfce-f3b7167a1195"
	}
}
*)
FUNCTION VisuUeb_Station : BOOL
VAR_IN_OUT
  stBP    : StationBasisParameter_ST;
  stKarte : VisuUeb_Station_ST;
END_VAR
VAR_INPUT
  sTitel  : STRING(40);
  bBlink  : BOOL;
  bGlasZusatz : BOOL := FALSE; // zusaetzliche Glaserkennung (z.B. Sensoren)
  bReferenzRelevant : BOOL := TRUE; // FALSE: Station hat keine referenzierbaren Achsen (z.B. Faecherwagen)
END_VAR
VAR
  bDeaktiviert : BOOL;
END_VAR
stKarte.sTitel := sTitel;
IF __ISVALIDREF(stBP.stMKs) THEN
  bDeaktiviert := stBP.stMKs.bDeaktivieren;
END_IF
stKarte.bDeaktiviert := bDeaktiviert;

// Referenzstatus (BasisStationsParameter.bIstReferenziert)
stKarte.bReferenzAnzeigen := bReferenzRelevant AND NOT bDeaktiviert;
IF stBP.bIstReferenziert THEN
  stKarte.sReferenz := 'REFERENZIERT';      stKarte.dwReferenzFarbe := VISU_UEBERSICHT.cFARBE_GRUEN;
ELSIF stBP.bReferenz THEN
  stKarte.sReferenz := 'REFERENZIERT ...';  stKarte.dwReferenzFarbe := SEL(bBlink, VISU_UEBERSICHT.cFARBE_GRAU, VISU_UEBERSICHT.cFARBE_BLAU);
ELSE
  stKarte.sReferenz := 'NICHT REFERENZIERT'; stKarte.dwReferenzFarbe := VISU_UEBERSICHT.cFARBE_ORANGE;
END_IF

// Zustand
IF bDeaktiviert THEN
  stKarte.sZustand := 'DEAKTIVIERT';         stKarte.dwZustandFarbe := VISU_UEBERSICHT.cFARBE_GRAU;
ELSIF stBP.bFehler THEN
  stKarte.sZustand := 'STÖRUNG';             stKarte.dwZustandFarbe := VISU_UEBERSICHT.cFARBE_ROT;
ELSIF stBP.bReset THEN
  stKarte.sZustand := 'RESET';               stKarte.dwZustandFarbe := VISU_UEBERSICHT.cFARBE_BLAU;
ELSIF stBP.bReferenz THEN
  stKarte.sZustand := 'REFERENZFAHRT';       stKarte.dwZustandFarbe := VISU_UEBERSICHT.cFARBE_BLAU;
ELSIF stBP.bCheck THEN
  stKarte.sZustand := 'SYSTEMCHECK';         stKarte.dwZustandFarbe := VISU_UEBERSICHT.cFARBE_BLAU;
ELSIF stBP.bAutomatik THEN
  stKarte.sZustand := 'AUTOMATIK';           stKarte.dwZustandFarbe := VISU_UEBERSICHT.cFARBE_GRUEN;
ELSE
  stKarte.sZustand := 'HAND';                stKarte.dwZustandFarbe := VISU_UEBERSICHT.cFARBE_ORANGE;
END_IF

// Rahmen: Stoerung blinkt rot, aktiver Auftrag blau
IF stBP.bFehler AND NOT bDeaktiviert THEN
  stKarte.dwRahmenFarbe := SEL(bBlink, VISU_UEBERSICHT.cFARBE_RAHMEN, VISU_UEBERSICHT.cFARBE_ROT);
ELSIF stBP.bAuftragAktiv THEN
  stKarte.dwRahmenFarbe := VISU_UEBERSICHT.cFARBE_BLAU;
ELSE
  stKarte.dwRahmenFarbe := VISU_UEBERSICHT.cFARBE_RAHMEN;
END_IF

// Aktive Funktion
IF bDeaktiviert THEN
  stKarte.sFunktion := '-';
ELSIF stBP.bFehler THEN
  stKarte.sFunktion := CONCAT('Fehlernummer ', WORD_TO_STRING(stBP.wFehlerNummer));
ELSIF stBP.bAnlegen THEN                      stKarte.sFunktion := 'Anlegen';
ELSIF stBP.bAbnehmen THEN                     stKarte.sFunktion := 'Abnehmen';
ELSIF stBP.bEintransport[cWAND_1] THEN        stKarte.sFunktion := 'Eintransport';
ELSIF stBP.bAustransport[cWAND_1] THEN        stKarte.sFunktion := 'Austransport';
ELSIF stBP.bDurchtransport[cWAND_1] THEN      stKarte.sFunktion := 'Durchtransport';
ELSIF stBP.bVortransport[cWAND_1] THEN        stKarte.sFunktion := 'Vortransport';
ELSIF stBP.bTransportkopplung[cWAND_1] THEN   stKarte.sFunktion := 'Transportkopplung';
ELSIF stBP.bMesskopplung[cWAND_1] THEN        stKarte.sFunktion := 'Messkopplung';
ELSIF stBP.bGlaslaengenmessung THEN           stKarte.sFunktion := 'Glaslängenmessung';
ELSIF stBP.bGlashoehenmessung THEN            stKarte.sFunktion := 'Glashöhenmessung';
ELSIF stBP.bVorabpositionieren THEN           stKarte.sFunktion := 'Vorabpositionierung';
ELSIF stBP.bAuftragAktiv THEN                 stKarte.sFunktion := 'Auftrag aktiv';
ELSIF stBP.bFreigabe THEN                     stKarte.sFunktion := 'Bereit';
ELSE                                          stKarte.sFunktion := 'Keine Freigabe';
END_IF

stKarte.bGlas := stBP.bStationBelegt[cWAND_1] OR bGlasZusatz;
VisuUeb_Station := stBP.bFehler AND NOT bDeaktiviert;
END_FUNCTION