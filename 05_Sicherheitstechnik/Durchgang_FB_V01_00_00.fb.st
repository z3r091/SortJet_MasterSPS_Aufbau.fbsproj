(* METADATA
{
	"v3Meta": {
		"objectGuid": "fc23c363-cc05-42cf-86d7-bbdeb020e062"
	}
}
*)
FUNCTION_BLOCK Durchgang_FB_V01_00_00
VAR_INPUT

  // BOOL
  bpFreigabeZumOeffnenDurchgang    : BOOL;
  bpDurchgangGeschlossen           : BOOL;
  bpSKGeschlossen                  : BOOL;
  bpAbschrankung_Geschlossen       : BOOL;     //Signal aus der Safety, das die Abschrankung geschlossen ist

  // WORD
  wSicherheitskreis                : WORD;

  //Baustein
  BeweglicheAbschrankung          : ZylinderPneumatik_FB_V01_00_00;

  // POINTER
  ppParameterBaustein          : REFERENCE TO Parameter_Durchgang;

END_VAR
VAR_OUTPUT

  // BOOL
  bpAnforderungZumDurchgangOffnenGestellt : BOOL;
  bpStatusDurchgangNichtGeschlossen       : BOOL;

END_VAR
VAR
  // BOOL
  blErsterZyklus     : BOOL := TRUE;

  // TRIGGER
  rtlTuerGeschlossen : R_TRIG;

  // TIMER
  tonlNotEinlass     : TON;

END_VAR
VAR

  // HARDWARE EINGÄNGE
  in_bTasterAnforderungOeffnen_1          AT %I* : BOOL;
  in_bTasterAnforderungOeffnen_2          AT %I* : BOOL;
  in_bTasterQuittierungSchliessen_1       AT %I* : BOOL;
  in_bTasterQuittierungSchliessen_2       AT %I* : BOOL;

  // HARDWARE AUSGÄNGE
  out_bLeuchteTasterAnforderungDurchgang1  AT %Q* : BOOL;
  out_bLeuchteTasterAnforderungDurchgang2  AT %Q* : BOOL;
  out_bLeuchteTasterQuittierungDurchgang1  AT %Q* : BOOL;
  out_bLeuchteTasterQuittierungDurchgang2  AT %Q* : BOOL;
  out_bDurchgangSperren                    AT %Q* : BOOL;
  out_bVerriegelungOeffnen                 AT %Q* : BOOL;
  out_bVerriegelungSchliessen              AT %Q* : BOOL;

END_VAR
//-------------------------------------------------------------------------------------------------
// Initialisierung
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus  ) THEN
  blErsterZyklus := FALSE;

  IF bpDurchgangGeschlossen THEN
    out_bDurchgangSperren := TRUE;
    bpAnforderungZumDurchgangOffnenGestellt := FALSE;
  END_IF
END_IF

bpAbschrankung_Geschlossen:= BeweglicheAbschrankung.in_bStatusZylinderEingefahren;


