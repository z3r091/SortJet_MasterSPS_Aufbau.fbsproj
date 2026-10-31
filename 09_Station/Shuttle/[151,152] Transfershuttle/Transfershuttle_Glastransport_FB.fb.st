(* METADATA
{
	"v3Meta": {
		"objectGuid": "2254a377-1dbb-47e5-a6cb-497511b1e2ee"
	}
}
*)
FUNCTION_BLOCK Transfershuttle_Glastransport_FB
VAR_INPUT

  // BOOLEAN
  bpAktivieren                                       : BOOL;
  bpEintransport                                     : BOOL;
  bpAustransport                                     : BOOL; 
  bpVortransport                                     : BOOL; 
  bpFahreReferenz                                    : BOOL; 
  bpAutomatikAktiv                                   : BOOL;
  bpSlaveKopplung                                    : BOOL;
  bpCheck                                            : BOOL;
  bpReset                                            : BOOL;
  bpShuttleVerfaehrt                                 : BOOL;
  bpHand                                             : BOOL;
  bpFreigabe                                         : BOOL;
  bpLetzteScheibe                                    : BOOL;
  bpShuttleAbsenken                                  : BOOL;
  bpCheckMitVorgaenger                               : BOOL;
  bpCheckMitNachfolger                               : BOOL;
  bpHandfahrenPositiv                                : BOOL;
  bpHandfahrenNegativ                                : BOOL;
  bpHandGlastransportAnheben                         : BOOL;
  bpHandScheibenKontrolleEinlaufseiteAnheben         : BOOL;
  bpHandScheibenKontrolleAuslaufseiteAnheben         : BOOL;
  bpHandScheibenKontrolleEinlaufseiteEin             : BOOL;
  bpHandScheibenKontrolleAuslaufseiteEin             : BOOL;
  bpStarteHebeVorgang                                : BOOL;
  bpRueckwaertsEintransportieren                     : BOOL;
  bpRueckwaertsAustransportieren                     : BOOL;
  bpGlastransportTest                                : BOOL;
  bpShuttleDeaktivieren                              : BOOL;
  bpSpeicherfachValidierung                          : BOOL; (* Betriebsmodus: Speicherfach wird ueberprueft ob beide Luftabfragen frei und somit kein Glas uebersteht *)
  bpScheibentrennung                                 : BOOL := FALSE;
  bpAnforderungTransportkopplung                     : BOOL := FALSE;
  blSensorGlastransportOben                          : BOOL;
  blSensorGlastransportUnten                         : BOOL;
  bpSensorScheibenKontrolleAuslaufSeiteOben          : BOOL;
  bpSensorScheibenKontrolleAuslaufSeiteUnten         : BOOL;
  bpSensorScheibenKontrolleAuslaufSeiteFrei          : BOOL; (* Oeffner *)
  bpSensorScheibenKontrolleEinlaufSeiteOben          : BOOL;
  bpSensorScheibenKontrolleEinlaufSeiteUnten         : BOOL;
  bpSensorScheibenKontrolleEinlaufSeiteFrei          : BOOL; (* Oeffner *)
  blDruckluftEinlaufSeiteOK                          : BOOL;
  blDruckluftAuslaufSeiteOK                          : BOOL;
  bpTransfershuttleVerbundAktiv                      : BOOL := FALSE; (* Hinweis: Transferverbund zwischen 2 Transvershuttle aktiv *)
  bpOptionSensorEinlauf                              : BOOL := TRUE;  (* Hinweis: Option ob der Sensorvorhanden ist  *)
  bpOptionSensorAuslauf                              : BOOL := TRUE;  (* Hinweis: Option ob der Sensorvorhanden ist  *)
  bpScheibenNeuAusrichten                            : BOOL;
  bpOptionTransfershuttleMitFaecherwagen             : BOOL;
  bpOptionTransfershuttleMitUltraschallSensoren      : BOOL;
  bpOptionMasterSlaveAustransport                    : BOOL;
  bpOptionTransfershuttleFaecherwagenKurzeScheibenTieferEintransportieren : BOOL;

  // WORD 
  wpSystemCheckMitStation : WORD;
  wpSystemCheckMitWand    : WORD;


  // REAL 
  rpVorpositionierweg : REAL; (* Auftragsdaten: Der Weg der Vorpositioniert werden soll *)

  // STRUCT 
  InGlasTransportVorgaenger   : Interface_GlasTransport; (* STRUKTUR: Informationen ueber den Aus- Ein- Transport der Vorgaengerstation  *)
  InGlasTransportNachfolger   : Interface_GlasTransport; (* STRUKTUR: Informationen ueber den Aus- Ein- Transport der Nachfolge- Station *)
  stpInTransportVerbund       : Interface_TransfershuttleVerbund;
  pAuftrag                    : Auftragsdaten_ST;        (* AUFTRAG: Aktuelle daten zum Auftrag [Laenge, Hoehe, Modelle] *)
  pSystemCheckDaten           : Auftragsdaten_ST;        (* Hinweis: Daten fuer den SystemCheck *)
  stMasterSlaveConfig         : MasterSlaveConfig_ST;
  stStationsNummern           : Station_ST;
  
  // POINTER 
  ppParameterBaustein     : REFERENCE TO Parameter_TransfershuttleGlastransport;
  ppAntriebsInformationen : REFERENCE TO AntriebsInformationen;

