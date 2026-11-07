(* METADATA
{
	"v3Meta": {
		"objectGuid": "ce8ece5c-8ab2-443c-8006-efb283711b14"
	}
}
*)
ACTION A_Ausgaenge
//-------------------------------------------------------------------------------------------------
// AUSGAENGE
//-------------------------------------------------------------------------------------------------


// Zuweisung[Lokal]:
//   - Sicherstellen das kein Interner-Vortransport aktiviert wird wenn in der Steuerung der autarke Vortransport
//     aktiv ist
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  ablVortransportAktiv[wlIndex] := Glastransport[wlIndex].bpVortransportAktiv;
END_FOR


// Zuweisung[Lokal]:
//   - Sicherstellen das bestimmte Komponenten Prozesse nicht ueberschrieben werden
//     => Beachten der Bausteinaufrufe (Start- Bit und Rucksetzen)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blVorAbAuftragAktiv[wlIndex] :=    (  BasisStationsParameter.bVorabKomponentenAnsteuerung[wlIndex]
                                       OR ( NOT BasisStationsParameter.bVorabKomponentenAnsteuerung[wlIndex] AND ( AnsteuerungRessourcen[wlIndex].steplAktion > STEP_0_E )));
END_FOR

// Ausgaenge:
//   - Der Auftragsstatus [cSHUTTLE_VORABPOSITIONIEREN] muss zurueck gesetzt werden
BasisStationsParameter.bPositionierAuftragZuruecksetzen := Querfahrt.bpAuftragsstatusZuruecksetzen;


(* Hinweis:
   - Uebergabe der aktuellen IST- Position des Shuttles
*)
BasisStationsParameter.rAktuellePositionQuerfahrt := Querfahrt.rpAktPosition;


// Positionsabfrage:
//   - Wurde die Zielposition aus dem Auftrag erreicht, bzw. stimmt die aktuelle Shuttleposition mit der
//     Position aus dem Auftrag ueberein.
blZielPositionErreicht := (     ( ABS( BasisStationsParameter.rAktuellePositionQuerfahrt - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz )
                            OR ( ABS( BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz ) 
                            OR  ( ABS(ABS(BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition) - ABS(BasisStationsParameter.rAktuellePositionQuerfahrt) ) <= rgMKZielPositionToleranz ) );

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