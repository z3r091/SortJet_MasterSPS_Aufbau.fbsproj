(* METADATA
{
	"v3Meta": {
		"objectGuid": "88539335-6d2a-4efd-8213-a5feda61f359"
	}
}
*)
PROGRAM Verfahrueberwachung_PRG
VAR

  // BOOLEAN
  ablKonfiguriert                           : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL; // Shuttle / Transfershuttle ist in dieser Anlage vorhanden
  ablShuttleInParkpos                       : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL;
  ablShuttleStehtOhnePositionsveraenderung  : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL;

  // WORD
  wlIndex    : WORD;

  // REAL
  rlAlteZeit                               : REAL;
  rlAktuelleZeit                           : REAL;
  rlZyklusZeit                             : REAL;
  arlAktuelleGeschwindigkeit               : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; // mm/s
  arlErrechneteGeschwindigkeit             : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; // mm/s, aus der Positionsaenderung
  arlBerechneterBremsWeg                   : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlAltePosition                          : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlNeuePosition                          : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlPostionsveraenderung                  : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlErrechneteStillstandposition          : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlVerzoegerung                          : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; // Verzoegerung bei Sofort-Stopp in mm/s^2
  arlBremsfaktor                           : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; // Bremszeit in s
  arlAktuellerSicherheitsabstand           : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlPostionsMittelwert                    : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlActPosShuttle                         : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; // Aktuelle Position in mm
  arlActGeschwindigkeit                    : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; // Aktuelle Geschwindigkeit in mm/s

  // STRUCT
  arrParkpositionen                        : ARRAY[cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF Parkpositionen_ST;

  // TIME
  TmStmp : TIME;
  Zyklus : TIME;

END_VAR
VAR CONSTANT

  // REAL
  cTOLERANZ_PARKPOSITION : REAL := 100.0; // Abweichung zur Parkposition [mm], in der das Shuttle als "in Parkposition" gilt
  cTOLERANZ_STEHT        : REAL := 2.0;   // Positionsaenderung je Zyklus [mm], unter der das Shuttle als stehend gilt

END_VAR
(* Hinweis:
   - Dieser Baustein errechnet die Stillstandsposition von fahrenden Shuttlen (Shuttle und Transfershuttle),
     um eine drohende Kollision zweier Shuttle auf einer Bahn vorauszuberechnen.
   - Die berechneten Einheiten sind mm und s.
   - Die Shuttle liegen auf einer Bahn in der Reihenfolge ihrer Nummer: das Shuttle mit der kleineren Nummer
     (z. B. 151) liegt auf der kleineren Position, das mit der groesseren Nummer (z. B. 152) auf der groesseren.
*)
TmStmp := TIME();

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: ZYKLUSZEITBERECHNUNG
//-------------------------------------------------------------------------------------------------
rlAktuelleZeit := TIME_TO_REAL(TIME());
rlZyklusZeit   := rlAktuelleZeit - rlAlteZeit;
rlAlteZeit     := rlAktuelleZeit;

// WORKAROUND EXCEPTION
IF ( rlZyklusZeit = 0 ) THEN
  rlZyklusZeit := 1;
END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: UEBERGABE PARKPOSITION, VERZOEGERUNG UND POSITION
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Parkpositionen, Verzoegerungen (Maschinenkonstanten, in mm/s^2) und die vom Antrieb gemeldete Position / Geschwindigkeit
     der Shuttle und der Transfershuttle in gemeinsame Arrays uebernehmen
   - Ist ein Shuttle deaktiviert, wird seine Position auf die weit entfernte Parkseite gelegt, damit es nicht stoert
*)
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

  ablKonfiguriert[wlIndex] := ( apgShuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MAX
                                OR apgShuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN
                                OR apgShuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN_MAX );

  IF ablKonfiguriert[wlIndex] THEN

    arrParkpositionen[wlIndex].eParkposition        := apgShuttleVerfahrparameter[wlIndex].eParkposition;
    arrParkpositionen[wlIndex].rParkpositionMaximum := apgShuttleVerfahrparameter[wlIndex].rParkpositionMaximum;
    arrParkpositionen[wlIndex].rParkpositionMinimum := apgShuttleVerfahrparameter[wlIndex].rParkpositionMinimum;
    arlVerzoegerung[wlIndex]                        := apgVerfahrueberwachung[wlIndex].rMaxVerzoegerungsRampeUeberwachung;

    IF ( NOT starrShuttleBasisParameter[wlIndex].stMKs.bDeaktivieren ) THEN
      arlActPosShuttle[wlIndex]      := aShuttle[wlIndex].Querfahrt.rpAktPosition;
      arlActGeschwindigkeit[wlIndex] := aShuttle[wlIndex].Querfahrt.rpAktSpeed;
    ELSE
      arlActPosShuttle[wlIndex]      := SEL( apgShuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MAX, -50000.0, 50000.0 );
      arlActGeschwindigkeit[wlIndex] := 0;
    END_IF

  ELSE
    wpgFehlerdaten[0] := wlIndex;
    wpgFehlerdaten[1] := apgShuttleVerfahrparameter[wlIndex].eParkposition;
    SpsHinweis( eFehler_Verfahrueberwachung,
                cMELDUNG_VERFAHRUEBERWACHUNG_UNGUELTIGE_PARKPOSITION,
                wlIndex,
                AutomatikkreisBestimmen(wlIndex),
                wpgFehlerdaten );
  END_IF

