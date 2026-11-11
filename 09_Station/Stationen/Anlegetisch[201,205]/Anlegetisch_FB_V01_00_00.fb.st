(* METADATA
{
	"v3Meta": {
		"objectGuid": "d4e6e20e-ec1c-45cb-88d5-76340f232224"
	}
}
*)
FUNCTION_BLOCK Anlegetisch_FB_V01_00_00 EXTENDS Basic_Station_FB_V01_00_00

VAR_INPUT

  // BOOLEAN
  bpAbbruchAnlegeauftrag            : BOOL;  // Der Anlegeauftrag wurde vom MMI abgebrochen
  bpFreigabeScheibe                 : BOOL;  // Wird vom MMI gesetzt. Scheibe wurde erfolgreich vom Scanner vermessen
  bpKeineFreigabeScheibe            : BOOL;  // Wird vom MMI gesetzt. Scheibe wurde nicht erfolgreich vom Scanner vermessen

  in_bSensorKipptischUnten          : BOOL;

  // Safety Eingang
  in_bSchaltleisteAusgeloest_Safety : BOOL; // Schaltleiste am Tisch. Verhinderung von Quetschungen

END_VAR
VAR_OUTPUT

  // ENUM
  epTypeHoehenmessung         : ModusHoehenvermessung_EN;

END_VAR
VAR

  // BOOLEAN
  blGlasBruchMeldungSperren       : BOOL := FALSE;
  blMerkerDrosselklappeAuf        : BOOL;
  blAnlegenErzwingen              : BOOL;
  blVSGUebernahme                 : BOOL; // VSG-Schnittstelle: der Eintransport der Schneidlinie hat das Anlegen uebernommen
  blNeustartAnschlag              : BOOL; // Anlegen von vorne beginnen: Anschlaege wurden umgeschaltet
  blNeustartSchneidlinie          : BOOL; // Anlegen von vorne beginnen: Eintransport der Schneidlinie wurde abgebrochen
  blLampeSchneidlinie             : BOOL; // Lampe Scheibe anlegen im Eintransport der Schneidlinie
  blDrosselklappeAnforderung      : BOOL; // Anlegen verlangt die offene Drosselklappe
  blBedienerEingriff              : BOOL; // Eine Aktion wartet auf den Bediener (Anlegen, Glaslaengenmessung)
  blAktionImFehler                : BOOL; // Eine der wandweisen Aktionen steht im Fehler
  blFreigabeTischKippen           : BOOL;
  blVSG_Automatik_Eintransport    : BOOL;
  blAnschlagAutomatischFahren     : BOOL;
  blMerkerAnschlagTasterFahren    : BOOL;

  // TIME
  tlZeitBereitAnzulegen                 : TIME; // STATISTIK: Zeiteinheit zum Vergleichen
  toflEinlaufsensor                     : TOF;
  toflZeitlicheSperrungGlasbruch        : TOF;
  tonlTasterGlasbruch                   : TON;
  tonlTasterGlasAbgenommen              : TON;
  tonlStatusKippstatusUnten             : TON;
  tonlStatusKippenOben                  : TON;
  toflDruckluftOK                       : TOF;
  tonlKnebelZurueck                     : TON;

  // TRIGGER
  rtlFussleisteStart                    : R_TRIG;
  rtlAnlegenFertig                      : R_TRIG;
  rtlEintransportDrosselklappe          : R_TRIG;
  rtlEintransportAbgeschlossen          : R_TRIG;
  rtlAustransportStart                  : R_TRIG;
  ftlEintransportAktiv                  : F_TRIG;
  rtlGeblaeseLaeuft                     : R_TRIG;
  ftlGeblaeseLaeuft                     : F_TRIG;
  rtlGlaslaengenmessungStart            : R_TRIG;
  ftlGlaslaengenmessungAktiv            : F_TRIG;
  ftlGlashoehenmessungAktiv             : F_TRIG;
  rtlDrosselklappeAnforderung           : R_TRIG;
  ftlDrosselklappeAnforderung           : F_TRIG;
  ftlAnlegenAktiv                       : F_TRIG;
  ftlAnlegenBedienerEingriff            : F_TRIG;
  rtlTasterQuittierung                  : R_TRIG;
  rtlTasterGlasAbgenommen               : R_TRIG;
  rtlTasterGlasbruch                    : R_TRIG;
  rtlGlasBruchSperren                   : R_TRIG;
  ftlHubrahmenAbsenken                  : F_TRIG;
  ftlVSGAutomatikBetriebBeendet         : F_TRIG;
  ftlGlastransportCheckMitNachfolger    : F_TRIG;
  rtlKipparmeAnschlaegeAuf              : R_TRIG;
  rtlKipparmeAnschlaegeAb               : R_TRIG;
  rtlAnschlaegeAufAb                    : R_TRIG;

  // REAL
  rlScheibenHoehe       : REAL;
  rlAbstandZurNulllinie : REAL;

  // STEPS
  steplEintransportSchneidlinie : Steps_TE;

  // AKTION (STATION)
  Anlegen : Basic_Station_Anlegen_FB_V01_00_00;
  Glaslaengenmessung : Basic_Station_Glaslaengenmessung_FB_V01_00_00;

  // AKTIONEN (WANDWEISE)
  Eintransport       : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Anlegetisch_Eintransport_FB_V01_00_00;
  Austransport       : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Anlegetisch_Austransport_FB_V01_00_00;
  Glashoehenmessung  : Basic_Station_Glashoehenmessung_FB_V01_00_00;

  // BAUSTEINE
  Geblaese : Geblaese_Schuetz_FB_V01_00_00; // Geblaese 1 und 2 (Ausgang und Motorschutz kommen von der Station)

