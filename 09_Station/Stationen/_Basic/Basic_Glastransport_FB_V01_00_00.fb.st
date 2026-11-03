(* METADATA
{
  "v3Meta": {
    "objectGuid": "8cc859a4-3853-4716-ad69-f1a04cff8809"
  }
}
*)
FUNCTION_BLOCK Basic_Glastransport_FB_V01_00_00
VAR_INPUT

  // BOOL
  bpAktivieren                     : BOOL;
  bpEintransport                   : BOOL;
  bpEintransportRueckwaertig       : BOOL;
  bpAustransport                   : BOOL;
  bpAustransportRueckwaertig       : BOOL;
  bpVortransport                   : BOOL; 
  bpVortransportRueckwaertig       : BOOL;
  bpMesskopplung                   : BOOL;
  bpDurchtransport                 : BOOL;
  bpGlaslaengenmessung             : BOOL;
  bpHandfahrenPlus                 : BOOL;
  bpHandfahrenMinus                : BOOL;
  bpScheibeZurueckFahren           : BOOL;
  bpScheibeVorFahren               : BOOL;
  bpReferenz                       : BOOL;
  bpCheck                          : BOOL;
  bpReset                          : BOOL;
  bpAutomatikAktiv                 : BOOL;
  bpFreigabe                       : BOOL;
  bpMessrichtungNegativ            : BOOL; 
  bpCheckMitVorgaenger             : BOOL;
  bpCheckMitNachfolger             : BOOL; 
  bpRueckwaertigerTransport        : BOOL;
  bpScheibentrennen                : BOOL;
  bpAbbruchVortransport            : BOOL;
  
  // Sensoren
  bpSensorEinlauf                  : BOOL; 
  bpSensorEinlaufVorAb             : BOOL; 
  bpSensorAuslaufVorAb             : BOOL; 
  bpSensorAuslauf                  : BOOL; 

  // OPTIONEN 
  bpOptionMessungSystemCheckAktiv            : BOOL;
  bpOptionMasterSlaveTransport               : BOOL;
  bpOptionScheibenmessungEintransport        : BOOL;
  bpOptionAustransportISOLinie               : BOOL;
  bpOptionSlaveAntrieb                       : BOOL;
  bpOptionNachSystemcheckAufAuslaufsensor    : BOOL;
  bpOptionbScheibenmessungSensorVorabAuslauf : BOOL;

  // WORD 
  wlIndex : WORD := 0;
  
  // ENUM 
  eGlastyp : GlasTyp_EN;

  // STRUCT 
  InGlasTransportVorgaenger   : Interface_GlasTransport; // STRUKTUR: Informationen ueber den Aus- Ein- Transport der Vorgaengerstation
  InGlasTransportNachfolger   : Interface_GlasTransport; // STRUKTUR: Informationen ueber den Aus- Ein- Transport der Nachfolge- Station
  pAuftrag                    : Auftragsdaten_ST;            // AUFTRAG: Aktuelle daten zum Auftrag [Laenge, Hoehe, Modelle]
  stStationsNummern           : Station_ST;

  // POINTER 
  ppParameterBaustein          : REFERENCE TO Parameter_Glastransport;
  ppAntriebsInformationen      : REFERENCE TO AntriebsInformationen;
  ppAntriebsInformationenSlave : REFERENCE TO AntriebsInformationen; // Wird nur verwendet um die Box Nummer anzeigen zu lassen

  // Antrieb
  Antrieb       : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;
  Antrieb_Slave : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

END_VAR

