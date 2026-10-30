(* METADATA
{
	"v3Meta": {
		"objectGuid": "3cf7151a-d1e7-411b-8787-2152828f9434"
	}
}
*)
FUNCTION_BLOCK Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02

VAR_INPUT
  // BOOL
  bpFreigabe                          : BOOL;
  bpFreigabeErzwingen                 : BOOL;
  bpFreigabeEntziehenAnhalten         : BOOL;
  bpAktiviereLangsamfahrtNocke        : BOOL;
  bpDrehrichtungsumkehrMessung        : BOOL;
  bpAuswahlSensorVorabScheibenmessung : BOOL;
  bpBremseLoesen                      : BOOL;
  bpAbsolutSetzen                     : BOOL;

  // UINT / UDINT
  i_ui_Signal_StatusWord              : UINT;
  i_ui_Cia402_StatusWord              : UINT;
  PowerSupplyStatus                   : UINT;
  uiTouchProbeStatus                  : UINT;
  udipEingaengeUmrichter              : UDINT;

  // WORD / ENUM / STRUCT
  wpBetriebsart                       : AntriebsBetriebsart_EN;
  wpRestwegMode                       : Restwegmode_SEW_EN;
  wpAusgaengeUmrichter                : WORD;
  wpMaster                            : WORD;
  wpSlaveNr                           : WORD;
  eSensorAuswahl_Messung_1            : eSensoren;
  eSensorAuswahl_Messung_2            : eSensoren;
  stStationsNummern                   : Station_ST;

  // REAL
  rpGeschwindigkeit                   : REAL;
  rpBeschleunigung                    : REAL;
  rpVerzoegerung                      : REAL;
  rpRuckzeit                          : REAL;
  rpZielposition                      : REAL;
  rpRestweg                           : REAL;
  rpMinSwEsEingrenzung                : REAL; (* Externer zusaetzlicher Software-Endschalter MIN; 0 = inaktiv; darf den MK-MIN nur weiter eingrenzen *)
  rpMaxSwEsEingrenzung                : REAL; (* Externer zusaetzlicher Software-Endschalter MAX; 0 = inaktiv; darf den MK-MAX nur weiter eingrenzen *)
  rpPositionMesstaster1Positiv        : REAL;
  rpPositionMesstaster2Positiv        : REAL;
  rpPositionMesstaster1Negativ        : REAL;
  rpPositionMesstaster2Negativ        : REAL;
  rpOverride                          : REAL := 100;
  rpSimMessErgebnis                   : REAL; (* Nur Simulation: von der Station vorgegebenes Ergebnis der Scheibenmessung (Echtbetrieb: Laenge - Messstrecke); 0 = virtuelle Scheibenlaenge rgSimScheibenlaenge *)

  // POINTER
  ppAntriebsInformationen             : REFERENCE TO AntriebsInformationen;

END_VAR

VAR_OUTPUT
  // BOOL
  bpDone                              : BOOL;
  bpFehler                            : BOOL;
  bpMotionAktiv                       : BOOL;
  bpLS_150F02_230V                    : BOOL;
  bpReglerBereit                      : BOOL;
  bpAntrieblaeuft                     : BOOL;
  bpIstReferenziert                   : BOOL;
  bpAchseSychron                      : BOOL;
  bpMessungOk                         : BOOL;
  bpMessungFehlerhaft                 : BOOL;
  bpMinSchalterBelegt                 : BOOL;
  bpMaxSchalterBelegt                 : BOOL;
  bpBewegungsrichtungPositiv          : BOOL;
  bpBewegungsrichtungNegativ          : BOOL;
  bpAntriebFreigegeben                : BOOL;
  bpRestwegMaterialGefunden           : BOOL;
  bpHaupschalter400VEin               : BOOL;
  bpLangsamfahrenAktiv                : BOOL;
  bpBremseGeloest                     : BOOL;
  bpAbsolutSetzenDone                 : BOOL;

  // REAL
  rpIstPosition                       : REAL;
  rpIstGeschwindigkeit                : REAL;
  rpMessErgebnis                      : REAL;
  rpMinPosition                       : REAL;
  rpMaxPosition                       : REAL;
  rpStillstandsPosition               : REAL;

  // UINT
  SignalSteuerWort                    : UINT;

  // STRING
  slAchsname                          : STRING;

