(* METADATA
{
  "v3Meta": {
    "objectGuid": "7b7fef86-43ad-4753-b6a4-4b3d917128e2"
  }
}
*)
ACTION ZylinderBewegung
//-------------------------------------------------------------------------------------------------
// BNAUSTEIN: STEUERUNG
//-------------------------------------------------------------------------------------------------

IF ( bpStartZylinderBewegung ) THEN

  CASE steplZylinderStellung OF
    // ZYLINDER STELLUNG =======================================================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder ausfahren starten
      *)
      bpDone := FALSE;

      tonlStellung13mm(IN := FALSE );
      tonlStellung23mm(IN := FALSE );
      tonlStellung29mm(IN := FALSE );

      tonlWartezeitZylinderStellung( IN := FALSE );

      steplZylinderStellung := STEP_10_E;

    // ZYLINDER STELLUNG =======================================================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      //  ZYLINDER ALLE EINFAHREN
      //
      //  Hinweis:
      //  - Es muessen erst alle Zylinder eingefahren sein bevor sie ausgefahren werden koennen
      // ---------------------------------------------------------------------------------------

      IF ( epStatusZylinderStellung <> eZylinderStellung16mm ) THEN
        out_bZylinder_1_Einfahren := TRUE;
        out_bZylinder_2_Einfahren := TRUE;

        out_bZylinder_1_Ausfahren := FALSE;
        out_bZylinder_2_Ausfahren := FALSE;

        tonlWartezeitZylinderStellung( IN := FALSE );

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
         - Mit Abfragen: Ueberwachungszeit 5s
         - Ohne Abfragen: Bewegungszeit abwarten, danach gilt die Stellung als eingefahren
      *)
      IF ( bpZylinderAbfragenVorhanden ) THEN
        tonlWartezeitZylinderStellung( IN := TRUE, PT := T#5S );
      ELSE
        tonlWartezeitZylinderStellung( IN := TRUE, PT := tpBewegungszeit );
      END_IF

      IF (    ( bpZylinderAbfragenVorhanden AND ( epStatusZylinderStellung = eZylinderStellung16mm ) )
           OR ( NOT bpZylinderAbfragenVorhanden AND tonlWartezeitZylinderStellung.Q ) )
      THEN

        out_bZylinder_1_Einfahren := FALSE;
        out_bZylinder_2_Einfahren := FALSE;

        out_bZylinder_1_Ausfahren := FALSE;
        out_bZylinder_2_Ausfahren := FALSE;

        tonlWartezeitZylinderStellung( IN := FALSE );

        IF ( NOT bpZylinderAbfragenVorhanden ) THEN
          epStatusZylinderStellung := eZylinderStellung16mm;
        END_IF

        steplZylinderStellung := STEP_100_E;

      END_IF

      IF ( bpZylinderAbfragenVorhanden AND tonlWartezeitZylinderStellung.Q ) THEN
        out_bZylinder_1_Einfahren := FALSE;
        out_bZylinder_2_Einfahren := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        steplZylinderStellung := STEP_900_E;
      END_IF

    // ZYLINDER STELLUNG =======================================================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  ZYLINDER AUF SOLL-POSITION BEWEGEN
      //
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      tonlWartezeitZylinderStellung( IN := FALSE );

      // Ohne Abfragen ist die Stellung bis zum Ende der Bewegungszeit unbekannt
      IF ( NOT bpZylinderAbfragenVorhanden ) THEN
        epStatusZylinderStellung := eZylinderUndefiniert;
      END_IF

      steplZylinderStellung := STEP_110_E;

      CASE epSollZylinderStellung OF

        eZylinderStellung16mm: 
          out_bZylinder_1_Einfahren := TRUE;
          out_bZylinder_2_Einfahren := TRUE;

          out_bZylinder_1_Ausfahren := FALSE;
          out_bZylinder_2_Ausfahren := FALSE;

        eZylinderStellung23mm:
          out_bZylinder_1_Einfahren := FALSE;
          out_bZylinder_2_Einfahren := TRUE;

          out_bZylinder_1_Ausfahren := TRUE;
          out_bZylinder_2_Ausfahren := FALSE;


        eZylinderStellung29mm:
          out_bZylinder_1_Einfahren := FALSE;
          out_bZylinder_2_Einfahren := FALSE;

          out_bZylinder_1_Ausfahren := TRUE;
          out_bZylinder_2_Ausfahren := TRUE;

        ELSE
          out_bZylinder_1_Einfahren := FALSE;
          out_bZylinder_2_Einfahren := FALSE;

          out_bZylinder_1_Ausfahren := FALSE;
          out_bZylinder_2_Ausfahren := FALSE;

          wpFehlerNr            := cMELDUNG_ZYLINDER_STELLUNG_UNGUELTIG;
          steplZylinderStellung := STEP_900_E;

      END_CASE

    // ZYLINDER STELLUNG =======================================================
    STEP_110_E:
      (* Hinweis:
         - wenn keine Abfragen verbaut sind, pauschal die Schaltung der Ventile zurücksetzen
      *)
      IF ( bpZylinderAbfragenVorhanden ) THEN
        steplZylinderStellung := STEP_200_E;

      ELSE

        tonlWartezeitZylinderStellung( IN := TRUE, PT := tpBewegungszeit );

        IF ( tonlWartezeitZylinderStellung.Q ) THEN

          out_bZylinder_1_Einfahren := FALSE;
          out_bZylinder_2_Einfahren := FALSE;

          out_bZylinder_1_Ausfahren := FALSE;
          out_bZylinder_2_Ausfahren := FALSE;

          steplZylinderStellung := STEP_1000_E;

        END_IF

      END_IF

    // ZYLINDER STELLUNG =======================================================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  SENSOREN PRUEFEN (ZYLINDERSTELLUNG)
      //
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      tonlStellung13mm(IN := NOT ( epStatusZylinderStellung = eZylinderStellung16mm ) , PT := T#5S);
      tonlStellung23mm(IN := NOT ( epStatusZylinderStellung = eZylinderStellung23mm ) , PT := T#5S);
      tonlStellung29mm(IN := NOT ( epStatusZylinderStellung = eZylinderStellung29mm ) , PT := T#5S);

      CASE epSollZylinderStellung OF

        eZylinderStellung16mm:
          IF ( epSollZylinderStellung = epStatusZylinderStellung ) THEN
            steplZylinderStellung := STEP_210_E;
          END_IF

          IF ( tonlStellung13mm.Q )THEN
            wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
            steplZylinderStellung := STEP_900_E;
          END_IF


        eZylinderStellung23mm:
          IF ( epSollZylinderStellung = epStatusZylinderStellung ) THEN
            steplZylinderStellung := STEP_210_E;
          END_IF

          IF ( tonlStellung23mm.Q )THEN
            wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
            steplZylinderStellung := STEP_900_E;
          END_IF


        eZylinderStellung29mm:
          IF ( epSollZylinderStellung = epStatusZylinderStellung ) THEN
            steplZylinderStellung := STEP_210_E;
          END_IF

          IF ( tonlStellung29mm.Q )THEN
            wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
            steplZylinderStellung := STEP_900_E;
          END_IF

      END_CASE

    // ZYLINDER STELLUNG =======================================================
    STEP_210_E:
      (* Hinweis:
         - Ausgaenge im zuruecksetzen
      *)
      out_bZylinder_1_Einfahren := FALSE;
      out_bZylinder_2_Einfahren := FALSE;

      out_bZylinder_1_Ausfahren := FALSE;
      out_bZylinder_2_Ausfahren := FALSE;

      steplZylinderStellung := STEP_1000_E;

    // ZYLINDER STELLUNG =======================================================
    STEP_900_E:
      (* Hinweis:
         - Ausgaenge im Fehlerfall zuruecksetzen
      *)
      out_bZylinder_1_Einfahren := FALSE;
      out_bZylinder_2_Einfahren := FALSE;

      out_bZylinder_1_Ausfahren := FALSE;
      out_bZylinder_2_Ausfahren := FALSE;

      bpFehler := TRUE;

    // ZYLINDER STELLUNG =======================================================
    STEP_1000_E:
      // Ohne Abfragen ist die Stellung zeitlich angenommen, nicht gemessen
      IF ( NOT bpZylinderAbfragenVorhanden ) THEN
        epStatusZylinderStellung := epSollZylinderStellung;
      END_IF
      bpDone := TRUE;

  // ZYLINDER STELLUNG =======================================================
  END_CASE

ELSE

  IF (steplZylinderStellung > STEP_0_E) THEN
    bpDone                   := FALSE;

    steplZylinderStellung := STEP_0_E;

    out_bZylinder_1_Einfahren := FALSE;
    out_bZylinder_2_Einfahren := FALSE;

    out_bZylinder_1_Ausfahren := FALSE;
    out_bZylinder_2_Ausfahren := FALSE;

    tonlStellung13mm( IN := FALSE );
    tonlStellung23mm( IN := FALSE );
    tonlStellung29mm( IN := FALSE );
    tonlWartezeitZylinderStellung( IN := FALSE );

  END_IF

END_IF
END_ACTION