VAR_OUTPUT

  // BOOL
  bpDone                        : BOOL;
  bpFehler                      : BOOL;
  bprtScheibe                   : BOOL; // Scheibenzaehler: Bool der wie ein Trigger genutzt wird
  bpStationBelegt               : BOOL;
  bpVerfahrFreigabe             : BOOL;
  bpScheibeFaehrtUeberAuslauf   : BOOL; // HINWEIS: Glas ist ueber den Auslauf-Sensor gefahren und somit in den Verfahrbereich des Transportshuttles -> Nehmen der Verfahrfreigabe fuer das Transportshuttles
  bpScheibeFaehrtUeberEinlauf   : BOOL;
  bpResetAbgeschlossen          : BOOL; // STATUS: Reset wurde abgeschlossen TRUE / FALSE
  bpOutBereitZumAustransport    : BOOL; // OUT STATUS: Bereit zum Austransport [Eintransport auf die Nachfolgerstation]
  bpOutBereitZumEintransport    : BOOL; // OUT STATUS: Bereit zum Eintransport [Austransport auf die Vorgaengerstation]
  bpFreigabeFremdprozess        : BOOL;
  bpSlaveAktiv                  : BOOL;
  bpDurchtransportWarAktiv      : BOOL;
  bpUebergrosseScheibeUebergang : BOOL;

  // WORD 
  wpFehlerNr                   : WORD;

  // DWORD 
  dwpWartezeit                 : DWORD; // STATISTIK: Zeitwerte fuer die Statistik zum auswerten

  // REAL 
  rpOutGeschwindigkeit         : REAL;
  rpGemesseneGlaslaenge        : REAL;  

END_VAR

VAR

  // HARDWARE EINGAENGE (vom Umrichter)
  in_bSensorEinlauf             : BOOL;
  in_bSensorEinlaufVorAb        : BOOL;
  in_bSensorAuslaufVorab        : BOOL;
  in_bSensorAuslauf             : BOOL;

  // BOOL 
  blErsterZyklus                : BOOL := TRUE;
  blScheibenMerker              : BOOL;
  blReduzierteGeschwindigkeit   : BOOL;
  blAntriebsKopplungAktiv       : BOOL;
  blStarteSlaveKopplung         : BOOL;
  
  // INT
  ilScheibenZaehler             : INT;
  ilIndexScheibenmessung        : INT := 1;

  // REAL 
  rlGefahreneStreckeEintransport    : REAL; // HINWEIS: Weg-Merker fuer die Strecke die beim Eintransport zurueck gelegt werden muss laut Auftrag
  rlPositionAntriebBeiStart         : REAL;
  rlGlasgewicht                     : REAL;
  rlPositionScheibenAnfangErkannt   : REAL;
  rlStreckeBisZurVerzoegerung       : REAL;
  rlScheibenMessung                 : ARRAY[1..10] OF REAL;

  // STEPS 
  steplEintransport             : Steps_TE;
  steplEintransportRueckwaertig : Steps_TE;
  steplAustransport             : Steps_TE;
  steplAustransportRueckwaertig : Steps_TE;
  steplVortransport             : Steps_TE;
  steplVortransportRueckwaertig : Steps_TE;
  steplDurchtransport           : Steps_TE;
  steplMesskopplung             : Steps_TE;
  steplGlaslaengenMessung       : Steps_TE;
  steplCheck                    : Steps_TE;
  steplReset                    : Steps_TE;
  steplReferenz                 : Steps_TE;
  steplSlave                    : Steps_TE;

  // TIMER
  toflAutoAbschaltung                       : TOF;
  toflEinlaufsensor                         : TOF;
  toflAuslaufsensor                         : TOF;
  tonlEinlaufsensor                         : TON; // Entprellung belegt (Flackern quittiert keine zweite Scheibe)
  tonlAuslaufsensor                         : TON; // Entprellung belegt (Flackern quittiert keine zweite Scheibe)
  toflVorAbStopSensorAuslauf                : TOF;
  toflVorAbStopSensorEinlauf                : TOF;
  tonlMaximaleZeitAuslaufsensorFreiFahren   : TON;
  tonlMaximaleZeitEinlaufsensorFreiFahren   : TON;
  tonlMaximaleZeitSensorAnfahren            : TON;
  tonlMaxWarteAufResetErfolgreich           : TON;
  tonlMaxWartezeitFremdanlage               : TON;
  tonlAntriebNichtBetriebsBereit            : TON;
  tonlSchrittueberwachung                   : TON;
  tonlUberwachungSlaveAktiv                 : TON;
  tonlSlaveKopplungDeaktiviert              : ton;
  tonlSlaveKopplungHerstellen               : TON; // Ueberwachung: Kopplung nicht hergestellt

  rtlMessungOK                              : R_TRIG;

  // TIME 
  tlWarteZeitAufnahme    : TIME; // STATISTIK

