(* METADATA
{
	"v3Meta": {
		"objectGuid": "a8175c8a-0e5e-42c5-a90c-c5e1a843dc34"
	}
}
*)
FUNCTION_BLOCK Shuttle_FB_V01_00_00
VAR_IN_OUT

  // STRUKT
  BasisStationsParameter : StationBasisParameter_ST;

END_VAR
VAR_INPUT

  // BOOLEAN
  bpShuttleAnhalten                      : BOOL; // HINWEIS: Nehmen der Verfahrfreigabe wenn bei der Folge- bzw. Nachfolgestation der Einlauf- / Auslauf- Sensor belegt wurde
  bpStarteFaecherwagensuche              : BOOL; // Der Fächerwagen kann mittels Sensor gesucht werden um die Fachpositionen zu bestimmen
    
  // WORD
  rpMinPosSwEsEingrenzung                : REAL;
  rpMaxPosSwEsEingrenzung                : REAL;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFaecherwagenGefunden                 : BOOL;

  // REAL
  rpAktuelleFaecherwagenPosition         : REAL;

  // DWORD
  dwpHandfunktionenReturn                : DWORD; // Aktive Handfunktionen, gleiche Bitbelegung wie dwlHandfunktionen

END_VAR
VAR

  // BOOL
  blErsterZyklus                         : BOOL := TRUE;// Initialisierungsphase
  blGeblaeseAktiv                        : BOOL;
  blBetriebsartHand                      : BOOL;
  blBetriebsartReset                     : BOOL;
  blBetriebartCheck                      : BOOL;
  blBetriebsartAutomatik                 : BOOL;
  blBetriebsartReferenz                  : BOOL;
  blZielPositionErreicht                 : BOOL; // Ueberpruefung ob die Zielposition aus dem Auftrag mit der aktuellen Position uebereinstimmt [Abweichung + - 1mm]
  blVorAbAuftragAktiv                    : ARRAY [cWAND_1..cANZAHL_WAENDE] OF BOOL; // STATUS: Merker ob die Komponenten Ansteuerung aktiv ist [Angesteuert mit dem Starten der Querfahrt](Autark gesteuert)
  blUpdateTimer                          : BOOL;
  blNachSystemcheckMerker                : BOOL; // Merkt sich, wenn der Systemcheck erfolgreich durchgeführt wurde, damit die Gebläse nicht nach dem Systemcheck ausgehen
  ablVortransportAktiv                   : ARRAY [cWAND_1..cANZAHL_WAENDE] OF BOOL; // STATUS: Merker ob der Vortransport (Autark gesteuert) aktiv ist -> Wichtig für den Austransport zum sicherstellen das erst dann Transportiert werden kann
  blDatenlichtschrankeUnterbrochenMelden : BOOL;
  blFehlerAusAutomatikBetrieb            : BOOL;
  blShuttleErreichbar                    : BOOL;
  blMerkerAuftragAktiv                   : BOOL;
  blMerkerEinOderAustransportAktiv       : BOOL;

  // WORD
  wlBetriebsart              : WORD;
  wlWatchIONachrichtenNummer : WORD;
  wlIndex                    : WORD;

  // DWORD
  dwlHandfunktionen                : DWORD;  // Handfunktionen: 0..31 Bit
  dwlHandfunktionenZuletztGesendet : DWORD;  // Rueckmeldung der Handfunktionen zum MMI

  // REAL
  rlLetztePosition  : REAL;

  // TIMER
  tonlMaxWarteAufResetErfolgreich       : TON; 
  tonlUpdateTimer                       : TON; // Verfahrlogik 
  tonWaitTimerAnsteuerungResourcen      : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TON;
  tonWaitTimerAnsteuerungResourcenDone  : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TON;

  toflGeblaeseHandfahren                : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TOF;
  atoflSensorEinlauf                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TOF;
  atoflSensorAuslauf                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TOF;
  atoflSensorAUslaufStopp               : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TOF;
  atoflSensorEinlaufStopp               : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TOF;

  // TRIGGER
  rtlAutomatikActiv                     : R_TRIG;
  rtlGlastransportVerfahrfreigabe       : ARRAY [cWAND_1..cANZAHL_WAENDE] OF R_TRIG;
  rtlDatenlichtschrankeUnterbrochen     : R_TRIG;
  rtlFehlerMeldungGenerierenHandbetrieb : R_TRIG;
  rtlFehlerAusgeloestImAutomatikbetrieb : R_TRIG;
  artlVerfahrabbruchSensorik            : ARRAY [cWAND_1..cANZAHL_WAENDE] OF R_TRIG;
  artlWandverstellungPositionieren      : ARRAY [cWAND_1..cANZAHL_WAENDE] OF R_TRIG;
  rtlRackPositionGefunden               : R_TRIG;
  ftlBausteinDeaktivierung              : F_TRIG;

  // STEPS
  steplCheck                       : STEPS_TE;
  steplResetAntrieb                : STEPS_TE;
  steplReferenz                    : Steps_TE;
  steplVorabpositionierung         : STEPS_TE;
  steplFaecherwagensuche           : STEPS_TE;

  // BAUSTEINE
  Querfahrt                       : Querfahrt_Shuttle_FB_V01_00_00; 
  Zentralschmierung               : Zentralschmierung_DLS_4xxi_FB_V01_00_00;
  Glastransport                   : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Glastransport_FB_V01_00_00;
  Geblaese                        : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Geblaese_Schuetz_FB_V01_00_00;
  Wandverstellung                 : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Dickenverstellung_FB_V01_00_00;
  Kippen                          : Shuttle_Kippen_V01_00_00;

  Eintransport                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Eintransport_FB_V01_00_00;
  Austransport                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Austransport_FB_V01_00_00;
  Durchtransport                  : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Durchtransport_FB_V01_00_00;
  AnsteuerungRessourcen           : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Ansteuerung_Ressourcen_FB_V01_00_00;
  Greifer                         : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Greifer_FB_V01_00_00; // Ausbaustufe stStationsAufbau.bGreifer

