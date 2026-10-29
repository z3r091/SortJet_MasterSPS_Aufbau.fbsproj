(* METADATA
{
	"v3Meta": {
		"objectGuid": "bced77b5-e61c-4af0-a672-a0da8c7118bb"
	}
}
*)
FUNCTION_BLOCK Shuttle_Glastransport_FB
VAR_INPUT

  bpDurchtransport                 : BOOL; (* BETRIEBSMODUS[AUTOMATIK]: Eintransport-Schrittkette starten *)
  bpEintransport                   : BOOL; (* BETRIEBSMODUS[AUTOMATIK]: Eintransport-Schrittkette starten *)
  bpRueckwaertsEintransportieren   : BOOL; (* BETRIEBSMODUS[AUTOMATIK]: Eintransport Richtung -Rueckwaerts ueber den Auslaufsensor *)
  bpAustransport                   : BOOL; (* BETRIEBSMODUS[AUTOMATIK]: Autransport-Schrittkette starten *)
  bpRueckwaertsAustransportieren   : BOOL; (* BETRIEBSMODUS[AUTOMATIK]: Austransport Richtung -Rueckwaerts ueber den Einlaufsensor *)
  bpRueckwaertsSystemcheck         : BOOL;
  bpVortransport                   : BOOL; (* BETRIEBSMODUS[AUTOMATIK]: Vortransport-Schrittkette starten *)
  bpVortransportRueck              : BOOL; (* BETRIEBSMODUS[AUTOMATIK]: Vortransport-Schrittkette starten *)
  bpStarteSensorFreiFahren         : BOOL := FALSE; (* BETRIEBSMODUS[AUTOMATIK]: *)
  bpHandfahrenPlus                 : BOOL; (* BETRIEBSMODUS HANDBETRIEB: Im Handbetrieb den Riemen in positive Glasflussrichtung bewegen *)
  bpHandfahrenMinus                : BOOL; (* BETRIEBSMODUS HANDBETRIEB: Im Handbetrieb den Riemen in negative Glasflussrichtung bewegen *)
  bpFahreReferenz                  : BOOL; (* BETRIEBSMODUS: Antrieb referenzieren *)
  bpStarteVorabPositionierung      : BOOL; (* BETRIEBSMODUS Positionieren der Scheibe fuer den Austransport *)
  bpCheck                          : BOOL;
  bpReset                          : BOOL;
  bpCheckMitVorgaenger             : BOOL; (* Status: SystemCheck mit der Vorgaenger- Station *)
  bpCheckMitNachfolger             : BOOL; (* Status: SystemCheck mit der Nachfolger- Station *)
  bpAutomatikAktiv                 : BOOL;
  bpFreigabe                       : BOOL; (* Status: Der Riemen ist Freigegeben und kann Prozesse abarbeiten *)
  bpMessrichtungNegativ            : BOOL := FALSE; (* HINWEIS: TRUE = Messrichtung negativ, FALSE = Messrichtung positiv *)
  bpAktivieren                     : BOOL := TRUE; (* WICHTIG: Aktivieren des Bausteins *)
  bpScheibentrennung               : BOOL := FALSE;
  bpTransferstationTransfershuttle : BOOL := FALSE;
  bpSensorEinlauf                  : BOOL; (* Sensoren von links nach rechts Sensor 1 *)
  bpSensorEinlaufVorab             : BOOL; (* Sensoren von links nach rechts Sensor 2 *)
  bpSensorAuslaufVorab             : BOOL; (* Sensoren von links nach rechts Sensor 3 *)
  bpSensorAuslauf                  : BOOL; (* Sensoren von links nach rechts Sensor 4 *)
  bpSensorAuslaufStopp             : BOOL; (* Sensoren von links nach rechts Sensor 5 *)
  bpScheibeNachSystemcheckAufAuslaufsensor : BOOL;
  bpTeilnehmerErreichbar           : BOOL;
  bpMessungSystemCheckAktiv        : BOOL;
  bpSlaveAntriebVorhanden          : BOOL;
  
  // OPTIONEN
  bpOptionMasterSlaveTransport     : BOOL;

  (* WORD *)
  wpWandNr                    : WORD;
  
  (* ENUM *)
  eStationsTyp                 : StationsTyp_EN; (* Typ der Station [ Shuttle \ Station \ Faecherwagen \ etc. ] *)
  wpGlastyp                   : GlasTyp_EN; (* AUFTRAGSDATEN : Unterscheidung fuer den Eintransports -> Grosse Scheiben *)

  (* STRUCT *)
  InGlasTransportNachfolger   : Interface_GlasTransport; (* STRUKTUR: Informationen ueber den Aus- Ein- Transport WAND 2 *)
  InGlasTransportVorgaenger   : Interface_GlasTransport; (* STRUKTUR: Informationen ueber den Aus- Ein- Transport WAND 2 *)
  pAuftrag                    : Auftragsdaten_ST;        (* AUFTRAG: Aktuelle daten zum Auftrag [Laenge, Hoehe, Modelle] *)
  stStationsNummern           : Station_ST;
  stMasterSlaveConfig         : MasterSlaveConfig_ST;

  (* POINTER *)
  ppParameterBaustein           : REFERENCE TO Parameter_ShuttleGlastransport;
  ppAntriebsInformationen       : REFERENCE TO AntriebsInformationen;
  ppAntriebsInformationenSlave  : REFERENCE TO AntriebsInformationen;

