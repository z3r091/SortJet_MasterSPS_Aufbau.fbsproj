(* METADATA
{
  "v3Meta": {
    "objectGuid": "5ce4686b-6dc1-45ac-a400-bd96dddf05f1"
  }
}
*)
ACTION AusEinFahren
//_________________________________________________________________________
// ****************** START Zylinder - Aus- & Einfahren ********************
//_________________________________________________________________________
IF (  bpStartPneumatik )
THEN
  CASE steplAusfahren OF
    // AUS - &  EINFAHREN =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder ausfahren starten
      *)
      tonlZylinder1Ausgefahren(IN := FALSE);
      tonlZylinder1Eingefahren(IN := FALSE);
      tonlZylinder2Ausgefahren(IN := FALSE);
      tonlZylinder2Eingefahren(IN := FALSE);
      tonlWarteZeitAufVentile(IN := FALSE);

      // Ohne Abfragen ist die Stellung bis zum Ende der Wartezeit unbekannt
      IF NOT bpZylinderAbfragenVorhanden THEN
        wpStatusZylinder := eZylinderUndefiniert;
      END_IF

      steplAusfahren := STEP_10_E;


    // AUS - &  EINFAHREN =====================
    STEP_10_E:

      (* Hinweis:
         - Geschlossen = 16 mm, Geoeffnet = 29 mm
         - Mit nur einem Zylinder gibt es keine mittlere Stellung, 23 mm gilt dann als geoeffnet
      *)
      elStellung := epOeffnungsStellung;

      IF ( elStellung = eZylinderGeschlossen ) THEN
        elStellung := eZylinderStellung16mm;
      ELSIF ( elStellung = eZylinderGeoeffnet ) THEN
        elStellung := eZylinderStellung29mm;
      END_IF

      IF ( NOT bpZweiterZylinderVorhanden AND ( elStellung = eZylinderStellung23mm ) ) THEN
        elStellung := eZylinderStellung29mm;
      END_IF

      CASE elStellung OF
          eZylinderStellung16mm :
          IF bpEinAusFahrenLogikDrehen THEN
            out_bZylinder1Ausfahren     := TRUE;
            out_bZylinder1Einfahren     := FALSE;
            out_bZylinder2Ausfahren     := TRUE;
            out_bZylinder2Einfahren     := FALSE;
          ELSE
            out_bZylinder1Ausfahren     := FALSE;
            out_bZylinder1Einfahren     := TRUE;
            out_bZylinder2Ausfahren     := FALSE;
            out_bZylinder2Einfahren     := TRUE;
          END_IF

        eZylinderStellung23mm :
          IF bpEinAusFahrenLogikDrehen THEN
            out_bZylinder1Einfahren     := TRUE;
            out_bZylinder1Ausfahren     := FALSE;
            out_bZylinder2Einfahren     := FALSE;
            out_bZylinder2Ausfahren     := TRUE;
          ELSE
            out_bZylinder1Ausfahren     := TRUE;
            out_bZylinder1Einfahren     := FALSE;
            out_bZylinder2Ausfahren     := FALSE;
            out_bZylinder2Einfahren     := TRUE;
          END_IF

        eZylinderStellung29mm :
          IF bpEinAusFahrenLogikDrehen THEN
            out_bZylinder1Ausfahren     := FALSE;
            out_bZylinder1Einfahren     := TRUE;
            out_bZylinder2Ausfahren     := FALSE;
            out_bZylinder2Einfahren     := TRUE;
          ELSE
            out_bZylinder1Ausfahren     := TRUE;
            out_bZylinder1Einfahren     := FALSE;
            out_bZylinder2Ausfahren     := TRUE;
            out_bZylinder2Einfahren     := FALSE;
          END_IF


      END_CASE

      IF ( NOT bpZweiterZylinderVorhanden ) THEN
        out_bZylinder2Ausfahren := FALSE;
        out_bZylinder2Einfahren := FALSE;
      END_IF

      steplAusfahren := STEP_20_E;



    // AUS - &  EINFAHREN =====================
    STEP_20_E:
      (* Hinweis:
         - wenn keine Abfragen verbaut sind, pauschal die Schaltung der Ventile zurücksetzen
      *)
      tonlWarteZeitAufVentile(IN:= TRUE,PT:=tpWartezeitOhneAbfrage);
      tonlZylinder1Ausgefahren(IN := FALSE);
      tonlZylinder1Eingefahren(IN := FALSE);
      tonlZylinder2Ausgefahren(IN := FALSE);
      tonlZylinder2Eingefahren(IN := FALSE);

      IF bpZylinderAbfragenVorhanden THEN

        steplAusfahren := STEP_30_E;

      ELSE
        IF tonlWarteZeitAufVentile.Q THEN

          out_bZylinder1Ausfahren     := FALSE;
          out_bZylinder1Einfahren     := FALSE;
          out_bZylinder2Ausfahren     := FALSE;
          out_bZylinder2Einfahren     := FALSE;

          steplAusfahren := STEP_1000_E;
        END_IF


      END_IF




    // AUS - &  EINFAHREN =====================
    STEP_30_E:
      tonlZylinder1Ausgefahren(IN := NOT in_bStatusZylinder1Ausgefahren, PT := t#3s);
      tonlZylinder1Eingefahren(IN := NOT in_bStatusZylinder1Eingefahren, PT := t#3s);
      tonlZylinder2Ausgefahren(IN := NOT blZylinder2Ausgefahren, PT := t#3s);
      tonlZylinder2Eingefahren(IN := NOT blZylinder2Eingefahren, PT := t#3s);


      CASE elStellung OF

        eZylinderStellung16mm :

          IF ( wpStatusZylinder = eZylinderStellung16mm) THEN
            out_bZylinder1Ausfahren     := FALSE;
            out_bZylinder1Einfahren     := FALSE;
            out_bZylinder2Ausfahren     := FALSE;
            out_bZylinder2Einfahren     := FALSE;
            steplAusfahren := STEP_1000_E;
          END_IF

          (* Fehlerbehandlung:
             - Zylinder
          *)
          IF bpEinAusFahrenLogikDrehen THEN
            IF ( tonlZylinder1Ausgefahren.Q
                 AND tonlZylinder2Ausgefahren.Q
               ) THEN
              out_bZylinder1Ausfahren     := FALSE;
              out_bZylinder1Einfahren     := FALSE;
              out_bZylinder2Ausfahren     := FALSE;
              out_bZylinder2Einfahren     := FALSE;
              wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
              steplAusfahren := STEP_900_E;
            END_IF
          ELSE
            IF ( tonlZylinder1Eingefahren.Q
                 AND tonlZylinder2Eingefahren.Q
               ) THEN
              out_bZylinder1Ausfahren     := FALSE;
              out_bZylinder1Einfahren     := FALSE;
              out_bZylinder2Ausfahren     := FALSE;
              out_bZylinder2Einfahren     := FALSE;
              wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
              steplAusfahren := STEP_900_E;
            END_IF
          END_IF


        eZylinderStellung23mm :

          IF ( wpStatusZylinder = eZylinderStellung23mm) THEN
            out_bZylinder1Ausfahren     := FALSE;
            out_bZylinder1Einfahren     := FALSE;
            out_bZylinder2Ausfahren     := FALSE;
            out_bZylinder2Einfahren     := FALSE;
            steplAusfahren := STEP_1000_E;
          END_IF

          (* Fehlerbehandlung:
             - Zylinder
          *)
          IF bpEinAusFahrenLogikDrehen THEN
            IF ( tonlZylinder1Eingefahren.Q
                 AND tonlZylinder2Ausgefahren.Q
               ) THEN
              out_bZylinder1Ausfahren     := FALSE;
              out_bZylinder1Einfahren     := FALSE;
              out_bZylinder2Ausfahren     := FALSE;
              out_bZylinder2Einfahren     := FALSE;
              wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
              steplAusfahren := STEP_900_E;
            END_IF
          ELSE
            IF ( tonlZylinder1Ausgefahren.Q
                 AND tonlZylinder2Eingefahren.Q
               ) THEN
              out_bZylinder1Ausfahren     := FALSE;
              out_bZylinder1Einfahren     := FALSE;
              out_bZylinder2Ausfahren     := FALSE;
              out_bZylinder2Einfahren     := FALSE;
              wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
              steplAusfahren := STEP_900_E;
            END_IF
          END_IF

        eZylinderStellung29mm :

          IF ( wpStatusZylinder = eZylinderStellung29mm) THEN
            out_bZylinder1Ausfahren     := FALSE;
            out_bZylinder1Einfahren     := FALSE;
            out_bZylinder2Ausfahren     := FALSE;
            out_bZylinder2Einfahren     := FALSE;
            steplAusfahren := STEP_1000_E;
          END_IF

          (* Fehlerbehandlung:
             - Zylinder
          *)
          IF bpEinAusFahrenLogikDrehen THEN
            IF ( tonlZylinder1Eingefahren.Q
                 AND tonlZylinder2Eingefahren.Q
               ) THEN
              out_bZylinder1Ausfahren     := FALSE;
              out_bZylinder1Einfahren     := FALSE;
              out_bZylinder2Ausfahren     := FALSE;
              out_bZylinder2Einfahren     := FALSE;
              wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
              steplAusfahren := STEP_900_E;
            END_IF
          ELSE
            IF ( tonlZylinder1Ausgefahren.Q
                 AND tonlZylinder2Ausgefahren.Q
               ) THEN
              out_bZylinder1Ausfahren     := FALSE;
              out_bZylinder1Einfahren     := FALSE;
              out_bZylinder2Ausfahren     := FALSE;
              out_bZylinder2Einfahren     := FALSE;
              wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
              steplAusfahren := STEP_900_E;
            END_IF
          END_IF

      END_CASE

    // AUS - &  EINFAHREN =====================
    STEP_900_E:
      out_bZylinder1Ausfahren := FALSE;
      out_bZylinder1Einfahren := FALSE;
      out_bZylinder2Ausfahren := FALSE;
      out_bZylinder2Einfahren := FALSE;
      bpFehler := TRUE;

    // AUS - &  EINFAHREN =====================
    STEP_1000_E:
      // Ohne Abfragen ist die Stellung zeitlich angenommen, nicht gemessen
      IF NOT bpZylinderAbfragenVorhanden THEN
        wpStatusZylinder := elStellung;
      END_IF
      bpDone := TRUE;

  // AUS - &  EINFAHREN =====================
  END_CASE
ELSE
  IF (steplAusfahren > STEP_0_E) THEN
    bpDone                   := FALSE;
    out_bZylinder1Ausfahren     := FALSE;
    out_bZylinder1Einfahren     := FALSE;
    out_bZylinder2Ausfahren     := FALSE;
    out_bZylinder2Einfahren     := FALSE;
    tonlZylinder1Ausgefahren( IN := FALSE );
    tonlZylinder1Eingefahren( IN := FALSE );
    tonlZylinder2Ausgefahren( IN := FALSE );
    tonlZylinder2Eingefahren( IN := FALSE );
    tonlWarteZeitAufVentile( IN := FALSE );
    steplAusfahren := STEP_0_E;
  END_IF
END_IF
//_________________________________________________________________________
// ************************ Zylinder - Aus- & Einfahren ********************
//_________________________________________________________________________
END_ACTION