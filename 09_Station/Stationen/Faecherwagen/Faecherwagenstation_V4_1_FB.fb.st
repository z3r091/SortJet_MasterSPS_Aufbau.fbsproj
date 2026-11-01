(* METADATA
{
  "v3Meta": {
    "objectGuid": "3779c208-854f-4c13-8b26-aa1147fe8cdb"
  }
}
*)
FUNCTION_BLOCK Faecherwagenstation_V4_1_FB
VAR_IN_OUT

  // STRUKT 
  BasisStationsParameter : StationBasisParameter_ST;

END_VAR
VAR_INPUT
 
  // BOOL
  blMerkerEinschleusenQuittiert           : BOOL;
  blRolltorUnten                          : BOOL;//Eingang von der Sicherheitstechnik, das das Rolltor unten ist
  bpLichtschranke_OK                      : BOOL;// Eingang aus der Sicherheitsteechnik das die Lichtschrnake quittiert ist
  bpUntergestellErkannt                   : BOOL;//safety eingang der Anzeigt, ob ein Unterwagen erkannt wurde
  in_bDruckluftOK                         : BOOL;
  bpLichtschrankeWartetAufQuittierungAmOP : BOOL;

  // DWORD 
  dwpHandfunktionen : DWORD;  // Handfunktionen: 0..31 Bit
  
  // WORD
  wlRFID_Nummer_Schreiben : WORD;
  
  // USINT
  usilErrorSafety : USINT;

END_VAR
VAR_OUTPUT

  // BOOL
  bpDone                            : BOOL;
  bpEinschleusenAbgeschlossen       : BOOL;
  bpAusschleusenAbgeschlossen       : BOOL;
  bpAuftragAktiv                    : BOOL;
  bpFehler                          : BOOL;
  bpErzwingeAusschleusen            : BOOL;
  bpErzwingeEinschleusen            : BOOL;
  bpBoxInHomePosition               : BOOL;
  bpOutBereitZumAustransport        : BOOL; // OUT STATUS: Bereit zum Austransport [Eintransport auf die Nachfolgerstation]
  bpOutBereitZumEintransport        : BOOL; // OUT STATUS: Bereit zum Eintransport [Austransport auf die Vorgaengerstation]
  bpStatusStationInBeladePosition   : BOOL; (* Hinweis: Zyklische Abfrage ob der Faecherwagen noch in der Beladeposition ist *);
  
  // WORD
  wpFehlerNr                        : WORD; // FEHLER-AUSWERTUNG: Fehlernummer[Const]
  
