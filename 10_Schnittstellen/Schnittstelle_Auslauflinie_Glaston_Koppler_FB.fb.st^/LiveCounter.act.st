(* METADATA
{
	"v3Meta": {
		"objectGuid": "3cd2f2d8-64d5-45ea-9c2e-511669c13ead"
	}
}
*)
ACTION LiveCounter
(***************************************************************************************************)
(* AKTION: PRUEFEN DER SCHNITTSTELLE [LIVECOUNTER] *)
(***************************************************************************************************)

(* Hinweis:
   - Werte- Vergleichen
     => Sind die Werte gleich wirde der Zaehler ums eins erhoeht
*)
IF ( BasisStationsParameter.stMKs.stFremdanlage.bCounterSwappen ) THEN
  wlLiveCounterFremdanlage := SWAP_WORD( wpWert := in_wEmpfaengerLiveCounter) ;
  out_wSenderLiveCounter   := SWAP_WORD( wpWert := wlLiveCounterSortJet) ;
ELSE
  wlLiveCounterFremdanlage := in_wEmpfaengerLiveCounter;
  out_wSenderLiveCounter   := wlLiveCounterSortJet;
END_IF


IF ( wlLiveCounterFremdanlage = wlLiveCounterSortJet ) THEN

   wlVerbindungsVersuche := 0;
   blLiveCounterGueltig := TRUE;

   blFehlermeldungGenerierenKommunikation := FALSE;

ELSE
  blLiveCounterGueltig := FALSE;

END_IF


(* Hinweis:
   - Zeitliche Verzoegerung des Live Counters
*)
tonlZeitLiveCounterInkrementieren( IN := blLiveCounterGueltig,
                                   PT := cZEIT_LIVECOUNTER_INKREMENTIEREN );

IF ( tonlZeitLiveCounterInkrementieren.Q ) THEN
  (* Hinweis:
     - Wertebreich von 0 - 65535
  *)
  wlLiveCounterSortJet    := INCW(wlLiveCounterSortJet, cWERTEBREICH_WORD);
END_IF


(* Hinweis:
   - Kommunikationsproblem feststellen
     => Weitere 5 Verbindungsversuche ausfuehren (Counter erhoehen) bis ein Fehler generiert wird
     => Zeitliche- Ueberwachung zuruecksetzen
     => Verbindungsversuche zaehlen bis zum Fehler
     => LiveCounter weiter erhoehen
*)
IF ( tonlZeitLiveCounterNichtAequivalent.Q ) THEN

  (* Hinweis:
     - Verbindungsversuche zaehlen
  *)
  IF ( NOT ( wlVerbindungsVersuche >= cVERBINDUNGSVERSUCHE_BIS_FEHLER ) ) THEN
    wlVerbindungsVersuche  := wlVerbindungsVersuche + 1;
  END_IF

  (* Hinweis:
     - Erzeugen einer Fehlermeldung
  *)
  IF ( wlVerbindungsVersuche = cVERBINDUNGSVERSUCHE_BIS_FEHLER ) THEN
    blFehlermeldungGenerierenKommunikation := TRUE;
  END_IF

  (* Hinweis:
     - Wertebreich von 0 - 65535
  *)
  wlLiveCounterSortJet   := INCW(wlLiveCounterSortJet,cWERTEBREICH_WORD);

  (* Hinweis:
     - Ueberwachung zuruecksetzen 
       => Sicherstellen das der naechste Verbindungsversuch erst nach 1 Sekunde wieder erfolgt 
  *)
  tonlZeitLiveCounterNichtAequivalent( IN := FALSE );

END_IF
END_ACTION