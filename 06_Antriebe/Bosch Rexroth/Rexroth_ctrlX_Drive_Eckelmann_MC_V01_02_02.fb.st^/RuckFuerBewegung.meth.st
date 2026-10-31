(* METADATA
{
  "v3Meta": {
    "objectGuid": "22a6795c-24d0-485d-84ce-ae7862297fab"
  }
}
*)
METHOD PRIVATE RuckFuerBewegung : REAL
VAR_INPUT
  bStart   : BOOL;  // TRUE beim Schreiben des Fahrbefehls, auch nach Parameteraenderung
  bMitZiel : BOOL;  // FALSE bei Suchfahrt oder Synchronisieren ohne bekannte Zielposition
  lrZiel   : LREAL; // Zielposition in mm bzw. Grad
END_VAR
VAR
  lrlGeschwindigkeit     : LREAL;
  lrlBeschleunigung      : LREAL;
  lrlVerzoegerung        : LREAL;
  lrlRuckBeschleunigung  : LREAL;
  lrlRuckVerzoegerung    : LREAL;
  lrlBeschleunigungszeit : LREAL;
  lrlBremszeit           : LREAL;
  lrlEinheitenfaktor     : LREAL;
END_VAR
// 1. Strecke nur beim ersten Fahrbefehl einteilen.
// Ein erneuter Aufruf nach Parameteraenderung oder Pause setzt das Profil nicht zurueck.
IF bStart AND NOT blRuckProfilInitialisiert THEN
  blRuckProfilInitialisiert := TRUE;
  blRuckBremsphase := FALSE;
  blRuckKurzfahrt := TRUE;

  IF (rlRuckVerzoegerung > 0) AND (rlRuckBeschleunigung > 0)
     AND (rlGeschwindigkeit > 0)
     AND (rlBeschleunigung > 0) AND (rlVerzoegerung > 0) THEN
    IF NOT bMitZiel THEN
      // Ohne bekannte Strecke mit Beschleunigungs-Jerk beginnen.
      blRuckKurzfahrt := FALSE;
    ELSIF l_mc_ReadStatus.Valid AND l_mc_ReadStatus.StandStill THEN
      // Alle Werte fuer die Wegberechnung in mm/s bzw. Grad/s umrechnen.
      IF l_ts_MKAxisConfig.dwAxisFlags.0 THEN
        lrlGeschwindigkeit := TO_LREAL(rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT) * 6.0;
        lrlEinheitenfaktor := 360.0;  // Umdrehungen -> Grad
      ELSE
        lrlGeschwindigkeit := TO_LREAL(rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT) / 60.0;
        lrlEinheitenfaktor := 1000.0; // Meter -> Millimeter
      END_IF

      lrlBeschleunigung := TO_LREAL(rlBeschleunigung * cFAKTOR_RAMPEN) * lrlEinheitenfaktor;
      lrlVerzoegerung := TO_LREAL(rlVerzoegerung * cFAKTOR_RAMPEN) * lrlEinheitenfaktor;
      lrlRuckBeschleunigung := TO_LREAL(rlRuckBeschleunigung) * lrlEinheitenfaktor;
      lrlRuckVerzoegerung := TO_LREAL(rlRuckVerzoegerung) * lrlEinheitenfaktor;

      // S-Kurve aus dem Stillstand: Zeit bis zur vorgegebenen Geschwindigkeit.
      // Wird die volle Beschleunigung nicht erreicht, gibt es nur die beiden Ruckflanken.
      IF lrlGeschwindigkeit >= lrlBeschleunigung * lrlBeschleunigung / lrlRuckBeschleunigung THEN
        lrlBeschleunigungszeit := lrlGeschwindigkeit / lrlBeschleunigung
                                 + lrlBeschleunigung / lrlRuckBeschleunigung;
      ELSE
        lrlBeschleunigungszeit := 2.0 * SQRT(lrlGeschwindigkeit / lrlRuckBeschleunigung);
      END_IF

      // Entsprechend die Zeit fuer das Abbremsen bis zum Stillstand berechnen.
      IF lrlGeschwindigkeit >= lrlVerzoegerung * lrlVerzoegerung / lrlRuckVerzoegerung THEN
        lrlBremszeit := lrlGeschwindigkeit / lrlVerzoegerung
                       + lrlVerzoegerung / lrlRuckVerzoegerung;
      ELSE
        lrlBremszeit := 2.0 * SQRT(lrlGeschwindigkeit / lrlRuckVerzoegerung);
      END_IF

      // Beschleunigungsweg + Bremsweg ergeben die Grenze zur Langfahrt.
      // An der Grenze bleibt keine Konstantfahrt: deshalb noch Kurzfahrt.
      // Ohne Override rechnen; ein kleinerer Override macht die Grenze konservativer.
      blRuckKurzfahrt := ABS(lrZiel - TO_LREAL(rpIstPosition))
        <= 0.5 * lrlGeschwindigkeit * (lrlBeschleunigungszeit + lrlBremszeit);
    END_IF
  END_IF

// 2. Bei Langfahrt genau einmal auf Brems-Jerk wechseln.
ELSIF blRuckProfilInitialisiert AND NOT blRuckKurzfahrt AND NOT blRuckBremsphase
      AND l_mc_ReadStatus.Valid AND bpKonstantfahrtAktiv
      AND NOT bpBeschleunigungAktiv AND NOT bpVerzoegerungAktiv
      AND bpAntrieblaeuft THEN
  blRuckBremsphase := TRUE;
END_IF

// 3. Jerk fuer den Fahrbaustein zurueckgeben.
IF NOT blRuckProfilInitialisiert THEN
  RuckFuerBewegung := rlRuckVerzoegerung;
ELSIF blRuckKurzfahrt THEN
  RuckFuerBewegung := MIN(rlRuckBeschleunigung, rlRuckVerzoegerung);
ELSIF blRuckBremsphase THEN
  RuckFuerBewegung := rlRuckVerzoegerung;
ELSE
  RuckFuerBewegung := rlRuckBeschleunigung;
END_IF
END_METHOD