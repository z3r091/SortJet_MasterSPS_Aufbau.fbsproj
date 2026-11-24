(* METADATA
{
	"v3Meta": {
		"objectGuid": "466fafaa-eb0c-4cc2-9ac3-d488ea338d40"
	}
}
*)
FUNCTION_BLOCK Basic_Schnittstelle_FB_V01_00_00
VAR_IN_OUT

  // STRUKT
  BasisStationsParameter     : StationBasisParameter_ST;

END_VAR

VAR_INPUT

  // BOOL
  bpEmpfaengerSensorEinlauf  : BOOL;
  bpResetISOLinieEvent       : BOOL;
  bpStarteIGEvent            : BOOL;

  // WORD
  wpAuftragsTyp              : WORD; // Unterteilung => 0 = Scheibe vom Sortjet , 1 = Scheibe soll Manuell angelegt werden *)

  // STRUCT
  AuftragsSpeicher           : Auftragswarteschlange_Fremdanlage_FB;

END_VAR

VAR_OUTPUT

  // BOOL
  bpISOLineEventAktiv       : BOOL; // Offenes ISO Linie Event nach aussen weitergeben

  // REAL
  rpGeschwindigkeit          : REAL;

  //DWORD
  dwpWartezeit     : DWORD;// STATISTIK: Beschreibt die Zeit zwischen Anlegeauftrag und betaetigen des Tasters zum Eintransport


END_VAR

VAR

  // BOOL
  blErsterZyklus             : BOOL := TRUE;
  bEmpfaengerSensorEinlauf   : BOOL; // Eingang Einlaufsensor von Umrichter Box
  blBereitZumEintransport    : BOOL;
  blBereitZumAustransport    : BOOL;
  blAutomatikBetriebAktiv    : BOOL;
  blSenderBereit             : BOOL;
  blSenderGlasBereit         : BOOL;
  blInLogSchreiben           : BOOL;
  blOutLogSchreiben          : BOOL;
  blTempSenderBereit         : BOOL;
  blTempSenderGlasBereit     : BOOL;
  blTempFreigabeSK           : BOOL;
  blTempAnforderungSK        : BOOL;
  blTempGlasAbruf            : BOOL;
  blTempEinlaufSensor        : BOOL;
  blTempAutomatikBetrieb     : BOOL;
  blUebergabeGlas            : BOOL; // Schrittkettenvariable
  blStartISOLinie            : BOOL; // Schrittkettenvariable

  // WORD
  wlWatchIONachrichtenNummer : WORD;

  //TRIGGER
  rtlTasterSpezial           : R_TRIG;
  rtlTasterGlasbruch         : R_TRIG;

  // STRING
  slInLogString              : STRING;
  slOutLogString             : STRING;

  // TIME
  tlWarteZeiteAufnahme       : TIME;

  // STEPS
  steplUebergabeGlas         : Steps_TE;

  // BAUSTEINE
  Horn                       : Horn_FB;

  // GLAETTUNG AUSGANGSGESCHWINDIGKEIT (M_GeschwindigkeitGlaetten)
  blGeschwindigkeitInitialisiert     : BOOL; // Erste Geschwindigkeit nach Stillstand uebernommen
  blGeschwindigkeitUpdateSperreAktiv : BOOL; // Sperrzeit nach Geschwindigkeitsaenderung aktiv
  rlGeschwindigkeitFreigegeben       : REAL; // Zuletzt freigegebene Geschwindigkeit
  tonlGeschwindigkeitUpdateSperre    : TON;

END_VAR

VAR_INPUT

  // HARDWARE EINGAENGE
  in_bEmpfaengerSensorEinlauf         : BOOL; // Einlaufsensor
  in_bTasterGlasbruch           AT%I* : BOOL; // Taster, Gegenscheibe wurde ausgeschleust
  in_bTasterSpezial             AT%I* : BOOL; // Taster, Sonderscheibe zugestellt

  // HARDWARE AUSGAENGE
  out_bSenderBereit             AT %Q* : BOOL; // Anlage zum Transport bereit
  out_bSenderGlasBereit         AT %Q* : BOOL; // Glas bereit zum Transport
  out_bLeuchteGlasbruch         AT %Q* : BOOL;
  out_bLeuchteSpezial           AT %Q* : BOOL;
  out_bAmpelEventAktiv          AT %Q* : BOOL;

END_VAR


//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN
  blErsterZyklus:=FALSE;

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: DEAKTIVIERUNG
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Schnittstelle deaktiviert (MK bDeaktivieren): Ausgaenge zur Fremdanlage abschalten, Baustein verlassen.
     Abgeleitete Bausteine pruefen nach SUPER^() selbst und schalten ihre eigenen Ausgaenge ab
*)
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  out_bSenderBereit     := FALSE;
  out_bSenderGlasBereit := FALSE;
  out_bLeuchteGlasbruch := FALSE;
  out_bLeuchteSpezial   := FALSE;
  out_bAmpelEventAktiv  := FALSE;
  bpISOLineEventAktiv   := FALSE;
  rpGeschwindigkeit     := 0;
  RETURN;
END_IF

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bReset ) THEN
  Reset();
END_IF

IF ( BasisStationsParameter.stMKs.stFremdanlage.bAnzeigeISOLinieEventAktiv ) THEN
  IGLineEvent();
END_IF

A_Schnittstelle();

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: ZUWEISUNGEN, AUFRUFE
//-------------------------------------------------------------------------------------------------
Horn(bpAktiv := bgHornAktivieren);
END_FUNCTION_BLOCK