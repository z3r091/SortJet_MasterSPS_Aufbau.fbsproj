(* METADATA
{
  "v3Meta": {
    "objectGuid": "31ddb79b-bc55-40d4-9ada-545629857e9d"
  }
}
*)
ACTION ZylinderBewegung
//-------------------------------------------------------------------------------------------------
// AKTION: ZYLINDERBEWEGUNG
//-------------------------------------------------------------------------------------------------

IF ( bpStartZylinderBewegung ) THEN

  CASE steplZylinderStellung OF
    // ZYLINDER STELLUNG =======================================================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
      *)
      bpDone := FALSE;

      tonlUeberwachungStellung( IN := FALSE );
      tonlWartezeitZylinderStellung( IN := FALSE );

      steplZylinderStellung := STEP_10_E;

    // ZYLINDER STELLUNG =======================================================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      //  ZYLINDER ALLE EINFAHREN
      //
      //  Hinweis:
      //  - Vor dem Oeffnen muessen alle Zylinder eingefahren sein
      //  - Beim Schliessen direkt in die Soll-Stellung
      // ---------------------------------------------------------------------------------------

      IF (     ( epSollZylinderStellung <> eZylinderGeschlossen )
           AND ( epSollZylinderStellung <> epStatusZylinderStellung ) )
      THEN
        out_bZylinder_1_Einfahren := TRUE;
        out_bZylinder_2_Einfahren := TRUE;
        out_bZylinder_3_Einfahren := TRUE;

        out_bZylinder_1_Ausfahren := FALSE;
        out_bZylinder_2_Ausfahren := FALSE;
        out_bZylinder_3_Ausfahren := FALSE;

        // Ohne Abfragen ist die Stellung bis zum Ende der Bewegungszeit unbekannt
        IF ( NOT bpZylinderAbfragenVorhanden ) THEN
          epStatusZylinderStellung := eZylinderUndefiniert;
        END_IF

        steplZylinderStellung := STEP_20_E;

      ELSE
        steplZylinderStellung := STEP_100_E;

      END_IF

    // ZYLINDER STELLUNG =======================================================
    STEP_20_E:
      (* Hinweis:
         - Mit Abfragen: auf die Meldung "alle eingefahren" warten (Zeitueberwachung)
         - Ohne Abfragen: Bewegungszeit abwarten
      *)
      tonlUeberwachungStellung( IN := bpZylinderAbfragenVorhanden, PT := cZEIT_UEBERWACHUNG_STELLUNG );
      tonlWartezeitZylinderStellung( IN := NOT bpZylinderAbfragenVorhanden, PT := tpBewegungszeit );

      IF (    ( bpZylinderAbfragenVorhanden AND in_bStatusZylinder_Alle_Eingefahren )
           OR ( NOT bpZylinderAbfragenVorhanden AND tonlWartezeitZylinderStellung.Q ) )
      THEN
        out_bZylinder_1_Einfahren := FALSE;
        out_bZylinder_2_Einfahren := FALSE;
        out_bZylinder_3_Einfahren := FALSE;

        tonlUeberwachungStellung( IN := FALSE );
        tonlWartezeitZylinderStellung( IN := FALSE );

        steplZylinderStellung := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche Ueberwachung (nur mit Abfragen)
      *)
      IF ( tonlUeberwachungStellung.Q ) THEN
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        steplZylinderStellung := STEP_900_E;
      END_IF

    // ZYLINDER STELLUNG =======================================================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  ZYLINDER AUF SOLL-STELLUNG BEWEGEN
      //
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      tonlUeberwachungStellung( IN := FALSE );
      tonlWartezeitZylinderStellung( IN := FALSE );

      IF ( NOT bpZylinderAbfragenVorhanden ) THEN
        epStatusZylinderStellung := eZylinderUndefiniert;
      END_IF

      steplZylinderStellung := STEP_110_E;

      CASE epSollZylinderStellung OF

        eZylinderGeschlossen:
          out_bZylinder_1_Einfahren := TRUE;
          out_bZylinder_2_Einfahren := TRUE;
          out_bZylinder_3_Einfahren := TRUE;

          out_bZylinder_1_Ausfahren := FALSE;
          out_bZylinder_2_Ausfahren := FALSE;
          out_bZylinder_3_Ausfahren := FALSE;

        eZylinderStellung16mm:
          out_bZylinder_1_Einfahren := FALSE;
          out_bZylinder_2_Einfahren := FALSE;
          out_bZylinder_3_Einfahren := FALSE;

          out_bZylinder_1_Ausfahren := TRUE;
          out_bZylinder_2_Ausfahren := FALSE;
          out_bZylinder_3_Ausfahren := FALSE;

        eZylinderStellung23mm:
          out_bZylinder_1_Einfahren := FALSE;
          out_bZylinder_2_Einfahren := FALSE;
          out_bZylinder_3_Einfahren := FALSE;

          out_bZylinder_1_Ausfahren := FALSE;
          out_bZylinder_2_Ausfahren := TRUE;
          out_bZylinder_3_Ausfahren := FALSE;

        eZylinderStellung29mm:
          out_bZylinder_1_Einfahren := FALSE;
          out_bZylinder_2_Einfahren := FALSE;
          out_bZylinder_3_Einfahren := FALSE;

          out_bZylinder_1_Ausfahren := FALSE;
          out_bZylinder_2_Ausfahren := FALSE;
          out_bZylinder_3_Ausfahren := TRUE;

        ELSE
          out_bZylinder_1_Einfahren := FALSE;
          out_bZylinder_2_Einfahren := FALSE;
          out_bZylinder_3_Einfahren := FALSE;

          out_bZylinder_1_Ausfahren := FALSE;
          out_bZylinder_2_Ausfahren := FALSE;
          out_bZylinder_3_Ausfahren := FALSE;

          wpFehlerNr            := cMELDUNG_ZYLINDER_STELLUNG_UNGUELTIG;
          steplZylinderStellung := STEP_900_E;

      END_CASE

    // ZYLINDER STELLUNG =======================================================
    STEP_110_E:
      (* Hinweis:
         - Schliessen: Glas zwischen den Backen verhindert die Endlage, daher immer nur Bewegungszeit
         - Oeffnen mit Abfragen: auf die Soll-Stellung warten (Zeitueberwachung)
         - Oeffnen ohne Abfragen: Bewegungszeit abwarten
      *)
      IF ( bpZylinderAbfragenVorhanden AND ( epSollZylinderStellung <> eZylinderGeschlossen ) ) THEN

        tonlUeberwachungStellung( IN := TRUE, PT := cZEIT_UEBERWACHUNG_STELLUNG );

        IF ( epStatusZylinderStellung = epSollZylinderStellung ) THEN
          tonlUeberwachungStellung( IN := FALSE );
          steplZylinderStellung := STEP_210_E;
        END_IF

        (* Fehlerbehandlung:
           - Zeitliche Ueberwachung
        *)
        IF ( tonlUeberwachungStellung.Q ) THEN
          wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
          steplZylinderStellung := STEP_900_E;
        END_IF

      ELSE

        tonlWartezeitZylinderStellung( IN := TRUE, PT := tpBewegungszeit );

        IF ( tonlWartezeitZylinderStellung.Q ) THEN
          tonlWartezeitZylinderStellung( IN := FALSE );
          steplZylinderStellung := STEP_210_E;
        END_IF

      END_IF

    // ZYLINDER STELLUNG =======================================================
    STEP_210_E:
      (* Hinweis:
         - Ausgaenge zuruecksetzen (Impulsventile)
      *)
      out_bZylinder_1_Einfahren := FALSE;
      out_bZylinder_2_Einfahren := FALSE;
      out_bZylinder_3_Einfahren := FALSE;

      out_bZylinder_1_Ausfahren := FALSE;
      out_bZylinder_2_Ausfahren := FALSE;
      out_bZylinder_3_Ausfahren := FALSE;

      steplZylinderStellung := STEP_1000_E;

    // ZYLINDER STELLUNG =======================================================
    STEP_900_E:
      (* Hinweis:
         - Ausgaenge im Fehlerfall zuruecksetzen
      *)
      out_bZylinder_1_Einfahren := FALSE;
      out_bZylinder_2_Einfahren := FALSE;
      out_bZylinder_3_Einfahren := FALSE;

      out_bZylinder_1_Ausfahren := FALSE;
      out_bZylinder_2_Ausfahren := FALSE;
      out_bZylinder_3_Ausfahren := FALSE;

      bpFehler := TRUE;

    // ZYLINDER STELLUNG =======================================================
    STEP_1000_E:
      // Ohne Abfragen bzw. beim Schliessen auf Glas ist die Stellung zeitlich angenommen, nicht gemessen
      IF (    NOT bpZylinderAbfragenVorhanden
           OR ( epSollZylinderStellung = eZylinderGeschlossen ) )
      THEN
        epStatusZylinderStellung := epSollZylinderStellung;
      END_IF
      bpDone := TRUE;

  // ZYLINDER STELLUNG =======================================================
  END_CASE

ELSE

  IF ( steplZylinderStellung > STEP_0_E ) THEN
    bpDone := FALSE;

    out_bZylinder_1_Einfahren := FALSE;
    out_bZylinder_2_Einfahren := FALSE;
    out_bZylinder_3_Einfahren := FALSE;

    out_bZylinder_1_Ausfahren := FALSE;
    out_bZylinder_2_Ausfahren := FALSE;
    out_bZylinder_3_Ausfahren := FALSE;

    tonlUeberwachungStellung( IN := FALSE );
    tonlWartezeitZylinderStellung( IN := FALSE );

    steplZylinderStellung := STEP_0_E;
  END_IF

END_IF
END_ACTION