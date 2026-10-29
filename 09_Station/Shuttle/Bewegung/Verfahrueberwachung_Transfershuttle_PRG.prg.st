(* METADATA
{
	"v3Meta": {
		"objectGuid": "e6880982-6180-4ce8-b7d2-e8ad78a8f219"
	}
}
*)
PROGRAM Verfahrueberwachung_Transfershuttle_PRG
VAR

  (* BOOLEAN *)
  blErsterZyklus                            : BOOL := TRUE;
  ablShuttleInParkpos                       : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL;  (* Die Verzögerung wird in 10tel mm/s² üebergeben, wir benötigen mm/s² *)
  ablShuttleStehtOhnePositionsveraenderung  : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL;
  ablShuttleVerfaehrt                       : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL  :=[ 0]; (* Hinweis: Initialisiert muss dieses Array mit 0 [je Index] *)

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
  arlAktuelleGeschwindigkeit               : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlErrechneteGeschwindigkeit             : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlBerechneterBremsWeg                   : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlAltePosition                          : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlNeuePosition                          : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlPostionsveraenderung                  : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlErrechneteStillstandposition          : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlVerzoegerung                          : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; (* Sollte das Shuttle bei aktueller Geschwindigkeit sofort bremsen, dann würde es an dieser Stelle zum stehen kommen *)
  arlShutleParkposition                    : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; (* Das Shuttle ist in Parkposition, das Gegenshuttle darf näher fahren *)
  arlBremsfaktor                           : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; (* Parkpositonen in ein Array übertragen *)
  arlAktuellerSicherheitsabstand           : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL;
  arlPostionsMittelwert                    : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; (* Die Geschwindigkeitsrichtig mit der das Shuttle in seine Parkposition hinein fährt *)
  arpGeschwindigkeitInRichtungParkposition : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL :=[ -1]; (* -1, 1, -1, 1, -1, 1, -1, 1; *)
  arlActPosShuttle                         : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; (* Aktuelle Position in mm (festgelegt in S-0-0076, Wichtungsart für Lagedaten) *)
  arlActGeschwindigkeit                    : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF REAL; (* aktuelle Geschwindigkeit in m/min (festgelegt in S-0-0044, Wichtungsart für Geschwindigkeitsdaten) *)
  arrParkpositionen                        : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF Parkpositionen_ST;


  (* STRUCT *)
  astlSpeicher : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE,0..100] OF Verfahrueberwachung_ST; (* Die errechneten Variablen speichern um die Ergebnisse nachvollziehen zu können *)

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

END_VAR
(* Hinweis:
   - Dieser Baustein soll eine Stillstandsposition von fahrenden Shuttlen errechnen um eine
     drohende Kollision zweier Shuttle voraus zu berechnen.
   - Die berechneten Einheiten sollen in mm und s sein.
*)

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
     => Inputshuttle \ Outputshuttle \ Transfershuttle 
*)
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO


  IF ( apgTransfershuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MAX
    OR apgTransfershuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN
    OR apgTransfershuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN_MAX )
  THEN

    arrParkpositionen[wlIndex].eParkposition        := apgTransfershuttleVerfahrparameter[wlIndex].eParkposition;
    arrParkpositionen[wlIndex].rParkpositionMaximum := apgTransfershuttleVerfahrparameter[wlIndex].rParkpositionMaximum;
    arrParkpositionen[wlIndex].rParkpositionMinimum := apgTransfershuttleVerfahrparameter[wlIndex].rParkpositionMinimum;

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


(***************************************************************************************************)
(* BAUSTEIN: MASCHINENKONSTANTEN *)
(***************************************************************************************************)
(* Hinwesi
   - Maschinenkonstanten für die Verzögerung in 10tel mm in das Array übernehmen und in mm umwandeln 
*)
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  arlVerzoegerung[wlIndex]   := apgVerfahrueberwachungTransfershuttle[wlIndex].rMaxVerzoegerungsRampeUeberwachung;
END_FOR


(***************************************************************************************************)
(* BAUSTEIN: ZUWEISUNGEN *)
(***************************************************************************************************)
(* Hinweis:
   - Die vom Bus übertragenen Werte übernehmen und in auswertbare Zahlen umwandeln 
   - Das erste Shuttle bekommt in diesem Fall immer eine negative Position
     => Gerader Zaehler = Positive Zahl
     => Ungerader Zaehler = Negative Zahl
   Wichtig:
   - Zaehler [ilZaehler] muss bei 1 anfangen
*)
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO

  IF ( NOT starrTransfershuttleBasisParameter[wlIndex].stMKs.bDeaktivieren ) THEN
    arlActPosShuttle[wlIndex]      := aTransferShuttles[wlIndex].Querfahrt.rpAktPosition;
    arlActGeschwindigkeit[wlIndex] := aTransferShuttles[wlIndex].Querfahrt.rpAktSpeed;

  ELSE

    IF ( apgTransfershuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MAX ) THEN
      arlActPosShuttle[wlIndex]      := 10000.0;
      arlActGeschwindigkeit[wlIndex] := 0;

    ELSIF ( apgTransfershuttleVerfahrparameter[wlIndex].eParkposition = PARKPOSITION_MIN ) THEN
      arlActPosShuttle[wlIndex]      :=  -10000.0;
      arlActGeschwindigkeit[wlIndex] := 0;

    ELSE
      arlActPosShuttle[wlIndex]      := -10000.0;
      arlActGeschwindigkeit[wlIndex] := 0;

    END_IF

  END_IF

END_FOR