END_VAR

VAR_INPUT

  // BAUSTEINE
  Anschlag            : ZylinderPneumatik_Anschlag_FB_V01_00_00;
  Messachse           : Messachse_FB_V01_00_00;
  Glastransport       : Anlegetisch_Glastransport_FB_V01_00_00;
  Hubrahmen           : ZylinderPneumatik_Riemen_FB_V01_00_00;

END_VAR
VAR

  // Taster
  in_bFussschalterGlasAngelegt                    : BOOL; // Fusspedal - Fusstaster: Quittierung Glas angelegt
  in_bTasterGlasAngelegt                   AT %I* : BOOL; // Weißer Leuchtdrucktaster: Quittierung Glas angelegt
  in_bTasterQuittierungScheibenmessung     AT %I* : BOOL; // Weißer Leuchtdrucktaster
  in_bKnebelRiemenVor                      AT %I* : BOOL; // Knebeltaster zum zurückfahren der Riemen
  in_bKnebelRiemenZurueck                  AT %I* : BOOL; // Knebeltaster zum zurückfahren der Riemen
  in_bTasterGlasBruch                      AT %I* : BOOL;
  in_bTasterGlasAbgenommen                 AT %I* : BOOL;
  in_bTasterAnschlaege                     AT %I* : BOOL;

  // Basic
  in_bDruckluft_OK                                : BOOL; // Druckluftversorung OK

  // Gebläse
  in_bTasterGeblaese1Ein                   AT %I* : BOOL;
  in_bTasterGeblaese2Ein                   AT %I* : BOOL;
  in_bMotorschutzGeblaese_Ok               AT %I* : BOOL;
  in_bDrehzahlErreicht                     AT %I* : BOOL; // Das Sanftanlaufmodul gibt ein Signal raus, wenn die Drehzahl erreicht ist

  out_bDrosselklappeOeffnen                       : BOOL;
  out_bGeblaese1Ein                        AT %Q* : BOOL;
  out_bGeblaese2Ein                        AT %Q* : BOOL;

  // Hydraulisch Kippen
  in_bMotorschutzHydraulik                 AT %I* : BOOL;
  in_bTasterKippenAuf                      AT %I* : BOOL;
  in_bTasterKippenAb                       AT %I* : BOOL;
  in_bTasterKippenAuf_OP                   AT %I* : BOOL;
  in_bTasterKippenAb_OP                    AT %I* : BOOL;
  in_bTasterAnforderungKippen              AT %I* : BOOL;
  in_bTasterAnforderungKippen_OP           AT %I* : BOOL;
  in_bSensorKipptischOben                  AT %I* : BOOL;
  in_bSensorKippsicherungGeschlossen       AT %I* : BOOL;
  in_bSensorKippsicherungOffen             AT %I* : BOOL;
  in_bSchaltleisteAusgeloest               AT %I* : BOOL; // Schaltleiste die das Kippen-Abschaltet wenn diese auf etwas trifft

  out_bHydraulikpumpeEin                   AT %Q* : BOOL;
  out_bHydraulikpumpeUmlaufVentil          AT %Q* : BOOL;
  out_bKippsicherungoeffnen                AT %Q* : BOOL;
  out_bKipptischAuf                        AT %Q* : BOOL;
  out_bKipptischAb                         AT %Q* : BOOL;
  out_bLeuchteKipptischOffen               AT %Q* : BOOL;
  out_bLeuchteKipptischOffen_OP            AT %Q* : BOOL;
  out_bSchaltleisteAusgeloest              AT %Q* : BOOL;
  out_bKipptischHornWarnsignal             AT %Q* : BOOL;
  out_bKipptischAmpelWarnsignal            AT %Q* : BOOL;
  out_bAmpelSignalGlastransportAktiv       AT %Q* : BOOL;

  // Kipparme
  in_bTasterKipparmeAuf                    AT %I* : BOOL;
  in_bTasterKipparmeAb                     AT %I* : BOOL;
  in_bMotorschutschalterKipparme           AT %I* : BOOL;
  in_bSensorKipparmeNichtOben              AT %I* : BOOL;
  in_bSensorKipparmeNichtUnten             AT %I* : BOOL;
  in_bSensorKipparmeAnschlaegeOben         AT %I* : BOOL;
  in_bSensorKipparmeAnschlaegeUnten        AT %I* : BOOL;

  out_bKipparmeAuf                         AT %Q* : BOOL;
  out_bKipparmeAb                          AT %Q* : BOOL;
  out_bKipparmeAnschlaegeAuf               AT %Q* : BOOL;
  out_bKipparmeAnschlaegeAb                AT %Q* : BOOL;


  // HARDWARE AUSGAENGE
  out_bAmpelSignalRot                      AT %Q* : BOOL; // Rote Ampel
  out_bAmpelSignalGruenScheibeAnlegen      AT %Q* : BOOL; // Gruene Ampel

  out_bSignalTasterScheibeQuittieren       AT %Q* : BOOL; // Gelber Leuchdrucktaster | Fehlmessung quittiern
  out_bSignalTasterScheibeAnlegen          AT %Q* : BOOL; // Weißer Leuchdrucktaster | Scheibe anlegen



