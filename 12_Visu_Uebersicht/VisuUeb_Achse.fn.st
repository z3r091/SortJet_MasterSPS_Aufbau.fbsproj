(* METADATA
{
  "v3Meta": {
    "objectGuid": "3979691c-e077-4914-8fb4-604417bd71fb"
  }
}
*)
FUNCTION VisuUeb_Achse : BOOL
VAR_IN_OUT
  stAchse   : VisuUeb_Achse_ST;
  bInit     : BOOL;  // Skalierung initialisiert (RETAIN)
  rMin      : REAL;  // gelerntes Minimum (RETAIN)
  rMax      : REAL;  // gelerntes Maximum (RETAIN)
END_VAR
VAR_INPUT
  rIst         : REAL;
  rZiel        : REAL;
  rSpeed       : REAL;
  bPositionierung : BOOL;
  bReferenziert   : BOOL;
  bFehler         : BOOL;
  bMinEnd         : BOOL;
  bMaxEnd         : BOOL;
  bNeuLernen      : BOOL;
  bBlink          : BOOL;
END_VAR
VAR
  rSpanne : REAL;
  rFaktor : REAL;
  iWeg    : INT;
END_VAR
// Skalierung lernen (nur mit gueltiger Referenz)
IF bNeuLernen THEN
  bInit := FALSE;
END_IF
IF bReferenziert THEN
  IF NOT bInit THEN
    rMin  := rIst;
    rMax  := rIst;
    bInit := TRUE;
  END_IF
  rMin := MIN(rMin, rIst);
  rMax := MAX(rMax, rIst);
  IF bPositionierung THEN
    rMin := MIN(rMin, rZiel);
    rMax := MAX(rMax, rZiel);
  END_IF
END_IF

rSpanne := MAX(rMax - rMin, VISU_UEBERSICHT.cMIN_SPANNE_MM);
iWeg    := VISU_UEBERSICHT.cBAHN_BREITE_PX - VISU_UEBERSICHT.cWAGEN_BREITE_PX;

rFaktor := LIMIT(0.0, (rIst - rMin) / rSpanne, 1.0);
stAchse.iPixel := REAL_TO_INT(rFaktor * INT_TO_REAL(iWeg));
rFaktor := LIMIT(0.0, (rZiel - rMin) / rSpanne, 1.0);
stAchse.iZielPixel := REAL_TO_INT(rFaktor * INT_TO_REAL(iWeg));

stAchse.rIstPos         := rIst;
stAchse.rZielPos        := rZiel;
stAchse.rSpeed          := rSpeed;
stAchse.bPositionierung := bPositionierung;
stAchse.bReferenziert   := bReferenziert;
stAchse.sIstPos         := VisuUeb_MmText(sPrefix := 'Ist  ', rWert := rIst);
stAchse.sZielPos        := SEL(bPositionierung, 'Ziel  -', VisuUeb_MmText(sPrefix := 'Ziel  ', rWert := rZiel));
stAchse.sSpeed          := VisuUeb_MmText(sPrefix := 'v  ', rWert := rSpeed, sEinheit := ' mm/s');
stAchse.sBereich        := CONCAT(CONCAT(VisuUeb_MmText(sPrefix := 'Bereich ', rWert := rMin), ' ... '), VisuUeb_MmText(sPrefix := '', rWert := rMax));

IF bFehler THEN
  stAchse.dwKoerperFarbe := SEL(bBlink, 16#FF8C2F2F, VISU_UEBERSICHT.cFARBE_ROT);
ELSIF NOT bReferenziert THEN
  stAchse.dwKoerperFarbe := VISU_UEBERSICHT.cFARBE_ORANGE;
ELSIF bPositionierung THEN
  stAchse.dwKoerperFarbe := 16#FF1C64CC;
ELSE
  stAchse.dwKoerperFarbe := VISU_UEBERSICHT.cFARBE_BLAU;
END_IF
stAchse.dwMinEndFarbe := SEL(bMinEnd, VISU_UEBERSICHT.cFARBE_GRAU_HELL, VISU_UEBERSICHT.cFARBE_ROT);
stAchse.dwMaxEndFarbe := SEL(bMaxEnd, VISU_UEBERSICHT.cFARBE_GRAU_HELL, VISU_UEBERSICHT.cFARBE_ROT);
VisuUeb_Achse := bInit;
END_FUNCTION