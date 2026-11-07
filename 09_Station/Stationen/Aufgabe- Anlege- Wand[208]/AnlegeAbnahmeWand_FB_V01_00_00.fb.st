(* METADATA
{
	"v3Meta": {
		"objectGuid": "4412b2e8-80e3-4d41-9c3d-84963f94e3c1"
	}
}
*)
FUNCTION_BLOCK AnlegeAbnahmeWand_FB_V01_00_00 EXTENDS Basic_Station_FB_V01_00_00

VAR_INPUT

  // BOOLEAN
  bpFreigabeBereichsScanner : BOOL := TRUE; 

END_VAR

VAR

  // BOOLEAN
  blAktionImFehler           : BOOL; // Eine der wandweisen Aktionen steht im Fehler
  blDrosselklappeAnforderung : BOOL; // Mindestens ein Transport verlangt die offene Drosselklappe
  blAnlegenErzwingen         : BOOL; // Anlegen wurde erzwungen (von den Messungen angefordert)
  bpFreigabeScheibe          : BOOL; // MMI: Scheibe wurde erfolgreich vermessen (Modellscheibe, ohne Funktion an der Wand)
  bpKeineFreigabeScheibe     : BOOL; // MMI: Scheibe wurde nicht erfolgreich vermessen (Modellscheibe, ohne Funktion an der Wand)
  blBedienerEingriff         : BOOL; // Eine Aktion wartet auf den Bediener (Anlegen, Glaslaengenmessung)

  // REAL
  rlScheibenHoehe            : REAL;
  rlAbstandZurNulllinie      : REAL;
    
  // INT
  ilScheibenZaehler          : INT;

  
  // TRIGGER
  rtlTasterQuittierung                  : R_TRIG;
  rtlFussleisteStart                    : R_TRIG;
  rtlDrosselklappeAnforderung           : R_TRIG;
  rtlAnlegenAbgeschlossen               : R_TRIG;
  rtlGlaslaengenmessungStart            : R_TRIG;
  ftlGlaslaengenmessungAktiv            : F_TRIG;
  ftlGlashoehenmessungAktiv             : F_TRIG;
  ftlAnlegenAktiv                       : F_TRIG;
  rtlGeblaeseLaeuft                     : R_TRIG;
  ftlGeblaeseLaeuft                     : F_TRIG;
  ftlAbnehmenAktiv                      : F_TRIG;
  ftlAnlegenBedienerEingriff            : F_TRIG;
  ftlDrosselklappeAnforderung           : F_TRIG;
  ftlGlastransportCheckMitNachfolger    : F_TRIG;

  // TIMER
  tonlQuittierungGlasAbgenommen         : TON; 
  tonlFreigabeErhalten                  : TON; 
  
  // TIME
  tlZeitBereitAnzulegen                 : TIME;
                                       
  // ENUM 
  epTypeHoehenmessung : ModusHoehenvermessung_EN;

  // BAUSTEINE 
  Glastransport     : AnlegeAbnahmeWand_Glastransport_FB_V01_00_00;
  Messachse         : Messachse_FB_V01_00_00;
  Kippen            : Kippen_FB_V01_00_00;
  Dickenverstellung : ZylinderPneumatik_3Wege_FB_V01_00_00;

  (* Hinweis:
     - Die Wand hat keinen Hub, keine Roellchenleiste, keine Wandverstellung und kein Geblaese ueber
       den Geblaese-Baustein, der Eintransport erwartet die Bausteine aber. Die Instanzen bleiben
       deaktiviert (bpAktivieren wird nie gesetzt)
  *)
  HubUnbenutzt             : Hub_FB_V01_00_00;
  RoellchenleisteUnbenutzt : ZylinderPneumatik_3Wege_FB_V01_00_00;
  WandverstellungUnbenutzt : ZylinderPneumatik_3Wege_FB_V01_00_00;
  Geblaese        : Geblaese_Schuetz_FB_V01_00_00;

  // AKTIONEN (STATION)
  Anlegen           : Basic_Station_Anlegen_FB_V01_00_00;
  Abnehmen          : Basic_Station_Abnehmen_FB_V01_00_00;
  Glaslaengenmessung : Basic_Station_Glaslaengenmessung_FB_V01_00_00;
  Glashoehenmessung  : Basic_Station_Glashoehenmessung_FB_V01_00_00;

  // AKTIONEN (WANDWEISE)
  Eintransport      : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Eintransport_FB_V01_00_00;
  Austransport      : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Austransport_FB_V01_00_00;
  Vortransport      : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Vortransport_FB_V01_00_00;
  Durchtransport    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Durchtransport_FB_V01_00_00;
  Messkopplung      : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Messkopplung_FB_V01_00_00;

END_VAR