END_VAR
VAR CONSTANT


  // TIME
  ZEIT_GEBLASE_FREIGABE_AUSSCHALTEN             : TIME := T#4000MS;  // Zeit ab wann das Geblaese ueber den Taster ausgeschaltet werden kann, nach dem der Ausgang <<Geblaese ein>> gesetzt wurde
  ZEITLICHE_VERZOEGERUNG_TASTER_GLASBRUCH       : TIME := T#200ms;
  ZEITLICHE_VERZOEGERUNG_TASTER_GLASABGENOMMEN  : TIME := T#200ms;
  ZEITLICHE_SPERRUNG_TASTER_GLASBRUCH           : TIME := T#2s;

END_VAR

//-------------------------------------------------------------------------------------------------
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
IF blErsterZyklus THEN
  // Default aus der Stationsoption, ueber den Taster Anschlaege umschaltbar (siehe Aktion Taster)
  blAnschlagAutomatischFahren := BasisStationsParameter.stMKs.stStationsOptionen.stAnlegetisch.bAnschlagAutomatischAusfahren;
END_IF

SUPER^(BasisStationsParameter := BasisStationsParameter);

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  HandfunktionenStatus();
  RETURN;
END_IF

//-------------------------------------------------------------------------------------------------
// IO ZUWEISUNG
//-------------------------------------------------------------------------------------------------