END_VAR
VAR
  // Alle Sensoren
  blAlleEinlaufStoppSensoren : BOOL; // wirksame Einlauf-Stopp-Sensoren (ohne MK: Einlaufsensor)
  blAlleAuslaufSensoren      : BOOL;
  blAlleEinlaufVorabSensoren : BOOL;
  blAlleAuslaufVorabSensoren : BOOL;
  blAlleAuslaufStoppSensoren : BOOL;
  ablSensorEinlaufStopp      : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; // wirksamer Einlauf-Stopp-Sensor (ohne MK: Einlaufsensor)
  ablSensorAuslaufStopp      : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; // wirksamer Auslauf-Stopp-Sensor (ohne MK: Auslaufsensor)
  blAlleVerfahrfreigaben     : BOOL;
  blAlleGreiferSicher        : BOOL; // Alle Greifer in sicherer Position mit eingefahrenen Glasrueckhaltern (oder nicht vorhanden)
  ablQuittScheibe            : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; // Scheibenquittierung Glastransport bzw. Greifer
  blDone                     : BOOL;
  blFehlerAktiv              : BOOL;

  // HARDWARE EINGAENGE
  in_bSensorEinlauf                                   : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; // Shuttle Sensoren von links nach rechts Sensor 1
  in_bSensorAuslauf                                   : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; // Shuttle Sensoren von links nach rechts Sensor 4
  in_bSensorEinlaufVorab                              : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; // Shuttle Sensoren von links nach rechts Sensor 2
  in_bSensorAuslaufVorab                              : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; // Shuttle Sensoren von links nach rechts Sensor 3
  in_bSensorEinlaufStopp                              : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; // Shuttle Sensoren von links nach rechts Sensor 0 (nur mit MK bSensorEinlaufStopp)
  in_bSensorAuslaufStopp                              : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; // Shuttle Sensoren von links nach rechts Sensor 5 (nur mit MK bSensorAuslaufStopp)
  in_bDatenlichtschrankeShuttlebahnOK          AT %I* : BOOL; // Bauteil an der Shuttlebahn => Sender / Empfaenger
  in_bDatenlichtschrankeShuttleOK              AT %I* : BOOL; // Bauteil auf dem Shuttle => Sender / Empfaenger
  in_bNetzteil_24V_OK                          AT %I* : BOOL;
  in_bKlimageraet_OK                                  : BOOL;
  in_bSicherungen24V_OK                               : BOOL;
  in_bDruckluft_OK                             AT %I* : BOOL;
  in_bSicherungKompressor_OK                   AT %I* : BOOL;
  in_bLSQuerfahrtBremseOK                      AT %I* : BOOL;

  in_bSicherungen230V_OK                       AT %I* : BOOL;
  in_iAnalogwertChannel1                              : INT; // Hinweis: Eingaenge des Analogmoduls u.a fuer die automatische Fachaufnahme
  in_iAnalogwertChannel2                              : INT; // Hinweis: Eingaenge des Analogmoduls u.a fuer die automatische Fachaufnahme
  in_bWandverstellungsAntriebsSicherungOK      AT %I* : BOOL;
  in_bWandverstellungsBremsSicherungOK         AT %I* : BOOL;
  in_bFaecherwagenSuchSensor                          : BOOL; // Shuttle Sensor zum Suchen der Fächerwagen um die Fachpositionen zu bestimmen

  aHand : ARRAY[0..31] OF BOOL;
  i     : INT;