END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpDone                                      : BOOL;
  bpFehler                                    : BOOL;
  bprtScheibe                                 : BOOL;
  bpStationBelegt                             : BOOL;
  bpVerfahrFreigabe                           : BOOL;
  bpVortransportAktiv                         : BOOL; (* STATUS: Merker ob der Vortransport (Autark gesteuert) aktiv ist -> Wichtig für den Austransport zum sicherstellen das erst dann Transportiert werden kann *)
  bpPositionierungAbgeschlossen               : BOOL; (* HINWEIS:  *)
  bpOutBereitZumAustransport                  : BOOL;
  bpOutBereitZumEintransport                  : BOOL;
  bpSlaveAktiv                                : BOOL; (* STATUS: dem Baustein melden das der Slavebetrieb aktiv ist *)
  bpFreigabeQuerfahrt                         : BOOL; (* HINWEIS: Freigabe setzen das die Querfahrt verfahren kann *)
  bpAuftragAktiv                              : BOOL;

  (* WORD *)
  wpFehlerNr             : WORD;

  (* DWORD *)
  dwpWartezeit              : DWORD :=0 ;(* STATISTIK: Beschreibt die Zeit zwischen Anlegeauftrag und betaetigen des Tasters zum Eintransport *)

  (* REAL *)
  rpOutGeschwindigkeit        : REAL;
  rlGlasgewicht               : REAL;