END_VAR
VAR

  // BOOLEAN 
  blErsterZyklus                   : BOOL := TRUE; // Init
  blBetriebsartHand                : BOOL; // Betriebsart
  blBetriebsartReset               : BOOL; // Betriebsart
  blBetriebsartCheck               : BOOL; // Betriebsart
  blBetriebsartAutomatik           : BOOL; // Betriebsart
  blBetriebsartReferenz            : BOOL; // Betriebsart
  
  //Startet eine Bewegung
  blLineareinheitVor               : BOOL;
  blLineareinheitZurueck           : BOOL;
  blLineareinheitShuttle           : BOOL;
  blEntriegelungOeffnen            : BOOL;
  blEntriegelungSchliessen         : BOOL;
  blGegenhalterOeffnen             : BOOL;
  blGegenhalterSchliessen          : BOOL;
  blGreiferOeffnen                 : BOOL;
  blGreiferSchliessen              : BOOL;
  blRolltorAuf                     : BOOL;
  blRolltorAb                      : BOOL;
  blTagPresent                     : BOOL;
  
  //Bewegungen Abgeschlossen
  blLineareinheitVorDone           : BOOL;
  blLineareinheitZurueckDone       : BOOL;
  blLineareinheitShuttleDone       : BOOL;
  blEntriegelungOeffnenDone        : BOOL;
  blEntriegelungSchliessenDone     : BOOL;
  blGegenhalterOeffnenDone         : BOOL;
  blGegenhalterSchliessenDone      : BOOL;
  blGreiferOeffnenDone             : BOOL;
  blGreiferSchliessenDone          : BOOL;
  blRolltorAufDone                 : BOOL;
  blRolltorAbDone                  : BOOL;
  blLuftAbschaltungS1              : BOOL;
  blLuftAbschaltungS2              : BOOL;
  blVentilReset                    : BOOL;
  
  // jeweils Zusammenfassung der beiden Eingänge
  blLinearEinheitVorne             : BOOL;  
  blLinearEinheitHinten            : BOOL;
  blLinearEinheitSH                : BOOL;
  blGreiferOffen                   : BOOL;
  blGreiferZu                      : BOOL;
  
  //Verschiedenes  
  blStationsposUndefiniert         : BOOL;
  blTasterLeuchteAnforderung       : BOOL;
  blRFID_Auslesen                  : BOOL;
  blRFID_Schreiben                 : BOOL;
  blRFID_Sensor_ModusBit_0         : BOOL;
  blRFID_Sensor_ModusBit_1         : BOOL;
  blRFID_Sensor_ModusBit_2         : BOOL;
  blRFID_Sensor_ModusBit_3         : BOOL;
  blRFID_Sensor_ModusBit_4         : BOOL;
  blRFID_Sensor_ModusBit_5         : BOOL;
  blRFID_Sensor_ModusBit_6         : BOOL;
  blRFID_Sensor_ModusBit_7         : BOOL;
  blRFID_Sensor_Write_Done         : BOOL;
  blResetSchmersal                 : BOOL;
  blAckRequested                   : BOOL;  
  
  blErr1, blErr2, blErr3, blErr4, blErr5 : BOOL;
  
  // WORD
  wlIoccMeldungsNummer                                   : WORD;
  wlBetriebsart                                          : WORD;
  wlZeitHochfahren                                       : WORD;
  wlZeitRunterfahren                                     : WORD;
  wlioccFWStationGegenhalterUnterwagenNichtFixiert       : WORD;
  wlioccFWStationGegenhalterUnterwagenNichtFrei          : WORD;
  wlioccFWStationRolltorNichtOben                        : WORD;
  wlioccFWStationRolltorNichtUnten                       : WORD;
  wlioccFWStationGreiferNichtGeoeffnet                   : WORD;
  wlioccFWStationGreiferNichtGeschlossen                 : WORD;
  wlioccFWStationLineareinheitNichtVorne                 : WORD;
  wlioccFWStationLineareinheitNichtHinten                : WORD;
  wlioccFWStationEntriegelungNichtGeoeffnet              : WORD;
  wlioccFWStationEntriegelungNichtGeschlossen            : WORD;
  wlioccFWStationAusrichtPositionNichtOK                 : WORD;
  wlioccStationsposUndefiniert                           : WORD;
  wlioccFWagenStationSIKreisausgeloest                   : WORD;
  wlioccFWagenStationHomeposLineareinheitNichtHinten     : WORD;
  wlioccFWagenStationHomeposGreiferNichtGeoeffnet        : WORD;
  wlioccFWagenStationHomeposRolltorNichtUnten            : WORD;
  wlioccFWagenStationHomeposEntriegelungNichtGeschlossen : WORD;
  wlioccFWagenStationHomeposGegenhalterNichtGeoeffnet    : WORD;
  wlioccFWagenStationKlemmungNichtEingefahren            : WORD;
  wlRFID_Nummer                                          : WORD;
  wlRFID_NummerMerker                                    : WORD;
  wlIndexByte                                            : WORD;
  wlIndexZiffer                                          : WORD;
  wlMaxRFIDNummer                                        : WORD;
  wlIndex_STRING                                         : WORD;
  wlioccRolltorBlockiertdurchFWNichtinPos                : WORD;
  
  // TIME
  tlZeitHochfahren   : TIME;
  tlZeitRunterfahren : TIME;
  
  // STEPS
  steplStationReset           : Steps_TE;
  stepStationCheck            : Steps_TE;
  steplEinschleusen           : Steps_TE;
  steplAusschleusen           : Steps_TE;
  steplLineareinheitVor       : Steps_TE;
  steplLineareinheitZur       : Steps_TE;
  steplLineareinheitShuttle   : Steps_TE;
  steplRolltorAuf             : Steps_TE;
  steplRolltorAb              : Steps_TE;
  steplEntriegelungOeffnen    : Steps_TE;
  steplEntriegelungSchliessen : Steps_TE;
  steplGegenhalterOeffnen     : Steps_TE;
  steplGegenhalterSchliessen  : Steps_TE;
  steplGreiferOeffnen         : Steps_TE;
  steplGreiferSchliessen      : Steps_TE;
  steplresetSIRelais          : Steps_TE;
  steplRFID_Auslesen          : Steps_TE;
  steplRFID_Schreiben         : Steps_TE;

  // TIMER
  tonlFreigabe                       : TON;
  tonlLineareinheitVorZurueck        : TON;
  tonlLineareinheitShuttle           : TON;
  tonlEntriegelungAufZu              : TON;
  tonlGegenhalterAufZu               : TON;
  tonlGreiferAufZu                   : TON;
  tonlErzwungenesAuschleusen         : TON;
  tonlUeberwachungRolltor            : TON;
  tonlRolltorOeffnenSchliesen        : TON;
  tonlFreigabeZumAusschleusen        : TON;
  tonlZeitRunterfahren               : TON; // Zum ermitteln wie lange das Rolltor runterfährt
  tonlZeitHochfahren                 : TON; // Zum ermitteln wie lange das Rolltor hochfährt
  tonlWagenInShuttleTransferposition : TON;
  tonlTimeoutSensorVorne             : TON;
  tonlTimeoutSensorHinten            : TON;
  tonlTimeoutSensorShutle            : TON;
  tonlTimeoutReadRFID                : TON;
  tonlTimeoutGreiferAufZu            : TON;
  tonlTimeoutGegenhalterAufZu        : TON;
  tonlTimeoutEntriegelungAufZu       : TON;
  tonlMaxWarteAufResetErfolgreich    : TON; 
  tonlFWInBox                        : TON;
  tonlSetzeSIRealisReset             : TON;
  tonlWarteSchritt                   : TON;
  tonUntergestellErkannt             : TON;
  tplResetSchmersal                  : TP;
  tofTagPresent                      : TOF;

  // TRIGGER
  rtlLogIn                           : R_TRIG;
  rtlBetriebsartHand                 : R_TRIG;
  ftlBetriebsartAutomatik            : F_TRIG;
  rtlQuittierungEinschleusen         : R_TRIG;
  ftlBausteinDeaktivierung           : F_TRIG;
  rtlSafetyError                     : R_TRIG;
  rtlRFID_Schreiben                  : R_TRIG;

  // ENUM
  eLetzterStatus                     : eLetzter_FW_Status;

