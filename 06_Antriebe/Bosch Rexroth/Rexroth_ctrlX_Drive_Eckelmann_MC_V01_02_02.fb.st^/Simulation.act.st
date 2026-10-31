(* METADATA
{
	"v3Meta": {
		"objectGuid": "9748a137-ad7c-4c4d-81da-72983eb37826"
	}
}
*)
ACTION Simulation
(***************************************************************************************************)
(* AKTION: SIMULATION                                                                              *)
(*                                                                                                 *)
(* Simulationsmodus fuer den Rexroth-Antriebsbaustein (inkl. Scheibenmessung mit virtueller Laenge rgSimScheibenlaenge, Bremse loesen, Absolut setzen, Langsamfahrnocken).                                             *)
(* - Simuliert Achsbewegung (Istposition / Istgeschwindigkeit)                                     *)
(* - Simuliert Sensoren (Eingaenge Umrichter) inkl. Flankenerkennung                               *)
(* - Simuliert Statusbits (Done, laeuft, Richtungen, Sync, Limits)                                 *)
(* - Simuliert Restweg-Flankenlogik inkl. Suchfahrt und Zielpunkt                                  *)
(***************************************************************************************************)

IF NOT blSimulationAktivVorzyklus THEN
  blSimulationAktivVorzyklus := TRUE;
  tlSimLetzterZyklus := TIME();
  wlSimVorherigeBetriebsart := KEINE_FUNKTION;
  blSimRestwegSucheFlanke := FALSE;
  blSimRelativZielGueltig := FALSE;
  blSimIstReferenziert := TRUE;
  bpRestwegMaterialGefunden := FALSE;

  ablSimSensorAlt[eSensoren.Sensor_1] := FALSE;
  ablSimSensorAlt[eSensoren.Sensor_2] := FALSE;
  ablSimSensorAlt[eSensoren.Sensor_3] := FALSE;
  ablSimSensorAlt[eSensoren.Sensor_4] := FALSE;
  ablSimSensorAlt[eSensoren.Sensor_5] := FALSE;
  ablSimSensorAlt[eSensoren.Sensor_6] := FALSE;
  ablSimSensorAlt[eSensoren.Sensor_7] := FALSE;
  ablSimSensorAlt[eSensoren.Sensor_8] := FALSE;
  ablSimSensorAlt[eSensoren.Sensor_9] := FALSE;
END_IF

IF slAchsname = '' THEN
  slAchsname := CONCAT(TO_STRING(stStationsNummern.NummerSPS), CONCAT(': ', ppAntriebsInformationen.stTyp));
END_IF

