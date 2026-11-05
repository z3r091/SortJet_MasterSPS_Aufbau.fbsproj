(* METADATA
{
  "v3Meta": {
    "objectGuid": "e6879d41-371d-40de-a0ee-fe2898e6d6d8"
  }
}
*)
FUNCTION_BLOCK Faecherwagenstation_Hydraulik_FB_V01_00_00 EXTENDS Basic_Faecherwagenstation_FB_V01_00_00
VAR_OUTPUT

  // BOOL
  bpAnforderungHydraulikEin        : BOOL; // Hydraulikaggregat einschalten (eine hydraulische Bewegung ist angefordert)
  bpUmlaufVentilPause              : BOOL; // Umlaufventil zwischen zwei direkt folgenden Bewegungen kurz zuruecknehmen

END_VAR
VAR

  // BOOL: Anforderungen
  blHubrahmenHeben                 : BOOL;
  blHubrahmenSenken                : BOOL;
  blFaecherwagenVor                : BOOL;
  blFaecherwagenZurueck            : BOOL;
  blZentrierungOeffnen             : BOOL;
  blZentrierungSchliessen          : BOOL;
  blAnschlagAuf                    : BOOL;
  blAnschlagAb                     : BOOL;
  blAnschlagVor                    : BOOL; // Option AGV: Anschlag nach vorne
  blAnschlagZurueck                : BOOL; // Option AGV: Anschlag nach hinten

  // BOOL: Bewegungen abgeschlossen
  blHubrahmenHebenDone             : BOOL;
  blHubrahmenSenkenDone            : BOOL;
  blFaecherwagenVorDone            : BOOL;
  blFaecherwagenZurueckDone        : BOOL;
  blZentrierungOeffnenDone         : BOOL;
  blZentrierungSchliessenDone      : BOOL;
  blAnschlagAufDone                : BOOL;
  blAnschlagAbDone                 : BOOL;
  blAnschlagVorDone                : BOOL;
  blAnschlagZurueckDone            : BOOL;

  // BOOL: Verschiedenes
  blFaecherwagenErkannt            : BOOL; // Beide Muting-Sensoren belegt
  blAnschlagUntenOderOhne          : BOOL; // Anschlag unten oder kein Anschlag laut MK
  blLadepositionOhneOben           : BOOL; // Beladeposition bis auf den abgesackten Hubrahmen
  blPositionskorrekturAktiv        : BOOL; // Hubrahmen wird nachgehoben
  blAnforderungHydraulik           : BOOL;
  blHandFreigabe                   : BOOL; // Handfunktionen nur im Handbetrieb zulassen
  blTasterLeuchteAnforderung       : BOOL;
  blHydraulikLaeuft                : BOOL; // Rueckmeldung der zugeordneten Hydraulikstation
  blStationBeladen                 : BOOL; // Faecherwagen eingeschleust (Status fuer AGV-Betrieb)
  blStartUp                        : BOOL := TRUE; // Sicherheitsrelais nach dem Programmstart einmal quittieren

  // BOOL: Begrenzung gleichzeitiger Auftraege je Hydraulikstation
  blHydraulikAuftragAnfrage        : BOOL; // Kette wartet auf die Freigabe eines neuen Auftrags (je Zyklus neu gesetzt)
  blHydraulikAuftragFreigabe       : BOOL; // Rueckmeldung der Hydraulikstation (M_AuftragFreigabe, letzter Zyklus)
  blHydraulikAuftragAktiv          : BOOL; // Ein-/Ausschleusen mit hydraulischen Bewegungen laeuft, belegt die Hydraulikstation
  blAuftragWartetAufHydraulik      : BOOL; // Auftrag erteilt, Hydraulikstation laesst noch keinen weiteren Auftrag zu

  // BOOL: Muting
  blMutingAusschalten              : BOOL; // Option AGV: Muting dauerhaft zuruecksetzen (kein Faecherwagen eingeschleust)
  blMutingResetAnforderung         : BOOL; // Anforderung Muting-Sensoren zuruecksetzen pruefen
  blMutingResetImpuls              : BOOL; // Reset-Impuls fuer die Muting-Sensoren ausgeben
  blMutingSensorReset              : BOOL; // Reset-Impuls aktiv

  // BYTE
  bylRFID_Nummer                   : BYTE;

  // WORD
  wlIoccMeldungsNummer             : WORD;
  wlStationStatusWord              : WORD; // Option AGV: zuletzt ans MMI gemeldeter Status der Station

  // REFERENZ
  refHydraulikstation              : REFERENCE TO Hydraulik_FB_V01_00_00; // laut MK stStationsAufbau.wHydraulikstation

  // STEPS
  steplEinschleusen                : Steps_TE;
  steplAusschleusen                : Steps_TE;
  steplHubrahmenHeben              : Steps_TE;
  steplHubrahmenSenken             : Steps_TE;
  steplFaecherwagenVor             : Steps_TE;
  steplFaecherwagenZurueck         : Steps_TE;
  steplZentrierungOeffnen          : Steps_TE;
  steplZentrierungSchliessen       : Steps_TE;
  steplSicherheitskreisReset       : Steps_TE;

  // TIMER
  tonlHubrahmenUeberfahren         : TON; // Sensor ueberfahren, Endlage sicher erreicht
  tonlVerfahrenUeberfahren         : TON;
  tonlZentrierungUeberfahren       : TON;
  tonlTimeoutHubrahmen             : TON;
  tonlTimeoutVerfahren             : TON;
  tonlTimeoutZentrierung           : TON;
  tonlTimeoutHydraulik             : TON; // Warten auf das Hydraulikaggregat
  tonlTimeoutReadRFID              : TON;
  tonlFWInBox                      : TON;
  tonlErzwungenesAuschleusen       : TON;
  tonlMutingSensorFehler           : TON;
  tonlPositionskorrektur           : TON;
  tonlUmlaufventilPause            : TON; // Dauer der Pause des Umlaufventils
  tonlMutingSensorenBelegt         : TON; // Beide Muting-Sensoren stabil belegt
  tonlTimeoutAGV                   : TON; // Option AGV: Warten auf den Faecherwagen
  tonlRFIDGelesen                  : TON; // Option AGV: RFID-Chip stabil gelesen
  tonlStartUp                      : TON;
  tonlResetImpuls                  : TON; // Impulsdauer Reset Sicherheitsrelais
  tonlResetWarten                  : TON; // Wartezeiten der Kette Sicherheitskreis-Reset
  toflAnforderungHydraulikEin      : TOF;
  toflMutingSensorReset            : TOF; // Impulsdauer Reset Muting-Sensoren

  // TRIGGER
  rtlLogIn                         : R_TRIG;
  rtlQuittierungEinschleusen       : R_TRIG;
  rtlBetriebsartHand               : R_TRIG;
  ftlBetriebsartAutomatik          : F_TRIG;
  rtlPositionskorrektur            : R_TRIG;
  rtlAnschlagFehler                : R_TRIG;
  rtlAnschlagHorizontalFehler      : R_TRIG;
  rtlMutingSensorReset             : R_TRIG;
  ftlRFIDNichtMehrGelesen          : F_TRIG;

  // BAUSTEINE
  Anschlag                         : ZylinderPneumatik_FB_V01_00_00; // Option stStationsAufbau.bAnschlag, ausgefahren = oben
  AnschlagHorizontal               : ZylinderPneumatik_FB_V01_00_00; // Option bAnschlag und bAGV, ausgefahren = vorne

  // HARDWARE EINGAENGE
  in_bHubrahmenOben                AT %I* : BOOL;
  in_bHubrahmenUnten               AT %I* : BOOL;
  in_bFaecherwagenVorne            AT %I* : BOOL;
  in_bFaecherwagenHinten           AT %I* : BOOL;
  in_bZentrierungOffen             AT %I* : BOOL;
  in_bZentrierungGeschlossen       AT %I* : BOOL;
  in_bAnschlagOben                 AT %I* : BOOL;
  in_bAnschlagUnten                AT %I* : BOOL;
  in_bAnschlagVorne                AT %I* : BOOL; // Option AGV
  in_bAnschlagHinten               AT %I* : BOOL; // Option AGV
  in_bFWInAusrichtPosition         AT %I* : BOOL; // Faecherwagen steht vor der Station in Ausrichtposition
  in_bMutingSensorLinks            AT %I* : BOOL;
  in_bMutingSensorRechts           AT %I* : BOOL;
  in_bStartSchleusen               AT %I* : BOOL; // Taster Ein-/Ausschleusen an der Station
  in_bSicherheitsrelaisOK          AT %I* : BOOL;
  in_bAbrollsicherungOK            AT %I* : BOOL; // Abrollsicherung des Rolltors nicht ausgeloest
  in_bRFID_DataValid               AT %I* : BOOL;
  in_bRFID_NR1                     AT %I* : BOOL;
  in_bRFID_NR2                     AT %I* : BOOL;
  in_bRFID_NR3                     AT %I* : BOOL;
  in_bRFID_NR4                     AT %I* : BOOL;
  in_bRFID_NR5                     AT %I* : BOOL;
  in_bRFID_NR6                     AT %I* : BOOL;
  in_bRFID_NR7                     AT %I* : BOOL;
  in_bRFID_NR8                     AT %I* : BOOL;

  // HARDWARE AUSGAENGE
  out_bHubrahmenHeben              AT %Q* : BOOL;
  out_bHubrahmenSenken             AT %Q* : BOOL;
  out_bFaecherwagenVor             AT %Q* : BOOL;
  out_bFaecherwagenZurueck         AT %Q* : BOOL;
  out_bZentrierungOeffnen          AT %Q* : BOOL;
  out_bZentrierungSchliessen       AT %Q* : BOOL;
  out_bAnschlagAuf                 AT %Q* : BOOL;
  out_bAnschlagAb                  AT %Q* : BOOL;
  out_bAnschlagVor                 AT %Q* : BOOL; // Option AGV
  out_bAnschlagZurueck             AT %Q* : BOOL; // Option AGV
  out_bFreigabeSchleusen           AT %Q* : BOOL; // Leuchte im Taster Ein-/Ausschleusen
  out_bMutingSensorReset           AT %Q* : BOOL; // Muting-Sensoren zuruecksetzen
  out_bResetSicherheitsrelais      AT %Q* : BOOL; // Sicherheitsrelais der Station quittieren