END_FOR

FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO

  ablKonfiguriert[wlIndex] := ( apgTransfershuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MAX
                                OR apgTransfershuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN
                                OR apgTransfershuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN_MAX );

  IF ablKonfiguriert[wlIndex] THEN

    arrParkpositionen[wlIndex].eParkposition        := apgTransfershuttleVerfahrparameter[wlIndex].eParkposition;
    arrParkpositionen[wlIndex].rParkpositionMaximum := apgTransfershuttleVerfahrparameter[wlIndex].rParkpositionMaximum;
    arrParkpositionen[wlIndex].rParkpositionMinimum := apgTransfershuttleVerfahrparameter[wlIndex].rParkpositionMinimum;
    arlVerzoegerung[wlIndex]                        := apgVerfahrueberwachungTransfershuttle[wlIndex].rMaxVerzoegerungsRampeUeberwachung;

    IF ( NOT starrTransfershuttleBasisParameter[wlIndex].stMKs.bDeaktivieren ) THEN
      arlActPosShuttle[wlIndex]      := aTransfershuttles[wlIndex].Querfahrt.rpAktPosition;
      arlActGeschwindigkeit[wlIndex] := aTransfershuttles[wlIndex].Querfahrt.rpAktSpeed;
    ELSE
      arlActPosShuttle[wlIndex]      := SEL( apgTransfershuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MAX, -50000.0, 50000.0 );
      arlActGeschwindigkeit[wlIndex] := 0;
    END_IF

  ELSE
    wpgFehlerdaten[0] := wlIndex;
    wpgFehlerdaten[1] := apgTransfershuttleVerfahrparameter[wlIndex].eParkposition;
    SpsHinweis( eFehler_Verfahrueberwachung,
                cMELDUNG_VERFAHRUEBERWACHUNG_UNGUELTIGE_PARKPOSITION,
                wlIndex,
                AutomatikkreisBestimmen(wlIndex),
                wpgFehlerdaten );
  END_IF

END_FOR

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: STILLSTANDSPOSITION UND PARKPOSITION
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Bei einem stillstehenden Shuttle ist die errechnete Stillstandsposition gleich der aktuellen Position
   - Sonst: Position plus Bremsweg bei Sofort-Stopp in Fahrtrichtung
