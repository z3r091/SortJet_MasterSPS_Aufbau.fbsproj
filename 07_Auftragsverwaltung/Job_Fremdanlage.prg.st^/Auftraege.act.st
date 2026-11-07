(* METADATA
{
	"v3Meta": {
		"objectGuid": "c249d517-2d16-45f2-b7bc-658c62d8cf35"
	}
}
*)
ACTION Auftraege
//-------------------------------------------------------------------------------------------------
// AUFTRAG: M_SB0_MMI_ISOQUITTUNG
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Unabhaengige Quittung der Sondergläser durch Tasterdruck anfordern
*)
IF ( M_SB0_MMI_ISOQUITTUNG ) THEN
  M_SB0_MMI_ISOQUITTUNG:=FALSE;

  CASE tMmi2SpsInfo.wISOStation OF

    cERSTE_FREMDANLAGE..cLETZTE_FREMDANLAGE:
      aSchnittstelleAuslauf[tMmi2SpsInfo.wISOStation].wpAuftragsTyp := tMmi2SpsInfo.wISOAuftragsID;
      aSchnittstelleAuslauf[tMmi2SpsInfo.wISOStation].bpStarteIGEvent := TRUE;

  END_CASE

END_IF

//-------------------------------------------------------------------------------------------------
// AUFTRAG: M_SB0_MMI_SORTIERUNGCANCELISOLINEEVENT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   -  Abbruch des offenen ISO Line Events
*)

IF ( M_SB0_MMI_SORTIERUNGCANCELISOLINEEVENT ) THEN
  M_SB0_MMI_SORTIERUNGCANCELISOLINEEVENT := FALSE;

  CASE tMmi2SpsInfo.wDeleteISOLinienStationNr OF

    cERSTE_FREMDANLAGE..cLETZTE_FREMDANLAGE:
      aSchnittstelleAuslauf[tMmi2SpsInfo.wDeleteISOLinienStationNr].bpResetISOLinieEvent := TRUE;
      
  END_CASE

END_IF