// Riemen
Hubrahmen.in_bStatusZylinderAusgefahren := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_5_I_7;
Hubrahmen.in_bStatusZylinderEingefahren := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_6_I_8;

Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_O_5 := Hubrahmen.out_bZylinderAusfahren;
Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_O_6 := out_bDrosselklappeOeffnen OR bgVISUDrosselklappeAUF[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

// Anschläge
Anschlag.in_bStatusZylinderAusgefahren := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_1_IO_1;
Anschlag.in_bStatusZylinderEingefahren := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_2_IO_2;

Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_O_7 := Anschlag.out_bZylinderEinfahren;
Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_O_8 := Anschlag.out_bZylinderAusfahren;

// Baustein
in_bDruckluft_OK             := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_3_I_5;
in_bFussschalterGlasAngelegt := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_4_I_6;

Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_IO_3 := out_bAmpelSignalRot OR abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].boutAmpelRot;
Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_IO_4 := out_bAmpelSignalGruenScheibeAnlegen  OR abgStationsstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].boutAmpelGruen;

//-------------------------------------------------------------------------------------------------
// DEAKTIVIERUNG
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Werte wieder passend abloeschen, wenn der Baustein wieder aktiviert wird
*)
ftlBausteinDeaktivierung( CLK := BasisStationsParameter.stMKs.bDeaktivieren );

IF ( ftlBausteinDeaktivierung.Q ) THEN

  BasisStationsParameter.bAnlegenAbgeschlossen               := FALSE;
  BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;
  BasisStationsParameter.bGlaslaengenmessungAbgeschlossen    := FALSE;
  BasisStationsParameter.bGlashoehenmessungAbgeschlossen     := FALSE;

  BasisStationsParameter.bIstReferenziert       := FALSE;
  BasisStationsParameter.bCheckAbgeschlossen    := FALSE;
  BasisStationsParameter.bReferenzAbgeschlossen := FALSE;

END_IF

(* Hinweis:
   - Deaktivierung des Bausteins
     => Der Baustein wird zum Ende der RETURN-Anweisung verlassen
*)
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN

  IF ( BasisStationsParameter.bCheck ) THEN
    rSps2MmiMessungScheibenlaenge   := 0;
    wSps2MmiMessungStationNummer    := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
    wSps2MmiMessungSlotNummer       := 1;
    iSps2MmiMessungScheibenanzahl   := 0;

    MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );
  END_IF

  BasisStationsParameter.bAnlegenAbgeschlossen               := TRUE;
  BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := TRUE;
  BasisStationsParameter.bGlaslaengenmessungAbgeschlossen    := TRUE;
  BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := TRUE;

  BasisStationsParameter.bCheckAbgeschlossen    := TRUE;
  BasisStationsParameter.bReferenzAbgeschlossen := TRUE;
  BasisStationsParameter.bIstReferenziert       := TRUE;

  BasisStationsParameter.bFehler        := FALSE;
  BasisStationsParameter.wFehlerNummer  := cMELDUNG_NULL;

  HandfunktionenStatus();
  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------

// Basis
Reset();
Referenz();
Handfunktionen();
Taster();
A_Aufrufe();
A_Geblaese();
A_Timer();
SystemCheck();

// Automatik
(* Hinweis:
   - VSG-Schnittstelle mit Selbstentscheidung der Station: Eintransport der Schneidlinie
   - Sonst entscheidet das MMI ueber die Transferstation, ob angelegt oder eingetragen wird
*)
IF BasisStationsParameter.stMKs.stStationsOptionen.stAnlegetisch.bAnlegetischMitEintransportVorgaenger THEN
  Eintransport_Schneidlinie();
END_IF

Anlegen( BasisStationsParameter     := BasisStationsParameter,
         bpAutomatikAktiv           := blBetriebsartAutomatik,
         bpAnlegenQuittiert         := rtlFussleisteStart.Q,
         bpVoraussetzungErfuellt    := ( NOT in_bSensorKipparmeNichtUnten AND NOT in_bSensorKipparmeAnschlaegeOben ),
         bpAnschlagAutomatischFahren := blAnschlagAutomatischFahren,
         bpNeustart                 := ( blNeustartAnschlag OR blNeustartSchneidlinie ),
         bpUebernahmeEintransport   := blVSGUebernahme,
         bpBetriebBeendet           := ftlVSGAutomatikBetriebBeendet.Q,
         Glastransport              := Glastransport,
         Messachse                  := Messachse,
         Anschlag                   := Anschlag,
         Hubrahmen                  := Hubrahmen,
         blAnlegenErzwingen         := blAnlegenErzwingen );