END_VAR

VAR_INPUT

  // BAUSTEINE
  Scheibenmessung  : Scheibenmessung_FB_V01_01_01;

END_VAR

VAR CONSTANT

  // TIME 
  cUEBERWACHUNG_SLAVE_AKTIV           : TIME := T#1S;
  cMAX_ZEIT_SLAVE_KOPPLUNG_HERSTELLEN : TIME := T#30S; // inkl. Referenzfahrt von Master und Slave

END_VAR

//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN

  IF ( __ISVALIDREF(ppAntriebsInformationen) ) THEN

    blErsterZyklus            := FALSE;
  
    // Antrieb referenzieren
    Antrieb       REF= pgAntriebe[ppAntriebsInformationen.wAchsID];
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
       - Für die Zielpunktkontrolle muss im ersten Zyklus die Zielposition initialisiert werden
    *)
    Antrieb.rpZielPosition := Antrieb.rpIstPosition;
    IF ( __ISVALIDREF(Antrieb_Slave) AND __ISVALIDREF(ppAntriebsInformationenSlave) ) THEN
      Antrieb_Slave.rpZielPosition := Antrieb_Slave.rpIstPosition;
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
// IO ZUWEISUNG
//-------------------------------------------------------------------------------------------------
in_bSensorEinlauf      := Antrieb.udipEingaengeUmrichter.cXG31_1_I_1;
in_bSensorEinlaufVorAb := Antrieb.udipEingaengeUmrichter.cXG31_6_I_4;
in_bSensorAuslaufVorab := Antrieb.udipEingaengeUmrichter.cXG31_7_I_5;
in_bSensorAuslauf      := Antrieb.udipEingaengeUmrichter.cXG31_2_I_2;

bpSensorEinlauf      := in_bSensorEinlauf;
bpSensorEinlaufVorAb := in_bSensorEinlaufVorAb;
bpSensorAuslaufVorab := in_bSensorAuslaufVorab;
bpSensorAuslauf      := in_bSensorAuslauf;

