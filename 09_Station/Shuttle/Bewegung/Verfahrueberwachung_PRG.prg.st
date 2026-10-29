(* METADATA
{
	"v3Meta": {
		"objectGuid": "88539335-6d2a-4efd-8213-a5feda61f359"
	}
}
*)
PROGRAM Verfahrueberwachung_PRG
VAR

  (* BOOLEAN *)
  blErsterZyklus                            : BOOL := TRUE;
  ablShuttleInParkpos                       : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF BOOL;  (* Die Verzögerung wird in 10tel mm/s² üebergeben, wir benötigen mm/s² *)
  ablShuttleStehtOhnePositionsveraenderung  : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF BOOL;
  ablShuttleVerfaehrt                       : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF BOOL  :=[ 0]; (* Hinweis: Initialisiert muss dieses Array mit 0 [je Index] *)

  (* WORD *)
  wlSpeicherintervall : WORD := 1;  (* Diese Zahl gibt an in welchem Intervall die errechneten Daten gespeichert werden sollen, in ms *)
  wlIndex    : WORD;
  wlIndex2   : WORD := 0;

  (* REAL *)
  rlAlteZeit                  : REAL;
  rlAktuelleZeit              : REAL;
  rlZyklusZeit                : REAL;
  rlZeitBeiLetzterSpeicherung : REAL;
  rlSpeicherIndex             : REAL;
  arlAktuelleGeschwindigkeit               : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL;
  arlErrechneteGeschwindigkeit             : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL;
  arlBerechneterBremsWeg                   : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL;
  arlAltePosition                          : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL;
  arlNeuePosition                          : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL;
  arlPostionsveraenderung                  : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL;
  arlErrechneteStillstandposition          : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL;
  arlVerzoegerung                          : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL; (* Sollte das Shuttle bei aktueller Geschwindigkeit sofort bremsen, dann würde es an dieser Stelle zum stehen kommen *)
  arlShutleParkposition                    : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL; (* Das Shuttle ist in Parkposition, das Gegenshuttle darf näher fahren *)
  arlBremsfaktor                           : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL; (* Parkpositonen in ein Array übertragen *)
  arlAktuellerSicherheitsabstand           : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL;
  arlPostionsMittelwert                    : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL; (* Die Geschwindigkeitsrichtig mit der das Shuttle in seine Parkposition hinein fährt *)
  arpGeschwindigkeitInRichtungParkposition : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL :=[ -1]; (* -1, 1, -1, 1, -1, 1, -1, 1; *)
  arlActPosShuttle                         : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL; (* Aktuelle Position in mm (festgelegt in S-0-0076, Wichtungsart für Lagedaten) *)
  arlActGeschwindigkeit                    : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF REAL; (* aktuelle Geschwindigkeit in m/min (festgelegt in S-0-0044, Wichtungsart für Geschwindigkeitsdaten) *)
  arrParkpositionen                        : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF Parkpositionen_ST;

  (* STRUCT *)
  astlSpeicher : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE,0..100] OF Verfahrueberwachung_ST; (* Die errechneten Variablen speichern um die Ergebnisse nachvollziehen zu können *)

  (* DATEI SCHREIBEN *)
  blDateiOffen         : BOOL;   (* File System *)
  blAufzeichnenStarten : BOOL  := FALSE; (* File System *)
  TestDatei            : STRING; (* File System *)
  Mode                 : STRING; (* File System *)
  ilsizeof             : INT;    (* Datei schreiben *)
  DwWritten            : DWORD;  (* Datei schreiben *)
  hFile                : DWORD;  (* Datei schreiben *)
  File                 : DWORD;  (* Datei schreiben *)
  WriteBuffer          : ARRAY[0..7] OF DWORD; (* Datei schreiben *)

  TmStmp : TIME;
  Zyklus : TIME;
  
