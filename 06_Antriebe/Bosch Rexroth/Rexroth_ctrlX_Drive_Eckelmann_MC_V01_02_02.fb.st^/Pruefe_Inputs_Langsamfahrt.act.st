(* METADATA
{
  "v3Meta": {
    "objectGuid": "1b136394-d10a-4169-9faf-2f70a4dfcb82"
  }
}
*)
ACTION Pruefe_Inputs_Langsamfahrt
IF blZweiterZyklus OR blErsterZyklus THEN
  RETURN;
END_IF

rlGeschwindigkeit := rpGeschwindigkeit;
rlBeschleunigung  := rpBeschleunigung;
rlVerzoegerung    := rpVerzoegerung;

// Übergebene Geschwindigkeit über konfiguriertem Maximum
IF ( ( rlGeschwindigkeit ) > l_ts_MKAxisConfig.rVelocity / cFAKTOR_GESCHWINDIGKEIT_ECONSET ) THEN // EConSet in m/min angegeben...
  rlGeschwindigkeit := l_ts_MKAxisConfig.rVelocity / cFAKTOR_GESCHWINDIGKEIT_ECONSET;
END_IF
// Übergebene Geschwindigkeit kleiner 0
IF ( ( rlGeschwindigkeit ) < 0 ) THEN
  rlGeschwindigkeit := 0;
END_IF

// Übergebene Beschleunigung über konfiguriertem Maximum
IF ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) > l_ts_MKAxisConfig.rAcceleration ) THEN
  rlBeschleunigung := l_ts_MKAxisConfig.rAcceleration / cFAKTOR_RAMPEN;
END_IF
// Übergebene Beschleunigung kleiner gleich 0
IF ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) <= 0 ) THEN
  rlBeschleunigung := l_ts_MKAxisConfig.rAcceleration / cFAKTOR_RAMPEN;
END_IF

// Übergebene Verzögerung über konfiguriertem Maximum
IF ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) > l_ts_MKAxisConfig.rDeceleration ) THEN
  rlVerzoegerung := l_ts_MKAxisConfig.rDeceleration / cFAKTOR_RAMPEN;
END_IF
// Übergebene Verzögerung kleiner gleich 0
IF ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) <= 0 ) THEN
  rlVerzoegerung := l_ts_MKAxisConfig.rDeceleration / cFAKTOR_RAMPEN;
END_IF


// Wirksame Ruckzeit [s]: Vorgabe in ms, begrenzt durch EConSet.
rlRuckzeitSek := rpRuckzeit * 0.001;
IF rlRuckzeitSek <= 0 THEN
  rlRuckzeitSek := MAX(0.0, l_ts_MKAxisConfig.rRampTime);
ELSIF l_ts_MKAxisConfig.rRampTime > 0 THEN
  rlRuckzeitSek := MIN(rlRuckzeitSek, l_ts_MKAxisConfig.rRampTime);
END_IF

// Beide Jerk-Werte in MC-Einheiten bereitstellen.
// Welcher kleiner ist, haengt von Beschleunigung und Verzoegerung ab.
rlRuckBeschleunigung := 0;
rlRuckVerzoegerung := 0;
IF rlRuckzeitSek > 0 THEN
  rlRuckBeschleunigung := rlBeschleunigung * cFAKTOR_RAMPEN / rlRuckzeitSek;
  rlRuckVerzoegerung := rlVerzoegerung * cFAKTOR_RAMPEN / rlRuckzeitSek;
END_IF

// Die aktive Betriebsart waehlt danach in RuckFuerBewegung ihren Fahr-Jerk.
rlRuckzeit := rlRuckVerzoegerung;

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// SHUTTLE LANGSAMFAHRT NOCKE
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Nocke in der aktuellen Fahrtrichtung erkennen.
blNockeInFahrtrichtung :=
(NOT udipEingaengeUmrichter.cXG31_2_I_2
  AND eBewegungsrichtung = TE_Move_Direction.MD_NEGATIV_E)
OR (NOT udipEingaengeUmrichter.cXG31_1_I_1
  AND eBewegungsrichtung = TE_Move_Direction.MD_POSITIV_E);

blEineLangsamfahrtnockeBelegt :=
NOT udipEingaengeUmrichter.cXG31_1_I_1
OR NOT udipEingaengeUmrichter.cXG31_2_I_2;

IF NOT bpAktiviereLangsamfahrtNocke
  OR rlGeschwindigkeit <=
  (l_ts_MKAxisConfig.rVelocity / cFAKTOR_GESCHWINDIGKEIT_ECONSET) * 0.1
THEN
  bpLangsamfahrenAktiv := FALSE;

ELSIF bpLangsamfahrenAktiv THEN
  // Bei kurz erkanntem Stillstand aktiv bleiben, solange eine Nocke belegt ist.
  bpLangsamfahrenAktiv :=
  blNockeInFahrtrichtung
  OR (eBewegungsrichtung = TE_Move_Direction.MD_STANDSTILL_E
    AND blEineLangsamfahrtnockeBelegt);

ELSE
  // Während einer laufenden Verzögerung keine neue Langsamfahrt starten.
  bpLangsamfahrenAktiv :=
  blNockeInFahrtrichtung AND NOT l_mc_ReadStatus.Decelerating;
END_IF
END_ACTION