// Zykluszeit
rlSimDeltaT := TO_REAL(TIME_TO_DWORD(TIME() - tlSimLetzterZyklus)) * REAL#0.001;
IF ( rlSimDeltaT <= REAL#0.0 ) OR ( rlSimDeltaT > REAL#0.25 ) THEN
  rlSimDeltaT := REAL#0.02;
END_IF
tlSimLetzterZyklus := TIME();

// Grundzustand
blFehlerAktiv := FALSE;
blInternerFehler := FALSE;
bpFehler := FALSE;
// bpMessungOk / bpMessungFehlerhaft / rpMessErgebnis bleiben wie im Echtbetrieb bis zum Betriebsartenwechsel gespeichert

// MK-Konfiguration wie im Echtbetrieb laden (Software-Endschalter, Maximalwerte, Achstyp)
MK_GetAxisConfiguration(ppAntriebsInformationen.wAchsID, ADR(l_ts_MKAxisConfig));

// Umrechnungsfaktoren wie im Echtbetrieb (rotativ / linear)
IF l_ts_MKAxisConfig.dwAxisFlags.0 THEN
  cFAKTOR_GESCHWINDIGKEIT := cFAKTOR_GESCHWINDIGKEIT_ROTATIV;
  cFAKTOR_RAMPEN := cFAKTOR_RAMPEN_ROTATIV;
  cFAKTOR_GESCHWINDIGKEIT_ECONSET := 0.16667;
ELSE
  cFAKTOR_GESCHWINDIGKEIT := cFAKTOR_GESCHWINDIGKEIT_LINEAR;
  cFAKTOR_RAMPEN := cFAKTOR_RAMPEN_LINEAR;
  cFAKTOR_GESCHWINDIGKEIT_ECONSET := 0.06;
END_IF

// Limits bestimmen (mit robustem Fallback)
rlSoftwareLimitMin := TO_REAL(l_ts_MKAxisConfig.lrSoftwareLimitNegative);
rlSoftwareLimitMax := TO_REAL(l_ts_MKAxisConfig.lrSoftwareLimitPositive);

IF ( rlSoftwareLimitMin = REAL#0.0 ) AND ( rlSoftwareLimitMax = REAL#0.0 ) THEN
  rlSoftwareLimitMin := -REAL#1000.0;
  rlSoftwareLimitMax := REAL#1000.0;
END_IF
IF rlSoftwareLimitMin >= rlSoftwareLimitMax THEN
  rlSoftwareLimitMin := -REAL#1000.0;
  rlSoftwareLimitMax := REAL#1000.0;
END_IF

rpMinPosition := rlSoftwareLimitMin;
rpMaxPosition := rlSoftwareLimitMax;

// Externe Endschalter-Eingrenzung identisch zur Echtlogik
IF rpMinSwEsEingrenzung <> REAL#0.0 THEN
  IF ( rlSoftwareLimitMin = REAL#0.0 ) OR ( rpMinSwEsEingrenzung >= rlSoftwareLimitMin ) THEN
    rpMinPosition := rpMinSwEsEingrenzung;
  END_IF
END_IF

IF rpMaxSwEsEingrenzung <> REAL#0.0 THEN
  IF ( rlSoftwareLimitMax = REAL#0.0 ) OR ( rpMaxSwEsEingrenzung <= rlSoftwareLimitMax ) THEN
    rpMaxPosition := rpMaxSwEsEingrenzung;
  END_IF
END_IF

IF rpMinPosition > rpMaxPosition THEN
  rpMinPosition := rlSoftwareLimitMin;
  rpMaxPosition := rlSoftwareLimitMax;
END_IF

blSoftwareLimitAktiv := ( rpMaxPosition > rpMinPosition );
rlSimWegbereich := rpMaxPosition - rpMinPosition;
IF rlSimWegbereich < REAL#50.0 THEN
  rlSimWegbereich := REAL#1000.0;
  rpMinPosition := -REAL#500.0;
  rpMaxPosition := REAL#500.0;
END_IF

// Virtuelle Sensorschwellen entlang des Fahrwegs
rlSimSensorPos1 := rpMinPosition + ( rlSimWegbereich * REAL#0.12 );
rlSimSensorPos4 := rpMinPosition + ( rlSimWegbereich * REAL#0.30 );
rlSimSensorPos5 := rpMinPosition + ( rlSimWegbereich * REAL#0.70 );
rlSimSensorPos2 := rpMinPosition + ( rlSimWegbereich * REAL#0.88 );
rlSimSensorFenster := MAX( REAL#5.0, rlSimWegbereich * REAL#0.03 );

// Fahrparameter wie in Pruefe_Inputs_Langsamfahrt bilden (im Simulationsmodus wird diese Aktion nicht aufgerufen)
// rlSimVelMax = konfigurierte Maximalgeschwindigkeit in Einheiten von rpGeschwindigkeit
rlSimVelMax := l_ts_MKAxisConfig.rVelocity / cFAKTOR_GESCHWINDIGKEIT_ECONSET;

rlGeschwindigkeit := MAX( rpGeschwindigkeit, REAL#0.0 );
IF ( rlSimVelMax > REAL#0.0 ) AND ( rlGeschwindigkeit > rlSimVelMax ) THEN
  rlGeschwindigkeit := rlSimVelMax;
END_IF

rlBeschleunigung := rpBeschleunigung;
IF ( l_ts_MKAxisConfig.rAcceleration > REAL#0.0 )
  AND ( ( rlBeschleunigung <= REAL#0.0 ) OR ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) > l_ts_MKAxisConfig.rAcceleration ) ) THEN
  rlBeschleunigung := l_ts_MKAxisConfig.rAcceleration / cFAKTOR_RAMPEN;
END_IF

rlVerzoegerung := rpVerzoegerung;
IF ( l_ts_MKAxisConfig.rDeceleration > REAL#0.0 )
  AND ( ( rlVerzoegerung <= REAL#0.0 ) OR ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) > l_ts_MKAxisConfig.rDeceleration ) ) THEN
  rlVerzoegerung := l_ts_MKAxisConfig.rDeceleration / cFAKTOR_RAMPEN;
END_IF

// Bewegungsparameter bestimmen
rlSimSollGeschwindigkeitAbs := ABS(rlGeschwindigkeit);
IF ( rlSimSollGeschwindigkeitAbs <= REAL#0.0 ) AND __ISVALIDREF(ppAntriebsInformationen) THEN
  rlSimSollGeschwindigkeitAbs := ABS(ppAntriebsInformationen.rpHandGeschwindigkeit);
END_IF
IF rlSimSollGeschwindigkeitAbs <= REAL#0.0 THEN
  rlSimSollGeschwindigkeitAbs := REAL#200.0;
END_IF

rlSimBeschleunigung := ABS(rlBeschleunigung);
IF ( rlSimBeschleunigung <= REAL#0.0 ) AND __ISVALIDREF(ppAntriebsInformationen) THEN
  rlSimBeschleunigung := ABS(ppAntriebsInformationen.rpMaxBeschleunigung);
END_IF
IF rlSimBeschleunigung <= REAL#0.0 THEN
  rlSimBeschleunigung := REAL#800.0;
END_IF

rlSimVerzoegerung := ABS(rlVerzoegerung);
IF ( rlSimVerzoegerung <= REAL#0.0 ) AND __ISVALIDREF(ppAntriebsInformationen) THEN
  rlSimVerzoegerung := ABS(ppAntriebsInformationen.rpMaxVerzoegerung);
END_IF
IF rlSimVerzoegerung <= REAL#0.0 THEN
  rlSimVerzoegerung := REAL#800.0;
END_IF

// Override wie im Echtbetrieb (MC_SetOverride wirkt nur auf die Geschwindigkeit)
IF IsBetweenLReal( rpOverride, 0, 100 ) THEN
  rlSimOverride := rpOverride / REAL#100.0;
ELSE
  rlSimOverride := REAL#1.0;
END_IF
rlSimSollGeschwindigkeitAbs := rlSimSollGeschwindigkeitAbs * rlSimOverride;

// Langsamfahrnocken wie in Pruefe_Inputs_Langsamfahrt (Nocken sind Low-aktiv: FALSE = Nocke belegt)
blNockeInFahrtrichtung := ( NOT udipEingaengeUmrichter.cXG31_2_I_2 AND ( eBewegungsrichtung = TE_Move_Direction.MD_NEGATIV_E ) )
  OR ( NOT udipEingaengeUmrichter.cXG31_1_I_1 AND ( eBewegungsrichtung = TE_Move_Direction.MD_POSITIV_E ) );
blEineLangsamfahrtnockeBelegt := NOT udipEingaengeUmrichter.cXG31_1_I_1 OR NOT udipEingaengeUmrichter.cXG31_2_I_2;

IF NOT bpAktiviereLangsamfahrtNocke OR ( rlGeschwindigkeit <= ( rlSimVelMax * REAL#0.1 ) ) THEN
  bpLangsamfahrenAktiv := FALSE;
ELSIF bpLangsamfahrenAktiv THEN
  bpLangsamfahrenAktiv := blNockeInFahrtrichtung
    OR ( ( eBewegungsrichtung = TE_Move_Direction.MD_STANDSTILL_E ) AND blEineLangsamfahrtnockeBelegt );
ELSE
  // Waehrend einer laufenden Verzoegerung keine neue Langsamfahrt starten
  bpLangsamfahrenAktiv := blNockeInFahrtrichtung AND NOT blSimVerzoegert;
END_IF

IF bpLangsamfahrenAktiv THEN
  // Wie im Echtbetrieb: Begrenzung auf 10 % der konfigurierten Maximalgeschwindigkeit
  IF rlSimVelMax > REAL#0.0 THEN
    rlSimSollGeschwindigkeitAbs := MIN( rlSimSollGeschwindigkeitAbs, rlSimVelMax * REAL#0.1 );
  ELSE
    rlSimSollGeschwindigkeitAbs := rlSimSollGeschwindigkeitAbs * REAL#0.1;
  END_IF
END_IF

// Betriebsartenwechsel erkennen
IF wlSimVorherigeBetriebsart <> wpBetriebsart THEN
  // Messergebnisse wie ResetStepsUndMcAktionen bei Betriebsartenwechsel loeschen
  bpMessungOk := FALSE;
  bpMessungFehlerhaft := FALSE;
  rpMessErgebnis := REAL#0.0;
  lrlMessErgebnis := 0;
  blSimMessAktiv := FALSE;
  blSimMessFertig := FALSE;
  rlSimMessWeg := REAL#0.0;
  IF wpBetriebsart = SCHEIBENMESSUNG THEN
    blSimMessAktiv := TRUE;
  END_IF

  bpDone := FALSE;
  blSimRelativZielGueltig := FALSE;

  CASE wpBetriebsart OF
    RESET:
      blSimIstReferenziert := TRUE;
      blSimRestwegSucheFlanke := FALSE;
      bpRestwegMaterialGefunden := FALSE;

    REFERENZ:
      rlSimZielPosition := rpMinPosition;
      blSimRelativZielGueltig := TRUE;
      blSimRestwegSucheFlanke := FALSE;

    ABSOLUT:
      rlSimZielPosition := rpZielposition;
      blSimRelativZielGueltig := TRUE;
      blSimRestwegSucheFlanke := FALSE;

    RELATIV:
      rlSimZielPosition := rpIstPosition + rpZielposition;
      blSimRelativZielGueltig := TRUE;
      blSimRestwegSucheFlanke := FALSE;

    RESTWEG:
      blSimRestwegSucheFlanke := TRUE;
      blSimRestwegPositiv := wpRestwegMode.0;
      blSimRestwegFlankeSteigend := wpRestwegMode.4;
      bpRestwegMaterialGefunden := FALSE;
      tonlSimRestwegFlankeTimeout( IN := FALSE );

    ELSE
      blSimRestwegSucheFlanke := FALSE;
      tonlSimRestwegFlankeTimeout( IN := FALSE );
  END_CASE
END_IF
wlSimVorherigeBetriebsart := wpBetriebsart;

// Kommandierte Geschwindigkeit bestimmen
rlSimSollGeschwindigkeit := REAL#0.0;
blSimIstPositionsmodus := FALSE;
blSimSyncAktiv := FALSE;

CASE wpBetriebsart OF

  KEINE_FUNKTION:
    rlSimSollGeschwindigkeit := REAL#0.0;
    bpDone := ABS(rpIstGeschwindigkeit) < REAL#0.5;

  RESET:
    rlSimSollGeschwindigkeit := REAL#0.0;
    bpDone := TRUE;

  REFERENZ:
    blSimIstPositionsmodus := TRUE;
    IF NOT blSimRelativZielGueltig THEN
      rlSimZielPosition := rpMinPosition;
      blSimRelativZielGueltig := TRUE;
    END_IF

  ABSOLUT:
    blSimIstPositionsmodus := TRUE;
    rlSimZielPosition := rpZielposition;
    blSimRelativZielGueltig := TRUE;

  RELATIV:
    blSimIstPositionsmodus := TRUE;
    IF NOT blSimRelativZielGueltig THEN
      rlSimZielPosition := rpIstPosition + rpZielposition;
      blSimRelativZielGueltig := TRUE;
    END_IF

  HANDPLUS:
    rlSimSollGeschwindigkeit := rlSimSollGeschwindigkeitAbs;
    bpDone := FALSE;

  HANDMINUS:
    rlSimSollGeschwindigkeit := -rlSimSollGeschwindigkeitAbs;
    bpDone := FALSE;

  SCHEIBENMESSUNG:
    // Wie im Echtbetrieb: Messfahrt immer in positive Richtung (bpDrehrichtungsumkehrMessung wirkt nur auf das Vorzeichen des Ergebnisses)
    IF blSimMessFertig THEN
      rlSimSollGeschwindigkeit := REAL#0.0;
      bpDone := TRUE;
    ELSE
      rlSimSollGeschwindigkeit := rlSimSollGeschwindigkeitAbs;
      bpDone := FALSE;
    END_IF

    SYNC_AUF_MASTER,
  INVERTIERTER_SYNC_AUF_MASTER:
    blSimSyncAktiv := TRUE;
    IF IsBetweenWORD(wpMaster, 0, 64) AND ( wpMaster <> ppAntriebsInformationen.wAchsID ) THEN
      rlSimZielPosition := pgAntriebe[TO_INT(wpMaster)].rpIstPosition;
      rlSimSollGeschwindigkeit := pgAntriebe[TO_INT(wpMaster)].rpIstGeschwindigkeit;
      bpDone := ( ABS( rlSimZielPosition - rpIstPosition ) <= REAL#1.0 );
    ELSE
      rlSimSollGeschwindigkeit := REAL#0.0;
      bpDone := FALSE;
    END_IF

  RESTWEG:
    IF blSimRestwegSucheFlanke THEN
      IF blSimRestwegPositiv THEN
        rlSimSollGeschwindigkeit := rlSimSollGeschwindigkeitAbs;
      ELSE
        rlSimSollGeschwindigkeit := -rlSimSollGeschwindigkeitAbs;
      END_IF
      bpDone := FALSE;
    ELSE
      blSimIstPositionsmodus := TRUE;
      IF NOT blSimRelativZielGueltig THEN
        rlSimZielPosition := rpIstPosition + rpZielposition;
        blSimRelativZielGueltig := TRUE;
      END_IF
    END_IF

  ELSE
    rlSimSollGeschwindigkeit := REAL#0.0;
END_CASE

// Positionsmodus mit Bremsweg-begrenzter Sollgeschwindigkeit
IF blSimIstPositionsmodus THEN
  IF blSoftwareLimitAktiv THEN
    rlSimZielPosition := MIN( MAX( rlSimZielPosition, rpMinPosition ), rpMaxPosition );
  END_IF

  rlSimDistanzZumZiel := rlSimZielPosition - rpIstPosition;

  IF ABS(rlSimDistanzZumZiel) <= REAL#0.5 THEN
    rlSimSollGeschwindigkeit := REAL#0.0;
    bpDone := TRUE;
  ELSE
    rlSimBremsweg := SQRT( 2.0 * rlSimVerzoegerung * ABS(rlSimDistanzZumZiel) );
    rlSimSollGeschwindigkeitAbs := MIN( rlSimSollGeschwindigkeitAbs, rlSimBremsweg );
    rlSimSollGeschwindigkeitAbs := MAX( rlSimSollGeschwindigkeitAbs, REAL#20.0 );

    IF rlSimDistanzZumZiel > REAL#0.0 THEN
      rlSimSollGeschwindigkeit := rlSimSollGeschwindigkeitAbs;
    ELSE
      rlSimSollGeschwindigkeit := -rlSimSollGeschwindigkeitAbs;
    END_IF
    bpDone := FALSE;
  END_IF
END_IF

// Beschleunigen / Verzoegern
blSimBeschleunigt := FALSE;
blSimVerzoegert := FALSE;
rlLetzteIstPosition := rpIstPosition;

IF rpIstGeschwindigkeit < rlSimSollGeschwindigkeit THEN
  rpIstGeschwindigkeit := rpIstGeschwindigkeit + ( rlSimBeschleunigung * rlSimDeltaT );
  IF rpIstGeschwindigkeit > rlSimSollGeschwindigkeit THEN
    rpIstGeschwindigkeit := rlSimSollGeschwindigkeit;
  END_IF
  blSimBeschleunigt := TRUE;
ELSIF rpIstGeschwindigkeit > rlSimSollGeschwindigkeit THEN
  rpIstGeschwindigkeit := rpIstGeschwindigkeit - ( rlSimVerzoegerung * rlSimDeltaT );
  IF rpIstGeschwindigkeit < rlSimSollGeschwindigkeit THEN
    rpIstGeschwindigkeit := rlSimSollGeschwindigkeit;
  END_IF
  blSimVerzoegert := TRUE;
END_IF

// Position integrieren
rpIstPosition := rpIstPosition + ( rpIstGeschwindigkeit * rlSimDeltaT );

// Harte Positionsgrenzen
IF blSoftwareLimitAktiv THEN
  IF rpIstPosition <= rpMinPosition THEN
    rpIstPosition := rpMinPosition;
    IF rpIstGeschwindigkeit < REAL#0.0 THEN
      rpIstGeschwindigkeit := REAL#0.0;
    END_IF
  ELSIF rpIstPosition >= rpMaxPosition THEN
    rpIstPosition := rpMaxPosition;
    IF rpIstGeschwindigkeit > REAL#0.0 THEN
      rpIstGeschwindigkeit := REAL#0.0;
    END_IF
  END_IF
END_IF

// Zielpunkt sauber einrasten lassen
IF blSimIstPositionsmodus THEN
  rlSimDistanzZumZiel := rlSimZielPosition - rpIstPosition;
  IF ( ABS(rlSimDistanzZumZiel) <= REAL#1.0 )
    OR ( ( rlSimZielPosition >= rlLetzteIstPosition ) AND ( rlSimZielPosition <= rpIstPosition ) )
    OR ( ( rlSimZielPosition <= rlLetzteIstPosition ) AND ( rlSimZielPosition >= rpIstPosition ) ) THEN
    rpIstPosition := rlSimZielPosition;
    rpIstGeschwindigkeit := REAL#0.0;
    bpDone := TRUE;

    IF wpBetriebsart = REFERENZ THEN
      blSimIstReferenziert := TRUE;
    END_IF
  END_IF
END_IF

// Virtuelle Sensorik aus Position ableiten und wie im Echtbetrieb ueber die Umrichter-Eingaenge fuehren
// (Sensor_1 = XG31_1, Sensor_2 = XG31_2, Sensor_3 = XG31_6, Sensor_4 = XG31_7, Sensor_5 = XG37_4)
IF bpAktiviereLangsamfahrtNocke THEN
  // Shuttle: XG31_1 / XG31_2 sind Langsamfahrnocken am positiven / negativen Wegende, Low-aktiv (FALSE = belegt)
  rlSimNockenBreite := MAX( REAL#50.0, rlSimWegbereich * REAL#0.05 );
  udipEingaengeUmrichter.cXG31_1_I_1 := NOT ( rpIstPosition >= ( rpMaxPosition - rlSimNockenBreite ) );
  udipEingaengeUmrichter.cXG31_2_I_2 := NOT ( rpIstPosition <= ( rpMinPosition + rlSimNockenBreite ) );
ELSE
  udipEingaengeUmrichter.cXG31_1_I_1 := ( ABS( rpIstPosition - rlSimSensorPos1 ) <= rlSimSensorFenster );
  udipEingaengeUmrichter.cXG31_2_I_2 := ( ABS( rpIstPosition - rlSimSensorPos2 ) <= rlSimSensorFenster );
END_IF
udipEingaengeUmrichter.cXG31_3_I_3 := TRUE;
udipEingaengeUmrichter.cXG31_6_I_4 := TRUE;
udipEingaengeUmrichter.cXG31_7_I_5 := ( ABS( rpIstPosition - rlSimSensorPos4 ) <= rlSimSensorFenster );
udipEingaengeUmrichter.cXG37_4_I_6 := ( ABS( rpIstPosition - rlSimSensorPos5 ) <= rlSimSensorFenster );

blSensoren[eSensoren.Sensor_1] := udipEingaengeUmrichter.cXG31_1_I_1;
blSensoren[eSensoren.Sensor_2] := udipEingaengeUmrichter.cXG31_2_I_2;
blSensoren[eSensoren.Sensor_3] := udipEingaengeUmrichter.cXG31_6_I_4;
blSensoren[eSensoren.Sensor_4] := udipEingaengeUmrichter.cXG31_7_I_5;
blSensoren[eSensoren.Sensor_5] := udipEingaengeUmrichter.cXG37_4_I_6;

// Sensorik vom Slave-gekoppelten Antrieb uebernehmen (wie im Echtbetrieb)
IF IsBetweenWORD( wpSlaveNr, 0, 64 ) AND ( wpSlaveNr <> ppAntriebsInformationen.wAchsID ) THEN
  blSensoren[eSensoren.Sensor_6] := pgAntriebe[wpSlaveNr].udipEingaengeUmrichter.cXG31_1_I_1;
  blSensoren[eSensoren.Sensor_7] := pgAntriebe[wpSlaveNr].udipEingaengeUmrichter.cXG31_2_I_2;
  blSensoren[eSensoren.Sensor_8] := pgAntriebe[wpSlaveNr].udipEingaengeUmrichter.cXG31_6_I_4;
  blSensoren[eSensoren.Sensor_9] := pgAntriebe[wpSlaveNr].udipEingaengeUmrichter.cXG31_7_I_5;
ELSE
  blSensoren[eSensoren.Sensor_6] := FALSE;
  blSensoren[eSensoren.Sensor_7] := FALSE;
  blSensoren[eSensoren.Sensor_8] := FALSE;
  blSensoren[eSensoren.Sensor_9] := FALSE;
END_IF

bRising[eSensoren.Sensor_1] := blSensoren[eSensoren.Sensor_1] AND NOT ablSimSensorAlt[eSensoren.Sensor_1];
bRising[eSensoren.Sensor_2] := blSensoren[eSensoren.Sensor_2] AND NOT ablSimSensorAlt[eSensoren.Sensor_2];
bRising[eSensoren.Sensor_3] := blSensoren[eSensoren.Sensor_3] AND NOT ablSimSensorAlt[eSensoren.Sensor_3];
bRising[eSensoren.Sensor_4] := blSensoren[eSensoren.Sensor_4] AND NOT ablSimSensorAlt[eSensoren.Sensor_4];
bRising[eSensoren.Sensor_5] := blSensoren[eSensoren.Sensor_5] AND NOT ablSimSensorAlt[eSensoren.Sensor_5];
bRising[eSensoren.Sensor_6] := blSensoren[eSensoren.Sensor_6] AND NOT ablSimSensorAlt[eSensoren.Sensor_6];
bRising[eSensoren.Sensor_7] := blSensoren[eSensoren.Sensor_7] AND NOT ablSimSensorAlt[eSensoren.Sensor_7];
bRising[eSensoren.Sensor_8] := blSensoren[eSensoren.Sensor_8] AND NOT ablSimSensorAlt[eSensoren.Sensor_8];
bRising[eSensoren.Sensor_9] := blSensoren[eSensoren.Sensor_9] AND NOT ablSimSensorAlt[eSensoren.Sensor_9];

bFalling[eSensoren.Sensor_1] := ( NOT blSensoren[eSensoren.Sensor_1] ) AND ablSimSensorAlt[eSensoren.Sensor_1];
bFalling[eSensoren.Sensor_2] := ( NOT blSensoren[eSensoren.Sensor_2] ) AND ablSimSensorAlt[eSensoren.Sensor_2];
bFalling[eSensoren.Sensor_3] := ( NOT blSensoren[eSensoren.Sensor_3] ) AND ablSimSensorAlt[eSensoren.Sensor_3];
bFalling[eSensoren.Sensor_4] := ( NOT blSensoren[eSensoren.Sensor_4] ) AND ablSimSensorAlt[eSensoren.Sensor_4];
bFalling[eSensoren.Sensor_5] := ( NOT blSensoren[eSensoren.Sensor_5] ) AND ablSimSensorAlt[eSensoren.Sensor_5];
bFalling[eSensoren.Sensor_6] := ( NOT blSensoren[eSensoren.Sensor_6] ) AND ablSimSensorAlt[eSensoren.Sensor_6];
bFalling[eSensoren.Sensor_7] := ( NOT blSensoren[eSensoren.Sensor_7] ) AND ablSimSensorAlt[eSensoren.Sensor_7];
bFalling[eSensoren.Sensor_8] := ( NOT blSensoren[eSensoren.Sensor_8] ) AND ablSimSensorAlt[eSensoren.Sensor_8];
bFalling[eSensoren.Sensor_9] := ( NOT blSensoren[eSensoren.Sensor_9] ) AND ablSimSensorAlt[eSensoren.Sensor_9];

ablSimSensorAlt[eSensoren.Sensor_1] := blSensoren[eSensoren.Sensor_1];
ablSimSensorAlt[eSensoren.Sensor_2] := blSensoren[eSensoren.Sensor_2];
ablSimSensorAlt[eSensoren.Sensor_3] := blSensoren[eSensoren.Sensor_3];
ablSimSensorAlt[eSensoren.Sensor_4] := blSensoren[eSensoren.Sensor_4];
ablSimSensorAlt[eSensoren.Sensor_5] := blSensoren[eSensoren.Sensor_5];
ablSimSensorAlt[eSensoren.Sensor_6] := blSensoren[eSensoren.Sensor_6];
ablSimSensorAlt[eSensoren.Sensor_7] := blSensoren[eSensoren.Sensor_7];
ablSimSensorAlt[eSensoren.Sensor_8] := blSensoren[eSensoren.Sensor_8];
ablSimSensorAlt[eSensoren.Sensor_9] := blSensoren[eSensoren.Sensor_9];

// Restweg: Flankensuche und Umschalten in Zielpunktfahrt
blSimRestwegFlankeGefunden := FALSE;
IF ( wpBetriebsart = RESTWEG ) AND blSimRestwegSucheFlanke THEN
  tonlSimRestwegFlankeTimeout( IN := TRUE, PT := T#30S );

  IF blSimRestwegFlankeSteigend THEN
    blSimRestwegFlankeGefunden := ( wpRestwegMode.2  AND bRising[eSensoren.Sensor_1] )
    OR ( wpRestwegMode.3  AND bRising[eSensoren.Sensor_2] )
    OR ( wpRestwegMode.5  AND bRising[eSensoren.Sensor_3] )
    OR ( wpRestwegMode.6  AND bRising[eSensoren.Sensor_4] )
    OR ( wpRestwegMode.7  AND bRising[eSensoren.Sensor_5] )
    OR ( wpRestwegMode.8  AND bRising[eSensoren.Sensor_6] )
    OR ( wpRestwegMode.9  AND bRising[eSensoren.Sensor_7] )
    OR ( wpRestwegMode.10 AND bRising[eSensoren.Sensor_8] )
    OR ( wpRestwegMode.11 AND bRising[eSensoren.Sensor_9] );
  ELSE
    blSimRestwegFlankeGefunden := ( wpRestwegMode.2  AND bFalling[eSensoren.Sensor_1] )
    OR ( wpRestwegMode.3  AND bFalling[eSensoren.Sensor_2] )
    OR ( wpRestwegMode.5  AND bFalling[eSensoren.Sensor_3] )
    OR ( wpRestwegMode.6  AND bFalling[eSensoren.Sensor_4] )
    OR ( wpRestwegMode.7  AND bFalling[eSensoren.Sensor_5] )
    OR ( wpRestwegMode.8  AND bFalling[eSensoren.Sensor_6] )
    OR ( wpRestwegMode.9  AND bFalling[eSensoren.Sensor_7] )
    OR ( wpRestwegMode.10 AND bFalling[eSensoren.Sensor_8] )
    OR ( wpRestwegMode.11 AND bFalling[eSensoren.Sensor_9] );
  END_IF

  IF blSimRestwegFlankeGefunden THEN
    blSimRestwegSucheFlanke := FALSE;
    bpRestwegMaterialGefunden := TRUE;
    lrlRestwegMesstasterGefunden := TO_LREAL(rpIstPosition);
    // Restwegmessung: Messung der virtuellen Scheibe beginnt an der ersten Flanke
    bpMessungOk := FALSE;
    rpMessErgebnis := REAL#0.0;
    lrlMessErgebnis := 0;
    rlSimMessWeg := REAL#0.0;
    blSimMessAktiv := TRUE;
    rlSimZielPosition := rpIstPosition + rpZielposition;
    blSimRelativZielGueltig := TRUE;
    tonlSimRestwegFlankeTimeout( IN := FALSE );
  ELSIF tonlSimRestwegFlankeTimeout.Q THEN
    bpFehler := TRUE;
    blFehlerAktiv := TRUE;
    blSimRestwegSucheFlanke := FALSE;
    tonlSimRestwegFlankeTimeout( IN := FALSE );
  END_IF
ELSE
  tonlSimRestwegFlankeTimeout( IN := FALSE );
END_IF

// Virtuelle Scheibenmessung: abgeschlossen, wenn die Achse seit Messstart die Strecke rgSimScheibenlaenge verfahren hat
IF blSimMessAktiv THEN
  rlSimMessWeg := rlSimMessWeg + ABS( rpIstPosition - rlLetzteIstPosition );

  IF wpBetriebsart = SCHEIBENMESSUNG THEN
    // Ergebnis der Messfahrt: von der Station vorgegeben (rpSimMessErgebnis, z.B. Scheibenmessung_FB) oder virtuelle Scheibenlaenge
    IF rpSimMessErgebnis <> REAL#0.0 THEN
      rlSimMessErgebnisVirt := rpSimMessErgebnis;
    ELSIF bpDrehrichtungsumkehrMessung THEN
      rlSimMessErgebnisVirt := rgSimScheibenlaenge;
    ELSE
      rlSimMessErgebnisVirt := -rgSimScheibenlaenge;
    END_IF
    IF rlSimMessWeg >= ABS( rlSimMessErgebnisVirt ) THEN
      rpMessErgebnis := rlSimMessErgebnisVirt;
      lrlMessErgebnis := TO_LREAL(rpMessErgebnis);
      bpMessungOk := TRUE;
      blSimMessAktiv := FALSE;
      blSimMessFertig := TRUE;
    ELSIF blSoftwareLimitAktiv AND ( rpIstPosition >= rpMaxPosition ) THEN
      // Wegende erreicht, bevor die Scheibe vollstaendig gemessen werden konnte
      bpMessungFehlerhaft := TRUE;
      blSimMessAktiv := FALSE;
      blSimMessFertig := TRUE;
    END_IF
  ELSIF wpBetriebsart = RESTWEG THEN
    IF rlSimMessWeg >= rgSimScheibenlaenge THEN
      rpMessErgebnis := rgSimScheibenlaenge;
      lrlMessErgebnis := TO_LREAL(rpMessErgebnis);
      bpMessungOk := TRUE;
      blSimMessAktiv := FALSE;
    END_IF
  ELSE
    blSimMessAktiv := FALSE;
  END_IF
END_IF

// Bremse loesen wie FUNKTION_Bremse_loesen: nur mit Freigabe, Rueckmeldung bpBremseGeloest (Statuswort Bit 15) verzoegert
IF bpBremseLoesen THEN
  IF ppAntriebsInformationen.stOptionen.bBremseLoesenFreigabe THEN
    blBremseLoesen := TRUE;
  ELSE
    blFehlerAktiv := TRUE; // Echtbetrieb: cKeineFreigabeZumBremseLoesen
  END_IF
ELSE
  blBremseLoesen := FALSE;
END_IF
tonlSimBremse( IN := blBremseLoesen, PT := T#300MS );
bpBremseGeloest := tonlSimBremse.Q;

// Absolut setzen wie FUNKTION_Absolut_setzen: Referenz abloeschen, dann an der aktuellen Position neu setzen
IF bpAbsolutSetzen THEN
  CASE asteplSchritt[ABSOLUT_SETZEN] OF
    STEP_0_E:
      bpAbsolutSetzenDone := FALSE;
      blSimIstReferenziert := FALSE;
      asteplSchritt[ABSOLUT_SETZEN] := STEP_10_E;

    STEP_10_E:
      blSimIstReferenziert := TRUE;
      asteplSchritt[ABSOLUT_SETZEN] := STEP_1000_E;

    STEP_1000_E:
      bpAbsolutSetzenDone := TRUE;
  END_CASE
ELSE
  bpAbsolutSetzenDone := FALSE;
  asteplSchritt[ABSOLUT_SETZEN] := STEP_0_E;
END_IF

// Statusausgaenge
bpAntriebFreigegeben := ( bpFreigabe OR bpFreigabeErzwingen ) AND NOT bpFreigabeEntziehenAnhalten;
bpReglerBereit := bpAntriebFreigegeben;
bpFehler := blFehlerAktiv;
bpMotionAktiv := ( ABS(rpIstGeschwindigkeit) > REAL#0.5 );
bpAntrieblaeuft := bpMotionAktiv;

IF rpIstGeschwindigkeit > REAL#0.5 THEN
  eBewegungsrichtung := TE_Move_Direction.MD_POSITIV_E;
ELSIF rpIstGeschwindigkeit < -REAL#0.5 THEN
  eBewegungsrichtung := TE_Move_Direction.MD_NEGATIV_E;
ELSE
  eBewegungsrichtung := TE_Move_Direction.MD_STANDSTILL_E;
END_IF

bpBewegungsrichtungPositiv := ( eBewegungsrichtung = TE_Move_Direction.MD_POSITIV_E );
bpBewegungsrichtungNegativ := ( eBewegungsrichtung = TE_Move_Direction.MD_NEGATIV_E );
bpKonstantfahrtAktiv := bpAntrieblaeuft AND NOT blSimBeschleunigt AND NOT blSimVerzoegert;
bpBeschleunigungAktiv := blSimBeschleunigt;
bpVerzoegerungAktiv := blSimVerzoegert;
bpIstReferenziert := blSimIstReferenziert;
bpMinSchalterBelegt := ( rpIstPosition <= rpMinPosition );
bpMaxSchalterBelegt := ( rpIstPosition >= rpMaxPosition );
bpHaupschalter400VEin := TRUE;
bpLS_150F02_230V := TRUE;
// bpLangsamfahrenAktiv wird oben (Langsamfahrnocken) bestimmt

IF blSimSyncAktiv AND IsBetweenWORD(wpMaster, 0, 64) THEN
  bpAchseSychron := ( ABS( pgAntriebe[TO_INT(wpMaster)].rpIstPosition - rpIstPosition ) <= REAL#2.0 )
  AND ( ABS( pgAntriebe[TO_INT(wpMaster)].rpIstGeschwindigkeit - rpIstGeschwindigkeit ) <= REAL#10.0 );
ELSE
  bpAchseSychron := FALSE;
END_IF

// Umrichter-Eingaenge werden oben bei der Sensorik gesetzt (kein Spiegeln mehr noetig)

wlAusgaengeUmrichter := wpAusgaengeUmrichter;
_Steuerwort();

wlAktiveBetriebsart := wpBetriebsart;
wlAngeforderteBetriebsart := wpBetriebsart;
END_ACTION