END_VAR
VAR CONSTANT

  // TIME
  ZEIT_TIMEOUT_SENSOR              : TIME := T#30S;
  ZEIT_TIMEOUT_HYDRAULIK           : TIME := T#30S;
  ZEIT_SENSOR_UEBERFAHREN          : TIME := T#3S;
  ZEIT_POSITIONSKORREKTUR          : TIME := T#5S;
  ZEIT_TIMEOUT_RFID                : TIME := T#5S;
  ZEIT_ZWANGSAUSSCHLEUSEN          : TIME := T#3S;
  ZEIT_FW_IN_BOX                   : TIME := T#1S;
  ZEIT_UMLAUFVENTIL_PAUSE          : TIME := T#1S;
  ZEIT_MUTING_SENSOR_RESET         : TIME := T#500MS;
  ZEIT_STARTUP_SICHERHEITSRELAIS   : TIME := T#5S;

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

  blHubrahmenHeben           := FALSE;
  blHubrahmenSenken          := FALSE;
  blFaecherwagenVor          := FALSE;
  blFaecherwagenZurueck      := FALSE;
  blZentrierungOeffnen       := FALSE;
  blZentrierungSchliessen    := FALSE;
  blAnschlagAuf              := FALSE;
  blAnschlagAb               := FALSE;
  blAnschlagVor              := FALSE;
  blAnschlagZurueck          := FALSE;
  blPositionskorrekturAktiv  := FALSE;
  blMutingResetImpuls        := FALSE;
  steplSicherheitskreisReset := STEP_0_E;

  out_bHubrahmenHeben        := FALSE;
  out_bHubrahmenSenken       := FALSE;
  out_bFaecherwagenVor       := FALSE;
  out_bFaecherwagenZurueck   := FALSE;
  out_bZentrierungOeffnen    := FALSE;
  out_bZentrierungSchliessen := FALSE;
  out_bAnschlagAuf           := FALSE;
  out_bAnschlagAb             := FALSE;
  out_bAnschlagVor            := FALSE;
  out_bAnschlagZurueck        := FALSE;
  out_bFreigabeSchleusen      := FALSE;
  out_bMutingSensorReset      := FALSE;
  out_bResetSicherheitsrelais := FALSE;
  bpAnforderungHydraulikEin   := FALSE;
  bpUmlaufVentilPause         := FALSE;

  HandfunktionenStatus();
  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
