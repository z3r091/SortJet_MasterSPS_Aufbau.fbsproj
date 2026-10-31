(* METADATA
{
	"v3Meta": {
		"objectGuid": "408b9d1a-1641-4edf-bb35-4e7a7361d31c"
	}
}
*)
ACTION _Statusword
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Aktuellen Status vom Antrieb auslesen
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
Status();

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Ist-Position auslesen
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
Istposition();

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Ist-Geschwindigkeit auslesen
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
IstGeschwindigkeit();

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Hardware Endschalter auslesen
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Rueckmeldung auch bei Quelle SPS aus dem Signal-Statuswort (im Umrichter parametriert)
IF ppAntriebsInformationen.stOptionen.eEndschalterQuelle <> Endschalterquelle_EN.KEINE THEN
  bpMaxSchalterBelegt := i_ui_Signal_StatusWord.1;
  bpMinSchalterBelegt := i_ui_Signal_StatusWord.0;
ELSE
  bpMinSchalterBelegt := FALSE;
  bpMaxSchalterBelegt := FALSE;
END_IF

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Erkennung ob und in welche Richtung der Antrieb verfährt
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
FahrrichtungErkennung();

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Status-Bits aus Antrieb / Motion holen
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
IF l_mc_ReadStatus.ErrorStop THEN
  l_mc_ReadAxisError( Axis := ppAntriebsInformationen.wAchsID , Enable := TRUE );
  blReadAxisErrorAktiv := TRUE;
ELSIF blReadAxisErrorAktiv THEN
  l_mc_ReadAxisError( Axis := ppAntriebsInformationen.wAchsID , Enable := FALSE );
  blReadAxisErrorAktiv := FALSE;
END_IF

blFehlerAktiv   := (  i_ui_Cia402_StatusWord.3 // Achsfehler
  OR ( l_mc_ReadStatus.ErrorStop // MC Fehler
  AND l_mc_ReadAxisError.Valid
  AND NOT blFreigabeEntziehenAktiv ) // Aktiver Fehler aus MC_ReadAxisError
  OR blInternerFehler ); // Fehler im Antriebsbaustein

bpIstReferenziert  := i_ui_Signal_StatusWord.3;
bpAchseSychron     := l_mc_GearIn.InGear (* AND l_mc_ReadStatus.SynchronizedMotion *);
bpBremseGeloest    := i_ui_Signal_StatusWord.15;

blSensoren[eSensoren.Sensor_1] := udipEingaengeUmrichter.cXG31_1_I_1;
blSensoren[eSensoren.Sensor_2] := udipEingaengeUmrichter.cXG31_2_I_2;
blSensoren[eSensoren.Sensor_3] := udipEingaengeUmrichter.cXG31_6_I_4;
blSensoren[eSensoren.Sensor_4] := udipEingaengeUmrichter.cXG31_7_I_5;
blSensoren[eSensoren.Sensor_5] := udipEingaengeUmrichter.cXG37_4_I_6;

// Sensorik vom Slave-gekoppelten Antrieb übernehmen - ggf kann man
IF IsBetweenWORD(wpSlaveNr, 0, 64) AND ( wpSlaveNr <> ppAntriebsInformationen.wAchsID ) THEN
  blSensoren[eSensoren.Sensor_6] := pgAntriebe[wpSlaveNr].udipEingaengeUmrichter.cXG31_1_I_1; // Slave Einlauf
  blSensoren[eSensoren.Sensor_7] := pgAntriebe[wpSlaveNr].udipEingaengeUmrichter.cXG31_2_I_2; // Slave Auslauf
  blSensoren[eSensoren.Sensor_8] := pgAntriebe[wpSlaveNr].udipEingaengeUmrichter.cXG31_6_I_4; // Slave Einlauf Vorab
  blSensoren[eSensoren.Sensor_9] := pgAntriebe[wpSlaveNr].udipEingaengeUmrichter.cXG31_7_I_5; // Slave Auslauf Vorab
ELSE
  blSensoren[eSensoren.Sensor_6] := FALSE;
  blSensoren[eSensoren.Sensor_7] := FALSE;
  blSensoren[eSensoren.Sensor_8] := FALSE;
  blSensoren[eSensoren.Sensor_9] := FALSE;
END_IF

bpMotionAktiv := ( NOT l_mc_ReadStatus.StandStill ) (* OR l_mc_ReadStatus.Disabled *);