END_VAR
VAR_OUTPUT

  // BOOLEAN 
  bpDone                                 : BOOL;
  bpFehler                               : BOOL;
  bpAktiv                                : BOOL;
  bpSlaveAktiv                           : BOOL;
  bpBereitZumVerfahren                   : BOOL := FALSE;
  bpScheibeFaehrtUeberAuslauf            : BOOL; (* Variable zum nehmen der Verfahrfreigabe des Shuttles da Glas in den Verfahrbereich liegen koennte *)
  bpScheibeFaehrtUeberEinlauf            : BOOL; (* Variable zum nehmen der Verfahrfreigabe des Shuttles da Glas in den Verfahrbereich liegen koennte *)
  bpAnforderungBetriebsstopp             : BOOL; (* Hinweis: Anforderung zum setzen des Betriebsstopps fuer die Auslaufseite des Transfershuttles *)
  bprtScheibe                            : BOOL; (* Scheibenzaehler, funktion wie ein Trigger *)
  bpOutBereitZumAustransport             : BOOL;
  bpOutBereitZumEintransport             : BOOL;
  bpSpeicherfachValidierungAbgeschlossen : BOOL;
  bpSensorEinlauf                        : BOOL; (* Sensorik Ausgang: Setzen der Sensorik fuer die Transportkopplung *)
  bpSensorAuslauf                        : BOOL; (* Sensorik Ausgang: Setzen der Sensorik fuer die Transportkopplung *)

  // WORD 
  wpFehlerNr              : WORD;
  wpAusnahmefehlerTyp     : WORD := WORD#0; (* Sensorfehlertyp: 0 = Allgemeiner Fehler / 1 = Einlauf / 2 = Auslauf / 3 = Ein- Aus- Lauf *)
  
  // DWORD 
  dwpWartezeit : DWORD;

  // REAL 
  rpOutGeschwindigkeit   : REAL; (* OUT STATUS: Aktuelle Geschwindigkeit *)
  rpVorpositionierterWeg : REAL; (* OUT STATUS: Beschreibt den Weg der Vorpositioniert wurde *)

  // STRUCT 
  stpOutTransportVerbund : Interface_TransfershuttleVerbund;

