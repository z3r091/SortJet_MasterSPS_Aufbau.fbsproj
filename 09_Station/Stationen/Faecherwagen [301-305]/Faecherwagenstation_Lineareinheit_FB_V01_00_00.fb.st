(* METADATA
{
	"v3Meta": {
		"objectGuid": "3779c208-854f-4c13-8b26-aa1147fe8cdb"
	}
}
*)
FUNCTION_BLOCK Faecherwagenstation_Lineareinheit_FB_V01_00_00 EXTENDS Basic_Faecherwagenstation_FB_V01_00_00
VAR_INPUT

  // BOOL
  bpLichtschranke_OK                      : BOOL;// Eingang aus der Sicherheitsteechnik das die Lichtschrnake quittiert ist
  bpUntergestellErkannt                   : BOOL;//safety eingang der Anzeigt, ob ein Unterwagen erkannt wurde
  in_bDruckluftOK                         : BOOL;
  bpLichtschrankeWartetAufQuittierungAmOP : BOOL;

END_VAR
VAR

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
  blLuftAbschaltungS1              : BOOL;
  blLuftAbschaltungS2              : BOOL;
  blVentilReset                    : BOOL;
  blLinVorBeiRolltorFahrt          : BOOL; // Einschleusen: Lineareinheit darf vorfahren, waehrend das Rolltor hochfaehrt
  blRolltorAbBeiLinZurueck         : BOOL; // Ausschleusen: Rolltor darf schliessen, waehrend die Lineareinheit zurueckfaehrt
  blOberwagenBewegenGesperrt       : BOOL; // Rolltor nicht oben + Greifer haelt Oberwagen + Lineareinheit nicht hinten/SH -> Lineareinheit darf nicht fahren
  blHandFreigabe                   : BOOL; // Handfunktionen nur im Handbetrieb zulassen

  // jeweils Zusammenfassung der beiden Eingänge
  blLinearEinheitVorne             : BOOL;
  blLinearEinheitHinten            : BOOL;
  blLinearEinheitSH                : BOOL;
  blGreiferOffen                   : BOOL;
  blGreiferZu                      : BOOL;

  //Verschiedenes
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

  blErr1, blErr2, blErr3, blErr4, blErr5 : BOOL;

  // WORD
  wlIoccMeldungsNummer                                   : WORD;
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
  wlRFID_NummerMerker                                    : WORD;
  wlIndexByte                                            : WORD;
  wlIndexZiffer                                          : WORD;
  wlMaxRFIDNummer                                        : WORD;
  wlIndex_STRING                                         : WORD;
  wlioccRolltorBlockiertdurchFWNichtinPos                : WORD;

  // STEPS
  steplEinschleusen           : Steps_TE;
  steplAusschleusen           : Steps_TE;
  steplLineareinheitVor       : Steps_TE;
  steplLineareinheitZur       : Steps_TE;
  steplLineareinheitShuttle   : Steps_TE;
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
  tonlLineareinheitVorZurueck        : TON;
  tonlLineareinheitShuttle           : TON;
  tonlEntriegelungAufZu              : TON;
  tonlGegenhalterAufZu               : TON;
  tonlGreiferAufZu                   : TON;
  tonlErzwungenesAuschleusen         : TON;
  tonlFreigabeZumAusschleusen        : TON;
  tonlWagenInShuttleTransferposition : TON;
  tonlTimeoutSensorVorne             : TON;
  tonlTimeoutSensorHinten            : TON;
  tonlTimeoutSensorShutle            : TON;
  tonlTimeoutReadRFID                : TON;
  tonlTimeoutGreiferAufZu            : TON;
  tonlTimeoutGegenhalterAufZu        : TON;
  tonlTimeoutEntriegelungAufZu       : TON;
  tonlFWInBox                        : TON;
  tonlSetzeSIRealisReset             : TON;
  tonlWarteSchritt                   : TON;
  tonUntergestellErkannt             : TON;
  tofTagPresent                      : TOF;

  // TRIGGER
  rtlLogIn                           : R_TRIG;
  rtlBetriebsartHand                 : R_TRIG;
  ftlBetriebsartAutomatik            : F_TRIG;
  rtlQuittierungEinschleusen         : R_TRIG;
  rtlRFID_Schreiben                  : R_TRIG;