A_Eingaenge();
Ausschleusen();
Einschleusen();
Positionskorrektur();

Hubrahmen();
Verfahren();
Zentrierung();
Rolltor();

Systemcheck();
Status_Meldung();

Reset();
Handfunktionen();

MutingSensorReset();
Sicherheitskreis_Reset();

A_Aufrufe();
Ausgaenge();

A_Visu();
A_VisuVariante();

//-------------------------------------------------------------------------------------------------
// TASTER
//-------------------------------------------------------------------------------------------------
IF blAuftragWartetAufHydraulik THEN
  blTasterLeuchteAnforderung := gbFlashbit02sec; // Auftrag erteilt, wartet auf die Hydraulikstation - sehr schnell blinken

ELSIF BasisStationsParameter.bEintransport[cWAND_1] THEN

  IF steplEinschleusen = STEP_100_E THEN
    blTasterLeuchteAnforderung := gbFlashbit05sec; // Einschleusen wartet auf die Quittierung
  ELSE
    blTasterLeuchteAnforderung := gbFlashbit1sec;
  END_IF

ELSIF BasisStationsParameter.bAustransport[cWAND_1] THEN
  blTasterLeuchteAnforderung := gbFlashbit1sec;

ELSIF blStationsposUndefiniert THEN
  blTasterLeuchteAnforderung := gbFlashbit02sec; // Undefinierter Zustand - sehr schnell blinken