END_VAR
VAR CONSTANT

  // TIME
  ZEIT_SENSOR_ENTPRELLEN         : TIME := T#50ms;

END_VAR
(* Anmerkung:
   - Shuttle Koordinationsbaustein regelt das komplette Shuttle
*)
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: INITIALISIERUNG
//-------------------------------------------------------------------------------------------------

IF ( blErsterZyklus ) THEN
  blErsterZyklus:=FALSE;

  (* Wichtig:
     - Initialisierung
  *)
  A_Baustein_Initialisierung();

END_IF

FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  in_bSensorEinlauf[wlIndex] := Glastransport[wlIndex].Antrieb.udipEingaengeUmrichter.cXG31_1_I_1;
  in_bSensorAuslauf[wlIndex] := Glastransport[wlIndex].Antrieb.udipEingaengeUmrichter.cXG31_2_I_2;

  ablSensorEinlaufStopp[wlIndex] := SEL( BasisStationsParameter.stMKs.stStationsAufbau.bSensorEinlaufStopp, in_bSensorEinlauf[wlIndex], in_bSensorEinlaufStopp[wlIndex] );
  ablSensorAuslaufStopp[wlIndex] := SEL( BasisStationsParameter.stMKs.stStationsAufbau.bSensorAuslaufStopp, in_bSensorAuslauf[wlIndex], in_bSensorAuslaufStopp[wlIndex] );
END_FOR

blAlleEinlaufStoppSensoren := FALSE;
blAlleAuslaufSensoren      := FALSE;
blAlleEinlaufVorabSensoren := FALSE;
blAlleAuslaufVorabSensoren := FALSE;
blAlleAuslaufStoppSensoren := FALSE;
blAlleVerfahrfreigaben     := TRUE;
blAlleGreiferSicher        := TRUE;

FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blAlleGreiferSicher        := blAlleGreiferSicher
                                AND (    ( Greifer[wlIndex].bpSicherePosition AND Greifer[wlIndex].bpGlasRueckhalterEingefahren )
                                      OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex] );
  blAlleEinlaufStoppSensoren := blAlleEinlaufStoppSensoren OR ablSensorEinlaufStopp[wlIndex];
  blAlleAuslaufSensoren      := blAlleAuslaufSensoren OR in_bSensorAuslauf[wlIndex];
  blAlleEinlaufVorabSensoren := blAlleEinlaufVorabSensoren OR in_bSensorEinlaufVorab[wlIndex];
  blAlleAuslaufVorabSensoren := blAlleAuslaufVorabSensoren OR in_bSensorAuslaufVorab[wlIndex];
  blAlleAuslaufStoppSensoren := blAlleAuslaufStoppSensoren OR ablSensorAuslaufStopp[wlIndex];
  blAlleVerfahrfreigaben     := blAlleVerfahrfreigaben AND Glastransport[wlIndex].bpVerfahrFreigabe;
END_FOR

//-------------------------------------------------------------------------------------------------
// DEAKTIVIERUNG
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Werte wieder passend abloeschen, wenn der Baustein wieder aktiviert wird
*)
ftlBausteinDeaktivierung( CLK := BasisStationsParameter.stMKs.bDeaktivieren );

IF ( ftlBausteinDeaktivierung.Q ) THEN

  SendShuttlePosition();

  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
    BasisStationsParameter.bEintransportAbgeschlossen[wlIndex] := FALSE;
    BasisStationsParameter.bAustransportAbgeschlossen[wlIndex] := FALSE;
  END_FOR

  BasisStationsParameter.bIstReferenziert       := FALSE;
  BasisStationsParameter.bCheckAbgeschlossen    := FALSE;
  BasisStationsParameter.bReferenzAbgeschlossen := FALSE;

END_IF