END_VAR

VAR

  // IO-Link-Master
  in_bLinearEinheit1Vorne         : BOOL;
  in_bLinearEinheit1Hinten        : BOOL;
  in_bLinearEinheit2Vorne         : BOOL;
  in_bLinearEinheit2Hinten        : BOOL;
  in_bFaecherwagenNichtInPos      : BOOL;
  in_bNichtRolltorGeoeffnet       : BOOL;
  in_bEntriegelungOffen           : BOOL;
  in_bEntriegelungGeschlossen     : BOOL;
  in_bGegenhalterOffen            : BOOL;
  in_bGegenhalterZu               : BOOL;
  in_bGreifer1Offen               : BOOL;
  in_bGreifer1Zu                  : BOOL;
  in_bKlemmZylinderEingefahren    : BOOL; //zur Fixierung des Oberrahmens beim Ein und Ausschleusen. Eingefahren = Grundstellung 
  
  //  IO-Link-Slave
  in_bGreifer2Offen                  : BOOL;
  in_bGreifer2Zu                     : BOOL;
  out_bGreiferEinfahren              : BOOL;
  out_bGreiferAusfahren              : BOOL;
  out_bEntriegelungEinfahren         : BOOL;
  out_bEntriegelungAusfahren         : BOOL;
  in_bStartSchleusen                 : BOOL;
  out_bFreigabeSchleusen             : BOOL;
  in_bResetSafetyLichtschranke       : BOOL;
  out_bSafetyLichtschrankeAusgeloest : BOOL;
  in_bLineareinheit1Umgreifposition  : BOOL;
  in_bLineareinheit2Umgreifposition  : BOOL;
  out_bGegenhalterEinfahren          : BOOL;
  out_bGegenhalterAusfahren          : BOOL;
  out_bLinearEinheitVor              : BOOL;
  out_bLinearEinheitZurueck          : BOOL;
  
  //CAB2
  out_bRolltorAb             AT%Q*    : BOOL;
  out_bRolltorAuf            AT%Q*    : BOOL;
  
  
  blRFID_NR1                     : BOOL;
  blRFID_NR2                     : BOOL;
  blRFID_NR3                     : BOOL;
  blRFID_NR4                     : BOOL;
  blRFID_NR5                     : BOOL;
  blRFID_NR6                     : BOOL;
  blRFID_NR7                     : BOOL;
  blRFID_NR8                     : BOOL;
  blRFID_DataValid               : BOOL;
  blRFID_DataWasValid            : BOOL;
  
  //RFID Ansteuerung
  // Out
  out_bRFID_Sensor_Start_RW      : BOOL;
  out_bDeactivateAntenna         : BOOL;
  blCMD_END                      : BOOL;

  //tmp
  ablRFID                        : ARRAY[1..32,0..7] OF BOOL;
  ablRFID_out                                : ARRAY[1..32,0..7] OF BOOL;
  
  abylBytesRFID                  : ARRAY [1..32] OF BYTE; //16=R,17=a,18=c,19=k,20= ,21=0,22=0,23=9
  abylBytesRFID_out              : ARRAY [1..32] OF BYTE; //16=R,17=a,18=c,19=k,20= ,21=0,22=0,23=
  bytest                         : BYTE;
  
  slRFID_Nummer                  : STRING;
  slMaxRFID_Nummer               : STRING;
  slRFID_Validierung             : STRING;
  
  