//-------------------------------------------------------------------------------------------------
// TIMER, SETTINGS, ETC.
//-------------------------------------------------------------------------------------------------
// Sensorenflackern
toflEinlaufsensor(IN := bpSensorEinlauf, PT := T#50MS);
toflAuslaufsensor(IN := bpSensorAuslauf, PT := T#50MS);
tonlEinlaufsensor(IN := bpSensorEinlauf, PT := T#50MS);
tonlAuslaufsensor(IN := bpSensorAuslauf, PT := T#50MS);
toflVorAbStopSensorEinlauf(IN := bpSensorEinlaufVorab, PT := t#50ms);
toflVorAbStopSensorAuslauf(IN := bpSensorAuslaufVorAb, PT := t#50ms);

// Reset
tonlMaxWarteAufResetErfolgreich(IN:=bpReset,pt:=tgMaxWartezeitReset-T#1S);

//-------------------------------------------------------------------------------------------------
// AUFRUFE
//-------------------------------------------------------------------------------------------------
// 2. Riemen/Rollen vorhanden -> Kipptisch
//   - Vor den Schrittketten, damit diese die Kopplung im selben Zyklus sehen
//   - Kopplung gilt erst, wenn der Slave synchron ist UND seine Kette die Kopplung hergestellt hat
IF bpOptionSlaveAntrieb THEN
  SlaveAntrieb();
  blAntriebsKopplungAktiv := Antrieb_Slave.bpAchseSychron AND blStarteSlaveKopplung;
ELSE
  blAntriebsKopplungAktiv := TRUE;
END_IF

Eintransport();
Eintransport_Rueckwaertig();
Vortransport();
Vortransport_Rueck();
Durchtransport();
Messkopplung();
SystemCheck();
Referenz();
Handfunktionen();
Meldungen();
Reset();

IF ( NOT bpOptionMasterSlaveTransport ) THEN
  IF bpOptionAustransportISOLinie THEN
    Austransport_ISO();
  ELSE
    Austransport();
    Austransport_Rueckwaertig();
  END_IF
ELSE
  Austransport_MasterSlave();
  Austransport_Rueckwaertig_MasterSlave();
END_IF


//-------------------------------------------------------------------------------------------------
// FREIGABEN UND AUFRUFE
//-------------------------------------------------------------------------------------------------
// Glastransportfreigabe
//   - Freigabe
toflAutoAbschaltung( IN := (  bpAutomatikAktiv
                             AND ( bpAustransport
                                   OR bpAustransportRueckwaertig
                                   OR bpEintransport
                                   OR bpEintransportRueckwaertig
                                   OR bpVortransport
                                   OR bpVortransportRueckwaertig
                                   OR bpMesskopplung
                                   OR bpDurchtransport
                                   OR bpGlaslaengenmessung
                                 ) )
                     OR bpCheck
                     OR bpHandfahrenMinus
                     OR bpHandfahrenPlus
                     OR bpScheibeZurueckFahren
                     OR bpReferenz,
                     PT:= tgZeitAutoabschaltungEnergiesparModus );

// Aufruf:
//   - Antriebe
//   - Scheibenmessung
Antrieb.bpFreigabe        := toflAutoAbschaltung.Q AND bpFreigabe;
Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;
Antrieb.stStationsNummern := stStationsNummern;

IF bpOptionSlaveAntrieb THEN
  Antrieb_Slave.bpFreigabe        := Antrieb.bpFreigabe;
  Antrieb_Slave.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;
  Antrieb_Slave.stStationsNummern := stStationsNummern;
END_IF

Scheibenmessung( stStationsNummern                   := stStationsNummern,
                 ppAntrieb                           := Antrieb,
                 pbpVorstopSensor                    := bpSensorAuslaufVorab,
                 pbpEinlaufSensor                    := bpSensorEinlauf,
                 bpDrehrichtungsumkehrMessung        := bpMessrichtungNegativ,
                 rpMessstrecke                       := ppParameterBaustein.rMessstrecke,
                 ppAntriebsInformationen             := ppAntriebsInformationen,
                 bpAuswahlSensorVorabScheibenmessung := bpOptionbScheibenmessungSensorVorabAuslauf,
                 rpFaktorBremswegverlaengern         := 1.6 ) ;

//-------------------------------------------------------------------------------------------------
// AKTION AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Ausgaeng:
//   - Aktuelle Geschwindigkeit des Antriebs
//     -> Soll- Wertkopplung ( Soll-Geschwindigkeit des Antriebs)
//     -> Ist- Wertkopplung ( Soll-Geschwindigkeit des Antriebs)
IF ( ( bpEintransport OR bpEintransportRueckwaertig ) AND bpOutBereitZumEintransport )THEN
  rpOutGeschwindigkeit :=  ABS(Antrieb.rpGeschwindigkeit);
ELSE
  rpOutGeschwindigkeit :=  ABS(Antrieb.rpIstGeschwindigkeit);
END_IF

// Freigabe für eine Bewegung
bpVerfahrFreigabe :=  NOT ( bpSensorEinlauf 
                            OR bpSensorAuslauf 
                            OR bpEintransport 
                            OR bpAustransport );
END_FUNCTION_BLOCK