END_VAR

VAR
  // BOOL
  blErsterZyklus                         : BOOL := TRUE;
  blZweiterZyklus                        : BOOL;
  blNockeInFahrtrichtung                 : BOOL;
  blEineLangsamfahrtnockeBelegt          : BOOL;
  blFehlerAktiv                          : BOOL;
  blInternerFehler                       : BOOL;
  bpKonstantfahrtAktiv                   : BOOL;
  bpBeschleunigungAktiv                  : BOOL;
  bpVerzoegerungAktiv                    : BOOL;
  bRising                                : ARRAY[eSensoren.Sensor_1..eSensoren.Sensor_9] OF BOOL;
  bFalling                               : ARRAY[eSensoren.Sensor_1..eSensoren.Sensor_9] OF BOOL;
  blMesstaster1Gefunden                  : BOOL;
  blMesstaster2Gefunden                  : BOOL;
  blHelfer_RestwegMesung_Objekt_Gefunden : BOOL;
  blStopOhneReset                        : BOOL;
  blFreigabeEntziehenAktiv               : BOOL;
  blFreigabeEntziehenAktivVorzyklus      : BOOL;
  blFreigabeEntziehenPowerAus            : BOOL;
  blTouchprobeScheibenAktiv              : BOOL;
  blAchseInOP                            : BOOL;
  blAchseStoppen                         : BOOL;
  blAchseStoppenAktiv                    : BOOL;
  blReadAxisErrorAktiv                   : BOOL;
  blStillstandspositionBerechnen         : BOOL;
  blSoftwareLimitAktiv                   : BOOL;
  blSensoren                             : ARRAY[eSensoren.Sensor_1..eSensoren.Sensor_9] OF BOOL;
  blSensorenVorzyklus                    : ARRAY[eSensoren.Sensor_1..eSensoren.Sensor_9] OF BOOL;
  blSimulationAktivVorzyklus             : BOOL;
  blSimIstReferenziert                   : BOOL := TRUE;
  blSimRestwegSucheFlanke                : BOOL;
  blSimRestwegFlankeSteigend             : BOOL;
  blSimRestwegPositiv                    : BOOL;
  blSimRelativZielGueltig                : BOOL;
  blSimBeschleunigt                      : BOOL;
  blSimVerzoegert                        : BOOL;
  blSimIstPositionsmodus                 : BOOL;
  blSimSyncAktiv                         : BOOL;
  blSimRestwegFlankeGefunden             : BOOL;
  blS277PruefungNotwendig                : BOOL := TRUE;
  blCoeS277ReadExecute                   : BOOL;
  blCoeS277ReadGestartet                 : BOOL;
  ablSimSensorAlt                        : ARRAY[eSensoren.Sensor_1..eSensoren.Sensor_9] OF BOOL;

  // Jerk-Profil des laufenden Fahrbefehls; Ruecksetzen in ResetStepsUndMcAktionen.
  blRuckProfilInitialisiert             : BOOL; // Streckeneinteilung wurde bereits ausgefuehrt
  blRuckBremsphase                      : BOOL; // Konstantfahrt erreicht; Brems-Jerk bleibt ausgewaehlt
  blRuckKurzfahrt                       : BOOL; // Durchgehend den kleineren Jerk verwenden
  rlRuckBeschleunigung                  : REAL; // Jerk aus Beschleunigung / wirksamer Ruckzeit
  rlRuckVerzoegerung                    : REAL; // Jerk aus Verzoegerung / wirksamer Ruckzeit
  rlRuckStop                            : REAL; // Bei Stop-Beginn gewaehlt, bis Stop-Ende festgehalten
  rlRuckzeitSek                         : REAL; // Wirksame Ruckzeit nach EConSet-Begrenzung [s]

  // REAL
  rlLetzteIstPosition                 : REAL;
  rlDistanzSeitLetzterPosition        : REAL;
  rlZielPosition                      : REAL;
  rlGeschwindigkeit                   : REAL;
  rlBeschleunigung                    : REAL;
  rlVerzoegerung                      : REAL;
  rlRuckzeit                          : REAL; // Ausgewaehlter Jerk fuer die MC-Fahrbausteine
  rlSoftwareLimitMin                  : REAL;
  rlSoftwareLimitMax                  : REAL;
  rlMerkerOverride                    : REAL;
  cFAKTOR_GESCHWINDIGKEIT             : REAL := 0;
  cFAKTOR_RAMPEN                      : REAL := 0;
  cFAKTOR_GESCHWINDIGKEIT_ECONSET     : REAL := 0;
  rlSimDeltaT                         : REAL;
  rlSimSollGeschwindigkeit            : REAL;
  rlSimSollGeschwindigkeitAbs         : REAL;
  rlSimBeschleunigung                 : REAL;
  rlSimVerzoegerung                   : REAL;
  rlSimZielPosition                   : REAL;
  rlSimWegbereich                     : REAL;
  rlSimSensorPos1                     : REAL;
  rlSimSensorPos2                     : REAL;
  rlSimSensorPos4                     : REAL;
  rlSimSensorPos5                     : REAL;
  rlSimSensorFenster                  : REAL;
  rlSimBremsweg                       : REAL;
  rlSimDistanzZumZiel                 : REAL;
  rlSimVelMax                         : REAL;
  rlSimOverride                       : REAL;
  rlSimMessWeg                        : REAL;
  rlSimMessErgebnisVirt               : REAL;
  rlSimNockenBreite                   : REAL;
  blSimMessAktiv                      : BOOL;
  blSimMessFertig                     : BOOL;
  tonlSimBremse                       : TON;

  // LREAL
  lrlMessErgebnis                     : LREAL;
  lrlMessenPositionSensor1            : LREAL;
  lrlMessenPositionSensor2            : LREAL;
  lrlRestwegMesstasterGefunden        : LREAL;
  lrlRestwegMessungMesstasterGefunden : LREAL;

  // DINT
  diTouchProbe1Pos                    : DINT;
  diTouchProbe1Neg                    : DINT;
  diTouchProbe2Pos                    : DINT;
  diTouchProbe2Neg                    : DINT;

  // WORD / UDINT
  wlFehlerVonMotionFunktion           : WORD;
  wlError                             : WORD;
  wlAktiveBetriebsart                 : AntriebsBetriebsart_EN;
  wlAngeforderteBetriebsart           : AntriebsBetriebsart_EN;
  udiErrorFromECat                    : UDINT;
  uilSchreibeUeberCoe                 : UINT;
  uilSchreibeUeberCoeTouchProbe       : UINT;
  awlFehlerinformationen              : ARRAY [0..25] OF WORD;
  wlSchrittkette                      : AntriebsBetriebsart_EN;
  eAchsStatus                         : eAchsStatus_EN;
  wlSimVorherigeBetriebsart           : AntriebsBetriebsart_EN;
  wlFlankenerkennung                  : WORD;
  udiEncoderProperties                : UDINT;

  // TIMER
  tonlAuswertungBewegungsrichtung     : TON;
  tonlHardwareFreigabe                : TON;
  tonlSoftwareFreigabe                : TON;
  tonlFehlermeldungAusgeben           : TON;
  tonlMaxZeitStatusUngueltig          : TON;
  tonlAchseInOP                       : TON;
  tonlTouchprobeNeustart              : TON;
  tonlSimRestwegFlankeTimeout         : TON;

  // R_TRIG
  rtl_Fehlermeldung                   : R_TRIG;
  rtlStop                             : R_TRIG;
  rtlECatStatusOK                     : R_TRIG;

  // ENUM
  eBewegungsrichtung                  : TE_Move_Direction;

  // TIME
  tlSimLetzterZyklus                  : TIME;

  // STRUCT
  Antriebsfehler                      : ctrlX_FEHLER;
  Diagnose                            : Rexroth_Fehler;
  asteplSchritt                       : ARRAY[KEINE_FUNKTION..ABSOLUT_SETZEN] OF Steps_TE;

  // MC-Bausteine / FBs
  l_ts_MKAxisConfig                   : MK_Axis_Config_TR;
  l_mc_ReadStatus                     : MC_ReadStatus;
  l_mc_ReadActualPosition             : MC_ReadActualPosition;
  l_mc_ReadActualVelocity             : MC_ReadActualVelocity;
  l_mc_ReadAxisError                  : MC_ReadAxiserror;
  l_mc_Power                          : MC_Power;
  l_mc_Reset                          : MC_Reset;
  l_mc_Stop                           : MC_Stop;
  l_mc_GearIn                         : MC_GearIn;
  l_mc_MoveVelocity                   : MC_MoveVelocity;
  l_mc_Home                           : MC_Home;
  l_mc_MoveAbsolute                   : MC_MoveAbsolute;
  l_mc_Override                       : MC_SetOverride;
  l_fb_CoeLesen                       : CoeReadObject;
  l_fb_CoeTouchProbeSchreiben         : CoeWriteObject;
  l_fb_CoeSchreiben                   : CoeWriteObject;
  l_fb_CoeS277Lesen                   : CoeReadObject;

