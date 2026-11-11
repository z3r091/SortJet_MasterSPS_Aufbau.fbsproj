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
  bpBremseLoesen   : BOOL; // Schalter: Bremse loesen, solange gesetzt
  bpAbsolutSetzen  : BOOL; // Taster: Absolutwert setzen starten (laeuft bis Done, Stopp oder Reset)
  bpAchseVor       : BOOL; // Taster: naechste vorhandene Achse
  bpAchseZurueck   : BOOL; // Taster: vorherige vorhandene Achse
  bpAuswahlOeffnen    : BOOL; // Taster: Auswahlfenster der Achsen oeffnen / schliessen
  bpAuswahlSchliessen : BOOL; // Taster: Tippen neben die Liste schliesst das Auswahlfenster
  abAuswahlTaster     : ARRAY[0..65] OF BOOL; // Taster je Listenplatz im Auswahlfenster

  bpRestwegPositiv         : BOOL;
  bpRestwegNegativ         : BOOL;
  bpRestwegSteigendeFlanke : BOOL;
  bpRestwegFallendeFlanke  : BOOL;
  bpRestwegSensor1         : BOOL;
  bpRestwegSensor2         : BOOL;
  bpRestwegSensor3         : BOOL;
  bpRestwegSensor4         : BOOL;

  bpDrehrichtungsumkehrMessung : BOOL; // Scheibenmessung in Gegenrichtung (Sensor 2 vor Sensor 1)
  bpSensorVorabMessung         : BOOL; // Scheibenmessung mit dem Vorab-Sensor

  bpOverrideAktiv  : BOOL; // Schalter: Visu-Override fuer die gewaehlte Achse uebernehmen
  bpOverrideMinus  : BOOL; // Taster: Override - 5 %
  bpOverridePlus   : BOOL; // Taster: Override + 5 %
  abOverrideStufe  : ARRAY[1..10] OF BOOL; // Taster der Override-Leiste: 10 ... 100 %

  // WORD
  bAchsIDTemp      : WORD;
  wpSensorMessung1 : WORD := 1; // Sensor 1..9 fuer die Scheibenmessung
  wpSensorMessung2 : WORD := 2;

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
  rtlAbsolutSetzen  : R_TRIG;
  rtlAchseVor       : R_TRIG;
  rtlAchseZurueck   : R_TRIG;
  rtlOverrideMinus  : R_TRIG;
  rtlOverridePlus   : R_TRIG;
  rtlAuswahlOeffnen : R_TRIG;
  ftlVisuAktiv      : F_TRIG;

  ftlHandPlusMinus  : f_trig;

  // BOOL
  blAbsolutSetzenAktiv : BOOL;
  blFreigeben          : BOOL; // Bits der zuletzt bedienten Achse zuruecknehmen

  // INT
  i : UINT;
  wlSuche : WORD;
  wlAchse : WORD; // zuletzt bediente Achse
END_VAR

VAR_OUTPUT
  // Override aus der Visu: nur wirksam, wenn die Bedienung aktiv ist und der Override ausdruecklich uebernommen wurde
  bpOverrideWirksam : BOOL;
  rpOverrideVisu    : REAL := 100.0; // [%]
END_VAR

