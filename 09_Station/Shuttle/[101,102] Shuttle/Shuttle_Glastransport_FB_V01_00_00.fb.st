(* METADATA
{
	"v3Meta": {
		"objectGuid": "bced77b5-e61c-4af0-a672-a0da8c7118bb"
	}
}
*)
FUNCTION_BLOCK Shuttle_Glastransport_FB_V01_00_00
VAR_INPUT

  bpDurchtransport                 : BOOL; // BETRIEBSMODUS[AUTOMATIK]: Eintransport-Schrittkette starten
  bpEintransport                   : BOOL; // BETRIEBSMODUS[AUTOMATIK]: Eintransport-Schrittkette starten
  bpRueckwaertsEintransportieren   : BOOL; // BETRIEBSMODUS[AUTOMATIK]: Eintransport Richtung -Rueckwaerts ueber den Auslaufsensor
  bpAustransport                   : BOOL; // BETRIEBSMODUS[AUTOMATIK]: Autransport-Schrittkette starten
  bpRueckwaertsAustransportieren   : BOOL; // BETRIEBSMODUS[AUTOMATIK]: Austransport Richtung -Rueckwaerts ueber den Einlaufsensor
  bpRueckwaertsSystemcheck         : BOOL;
  bpVortransport                   : BOOL; // BETRIEBSMODUS[AUTOMATIK]: Vortransport-Schrittkette starten
  bpVortransportRueck              : BOOL; // BETRIEBSMODUS[AUTOMATIK]: Vortransport-Schrittkette starten
  bpStarteSensorFreiFahren         : BOOL := FALSE; // BETRIEBSMODUS[AUTOMATIK]:
  bpHandfahrenPlus                 : BOOL; // BETRIEBSMODUS HANDBETRIEB: Im Handbetrieb den Riemen in positive Glasflussrichtung bewegen
  bpHandfahrenMinus                : BOOL; // BETRIEBSMODUS HANDBETRIEB: Im Handbetrieb den Riemen in negative Glasflussrichtung bewegen
  bpFahreReferenz                  : BOOL; // BETRIEBSMODUS: Antrieb referenzieren
  bpStarteVorabPositionierung      : BOOL; // BETRIEBSMODUS Positionieren der Scheibe fuer den Austransport
  bpStarteVorabPositionierungRueckwaertig : BOOL; // BETRIEBSMODUS Positionieren der Scheibe fuer den Austransport rueckwaerts (ueber den Einlaufsensor)
  bpCheck                          : BOOL;
  bpReset                          : BOOL;
  bpCheckMitVorgaenger             : BOOL; // Status: SystemCheck mit der Vorgaenger- Station
  bpCheckMitNachfolger             : BOOL; // Status: SystemCheck mit der Nachfolger- Station
  bpAutomatikAktiv                 : BOOL;
  bpFreigabe                       : BOOL; // Status: Der Riemen ist Freigegeben und kann Prozesse abarbeiten
  bpMessrichtungNegativ            : BOOL := FALSE; // HINWEIS: TRUE = Messrichtung negativ, FALSE = Messrichtung positiv
  bpAktivieren                     : BOOL := TRUE; // WICHTIG: Aktivieren des Bausteins
  bpScheibentrennung               : BOOL := FALSE;
  bpTransferstationTransfershuttle : BOOL := FALSE;
  bpSensorEinlauf                  : BOOL; // Sensoren von links nach rechts Sensor 1
  bpSensorEinlaufVorab             : BOOL; // Sensoren von links nach rechts Sensor 2
  bpSensorAuslaufVorab             : BOOL; // Sensoren von links nach rechts Sensor 3
  bpSensorAuslauf                  : BOOL; // Sensoren von links nach rechts Sensor 4
  bpSensorEinlaufStopp             : BOOL; // Sensoren von links nach rechts Sensor 0 (Verfahrfreigabe, Notbremse und Scheibe hat Shuttle verlassen im Rueckwaertstransport)
  bpSensorAuslaufStopp             : BOOL; // Sensoren von links nach rechts Sensor 5
  bpScheibeNachSystemcheckAufAuslaufsensor : BOOL;
  bpTeilnehmerErreichbar           : BOOL;
  bpMessungSystemCheckAktiv        : BOOL;
  bpSlaveAntriebVorhanden          : BOOL;
  
  // OPTIONEN
  bpOptionMasterSlaveTransport     : BOOL;

  // GREIFER
  bpStarteSlaveKopplungGreifer      : BOOL; // BETRIEBSMODUS GREIFER: Glastransport als Slave auf die Greiferachse koppeln
  bpStarteKorrekturfahrt            : BOOL; // BETRIEBSMODUS GREIFER: Sensor der Greiferseite frei fahren (uebergrosse Scheibe / nach dem Austransport)
  bpKorrekturfahrtRueckwaerts       : BOOL; // BETRIEBSMODUS GREIFER: TRUE = Auslaufsensor frei fahren, FALSE = Einlaufsensor frei fahren
  bpStarteGlasPositionierungGreifer : BOOL; // BETRIEBSMODUS GREIFER: Scheibe fuer den Austransport mit dem Greifer positionieren
  bpGlasPositionierungEinlaufseite  : BOOL; // BETRIEBSMODUS GREIFER: TRUE = ueber den Einlaufsensor positionieren, FALSE = ueber den Auslaufsensor
  wpAchsIDGreifer                   : WORD; // Achs-ID der Greiferachse (Master der Kopplung)
  rpWegGlasUebergabeposition        : REAL; // Weg der Scheibe ueber den Sensor der Greiferseite

  // WORD
  wpWandNr                    : WORD;
  
  // ENUM
  eStationsTyp                 : StationsTyp_EN; // Typ der Station [ Shuttle \ Station \ Faecherwagen \ etc. ]
  wpGlastyp                   : GlasTyp_EN; // AUFTRAGSDATEN : Unterscheidung fuer den Eintransports -> Grosse Scheiben

  // STRUCT
  InGlasTransportNachfolger   : Interface_GlasTransport; // STRUKTUR: Informationen ueber den Aus- Ein- Transport WAND 2
  InGlasTransportVorgaenger   : Interface_GlasTransport; // STRUKTUR: Informationen ueber den Aus- Ein- Transport WAND 2
  pAuftrag                    : Auftragsdaten_ST;        // AUFTRAG: Aktuelle daten zum Auftrag [Laenge, Hoehe, Modelle]
  stStationsNummern           : Station_ST;
  stMasterSlaveConfig         : MasterSlaveConfig_ST;

  // POINTER
  ppParameterBaustein           : REFERENCE TO Parameter_ShuttleGlastransport;
  ppAntriebsInformationen       : REFERENCE TO AntriebsInformationen;
  ppAntriebsInformationenSlave  : REFERENCE TO AntriebsInformationen;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone                                      : BOOL;
  bpFehler                                    : BOOL;
  bprtScheibe                                 : BOOL;
  bpStationBelegt                             : BOOL;
  bpVerfahrFreigabe                           : BOOL;
  bpVortransportAktiv                         : BOOL; // STATUS: Merker ob der Vortransport (Autark gesteuert) aktiv ist -> Wichtig für den Austransport zum sicherstellen das erst dann Transportiert werden kann
  bpPositionierungAbgeschlossen               : BOOL; // HINWEIS:
  bpOutBereitZumAustransport                  : BOOL;
  bpOutBereitZumEintransport                  : BOOL;
  bpSlaveAktiv                                : BOOL; // STATUS: dem Baustein melden das der Slavebetrieb aktiv ist
  bpFreigabeQuerfahrt                         : BOOL; // HINWEIS: Freigabe setzen das die Querfahrt verfahren kann
  bpAuftragAktiv                              : BOOL;
  bpGreiferSlaveAktiv                         : BOOL; // STATUS: Glastransport ist auf die Greiferachse gekoppelt
  bpKorrekturfahrtAbgeschlossen               : BOOL; // STATUS: Korrekturfahrt fuer den Greifer abgeschlossen
  bpGlasPositionierungGreiferAbgeschlossen    : BOOL; // STATUS: Scheibe fuer den Greifer positioniert

  // WORD
  wpFehlerNr             : Fehlerkonstanten_EN;

  // DWORD
  dwpWartezeit              : DWORD :=0 ;// STATISTIK: Beschreibt die Zeit zwischen Anlegeauftrag und betaetigen des Tasters zum Eintransport

  // REAL
  rpOutGeschwindigkeit        : REAL;
  rlGlasgewicht               : REAL;

