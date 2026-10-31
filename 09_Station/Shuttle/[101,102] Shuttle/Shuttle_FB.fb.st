(* METADATA
{
	"v3Meta": {
		"objectGuid": "a8175c8a-0e5e-42c5-a90c-c5e1a843dc34"
	}
}
*)
FUNCTION_BLOCK Shuttle_FB
VAR_IN_OUT

  (* STRUKT *)
  BasisStationsParameter : StationBasisParameter_ST;

END_VAR
VAR_INPUT

  // BOOLEAN
  bpShuttleAnhalten                      : BOOL; (* HINWEIS: Nehmen der Verfahrfreigabe wenn bei der Folge- bzw. Nachfolgestation der Einlauf- / Auslauf- Sensor belegt wurde *)
  bpStarteFaecherwagensuche              : BOOL; (* Der Fächerwagen kann mittels Sensor gesucht werden um die Fachpositionen zu bestimmen *)
    
  // WORD
  rpMinPosSwEsEingrenzung                : REAL;
  rpMaxPosSwEsEingrenzung                : REAL;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFaecherwagenGefunden                 : BOOL;

  // REAL
  rpAktuelleFaecherwagenPosition         : REAL;

END_VAR
VAR

  (* BOOL *)
  blErsterZyklus                         : BOOL := TRUE;(* Initialisierungsphase *)
  blGeblaeseAktiv                        : BOOL;
  blBetriebsartHand                      : BOOL;
  blBetriebsartReset                     : BOOL;
  blBetriebartCheck                      : BOOL;
  blBetriebsartAutomatik                 : BOOL;
  blBetriebsartReferenz                  : BOOL;
  blZielPositionErreicht                 : BOOL; (* Ueberpruefung ob die Zielposition aus dem Auftrag mit der aktuellen Position uebereinstimmt [Abweichung + - 1mm] *)
  blVorAbAuftragAktiv                    : ARRAY [cWAND_1..cANZAHL_WAENDE] OF BOOL; (* STATUS: Merker ob die Komponenten Ansteuerung aktiv ist [Angesteuert mit dem Starten der Querfahrt](Autark gesteuert) *)
  blUpdateTimer                          : BOOL;
  blNachSystemcheckMerker                : BOOL; (* Merkt sich, wenn der Systemcheck erfolgreich durchgeführt wurde, damit die Gebläse nicht nach dem Systemcheck ausgehen *)
  ablVortransportAktiv                   : ARRAY [cWAND_1..cANZAHL_WAENDE] OF BOOL; (* STATUS: Merker ob der Vortransport (Autark gesteuert) aktiv ist -> Wichtig für den Austransport zum sicherstellen das erst dann Transportiert werden kann *)
  blDatenlichtschrankeUnterbrochenMelden : BOOL;
  blFehlerAusAutomatikBetrieb            : BOOL;
  blShuttleErreichbar                    : BOOL;
  blMerkerAuftragAktiv                   : BOOL;
  blMerkerEinOderAustransportAktiv       : BOOL;

  (* WORD *)
  wlBetriebsart              : WORD;
  wlWatchIONachrichtenNummer : WORD;
  wlIndex                    : WORD;

  (* DWORD *)
  dwlHandfunktionen : DWORD;  (* Handfunktionen: 0..31 Bit *)

  (* REAL *)
  rlLetztePosition  : REAL;

  (* TIMER *)
  toflGeblaeseEnergiesparModus          : TOF; //Timer um das Geblaese bei langen Stillstandszeiten abzuschalten 
  tonlMaxWarteAufResetErfolgreich       : TON; 
  tonlUpdateTimer                       : TON; // Verfahrlogik 
  tonWaitTimerAnsteuerungResourcen      : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TON;
  tonWaitTimerAnsteuerungResourcenDone  : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TON;

  toflGeblaeseHandfahren                : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TOF;
  atoflSensorEinlauf                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TOF;
  atoflSensorAuslauf                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TOF;
  atoflSensorAUslaufStopp               : ARRAY[cWAND_1..cANZAHL_WAENDE] OF TOF;

  (* TRIGGER *)
  rtlAutomatikActiv                     : R_TRIG;
  rtlGlastransportVerfahrfreigabe       : ARRAY [cWAND_1..cANZAHL_WAENDE] OF R_TRIG;
  rtlDatenlichtschrankeUnterbrochen     : R_TRIG;
  rtlFehlerMeldungGenerierenHandbetrieb : R_TRIG;
  rtlFehlerAusgeloestImAutomatikbetrieb : R_TRIG;
  artlVerfahrabbruchSensorik            : ARRAY [cWAND_1..cANZAHL_WAENDE] OF R_TRIG;
  artlWandverstellungPositionieren      : ARRAY [cWAND_1..cANZAHL_WAENDE] OF R_TRIG;
  rtlRackPositionGefunden               : R_TRIG;
  ftlBausteinDeaktivierung              : F_TRIG;

  (* STEPS *)
  steplCheck                       : STEPS_TE;
  steplResetAntrieb                : STEPS_TE;
  steplReferenz                    : Steps_TE;
  steplVorabpositionierung         : STEPS_TE;
  steplFaecherwagensuche           : STEPS_TE;

  // BAUSTEINE
  Querfahrt                       : Querfahrt_Shuttle_FB; 
  Zentralschmierung               : Zentralschmierung_DLS_4xxi_FB;
  Glastransport                   : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Glastransport_FB;
  Geblaese                        : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Geblaese_Schuetz_FB;
  Wandverstellung                 : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Dickenverstellung_FB;
  Kippen                          : Shuttle_Kippen;

  Eintransport                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Eintransport_FB;
  Austransport                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Austransport_FB;
  Durchtransport                  : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Durchtransport_FB;
  AnsteuerungRessourcen           : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Shuttle_Ansteuerung_Ressourcen_FB;

