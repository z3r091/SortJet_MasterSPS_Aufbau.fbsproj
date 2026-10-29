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
// Geschwindigkeit
CASE BasisStationsParameter.stMKs.stStationsNummern.NummerIntern OF

  401:
    IF in_bEmpfaengerBereitZumEintransport THEN
      rpGeschwindigkeit  := in_rEmpfaengerGeschwindigkeit;
    ELSIF ( in_bTasterGlasbruch AND in_bTasterSpezial )THEN
      rpGeschwindigkeit  := 100;
    ELSE
      rpGeschwindigkeit  := 0;
    END_IF

END_CASE

// Setzen der Signale fuer die Fremdanlage [Hardware- Ausgaenge]
blSenderGlasBereit := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bBereitZumAustransport;

// Der Auslaufsensor der Vorgaengerstation übergeben
out_bSensorAuslauf := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bAuslaufsensor;

(* Hinweis:
   - Ausgangswort zusammenstellen 
   - Evtl. Swappen
*)
wlOutSignale.0 := out_bSenderAuftragdatenVorhanden;
wlOutSignale.1 := out_bSenderAuftragdatenPlausibel;
wlOutSignale.2 := 0;
wlOutSignale.3 := blSenderBereit; 
wlOutSignale.4 := blSenderGlasBereit;
wlOutSignale.5 := 0;
wlOutSignale.6 := out_bSensorAuslauf;
wlOutSignale.7 := 0;
wlOutSignale.8 := 0;

IF ( BasisStationsParameter.stMKs.stFremdanlage.bSignaleSwappen ) THEN
  wlInSignale        := SWAP_WORD( wpWert := in_wEmpfaengerSignale) ;
  out_wSenderSignale := SWAP_WORD( wpWert := wlOutSignale) ;
ELSE
  wlInSignale        := in_wEmpfaengerSignale;
  out_wSenderSignale := wlOutSignale;
END_IF

in_bEmpfaengerAuftragsdatenErhalten  := wlInSignale.0;
in_bEmpfaengerBereitZumEintransport  := wlInSignale.1;
in_bEmpfaengerSensorEinlauf          := wlInSignale.2;
in_bEmpfaengerStationFrei            := wlInSignale.6;
in_bEmpfaengerStationBeladen         := wlInSignale.7;

blBereitZumEintransport := in_bEmpfaengerBereitZumEintransport OR ( in_bTasterGlasbruch AND in_bTasterSpezial );
END_ACTION