END_VAR
VAR

  (* BOOLEAN *)
  blErsterZyklus                              : BOOL := TRUE;
  blSensorFreifahren                          : BOOL;
  blScheibenMerker                            : BOOL; (* Merken da eien Scheibe den Auslaufsensor / Einlaufsensor beim Eintransport weiter *)
  blBausteinFreigabeAntrieb                   : BOOL; (* lokale Freigabe für den Glastransportantrieb *)
  blReduzierteGeschwindigkeit                 : BOOL;
  blZeitGeschwindigkeitsReduzierungAktiv      : BOOL; (* Hinweis: Zeitliche Komponente zum reduzieren der Geschwindigkeit *)
  blOptionReduzierungGeschwindigkeitUeberZeit : BOOL := FALSE;
  blAntriebsKopplungAktiv                     : BOOL;
  blStarteSlaveKopplung                       : BOOL;

  (* INT *)
  ilScheibenZaehler  : INT;

  (* REAL *)
  rlScheibenMessungErgebnis         : REAL; (* SystemCheck *)
  rlAntriebIstPositionBeiStart      : REAL;
  rlStreckeBisZurVerzoegerung       : REAL;
  rlPositionScheibenAnfangErkannt   : REAL;
  rlGeschwindigkeitEintransport     : REAL;
  rlGefahreneStreckeEintransport    : REAL; (* Weg-Merker fuer die Strecke die beim Eintransport zurueck gelegt werden muss laut Auftrag *)

  (* STEPS *)
  steplDurchtransport           : Steps_TE;
  steplEintransport             : Steps_TE;
  steplEintransportRueckwaertig : Steps_TE;
  steplAustransport             : Steps_TE;
  steplAustransportRueckwaertig : Steps_TE;
  steplSlave                    : Steps_TE;
  steplCheck                    : Steps_TE;
  steplReset                    : Steps_TE;
  steplReferenz                 : Steps_TE;
  steplVorabpositionieren       : STEPS_TE; (* Hinweis: Positionierung ueber den Auslaufsensor *)
  steplSensorFreiFahren         : Steps_TE;
  steplVortransport             : Steps_TE;
  steplVortransportRueckwertig  : Steps_TE;
  
  steplCheckMerker : Steps_TE;

  (* TIMER *)
  toflAutoAbschaltung                : TOF; (* AUSSCHALTVERZOEGERUNG: *)
  toflEinlaufsensor                  : TOF; (* AUSSCHALTVERZOEGERUNG: Entprellen der Sensoren *)
  toflAuslaufsensor                  : TOF; (* AUSSCHALTVERZOEGERUNG: Entprellen der Sensoren *)
  toflAuslaufsensorSTOP              : TOF; (* AUSSCHALTVERZOEGERUNG: Entprellen der Sensoren *)
  toflEinlaufsensorFrei              : TOF; (* AUSSCHALTVERZOEGERUNG: Haelt die positive Flanke des Auslaufsensor eine gewissen Zeit aufrecht ( Freifahren des Sensors ) *)
  toflAuslaufsensorFrei              : TOF; (* AUSSCHALTVERZOEGERUNG: Haelt die positive Flanke des Auslaufsensor eine gewissen Zeit aufrecht ( Freifahren des Sensors ) *)
  tonlMaxWarteAufResetErfolgreich    : TON; (* EINSCHALTVERZOEGERUNG: *)
  tonlWarteSchritt                   : TON; (* EINSCHALTVERZOEGERUNG: *)
  tonlAntriebNichtFreigegeben        : TON; (* EINSCHALTVERZOEGERUNG: *)
  tonlGeschwindigkeitReduzieren      : TON; (* EINSCHALTVERZOEGERUNG: Zeitliche Komponente zum reduzieren der Geschwindigkeit *)  
  tonlUberwachungSlaveAktiv          : TON; (* EINSCHALTVERZOEGERUNG: *)  
  tonlSlaveKopplungDeaktiviert       : TON;
  
  (* TIME *)
  tlWarteZeiteAufnahme               : TIME; (* STATISTIK: Zeit Ermittlung von evtl. Wartezeiten *)
  tlReduzierungGeschwindigkeit       : TIME := T#1s;

  (* STRING *)
  stlLogString    : STRING;

  (* Antrieb *)
  Scheibenmessung  : Scheibenmessung_FB;

  // Antrieb
  Antrieb       : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_01;
  Antrieb_Slave : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_01;

END_VAR
VAR CONSTANT

  (* TIME *)
  cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE : TIME := T#5S;  
  cUEBERWACHUNG_SLAVE_AKTIV           : TIME :=T#1S;

END_VAR