blNeustartAnschlag     := FALSE;
blNeustartSchneidlinie := FALSE;

(* Hinweis:
   - Ausgaenge der Aktion Anlegen auf die Hardware der Station legen
   - Solange das Anlegen laeuft (und einen Zyklus danach) gehoert die Lampe dem Anlegen, danach den anderen Aktionen
*)
rtlAnlegenFertig( CLK := Anlegen.bpAnlegenFertig );
IF ( rtlAnlegenFertig.Q ) THEN
  epTypeHoehenmessung := Anlegen.epTypeHoehenmessung;
END_IF

ftlAnlegenAktiv( CLK := BasisStationsParameter.bAnlegen );
IF ( BasisStationsParameter.bAnlegen OR ftlAnlegenAktiv.Q ) THEN
  out_bAmpelSignalGruenScheibeAnlegen := ( Anlegen.bpAnlegenLampe OR blLampeSchneidlinie );
END_IF

// Drosselklappe: oeffnet bei steigender, schliesst bei fallender Flanke der Anforderung des Anlegens
blDrosselklappeAnforderung := Anlegen.bpDrosselklappeOeffnen;
rtlDrosselklappeAnforderung( CLK := blDrosselklappeAnforderung );
ftlDrosselklappeAnforderung( CLK := blDrosselklappeAnforderung );
IF ( rtlDrosselklappeAnforderung.Q ) THEN
  blMerkerDrosselklappeAuf := TRUE;
ELSIF ( ftlDrosselklappeAnforderung.Q ) THEN
  blMerkerDrosselklappeAuf := FALSE;
END_IF

// Anlegen ist Automatikbetrieb: Handfunktionen (Knebel Riemen, Hubrahmen) greifen, solange das Anlegen auf den Bediener wartet
blBedienerEingriff := (     Anlegen.bpBedienerEingriff
                           OR Glaslaengenmessung.bpBedienerEingriff
                           OR Glashoehenmessung.bpBedienerEingriff );
ftlAnlegenBedienerEingriff( CLK := blBedienerEingriff );
IF ( blBedienerEingriff ) THEN
  Glastransport.bpAnforderungHandfunktion := TRUE;
ELSIF ( ftlAnlegenBedienerEingriff.Q ) THEN
  Glastransport.bpAnforderungHandfunktion := FALSE;
END_IF

(* Hinweis:
   - Automatik-Aktion Eintransport je Wand
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Eintransport[wlIndex]( BasisStationsParameter  := BasisStationsParameter,
                         wWand                   := wlIndex,
                         bpAutomatikAktiv        := blBetriebsartAutomatik,
                         bpGeblaeseFehler        := NOT in_bMotorschutzGeblaese_Ok,
                         bpAnlegenUmschalten     := ( rtlFussleisteStart.Q OR ftlVSGAutomatikBetriebBeendet.Q ),
                         Glastransport           := Glastransport,
                         Messachse               := Messachse,
                         Anschlag                := Anschlag,
                         Hubrahmen               := Hubrahmen );
END_FOR

(* Hinweis:
   - Lampe, Drosselklappe und Modus der Hoehenmessung des Eintransports auf die Station legen
   - Die Drosselklappe oeffnet im Eintransport und schliesst die Station wie bisher (Anlegen, Messungen, Geblaese)
*)
ftlEintransportAktiv( CLK := BasisStationsParameter.bEintransport[cWAND_1] );
IF ( BasisStationsParameter.bEintransport[cWAND_1] OR ftlEintransportAktiv.Q ) THEN
  out_bAmpelSignalGruenScheibeAnlegen := Eintransport[cWAND_1].bpAnlegenLampe;
END_IF

rtlEintransportDrosselklappe( CLK := Eintransport[cWAND_1].bpDrosselklappeOeffnen );
IF ( rtlEintransportDrosselklappe.Q ) THEN
  blMerkerDrosselklappeAuf := TRUE;
END_IF

rtlEintransportAbgeschlossen( CLK := BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] );
IF ( rtlEintransportAbgeschlossen.Q ) THEN
  epTypeHoehenmessung := Modus_Vermessen_OberUndUnterkante_2_Sensoren;