END_VAR

VAR CONSTANT

  // TIME
  TIMEOUT_SENSOR           : TIME := T#2M;
  ZEIT_ZWANGSAUSSCHLEUSEN  : TIME := t#3s;
  ZEIT_MUTING_SENSOR_RESET : TIME := T#500MS;
  //String
  VERGLEICH_RFID_VALID     : STRING := 'Rack ';
  //WORD
  ERSTES_ZEICHEN           : WORD := 16;
  ERSTE_ZIFFER_RFID        : WORD := 21 ;
  ANZAHL_ZIFFERN_RFID      : WORD := 3 ;
  cByte0                   : BYTE := 0;

END_VAR


//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN
  
  BasisStationsParameter.awFehlerInformationen[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
  blRFID_Sensor_ModusBit_0 := TRUE;  // auf diese Art wird das automatische Auslesen des RFID-Sensors gestartet
  blRFID_Sensor_ModusBit_1 := FALSE;
  blRFID_Sensor_ModusBit_2 := FALSE;
  blRFID_Sensor_ModusBit_3 := FALSE;
  blRFID_Sensor_ModusBit_4 := FALSE;
  blRFID_Sensor_ModusBit_5 := FALSE;
  blRFID_Sensor_ModusBit_6 := FALSE;
  blRFID_Sensor_ModusBit_7 := FALSE;
  slMaxRFID_Nummer:= '';
  
  IF ANZAHL_ZIFFERN_RFID < 5 THEN // Maxwert des Datentypes muss beachtet werden. Sonst gibt es einen Überlauf; Maxwert := 65535
    FOR wlIndexZiffer := 1 TO ANZAHL_ZIFFERN_RFID  DO//zusammenfügen aller Ziffern des Maxwertes in einen String
      slMaxRFID_Nummer := CONCAT(slMaxRFID_Nummer, '9' );
    END_FOR
    wlMaxRFIDNummer    := STRING_TO_WORD(slMaxRFID_Nummer);
  ELSE
    wlMaxRFIDNummer := 65535;//Max Wert eines Wortes 
  END_IF
  
  blErsterZyklus := FALSE;
END_IF

IF NOT __ISVALIDREF(BasisStationsParameter.stMKs) THEN
  RETURN;
END_IF

//-------------------------------------------------------------------------------------------------
// SAFETY ERROR
//-------------------------------------------------------------------------------------------------
rtlSafetyError( CLK := usilErrorSafety <> 0 );
IF rtlSafetyError.Q THEN

  SpsError( eFehler_Safety_Schmersal,
            usilErrorSafety,
            BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
            AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
            BasisStationsParameter.awFehlerInformationen );

END_IF

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Werte wieder passend abloeschen, wenn der Baustein wieder aktiviert wird
*)
ftlBausteinDeaktivierung( CLK := BasisStationsParameter.stMKs.bDeaktivieren );

