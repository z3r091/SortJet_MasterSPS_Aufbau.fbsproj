(* METADATA
{
  "v3Meta": {
    "objectGuid": "6c964fae-8570-4be5-95fb-842bfc44c37d"
  }
}
*)
ACTION LiveCounter
(***************************************************************************************************)
(* AKTION: PRUEFEN DER SCHNITTSTELLE [LIVECOUNTER] *)
(***************************************************************************************************)

(* Hinweis:
   - Live Counter an den Glas-Sender zurueck schicken 
*)
out_wEmpfaengerLiveCounter := in_wSenderLiveCounter;

(* Hinweis:
   - Kommunikationsproblem feststellen
     => Der Live Counter muss sich innerhalb von 5 Sekunden erhoehen sonst muss ein Fehler generiert werden
*)
IF ( wlMerkerLiveCounterSender <> in_wSenderLiveCounter ) THEN
  wlMerkerLiveCounterSender := in_wSenderLiveCounter;
END_IF


tonlUeberwachungLiveCounter( IN := ( out_wEmpfaengerLiveCounter = wlMerkerLiveCounterSender ),
                             PT := cZEIT_UEBERWACHUNG_LIVECOUNTER );

IF ( tonlUeberwachungLiveCounter.Q ) THEN
  blFehlermeldungGenerierenKommunikation := TRUE;
ELSE
  blFehlermeldungGenerierenKommunikation := FALSE;
END_IF
END_ACTION