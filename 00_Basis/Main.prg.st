(* METADATA
{
	"v3Meta": {
		"objectGuid": "38b1ebdf-93dc-4d21-adff-5cd8952a9cb8"
	}
}
*)
PROGRAM Main
VAR

  // BOOL
  blErsterZyklus : BOOL := TRUE;
  blZweiterZyklus : BOOL := FALSE;

  aStation1Wand : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL;
  aStation2Wand : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL;

  // BLINK
  Flasher02                  : BLINK;
  Flasher03                  : BLINK;
  Flasher05                  : BLINK;
  Flasher10                  : BLINK;
  Flasher12                  : BLINK;

  // WORD
  wlIndex                    : WORD;

  // TRIGGER
  rtlChangeWatchIOStatus     : R_TRIG;

  // Events
  sCallbackOnlineChange      : CB.CB_CALLBACK;
  peCallbackStopOnlineChange : CB.ERROR;

END_VAR

VAR_OUTPUT

  // TRIGGER
  rtlEtherCatOK              : R_TRIG;
END_VAR
// -------------------------------------------------------------------------
// -----!!! Vor dem Befehl <MsgBegin> sollte keine Anweisung stehen !!!-----
TCPMain.l_fb_SortjetHMI.MsgBegin();
// -----!!! Vor dem Befehl <MsgBegin> sollte keine Anweisung stehen !!!-----
// -------------------------------------------------------------------------

TCPMain();

EtherCAT_Master.StartConfigWithLessDevice := TRUE;

// OP1 bis OP5 einschalten, sobald EtherCAT laeuft
%QX0.0 := %QX0.1 := %QX0.3 := %QX0.4 := %QX0.5 := bgEtherCatOK OR bgInbetriebnahmeBit;

IF ( Auftraege.bgInbetriebnahmeAblaeufe ) THEN
  Auftraege();
END_IF

Flasher();
Merker();


//EventsRegistrieren();
CheckReset();
StationBasisZuweisungen();
Auftraege();
Interface_SLC();
NotHalt();
SteuerungSicherheitskreise();
Stop_Baustein();
Initialisierung();
SystemCheck();
Job();
StationsAufrufe();

IF ( blZweiterZyklus ) THEN
  blZweiterZyklus := FALSE;
  StartUpCheck();
END_IF

IF ( blErsterZyklus ) THEN
  blErsterZyklus := FALSE;
  blZweiterZyklus := TRUE;
  // !!! Muss NACH dem Aufruf von Job erfolgen, da sonst die MKs nicht initialisiert sind !!!
  wgAnzahlSystemcheckZyklen := getAnzahlSystemcheckZyklen();
END_IF

StatusAnlage();
Visu();

(* Hinweis:
   - Schrittketten Auswertung
*)
Schrittketten_Logger();
AntriebeVerfahren();

bgMMIOK := TCPMain.l_fb_SortjetHMI.o_b_WatchdogOk;
// -------------------------------------------------------------------------
// -!!! Nach dem Befehl <MsgEnd> sollte keine weitere Anweisung folgen !!!--
TCPMain.l_fb_SortjetHMI.MsgEnd();
// -!!! Nach dem Befehl <MsgEnd> sollte keine weitere Anweisung folgen !!!--
// -------------------------------------------------------------------------
END_PROGRAM