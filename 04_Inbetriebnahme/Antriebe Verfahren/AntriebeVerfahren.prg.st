(* METADATA
{
  "v3Meta": {
    "objectGuid": "a5762ed9-3fa6-4730-8f16-2864171dd370"
  }
}
*)
PROGRAM AntriebeVerfahren
VAR_INPUT
  // BOOL
  bpStartAbsolut   : BOOL;
  bpStartRelativ   : BOOL;
  bpStartReferenz  : BOOL;
  bpStartRestweg   : BOOL;
  bpStartMessung   : BOOL;
  bpMasterSlave : BOOL;
  bpMasterSlaveInv : BOOL;
  bpHandPlus       : BOOL;
  bpHandMinus      : BOOL;
  bpStopp          : BOOL;
  bpReset          : BOOL;
  bpFreigabeSetzen : BOOL;
  
  bpRestwegPositiv         : BOOL;
  bpRestwegNegativ         : BOOL;
  bpRestwegSteigendeFlanke : BOOL;
  bpRestwegFallendeFlanke  : BOOL;
  bpRestwegSensor1         : BOOL;
  bpRestwegSensor2         : BOOL;
  bpRestwegSensor3         : BOOL;
  bpRestwegSensor4         : BOOL;
  
  // WORD
  bAchsIDTemp      : WORD;
  
END_VAR

VAR
  // TRIGGER
  rtlStartAbsolut   : r_trig;
  rtlStartRelativ   : r_trig;
  rtlStartReferenz  : r_trig;
  rtlStartMessung   : r_trig;
  rtlStartRestweg   : r_trig;
  rtlStartMasterSlave : R_TRIG;
  rtlStartMasterSlaveInvertiert : R_TRIG;
  rtlStopp          : r_trig;
  rtlReset          : r_trig;
  rtlAntriebDone    : r_trig;
  
  ftlHandPlusMinus  : f_trig;
  
  // TIMER
  tonlErsterZyklus  :ton;;
  
  // BOOL
  bInit : BOOL := TRUE;
  
  // INT
  i : UINT;
END_VAR

VAR_OUTPUT
  astlAchseName : ARRAY[0..35] OF STRING;
  uiAchsenAnzahl : UINT := 35;
END_VAR

rtlStartAbsolut( CLK := bpStartAbsolut);
rtlStartRelativ( CLK := bpStartRelativ);
rtlStartReferenz( CLK := bpStartReferenz);
rtlStartRestweg( CLK := bpStartRestweg);
rtlStartMessung( CLK := bpStartMessung);
rtlStartMasterSlave( CLK := bpMasterSlave);
rtlStartMasterSlaveInvertiert( CLK := bpMasterSlaveInv);
rtlStopp( CLK := bpStopp);
rtlReset( CLK := bpReset);
rtlAntriebDone( CLK := pgAntriebe[wgAuswahlAchsID].bpDone);
ftlHandPlusMinus( CLK := bpHandPlus OR bpHandMinus );