ELSIF bpStatusStationInBeladePosition THEN
  blTasterLeuchteAnforderung := bpMMIFWBaldVoll; // Faecherwagen in Beladeposition: Dauerlicht, wenn er laut MMI bald voll ist

ELSIF bpBoxInHomePosition AND in_bFWInAusrichtPosition THEN
  blTasterLeuchteAnforderung := TRUE; // Faecherwagen steht bereit zum Einschleusen

ELSE
  blTasterLeuchteAnforderung := FALSE;
END_IF

out_bFreigabeSchleusen := blTasterLeuchteAnforderung;

//-------------------------------------------------------------------------------------------------
// GESONDERTE LOGIK
//-------------------------------------------------------------------------------------------------

// Ausschleusen erzwingen: Taster lange druecken
tonlErzwungenesAuschleusen( IN := in_bStartSchleusen, PT := ZEIT_ZWANGSAUSSCHLEUSEN );
bpErzwingeAusschleusen := tonlErzwungenesAuschleusen.Q;

// Faecherwagen anmelden: Taster bei Faecherwagen in Ausrichtposition und Station in Grundstellung
rtlLogIn( CLK :=     in_bStartSchleusen
                 AND bpBoxInHomePosition
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

// Hydraulikaggregat einschalten, solange eine hydraulische Bewegung angefordert und nicht fertig ist
blAnforderungHydraulik :=     BasisStationsParameter.bFreigabe
                          AND (    ( blHubrahmenHeben        AND NOT blHubrahmenHebenDone )
                                OR ( blHubrahmenSenken       AND NOT blHubrahmenSenkenDone )
                                OR ( blFaecherwagenVor       AND NOT blFaecherwagenVorDone )
                                OR ( blFaecherwagenZurueck   AND NOT blFaecherwagenZurueckDone )
                                OR ( blZentrierungOeffnen    AND NOT blZentrierungOeffnenDone )
                                OR ( blZentrierungSchliessen AND NOT blZentrierungSchliessenDone ) );

toflAnforderungHydraulikEin( IN := blAnforderungHydraulik, PT := T#2S );
bpAnforderungHydraulikEin := toflAnforderungHydraulikEin.Q;

// Anforderung an die zugeordnete Hydraulikstation melden (Aufruf der Hydraulikstation nach den Faecherwagenstationen)
IF __ISVALIDREF(refHydraulikstation) THEN
  refHydraulikstation.M_Anfordern( bpHydraulikEin      := bpAnforderungHydraulikEin,
                                   bpUmlaufventilPause := bpUmlaufVentilPause );
  blHydraulikLaeuft := refHydraulikstation.bpHydraulikLaeuft;
ELSE
  // Keine Hydraulikstation zugeordnet: hydraulische Bewegungen laufen in die Zeitueberwachung
  blHydraulikLaeuft := FALSE;
END_IF

// Begrenzung gleichzeitiger Auftraege je Hydraulikstation (MK wMaximaleAnzahlAktiverAuftraege):
// Auftrag belegt die Hydraulikstation, bis Ein-/Austransport beendet oder abgebrochen ist
IF     NOT BasisStationsParameter.bEintransport[cWAND_1]
   AND NOT BasisStationsParameter.bAustransport[cWAND_1]
THEN
  blHydraulikAuftragAktiv := FALSE;
END_IF

IF __ISVALIDREF(refHydraulikstation) THEN
  blHydraulikAuftragFreigabe := refHydraulikstation.M_AuftragFreigabe( bpAuftragAktiv   := blHydraulikAuftragAktiv OR blPositionskorrekturAktiv,
                                                                       bpAuftragStarten := blHydraulikAuftragAnfrage );
ELSE
  // Keine Hydraulikstation zugeordnet: keine Begrenzung
  blHydraulikAuftragFreigabe := TRUE;
END_IF

blAuftragWartetAufHydraulik := blHydraulikAuftragAnfrage AND NOT blHydraulikAuftragFreigabe;
blHydraulikAuftragAnfrage   := FALSE;

// Sicherheitsrelais der Station nach dem Programmstart einmal quittieren, sobald Not-Halt in Ordnung ist
tonlStartUp( IN := blStartUp AND NotHalt.bpNotHaltOK, PT := ZEIT_STARTUP_SICHERHEITSRELAIS );

IF ( tonlStartUp.Q ) THEN
  blStartUp                     := FALSE;
  blStarteSicherheitskreisReset := TRUE;
END_IF
END_FUNCTION_BLOCK