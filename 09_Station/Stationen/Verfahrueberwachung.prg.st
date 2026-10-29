(* METADATA
{
	"v3Meta": {
		"objectGuid": "98557de6-cf65-42b5-a265-5078b9ea595a"
	}
}
*)
PROGRAM Verfahrueberwachung
VAR

  (* BOOLEAN *)
  blErsterZyklus                            : BOOL := TRUE;
  ablShuttleInParkpos                       : ARRAY[cSTATION_204..cSTATION_208] OF BOOL;  (* Die Verzögerung wird in 10tel mm/s² üebergeben, wir benötigen mm/s² *)
  ablShuttleStehtOhnePositionsveraenderung  : ARRAY[cSTATION_204..cSTATION_208] OF BOOL;
  ablShuttleVerfaehrt                       : ARRAY[cSTATION_204..cSTATION_208] OF BOOL  :=[ 0]; (* Hinweis: Initialisiert muss dieses Array mit 0 [je Index] *)

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
  arlAktuelleGeschwindigkeit               : ARRAY[cSTATION_204..cSTATION_208] OF REAL;
  arlErrechneteGeschwindigkeit             : ARRAY[cSTATION_204..cSTATION_208] OF REAL;
  arlBerechneterBremsWeg                   : ARRAY[cSTATION_204..cSTATION_208] OF REAL;
  arlAltePosition                          : ARRAY[cSTATION_204..cSTATION_208] OF REAL;
  arlNeuePosition                          : ARRAY[cSTATION_204..cSTATION_208] OF REAL;
  arlPostionsveraenderung                  : ARRAY[cSTATION_204..cSTATION_208] OF REAL;
  arlErrechneteStillstandposition          : ARRAY[cSTATION_204..cSTATION_208] OF REAL;
  arlVerzoegerung                          : ARRAY[cSTATION_204..cSTATION_208] OF REAL; (* Sollte das Shuttle bei aktueller Geschwindigkeit sofort bremsen, dann würde es an dieser Stelle zum stehen kommen *)
  arlShutleParkposition                    : ARRAY[cSTATION_204..cSTATION_208] OF REAL; (* Das Shuttle ist in Parkposition, das Gegenshuttle darf näher fahren *)
  arlBremsfaktor                           : ARRAY[cSTATION_204..cSTATION_208] OF REAL; (* Parkpositonen in ein Array übertragen *)
  arlAktuellerSicherheitsabstand           : ARRAY[cSTATION_204..cSTATION_208] OF REAL;
  arlPostionsMittelwert                    : ARRAY[cSTATION_204..cSTATION_208] OF REAL; (* Die Geschwindigkeitsrichtig mit der das Shuttle in seine Parkposition hinein fährt *)
  arpGeschwindigkeitInRichtungParkposition : ARRAY[cSTATION_204..cSTATION_208] OF REAL :=[ -1]; (* -1, 1, -1, 1, -1, 1, -1, 1; *)
  arlActPosShuttle                         : ARRAY[cSTATION_204..cSTATION_208] OF REAL; (* Aktuelle Position in mm (festgelegt in S-0-0076, Wichtungsart für Lagedaten) *)
  arlActGeschwindigkeit                    : ARRAY[cSTATION_204..cSTATION_208] OF REAL; (* aktuelle Geschwindigkeit in m/min (festgelegt in S-0-0044, Wichtungsart für Geschwindigkeitsdaten) *)
  arrParkpositionen                        : ARRAY[cSTATION_204..cSTATION_208] OF Parkpositionen_ST;
	abggeschwindigkeitVerringern             : ARRAY[cSTATION_204..cSTATION_208] OF BOOL;



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
(*
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
FOR wlIndex := cSTATION_204 TO cSTATION_208 DO

  IF ( apgStationVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MAX
    OR apgStationVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN
    OR apgStationVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN_MAX )
  THEN

    arrParkpositionen[wlIndex].eParkposition        := apgStationVerfahrparameter[wlIndex].eParkposition;
    arrParkpositionen[wlIndex].rParkpositionMaximum := apgStationVerfahrparameter[wlIndex].rParkpositionMaximum;
    arrParkpositionen[wlIndex].rParkpositionMinimum := apgStationVerfahrparameter[wlIndex].rParkpositionMinimum;

  ELSE
    wpgFehlerdaten[0] := wlIndex;
    wpgFehlerdaten[1] := apgStationVerfahrparameter[wlIndex].eParkposition;
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
FOR wlIndex := cSTATION_204 TO cSTATION_208 DO
  arlVerzoegerung[wlIndex]    := pgVerfahrueberwachung.rMaxVerzoegerungsRampeUeberwachung;
END_FOR


(***************************************************************************************************)
(* BAUSTEIN: ZUWEISUNGEN *)
(***************************************************************************************************)
(* Hinweis:
   - Die vom Bus übertragenen Werte übernehmen und in auswertbare Zahlen umwandeln 
*)

(* Shuttle 204 *)
IF ( NOT starrStationBasisParameter[cSTATION_204].stMKs.bDeaktivieren ) THEN
  arlActPosShuttle[cSTATION_204]      := Foerderer204.Querfahrt.Antrieb.rpIstPosition;
  arlActGeschwindigkeit[cSTATION_204] := Foerderer204.Querfahrt.Antrieb.rpIstGeschwindigkeit;
ELSE
  arlActPosShuttle[cSTATION_204]      := -50000.0;
  arlActGeschwindigkeit[cSTATION_204] := 0;
END_IF

(* Shuttle 208 *)
IF ( NOT starrStationBasisParameter[cSTATION_208].stMKs.bDeaktivieren ) THEN
  arlActPosShuttle[cSTATION_208]      := Foerderer208.Querfahrt.Antrieb.rpIstPosition;
  arlActGeschwindigkeit[cSTATION_208] := Foerderer208.Querfahrt.Antrieb.rpIstGeschwindigkeit;
ELSE
  arlActPosShuttle[cSTATION_208]      := -50000.0;
  arlActGeschwindigkeit[cSTATION_208] := 0;
END_IF
(***************************************************************************************************)
(* BAUSTEIN: UEBERWACHUNG *)
(***************************************************************************************************)
FOR wlIndex := cSTATION_204 TO cSTATION_208 DO

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

(* SHUTTLE 104- 108 *)

IF ablShuttleInParkpos[cSTATION_204] OR ablShuttleInParkpos[cSTATION_208] THEN
  arlAktuellerSicherheitsabstand[cSTATION_204] := rgMkMinSecureDistanceInputShuttlesAtParkPos;
  arlAktuellerSicherheitsabstand[cSTATION_208] := rgMkMinSecureDistanceInputShuttlesAtParkPos;
ELSE
  arlAktuellerSicherheitsabstand[cSTATION_204] := rgMkMinSecureDistanceInputShuttles;
  arlAktuellerSicherheitsabstand[cSTATION_208] := rgMkMinSecureDistanceInputShuttles;
END_IF


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

IF arlErrechneteStillstandposition[cSTATION_204] >
   (arlErrechneteStillstandposition[cSTATION_208] - arlAktuellerSicherheitsabstand[cSTATION_204])
  AND Foerderer204.Querfahrt.Antrieb.bpIstReferenziert
  AND Foerderer208.Querfahrt.Antrieb.bpIstReferenziert
THEN
  abgVerfahrfreigabeStation[cSTATION_204] := FALSE;
END_IF

IF arlErrechneteStillstandposition[cSTATION_208] <
   (arlErrechneteStillstandposition[cSTATION_204] + arlAktuellerSicherheitsabstand[cSTATION_208])
  AND Foerderer204.Querfahrt.Antrieb.bpIstReferenziert
  AND Foerderer208.Querfahrt.Antrieb.bpIstReferenziert
THEN
  abgVerfahrfreigabeStation[cSTATION_208] := FALSE;
END_IF

(* Hinweis
 Langsamfahren durch geringen abstand*)
IF arlErrechneteStillstandposition[cSTATION_204] >
   (arlErrechneteStillstandposition[cSTATION_208] - rgMkMinSecureDistanceInputShuttles)
  AND Foerderer204.Querfahrt.Antrieb.bpIstReferenziert
  AND Foerderer208.Querfahrt.Antrieb.bpIstReferenziert
THEN
  abggeschwindigkeitVerringern[cSTATION_204] := TRUE;
ELSE
  abggeschwindigkeitVerringern[cSTATION_204] := FALSE;	
END_IF

IF arlErrechneteStillstandposition[cSTATION_208] <
   (arlErrechneteStillstandposition[cSTATION_204] + rgMkMinSecureDistanceInputShuttles)
  AND Foerderer204.Querfahrt.Antrieb.bpIstReferenziert
  AND Foerderer208.Querfahrt.Antrieb.bpIstReferenziert
THEN
  abggeschwindigkeitVerringern[cSTATION_208] := TRUE;
ELSE
  abggeschwindigkeitVerringern[cSTATION_208] := FALSE;	 
END_IF



Zyklus := TIME() - TmStmp;
*)
END_PROGRAM