(***************************************************************************************************)
(* BAUSTEIN: UEBERWACHUNG *)
(***************************************************************************************************)
FOR wlIndex := cERSTES_TRANSFERSHUTTLE  TO cLETZTES_TRANSFERSHUTTLE DO

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
        ABS(arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMinimum) < 100 (* im Bereich der Parkposition *)
        AND (ABS(arlPostionsMittelwert[wlIndex] - arlNeuePosition[wlIndex]) < 2  ); (* das Shuttle steht *)


    PARKPOSITION_MAX:
      ablShuttleInParkpos[wlIndex] :=
        ABS(arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMaximum) < 100 (* im Bereich der Parkposition *)
        AND (ABS(arlPostionsMittelwert[wlIndex] - arlNeuePosition[wlIndex]) < 2  ); (* das Shuttle steht *)


    PARKPOSITION_MIN_MAX:
      ablShuttleInParkpos[wlIndex] :=
        (
             ( ABS(arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMinimum) < 100 )
          OR ( ABS(arlErrechneteStillstandposition[wlIndex] - arrParkpositionen[wlIndex].rParkpositionMaximum) < 100 )
        )  (* im Bereich der Parkposition *)
        AND (ABS(arlPostionsMittelwert[wlIndex] - arlNeuePosition[wlIndex]) < 2  ); (* das Shuttle steht *)

  END_CASE

END_FOR



(***************************************************************************************************)
(* BAUSTEIN: PARKPOSITION *)
(***************************************************************************************************)
(* Hinweis:
   - Wenn das Gegenshuttle in der Parkpositon ist, ist der Minimumabstand geringer 
*)
(*
(* Transfershuttle 151 <-> 152 *)
IF ( ablShuttleInParkpos[cSHUTTLE_151] OR ablShuttleInParkpos[cSHUTTLE_152] ) THEN
  arlAktuellerSicherheitsabstand[cSHUTTLE_151] := rgMkMinSecureDistanceTransferAtParkPos;
  arlAktuellerSicherheitsabstand[cSHUTTLE_152] := rgMkMinSecureDistanceTransferAtParkPos;
ELSE
  arlAktuellerSicherheitsabstand[cSHUTTLE_151] := rgMkMinSecureDistanceTransfer;
  arlAktuellerSicherheitsabstand[cSHUTTLE_152] := rgMkMinSecureDistanceTransfer;
END_IF

(* Transfershuttle 153 <-> 154 *)
IF ( ablShuttleInParkpos[cSHUTTLE_153] OR ablShuttleInParkpos[cSHUTTLE_154] ) THEN
  arlAktuellerSicherheitsabstand[cSHUTTLE_153] := rgMkMinSecureDistanceTransferAtParkPos;
  arlAktuellerSicherheitsabstand[cSHUTTLE_154] := rgMkMinSecureDistanceTransferAtParkPos;
ELSE
  arlAktuellerSicherheitsabstand[cSHUTTLE_153] := rgMkMinSecureDistanceTransfer;
  arlAktuellerSicherheitsabstand[cSHUTTLE_154] := rgMkMinSecureDistanceTransfer;
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
   - Transfershuttle 151 <-> 152
*)
(*
IF arlErrechneteStillstandposition[cSHUTTLE_151] >
   (arlErrechneteStillstandposition[cSHUTTLE_152] - arlAktuellerSicherheitsabstand[cSHUTTLE_151])
  AND aTransfershuttles[cSHUTTLE_151].Querfahrt.Antrieb.bpIstReferenziert
  AND aTransfershuttles[cSHUTTLE_152].Querfahrt.Antrieb.bpIstReferenziert
THEN
  abgVerfahrfreigabeShuttle[cSHUTTLE_151] := FALSE;
END_IF
IF arlErrechneteStillstandposition[cSHUTTLE_152] <
   (arlErrechneteStillstandposition[cSHUTTLE_151] + arlAktuellerSicherheitsabstand[cSHUTTLE_152])
  AND aTransfershuttles[cSHUTTLE_151].Querfahrt.Antrieb.bpIstReferenziert
  AND aTransfershuttles[cSHUTTLE_152].Querfahrt.Antrieb.bpIstReferenziert
THEN
  abgVerfahrfreigabeShuttle[cSHUTTLE_152] := FALSE;
END_IF


(* Hinweis:
   - Transfershuttle 153 <-> 154
*)
IF arlErrechneteStillstandposition[cSHUTTLE_153] >
   (arlErrechneteStillstandposition[cSHUTTLE_154] - arlAktuellerSicherheitsabstand[cSHUTTLE_153])
  AND aTransfershuttles[cSHUTTLE_153].Verfahrauftraege.Antrieb.bpIstReferenziert
  AND aTransfershuttles[cSHUTTLE_154].Verfahrauftraege.Antrieb.bpIstReferenziert
THEN
  abgVerfahrfreigabeShuttle[cSHUTTLE_152] := FALSE;
END_IF

IF arlErrechneteStillstandposition[cSHUTTLE_154] <
   (arlErrechneteStillstandposition[cSHUTTLE_153] + arlAktuellerSicherheitsabstand[cSHUTTLE_154])
  AND aTransfershuttles[cSHUTTLE_153].Verfahrauftraege.Antrieb.bpIstReferenziert
  AND aTransfershuttles[cSHUTTLE_154].Verfahrauftraege.Antrieb.bpIstReferenziert
THEN
  abgVerfahrfreigabeShuttle[cSHUTTLE_154] := FALSE;
END_IF
*)
END_PROGRAM