END_VAR
VAR

  // BOOLEAN
  blErsterZyklus                              : BOOL := TRUE;
  blSensorFreifahren                          : BOOL;
  blScheibenMerker                            : BOOL; // Merken da eien Scheibe den Auslaufsensor / Einlaufsensor beim Eintransport weiter
  blReduzierteGeschwindigkeit                 : BOOL;
  blAntriebsKopplungAktiv                     : BOOL;
  blStarteSlaveKopplung                       : BOOL;

  // INT
  ilScheibenZaehler  : INT;

  // REAL
  rlScheibenMessungErgebnis         : REAL; // SystemCheck
  rlAntriebIstPositionBeiStart      : REAL;
  rlMaxStreckeErsteScheibe          : REAL; // Max. Weg bis zur ersten Scheibe: Laenge der abgebenden Station, ohne bekannte Laenge die eigene Stationslaenge
  rlStreckeBisZurVerzoegerung       : REAL;
  rlPositionScheibenAnfangErkannt   : REAL;
  rlGeschwindigkeitEintransport     : REAL;
  rlGefahreneStreckeEintransport    : REAL; // Weg-Merker fuer die Strecke die beim Eintransport zurueck gelegt werden muss laut Auftrag

  // STEPS
  steplDurchtransport           : Steps_TE;
  steplEintransport             : Steps_TE;
  steplEintransportRueckwaertig : Steps_TE;
  steplAustransport             : Steps_TE;
  steplAustransportRueckwaertig : Steps_TE;
  steplSlave                    : Steps_TE;
  steplCheck                    : Steps_TE;
  steplReset                    : Steps_TE;
  steplReferenz                 : Steps_TE;
  steplVorabpositionieren       : STEPS_TE; // Hinweis: Positionierung ueber den Auslaufsensor
  steplVorabpositionierenRueckwaertig : STEPS_TE; // Hinweis: Positionierung ueber den Einlaufsensor
  steplSensorFreiFahren         : Steps_TE;
  steplVortransport             : Steps_TE;
  steplVortransportRueckwertig  : Steps_TE;
  steplSlaveGreifer             : Steps_TE;
  steplKorrekturfahrt           : Steps_TE;
  steplGlasPositionierungGreifer : Steps_TE;

  steplCheckMerker : Steps_TE;

  // TIMER
  toflAutoAbschaltung                : TOF; // AUSSCHALTVERZOEGERUNG:
  toflEinlaufsensor                  : TOF; // AUSSCHALTVERZOEGERUNG: Entprellen der Sensoren
  toflAuslaufsensor                  : TOF; // AUSSCHALTVERZOEGERUNG: Entprellen der Sensoren
  toflAuslaufsensorSTOP              : TOF; // AUSSCHALTVERZOEGERUNG: Entprellen der Sensoren
  toflEinlaufsensorSTOP              : TOF; // AUSSCHALTVERZOEGERUNG: Entprellen der Sensoren
  toflEinlaufsensorFrei              : TOF; // AUSSCHALTVERZOEGERUNG: Haelt die positive Flanke des Auslaufsensor eine gewissen Zeit aufrecht ( Freifahren des Sensors )
  toflAuslaufsensorFrei              : TOF; // AUSSCHALTVERZOEGERUNG: Haelt die positive Flanke des Auslaufsensor eine gewissen Zeit aufrecht ( Freifahren des Sensors )
  tonlMaxWarteAufResetErfolgreich    : TON; // EINSCHALTVERZOEGERUNG:
  tonlWarteSchritt                   : TON; // EINSCHALTVERZOEGERUNG:
  tonlAntriebNichtFreigegeben        : TON; // EINSCHALTVERZOEGERUNG:
  tonlUberwachungSlaveAktiv          : TON; // EINSCHALTVERZOEGERUNG:  
  tonlSlaveKopplungDeaktiviert       : TON;
  tonlSlaveAntriebNichtFreigegeben   : TON; // Ueberwachung: Master/Slave nicht betriebsbereit
  tonlUeberwachungSlaveGreifer       : TON; // Ueberwachung: Kopplung auf die Greiferachse
  tonlUeberwachungGreiferBetrieb      : TON; // Ueberwachung: Antrieb bereit fuer Korrekturfahrt / Positionierung fuer den Greifer
  
  // TIME
  tlWarteZeiteAufnahme               : TIME; // STATISTIK: Zeit Ermittlung von evtl. Wartezeiten

  // STRING
  stlLogString    : STRING;

  // Antrieb
  Scheibenmessung  : Scheibenmessung_FB_V01_01_01;

  // Antrieb
  Antrieb       : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;
  Antrieb_Slave : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