*)
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO

  IF NOT ablKonfiguriert[wlIndex] THEN
    CONTINUE;
  END_IF

  // => Die alte Position minus der neuen Position ergibt die Positionsveraenderung,
  //      geteilt durch die Zykluszeit ergibt das Weg/Zeit -> mm/ms, mal 1000 ergibt mm/s
  arlNeuePosition[wlIndex]                          := arlActPosShuttle[wlIndex];
  arlPostionsveraenderung[wlIndex]                  := arlNeuePosition[wlIndex] - arlAltePosition[wlIndex];
  arlErrechneteGeschwindigkeit[wlIndex]             := ( arlPostionsveraenderung[wlIndex] / rlZyklusZeit ) * 1000;
  ablShuttleStehtOhnePositionsveraenderung[wlIndex] := ( ABS( arlPostionsveraenderung[wlIndex] ) < 1 );

  // Mittelwert aus alter und neuer Position, VOR dem Ueberschreiben der alten Position bilden
  arlPostionsMittelwert[wlIndex] := ( arlNeuePosition[wlIndex] + arlAltePosition[wlIndex] ) / 2;
  arlAltePosition[wlIndex]       := arlNeuePosition[wlIndex];

  arlAktuelleGeschwindigkeit[wlIndex] := arlActGeschwindigkeit[wlIndex]; // mm/s

  // => Verbleibende Wegstrecke bei einem Sofort-Stopp
  //   => Berechnung:
  //      F [mm/s], a [mm/s^2], S [mm], t [s]
  //
  //      S = ( ( Va-Ve ) / 2 ) * t
  //      t = Va / a
  //
  //      S = ( ( Va-Ve ) / 2 ) * ( Va / a )
  //
  //      fuer Ve gilt = 0
  //
  //      S = ( Va / 2 ) * ( Va / a )
  IF ( arlVerzoegerung[wlIndex] > 0 ) THEN
    arlBremsfaktor[wlIndex] := arlAktuelleGeschwindigkeit[wlIndex] / arlVerzoegerung[wlIndex]; // dies ist t
  ELSE
    arlBremsfaktor[wlIndex] := 0;
  END_IF

  arlBerechneterBremsWeg[wlIndex] := ( arlAktuelleGeschwindigkeit[wlIndex] / 2.0 ) * arlBremsfaktor[wlIndex];

  // => Der errechnete Bremsweg ist durch die Quadratur immer positiv, deshalb nach Fahrtrichtung unterscheiden
  IF ( arlAktuelleGeschwindigkeit[wlIndex] > 0 ) THEN
    arlErrechneteStillstandposition[wlIndex] := arlNeuePosition[wlIndex] + arlBerechneterBremsWeg[wlIndex];
  ELSE
    arlErrechneteStillstandposition[wlIndex] := arlNeuePosition[wlIndex] - arlBerechneterBremsWeg[wlIndex];
  END_IF

  (* Hinweis:
     - Wenn das Shuttle in Parkposition ist, darf das Gegenshuttle naeher fahren
  *)
  CASE arrParkpositionen[wlIndex].eParkposition OF

    PARKPOSITION_MIN:
      ablShuttleInParkpos[wlIndex] :=
                                     ABS( arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMinimum ) < cTOLERANZ_PARKPOSITION // im Bereich der Parkposition
                                     AND ( ABS( arlPostionsMittelwert[wlIndex] - arlNeuePosition[wlIndex] ) < cTOLERANZ_STEHT ); // das Shuttle steht

    PARKPOSITION_MAX:
      ablShuttleInParkpos[wlIndex] :=
                                     ABS( arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMaximum ) < cTOLERANZ_PARKPOSITION // im Bereich der Parkposition
                                     AND ( ABS( arlPostionsMittelwert[wlIndex] - arlNeuePosition[wlIndex] ) < cTOLERANZ_STEHT ); // das Shuttle steht

    PARKPOSITION_MIN_MAX:
      ablShuttleInParkpos[wlIndex] :=
                                     (
                                       ( ABS( arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMinimum ) < cTOLERANZ_PARKPOSITION )
                                       OR ( ABS( arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMaximum ) < cTOLERANZ_PARKPOSITION )
                                     ) // im Bereich der Parkposition
                                     AND ( ABS( arlPostionsMittelwert[wlIndex] - arlNeuePosition[wlIndex] ) < cTOLERANZ_STEHT ); // das Shuttle steht

  END_CASE

END_FOR

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: ABSTANDSUEBERWACHUNG TRANSFERSHUTTLE 151 <-> 152
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Die Transfershuttle 151 und 152 fahren auf einer Bahn, 151 liegt auf der kleineren Position
   - Ist eines der beiden in Parkposition, gilt der kleinere Abstand
   - Die Verfahrfreigabe wird jeden Zyklus neu gebildet und nur gesperrt, solange der Mindestabstand unterschritten wuerde
   - Gesperrt wird nur, wenn beide Transfershuttle referenziert sind
