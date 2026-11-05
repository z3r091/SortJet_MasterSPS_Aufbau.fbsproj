(* METADATA
{
  "v3Meta": {
    "objectGuid": "602268ae-05d1-404e-8d8e-505fe92152ba"
  }
}
*)
FUNCTION_BLOCK Faecherwagenstation_Einfach_FB_V01_00_00 EXTENDS Basic_Faecherwagenstation_FB_V01_00_00
VAR

  // BOOL
  blArretierungSchliessen          : BOOL; // Anforderung Arretierung ausfahren (Faecherwagen festhalten)
  blArretierungOeffnen             : BOOL; // Anforderung Arretierung einfahren (Faecherwagen freigeben)
  blArretierungSchliessenDone      : BOOL;
  blArretierungOeffnenDone         : BOOL;
  blArretierungGeschlossen         : BOOL; // Arretierung ausgefahren (Endlage)
  blArretierungOffen               : BOOL; // Arretierung eingefahren (Endlage)
  blHandFreigabe                   : BOOL; // Handfunktionen nur im Handbetrieb zulassen
  blTasterLeuchteAnforderung       : BOOL;

  // WORD
  wlIoccMeldungsNummer             : WORD;

  // STEPS
  steplEinschleusen                : Steps_TE;
  steplAusschleusen                : Steps_TE;

  // TIMER
  tonlFWInBox                      : TON; // Faecherwagen steht stabil in der Station
  tonlErzwungenesAuschleusen       : TON;

  // TRIGGER
  rtlLogIn                         : R_TRIG;
  rtlQuittierungEinschleusen       : R_TRIG;
  rtlBetriebsartHand               : R_TRIG;
  ftlBetriebsartAutomatik          : F_TRIG;
  rtlArretierungFehler             : R_TRIG;

  // BAUSTEINE
  Arretierung                      : Arretierung_FB_V01_00_00; // Arretierung (Zentrierung/Klemmung) des ganzen Faecherwagens

  // HARDWARE EINGAENGE
  in_bFaecherwagenVorhanden        AT %I* : BOOL;
  in_bArretierungAusgefahren       AT %I* : BOOL; // Faecherwagen arretiert
  in_bArretierungEingefahren       AT %I* : BOOL; // Faecherwagen freigegeben
  in_bStartSchleusen               AT %I* : BOOL; // Taster Ein-/Ausschleusen an der Station
  in_bAbrollsicherungOK            AT %I* : BOOL; // Abrollsicherung am Rolltor in Ordnung (Oeffner: TRUE = frei)

  // HARDWARE AUSGAENGE
  out_bArretierungAusfahren        AT %Q* : BOOL;
  out_bArretierungEinfahren        AT %Q* : BOOL;
  out_bFreigabeSchleusen           AT %Q* : BOOL; // Leuchte im Taster Ein-/Ausschleusen

END_VAR
VAR CONSTANT

  // TIME
  ZEIT_ZWANGSAUSSCHLEUSEN          : TIME := T#3S;
  ZEIT_FW_IN_BOX                   : TIME := T#2S;

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

  blArretierungSchliessen   := FALSE;
  blArretierungOeffnen      := FALSE;
  out_bArretierungAusfahren := FALSE;
  out_bArretierungEinfahren := FALSE;
  out_bFreigabeSchleusen    := FALSE;

  HandfunktionenStatus();
  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
A_Eingaenge();
Ausschleusen();
Einschleusen();
Rolltor();

Systemcheck();

Reset();
Handfunktionen();

A_Aufrufe();
Ausgaenge();

A_Visu();
A_VisuVariante();

//-------------------------------------------------------------------------------------------------
// TASTER
//-------------------------------------------------------------------------------------------------
IF BasisStationsParameter.bEintransport[cWAND_1] THEN

  IF steplEinschleusen = STEP_105_E THEN
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

ELSIF bpBoxInHomePosition THEN
  blTasterLeuchteAnforderung := TRUE; // Station bereit zum Einschleusen

ELSE
  blTasterLeuchteAnforderung := gbFlashbit02sec;
END_IF

out_bFreigabeSchleusen := blTasterLeuchteAnforderung;

//-------------------------------------------------------------------------------------------------
// GESONDERTE LOGIK
//-------------------------------------------------------------------------------------------------

// Ausschleusen erzwingen: Taster lange druecken
tonlErzwungenesAuschleusen( IN := in_bStartSchleusen, PT := ZEIT_ZWANGSAUSSCHLEUSEN );
bpErzwingeAusschleusen := tonlErzwungenesAuschleusen.Q;

// Faecherwagen anmelden: Taster bei Faecherwagen in der Station und Station in Grundstellung
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
END_FUNCTION_BLOCK