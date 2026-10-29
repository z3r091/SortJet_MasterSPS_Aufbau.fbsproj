(* METADATA
{
	"v3Meta": {
		"objectGuid": "37f6c3a9-3bba-4d57-9c53-2ef1e7be2c3a"
	}
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION: RESET *)
(***************************************************************************************************)

FOR wlIndexReset := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  IF ( abpReset[wlIndexReset] ) THEN

    abpReset[wlIndexReset] := FALSE;
    abpFehler[wlIndexReset] := FALSE;

    FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO

      IF StationInAutomatikkreis(starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wlIndexReset) THEN

        abpAbbruchAnlegeauftrag[wlIndex] := FALSE;

        AuftragsSpeicherStation[wlIndex].bpReset := TRUE;
        AuftragsSpeicherStation[wlIndex]();

        AuftragsdatenStation[wlIndex].wAuftrag := eStation_Kein_Auftrag;

        starrStationBasisParameter[wlIndex].bReset := TRUE;

        FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO

          AuftragsSpeicherWand[wlIndex,wlIndexWand].bpReset := TRUE;
          AuftragsSpeicherWand[wlIndex,wlIndexWand]();

          AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag := eStation_Kein_Auftrag;

          ailScheibenZuQuittierenEintransport[wlIndex, wlIndexWand] := 0;
          ailScheibenZuQuittierenAustransport[wlIndex, wlIndexWand] := 0;

          ablMerkerLetzteScheibeStation[wlIndex, wlIndexWand] := FALSE;

          ablFreigabeZurParalleleBausteinAnsteuerung[wlIndex,wlIndexWand] := FALSE;
          abpStarteParalleleBausteinAnsteuerung[wlIndex, wlIndexWand]     := FALSE;

        END_FOR

      END_IF

    END_FOR

  END_IF

END_FOR
END_ACTION