*)
IF ( ablShuttleInParkpos[cSHUTTLE_151] OR ablShuttleInParkpos[cSHUTTLE_152] ) THEN
  arlAktuellerSicherheitsabstand[cSHUTTLE_151] := rgMkMinSecureDistanceTransferAtParkPos;
  arlAktuellerSicherheitsabstand[cSHUTTLE_152] := rgMkMinSecureDistanceTransferAtParkPos;
ELSE
  arlAktuellerSicherheitsabstand[cSHUTTLE_151] := rgMkMinSecureDistanceTransfer;
  arlAktuellerSicherheitsabstand[cSHUTTLE_152] := rgMkMinSecureDistanceTransfer;
END_IF

abgVerfahrfreigabeShuttle[cSHUTTLE_151] := TRUE;
abgVerfahrfreigabeShuttle[cSHUTTLE_152] := TRUE;

IF aTransfershuttles[cSHUTTLE_151].Querfahrt.bpInReference
   AND aTransfershuttles[cSHUTTLE_152].Querfahrt.bpInReference
THEN

  // 151 darf nicht ueber 152 hinaus (minus Sicherheitsabstand)
  IF arlErrechneteStillstandposition[cSHUTTLE_151] >
     ( arlErrechneteStillstandposition[cSHUTTLE_152] - arlAktuellerSicherheitsabstand[cSHUTTLE_151] )
  THEN
    abgVerfahrfreigabeShuttle[cSHUTTLE_151] := FALSE;
  END_IF

  // 152 darf nicht unter 151 hinaus (plus Sicherheitsabstand)
  IF arlErrechneteStillstandposition[cSHUTTLE_152] <
     ( arlErrechneteStillstandposition[cSHUTTLE_151] + arlAktuellerSicherheitsabstand[cSHUTTLE_152] )
  THEN
    abgVerfahrfreigabeShuttle[cSHUTTLE_152] := FALSE;
  END_IF

END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: ABSTANDSUEBERWACHUNG SHUTTLE 101 <-> 102 (DUMMY, AUSKOMMENTIERT)
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Nur noetig, wenn sich zwei Shuttle auf EINER Bahn befinden (bei Dreisbusch nicht: 101 und 102 fahren auf getrennten Bahnen)
   - Zum Aktivieren: Kommentar entfernen. MKs rgMkMinSecureDistanceShuttles / ...AtParkPos sind vorhanden
   - Aufbau wie bei den Transfershuttle: 101 liegt auf der kleineren Position, 102 auf der groesseren
   - Fuer weitere Paare auf einer Bahn kopieren und die Nummern anpassen

     IF ( ablShuttleInParkpos[cSHUTTLE_101] OR ablShuttleInParkpos[cSHUTTLE_102] ) THEN
     arlAktuellerSicherheitsabstand[cSHUTTLE_101] := rgMkMinSecureDistanceShuttlesAtParkPos;
     arlAktuellerSicherheitsabstand[cSHUTTLE_102] := rgMkMinSecureDistanceShuttlesAtParkPos;
     ELSE
     arlAktuellerSicherheitsabstand[cSHUTTLE_101] := rgMkMinSecureDistanceShuttles;
     arlAktuellerSicherheitsabstand[cSHUTTLE_102] := rgMkMinSecureDistanceShuttles;
     END_IF

     abgVerfahrfreigabeShuttle[cSHUTTLE_101] := TRUE;
     abgVerfahrfreigabeShuttle[cSHUTTLE_102] := TRUE;

     IF aShuttle[cSHUTTLE_101].Querfahrt.bpInReference
     AND aShuttle[cSHUTTLE_102].Querfahrt.bpInReference
     THEN

     IF arlErrechneteStillstandposition[cSHUTTLE_101] >
     ( arlErrechneteStillstandposition[cSHUTTLE_102] - arlAktuellerSicherheitsabstand[cSHUTTLE_101] )
     THEN
     abgVerfahrfreigabeShuttle[cSHUTTLE_101] := FALSE;
     END_IF

     IF arlErrechneteStillstandposition[cSHUTTLE_102] <
     ( arlErrechneteStillstandposition[cSHUTTLE_101] + arlAktuellerSicherheitsabstand[cSHUTTLE_102] )
     THEN
     abgVerfahrfreigabeShuttle[cSHUTTLE_102] := FALSE;
     END_IF

     END_IF
*)

Zyklus := TIME() - TmStmp;
END_PROGRAM