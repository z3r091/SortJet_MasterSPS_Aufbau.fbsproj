(* METADATA
{
	"v3Meta": {
		"objectGuid": "c9895c16-daf8-42f8-8f64-ac96a02bd793"
	}
}
*)
FUNCTION_BLOCK Geblaese_Schuetz_FB_V01_00_00
VAR_INPUT

  // BOOLEAN
  bpAktivieren              : BOOL;
  bpStart                   : BOOL;
  bpReset                   : BOOL;
  bpFreigabe                : BOOL;
  bpTeilnehmerErreichbar    : BOOL := TRUE;
  bpIOsBoschDrive               : BOOL;

  // EINGÄNGE
  bpMotorschutzschalter_OK  : BOOL;
  bpDrehzahlErreicht        : BOOL := TRUE; // Sanftanlauf: Drehzahl erreicht (ohne Sanftanlauf TRUE lassen)

  // DROSSELKLAPPE
  bpDrosselklappeAnforderung : BOOL; // Station: Drosselklappe soll offen sein (Transport, Anlegen, Geblaese gestartet)

  // STEUERUNG (wann das Geblaese laufen soll, Aktion Steuerung)
  bpAutomatik        : BOOL;            // Automatik / Check: Geblaese nach Aktivitaet mit Energiesparmodus
  bpAktivitaet       : BOOL;            // Station braucht das Geblaese (z.B. Auftrag aktiv)
  bpAktivitaetFlanke : BOOL;            // Anlegestation: nur die steigende Flanke der Aktivitaet startet, danach Abschaltzeit
  bpTaster           : BOOL;            // Taster am Geblaese: umschalten
  bpHandEin          : BOOL;            // Handbetrieb: Geblaese laeuft, solange gesetzt
  bpSperre           : BOOL;            // Geblaese sofort aus (Reset, Verriegelung)
  tpMindestlaufzeit  : TIME := T#500MS; // Der Taster schaltet erst nach dieser Laufzeit aus

  // STRUKT
  stStationsNummern       : Station_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFehler                 : BOOL;
  bpDone                   : BOOL;
  bpStarteGeblaese         : BOOL; // Geblaese wird angesteuert (Schuetz)
  bpDrosselklappeOeffnen   : BOOL; // Drosselklappe oeffnen: angefordert und Geblaese laeuft

  // WORD
  wpFehlerNr : Fehlerkonstanten_EN;

END_VAR
VAR

  // BOOLEAN
  blErsterZyklus           : BOOL := TRUE; // Initialisierung
  blMeldungAbgesetzt       : BOOL := FALSE;
  blMotorschutzschalter_OK : BOOL;

  // ARRAY
  awlErrorAdditional : ARRAY [0..25]  OF WORD;

  // STEPS
  steplStart      : Steps_TE;

  // TIMER
  tonlStartGeblaese          : TON;
  tonlWarteAufGeblaeseLaeuft : TON;
  toflWarteAufWiederAnlauf   : TOF;
  toflMotorschutz            : TOF;
  toflEnergiesparModus       : TOF; // Energiesparmodus: Geblaese nach der Abschaltzeit ohne Aktivitaet aus
  tonlMindestlaufzeit        : TON;

  // TRIGGER
  rtlAutomatik               : R_TRIG;
  rtlAktivitaet              : R_TRIG;
  rtlTaster                  : R_TRIG;

  // BOOLEAN (Steuerung)
  blTasterAus                : BOOL; // Automatik: Geblaese per Taster ausgeschaltet (bis zur naechsten Aktivitaet)
  blHandTaster               : BOOL; // Handbetrieb: Geblaese per Taster eingeschaltet

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bMotorschutzschalter_OK    AT %I* : BOOL;

  // HARDWARE AUSGAENGE
  out_bStarteGeblaese           AT %Q* : BOOL;

END_VAR

VAR CONSTANT

  // TIME
  WARTEZEIT_BIS_WIEDERANLAUF          : TIME := T#7000MS;
  WARTEZEIT_BIS_GEBLAESE_HOCHGELAUFEN : TIME := T#2000MS;

END_VAR

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN
  blErsterZyklus:=FALSE;

  (* Hinweis:
     - Timer initialisieren
  *)
  toflWarteAufWiederAnlauf(IN:=FALSE);
  tonlWarteAufGeblaeseLaeuft(IN:=FALSE);

END_IF
// IO Zuweisung
IF ( bpIOsBoschDrive ) THEN
  blMotorschutzschalter_OK  := bpMotorschutzschalter_OK;
ELSE
  blMotorschutzschalter_OK  := in_bMotorschutzschalter_OK;
END_IF


//-------------------------------------------------------------------------------------------------
// BAUSTEIN: DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF ( NOT bpAktivieren ) THEN
  bpDone                 := TRUE;
  bpStarteGeblaese       := FALSE;
  bpDrosselklappeOeffnen := FALSE;
  bpFehler   := FALSE;
  wpFehlerNr := cMELDUNG_NULL;

  RETURN;

END_IF


//-------------------------------------------------------------------------------------------------
// BAUSTEIN: STEUERUNG
//-------------------------------------------------------------------------------------------------
Steuerung();

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: TIMER
//-------------------------------------------------------------------------------------------------
toflWarteAufWiederAnlauf(IN :=     out_bStarteGeblaese,
                          PT := WARTEZEIT_BIS_WIEDERANLAUF);

tonlWarteAufGeblaeseLaeuft(IN :=     out_bStarteGeblaese,
                            PT := WARTEZEIT_BIS_GEBLAESE_HOCHGELAUFEN );

toflMotorschutz( IN := blMotorschutzschalter_OK, PT := T#5S );

(* Hinweis:
   - Einschaltverzoegerung
*)
tonlStartGeblaese(IN :=     bpStart
                   AND bpFreigabe
                   AND NOT toflWarteAufWiederAnlauf.Q
                   AND NOT bpReset,
                   PT := T#0S);



//-------------------------------------------------------------------------------------------------
// BAUSTEIN: STEUERUNG
//-------------------------------------------------------------------------------------------------
IF ( bpReset ) THEN

  bpStart   := FALSE;
  bpDone    := FALSE;
  bpReset   := FALSE;
  bpFehler  := FALSE;

  blMeldungAbgesetzt := FALSE;

  wpFehlerNr := cMELDUNG_NULL;

  out_bStarteGeblaese := FALSE;

ELSE
  Start();
  Meldungen();

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUSGAENGE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Ansteuerung des Geblaeses fuer Stationen, die den Ausgang selbst schalten (z.B. zwei Geblaese oder Ausgang am Umrichter)
   - Die Drosselklappe ist nur offen, wenn sie angefordert ist und das Geblaese laeuft (Drehzahl erreicht)
*)
bpStarteGeblaese       := out_bStarteGeblaese;
bpDrosselklappeOeffnen := bpDrosselklappeAnforderung AND bpDone;
END_FUNCTION_BLOCK