VAR
  
  // Taster
  in_bFussTaster                                  : BOOL; // Signal Fusstaster
  in_bTasterGlasAngelegt                   AT %I* : BOOL; // Signal Scheibe ist angelegt gelber Leuchtdrucktaster
  in_bTasterFehlmessungQuittiern           AT %I* : BOOL; // Gelber Leuchtdrucktaster
  in_bKnebelGlastransportZurueck           AT %I* : BOOL; // Knebelschalter: Glastransport zurück
  in_bKnebelGlastransportVor               AT %I* : BOOL; // Knebelschalter: Glastransport vor
  in_bTasterQuittierungGlasAbgenommen      AT %I* : BOOL;
  in_bTasterGeblaeseEin                    AT %I* : BOOL; 
  in_bTasterGlasbruch                      AT %I* : BOOL;
  in_bLichtschrankeQuittiert               AT %I* : BOOL;
  in_bLichtschrankeFehler                  AT %I* : BOOL;
  in_bMotorschutzGeblaese_Ok               AT %I* : BOOL; 

  // HARDWARE AUSGAENGE
  out_bDrosselklappeOeffnen                       : BOOL; // Drosselklappe oeffnen / schliessen
  out_bAmpelSignalRot                             : BOOL; // rote Ampel an der Station
  out_bAmpelSignalGruen                           : BOOL; (* grüne Ampel an der Station *)//evtl mit GruenScheibeAnlegen zusammen führen
  out_bSignalScheibeAufgegeben             AT %Q* : BOOL; // grüner Leuchdrucktaster
  out_bSignalScheibeAbnehmen               AT %Q* : BOOL; // grüner Leuchdrucktaster
  out_bSignalScheibeFehlmessung            AT %Q* : BOOL; // gelber Leuchdrucktaster
  out_bSignalScheibeGlasbruch              AT %Q* : BOOL; // gelber Leuchdrucktaster
  out_bGeblaeseEin                         AT %Q* : BOOL; // Geblaese starten (Schuetz)
  out_bLichtschrankeAusgeloest             AT %Q* : BOOL; // Signal im OP das die Lichtschranke ausgelöst hat und nicht quittiert ist
  
    
END_VAR
//-------------------------------------------------------------------------------------------------
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
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
in_bFussTaster := pgAntriebe[Glastransport.ppAntriebsInformationen.wAchsID].udipEingaengeUmrichter.cXG37_2_IO_2;

Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_IO_3  := out_bAmpelSignalRot;
Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_IO_4  := out_bAmpelSignalGruen;
Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_O_6   := Geblaese.bpDrosselklappeOeffnen; // Anforderung out_bDrosselklappeOeffnen, offen nur bei laufendem Geblaese

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
// Die fehlenden Aktionen werden im Master aufgerufen
A_Aufrufe();
A_Timer();

Referenz();
Reset();
SystemCheck();

(* Hinweis:
   - Automatik-Aktion Eintransport je Wand
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  (* Hinweis:
     - Geblaese aktiv = Freigabe Si-Kreis (verzoegert) liegt an und der Motorschutz ist nicht ausgeloest
     - Ist die Freigabe da und der Motorschutz ausgeloest, melden Ein- und Austransport einen Fehler
     - Die Drosselklappe oeffnet die Aktion Geblaese mit dem Geblaese, der Transport fordert sie zusaetzlich an (siehe unten)
  *)
  Eintransport[wlIndex]( BasisStationsParameter  := BasisStationsParameter,
                         wWand                   := wlIndex,
                         bpAutomatikAktiv        := blBetriebsartAutomatik,
                         bpGeblaeseAktiv         := ( tonlFreigabeErhalten.Q AND in_bMotorschutzGeblaese_Ok ),
                         bpGeblaeseFehler        := ( tonlFreigabeErhalten.Q AND NOT in_bMotorschutzGeblaese_Ok ),
                         bpZielPositionErreicht  := TRUE,
                         Glastransport           := Glastransport,
                         Kippen                  := Kippen,
                         Hub                     := HubUnbenutzt,
                         Roellchenleiste         := RoellchenleisteUnbenutzt,
                         Wandverstellung         := WandverstellungUnbenutzt,
                         Geblaese                := Geblaese,
                         Messachse               := Messachse,
                         Dickenverstellung       := Dickenverstellung );

  Vortransport[wlIndex]( BasisStationsParameter  := BasisStationsParameter,
                         wWand                   := wlIndex,
                         bpAutomatikAktiv        := blBetriebsartAutomatik,
                         bpGeblaeseAktiv         := ( tonlFreigabeErhalten.Q AND in_bMotorschutzGeblaese_Ok ),
                         bpZielPositionErreicht  := TRUE,
                         Glastransport           := Glastransport );

  Durchtransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                           wWand                  := wlIndex,
                           bpAutomatikAktiv       := blBetriebsartAutomatik,
                           bpGeblaeseAktiv        := ( tonlFreigabeErhalten.Q AND in_bMotorschutzGeblaese_Ok ),
                           bpZielPositionErreicht := TRUE,
                           Glastransport          := Glastransport,
                           Hub                    := HubUnbenutzt );

  Messkopplung[wlIndex]( BasisStationsParameter  := BasisStationsParameter,
                         wWand                   := wlIndex,
                         bpAutomatikAktiv        := blBetriebsartAutomatik,
                         bpGeblaeseAktiv         := ( tonlFreigabeErhalten.Q AND in_bMotorschutzGeblaese_Ok ),
                         bpZielPositionErreicht  := TRUE,
                         Glastransport           := Glastransport,
                         Kippen                  := Kippen,
                         Hub                     := HubUnbenutzt,
                         Roellchenleiste         := RoellchenleisteUnbenutzt,
                         Wandverstellung         := WandverstellungUnbenutzt );