END_VAR
VAR CONSTANT

  // TIME
  cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE : TIME := T#5S;  
  cUEBERWACHUNG_SLAVE_AKTIV           : TIME :=T#1S;

END_VAR

//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN

  IF ( __ISVALIDREF(ppAntriebsInformationen) ) THEN

    blErsterZyklus            := FALSE;

    Antrieb REF= pgAntriebe[ppAntriebsInformationen.wAchsID];
    IF ( __ISVALIDREF(ppAntriebsInformationenSlave) ) THEN
      Antrieb_Slave REF= pgAntriebe[ppAntriebsInformationenSlave.wAchsID];
    END_IF

    (* Hinweis:
       - Initialisierung Antriebsinformationen
    *)
    Antrieb.ppAntriebsInformationen REF= ppAntriebsInformationen;
    Antrieb.stStationsNummern := stStationsNummern;
    IF ( __ISVALIDREF(Antrieb_Slave) AND __ISVALIDREF(ppAntriebsInformationenSlave) ) THEN
      Antrieb_Slave.ppAntriebsInformationen REF= ppAntriebsInformationenSlave;
      Antrieb_Slave.stStationsNummern := stStationsNummern;
    END_IF

    (* Hinweis:
       - Antriebswerte vorinitialisieren
    *)
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
    Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
    Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
    Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;

    (* Hinweis:
       - Antriebswerte vorinitialisieren
    *)
    IF ( __ISVALIDREF(Antrieb_Slave) AND __ISVALIDREF(ppAntriebsInformationenSlave) ) THEN
      Antrieb_Slave.rpGeschwindigkeit := REAL#0;
      Antrieb_Slave.rpBeschleunigung  := ppAntriebsInformationenSlave.rpMaxBeschleunigung;
      Antrieb_Slave.rpVerzoegerung    := ppAntriebsInformationenSlave.rpMaxVerzoegerung;
      Antrieb_Slave.rpRuckzeit        := ppAntriebsInformationenSlave.rpMaxRuckzeit;
    END_IF

    // Pointer
    //   - Initialisierung zur vermeidung von null Pointerexceptions
    //     => Scheibenmessung
    Scheibenmessung.ppAntriebsInformationen REF= ppAntriebsInformationen;
    Scheibenmessung.ppAntrieb               REF= Antrieb;
    Scheibenmessung.pbpVorstopSensor        REF= bgFALSE;
    Scheibenmessung.pbpEinlaufSensor        REF= bgFALSE;

  ELSE
    RETURN;
  END_IF