END_VAR
VAR

  (* BOOLEAN *)
  blErsterZyklus                               : BOOL := TRUE;
  blBereitZumGlastransport                     : BOOL := FALSE;
  blEinlaufSensor                              : BOOL; (* entprellter Eingangssensor *)
  blAuslaufSensor                              : BOOL; (* entprellter Ausgangssensor *)
  blScheibenMerker                             : BOOL := FALSE; (* Scheibe lag nach dem Positionieren noch auf dem Einlaufsensor => Quittung beim Freifahren *)
  blFehlerAusloesen                            : BOOL; (* Hinweis: Es muss ggf ein Fehler ausgeloest werden wenn ein Sensor angefahren und programmgesteuert wieder Freigefahren wurde *)
  blMeldungAuslaufAbfrageBelegt                : BOOL := FALSE; (* Hinweis: Sensorik beim Pruefen belegt *)
  blMeldungEinlaufAbfrageBelegt                : BOOL := FALSE; (* Hinweis: Sensorik beim Pruefen belegt *)
  blSensorPruefungEinlaufsensorBelegt          : BOOL := FALSE;
  blAbgeschlossenAustransport                  : BOOL := FALSE;
  blAbgeschlossenEintransport                  : BOOL := FALSE;
  blEintransportDefaultLuftabfrage             : BOOL := FALSE;
  blAustransportDefaultLuftabfrage             : BOOL := FALSE;
  blSchnittstelle_bBereitZumTransportVerbund   : BOOL := FALSE;
  blSchnittstelle_bAnforderungTransportVerbund : BOOL := FALSE;
  blScheibenKontrolleEinlaufseiteEin           : BOOL;
  blScheibenKontrolleAuslaufseiteEin           : BOOL;
  blReduzierteGeschwindigkeit                  : BOOL;


  (* WORD *)
  wlSubIndex : WORD;

  (* INT *)
  ilScheibenZaehler                          : INT; (* Scheibenzaehlen *)

  (* REAL *)
  rlAntriebsPositionBeiStart                 : REAL;
  rlAntriebsPositionStartVortransport        : REAL; (* Ist-Position beim Start Vortransport fuer rpVorpositionierterWeg *)
  rlAntriebspositionBeiAuslaufSensorBelegung : REAL;
  rlAntriebspositionBeiEinlaufSensorBelegung : REAL;
  rlWegDifferenzNachStopSensorBelegung       : REAL;
  rlAntriebIstPosition1                      : REAL;
  rlAntriebIstPosition2                      : REAL;
  rlAntriebIstPosition3                      : REAL;
  rlPositionScheibenAnfangErkannt            : REAL;
  rlZielPosition                             : REAL;
  rlStreckeBisZurVerzoegerung                : REAL;
  rlGlasgewicht                              : REAL;

  (* STEPS *)
  steplEintransport                   : Steps_TE;
  steplAustransport                   : Steps_TE;
  steplVortransport                   : Steps_TE;
  steplReset                          : Steps_TE;
  steplReferenz                       : Steps_TE;
  steplCheck                          : Steps_TE;
  steplHebeVorgang                    : Steps_TE;
  steplScheibeZueruck                 : Steps_TE;
  steplGlastransporttest              : Steps_TE;
  steplSpeicherfachValidierung        : Steps_TE;
  steplEintransportDefaultLuftabfrage : Steps_TE;
  steplAustransportDefaultLuftabfrage : Steps_TE;
  steplSlave                          : Steps_TE;
  steplScheibenNeuAusrichten          : Steps_TE;

  (* FLANKEN *)
  rtriglFehlerAktiv                   : R_TRIG; (* Fehler-Bit Triggern *)
  ftriglAuslaufsensorBelegt           : F_TRIG; (* fallende Flanke: Auslaufsensor wurde angefahren *)
  ftriglEinlaufsensorBelegt           : F_TRIG; (* fallende Flanke: Einlaufsensor wurde angefahren *)

  (* TIMER *)
  tonlGlastransportOben                             : TON; 
  tonlAntriebNichtFreigegeben                       : TON; 
  tonlUeberwachungSensorFreifahren                  : TON; 
  tonlGlastransportUnten                            : TON; 
  tonlKontrolleEinlaufOben                          : TON;
  tonlKontrolleEinlaufUnten                         : TON;
  tonlKontrolleAuslaufOben                          : TON;
  tonlKontrolleAuslaufUnten                         : TON;
  tonlWartenAufAnheben                              : TON; 
  tonlWartenAufSenken                               : TON; 
  tonlEinlaufWirklichFrei                           : TON; 
  tonlEinlaufsensorTesten                           : TON; 
  tonlAuslaufsensorTesten                           : TON; 
  tonlMaxWarteAufResetErfolgreich                   : TON; 
  tonlEinlaufsensor                                 : TON; 
  tonlAuslaufsensor                                 : TON; 
  tonlUberwachungSlaveAktiv                         : TON; 
  tonlSensorScheibenKontrolleAuslaufSeiteFrei       : TON; 
  tonlSensorScheibenKontrolleEinlaufSeiteFrei       : TON; 
  toflEinlaufsensor                                 : TOF; 
  toflAuslaufsensor                                 : TOF; 
  toflEinlaufsensorFreiFahren                       : TOF; 
  toflAutoAbschaltung                               : TOF; 
  toflAntriebLaeuft                                 : TOF;

  (* BAUSTEINE *)
  Scheibenzaehler : ScheibenZaehler_FB;

  // Antrieb
  Antrieb : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