(* Hinweis:
   - Deaktivierung des Bausteins
     => Der Baustein wird zum Ende der RETURN-Anweisung verlassen
*)
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN

  IF ( apgShuttleVerfahrparameter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].eParkposition = PARKPOSITION_MAX ) THEN
    BasisStationsParameter.rAktuellePositionQuerfahrt := apgShuttleVerfahrparameter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rParkpositionMaximum;
  ELSE
    BasisStationsParameter.rAktuellePositionQuerfahrt := apgShuttleVerfahrparameter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].rParkpositionMinimum;
  END_IF

  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
    BasisStationsParameter.bEintransportAbgeschlossen[wlIndex] := TRUE;
    BasisStationsParameter.bAustransportAbgeschlossen[wlIndex] := TRUE;
    
    IF ( BasisStationsParameter.bCheck ) THEN
      
      IF BasisStationsParameter.stMKs.stStationsAufbau.bGlastransport[wlIndex] THEN
        rSps2MmiMessungScheibenlaenge   := 0;
        wSps2MmiMessungStationNummer    := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        wSps2MmiMessungSlotNummer       := wlIndex;
        iSps2MmiMessungScheibenanzahl   := 0;
        
        MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );
      END_IF
    END_IF    
    
  END_FOR

  BasisStationsParameter.bIstReferenziert       := TRUE;
  BasisStationsParameter.bCheckAbgeschlossen    := TRUE;
  BasisStationsParameter.bReferenzAbgeschlossen := TRUE;
  BasisStationsParameter.bReset                 := FALSE;

  BasisStationsParameter.bFehler       := FALSE;
  BasisStationsParameter.wFehlerNummer := 0;

  HandfunktionenStatus();
  RETURN;

END_IF

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
Betriebsart();

SystemCheck();

(* Hinweis:
   - Automatik-Aktionen
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Eintransport[wlIndex]( BasisStationsParameter := BasisStationsParameter, 
                         wWand := wlIndex,
                         bpGeblaeseAktiv := Geblaese[wlIndex].bpDone,
                         bpAutomatikAktiv := BasisStationsParameter.bAutomatik,
                         bpVorAbAuftragAktiv := blVorAbAuftragAktiv[wlIndex],
                         bpZielPositionErreicht := blZielPositionErreicht,
                         Glastransport := Glastransport[wlIndex],
                         Kippen := Kippen,
                         Wandverstellung := Wandverstellung[wlIndex],
                         Geblaese := Geblaese[wlIndex],
                         bpGreiferAktiv := BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex],
                         Greifer := Greifer[wlIndex]
                       );
  Austransport[wlIndex]( BasisStationsParameter := BasisStationsParameter, 
                         wWand := wlIndex,
                         bpGeblaeseAktiv := Geblaese[wlIndex].bpDone,
                         bpAutomatikAktiv := BasisStationsParameter.bAutomatik,
                         bpVorAbAuftragAktiv := blVorAbAuftragAktiv[wlIndex],
                         bpZielPositionErreicht := blZielPositionErreicht,
                         Glastransport := Glastransport[wlIndex],
                         Kippen := Kippen,
                         Wandverstellung := Wandverstellung[wlIndex],
                         Geblaese := Geblaese[wlIndex],
                         bpGreiferAktiv := BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex],
                         Greifer := Greifer[wlIndex]
                       );
                         
  Durchtransport[wlIndex]( BasisStationsParameter := BasisStationsParameter, 
                           wWand := wlIndex,
                           bpGeblaeseAktiv := Geblaese[wlIndex].bpDone,
                           bpAutomatikAktiv := BasisStationsParameter.bAutomatik,
                           bpVorAbAuftragAktiv := blVorAbAuftragAktiv[wlIndex],
                           bpZielPositionErreicht := blZielPositionErreicht,
                           Glastransport := Glastransport[wlIndex],
                           Kippen := Kippen,
                           Wandverstellung := Wandverstellung[wlIndex],
                           Geblaese := Geblaese[wlIndex]
                         );
  AnsteuerungRessourcen[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                                  wWand := wlIndex,
                                  bpGeblaeseAktiv := Geblaese[wlIndex].bpDone,
                                  bpAutomatikAktiv := BasisStationsParameter.bAutomatik,
                                  bpVorAbAuftragAktiv := blVorAbAuftragAktiv[wlIndex],
                                  bpZielPositionErreicht := blZielPositionErreicht,
                                  Glastransport := Glastransport[wlIndex],
                                  Kippen := Kippen,
                                  Wandverstellung := Wandverstellung[wlIndex],
                                  Geblaese := Geblaese[wlIndex],
                                  bpGreiferAktiv := BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex],
                                  Greifer := Greifer[wlIndex]
                                );
END_FOR

Vorabpositionierung();

SensorenFreifahren();
FaecherwagenSuche();

(* Hinweis:
   - Basis-Aktionen
*)
Reset();
Referenz();
Meldungen();
Handfunktionen();

A_Geblaese();
A_Aufrufe();
A_Schnittstelle();
A_Ausgaenge();
END_FUNCTION_BLOCK