//-------------------------------------------------------------------------------------------------
// AUFTRAG: M_SB0_MMI_AUFTRAGSDATEN_FREMDANLAGE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   -  Auftragsdaten fuer die Fremdanlage
*)
IF ( M_SB0_MMI_AUFTRAGSDATEN_FREMDANLAGE ) THEN
  M_SB0_MMI_AUFTRAGSDATEN_FREMDANLAGE := FALSE;


  CASE tMmi2SpsInfo.wFremdanlageNr OF

    cERSTE_FREMDANLAGE..cLETZTE_FREMDANLAGE:
      (* Hinweis:
         - Es folgt hier keine weitere Nachricht
      *)
      IF ( tMmi2SpsInfo.wNachrichtenAnzahl = 1 ) THEN
        stAuftragScheibenIDs.adwScheibenID_1 := ScheibenID(tMmi2SpsInfo.wFremdanlageNr, tMmi2SpsInfo.adwScheibenID_1);
        stAuftragScheibenIDs.adwScheibenID_2 := ScheibenID(tMmi2SpsInfo.wFremdanlageNr, tMmi2SpsInfo.adwScheibenID_2);
        stAuftragScheibenIDs.adwScheibenID_3 := ScheibenID(tMmi2SpsInfo.wFremdanlageNr, tMmi2SpsInfo.adwScheibenID_3);
        stAuftragScheibenIDs.adwScheibenID_4 := ScheibenID(tMmi2SpsInfo.wFremdanlageNr, tMmi2SpsInfo.adwScheibenID_4);

        aSchnittstelleAuslauf[tMmi2SpsInfo.wFremdanlageNr].AuftragsSpeicher.ppEingabeWert.wScheibenAnzahl := tMmi2SpsInfo.wScheibenanzahl;
        aSchnittstelleAuslauf[tMmi2SpsInfo.wFremdanlageNr].AuftragsSpeicher.ppEingabeWert.stScheibenID    := stAuftragScheibenIDs;
        aSchnittstelleAuslauf[tMmi2SpsInfo.wFremdanlageNr].AuftragsSpeicher( bpWerteSchreiben  := TRUE );

        stAuftragScheibenIDs.adwScheibenID_1[0]  := 0;
        stAuftragScheibenIDs.adwScheibenID_1[1]  := 0;
        stAuftragScheibenIDs.adwScheibenID_1[2]  := 0;
        stAuftragScheibenIDs.adwScheibenID_1[3]  := 0;
        stAuftragScheibenIDs.adwScheibenID_2[0]  := 0;
        stAuftragScheibenIDs.adwScheibenID_2[1]  := 0;
        stAuftragScheibenIDs.adwScheibenID_2[2]  := 0;
        stAuftragScheibenIDs.adwScheibenID_2[3]  := 0;
        stAuftragScheibenIDs.adwScheibenID_3[0]  := 0;
        stAuftragScheibenIDs.adwScheibenID_3[1]  := 0;
        stAuftragScheibenIDs.adwScheibenID_3[2]  := 0;
        stAuftragScheibenIDs.adwScheibenID_3[3]  := 0;
        stAuftragScheibenIDs.adwScheibenID_4[0]  := 0;
        stAuftragScheibenIDs.adwScheibenID_4[1]  := 0;
        stAuftragScheibenIDs.adwScheibenID_4[2]  := 0;
        stAuftragScheibenIDs.adwScheibenID_4[3]  := 0;
        stAuftragScheibenIDs.adwScheibenID_5[0]  := 0;
        stAuftragScheibenIDs.adwScheibenID_5[1]  := 0;
        stAuftragScheibenIDs.adwScheibenID_5[2]  := 0;
        stAuftragScheibenIDs.adwScheibenID_5[3]  := 0;
        stAuftragScheibenIDs.adwScheibenID_6[0]  := 0;
        stAuftragScheibenIDs.adwScheibenID_6[1]  := 0;
        stAuftragScheibenIDs.adwScheibenID_6[2]  := 0;
        stAuftragScheibenIDs.adwScheibenID_6[3]  := 0;

      (* Hinweis:
         - Es muss nicht noch auf eine Nachricht gewartet werden
      *)
      ELSE

        blUeberwachungFolgeNachricht := TRUE;

        CASE tMmi2SpsInfo.wNachrichtenIndex OF

          cNACHRICHTEN_INDEX_1:
            ablNachrichtEmpfangen[1] := TRUE;

            stAuftragScheibenIDs.adwScheibenID_1 := ScheibenID(tMmi2SpsInfo.wFremdanlageNr, tMmi2SpsInfo.adwScheibenID_1);
            stAuftragScheibenIDs.adwScheibenID_2 := ScheibenID(tMmi2SpsInfo.wFremdanlageNr, tMmi2SpsInfo.adwScheibenID_2);
            stAuftragScheibenIDs.adwScheibenID_3 := ScheibenID(tMmi2SpsInfo.wFremdanlageNr, tMmi2SpsInfo.adwScheibenID_3);
            stAuftragScheibenIDs.adwScheibenID_4 := ScheibenID(tMmi2SpsInfo.wFremdanlageNr, tMmi2SpsInfo.adwScheibenID_4);

          cNACHRICHTEN_INDEX_2:
            ablNachrichtEmpfangen[2] := TRUE;

            // Zweite Nachricht: Scheiben-ID 1 und 2 enthalten die Scheiben 5 und 6
            stAuftragScheibenIDs.adwScheibenID_5 := ScheibenID(tMmi2SpsInfo.wFremdanlageNr, tMmi2SpsInfo.adwScheibenID_1);
            stAuftragScheibenIDs.adwScheibenID_6 := ScheibenID(tMmi2SpsInfo.wFremdanlageNr, tMmi2SpsInfo.adwScheibenID_2);

          ELSE
            wpgFehlerdaten[0] := tMmi2SpsInfo.wNachrichtenIndex;
            SpsWarnung( eFehler_Schnittstelle,
                        cMELDUNG_SCHNITTSTELLE_AUFTRAGSDATEN_SCHNITTSTELLE_NACHRICHTENINDEX_FEHLERHAFT,
                        tMmi2SpsInfo.wNachrichtenIndex,
                        AutomatikkreisBestimmen(0),
                        wpgFehlerdaten );

        END_CASE


        (* Hinweis:
           - Werte zuruecksetzen wenn alle Nachrichten Empfangen worden sind
        *)
        IF (  ablNachrichtEmpfangen[1]
             AND ablNachrichtEmpfangen[2] )
        THEN
          aSchnittstelleAuslauf[tMmi2SpsInfo.wFremdanlageNr].AuftragsSpeicher.ppEingabeWert.stScheibenID    := stAuftragScheibenIDs;
          aSchnittstelleAuslauf[tMmi2SpsInfo.wFremdanlageNr].AuftragsSpeicher.ppEingabeWert.wScheibenAnzahl := tMmi2SpsInfo.wScheibenanzahl;
          aSchnittstelleAuslauf[tMmi2SpsInfo.wFremdanlageNr].AuftragsSpeicher( bpWerteSchreiben  := TRUE );
  
          stAuftragScheibenIDs.adwScheibenID_1[0]  := 0;
          stAuftragScheibenIDs.adwScheibenID_1[1]  := 0;
          stAuftragScheibenIDs.adwScheibenID_1[2]  := 0;
          stAuftragScheibenIDs.adwScheibenID_1[3]  := 0;
          stAuftragScheibenIDs.adwScheibenID_2[0]  := 0;
          stAuftragScheibenIDs.adwScheibenID_2[1]  := 0;
          stAuftragScheibenIDs.adwScheibenID_2[2]  := 0;
          stAuftragScheibenIDs.adwScheibenID_2[3]  := 0;
          stAuftragScheibenIDs.adwScheibenID_3[0]  := 0;
          stAuftragScheibenIDs.adwScheibenID_3[1]  := 0;
          stAuftragScheibenIDs.adwScheibenID_3[2]  := 0;
          stAuftragScheibenIDs.adwScheibenID_3[3]  := 0;
          stAuftragScheibenIDs.adwScheibenID_4[0]  := 0;
          stAuftragScheibenIDs.adwScheibenID_4[1]  := 0;
          stAuftragScheibenIDs.adwScheibenID_4[2]  := 0;
          stAuftragScheibenIDs.adwScheibenID_4[3]  := 0;
          stAuftragScheibenIDs.adwScheibenID_5[0]  := 0;
          stAuftragScheibenIDs.adwScheibenID_5[1]  := 0;
          stAuftragScheibenIDs.adwScheibenID_5[2]  := 0;
          stAuftragScheibenIDs.adwScheibenID_5[3]  := 0;
          stAuftragScheibenIDs.adwScheibenID_6[0]  := 0;
          stAuftragScheibenIDs.adwScheibenID_6[1]  := 0;
          stAuftragScheibenIDs.adwScheibenID_6[2]  := 0;
          stAuftragScheibenIDs.adwScheibenID_6[3]  := 0;

          ablNachrichtEmpfangen[1]     := FALSE;
          ablNachrichtEmpfangen[2]     := FALSE;
          blUeberwachungFolgeNachricht := FALSE;

        END_IF

      END_IF

    ELSE
      ;

  END_CASE

END_IF
END_ACTION