END_VAR
VAR

  (* HARDWARE - AUSGAENGE *)
  out_bShuttleAnheben                                        : BOOL;
  out_bScheibenKontrolleEinlaufSeiteAuf                      : BOOL; (* AUSGAENGE: Luftabfragen heben/senken*)
  out_bScheibenKontrolleEinlaufSeiteEinschalten              : BOOL;
  out_bScheibenKontrolleAuslaufSeiteAuf                      : BOOL; (* AUSGAENGE: Luftabfragen heben/senken*)
  out_bScheibenKontrolleAuslaufSeiteEinschalten              : BOOL;

END_VAR
VAR CONSTANT

  (* TIME *)
  cZEIT_SENSORIK_FREIFAHREN           : TIME := T#10s;
  cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE : TIME := T#5S;
  cZEIT_SENSORIK_FREI                 : TIME := T#250ms;
  cZEIT_UEBERWACHUNG_SLAVE_AKTIV      : TIME := T#10s;

END_VAR

(***************************************************************************************************)
(* INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN

  IF ( __ISVALIDREF(ppAntriebsInformationen) ) THEN

    blErsterZyklus := FALSE;

    Antrieb REF= pgAntriebe[ppAntriebsInformationen.wAchsID];

    (* Hinweis:
       - Initialisierung Antriebsinformationen
    *)
    Antrieb.ppAntriebsInformationen REF= ppAntriebsInformationen;

    (* Hinweis:
       - Für die Zielpunktkontrolle muss im ersten Zyklus die Zielposition initialisiert werden
    *)
    Antrieb.rpZielPosition := Antrieb.rpIstPosition;

    (* Hinweis:
       - Antriebswerte vorinitialisieren
    *)
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
    Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
    Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
    Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;

  ELSE
    RETURN;
  END_IF

END_IF

(***************************************************************************************************)
(* DEAKTIVIEREN *)
(***************************************************************************************************)
IF ( NOT bpAktivieren ) THEN

  bpDone := TRUE;

  (* Hinweis:
     - Ausnahmesituationen 
  *)
  bpFehler   := FALSE;
  wpFehlerNr := WORD#0;

  RETURN;

END_IF

(***************************************************************************************************)
(* BAUSTEIN: SCHNITTSTELLE *)
(***************************************************************************************************)
(* Hinweis:
   - Schnittstelle zwischen den Unterflur-Shuttle wenn diese zusammen arbeiten sollen
*)
stpOutTransportVerbund.wpMmiNummer                  := stStationsNummern.NummerSPS;
stpOutTransportVerbund.bEinlaufsensor               REF= bgFALSE;
stpOutTransportVerbund.bAuslaufsensor               REF= bgFALSE;
stpOutTransportVerbund.bMasterSlaveVerbundAktiv     REF= bpSlaveAktiv; (* Slave ist mit dem Master gekoppelt *); (* Slave ist mit dem Master gekoppelt *)
stpOutTransportVerbund.bBereitZumTransportVerbund   REF= blSchnittstelle_bBereitZumTransportVerbund;
stpOutTransportVerbund.bAnforderungTransportVerbund REF= blSchnittstelle_bAnforderungTransportVerbund;
stpOutTransportVerbund.rGeschwindigkeit             REF= rpOutGeschwindigkeit;
stpOutTransportVerbund.bFehler                      REF= bpFehler;


(***************************************************************************************************)
(* BAUSTEIN: SENSOREN \ TIMER \ GESCHWINDIGKEITEN \ ETC.  *)
(***************************************************************************************************)
(* [TIMER] Allgemein:
*)
toflAntriebLaeuft(IN:=Antrieb.bpAntrieblaeuft, PT := T#350MS);

(* [TIMER] Kontrolle Sensoren:
   - Glastransport Unten | Oben
*)
tonlGlastransportOben(IN := blSensorGlastransportOben, PT := t#500ms);
tonlGlastransportUnten(IN := blSensorGlastransportUnten , PT := t#500ms);



(* ---------------------------------------------------------------------------------------
//  TRANSFERSHUTTLE MIT EINEM LUFTABFRAGEN TYP
//         
//  Hinweis:
// - n/c
// ---------------------------------------------------------------------------------------*)

(* LUFTABFRAGEN [3- 12 MM]
   - [TIMER] Kontrolle Sensoren:
     => Einlauf- Sensoren [ Luftsenoren] Frei | Belegt
     => Auslauf- Sensoren [ Luftsenoren] Frei | Belegt
*)
toflEinlaufsensor(IN:= bpSensorScheibenKontrolleEinlaufseiteFrei, PT := t#50ms);
tonlEinlaufsensor(IN:= NOT bpSensorScheibenKontrolleEinlaufseiteFrei, PT := t#100ms);

toflAuslaufsensor(IN:= bpSensorScheibenKontrolleAuslaufSeiteFrei, PT := t#50ms);
tonlAuslaufsensor(IN:= NOT bpSensorScheibenKontrolleAuslaufSeiteFrei, PT := t#100ms);

(* LUFTABFRAGEN [3- 12 MM]
   - [TIMER] Kontrolle Sensoren:
     => Einlauf- Sensoren [ Luftsenoren] Unten | Oben
     => Auslauf- Sensoren [ Luftsenoren] Unten | Oben
*)
tonlKontrolleEinlaufUnten(IN := bpSensorScheibenKontrolleEinlaufseiteUnten, PT := T#500MS);
tonlKontrolleEinlaufOben(IN := bpSensorScheibenKontrolleEinlaufseiteOben, PT := T#500MS);

tonlKontrolleAuslaufUnten(IN := bpSensorScheibenKontrolleAuslaufseiteUnten, PT := T#500MS);
tonlKontrolleAuslaufOben(IN := bpSensorScheibenKontrolleAuslaufseiteOben, PT := T#500MS);

(* LUFTABFRAGEN [3- 12 MM]
   - Sensorik freifahren
*)
toflEinlaufsensorFreiFahren(IN:= bpSensorScheibenKontrolleEinlaufseiteFrei, PT := t#50ms);
tonlEinlaufWirklichFrei(IN:= NOT blEinlaufsensor, PT := t#500ms);


(* LUFTABFRAGEN [3- 12 MM]
   - Sensoren:
     => Einlauf / Auslauf
*)
blEinlaufsensor := NOT toflEinlaufsensor.Q AND ( blDruckluftEinlaufSeiteOK OR bpOptionTransfershuttleMitUltraschallSensoren );
blAuslaufsensor := NOT toflAuslaufsensor.Q AND ( blDruckluftAuslaufSeiteOK OR bpOptionTransfershuttleMitUltraschallSensoren );

(* Hinweis [3- 12 MM]:
   - Abfrage ob die Station bereit fuer den Glastransport ist 
*)
blBereitZumGlastransport := (    tonlGlastransportOben.Q
        	                   AND tonlKontrolleEinlaufOben.Q
	                           AND ( blDruckluftAuslaufSeiteOK OR bpOptionTransfershuttleMitUltraschallSensoren )
	                           AND tonlKontrolleAuslaufOben.Q
                             AND ( blDruckluftEinlaufSeiteOK OR bpOptionTransfershuttleMitUltraschallSensoren ) );


(***************************************************************************************************)
(* BAUSTEIN: AKTIONEN  *)
(***************************************************************************************************)
(* Hinweis:
   - Aktion zur Abhandlung von Transfershuttle mit nur einer physikalisch verbauten
     Luftabfrage
*)
Steuerung_OptionaleLuftabfragen();


(* Hinweis:
  - Aufruf der Aktion SystemCheck
    - Starten des SystemChecks mittels Riemen
*)
Systemcheck();

(* Aktion [Automatik]:
   - Starten der Automatik- Aktionen
     => Eintransport
     => Austransport
     => etc.
*)
Eintransport();
Eintransport_Default_Luftabfrage();

Austransport();
Austansport_Default_Luftabfrage();

SlaveBetrieb();

HebeVorgang();

SpeicherTest();

SpeicherfachValidierung();

Vortransport();

ScheibenNeuAusrichten();

(* Aktion[Basis]:
   - Basis Bausteinaktionen
*)
Reset();
Referenz();
Meldungen();
Handfunktionen();
SteuerungLuftschranken();



(***************************************************************************************************)
(* BAUSTEIN: VORTRANSPORT [SPEICHER]  *)
(***************************************************************************************************)
IF ( bpShuttleAbsenken ) THEN
   out_bShuttleAnheben := FALSE;
   out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
   blScheibenKontrolleAuslaufseiteEin    := FALSE;
   out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
   blScheibenKontrolleEinlaufseiteEin    := FALSE;

   bpShuttleAbsenken := FALSE;
END_IF



(***************************************************************************************************)
(* BAUSTEIN: ZUWEISUNGEN UND AUFRUFE *)
(***************************************************************************************************)
(* Glastransportfreigabe
*)
toflAutoAbschaltung( IN := (  bpAutomatikAktiv
                           AND ( bpEintransport
                           OR bpAustransport
					       OR bpStarteHebeVorgang
                           OR bpVortransport))
                           OR bpCheck
                           OR bpSlaveKopplung
                           OR bpSpeicherfachValidierung
                           OR bpScheibenNeuAusrichten
                           OR bpHandfahrenPositiv
                           OR bpHandfahrenNegativ
                           OR bpFahreReferenz,
                     PT:=( WORD_TO_TIME(ppParameterBaustein.wEnergieSparZeit)*1000) );

Antrieb.bpFreigabe            := toflAutoAbschaltung.Q AND bpFreigabe;
Antrieb.stStationsNummern     := stStationsNummern;
Antrieb.rpRuckzeit            := ppAntriebsInformationen.rpMaxRuckzeit;

// Scheibenzaehler [ Aufruf \ Zuweisung ]
Scheibenzaehler( ipScheibenAnzahl := ilScheibenZaehler,
                 bpSensor         := blEinlaufsensor );


(***************************************************************************************************)
(* BAUSTEIN: AUSGAENGE  *)
(***************************************************************************************************)

(* VERFAHRFREIGABE [3- 12 MM]:
 - Bit ob das Transfershuttle verfahren darf
*)
bpBereitZumVerfahren := (     blSensorGlastransportUnten
						AND NOT blSensorGlastransportOben
						AND tonlKontrolleEinlaufUnten.Q
						AND NOT bpSensorScheibenKontrolleEinlaufseiteOben
						AND tonlKontrolleAuslaufUnten.Q
						AND NOT bpSensorScheibenKontrolleAuslaufseiteOben );

(* Ausgaeng:
   - Aktuelle Geschwindigkeit des Antriebs
     -> Soll- Wertkopplung ( Soll-Geschwindigkeit des Antriebs)
     -> Ist- Wertkopplung ( Soll-Geschwindigkeit des Antriebs)
*)
IF  ( ( bpEintransport OR bpRueckwaertsEintransportieren ) AND bpOutBereitZumEintransport )
  OR ( bpCheck AND bpOutBereitZumEintransport )
THEN
  rpOutGeschwindigkeit := Antrieb.rpGeschwindigkeit;
ELSE
  rpOutGeschwindigkeit := Antrieb.rpIstGeschwindigkeit;
END_IF


(* Ausgaenge:
   - Sensorik als out-Variablen bereitstellen
     => Uebergabe der Werte fuer die Transportkopplung (Stationsinterface)
*)
bpSensorEinlauf := blEinlaufSensor;
bpSensorAuslauf := blAuslaufSensor;

(* Glastransport [Transfershuttle] arbeitet oder ist gehoben
   - in Progress
*)
bpAktiv := (   bpEintransport
            OR bpAustransport
            OR bpVortransport
            OR bpSlaveKopplung
            OR bpScheibenNeuAusrichten
            OR bpStarteHebeVorgang
            OR bpCheck
            OR bpDone );

(***************************************************************************************************)
(* BAUSTEIN: FEHLERNUMMER GENERIEREN BEI EINEM TRANSFERSHUTTLE- FEHLER  *)
(***************************************************************************************************)
(* Hinweis:
   - Ausnahmesituation
*)
rtriglFehlerAktiv(CLK := bpFehler );

IF ( rtriglFehlerAktiv.Q ) THEN

  CASE wpFehlerNr OF

    cMELDUNG_SENSOR_EINLAUF_BELEGT,
    cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_BELEGT,
    cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT,
    cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI,
    cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_NICHT_FREI:
      wpAusnahmefehlerTyp  := cAUSNAHMESITUATION_EINLAUFSENSOR;


    cMELDUNG_SENSOR_AUSLAUF_BELEGT,
    cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT,
    cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI,
    cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_BELEGT,
    cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI,
    cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_ODER_AUSLAUF_BELEGT_FREIFAHREN:
      wpAusnahmefehlerTyp := cAUSNAHMESITUATION_AUSLAUFSENSOR;


    cMELDUNG_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT,
    cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT,
    cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT:
      wpAusnahmefehlerTyp := cAUSNAHMESITUATION_EINLAUF_AUSLAUF_SENSOR;


    ELSE
      wpAusnahmefehlerTyp := cAUSNAHMESITUATION_KEIN_SENSOR;

  END_CASE

END_IF


(***************************************************************************************************)
(* BAUSTEIN: SICHERHEIT   *)
(***************************************************************************************************)
(* Anmerkung:
   - Sollte eine Fahrt anstehen duerfen Glastransport und Luftabfragen nicht angehoben werden!
     [Doppelte Sicherheit ] 
*)
out_bScheibenKontrolleAuslaufSeiteAuf := out_bScheibenKontrolleAuslaufSeiteAuf AND NOT bpShuttleVerfaehrt;
out_bScheibenKontrolleEinlaufSeiteAuf := out_bScheibenKontrolleEinlaufSeiteAuf AND NOT bpShuttleVerfaehrt;

out_bShuttleAnheben := out_bShuttleAnheben AND NOT bpShuttleVerfaehrt;
END_FUNCTION_BLOCK