IF ( ftlBausteinDeaktivierung.Q ) THEN

  bpDone                             := FALSE;
  bpEinschleusenAbgeschlossen        := FALSE;
  bpAusschleusenAbgeschlossen        := FALSE;

  BasisStationsParameter.bCheckAbgeschlossen    := FALSE;
  BasisStationsParameter.bReferenzAbgeschlossen := FALSE;
END_IF

(* Hinweis:
   - Deaktivieren der Station
*)
IF (  BasisStationsParameter.stMKs.bDeaktivieren ) THEN

  bpDone                             := TRUE;
  bpEinschleusenAbgeschlossen        := TRUE;
  bpAusschleusenAbgeschlossen        := TRUE;

  bpStatusStationInBeladePosition    := FALSE;
  blStationsposUndefiniert           := FALSE;
  bpAuftragAktiv                     := FALSE;

  BasisStationsParameter.bCheckAbgeschlossen    := TRUE;
  BasisStationsParameter.bReferenzAbgeschlossen := TRUE;

  BasisStationsParameter.bAuftragAktiv := FALSE;

  BasisStationsParameter.bFehler  := FALSE;
  BasisStationsParameter.bReset   := FALSE;
  BasisStationsParameter.wFehlerNummer := 0;

  (* Hinweis:
     - Ausgaenge zuruecksetzen
  *)
  blLineareinheitVor          := FALSE;
  blLineareinheitZurueck      := FALSE;
  blLineareinheitShuttle      := FALSE;
  blEntriegelungOeffnen       := FALSE;
  blEntriegelungSchliessen    := FALSE;
  blGegenhalterOeffnen        := FALSE;
  blGegenhalterSchliessen     := FALSE;
  blGreiferOeffnen            := FALSE;
  blGreiferSchliessen         := FALSE;
  blRolltorAuf                := FALSE;
  blRolltorAb                 := FALSE;

  RETURN;

END_IF



//-------------------------------------------------------------------------------------------------
// BETRIEBSART
//-------------------------------------------------------------------------------------------------
wlBetriebsart.0 := BasisStationsParameter.bReset;
wlBetriebsart.1 := BasisStationsParameter.bCheck;
wlBetriebsart.2 := BasisStationsParameter.bAutomatik;
wlBetriebsart.3 := BasisStationsParameter.bReferenz;

blBetriebsartHand      := FALSE;
blBetriebsartReset     := FALSE;
blBetriebsartCheck     := FALSE;
blBetriebsartAutomatik := FALSE;
blBetriebsartReferenz  := FALSE;

CASE wlBetriebsart OF
  cStationHandbetrieb:
    blBetriebsartHand := TRUE;

  cStationReset:
    blBetriebsartReset := TRUE;

  cStationCheck:
    blBetriebsartCheck := TRUE;

  cStationAutomatik:
    blBetriebsartAutomatik := TRUE;

  cStationReferenz:
    blBetriebsartReferenz := TRUE;

  ELSE
    //  Nicht unterstützte Betriebsart
    BasisStationsParameter.wFehlerNummer := cMELDUNG_UNGUELTIGE_BETRIEBSART;
    BasisStationsParameter.bFehler := TRUE;

END_CASE


