(* METADATA
{
	"v3Meta": {
		"objectGuid": "ef64e827-5941-4f03-afb0-0182424735b8"
	}
}
*)
ACTION Signalverarbeitung
(***************************************************************************************************)
(* SIGNALVERARBEITUNG *)
(***************************************************************************************************)
(* Hinweis:
   - Hegla Schnittstellenbeschreibung V4.0: Sender = SortJet, Empfaenger = Fremdanlage
*)

// Geschwindigkeit des Empfaengers [mm/s] (Big-Endian)
IF ( BasisStationsParameter.stMKs.stFremdanlage.bWerteSwappen ) THEN
  dwlGeschwindigkeit := SWAP_DWORD( dwpWert := in_dwEmpfaengerGeschwindigkeit );
ELSE
  dwlGeschwindigkeit := in_dwEmpfaengerGeschwindigkeit;
END_IF

IF in_bEmpfaengerBereitZumEintransport THEN
  rpGeschwindigkeit  := DWORD_TO_REAL( dwlGeschwindigkeit );
ELSIF ( in_bTasterGlasbruch AND in_bTasterSpezial )THEN
  rpGeschwindigkeit  := 100;
ELSE
  rpGeschwindigkeit  := 0;
END_IF

// Setzen der Signale fuer die Fremdanlage [Hardware- Ausgaenge]
blSenderGlasBereit := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bBereitZumAustransport;

// Der Auslaufsensor der Vorgaengerstation übergeben
out_bSensorAuslauf := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bAuslaufsensor;

// Optionale Signale: SortJet sendet immer mit Lade-ID
out_bSenderManuelleBeladung := FALSE;

// Optionale Signale: Belegung der Vorgaengerstation
stlVorgaenger REF= getBasis( BasisStationsParameter.stMKs.stSchnittstellendaten.wVorgaengerStation );

IF __ISVALIDREF( stlVorgaenger ) THEN
  out_bSenderStationBeladen := stlVorgaenger.bStationBelegt[cWAND_1];
  out_bSenderStationFrei    := NOT stlVorgaenger.bStationBelegt[cWAND_1];
ELSE
  out_bSenderStationBeladen := FALSE;
  out_bSenderStationFrei    := FALSE;
END_IF

// Optionale Signale: Scheibe des laufenden Eintransports in die Fremdanlage ist ein Modell
IF IsBetweenWORD( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cERSTE_FREMDANLAGE_AUSLAUF, cLETZTE_FREMDANLAGE_AUSLAUF ) THEN
  out_bSenderForm := ( Job_Fremdanlage.AuftragsdatenFremdanlage[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].wAuftrag = eStation_Eintransport )
                 AND Job_Fremdanlage.AuftragsdatenFremdanlage[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bModell;
ELSE
  out_bSenderForm := FALSE;
END_IF

(* Hinweis:
   - Ausgangswort zusammenstellen (Wort 50)
   - Evtl. Swappen
*)
wlOutSignale.0 := out_bSenderAuftragdatenVorhanden; // AV
wlOutSignale.1 := out_bSenderAuftragdatenPlausibel; // AP
wlOutSignale.2 := out_bSenderManuelleBeladung;      // HB
wlOutSignale.3 := blSenderBereit;                   // SB Sender betriebsbereit
wlOutSignale.4 := blSenderGlasBereit;               // GB
wlOutSignale.5 := 0;
wlOutSignale.6 := out_bSensorAuslauf;               // SA
wlOutSignale.7 := out_bSenderStationFrei;           // SF
wlOutSignale.8 := out_bSenderStationBeladen;        // SB Station beladen
wlOutSignale.9 := out_bSenderForm;                  // FG

IF ( BasisStationsParameter.stMKs.stFremdanlage.bSignaleSwappen ) THEN
  wlInSignale        := SWAP_WORD( wpWert := in_wEmpfaengerSignale) ;
  out_wSenderSignale := SWAP_WORD( wpWert := wlOutSignale) ;
ELSE
  wlInSignale        := in_wEmpfaengerSignale;
  out_wSenderSignale := wlOutSignale;
END_IF

// Eingangswort auswerten (Wort 49)
in_bEmpfaengerAuftragsdatenErhalten       := wlInSignale.0; // AG
in_bEmpfaengerBereitZumEintransport       := wlInSignale.1; // GA
in_bEmpfaengerSensorEinlauf               := wlInSignale.2; // SE
in_bEmpfaengerNothalt                     := wlInSignale.3; // NA
in_bEmpfaengerAnforderungDurchgangOeffnen := wlInSignale.4; // ADO
in_bEmpfaengerQuittungDurchgangOeffnen    := wlInSignale.5; // ADQ
in_bEmpfaengerStationFrei                 := wlInSignale.6; // SF
in_bEmpfaengerStationBeladen              := wlInSignale.7; // SB
in_bEmpfaengerUebernahmeposition          := wlInSignale.8; // UP

blBereitZumEintransport := in_bEmpfaengerBereitZumEintransport OR ( in_bTasterGlasbruch AND in_bTasterSpezial );
END_ACTION