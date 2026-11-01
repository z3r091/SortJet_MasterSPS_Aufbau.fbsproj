(* METADATA
{
  "v3Meta": {
    "objectGuid": "b3601bc0-1048-43ee-b139-90f8cc2d9e65"
  }
}
*)
ACTION A_Ausgaenge
(***************************************************************************************************)
(* AUSGAENGE *)
(***************************************************************************************************)

(* HINWEIS:
   - Anforderung des Betriebsstop fuer die Auslaufseite 
     => Scheibe ist ueber den Auslaufsensor gefahren und kann nicht mehr korregiert werden
*)
bpAnforderungBetriebsstopp := Glastransport.bpAnforderungBetriebsstopp;

(* Ausgaenge:
   - Der Auftragsstatus [cSHUTTLE_VORABPOSITIONIEREN] muss zurueck gesetzt werden
*)
BasisStationsParameter.bPositionierAuftragZuruecksetzen := Querfahrt.bpAuftragsstatusZuruecksetzen;
 

(* Anmerkung:
   - Ausgabe des Fehlertyp (Sensor \ etc. )
*)
wpAusnahmefehlerTyp := Glastransport.wpAusnahmefehlerTyp;

(***************************************************************************************************)
(* VERFAHRUEBERWACHUNG *)
(***************************************************************************************************)
(* Anmerkung:
   - Übergabe der aktuellen IST- Position des Shuttles
*)
BasisStationsParameter.rAktuellePositionQuerfahrt := Querfahrt.rpAktPosition;

(* Anmerkung:
   - Shuttle kann sicher verfahren. Alle Abfragen+ Shuttle sind abgesenkt
*)
bpShuttleKannSicherVerfahrenWerden := Glastransport.bpBereitZumVerfahren;

(* Anmerkung:
   - Positionsabfrage ob die Position korrekt angefahren wurde
 *)
blZielPositionErreicht := (     ( ABS( BasisStationsParameter.rAktuellePositionQuerfahrt - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz )
                            OR ( ABS( BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz )
                            OR  ( ABS(ABS(BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition) - ABS(BasisStationsParameter.rAktuellePositionQuerfahrt) ) <= rgMKZielPositionToleranz ) );

(* Hinweis:
   - Abfrage ob die Luftabfrage [Ein- Aus- Lauf] unten ist 
     => Verwendung fuer die Freigabe der Querfahrtsantriebs
*)
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bSensorAuslauf ) THEN
  blValidierungLuftabfrageAuslaufUnten       := ( NOT in_bSensorScheibenKontrolleAuslaufSeiteOben
                                                  AND in_bSensorScheibenKontrolleAuslaufSeiteUnten );

ELSE
  blValidierungLuftabfrageAuslaufUnten       := TRUE;

END_IF

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bSensorEinlauf ) THEN
  blValidierungLuftabfrageEinlaufUnten       := ( NOT in_bSensorScheibenKontrolleEinlaufSeiteOben
                                                  AND in_bSensorScheibenKontrolleEinlaufSeiteUnten );

ELSE
  blValidierungLuftabfrageEinlaufUnten       := TRUE;
END_IF

(* Anmerkung:
   - Doppelte Sicherheit => Es darf nicht verfahren werden wenn das Transfershuttle bzw. die Sensoren oben sind 
*)

blShuttleKannSicherVerfahrenWerden := (     NOT in_bSensorShuttleOben
                                        AND in_bSensorShuttleUnten
                                        AND blValidierungLuftabfrageEinlaufUnten
                                        AND blValidierungLuftabfrageAuslaufUnten );

(* Hinweis:
   - Gibt an wann wann sich der Antrieb melden muss
     => rlUpdateZeit: Wird von der Oberflaeche gesendet und entspricht der Zeit wann der Antrieb sich zurueck melden soll [Status]
*)
tonlUpdateTimer(IN := blUpdateTimer, PT := REAL_TO_TIME(BasisStationsParameter.pAuftragVorabPositionierung.rVorabUpdateZeit) );

(* Hinweis:
   - Quittierungsmeldung das der Auftrag zurueck gesetzt worden ist
*)
IF ( BasisStationsParameter.bQuittungPositionierungZurueckgesetzt ) THEN
  BasisStationsParameter.bQuittungPositionierungZurueckgesetzt := FALSE;
  Querfahrt.bpQuittungAuftragsstatusZurueckgesetzt := TRUE;
END_IF
END_ACTION