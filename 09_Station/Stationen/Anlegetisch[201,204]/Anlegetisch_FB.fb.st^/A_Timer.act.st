(* METADATA
{
  "v3Meta": {
    "objectGuid": "1069ab21-4b92-41c8-b82e-5b5576ca32a5"
  }
}
*)
ACTION A_Timer
(***************************************************************************************************)
(* AKTION TIMER *)
(***************************************************************************************************)
// Entprellen der Sensoren
toflEinlaufsensor(IN := Glastransport.bpSensorEinlauf, PT := T#50MS);

// Eingangsauswertung
rtlTasterQuittierung(CLK := in_bTasterQuittierungScheibenmessung);

rtlFussleisteStart(CLK := ( NOT ( in_bFussschalterGlasAngelegt OR in_bTasterGlasAngelegt ) ) );


tonlKnebelZurueck( IN := in_bKnebelRiemenZurueck , PT := T#200MS );


ftlVSGAutomatikBetriebBeendet( CLK := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bAutomatikBetriebAktiv );

toflDruckluftOK( IN := in_bDruckluft_OK, PT := t#3s );

ftlGlastransportCheckMitNachfolger( CLK := Glastransport.bpCheckMitNachfolger );
END_ACTION