VAR
  // ----------------------------------------------------------------------------------------------
  // VISU "Antriebe_Verfahren" (Aktion A_VisuDaten)
  // ----------------------------------------------------------------------------------------------
  stlAchse     : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;
  blRotativ    : BOOL;
  sEinheitPos  : STRING(12);
  sEinheitGeschw : STRING(12);
  sEinheitBeschl : STRING(12);
  sAchsKopf    : STRING(120);
  sNcKopf      : STRING(120);
  wlNcIndex    : WORD;
  wlNcZeile    : WORD;
  wlNcAchse    : WORD;

  // Statuszeilen: Text und Farbe je Zeile (Beschriftung in asLbl)
  asWert   : ARRAY[1..29] OF STRING(80);
  adwFarbe : ARRAY[1..29] OF DWORD;
  asNc     : ARRAY[0..15] OF STRING(255);

  // Auswahlfenster der Achsen: Listenplatz -> Achs-ID, nur Achsen mit Namen
  blAuswahlOffen : BOOL;
  awlAuswahlId   : ARRAY[0..65] OF WORD;
  asAuswahl      : ARRAY[0..65] OF STRING(60);
  adwAuswahl     : ARRAY[0..65] OF DWORD;
  abAuswahlFrei  : ARRAY[0..65] OF BOOL; // Listenplatz ohne Achse (ausgeblendet)
  wlAuswahlAnzahl : WORD;

  // Override-Leiste
  sOverride        : STRING(40);
  adwOverrideStufe : ARRAY[1..10] OF DWORD;
  asOverrideStufe  : ARRAY[1..10] OF STRING(4) := [ '10', '20', '30', '40', '50', '60', '70', '80', '90', '100' ];

  asLbl : ARRAY[1..29] OF STRING(30) := [
    'Achszustand',          // 1
    'Betriebsart aktiv',    // 2
    'Angefordert',          // 3
    'Freigabe',             // 4
    'Regler bereit',        // 5
    'Referenz',             // 6
    'Fehler',               // 7
    'Bewegung',             // 8
    'Ist-Position',         // 9
    'Ist-Geschwindigkeit',  // 10
    'Endschalter',          // 11
    'Bremse',               // 12
    'Versorgung',           // 13
    'Langsamfahrt',         // 14
    'Master/Slave',         // 15
    'Referenzbit S-0-0277', // 16
    'Messtaster-Funktion',  // 17
    'Messtaster 1  + / -',  // 18
    'Messtaster 2  + / -',  // 19
    'Scheibenmessung',      // 20
    'Restweg',              // 21
    'Absolut setzen',       // 22
    'Verfahrbereich aktiv', // 23
    'MK SW-Endschalter',    // 24
    'MK max. Geschw.',      // 25
    'MK max. Beschl./Verz.',// 26
    'MK max. Ruckzeit',     // 27
    'E°ConSet v / a / d',   // 28
    'E°ConSet Rampenzeit'   // 29
  ];

  // Beschriftungen (benannt, damit Visu und Programm nicht unbemerkt auseinanderlaufen)
  sL_Titel        : STRING(60) := 'Antriebe verfahren';
  sL_Aktiv        : STRING(30) := 'Bedienung aktiv';
  sL_Achse        : STRING(30) := 'Achse';
  sL_Status       : STRING(30) := 'Status';
  sL_Diagnose     : STRING(30) := 'Diagnose';
  sL_Grund        : STRING(30) := 'Grundfunktionen';
  sL_Parameter    : STRING(30) := 'Fahrparameter';
  sL_Fahren       : STRING(30) := 'Fahren';
  sL_Restweg      : STRING(30) := 'Restweg';
  sL_Messung      : STRING(30) := 'Scheibenmessung';
  sL_MasterSlave  : STRING(30) := 'Master / Slave';
  sL_NcFehler     : STRING(30) := 'NC-Fehlerliste';
  sL_Zurueck      : STRING(10) := '<';
  sL_Vor          : STRING(10) := '>';
  sL_Freigabe     : STRING(30) := 'Freigabe erzwingen';
  sL_Reset        : STRING(30) := 'Reset';
  sL_Stopp        : STRING(30) := 'STOPP';
  sL_Bremse       : STRING(30) := 'Bremse lösen';
  sL_AbsSetzen    : STRING(30) := 'Absolut setzen';
  sL_Geschw       : STRING(30) := 'Geschwindigkeit';
  sL_ZielPos      : STRING(30) := 'Ziel / Weg';
  sL_Master       : STRING(30) := 'Master-Achse';
  sL_HandMinus    : STRING(30) := '- Hand';
  sL_HandPlus     : STRING(30) := 'Hand +';
  sL_Referenz     : STRING(30) := 'Referenz';
  sL_Absolut      : STRING(30) := 'Absolut';
  sL_Relativ      : STRING(30) := 'Relativ';
  sL_Positiv      : STRING(30) := 'positiv';
  sL_Negativ      : STRING(30) := 'negativ';
  sL_Steigend     : STRING(30) := 'steigend';
  sL_Fallend      : STRING(30) := 'fallend';
  sL_Sensor1      : STRING(10) := 'S1';
  sL_Sensor2      : STRING(10) := 'S2';
  sL_Sensor3      : STRING(10) := 'S3';
  sL_Sensor4      : STRING(10) := 'S4';
  sL_Richtung     : STRING(30) := 'Richtung';
  sL_Flanke       : STRING(30) := 'Flanke';
  sL_Sensoren     : STRING(30) := 'Sensoren';
  sL_Start        : STRING(30) := 'Start';
  sL_Sensor1Mess  : STRING(30) := 'Sensor 1';
  sL_Sensor2Mess  : STRING(30) := 'Sensor 2';
  sL_Umkehr       : STRING(30) := 'Gegenrichtung';
  sL_Vorab        : STRING(30) := 'Vorab-Sensor';
  sL_Koppeln      : STRING(30) := 'Koppeln';
  sL_KoppelnInv   : STRING(30) := 'Invertiert';
  sL_LogLoeschen  : STRING(30) := 'Liste löschen';
  sL_Ergebnis     : STRING(30) := 'Ergebnis';
  sL_Override     : STRING(30) := 'Override';
  sL_Uebernehmen  : STRING(30) := 'übernehmen';
  sL_Minus        : STRING(10) := '-';
  sL_Plus         : STRING(10) := '+';
  sL_Liste        : STRING(20) := 'Liste';
  sL_AuswahlTitel : STRING(80) := 'Achse wählen   (blau = gewählt, rot = Fehler, orange = nicht referenziert)';
  sL_Leer         : STRING(2)  := '';
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
rtlAbsolutSetzen( CLK := bpAbsolutSetzen );
rtlAchseVor( CLK := bpAchseVor );
rtlAchseZurueck( CLK := bpAchseZurueck );
rtlOverrideMinus( CLK := bpOverrideMinus );
rtlOverridePlus( CLK := bpOverridePlus );
ftlVisuAktiv( CLK := bgVisuAntriebeVerfahrenAktiv );
ftlHandPlusMinus( CLK := bpHandPlus OR bpHandMinus );