END_VAR

VAR

  // IO-Link-Master
  in_bLinearEinheit1Vorne         : BOOL;
  in_bLinearEinheit1Hinten        : BOOL;
  in_bLinearEinheit2Vorne         : BOOL;
  in_bLinearEinheit2Hinten        : BOOL;
  in_bFaecherwagenNichtInPos      : BOOL;
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
  in_bLineareinheit1Umgreifposition  : BOOL;
  in_bLineareinheit2Umgreifposition  : BOOL;
  out_bGegenhalterEinfahren          : BOOL;
  out_bGegenhalterAusfahren          : BOOL;
  out_bLinearEinheitVor              : BOOL;
  out_bLinearEinheitZurueck          : BOOL;

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
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
IF NOT __ISVALIDREF(BasisStationsParameter.stMKs) THEN
  dwpHandfunktionenReturn := DWORD#0;
  RETURN;
END_IF

SUPER^(BasisStationsParameter := BasisStationsParameter);

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN

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

  HandfunktionenStatus();
  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
A_Eingaenge();
Entriegelung();
Ausschleusen();
Einschleusen();
Linereinheit();

// Rolltor nur schliessen, wenn die Lineareinheit nicht im Bereich des Rolltors steht
// (Ausschleusen: schon waehrend die Lineareinheit mit offenem Greifer zurueckfaehrt)
blRolltorAbFreigabe := blLinearEinheitHinten OR blLinearEinheitSH OR blRolltorAbBeiLinZurueck;
Rolltor();

Gegenhalter();
Greifer();
RFID_Auslesen();
RFID_Schreiben();

Systemcheck();

Reset();
Handfunktionen();

Ausgaenge();

A_Visu();
A_VisuVariante();

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
    blTasterLeuchteAnforderung := bpMMIFWBaldVoll; // Fächerwagen in Box: Dauerlicht, wenn er laut MMI bald voll ist, sonst aus
  ELSIF bpBoxInHomePosition THEN
    blTasterLeuchteAnforderung := TRUE; // Fächerwagenbox ist leer
  ELSE
    blTasterLeuchteAnforderung := gbFlashbit02sec; // Undefinierter Zustand - sehr schnell blinken
  END_IF
END_IF

out_bFreigabeSchleusen := blTasterLeuchteAnforderung;

//-------------------------------------------------------------------------------------------------
// GESONDERTE LOGIK
//-------------------------------------------------------------------------------------------------

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

// Oberwagen nie bewegen (reinziehen / rausschieben), solange das Rolltor nicht oben ist und die Lineareinheit ihn haelt:
//   - Greifer nicht offen und Lineareinheit nicht in Endlage hinten / SH -> Lineareinheit steht am Oberwagen
//   - z.B. Abbruch Einschleusen (Rolltor-Timeout) nachdem die Lineareinheit am FW gegriffen hat
//   - Hat Vorrang vor dem Zwangs-Zurueck unten, Ausgaenge bleiben aus bis Rolltor oben oder Greifer offen
//   - Die mechanische Oberwagensperre schaltet gegenlaeufig zum Greifer und wird nicht eigens angesteuert
blOberwagenBewegenGesperrt :=     BasisStationsParameter.stMKs.stStationsAufbau.bRolltor
                              AND NOT in_bRolltorGeoeffnet
                              AND NOT blGreiferOffen
                              AND NOT blLinearEinheitHinten
                              AND NOT blLinearEinheitSH;

IF blOberwagenBewegenGesperrt THEN
  out_bLinearEinheitZurueck := FALSE;
  out_bLinearEinheitVor     := FALSE;
  blVentilReset             := FALSE;

ELSIF (    tonUntergestellErkannt.Q
        OR ( NOT in_bRolltorGeoeffnet AND NOT blLinVorBeiRolltorFahrt ) ) THEN // Einschleusen: Vorfahren waehrend Rolltor hochfaehrt erlaubt

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