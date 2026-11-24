(* METADATA
{
	"v3Meta": {
		"objectGuid": "56bf71f0-8888-442d-bc10-aa3219eb5fdb"
	}
}
*)
ACTION Tueren
//-------------------------------------------------------------------------------------------------
// Zuweisungen/ Schnittstelle zu den Bausteinen[ Tuer/Durchgang <-> Sicherheitskreis ]
//-------------------------------------------------------------------------------------------------

// Anfordern Sicherheitskreis auslösen
FOR wlIndexSK := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO

  Sicherheitskreis[wlIndexSK].bpAnforderungSicherheitkreisAusloesen := FALSE;

  // Externe Anforderung unabhängig von Türen
  IF ablSicherheitskreisAnfordernExtern[wlIndexSK] THEN
    Sicherheitskreis[wlIndexSK].bpAnforderungSicherheitkreisAusloesen := TRUE;
  END_IF

  // Tür - Anforderung zum öffnen des Sicherheitskreises
  FOR wlIndex := cERSTE_TUER TO cLETZTE_TUER DO
    FOR wlIndexTuer := cERSTE_TUER TO cLETZTE_TUER DO
      IF ( apgMKSicherheiskreis[wlIndexSK].eaTueren[wlIndex] = wlIndexTuer ) THEN
        IF aTuer[wlIndexTuer].bpAnforderungZumTuerOffnenGestellt THEN
          Sicherheitskreis[wlIndexSK].bpAnforderungSicherheitkreisAusloesen := TRUE;
        END_IF
      END_IF
    END_FOR
  END_FOR

  // Durchgang - Anforderung zum öffnen des Sicherheitskreises
  FOR wlIndex := cERSTER_DURCHGANG TO cLETZTER_DURCHGANG DO
    FOR wlIndexDurchgang := cERSTER_DURCHGANG TO cLETZTER_DURCHGANG DO
      IF ( apgMKSicherheiskreis[wlIndexSK].eaDurchgang[wlIndex] = wlIndexDurchgang ) THEN
        // Übergabe an Durchgang -> SK geschlossen
        aDurchgang[wlIndexDurchgang].bpSKGeschlossen := Sicherheitskreis[wlIndexSK].bpSicherheitskreisGeschlossen;

        IF aDurchgang[wlIndexDurchgang].bpAnforderungZumDurchgangOffnenGestellt THEN
          Sicherheitskreis[wlIndexSK].bpAnforderungSicherheitkreisAusloesen := TRUE;
        END_IF
      END_IF
    END_FOR
  END_FOR

END_FOR

// Freigabe Türen öffnen
FOR wlIndexSK := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO

  // Tür
  FOR wlIndex := cERSTE_TUER TO cLETZTE_TUER DO
    FOR wlIndexTuer := cERSTE_TUER TO cLETZTE_TUER DO
      IF ( apgMKSicherheiskreis[wlIndexSK].eaTueren[wlIndex] = wlIndexTuer ) THEN
        aTuer[wlIndexTuer].bpFreigabeZumOeffnenDerTuer := Sicherheitskreis[wlIndexSK].bpFreigabeTuerenOeffnen;
      END_IF
    END_FOR
  END_FOR

  // Durchgang
  FOR wlIndex := cERSTER_DURCHGANG TO cLETZTER_DURCHGANG DO
    FOR wlIndexDurchgang := cERSTER_DURCHGANG TO cLETZTER_DURCHGANG DO
      IF ( apgMKSicherheiskreis[wlIndexSK].eaDurchgang[wlIndex] = wlIndexDurchgang ) THEN
        aDurchgang[wlIndexDurchgang].bpFreigabeZumOeffnenDurchgang := Sicherheitskreis[wlIndexSK].bpFreigabeTuerenOeffnen;
      END_IF
    END_FOR
  END_FOR

END_FOR


// Zuweisung Sicherheitskreis
FOR wlIndexSK := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO

  // Tür
  FOR wlIndex := cERSTE_TUER TO cLETZTE_TUER DO
    FOR wlIndexTuer := cERSTE_TUER TO cLETZTE_TUER DO
      IF ( apgMKSicherheiskreis[wlIndexSK].eaTueren[wlIndex] = wlIndexTuer ) THEN
        aTuer[wlIndexTuer].wSicherheitskreis := apgMKSicherheiskreis[wlIndexSK].eSicherheitskreis;
      END_IF
    END_FOR
  END_FOR

  // Durchgang
  FOR wlIndex := cERSTER_DURCHGANG TO cLETZTER_DURCHGANG DO
    FOR wlIndexDurchgang := cERSTER_DURCHGANG TO cLETZTER_DURCHGANG DO
      IF ( apgMKSicherheiskreis[wlIndexSK].eaDurchgang[wlIndex] = wlIndexDurchgang ) THEN
        aDurchgang[wlIndexDurchgang].wSicherheitskreis := apgMKSicherheiskreis[wlIndexSK].eSicherheitskreis;
      END_IF
    END_FOR
  END_FOR

END_FOR


// Anzeige über die blaue Leuchte, dass diese und eine weitere Tür geöffnet ist oder die Stromschiene noch abgeschaltet ist
FOR wlIndexTuer := cERSTE_TUER TO cLETZTE_TUER DO
  aTuer[wlIndexTuer].bpWeitereTuerenGeoeffnet := FALSE;

  // Tür
  FOR wlIndex := cERSTE_TUER TO cLETZTE_TUER DO
    IF ( aTuer[wlIndexTuer].wSicherheitskreis = aTuer[wlIndex].wSicherheitskreis )
       AND NOT ( wlIndexTuer = wlIndex )
       AND aTuer[wlIndex].bpStatusTuerNichtGeschlossen
    THEN
      aTuer[wlIndexTuer].bpWeitereTuerenGeoeffnet := TRUE;
    END_IF
  END_FOR

END_FOR
END_ACTION