//-------------------------------------------------------------------------------------------------
// Timer
//-------------------------------------------------------------------------------------------------
tonlFreigabe( IN := BasisStationsParameter.bFreigabe, PT:=t#1s );

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
A_Schnittstelle();
A_Eingaenge();
Entriegelung();
Ausschleusen();
Einschleusen();
Linereinheit();
Rolltor();
Gegenhalter();
Greifer();
RFID_Auslesen();
RFID_Schreiben();

Systemcheck();

Reset();
Meldungen();
Handfunktionen();

Ausgaenge();

//-------------------------------------------------------------------------------------------------
// TASTER
//-------------------------------------------------------------------------------------------------

// Hiwneis:
//    - Auftrag aktiv
IF BasisStationsParameter.bEintransport[1] THEN

  IF steplEinschleusen = STEP_105_E THEN
    blTasterLeuchteAnforderung := gbFlashbit05sec; // Eintransport wartet auf Quittierung oder Lichtschranke
  ELSE
    blTasterLeuchteAnforderung := gbFlashbit1sec;
  END_IF

ELSIF BasisStationsParameter.bAustransport[1] THEN
  IF steplAusschleusen = STEP_10_E THEN
    blTasterLeuchteAnforderung := gbFlashbit05sec;
  ELSIF steplAusschleusen = STEP_143_E THEN
    blTasterLeuchteAnforderung := gbFlashbit02sec;
  ELSE
    blTasterLeuchteAnforderung := gbFlashbit1sec;
  END_IF
ELSE
  IF blStationsposUndefiniert THEN
    blTasterLeuchteAnforderung := gbFlashbit02sec; // Undefinierter Zustand - sehr schnell blinken
  ELSIF bpStatusStationInBeladePosition THEN
    blTasterLeuchteAnforderung := FALSE; // Fächerwagen in Box - nicht leuchten und nicht blinken
  ELSIF bpBoxInHomePosition THEN
    blTasterLeuchteAnforderung := TRUE; // Fächerwagenbox ist leer
  ELSE
    blTasterLeuchteAnforderung := gbFlashbit02sec; // Undefinierter Zustand - sehr schnell blinken
  END_IF
END_IF

out_bFreigabeSchleusen := blTasterLeuchteAnforderung;

//-------------------------------------------------------------------------------------------------
// TIMER
//-------------------------------------------------------------------------------------------------
// Reset
tonlMaxWarteAufResetErfolgreich( IN := BasisStationsParameter.bReset, PT := tgMaxWartezeitReset);

//-------------------------------------------------------------------------------------------------
// GESONDERTE LOGIK
//-------------------------------------------------------------------------------------------------

// Globale Eingänge mappen
in_bDruckluftOK := bgDruckluftFaecherwagenstationenOK; 

(* Hinweis:
   - Ausschleusen erzwingen
*)
tonlErzwungenesAuschleusen( IN := in_bStartSchleusen, PT := ZEIT_ZWANGSAUSSCHLEUSEN );
tonlLineareinheitShuttle(IN:=blLinearEinheitSH, PT := T#2S);
bpErzwingeAusschleusen := tonlErzwungenesAuschleusen.Q;

(* Hinweis:
   - FW einschleusen
*)
tonlFWInBox(IN := blTagPresent, PT := T#2S);
tofTagPresent(IN := blTagPresent, PT := T#2S);

rtlLogIn( CLK := in_bStartSchleusen
          AND bpBoxInHomePosition
          AND bpUntergestellErkannt
          AND tonlFWInBox.Q
          AND NOT bpStatusStationInBeladePosition
          AND NOT bpAuftragAktiv );

IF ( rtlLogIn.Q ) THEN
  wSps2FaecherwagenStationNr              := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
  tMmi2SpsInfo.wSps2FaecherwagenStationNr := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
  MsgToMmi( auftragsnr_w := SB0_SPS_RACKLOGIN );

  M_SB0_MMI_RELEASERACKLOGIN    := TRUE;
  blMerkerEinschleusenQuittiert := TRUE;
END_IF


//-------------------------------------------------------------------------------------------------
// RFID Chip beschreiben
//-------------------------------------------------------------------------------------------------
rtlRFID_Schreiben(CLK :=wlRFID_Nummer_Schreiben > 0);
IF rtlRFID_Schreiben.Q THEN
  blRFID_Schreiben    := TRUE;
  blRFID_Auslesen     := FALSE;
END_IF


//-------------------------------------------------------------------------------------------------
// Kollision mit Rolltor verhindern
//-------------------------------------------------------------------------------------------------
// Ventil für die Lineareinheiten auf Home Pos schlaten falls das Ventiel Lineareinheit in Richtung geschlossenes Rolltor fährt
// - Wenn kein Unterwagen vorhanden ist und das Rolltor geschlossen ist sollte auch kein Oberwagen in der Anlage sein
 
tonUntergestellErkannt (IN:= NOT bpUntergestellErkannt, PT:= T#2S);
   
IF (tonUntergestellErkannt.Q 
     OR in_bNichtRolltorGeoeffnet ) THEN
  
  blVentilReset := TRUE;
  
  IF blVentilReset THEN
    out_bLinearEinheitZurueck := TRUE;
    out_bLinearEinheitVor     := FALSE;
  
  ELSE 
    out_bLinearEinheitZurueck := FALSE;
    out_bLinearEinheitVor     := FALSE;
    
  END_IF
ELSE
  blVentilReset := FALSE;  
END_IF
END_FUNCTION_BLOCK