tonlErsterZyklus( IN := NOT Main.blErsterZyklus, PT := T#1S);

IF tonlErsterZyklus.Q THEN
  bInit := TRUE;
END_IF

IF bInit THEN // Initialisieren
  FOR i := 0 TO uiAchsenAnzahl DO
    astlAchseName[i] := pgAntriebe[i].slAchsname;
  END_FOR
  bInit := FALSE;
END_IF

IF NOT bgVisuAntriebeVerfahrenAktiv THEN
  RETURN; 
ELSE
	IF  pgAntriebe[wgAuswahlAchsID].wpBetriebsart = ABSOLUT  OR  
        pgAntriebe[wgAuswahlAchsID].wpBetriebsart = RELATIV OR  
        pgAntriebe[wgAuswahlAchsID].wpBetriebsart = HANDPLUS OR  
        pgAntriebe[wgAuswahlAchsID].wpBetriebsart = HANDMINUS OR 
        pgAntriebe[wgAuswahlAchsID].wpBetriebsart = RESTWEG OR 
        pgAntriebe[wgAuswahlAchsID].wpBetriebsart = SCHEIBENMESSUNG
    THEN
      pgAntriebe[wgAuswahlAchsID].rpBeschleunigung  := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxBeschleunigung;
      pgAntriebe[wgAuswahlAchsID].rpVerzoegerung    := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxVerzoegerung;
      pgAntriebe[wgAuswahlAchsID].rpRuckzeit        := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxRuckzeit;
      pgAntriebe[wgAuswahlAchsID].rpGeschwindigkeit := rgGeschwindigkeit;
	END_IF
END_IF

// Freigabe
pgAntriebe[wgAuswahlAchsID].bpFreigabeErzwingen := bpFreigabeSetzen;

// Freigabe beim Achwechsel zurück nehmen
IF ( bAchsIDTemp <> wgAuswahlAchsID ) THEN
  bpFreigabeSetzen := FALSE; 
  pgAntriebe[wgAuswahlAchsID].bpFreigabeErzwingen := FALSE;
  bAchsIDTemp := wgAuswahlAchsID; 
END_IF

// Referenz
IF rtlStartReferenz.Q 
  AND NOT pgAntriebe[wgAuswahlAchsID].bpMotionAktiv
  AND pgAntriebe[wgAuswahlAchsID].bpReglerBereit
  AND NOT pgAntriebe[wgAuswahlAchsID].bpAntrieblaeuft
THEN
  pgAntriebe[wgAuswahlAchsID].rpBeschleunigung  := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxBeschleunigung;
  pgAntriebe[wgAuswahlAchsID].rpVerzoegerung    := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxVerzoegerung;
  pgAntriebe[wgAuswahlAchsID].rpRuckzeit        := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxRuckzeit;
  pgAntriebe[wgAuswahlAchsID].rpGeschwindigkeit := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpReferenzGeschwindigkeit;
  pgAntriebe[wgAuswahlAchsID].rpZielPosition    := rgZielPos;
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;
END_IF

// Absolut verfahren
IF rtlStartAbsolut.Q 
  AND NOT pgAntriebe[wgAuswahlAchsID].bpMotionAktiv
  AND pgAntriebe[wgAuswahlAchsID].bpReglerBereit
  AND NOT pgAntriebe[wgAuswahlAchsID].bpAntrieblaeuft
THEN
  pgAntriebe[wgAuswahlAchsID].rpBeschleunigung  := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxBeschleunigung;
  pgAntriebe[wgAuswahlAchsID].rpVerzoegerung    := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxVerzoegerung;
  pgAntriebe[wgAuswahlAchsID].rpRuckzeit        := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxRuckzeit;
  pgAntriebe[wgAuswahlAchsID].rpGeschwindigkeit := rgGeschwindigkeit;
  pgAntriebe[wgAuswahlAchsID].rpZielPosition    := rgZielPos;
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart     := ABSOLUT;
END_IF

// Relativ verfahren
IF rtlStartRelativ.Q 
  AND NOT pgAntriebe[wgAuswahlAchsID].bpMotionAktiv
  AND pgAntriebe[wgAuswahlAchsID].bpReglerBereit
  AND NOT pgAntriebe[wgAuswahlAchsID].bpAntrieblaeuft
THEN
  pgAntriebe[wgAuswahlAchsID].rpBeschleunigung  := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxBeschleunigung;
  pgAntriebe[wgAuswahlAchsID].rpVerzoegerung    := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxVerzoegerung;
  pgAntriebe[wgAuswahlAchsID].rpRuckzeit        := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxRuckzeit;
  pgAntriebe[wgAuswahlAchsID].rpGeschwindigkeit := rgGeschwindigkeit;
  pgAntriebe[wgAuswahlAchsID].rpZielPosition    := rgZielPos;
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart     := RELATIV;
END_IF

// Restweg relativ
IF rtlStartRestweg.Q 
  AND NOT pgAntriebe[wgAuswahlAchsID].bpMotionAktiv
  AND pgAntriebe[wgAuswahlAchsID].bpReglerBereit
  AND NOT pgAntriebe[wgAuswahlAchsID].bpAntrieblaeuft
THEN
  pgAntriebe[wgAuswahlAchsID].rpBeschleunigung  := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxBeschleunigung;
  pgAntriebe[wgAuswahlAchsID].rpVerzoegerung    := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxVerzoegerung;
  pgAntriebe[wgAuswahlAchsID].rpRuckzeit        := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxRuckzeit;
  pgAntriebe[wgAuswahlAchsID].rpGeschwindigkeit := rgGeschwindigkeit;
  pgAntriebe[wgAuswahlAchsID].rpZielPosition    := rgZielPos;
  
  pgAntriebe[wgAuswahlAchsID].wpRestwegMode.0 := bpRestwegPositiv;
  pgAntriebe[wgAuswahlAchsID].wpRestwegMode.1 := bpRestwegNegativ;
  pgAntriebe[wgAuswahlAchsID].wpRestwegMode.2 := bpRestwegSensor1;
  pgAntriebe[wgAuswahlAchsID].wpRestwegMode.3 := bpRestwegSensor2;
  pgAntriebe[wgAuswahlAchsID].wpRestwegMode.4 := bpRestwegSteigendeFlanke AND NOT bpRestwegFallendeFlanke;
  pgAntriebe[wgAuswahlAchsID].wpRestwegMode.5 := bpRestwegSensor3;
  pgAntriebe[wgAuswahlAchsID].wpRestwegMode.6 := bpRestwegSensor4;
  pgAntriebe[wgAuswahlAchsID].wpRestwegMode.7 := FALSE; // bpRestwegSensor5
  
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart     := AntriebsBetriebsart_EN.RESTWEG;
END_IF

// Messung fahren
IF rtlStartMessung.Q 
  AND NOT pgAntriebe[wgAuswahlAchsID].bpMotionAktiv
  AND pgAntriebe[wgAuswahlAchsID].bpReglerBereit
  AND NOT pgAntriebe[wgAuswahlAchsID].bpAntrieblaeuft
THEN
  pgAntriebe[wgAuswahlAchsID].rpBeschleunigung  := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxBeschleunigung;
  pgAntriebe[wgAuswahlAchsID].rpVerzoegerung    := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxVerzoegerung;
  pgAntriebe[wgAuswahlAchsID].rpRuckzeit        := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxRuckzeit;
  pgAntriebe[wgAuswahlAchsID].rpGeschwindigkeit := rgGeschwindigkeit;
  pgAntriebe[wgAuswahlAchsID].eSensorAuswahl_Messung_1 := eSensoren.Sensor_1;
  pgAntriebe[wgAuswahlAchsID].eSensorAuswahl_Messung_2 := eSensoren.Sensor_2;
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart     := AntriebsBetriebsart_EN.SCHEIBENMESSUNG;
END_IF

// Master Slave Koppeln
IF rtlStartMasterSlave.Q 
  AND NOT pgAntriebe[wgAuswahlAchsID].bpMotionAktiv
  AND pgAntriebe[wgAuswahlAchsID].bpReglerBereit
  AND NOT pgAntriebe[wgAuswahlAchsID].bpAntrieblaeuft
THEN
  pgAntriebe[wgAuswahlAchsID].wpMaster          := wgMasterNummer;
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart     := AntriebsBetriebsart_EN.SYNC_AUF_MASTER;
END_IF

// Master Slave Invertiert Koppeln
IF rtlStartMasterSlaveInvertiert.Q 
  AND NOT pgAntriebe[wgAuswahlAchsID].bpMotionAktiv
  AND pgAntriebe[wgAuswahlAchsID].bpReglerBereit
  AND NOT pgAntriebe[wgAuswahlAchsID].bpAntrieblaeuft
THEN
  pgAntriebe[wgAuswahlAchsID].wpMaster          := wgMasterNummer;
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart     := AntriebsBetriebsart_EN.INVERTIERTER_SYNC_AUF_MASTER;
END_IF

// Hand plus
IF bpHandPlus
  AND NOT pgAntriebe[wgAuswahlAchsID].bpMotionAktiv
  AND pgAntriebe[wgAuswahlAchsID].bpReglerBereit
  AND NOT pgAntriebe[wgAuswahlAchsID].bpAntrieblaeuft
THEN
  pgAntriebe[wgAuswahlAchsID].rpBeschleunigung  := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxBeschleunigung;
  pgAntriebe[wgAuswahlAchsID].rpVerzoegerung    := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxVerzoegerung;
  pgAntriebe[wgAuswahlAchsID].rpRuckzeit        := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxRuckzeit;
  pgAntriebe[wgAuswahlAchsID].rpGeschwindigkeit := rgGeschwindigkeit;
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart     := HANDPLUS;
END_IF

// Hand plus
IF bpHandMinus
  AND NOT pgAntriebe[wgAuswahlAchsID].bpMotionAktiv
  AND pgAntriebe[wgAuswahlAchsID].bpReglerBereit
  AND NOT pgAntriebe[wgAuswahlAchsID].bpAntrieblaeuft
THEN
  pgAntriebe[wgAuswahlAchsID].rpBeschleunigung  := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxBeschleunigung;
  pgAntriebe[wgAuswahlAchsID].rpVerzoegerung    := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxVerzoegerung;
  pgAntriebe[wgAuswahlAchsID].rpRuckzeit        := pgAntriebe[wgAuswahlAchsID].ppAntriebsInformationen.rpMaxRuckzeit;
  pgAntriebe[wgAuswahlAchsID].rpGeschwindigkeit := rgGeschwindigkeit;
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart     := HANDMINUS;
END_IF

// Stopp oder fertig
IF  rtlStopp.Q 
 OR ( rtlAntriebDone.Q AND NOT ( pgAntriebe[wgAuswahlAchsID].wpBetriebsart = SYNC_AUF_MASTER OR pgAntriebe[wgAuswahlAchsID].wpBetriebsart = SCHEIBENMESSUNG OR pgAntriebe[wgAuswahlAchsID].wpBetriebsart = INVERTIERTER_SYNC_AUF_MASTER ) )
 OR ftlHandPlusMinus.Q 
THEN
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart := KEINE_FUNKTION;
END_IF

// Reset
IF rtlReset.Q THEN
  pgAntriebe[wgAuswahlAchsID].wpBetriebsart := AntriebsBetriebsart_EN.RESET;
END_IF
END_PROGRAM