END_VAR
VAR
  // Alle Sensoren
  blAlleEinlaufSensoren      : BOOL;
  blAlleAuslaufSensoren      : BOOL;
  blAlleEinlaufVorabSensoren : BOOL;
  blAlleAuslaufVorabSensoren : BOOL;
  blAlleAuslaufStoppSensoren : BOOL;
  blAlleVerfahrfreigaben     : BOOL;
  blDone                     : BOOL;
  blFehlerAktiv              : BOOL;

  (* HARDWARE EINGAENGE *)
  in_bSensorEinlauf                                   : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; (* Shuttle Sensoren von links nach rechts Sensor 1*)
  in_bSensorAuslauf                                   : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; (* Shuttle Sensoren von links nach rechts Sensor 4*)
  in_bSensorEinlaufVorab                              : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; (* Shuttle Sensoren von links nach rechts Sensor 2*)
  in_bSensorAuslaufVorab                              : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; (* Shuttle Sensoren von links nach rechts Sensor 3*)
  in_bSensorAuslaufStopp                              : ARRAY[cWAND_1..cANZAHL_WAENDE] OF BOOL; (* Shuttle Sensoren von links nach rechts Sensor 5*)
  in_bDatenlichtschrankeShuttlebahnOK          AT %I* : BOOL; (* Bauteil an der Shuttlebahn => Sender / Empfaenger *)
  in_bDatenlichtschrankeShuttleOK 	           AT %I* : BOOL; (* Bauteil auf dem Shuttle => Sender / Empfaenger *)
  in_bNetzteil_24V_OK                          AT %I* : BOOL;
  in_bKlimageraet_OK                                  : BOOL;
  in_bSicherungen24V_OK                               : BOOL;
  in_bDruckluft_OK                             AT %I* : BOOL;
  in_bSicherungKompressor_OK                   AT %I* : BOOL;
  in_bLSQuerfahrtBremseOK                      AT %I* : BOOL;

  in_bSicherungen230V_OK                       AT %I* : BOOL;
  in_iAnalogwertChannel1                              : INT; (* Hinweis: Eingaenge des Analogmoduls u.a fuer die automatische Fachaufnahme *)
  in_iAnalogwertChannel2                              : INT; (* Hinweis: Eingaenge des Analogmoduls u.a fuer die automatische Fachaufnahme *)
  in_bWandverstellungsAntriebsSicherungOK      AT %I* : BOOL;
  in_bWandverstellungsBremsSicherungOK         AT %I* : BOOL;
  in_bFaecherwagenSuchSensor                          : BOOL; (* Shuttle Sensor zum Suchen der Fächerwagen um die Fachpositionen zu bestimmen *)

  aHand : ARRAY[0..31] OF BOOL;
  i     : INT;

END_VAR
VAR CONSTANT

  (* TIME *)
  ZEIT_SENSOR_ENTPRELLEN         : TIME := T#50ms;

END_VAR
(* Anmerkung:
   - Shuttle Koordinationsbaustein regelt das komplette Shuttle
*) 
(***************************************************************************************************)
(* BAUSTEIN: INITIALISIERUNG *)
(***************************************************************************************************)

IF ( blErsterZyklus ) THEN
  blErsterZyklus:=FALSE;

  (* WICHTIG:
     - Initialisierung 
  *)
  A_Baustein_Initialisierung();

END_IF

FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  in_bSensorEinlauf[wlIndex] := Glastransport[wlIndex].Antrieb.udipEingaengeUmrichter.cXG31_1_I_1;
  in_bSensorAuslauf[wlIndex] := Glastransport[wlIndex].Antrieb.udipEingaengeUmrichter.cXG31_2_I_2;
END_FOR

blAlleEinlaufSensoren      := FALSE;
blAlleAuslaufSensoren      := FALSE;
blAlleEinlaufVorabSensoren := FALSE;
blAlleAuslaufVorabSensoren := FALSE;
blAlleAuslaufStoppSensoren := FALSE;
blAlleVerfahrfreigaben     := TRUE;

FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blAlleEinlaufSensoren      := blAlleEinlaufSensoren OR in_bSensorEinlauf[wlIndex];
  blAlleAuslaufSensoren      := blAlleAuslaufSensoren OR in_bSensorAuslauf[wlIndex];
  blAlleEinlaufVorabSensoren := blAlleEinlaufVorabSensoren OR in_bSensorEinlaufVorab[wlIndex];
  blAlleAuslaufVorabSensoren := blAlleAuslaufVorabSensoren OR in_bSensorAuslaufVorab[wlIndex];
  blAlleAuslaufStoppSensoren := blAlleAuslaufStoppSensoren OR in_bSensorAuslaufStopp[wlIndex];
  blAlleVerfahrfreigaben     := blAlleVerfahrfreigaben AND Glastransport[wlIndex].bpVerfahrFreigabe;
END_FOR

(***************************************************************************************************)
(* DEAKTIVIERUNG *)
(***************************************************************************************************)

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
        wSps2MmiMessungStationNummer    := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
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

  RETURN;

END_IF

(***************************************************************************************************)
(* AKTIONEN *)
(***************************************************************************************************)
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
                         Geblaese := Geblaese[wlIndex]
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
	                       Geblaese := Geblaese[wlIndex]
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
								          Geblaese := Geblaese[wlIndex]
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