bpAntrieblaeuft            := ( eBewegungsrichtung <> TE_Move_Direction.MD_STANDSTILL_E );
bpBewegungsrichtungPositiv := ( eBewegungsrichtung = TE_Move_Direction.MD_POSITIV_E );
bpBewegungsrichtungNegativ := ( eBewegungsrichtung = TE_Move_Direction.MD_NEGATIV_E );

bpKonstantfahrtAktiv       := l_mc_ReadStatus.ConstantVelocity;
bpBeschleunigungAktiv      := l_mc_ReadStatus.Accelerating;
bpVerzoegerungAktiv        := l_mc_ReadStatus.Decelerating;

bpReglerBereit      := ( PowerSupplyStatus.15 AND PowerSupplyStatus.14 AND PowerSupplyStatus.6 AND PowerSupplyStatus.4 )
OR ( i_ui_Cia402_StatusWord.0 AND i_ui_Cia402_StatusWord.1 AND i_ui_Cia402_StatusWord.2 );

// Min- und Max-Position bestimmen
rlSoftwareLimitMin := TO_REAL(l_ts_MKAxisConfig.lrSoftwareLimitNegative);
rlSoftwareLimitMax := TO_REAL(l_ts_MKAxisConfig.lrSoftwareLimitPositive);
rpMinPosition := rlSoftwareLimitMin;
rpMaxPosition := rlSoftwareLimitMax;

// Externe Software-Endschalter koennen die MK-Grenzen nur weiter eingrenzen
// 0 bedeutet: kein zusaetzlicher externer Endschalter aktiv

// Min nur enger setzen, nie erweitern
IF rpMinSwEsEingrenzung <> 0 THEN
  IF ( rlSoftwareLimitMin = 0 ) OR ( rpMinSwEsEingrenzung >= rlSoftwareLimitMin ) THEN
    rpMinPosition := rpMinSwEsEingrenzung;
  END_IF
END_IF

// Max nur enger setzen, nie erweitern
IF rpMaxSwEsEingrenzung <> 0 THEN
  IF ( rlSoftwareLimitMax = 0 ) OR ( rpMaxSwEsEingrenzung <= rlSoftwareLimitMax ) THEN
    rpMaxPosition := rpMaxSwEsEingrenzung;
  END_IF
END_IF

// Widerspruch im Ergebnis (Min > Max):
// externe Eingrenzung komplett verwerfen und MK-Grenzen beibehalten
IF rpMinPosition > rpMaxPosition THEN
  rpMinPosition := rlSoftwareLimitMin;
  rpMaxPosition := rlSoftwareLimitMax;
END_IF

blSoftwareLimitAktiv := ( rpMinPosition <> 0 ) OR ( rpMaxPosition <> 0 );

bpAntriebFreigegeben := (     l_mc_Power.Enable
  AND l_mc_Power.Status );

rpPositionMesstaster1Positiv := TO_REAL(TO_LREAL(diTouchProbe1Pos) / l_ts_MKAxisConfig.lrIncrementsPerDistance * l_ts_MKAxisConfig.lrDistance);
rpPositionMesstaster1Negativ := TO_REAL(TO_LREAL(diTouchProbe1Neg) / l_ts_MKAxisConfig.lrIncrementsPerDistance * l_ts_MKAxisConfig.lrDistance);
rpPositionMesstaster2Positiv := TO_REAL(TO_LREAL(diTouchProbe2Pos) / l_ts_MKAxisConfig.lrIncrementsPerDistance * l_ts_MKAxisConfig.lrDistance);
rpPositionMesstaster2Negativ := TO_REAL(TO_LREAL(diTouchProbe2Neg) / l_ts_MKAxisConfig.lrIncrementsPerDistance * l_ts_MKAxisConfig.lrDistance);

bpHaupschalter400VEin := ppAntriebsInformationen.stOptionen.bVersorgungUeberXVR OR PowerSupplyStatus.4;

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Eingaenge vom Umrichter auslesen
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
bpLS_150F02_230V := ppAntriebsInformationen.stOptionen.bVersorgungUeberXVR OR udipEingaengeUmrichter.cXG31_3_I_3; // Eingang Leitungsschutzschalter 230V OK

// Ausgangssignale in diesem Normalzyklus uebernehmen, ins Steuerwort schreibt _Steuerwort
wlAusgaengeUmrichter := wpAusgaengeUmrichter;
END_ACTION