(***************************************************************************************************)
(* INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN

  blErsterZyklus            := FALSE;
  blBausteinFreigabeAntrieb := TRUE;
  
  Antrieb REF= pgAntriebe[ppAntriebsInformationen.wAchsID];
  Antrieb_Slave REF= pgAntriebe[ppAntriebsInformationenSlave.wAchsID];

  IF ( __ISVALIDREF(ppAntriebsInformationen) ) THEN

    (* Hinweis:
       - Initialisierung Antriebsinformationen
    *)
    Antrieb.ppAntriebsInformationen REF= ppAntriebsInformationen;
    Antrieb.stStationsNummern := stStationsNummern;
    Antrieb_Slave.ppAntriebsInformationen REF= ppAntriebsInformationenSlave;
    Antrieb_Slave.stStationsNummern := stStationsNummern;

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
    Antrieb_Slave.rpGeschwindigkeit := REAL#0;
    Antrieb_Slave.rpBeschleunigung  := ppAntriebsInformationenSlave.rpMaxBeschleunigung;
    Antrieb_Slave.rpVerzoegerung    := ppAntriebsInformationenSlave.rpMaxVerzoegerung;
    Antrieb_Slave.rpRuckzeit        := ppAntriebsInformationenSlave.rpMaxRuckzeit;

    (* Pointer
       - Initialisierung zur vermeidung von null Pointerexceptions
         => Scheibenmessung
    *)
    Scheibenmessung.ppAntriebsInformationen REF= ppAntriebsInformationen;
    Scheibenmessung.ppAntrieb               REF= Antrieb;
    Scheibenmessung.pbpVorstopSensor        REF= bgFALSE;
    Scheibenmessung.pbpEinlaufSensor        REF= bgFALSE;

  END_IF

END_IF

(***************************************************************************************************)
(* DEAKTIVIEREN *)
(***************************************************************************************************)
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


(***************************************************************************************************)
(* TIMER, EINSTELLUNGEN, ETC. *)
(***************************************************************************************************)
(* Hinweis:
   - Sensorenflackern
*)
toflEinlaufsensor(IN := bpSensorEinlauf, PT := t#50ms);
toflAuslaufsensor(IN := bpSensorAuslauf, PT := t#50ms);
toflAuslaufsensorSTOP(IN := bpSensorAuslaufStopp, PT := t#50ms);


(* TIMER:
   - Sensorenflackern 
     => Haelt die positive Flanke des Auslaufsensor eine gewissen Zeit aufrecht ( Freifahren des Sensors )
*)
toflAuslaufsensorFrei(IN := bpSensorAuslauf, PT := t#300ms);
toflEinlaufsensorFrei(IN := bpSensorEinlauf, PT := t#100ms);


(* Hinweis:
   - Reduzierung der Geschwindigkeit. Verwendet fuer Stationen vom Type = Inputshuttle die das Glas
     ueberden Auslaufsensor Positionieren beim Eintransport.
   - Nur Aktiv wenn im Auftrag die Bits fuer erste u. letzte Scheibe gesetzt sind.
*)
tonlGeschwindigkeitReduzieren( IN := blZeitGeschwindigkeitsReduzierungAktiv,
                               PT := tlReduzierungGeschwindigkeit );




(***************************************************************************************************)
(* AKTIONEN *)
(***************************************************************************************************)

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

CASE eStationsTyp OF

  eInputShuttle:
    Vortransport_Inputshuttle();
    Vortransport_Rueckwertig();

  eOutputShuttle:
    Vortransport();
    Vortransport_Rueckwertig();

END_CASE

SensorenFreifahren();

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

(***************************************************************************************************)
(* FREIGABEN UND BAUSTEINAUFRUFE *)
(***************************************************************************************************)
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
                           OR bpStarteVorabPositionierung ) )
                           OR bpCheck
                           OR bpHandfahrenMinus
                           OR bpHandfahrenPlus
                           OR bpFahreReferenz
                           OR blStarteSlaveKopplung,
                     PT:= tgZeitAutoabschaltungEnergiesparModus );

// Aufruf Antrieb
Antrieb.bpFreigabe        := toflAutoAbschaltung.Q AND bpFreigabe AND blBausteinFreigabeAntrieb; 
Antrieb.stStationsNummern := stStationsNummern;
Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;

Antrieb_Slave.bpFreigabe        := toflAutoAbschaltung.Q AND bpFreigabe AND blBausteinFreigabeAntrieb;
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