END_VAR
(* Hinweis:
   - Dieser Baustein soll eine Stillstandsposition von fahrenden Shuttlen errechnen um eine
     drohende Kollision zweier Shuttle voraus zu berechnen.
   - Die berechneten Einheiten sollen in mm und s sein.
*)
TmStmp := TIME();
(***************************************************************************************************)
(* BAUSTEIN: ZYKLUSZEITBERECHNUNG *)
(***************************************************************************************************)
blErsterZyklus := FALSE;

rlAktuelleZeit := TIME_TO_REAL(TIME());
rlZyklusZeit := rlAktuelleZeit - rlAlteZeit;
rlAlteZeit := rlAktuelleZeit;

// WORKAROUND EXCEPTION 
IF ( rlZyklusZeit = 0 ) THEN
    rlZyklusZeit := 1;
END_IF

(***************************************************************************************************)
(* BAUSTEIN: UEBERGABE DER PARKPOSITION  *)
(***************************************************************************************************)
(* Hinweis:
   - Zuweisen der der Parkpositionen
     => Inputshuttle \ Outputshuttle 
*)
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

  IF ( apgShuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MAX
    OR apgShuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN
    OR apgShuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN_MAX )
  THEN

    arrParkpositionen[wlIndex].eParkposition        := apgShuttleVerfahrparameter[wlIndex].eParkposition;
    arrParkpositionen[wlIndex].rParkpositionMaximum := apgShuttleVerfahrparameter[wlIndex].rParkpositionMaximum;
    arrParkpositionen[wlIndex].rParkpositionMinimum := apgShuttleVerfahrparameter[wlIndex].rParkpositionMinimum;

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

(***************************************************************************************************)
(* BAUSTEIN: MASCHINENKONSTANTEN *)
(***************************************************************************************************)
(* Hinwesi
   - Maschinenkonstanten für die Verzögerung in 10tel mm in das Array übernehmen und in mm umwandeln 
*)
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  arlVerzoegerung[wlIndex]    := apgVerfahrueberwachung[wlIndex].rMaxVerzoegerungsRampeUeberwachung;
END_FOR

(***************************************************************************************************)
(* BAUSTEIN: ZUWEISUNGEN *)
(***************************************************************************************************)
(* Hinweis:
   - Die vom Bus übertragenen Werte übernehmen und in auswertbare Zahlen umwandeln 
*)
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

  IF ( NOT starrShuttleBasisParameter[wlIndex].stMKs.bDeaktivieren ) THEN
    arlActPosShuttle[wlIndex]      := aShuttle[wlIndex].Querfahrt.rpAktPosition;
    arlActGeschwindigkeit[wlIndex] := aShuttle[wlIndex].Querfahrt.rpAktSpeed;

  ELSE

    IF ( apgShuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MAX ) THEN
      arlActPosShuttle[wlIndex]      := 50000.0;
      arlActGeschwindigkeit[wlIndex] := 0;

    ELSIF ( apgShuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN ) THEN
      arlActPosShuttle[wlIndex]      :=  -50000.0;
      arlActGeschwindigkeit[wlIndex] := 0;

    ELSE
      arlActPosShuttle[wlIndex]      := -50000.0;
      arlActGeschwindigkeit[wlIndex] := 0;

    END_IF

  END_IF

END_FOR