//-------------------------------------------------------------------------------------------------
// ACHSAUSWAHL
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Vor / Zurueck springt auf die naechste Achse, deren Baustein einen Achsnamen hat (aufgerufene Achse),
     damit die Visu bei keiner Maschine angepasst werden muss
   - Die ID kann auch direkt eingegeben werden
*)
IF ( rtlAchseVor.Q ) THEN
  wlSuche := wgAuswahlAchsID;
  FOR i := 1 TO 65 DO
    wlSuche := ( wlSuche + 1 ) MOD 66;
    IF ( pgAntriebe[wlSuche].slAchsname <> '' ) THEN
      wgAuswahlAchsID := wlSuche;
      EXIT;
    END_IF
  END_FOR
ELSIF ( rtlAchseZurueck.Q ) THEN
  wlSuche := wgAuswahlAchsID;
  FOR i := 1 TO 65 DO
    wlSuche := ( wlSuche + 65 ) MOD 66;
    IF ( pgAntriebe[wlSuche].slAchsname <> '' ) THEN
      wgAuswahlAchsID := wlSuche;
      EXIT;
    END_IF
  END_FOR
END_IF

(* Hinweis:
   - Auswahlfenster: ein Tipp auf einen Listenplatz waehlt die Achse und schliesst das Fenster,
     ein Tipp neben die Liste schliesst es ohne Auswahl
   - Die Taster werden hier zurueckgesetzt, weil das Element beim Schliessen verschwindet
*)
rtlAuswahlOeffnen( CLK := bpAuswahlOeffnen );
IF ( rtlAuswahlOeffnen.Q ) THEN
  blAuswahlOffen := NOT blAuswahlOffen;
END_IF

IF ( blAuswahlOffen ) THEN
  FOR i := 0 TO 65 DO
    IF ( abAuswahlTaster[i] AND ( UINT_TO_WORD( i ) < wlAuswahlAnzahl ) ) THEN
      wgAuswahlAchsID := awlAuswahlId[i];
      blAuswahlOffen  := FALSE;
    END_IF
  END_FOR
  IF ( bpAuswahlSchliessen ) THEN
    blAuswahlOffen := FALSE;
  END_IF