END_VAR


VAR CONSTANT

  // TIME
  cTIME_HARDWARE_FREIGABE                : TIME := T#10S;
  cTIME_TOUCHPROBE_NEUSTART              : TIME := T#3S;

  // REAL
  cFAKTOR_GESCHWINDIGKEIT_LINEAR         : REAL := 60;
  cFAKTOR_RAMPEN_LINEAR                  : REAL := 0.001;
  cFAKTOR_GESCHWINDIGKEIT_ROTATIV        : REAL := 0.16666666666666666666666666666667;
  cFAKTOR_RAMPEN_ROTATIV                 : REAL := 0.002777;

END_VAR
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// ERKLÄRUNG VERSIONIERUNG:
//
// Bei JEDER Änderung, MUSS die Version angepasst werden, damit Änderungen nachvollziehbar sind!
// JEDE Änderung muss in der Aktion A_Changelog dokumentiert werden!
//
// Die Version V01_00_00 ist in 3 Bereiche aufgegliedert:
//
// Bereich 1: VXX = Hauptversion
//            Wird erhöht, bei groben konzeptionellen Änderungen oder
//            bei Änderungen die inkompatibel zu Vorgängerversionen sind
//
// Bereich 2: _YY
//            Wird erhöht, bei neuen Funktionen im Baustein, die in der Vorgängerversion nicht vorhanden waren.
//
// Bereich 3: _ZZ
//            Wird erhöht, bei kleineren Änderungen die keinen oder nur sehr geringen Einfluss haben,
//            oder bei reinen Code-Optimierungen.
//
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