(***************************************************************************************************)
(* BAUSTEIN: UEBERWACHUNG *)
(***************************************************************************************************)
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

  (* =>  Die alte Position minus der neuen Position ergibt die Positionsveränderung
         geteilt durch die Zykluszeit ergibt das Weg/Zeit -> mm/ms mal 1000 ergibt mm/s
  *)
  arlNeuePosition[wlIndex] := arlActPosShuttle[wlIndex];
  arlPostionsveraenderung[wlIndex] := arlNeuePosition[wlIndex] - arlAltePosition[wlIndex];
  arlErrechneteGeschwindigkeit[wlIndex] := (arlPostionsveraenderung[wlIndex]/rlZyklusZeit)*1000;
  ablShuttleStehtOhnePositionsveraenderung[wlIndex] := (ABS(arlNeuePosition[wlIndex] - arlAltePosition[wlIndex]) < 1);
  arlAltePosition[wlIndex] := arlNeuePosition[wlIndex];
  arlAktuelleGeschwindigkeit[wlIndex] := (arlActGeschwindigkeit[wlIndex]); (*  mm/s *)
  arlPostionsMittelwert[wlIndex] := ((arlNeuePosition[wlIndex] + arlAltePosition[wlIndex]) / 2);

  (* => Verbleibende Wegstrecke bei einem Sofort-Stop
     => Berechnung:
        F [mm/s], a [mm/s²], S [mm], t [s]

        S = ( ( Va-Ve ) / 2 ) * t
        t = Va / a
      
        S = ( ( Va-Ve ) / 2 ) * ( Va / a )

        für Ve gilt = 0

        S = ( Va / 2 ) * ( Va / a )
  *)
  arlBremsfaktor[wlIndex] := (arlAktuelleGeschwindigkeit[wlIndex] / arlVerzoegerung[wlIndex]); (* dies ist t *)

  arlBerechneterBremsWeg[wlIndex] := ( arlAktuelleGeschwindigkeit[wlIndex] / 2.0 ) * (arlBremsfaktor[wlIndex]);

  (* => Da der errechnete Bremsweg immer positiv durch die Quadratur ist, müssen wir nach Geschwindigkeit unterscheiden
  *)
  IF ( arlAktuelleGeschwindigkeit[wlIndex] > 0 )THEN
    arlErrechneteStillstandposition[wlIndex] := arlNeuePosition[wlIndex] + arlBerechneterBremsWeg[wlIndex];
  ELSE
    arlErrechneteStillstandposition[wlIndex] := arlNeuePosition[wlIndex] - arlBerechneterBremsWeg[wlIndex];
  END_IF

  (* Hinweis:
     - Wenn das Shuttle in Parkposition ist, dann darf das Gegenshuttle näher fahren 
  *)
  CASE arrParkpositionen[wlIndex].eParkposition OF

    PARKPOSITION_MIN:
      ablShuttleInParkpos[wlIndex] :=
        ABS(arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMinimum) < 5 (* im Bereich der Parkposition *)
        AND (ABS(arlPostionsMittelwert[wlIndex] - arlNeuePosition[wlIndex]) < 1  ); (* das Shuttle steht *)


    PARKPOSITION_MAX:
      ablShuttleInParkpos[wlIndex] :=
        ABS(arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMaximum) < 5 (* im Bereich der Parkposition *)
        AND (ABS(arlPostionsMittelwert[wlIndex] - arlNeuePosition[wlIndex]) < 1  ); (* das Shuttle steht *)


    PARKPOSITION_MIN_MAX:
      ablShuttleInParkpos[wlIndex] :=
        (
             ( ABS(arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMinimum) < 1 )
          OR ( ABS(arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMaximum) < 1 )
        )  (* im Bereich der Parkposition *)
        AND (ABS(arlPostionsMittelwert[wlIndex] - arlNeuePosition[wlIndex]) < 1  ); (* das Shuttle steht *)

  END_CASE

END_FOR



(***************************************************************************************************)
(* BAUSTEIN: PARKPOSITION *)
(***************************************************************************************************)
(* Hinweis:
   - Wenn das Gegenshuttle in der Parkpositon ist, ist der Minimumabstand geringer 
*)