END_IF

FOR i := 0 TO 65 DO
  abAuswahlTaster[i] := FALSE;
END_FOR
bpAuswahlSchliessen := FALSE;

IF ( wgAuswahlAchsID > 65 ) THEN
  wgAuswahlAchsID := 65;
END_IF

//-------------------------------------------------------------------------------------------------
// BEDIEN-BITS DER VORHERIGEN ACHSE ZURUECKNEHMEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Beim Achswechsel und beim Deaktivieren der Visu: Freigabe erzwingen, Bremse loesen und
     Absolut setzen der zuletzt bedienten Achse zuruecknehmen
*)
blFreigeben := ( bAchsIDTemp <> wgAuswahlAchsID ) OR ftlVisuAktiv.Q;

IF ( blFreigeben ) THEN
  pgAntriebe[wlAchse].bpFreigabeErzwingen := FALSE;
  pgAntriebe[wlAchse].bpBremseLoesen      := FALSE;
  pgAntriebe[wlAchse].bpAbsolutSetzen     := FALSE;
  bpFreigabeSetzen     := FALSE;
  bpBremseLoesen       := FALSE;
  blAbsolutSetzenAktiv := FALSE;
  bpOverrideAktiv      := FALSE;
  bAchsIDTemp          := wgAuswahlAchsID;
END_IF

//-------------------------------------------------------------------------------------------------
// OVERRIDE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Leiste 10 ... 100 %, Feinstellung in 5-%-Schritten
   - Uebernommen wird der Wert nur fuer die gewaehlte Achse, solange die Bedienung aktiv ist und
     "uebernehmen" eingeschaltet ist (Aufruf der Achsen in Antriebe.prg), sonst gilt der Maschinen-Override
*)
FOR i := 1 TO 10 DO
  IF ( abOverrideStufe[i] ) THEN
    rpOverrideVisu := UINT_TO_REAL( i * 10 );
  END_IF
END_FOR

IF ( rtlOverrideMinus.Q ) THEN
  rpOverrideVisu := MAX( rpOverrideVisu - 5.0, 0.0 );
ELSIF ( rtlOverridePlus.Q ) THEN
  rpOverrideVisu := MIN( rpOverrideVisu + 5.0, 100.0 );
END_IF

bpOverrideWirksam := bgVisuAntriebeVerfahrenAktiv AND bpOverrideAktiv;

// Anzeige auch ohne aktive Bedienung
A_VisuDaten();

IF NOT bgVisuAntriebeVerfahrenAktiv THEN
  RETURN;
ELSE
  wlAchse := wgAuswahlAchsID;

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

// Bremse loesen (Schalter)
pgAntriebe[wgAuswahlAchsID].bpBremseLoesen := bpBremseLoesen;

// Absolut setzen: laeuft bis Done, Stopp oder Reset
IF ( rtlAbsolutSetzen.Q ) THEN
  blAbsolutSetzenAktiv := TRUE;
ELSIF ( pgAntriebe[wgAuswahlAchsID].bpAbsolutSetzenDone OR rtlStopp.Q OR rtlReset.Q ) THEN
  blAbsolutSetzenAktiv := FALSE;
END_IF
pgAntriebe[wgAuswahlAchsID].bpAbsolutSetzen := blAbsolutSetzenAktiv;

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
  pgAntriebe[wgAuswahlAchsID].eSensorAuswahl_Messung_1 := VisuAv_Sensor( wpSensorMessung1 );
  pgAntriebe[wgAuswahlAchsID].eSensorAuswahl_Messung_2 := VisuAv_Sensor( wpSensorMessung2 );
  pgAntriebe[wgAuswahlAchsID].bpDrehrichtungsumkehrMessung        := bpDrehrichtungsumkehrMessung;
  pgAntriebe[wgAuswahlAchsID].bpAuswahlSensorVorabScheibenmessung := bpSensorVorabMessung;
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

// Hand minus
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