END_IF
Glashoehenmessung( BasisStationsParameter  := BasisStationsParameter,
                   bpAutomatikAktiv        := blBetriebsartAutomatik,
                   bpTasterQuittierung     := rtlTasterQuittierung.Q,
                   bpKnebelZurueck         := in_bKnebelRiemenZurueck,
                   epTypeHoehenmessung     := epTypeHoehenmessung,
                   Glastransport           := Glastransport,
                   Messachse               := Messachse,
                   Anschlag                := Anschlag,
                   Hubrahmen               := Hubrahmen,
                   blAnlegenErzwingen      := blAnlegenErzwingen );

rlScheibenHoehe       := Glashoehenmessung.rpScheibenHoehe;
rlAbstandZurNulllinie := Glashoehenmessung.rpAbstandZurNulllinie;

ftlGlashoehenmessungAktiv( CLK := BasisStationsParameter.bGlashoehenmessung );
IF ( BasisStationsParameter.bGlashoehenmessung OR ftlGlashoehenmessungAktiv.Q ) THEN
  out_bAmpelSignalGruenScheibeAnlegen := Glashoehenmessung.bpAnlegenLampe;
  out_bSignalTasterScheibeQuittieren  := Glashoehenmessung.bpSignalFehlmessung;
END_IF
Glaslaengenmessung( BasisStationsParameter  := BasisStationsParameter,
                    bpAutomatikAktiv        := blBetriebsartAutomatik,
                    bpTasterQuittierung     := rtlTasterQuittierung.Q,
                    bpKnebelZurueck         := in_bKnebelRiemenZurueck,
                    Glastransport           := Glastransport,
                    Anschlag                := Anschlag,
                    Hubrahmen               := Hubrahmen,
                    blAnlegenErzwingen      := blAnlegenErzwingen,
                    bpFreigabeScheibe       := bpFreigabeScheibe,
                    bpKeineFreigabeScheibe  := bpKeineFreigabeScheibe );

(* Hinweis:
   - Beim Start der Messung ist die Drosselklappe zu, danach gehoert die Lampe der Messung
*)
rtlGlaslaengenmessungStart( CLK := BasisStationsParameter.bGlaslaengenmessung );
IF ( rtlGlaslaengenmessungStart.Q ) THEN
  blMerkerDrosselklappeAuf := FALSE;
END_IF

ftlGlaslaengenmessungAktiv( CLK := BasisStationsParameter.bGlaslaengenmessung );
IF ( BasisStationsParameter.bGlaslaengenmessung OR ftlGlaslaengenmessungAktiv.Q ) THEN
  out_bAmpelSignalGruenScheibeAnlegen := Glaslaengenmessung.bpAnlegenLampe;
  out_bSignalTasterScheibeQuittieren  := Glaslaengenmessung.bpSignalFehlmessung;
END_IF
(* Hinweis:
   - Automatik-Aktion Austransport je Wand
   - Beim Start des Austransports ist die Drosselklappe zu
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Austransport[wlIndex]( BasisStationsParameter  := BasisStationsParameter,
                         wWand                   := wlIndex,
                         bpAutomatikAktiv        := blBetriebsartAutomatik,
                         Glastransport           := Glastransport,
                         Hubrahmen               := Hubrahmen );
END_FOR

rtlAustransportStart( CLK := BasisStationsParameter.bAustransport[cWAND_1] );
IF ( rtlAustransportStart.Q ) THEN
  blMerkerDrosselklappeAuf := FALSE;
END_IF

// Gesonderte Funktionalitaet
Steuerung_Kippen();

IF BasisStationsParameter.stMKs.stStationsAufbau.bKipparme THEN
  Kipparme();
END_IF
END_FUNCTION_BLOCK