//-------------------------------------------------------------------------------------------------
// BAUSTEIN: EINSTELLUNGEN
//-------------------------------------------------------------------------------------------------
// Timer
tonlNotEinlass(IN := in_bTasterAnforderungOeffnen_1 OR in_bTasterAnforderungOeffnen_2, PT := T#7S);


//-------------------------------------------------------------------------------------------------
// BAUSTEIN: VERWALTUNG DER TÜREN
//-------------------------------------------------------------------------------------------------
//Anforderung zum betreten des Sicherheitskreises durch die entsprechende Tür
IF( in_bTasterAnforderungOeffnen_1 OR in_bTasterAnforderungOeffnen_2 ) THEN
  bpAnforderungZumDurchgangOffnenGestellt := TRUE;
END_IF

(* Hinweis:
   - Zuruecksetzen der Anforderung:
     => Wenn die Tuer geoeffnet wurde
     => Quittieren der Tuer
*)
IF ( in_bTasterQuittierungSchliessen_1 or in_bTasterQuittierungSchliessen_2 ) THEN
  bpAnforderungZumDurchgangOffnenGestellt := FALSE;
END_IF

// Ansteuerung der Taster-Leuchte
out_bLeuchteTasterAnforderungDurchgang1 := out_bLeuchteTasterAnforderungDurchgang2 := (( bpAnforderungZumDurchgangOffnenGestellt AND gbFlashbit05sec )
                                                                                        OR NOT out_bDurchgangSperren );

// Bewegliche Abschrankung schließen
IF ( bpFreigabeZumOeffnenDurchgang
     AND bpAnforderungZumDurchgangOffnenGestellt
     AND ppParameterBaustein.bBeweglicheAbschrankung
     AND NOT( BeweglicheAbschrankung.epStatusZylinder = eZylinderEingefahren) )
THEN
  BeweglicheAbschrankung.bpStartEinfahren := TRUE; //Einfahren = schließen
  BeweglicheAbschrankung.bpStartAusfahren := FALSE;//Ausfahren = öffnen
ELSE
  BeweglicheAbschrankung.bpStartEinfahren := FALSE;//Einfahren = schließen
END_IF

IF BeweglicheAbschrankung.bpDone AND BeweglicheAbschrankung.bpStartEinfahren THEN
  BeweglicheAbschrankung.bpStartEinfahren := FALSE;//Ausfahren = öffnen
END_IF

// Tür oeffnen
IF ( bpFreigabeZumOeffnenDurchgang
     AND bpAnforderungZumDurchgangOffnenGestellt
     AND( bpAbschrankung_Geschlossen OR NOT (ppParameterBaustein.bBeweglicheAbschrankung) ) ) OR tonlNotEinlass.Q
THEN
  out_bDurchgangSperren := FALSE;
ELSE
  out_bDurchgangSperren := TRUE;
END_IF


// Tür wieder schließen und zurücksetzen
rtlTuerGeschlossen(CLK := ( in_bTasterQuittierungSchliessen_1 OR in_bTasterQuittierungSchliessen_2 ) AND bpDurchgangGeschlossen );
IF ( rtlTuerGeschlossen.Q  ) THEN
  bpAnforderungZumDurchgangOffnenGestellt := FALSE;
END_IF

//IF ppParameterBaustein.bBeweglicheAbschrankung AND bpDurchgangGeschlossenVerriegelt AND NOT bpAnforderungZumDurchgangOffnenGestellt THEN
IF ppParameterBaustein.bBeweglicheAbschrankung AND bpDurchgangGeschlossen
   AND NOT bpAnforderungZumDurchgangOffnenGestellt AND NOT ( BeweglicheAbschrankung.epStatusZylinder =eZylinderAusgefahren) THEN
  BeweglicheAbschrankung.bpStartEinfahren := FALSE;//Einfahren = schließen
  BeweglicheAbschrankung.bpStartAusfahren := TRUE; //Ausfahren = öffnen
END_IF

IF BeweglicheAbschrankung.bpDone AND BeweglicheAbschrankung.bpStartAusfahren THEN
  BeweglicheAbschrankung.bpStartAusfahren := FALSE;//Ausfahren = öffnen
END_IF

// Bolzen ausfahren lassen
IF in_bTasterQuittierungSchliessen_1 OR in_bTasterQuittierungSchliessen_2 THEN
  out_bVerriegelungSchliessen := TRUE;
  out_bVerriegelungOeffnen    := FALSE;

ELSE
  out_bVerriegelungSchliessen := out_bDurchgangSperren;
  out_bVerriegelungOeffnen    := NOT out_bDurchgangSperren;
END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Meldung ob die Tuer geschlossen und verschlossen ist
bpStatusDurchgangNichtGeschlossen       := NOT bpSKGeschlossen;
out_bLeuchteTasterQuittierungDurchgang1 := out_bLeuchteTasterQuittierungDurchgang2 := NOT bpDurchgangGeschlossen;

// Aufruf der Unterbausteine
BeweglicheAbschrankung(bpAktivieren:=ppParameterBaustein.bBeweglicheAbschrankung, bpReset := Job_Stationen.abpReset[apgMKSicherheiskreis[ppParameterBaustein.eZuBlockierenderSK].eaAutomatikkreis[1]]);


// Meldungen für den Unterbaustein
WatchIoControl(T#10S, ppParameterBaustein.wMeldungsNummer + 0, (BeweglicheAbschrankung.wpFehlerNr = cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN)); //Fehler beim SChließen des Durchgangs
WatchIoControl(T#10S, ppParameterBaustein.wMeldungsNummer + 1, (BeweglicheAbschrankung.wpFehlerNr = cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN)); //Fehler beim Öffnen des Durchgangs
END_FUNCTION_BLOCK