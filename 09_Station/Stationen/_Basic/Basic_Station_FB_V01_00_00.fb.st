(* METADATA
{
	"v3Meta": {
		"objectGuid": "b8afb014-b2bc-4dd4-b6e0-59869c47ec49"
	}
}
*)
FUNCTION_BLOCK Basic_Station_FB_V01_00_00
VAR_IN_OUT

  // STRUKT
  BasisStationsParameter : StationBasisParameter_ST;

END_VAR

VAR_INPUT


END_VAR

VAR_OUTPUT

  // DWORD
  dwpHandfunktionenReturn    : DWORD; // Aktive Handfunktionen, gleiche Bitbelegung wie dwlHandfunktionen (Aktion HandfunktionenStatus der Station)

END_VAR

VAR

  // BOOLEAN
  blErsterZyklus             : BOOL := TRUE; // Initialisierung
  blBetriebsartHand          : BOOL;
  blBetriebsartReset         : BOOL;
  blBetriebartCheck          : BOOL;
  blBetriebsartAutomatik     : BOOL;
  blBetriebsartReferenz      : BOOL;
  blMerkerFehlerAutomatik    : BOOL;
  blNachSystemcheckMerker    : BOOL; // Merkt sich, wenn der Systemcheck erfolgreich durchgeführt wurde, damit die Gebläse nicht nach dem Systemcheck ausgehen

  // WORD
  wlBetriebsart              : WORD;
  wlWatchIONachrichtenNummer : WORD;
  wlIndex                    : WORD;

  // DWORD
  dwlHandfunktionen                : DWORD;  // Handfunktionen: 0..31 Bit
  dwlHandfunktionenZuletztGesendet : DWORD;  // Rueckmeldung der Handfunktionen zum MMI

  // STEPS
  steplReset                 : Steps_TE;
  steplCheck                 : Steps_TE;
  steplReferenz              : Steps_TE;
  steplEintransport          : Steps_TE;
  steplAustransport          : Steps_TE;
  steplVortransport          : Steps_TE;
  steplDurchtransport        : Steps_TE;
  steplMesskopplung          : Steps_TE;
  steplAnlegen               : Steps_TE;
  steplAbnehmen              : Steps_TE;
  steplGlaslaengenmessung    : Steps_TE;
  steplGlashoehenmessung     : Steps_TE;
  steplPositionieren         : Steps_TE;

  // TRIGGER
  ftlBausteinDeaktivierung              : F_TRIG;
  rtlFehlerMeldungGenerierenHandbetrieb : R_TRIG;

  // TIMER
  tonlMaxWarteAufResetErfolgreich       : TON;


END_VAR

//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG UND EINSTELLUNGEN
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus  ) THEN

  blErsterZyklus := FALSE;

  // Initialisierung des Bausteins
  A_Baustein_Initialisierung();

END_IF

//-------------------------------------------------------------------------------------------------
// DEAKTIVIERUNG DES BAUSTEINS
//-------------------------------------------------------------------------------------------------

// Werte wieder passend abloeschen, wenn der Baustein wieder aktiviert wird
ftlBausteinDeaktivierung( CLK := BasisStationsParameter.stMKs.bDeaktivieren );

IF ( ftlBausteinDeaktivierung.Q ) THEN

  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
    BasisStationsParameter.bAustransportAbgeschlossen[wlIndex]   := FALSE;
    BasisStationsParameter.bDurchtransportAbgeschlossen[wlIndex] := FALSE;
    BasisStationsParameter.bEintransportAbgeschlossen[wlIndex]   := FALSE;
    BasisStationsParameter.bMesskopplungAbgeschlossen[wlIndex]   := FALSE;
    BasisStationsParameter.bVorabKomponentenAnsteuerungAbgeschlossen[wlIndex] := FALSE;
    BasisStationsParameter.bVortransportAbgeschlossen[wlIndex]   := FALSE;
    BasisStationsParameter.bStationBelegt[wlIndex]               := FALSE;
  END_FOR

  BasisStationsParameter.bFehler                := FALSE;
  BasisStationsParameter.wFehlerNummer          := cMELDUNG_NULL;
  BasisStationsParameter.bAuftragAktiv          := FALSE;
  BasisStationsParameter.bReset                 := FALSE;
  BasisStationsParameter.bIstReferenziert       := FALSE;
  BasisStationsParameter.bCheckAbgeschlossen    := FALSE;
  BasisStationsParameter.bReferenzAbgeschlossen := FALSE;

END_IF

(* Hinweis:
   - Deaktivierung des Bausteins
     => Der Baustein wird zum Ende der RETURN-Anweisung verlassen
*)
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN

  A_ScheibenDeaktivierteStationMelden();

  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
    BasisStationsParameter.bAustransportAbgeschlossen[wlIndex]   := TRUE;
    BasisStationsParameter.bDurchtransportAbgeschlossen[wlIndex] := TRUE;
    BasisStationsParameter.bEintransportAbgeschlossen[wlIndex]   := TRUE;
    BasisStationsParameter.bMesskopplungAbgeschlossen[wlIndex]   := TRUE;
    BasisStationsParameter.bVorabKomponentenAnsteuerungAbgeschlossen[wlIndex] := TRUE;
    BasisStationsParameter.bVortransportAbgeschlossen[wlIndex]   := TRUE;
    BasisStationsParameter.bStationBelegt[wlIndex]               := FALSE;
  END_FOR

  BasisStationsParameter.bAbnehmenAbgeschlossen := TRUE;
  BasisStationsParameter.bAnlegenAbgeschlossen := TRUE;
  BasisStationsParameter.bCheckAbgeschlossen    := TRUE;
  BasisStationsParameter.bGlashoehenmessungAbgeschlossen := TRUE;
  BasisStationsParameter.bGlaslaengenmessungAbgeschlossen := TRUE;
  BasisStationsParameter.bReferenzAbgeschlossen := TRUE;
  BasisStationsParameter.bVorabDrehenAbgeschlossen := TRUE;
  BasisStationsParameter.bVorabpositionierenAbgeschlossen := TRUE;
  BasisStationsParameter.bIstReferenziert       := TRUE;

  BasisStationsParameter.bReset        := FALSE;
  BasisStationsParameter.bFehler := FALSE;
  BasisStationsParameter.wFehlerNummer := cMELDUNG_NULL;
  BasisStationsParameter.bAuftragAktiv := FALSE;

  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
A_Schnittstelle();
Betriebsart();
Meldungen();

//-------------------------------------------------------------------------------------------------
// TIMER
//-------------------------------------------------------------------------------------------------
// Reset
tonlMaxWarteAufResetErfolgreich( IN := BasisStationsParameter.bReset, PT := tgMaxWartezeitReset);
END_FUNCTION_BLOCK