END_FOR

Anlegen( BasisStationsParameter := BasisStationsParameter,
         bpAutomatikAktiv       := blBetriebsartAutomatik,
         bpGeblaeseFehler       := NOT in_bMotorschutzGeblaese_Ok,
         bpAnlegenQuittiert     := rtlFussleisteStart.Q,
         Glastransport          := Glastransport,
         Messachse              := Messachse,
         blAnlegenErzwingen     := blAnlegenErzwingen );

Abnehmen( BasisStationsParameter      := BasisStationsParameter,
          bpAutomatikAktiv            := blBetriebsartAutomatik,
          bpGeblaeseFehler            := NOT in_bMotorschutzGeblaese_Ok,
          bpFreigabeErhalten          := tonlFreigabeErhalten.Q,
          bpGlasAbgenommenQuittiert   := ( in_bTasterQuittierungGlasAbgenommen OR in_bFussTaster ),
          Glastransport               := Glastransport,
          Kippen                      := Kippen );

(* Hinweis:
   - Ausgaenge der Aktionen Anlegen und Abnehmen auf die Hardware der Station legen
   - Solange die Aktion laeuft (und einen Zyklus danach) gehoert die Lampe der Aktion, danach den Messungen
*)
rtlAnlegenAbgeschlossen( CLK := BasisStationsParameter.bAnlegenAbgeschlossen );
IF ( rtlAnlegenAbgeschlossen.Q ) THEN
  epTypeHoehenmessung := Anlegen.epTypeHoehenmessung;
END_IF

ftlAnlegenAktiv( CLK := BasisStationsParameter.bAnlegen );
IF ( BasisStationsParameter.bAnlegen OR ftlAnlegenAktiv.Q ) THEN
  out_bAmpelSignalGruen        := Anlegen.bpAnlegenLampe;
  out_bSignalScheibeAufgegeben := Anlegen.bpAnlegenLampe;
END_IF

ftlAbnehmenAktiv( CLK := BasisStationsParameter.bAbnehmen );
IF ( BasisStationsParameter.bAbnehmen OR ftlAbnehmenAktiv.Q ) THEN
  out_bAmpelSignalGruen       := Abnehmen.bpAbnehmenLampe;
  out_bSignalScheibeAbnehmen  := Abnehmen.bpSignalScheibeAbnehmen;
  out_bSignalScheibeGlasbruch := Abnehmen.bpSignalGlasbruch;
END_IF

(* Hinweis:
   - Anlegen ist Automatikbetrieb: Waehrend die Aktion auf den Bediener wartet, faehrt der Knebel die Scheibe vor / zurueck
*)
blBedienerEingriff := (     Anlegen.bpBedienerEingriff
                           OR Glaslaengenmessung.bpBedienerEingriff
                           OR Glashoehenmessung.bpBedienerEingriff );
ftlAnlegenBedienerEingriff( CLK := blBedienerEingriff );
IF ( blBedienerEingriff ) THEN
  Glastransport.bpScheibeZurueckFahren := (     in_bKnebelGlastransportZurueck
                                            AND tonlFreigabeErhalten.Q );
  Glastransport.bpScheibeVorFahren     := (     in_bKnebelGlastransportVor
                                            AND NOT in_bKnebelGlastransportZurueck
                                            AND tonlFreigabeErhalten.Q );
ELSIF ( ftlAnlegenBedienerEingriff.Q ) THEN
  Glastransport.bpScheibeZurueckFahren := FALSE;
  Glastransport.bpScheibeVorFahren     := FALSE;
END_IF