END_IF

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF ( NOT bpAktivieren ) THEN

  bpVerfahrFreigabe := TRUE;
  bpDone := TRUE;

  (* Hinweis:
     - Ausnahmesituationen
  *)
  bpFehler   := FALSE;
  wpFehlerNr := WORD#0;

  RETURN;

END_IF


//-------------------------------------------------------------------------------------------------
// TIMER, EINSTELLUNGEN, ETC.
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Sensorenflackern
*)
toflEinlaufsensor(IN := bpSensorEinlauf, PT := t#50ms);
toflAuslaufsensor(IN := bpSensorAuslauf, PT := t#50ms);
toflAuslaufsensorSTOP(IN := bpSensorAuslaufStopp, PT := t#50ms);
toflEinlaufsensorSTOP(IN := bpSensorEinlaufStopp, PT := t#50ms);


// TIMER:
//   - Sensorenflackern
//     => Haelt die positive Flanke des Auslaufsensor eine gewissen Zeit aufrecht ( Freifahren des Sensors )
toflAuslaufsensorFrei(IN := bpSensorAuslauf, PT := t#300ms);
toflEinlaufsensorFrei(IN := bpSensorEinlauf, PT := t#100ms);






//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - SystemCheck - Aktion
*)
SystemCheck();

(* Hinweis:
   - SystemCheck - Aktion
*)
Eintransport();
Eintransport_Rueckwertig();

Durchtransport();

Austransport();
Austransport_Rueckwertig();

GlasVorabPositionierung();
GlasVorabPositionierung_Rueckwaertig();

CASE eStationsTyp OF

  eInputShuttle:
    Vortransport_Inputshuttle();
    Vortransport_Rueckwertig();

  eOutputShuttle:
    Vortransport();
    Vortransport_Rueckwertig();

END_CASE

SensorenFreifahren();

(* Hinweis:
   - Zusammenspiel mit dem Shuttle-Greifer (nur mit stStationsAufbau.bGreifer angefordert)
*)
GlasPositionierungGreifer();
Korrekturfahrt();
SlaveBetriebGreifer();

IF ( bpSlaveAntriebVorhanden ) THEN
  Slave_Antrieb();
ELSE
  blAntriebsKopplungAktiv := TRUE;
END_IF
(* Hinweis:
   - Basis- Aktionen
*)
Reset();
Referenz();
Meldungen();
Handfunktionen();
Ausgaenge();

//-------------------------------------------------------------------------------------------------
// FREIGABEN UND BAUSTEINAUFRUFE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Freigaben des ANtriebs
*)
toflAutoAbschaltung( IN := (  bpAutomatikAktiv
                             AND ( bpEintransport
                                   OR bpRueckwaertsEintransportieren
                                   OR bpDurchtransport
                                   OR bpVortransport
                                   OR bpVortransportRueck
                                   OR bpAustransport
                                   OR bpRueckwaertsAustransportieren
                                   OR bpStarteSensorFreiFahren
                                   OR bpStarteVorabPositionierung
                                   OR bpStarteVorabPositionierungRueckwaertig
                                   OR bpStarteSlaveKopplungGreifer
                                   OR bpStarteKorrekturfahrt
                                   OR bpStarteGlasPositionierungGreifer ) )
                     OR bpCheck
                     OR bpHandfahrenMinus
                     OR bpHandfahrenPlus
                     OR bpFahreReferenz
                     OR blStarteSlaveKopplung,
                     PT:= tgZeitAutoabschaltungEnergiesparModus );

// Aufruf Antrieb
Antrieb.bpFreigabe        := toflAutoAbschaltung.Q AND bpFreigabe; 
Antrieb.stStationsNummern := stStationsNummern;
Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;

Antrieb_Slave.bpFreigabe        := toflAutoAbschaltung.Q AND bpFreigabe;
Antrieb_Slave.stStationsNummern := stStationsNummern;
Antrieb_Slave.rpRuckzeit        := ppAntriebsInformationenSlave.rpMaxRuckzeit;

  
// Aufruf Scheibenmessung
Scheibenmessung( stStationsNummern                   := stStationsNummern,
                 ppAntrieb                           := Antrieb,
                 pbpVorstopSensor                    := bpSensorAuslaufVorab,
                 pbpEinlaufSensor                    := bpSensorEinlauf,
                 bpDrehrichtungsumkehrMessung        := bpMessrichtungNegativ,
                 rpMessstrecke                       := ppParameterBaustein.rMessstrecke,
                 ppAntriebsInformationen             := ppAntriebsInformationen,
                 bpAuswahlSensorVorabScheibenmessung := bgFALSE,
                 epGlastyp                           := wpGlastyp,
                 rpFaktorBremswegverlaengern         := 1.6 ) ;
END_FUNCTION_BLOCK