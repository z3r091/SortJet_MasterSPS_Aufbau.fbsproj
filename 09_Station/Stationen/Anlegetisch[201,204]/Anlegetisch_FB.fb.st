(* METADATA
{
	"v3Meta": {
		"objectGuid": "d4e6e20e-ec1c-45cb-88d5-76340f232224"
	}
}
*)
FUNCTION_BLOCK Anlegetisch_FB EXTENDS Basic_Station_FB

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

  // DWORD
  dwpHandfunktionenReturn : DWORD; (* Aktive Handfunktionen, gleiche Bitbelegung wie dwlHandfunktionen *)

  // ENUM
  epTypeHoehenmessung         : ModusHoehenvermessung_EN;

END_VAR
VAR

  // Rueckmeldung der Handfunktionen zum MMI
  dwlHandfunktionenZuletztGesendet : DWORD;

 // BOOLEAN
  blFreigabeGeblaeseStartenSensor : BOOL := FALSE;  // Durch den Einlaufsensor wird das Gebläase gestartet
  blGlasBruchMeldungSperren       : BOOL := FALSE;
  blMerkerDrosselklappeAuf        : BOOL;
  blAnlegenErzwingen              : BOOL;
  blFreigabeTischKippen           : BOOL;
  blVSG_Automatik_Eintransport    : BOOL;
  blAnschlagAutomatischFahren     : BOOL;
  blMerkerAnschlagTasterFahren    : BOOL;

  // TIME 
  tlZeitBereitAnzulegen                 : TIME; // STATISTIK: Zeiteinheit zum Vergleichen
  toflEinlaufsensor                     : TOF; 
  toflGeblaeseEnergiesparModus          : TOF;  // Timer um das Geblaese bei langen Stillstandszeiten abzuschalten *)
  toflZeitlicheSperrungGlasbruch        : TOF;
  tonlTasterGlasbruch                   : TON; 
  tonlTasterGlasAbgenommen              : TON; 
  tonlStatusKippstatusUnten             : TON; 
  tonlStatusKippenOben                  : TON; 
  tofGeblaeseFreigabeAusschalten        : TOF;
  toflDruckluftOK                       : TOF;
  tonlKnebelZurueck                     : TON;

  // TRIGGER
  rtlFussleisteStart                    : R_TRIG;
  rtlTasterQuittierung                  : R_TRIG;
  rtlGeblaese                           : R_TRIG;
  rtlTasterGeblaese                     : R_TRIG;
  rtlTasterGlasAbgenommen               : R_TRIG;
  rtlTasterGlasbruch                    : R_TRIG;
  rtlGlasBruchSperren                   : R_TRIG;
  ftTonGeblaesePowerSaving              : F_TRIG;
  ftlHubrahmenAbsenken                  : F_TRIG;
  ftlGeblaese                           : F_TRIG;
  rtlAnlegen                            : R_TRIG;
  ftlVSGAutomatikBetriebBeendet         : F_TRIG;
  ftlGlastransportCheckMitNachfolger    : F_TRIG;
  rtlKipparmeAnschlaegeAuf              : R_TRIG;
  rtlKipparmeAnschlaegeAb               : R_TRIG;
  rtlAnschlaegeAufAb                    : R_TRIG;

  // REAL
  rlScheibenHoehe       : REAL;
  rlAbstandZurNulllinie : REAL;

END_VAR

VAR_INPUT
	
  // BAUSTEINE
  Anschlag            : ZylinderPneumatik_Anschlag_FB;
  Messachse           : Messachse_FB;
  Glastransport       : Anlegetisch_Glastransport_FB;
  Hubrahmen           : ZylinderPneumatik_Riemen_FB;

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
 
  outbKipparmeAuf                          AT %Q* : BOOL;
  outbKipparmeAb                           AT %Q* : BOOL;
  outbKipparmeAnschlaegeAuf                AT %Q* : BOOL;
  outbKipparmeAnschlaegeAb                 AT %Q* : BOOL;
  

  // HARDWARE AUSGAENGE
  out_bAmpelSignalRot                      AT %Q* : BOOL; // Rote Ampel     
  out_bAmpelSignalGruenScheibeAnlegen      AT %Q* : BOOL; // Gruene Ampel

  out_bSignalTasterScheibeQuittieren       AT %Q* : BOOL; // Gelber Leuchdrucktaster | Fehlmessung quittiern
  out_bSignalTasterScheibeAnlegen          AT %Q* : BOOL; // Weißer Leuchdrucktaster | Scheibe anlegen
  
  

END_VAR
VAR CONSTANT


  // TIME
  ZEIT_GEBLASE_FREIGABE_AUSSCHALTEN             : TIME := T#4000MS;  (* Zeit ab wann das Geblaese ueber den Taster ausgeschaltet werden kann, nach dem der Ausgang <<Geblaese ein>> gesetzt wurde *)
  ZEITLICHE_VERZOEGERUNG_TASTER_GLASBRUCH       : TIME := T#200ms;
  ZEITLICHE_VERZOEGERUNG_TASTER_GLASABGENOMMEN  : TIME := T#200ms;
  ZEITLICHE_SPERRUNG_TASTER_GLASBRUCH           : TIME := T#2s;

END_VAR

(***************************************************************************************************)
(* MASTER AUFRUFEN *)
(***************************************************************************************************)
IF blErsterZyklus THEN
  // Default aus der Stationsoption, ueber den Taster Anschlaege umschaltbar (siehe Aktion Taster)
  blAnschlagAutomatischFahren := BasisStationsParameter.stMKs.stStationsOptionen.stAnlegetisch.bAnschlagAutomatischAusfahren;
END_IF

SUPER^(BasisStationsParameter := BasisStationsParameter);

(***************************************************************************************************)
(* DEAKTIVIEREN *)
(***************************************************************************************************)
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  HandfunktionenStatus();
  RETURN;
END_IF

(***************************************************************************************************)
(* IO ZUWEISUNG *)
(***************************************************************************************************)

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

(***************************************************************************************************)
(* DEAKTIVIERUNG *)
(***************************************************************************************************) 
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
    wSps2MmiMessungStationNummer    := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
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
  BasisStationsParameter.wFehlerNummer  := 0;

  HandfunktionenStatus();
  RETURN;

END_IF

(***************************************************************************************************)
(* AKTIONEN *)
(***************************************************************************************************)

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
Anlegen();
Eintransport();
Glashoehenmessung();
Glaslaengenmessung();
Austransport();

// Gesonderte Funktionalitaet 
Steuerung_Kippen();

IF BasisStationsParameter.stMKs.stStationsAufbau.bKipparme THEN
  Kipparme();
END_IF
END_FUNCTION_BLOCK