(* SHUTTLE 101 - 102 *)
(*
IF ablShuttleInParkpos[cSHUTTLE_101] OR ablShuttleInParkpos[cSHUTTLE_102] THEN
  arlAktuellerSicherheitsabstand[cSHUTTLE_101] := rgMkMinSecureDistanceInputShuttlesAtParkPos;
  arlAktuellerSicherheitsabstand[cSHUTTLE_102] := rgMkMinSecureDistanceInputShuttlesAtParkPos;
ELSE
  arlAktuellerSicherheitsabstand[cSHUTTLE_101] := rgMkMinSecureDistanceInputShuttles;
  arlAktuellerSicherheitsabstand[cSHUTTLE_102] := rgMkMinSecureDistanceInputShuttles;
END_IF

(* SHUTTLE 103 - 104 *)
IF ablShuttleInParkpos[cSHUTTLE_103] OR ablShuttleInParkpos[cSHUTTLE_104] THEN
  arlAktuellerSicherheitsabstand[cSHUTTLE_103] := rgMkMinSecureDistanceOutputShuttlesAtParkPos;
  arlAktuellerSicherheitsabstand[cSHUTTLE_104] := rgMkMinSecureDistanceOutputShuttlesAtParkPos;
ELSE
  arlAktuellerSicherheitsabstand[cSHUTTLE_103] := rgMkMinSecureDistanceOutputShuttles;
  arlAktuellerSicherheitsabstand[cSHUTTLE_104] := rgMkMinSecureDistanceOutputShuttles;
END_IF
*)
(***************************************************************************************************)
(* BAUSTEIN: STILLSTANDSPOSITION *)
(***************************************************************************************************)
(* Hinweis:
   - Bei einem stillstehendem Shuttle ist die errechnete Stillstandsposition immer gleich der aktuellen Position
     Wenn beide Shuttle in die gleiche Richtung fahren, werden bei beiden die Stillstandspositionen errechnet
*)
(* Hinweis:
   - Inputshuttle 101 <-> 102
*)
(*
IF arlErrechneteStillstandposition[cSHUTTLE_101] <
   (arlErrechneteStillstandposition[cSHUTTLE_102] + arlAktuellerSicherheitsabstand[cSHUTTLE_101])
  AND aShuttle[cSHUTTLE_101].Querfahrt.Antrieb.bpIstReferenziert
  AND aShuttle[cSHUTTLE_102].Querfahrt.Antrieb.bpIstReferenziert
THEN
  abgVerfahrfreigabeShuttle[cSHUTTLE_101] := FALSE;
END_IF

IF arlErrechneteStillstandposition[cSHUTTLE_102] >
   (arlErrechneteStillstandposition[cSHUTTLE_101] - arlAktuellerSicherheitsabstand[cSHUTTLE_102])
  AND aShuttle[cSHUTTLE_101].Querfahrt.Antrieb.bpIstReferenziert
  AND aShuttle[cSHUTTLE_102].Querfahrt.Antrieb.bpIstReferenziert
THEN
  abgVerfahrfreigabeShuttle[cSHUTTLE_102] := FALSE;
END_IF

(* Hinweis:
   - Inputshuttle 103 <-> 104
*)

IF arlErrechneteStillstandposition[cSHUTTLE_103] <
   (arlErrechneteStillstandposition[cSHUTTLE_104] + arlAktuellerSicherheitsabstand[cSHUTTLE_103])
  AND aShuttle[cSHUTTLE_103].Querfahrt.Antrieb.bpIstReferenziert
  AND aShuttle[cSHUTTLE_104].Querfahrt.Antrieb.bpIstReferenziert
THEN
  abgVerfahrfreigabeShuttle[cSHUTTLE_103] := FALSE;
END_IF

IF arlErrechneteStillstandposition[cSHUTTLE_104] >
   (arlErrechneteStillstandposition[cSHUTTLE_103] - arlAktuellerSicherheitsabstand[cSHUTTLE_103])
  AND aShuttle[cSHUTTLE_103].Querfahrt.Antrieb.bpIstReferenziert
  AND aShuttle[cSHUTTLE_104].Querfahrt.Antrieb.bpIstReferenziert
THEN
  abgVerfahrfreigabeShuttle[cSHUTTLE_104] := FALSE;
END_IF
*)

Zyklus := TIME() - TmStmp;
END_PROGRAM