Glashoehenmessung( BasisStationsParameter  := BasisStationsParameter,
                   bpAutomatikAktiv        := blBetriebsartAutomatik,
                   bpTasterQuittierung     := rtlTasterQuittierung.Q,
                   bpKnebelZurueck         := in_bKnebelGlastransportZurueck,
                   epTypeHoehenmessung     := epTypeHoehenmessung,
                   Glastransport           := Glastransport,
                   Messachse               := Messachse,
                   blAnlegenErzwingen      := blAnlegenErzwingen );

rlScheibenHoehe       := Glashoehenmessung.rpScheibenHoehe;
rlAbstandZurNulllinie := Glashoehenmessung.rpAbstandZurNulllinie;

ftlGlashoehenmessungAktiv( CLK := BasisStationsParameter.bGlashoehenmessung );
IF ( BasisStationsParameter.bGlashoehenmessung OR ftlGlashoehenmessungAktiv.Q ) THEN
  out_bAmpelSignalGruen         := Glashoehenmessung.bpAnlegenLampe;
  out_bSignalScheibeAufgegeben  := Glashoehenmessung.bpAnlegenLampe;
  out_bSignalScheibeFehlmessung := Glashoehenmessung.bpSignalFehlmessung;
END_IF
Glaslaengenmessung( BasisStationsParameter  := BasisStationsParameter,
                    bpAutomatikAktiv        := blBetriebsartAutomatik,
                    bpGeblaeseFehler        := NOT in_bMotorschutzGeblaese_Ok,
                    bpTasterQuittierung     := rtlTasterQuittierung.Q,
                    bpKnebelZurueck         := in_bKnebelGlastransportZurueck,
                    Glastransport           := Glastransport,
                    blAnlegenErzwingen      := blAnlegenErzwingen,
                    bpFreigabeScheibe       := bpFreigabeScheibe,
                    bpKeineFreigabeScheibe  := bpKeineFreigabeScheibe );

(* Hinweis:
   - Beim Start der Messung ist die Drosselklappe zu, danach gehoert die Lampe der Messung
*)
rtlGlaslaengenmessungStart( CLK := BasisStationsParameter.bGlaslaengenmessung );
IF ( rtlGlaslaengenmessungStart.Q ) THEN
  out_bDrosselklappeOeffnen := FALSE;
END_IF

ftlGlaslaengenmessungAktiv( CLK := BasisStationsParameter.bGlaslaengenmessung );
IF ( BasisStationsParameter.bGlaslaengenmessung OR ftlGlaslaengenmessungAktiv.Q ) THEN
  out_bAmpelSignalGruen         := Glaslaengenmessung.bpAnlegenLampe;
  out_bSignalScheibeAufgegeben  := Glaslaengenmessung.bpAnlegenLampe;
  out_bSignalScheibeFehlmessung := Glaslaengenmessung.bpSignalFehlmessung;
END_IF

(* Hinweis:
   - Automatik-Aktion Austransport je Wand
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Austransport[wlIndex]( BasisStationsParameter  := BasisStationsParameter,
                         wWand                   := wlIndex,
                         bpAutomatikAktiv        := blBetriebsartAutomatik,
                         bpGeblaeseAktiv         := ( tonlFreigabeErhalten.Q AND in_bMotorschutzGeblaese_Ok ),
                         bpGeblaeseFehler        := ( tonlFreigabeErhalten.Q AND NOT in_bMotorschutzGeblaese_Ok ),
                         bpZielPositionErreicht  := TRUE,
                         Glastransport           := Glastransport,
                         Kippen                  := Kippen,
                         Hub                     := HubUnbenutzt,
                         Geblaese                := Geblaese,
                         Messachse               := Messachse );
END_FOR

(* Hinweis:
   - Drosselklappe: oeffnet, wenn ein Transport sie verlangt, und schliesst nach jedem Transport wieder
   - Das Geblaese selbst oeffnet sie ebenfalls (Aktion Geblaese)
*)
blDrosselklappeAnforderung := FALSE;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blDrosselklappeAnforderung := (     blDrosselklappeAnforderung
                                   OR Eintransport[wlIndex].bpDrosselklappeOeffnen
                                   OR Austransport[wlIndex].bpDrosselklappeOeffnen );
END_FOR
blDrosselklappeAnforderung := (     blDrosselklappeAnforderung
                                 OR Anlegen.bpDrosselklappeOeffnen
                                 OR Abnehmen.bpDrosselklappeOeffnen );

rtlDrosselklappeAnforderung( CLK := blDrosselklappeAnforderung );
ftlDrosselklappeAnforderung( CLK := blDrosselklappeAnforderung );

IF ( rtlDrosselklappeAnforderung.Q ) THEN
  out_bDrosselklappeOeffnen := TRUE;
ELSIF ( ftlDrosselklappeAnforderung.Q ) THEN
  out_bDrosselklappeOeffnen := FALSE;
END_IF

Handfunktionen();
A_Geblaese();
END_FUNCTION_BLOCK