IF NOT __ISVALIDREF(ppAntriebsInformationen) OR stStationsNummern.NummerSPS = 0 THEN
  Defaults();
  RETURN;
END_IF
IF ppAntriebsInformationen.wAchsID = 65 THEN
  Defaults();
  bpFehler := FALSE;
  bpDone := TRUE;
  RETURN;
END_IF

IF bgSPS_SIMULATION THEN
  Simulation();
  RETURN;
ELSE
  blSimulationAktivVorzyklus := FALSE;
END_IF

IF blErsterZyklus OR blZweiterZyklus THEN
  IF blErsterZyklus THEN
    blErsterZyklus := FALSE;
    blZweiterZyklus := TRUE;
  ELSE
    blZweiterZyklus := FALSE;
    MK_GetAxisConfiguration(ppAntriebsInformationen.wAchsID, ADR(l_ts_MKAxisConfig));
  END_IF
  RETURN;
END_IF
IF slAchsname = '' THEN
  slAchsname := CONCAT(TO_STRING(stStationsNummern.NummerSPS), CONCAT(': ', ppAntriebsInformationen.stTyp));
END_IF

// Ist die Achse nicht in OP, Ausführung des FBs abbrechen...
blAchseInOP := (EC_EsmGetNodeState(1000 + l_ts_MKAxisConfig.uiDeviceAddress) = EC_NODE_STATE_OP);
tonlAchseInOP(IN := blAchseInOP, PT := T#5S);
rtlECatStatusOK(CLK := tonlAchseInOP.Q);

// Achse ist nicht in OP - Antriebsbaustein darf nicht ausgeführt werden
IF NOT tonlAchseInOP.Q THEN
  Defaults();
  RETURN;
END_IF

// Wenn Achse OP dann die MKs von PLC nochmals neu herunterladen (Um Änderung im E°ConSet abzurufen)
IF rtlECatStatusOK.Q THEN
  MK_GetAxisConfiguration(ppAntriebsInformationen.wAchsID, ADR(l_ts_MKAxisConfig));
END_IF;

// Touchprobe Funktion am Umrichter starten via CoE Write ; Reset wenn Funktion aktiv
IF NOT uiTouchProbeStatus.0 THEN
  StarteTouchprobeFunktion();
ELSIF blTouchprobeScheibenAktiv OR l_fb_CoeTouchProbeSchreiben.o_b_Busy THEN
  blTouchprobeScheibenAktiv := FALSE;
  l_fb_CoeTouchProbeSchreiben( i_b_Execute := FALSE, i_b_Reset := TRUE );
  tonlTouchprobeNeustart( IN := FALSE );
END_IF

// Pruefen ob S277 Bit 11 auf 1 gesetzt wurde (Wichtig für Firmware 0612 beim referenzieren)
IF blS277PruefungNotwendig AND Job.tonlMmiOk.Q THEN
  PruefeFirmwareReferenzBit();
ELSE
  l_fb_CoeS277Lesen( i_b_Execute   := FALSE );
END_IF

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Umrechnungsfaktoren bestimmen, ob rotativ oder linear
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
IF l_ts_MKAxisConfig.dwAxisFlags.0 THEN // ROTATIV
  cFAKTOR_GESCHWINDIGKEIT := cFAKTOR_GESCHWINDIGKEIT_ROTATIV;
  cFAKTOR_RAMPEN := cFAKTOR_RAMPEN_ROTATIV;
  cFAKTOR_GESCHWINDIGKEIT_ECONSET := 0.16667;
ELSE // LINEAR
  cFAKTOR_GESCHWINDIGKEIT := cFAKTOR_GESCHWINDIGKEIT_LINEAR;
  cFAKTOR_RAMPEN := cFAKTOR_RAMPEN_LINEAR;
  cFAKTOR_GESCHWINDIGKEIT_ECONSET := 0.06;
END_IF

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Freigabe
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
blFreigabeEntziehenAktiv := bpFreigabeEntziehenAnhalten;

l_mc_Power
(
  Axis   := ppAntriebsInformationen.wAchsID,
  Enable := ( bpFreigabe OR bpFreigabeErzwingen OR ( blFreigabeEntziehenAktiv AND NOT blFreigabeEntziehenPowerAus ) )
);

// Stati und Fehler vom Antrieb holen ; globale Trigger und Timer ausführen
Pruefe_Inputs_Langsamfahrt();
_Statusword();
TimerTrigger();
blStillstandspositionBerechnen := blSoftwareLimitAktiv
AND ( ( wlAktiveBetriebsart = HANDPLUS )
  OR ( wlAktiveBetriebsart = HANDMINUS )
  OR ( wlAktiveBetriebsart = RESTWEG ) );

IF blStillstandspositionBerechnen THEN
  Stillstandsposition();
ELSE
  rpStillstandsPosition := rpIstPosition;
END_IF

// Freigabeentzug mit Anhalten:
// - aktiven Ablauf nicht resetten (Automatik soll nach Freigabe wieder ohne externen Trigger weiterlaufen)
// - erst anhalten, dann Power wegnehmen
FreigabeEntziehen_Wiederanlauf();

blFreigabeEntziehenAktivVorzyklus := blFreigabeEntziehenAktiv;

IF blFehlerAktiv THEN
  _Fehlerauswertung();
ELSE
  bpFehler := blFehlerAktiv;
END_IF

// STATE MACHINE - Erlaubte Zustände: https://docs.automation.boschrexroth.com/doc/359516816/achsobjekte/latest/de/
wlAngeforderteBetriebsart := wpBetriebsart;

IF NOT l_mc_ReadStatus.Valid THEN
  eAchsStatus := AXIS_UNKNOWN;
ELSIF l_mc_ReadStatus.Stopping THEN
  eAchsStatus := AXIS_STOPPING;
ELSIF l_mc_ReadStatus.Errorstop OR l_mc_ReadStatus.Disabled THEN
  eAchsStatus := AXIS_ERROR_OR_DISABLED;
ELSIF l_mc_ReadStatus.Valid THEN
  eAchsStatus := AXIS_VALID;
ELSE
  eAchsStatus := AXIS_UNKNOWN;
END_IF

// CASE FÜR STATE MACHINE
CASE eAchsStatus OF

  // Achse ist am anhalten - Nichts anderes erlaubt außer das MC_Stop.Execute auf false zu setzen und das anhalten zu beenden;
  // Automatisches zurücksetzen von MC_Stop.Execute wenn Antrieb angehalten ist
  AXIS_STOPPING:
    IF NOT bpAntrieblaeuft AND ( ( l_ts_MKAxisConfig.dwAxisFlags.0 AND rpIstGeschwindigkeit < 0.01 ) OR // Rotativ
        ( NOT l_ts_MKAxisConfig.dwAxisFlags.0 AND rpIstGeschwindigkeit < 1 ) ) // Linear
    THEN
      blAchseStoppen := FALSE;
      IF NOT blFreigabeEntziehenAktiv THEN
        blStopOhneReset := FALSE;
      END_IF
    END_IF

    // Achse ist im ErrorStop (Fehlerzustand) oder ist nicht in Reglung (MC_Power nicht aktiv)
    // In diesem Zustand ist ausschließlich der Reset erlaubt
  AXIS_ERROR_OR_DISABLED:
    blAchseStoppen := FALSE; // Achse nicht mehr am Stoppen oder am Error-Stoppen - manuelles Stoppen kann beendet werden
    IF NOT bpAntrieblaeuft THEN // Reset nur wenn der Antrieb zum Stillstand gekommen ist
      IF wlAngeforderteBetriebsart = RESET THEN // Im Errorstop nur Reset erlauben
        BETRIEBSART_Reset();
      ELSE // Ist der Reset nicht angesteuert, dann alles daraus zurücksetzen
        l_mc_Reset.Execute := FALSE;
        bpDone := FALSE;
        l_fb_CoeSchreiben.i_b_Execute := FALSE;
        asteplSchritt[RESET] := STEP_0_E;
      END_IF
    END_IF

    FUNKTION_Bremse_loesen();
    FUNKTION_Absolut_setzen();

    // Achse ist in einem unbekannten Zustand von der MC
    // Wenn dieser Zustand für min. 1 Sekunde ansteht, Achse stoppen!
  AXIS_UNKNOWN:
    tonlMaxZeitStatusUngueltig( IN := NOT l_mc_ReadStatus.Valid , PT := T#1S );
    IF tonlMaxZeitStatusUngueltig.Q THEN
      ResetStepsUndMcAktionen();
      blAchseStoppen := TRUE;
    END_IF

    // Achse ist in einem gültigen Zustand und darf Kommandos abarbeiten
  AXIS_VALID:
    IF blFreigabeEntziehenAktiv THEN
      bpDone := FALSE;
    ELSE
      // Alles resetten wenn Achse angehalten ist und eine Betriebsart aktiv ist UND die Betriebsart gewechselt werden soll
      IF l_mc_ReadStatus.StandStill AND ( ( wlAktiveBetriebsart <> KEINE_FUNKTION ) AND ( wlAktiveBetriebsart <> wlAngeforderteBetriebsart ) ) THEN
        ResetStepsUndMcAktionen();
        bpDone := FALSE;
        asteplSchritt[wlAktiveBetriebsart] := STEP_0_E;
        wlAktiveBetriebsart := KEINE_FUNKTION;
      END_IF

      // Achse anhalten, wenn eine Betriebsart aktiv ist UND die angeforderte Betriebsart sich von der aktiven Unterscheidet UND die Achse nicht im Stanadstill ist
      IF ( wlAktiveBetriebsart <> KEINE_FUNKTION ) AND ( wlAngeforderteBetriebsart <> wlAktiveBetriebsart ) AND NOT l_mc_ReadStatus.StandStill THEN
        ResetStepsUndMcAktionen();
        asteplSchritt[wlAktiveBetriebsart] := STEP_0_E;
        bpDone := FALSE;
        blAchseStoppen := TRUE;
      END_IF

      // Änderung der aktiven Betriebsart auf die angeforderte nur wenn die aktive Betriebsart auf keine Funktion steht
      // Beide Schrittketten vorher zurücksetzen
      IF wlAktiveBetriebsart = KEINE_FUNKTION THEN
        ResetStepsUndMcAktionen();
        wlAktiveBetriebsart := wlAngeforderteBetriebsart;
      END_IF

      // Aktive Betriebsart wurde gesetzt und wird hiermit ausgeführt
      CASE wlAktiveBetriebsart OF

        KEINE_FUNKTION:
          FUNKTION_Bremse_loesen();

        RESET:
          BETRIEBSART_Reset();

        REFERENZ:
          BETRIEBSART_Referenz();

        HANDPLUS:
          BETRIEBSART_Handplus();

        HANDMINUS:
          BETRIEBSART_Handminus();

        ABSOLUT:
          BETRIEBSART_Absolut();

        RELATIV:
          BETRIEBSART_Relativ();

        SCHEIBENMESSUNG:
          BETRIEBSART_Messung();

          INVERTIERTER_SYNC_AUF_MASTER,
        SYNC_AUF_MASTER:
          wlSchrittkette := wlAktiveBetriebsart;
          BETRIEBSART_MasterSlave();

        RESTWEG:
          BETRIEBSART_Restweg_Mit_Messung();

        ELSE
          // Unbekannte Betriebsart - Achse stoppen und Fehler auslösen
          ResetStepsUndMcAktionen();
          blAchseStoppen := TRUE;
          blInternerFehler := TRUE;
          Antriebsfehler.wlBausteinFehlerNr := cBetriebsartUnbekannt;
      END_CASE
    END_IF

END_CASE

// ============================================
// Override
// ============================================
IF IsBetweenLReal(rpOverride, 0, 100) THEN
  rlMerkerOverride := rpOverride;
ELSE
  rlMerkerOverride := 100;
END_IF

// Langsamfahrt auf 10 % der konfigurierten Maximalgeschwindigkeit begrenzen.
// Ein kleinerer externer Override bleibt wirksam.
IF bpLangsamfahrenAktiv AND rlGeschwindigkeit > 0 THEN
  rlMerkerOverride := MIN(rlMerkerOverride,
    (l_ts_MKAxisConfig.rVelocity / cFAKTOR_GESCHWINDIGKEIT_ECONSET)
    * 10 / rlGeschwindigkeit);
END_IF

l_mc_Override(
  Enable := TRUE,
  VelFactor := rlMerkerOverride / 100,
  AccFactor := 1,
  JerkFactor := 1,
  Axis := ppAntriebsInformationen.wAchsID
);

// ============================================
// Stop-Verwaltung
// ============================================

StopVerwaltung();

// Reset aller Schrittketten, wenn Stop aktiv ohne Sonderfall
rtlStop(CLK := blAchseStoppenAktiv AND NOT blStopOhneReset);
IF rtlStop.Q THEN
  ResetStepsUndMcAktionen();
END_IF;
END_FUNCTION_BLOCK