(* METADATA
{
	"v3Meta": {
		"objectGuid": "3ad406ab-889e-4d0d-be2f-76f9c9ecfe4e"
	}
}
*)
{attribute 'excludefrombuild'}
ACTION A_Changelog
(* !!! VERSIONSÄNDERUNGEN WERDEN HIER DETAILLIERT DOKUMENTIERT !!!

- 2025-07-02 - V01_00_00:
  - Entwicklung des Bausteins; Erste Version die Freigegeben wird/wurde

- 2025-10-10 - V01_00_01: Marc Wiegran
  - Änderung des Baustein. Damit die Visualisierung Antriebe_Verfahren weiterhin genutzt werden kann muss in den Schrittketten auf l_mc_power.Enable und nicht auf bpFreigabe geschaut werden.
    l_mc_power.Enable wird aus bpFreigabe und bpFrigabeErzingen, sodass wir nicht mehr in einen Internen Fehler laufen
  - Änderung des Bausteins Damit auch auf die gemeldeten zustände der Hardwarefreigabe geschaut wird wurde in den Schrittketten das l_mc_power.Status durch Regler bereit ersetzt

- 2025-10-15 - V01_00_02: Tobias Brekerbohm
  - Korrektur Vergleich der Software Endschalter - wenn beide 0 dann ansehen als wären keine Aktiv
  - Korrektur bpReglerBereit - Bei Achsen im Zwischenkreis kommen die Bits nicht entsprechend anderer Achsen
    Hier muss auf das CiA Status Word geschaut werden. Zu Prüfen ist, ob das bei den normalen Achsen auch ggf. schon ausreicht
  - Anpassungen / Korrekturen Rotative Achsen

- 2025-10-16 - V01_00_03: Tobias Brekerbohm
  - Korrektur dauernde Neuberechnung der Zielposition bei relativer Positionierung

- 2025-10-17 - V01_00_04: Marc Wiegran
  - Korrektur der Eingangsbits der Langsamfahrnocken auch CoE

- 2025-10-21 - V01_00_05: Marc Wiegran
  - Bei Geschwindigkeitsänderung bei der Messfahrt wird in Step 325 gesprungen um die MC_MOVE_Velocity neu zu starten und nicht wie vorher in 300, da dort erneut die Startbedingungen gepürft werden

- 2025-10-21 - V01_00_06: Marc Wiegran
  - Warteschritt 250 hinzugefgt um sicherzustellen, das die Softwarefreigabe vor Bewegungsstart erteilt wurde noch zu testen ob es die Fehler 6 der MC-Bausteine behebt
  - Schreiben der MC_Home-Fehler-ID in die dafür vorgesehene Variable

- 2025-10-22 - V01_00_07: Marc Wiegran
  - Entfernen des Warteschritt 250, statt dessen wird im Schritt 100 auf l_mc_Power.Status geschaut und Timerüberwacht wird dort ein Fehler ausgeworfen.
      - Enable := Freigabe setzten; Status := Freigabe wurde erfolgreich gesetzt
  - Entfernen der Überprüfung der aktuellen antriebsposition <100 nach der Referenz
      - die Querfahrten haben einen absoluten Referenzoffset von >100, sodass dies andernfalls nicht klappt

- 2025-10-28 - V01_00_08: Tobias Brekerbohm
  - State-Machine achtet nun auf NOT Valid als aller erstes
  - Vergessener Warteschritt 250 aus 1.00.06 der bei der Entfernung in 1.00.07 vergessen wurde zusätzlich entfernt

- 2025-11-11 - V01_00_09: Tobias Brekerbohm
  - Fehlerhaftes ABS setzen von Messergebnissen bei Scheibenmessungen entfernt

- 2025-11-13 - V01_00_10: Tobias Brekerbohm
  - Reset von Ref-Bezug löschen Bit hat gefehlt

- 2025-11-24 - V01_00_11: Tobias Brekerbohm
  - Fehlender Reset von Softwarefreigabe-Timer korigiert
  - An vielen Stellen wurde immernoch auf l_mc_Power.Enable geschaut für den Fehler der Softwarefreigabe statt auf l_mc_Power.Status

- 2026-12-10 - V01_00_12: Tobias Brekerbohm
  - Bei festen Zielpositionen werden keine mm/grad mehr aufaddiert, es werden hart die Grenzwerte aus dem EConSET genommen und nicht mehr schöngerechnet
  - Bei einer Zielpos außerhalb der Grenzen wird nun ein Fehler geworfen, statt die Zielpos stillschweigend zu begrenzen
  - Statt dauernd auf die MK Variablen zu schauen, welche noch konvertiert werden muss, wird nun direkt auf die rpMin- und rpMaxPosition geschaut

- 2026-12-10 - V01_00_13: Tobias Brekerbohm
  - bpAchseSychron schaut nicht länger auf l_mc_ReadStatus.SynchronizedMotion da das Signal aus dem Status gelegentlich geflackert hat

- 2026-12-10 - V01_00_14: Tobias Brekerbohm
  - ReadAxisError wurde nicht aufgerufen
  - Fehlerauswertung bei Fehler aus dem MotionKernel (F 108) bei kein Fehler vom Regler und kein internen Fehler

- 2026-03-12 - V01_00_15: Tobias Brekerbohm
  - Berechnung Ruckzeit bei Langsamfahrt fehlerhaft

- 2026-03-17 - V01_00_16: Tobias Brekerbohm
  - Handplus / Handminus / Restweg-Suchfahrt beachten nun die Software-Endschalter und bremsen vor Erreichen anhand der aktuellen Bremsposition ab
  - Ein Neustart in Richtung eines bereits ueberschrittenen Software-Endschalters wird unterbunden

- 2026-03-19 - V01_00_17: Tobias Brekerbohm
  - Neue Eingaben rpMinSwEsEingrenzung/rpMaxSwEsEingrenzung ergaenzen eine externe Eingrenzung der Software-Endschalter
  - Externe Limits duerfen den MK-Bereich nur enger machen und nicht erweitern
  - Alle Bewegungsarten pruefen neue Zielpositionen und Bremsgrenzen gegen die aktiven Min-/Max-Grenzen

- 2026-03-22 - V01_00_18: Tobias Brekerbohm
  - Antriebssimulation für SPS Simulation (ungetestet)

- 2026-03-24 - V01_00_19: Tobias Brekerbohm
  - XG37-1 und XG37-2 (eigentlich als Eingänge genutzt) optional auch als Ausgänge nutzbar (Benötigt Parameteränderung am Antrieb!!!)

- 2026-03-27 - V01_00_20: Tobias Brekerbohm
  - Neuer Eingang bpFreigabeEntziehenAnhalten fuer kontrollierten Freigabeentzug mit Halt ohne Schrittketten-Reset
  - Bei aktivem Freigabeentzug wird die Achse angehalten, danach die Power entzogen und nach Signalrueckkehr automatisch ohne externen Trigger fortgesetzt
  - Motion-Fehlerauswertung unterdrueckt erwartete ErrorStop-Meldungen waehrend aktivem Freigabeentzug
  - Beim Wiederanlauf nach Freigabeentzug werden laufende Schrittketten auf Execute-Startschritte remappt, damit Bewegungen sicher neu starten
  - Kein ungewollter Schrittketten-Reset bei Signalrueckkehr waehrend aktivem MC_Stop (rtlStop-Kante abgesichert)

- 2026-06-12 - V01_01_00: Tobias Brekerbohm
  - Globaler Override für die Achsgeschwindigkeit - Prozentual zu ändern. Neuer Input rpOverride 0-100
  - Taktzeitoptimierung: Flankenerkennung der Sensoren direkt im Antriebsbaustein ohne zusaetzlichen FB-Aufruf
  - Taktzeitoptimierung: Stillstandsposition nur bei aktiver Software-Endschalter-Bremswegueberwachung berechnen
  - Taktzeitoptimierung: MC_ReadAxisError nur im ErrorStop und einmalig zum Deaktivieren aufrufen
  - S277 Bit 12 wird geprüft, mit Fehlermeldung wenn nicht = 1
  - Bei aktivierter Langsamfahrtnocke wird nicht auf Langsame Geschwindigkeit gestellt, wenn die Achse beim belegen der Nocke/Laser gerade am Verzögern ist. 
     Würden wir während der Verzögerung die Geschwindigkeit reduzieren, würde der Verfahrbefehl abgebrochen und neu geschrieben werden in den MotionKernel.
     Dabei verlieren wir Zeit und die Achse würde ihre Zielposition überfahren.
  - Restweg positionierung kann nun auch auf Achsen Restweg fahren, die per wpSlave angegeben werden. Z. b. Greifer auf Riemen-Sensorik (Sensor 6-9)
  - Gravierender Fehler bei der Langsamfahrt behoben: Shuttle überfährt seine Position massiv bei aktiver Langsamfahrt weil die Ruckzeit umgerechnet wurde und dadurch
    die Zielposition nicht mehr erreicht werden kann und somit überschwingt
  - Fehler behoben, dass blInternerFehler erst nach einem 2. Reset zurückgesetzt wurde. MotionFehler brauchten dadurch immer 2 Resets

- 2026-07-07 - V01_01_01: Tobias Brekerbohm
  - Fehler bei Zuweisung von Beschleunigung und Verzögerung behoben.

- 2026-08-04 - V01_01_02: Tobias Brekerbohm
  - Restwegmessung während der Absolutfahrt ermöglicht und Messung mehrerer aufeinanderfolgender Scheiben korrigiert.
  - Messergebnis der Restwegmessung wird immer positiv ausgegeben.

- 2026-08-05 - V01_01_03: Marc Wiegran und Tobias Brekerbohm
  - Korrektur zuweisung rpMessergbnis - Messergebnis war erst einen Zyklus nach erfolgreicher Messung im Statusword
  - Messergebnis der Längenmessung wird wieder negativ ausgegeben, da der Scheibenmessung_FB darauf ausgelegt ist den so zu erhalten

- 2026-09-25 - V01_01_04: Tobias Brekerbohm
  - Langsamfahrt begrenzt die Geschwindigkeit ueber MC_SetOverride auf 10 % der konfigurierten Maximalgeschwindigkeit.
  - Der externe rpOverride bleibt wirksam; Bewegungsbefehle werden fuer Langsamfahrt nicht mehr neu geschrieben.
  - Bei kurz erkanntem Stillstand bleibt aktive Langsamfahrt erhalten, solange eine Langsamfahrtnocke belegt ist.
  - Langsamfahrt-Bedingung in Nockenerkennung, Aktivierung und Halten aufgeteilt; Verhalten unveraendert.

- 2026-10-14 - V01_01_05: Tobias Brekerbohm:
  - FreigabeEntziehen_Wiederanlauf: MC_Stop wird auch ausgeloest, wenn der Antrieb laut MC-Status nicht im Stillstand ist (bisher nur ueber bpAntrieblaeuft -> bei Anlauf/langsamer Fahrt kein Stop und evtl. Power-Entzug waehrend der Fahrt)
  - FreigabeEntziehen_Wiederanlauf: tonlSoftwareFreigabe/tonlHardwareFreigabe werden waehrend des Halts zurueckgesetzt (Haltezeit zaehlt nicht als Timeout der eingefrorenen Schrittkette)

- 2026-10-17 - V01_02_00: Tobias Brekerbohm, Claude
  - Ruck (Jerk) für lineare und rotative Achsen überarbeitet: Kurze Fahrten nutzen von Anfang an den kleineren Jerk. Lange Fahrten starten mit dem Beschleunigungs-Jerk und wechseln bei erreichter Fahrgeschwindigkeit auf den Brems-Jerk. Der Brems-Jerk kann größer oder kleiner sein.
  - Ob eine Fahrt kurz oder lang ist, wird aus Strecke, Geschwindigkeit, Beschleunigung, Verzögerung und Ruckzeit berechnet. Die Ruckzeitbegrenzung aus EConSet wird berücksichtigt.
  - Der Wechsel auf den Brems-Jerk erfolgt nur einmal pro Fahrt. Parameteränderungen und eine Freigabepause schalten nicht wieder in die Beschleunigungsphase zurück.
  - Stoppen verwendet grundsätzlich den Brems-Jerk. Beim Abbruch während der Beschleunigung wird mindestens der Beschleunigungs-Jerk und der Jerk des laufenden Fahrbefehls verwendet. Dieser bleibt bis zum Ende des Stops erhalten, auch wenn die Schrittkette zurückgesetzt wird.
  - Die Jerk-Auswahl wird gemeinsam für Absolut-, Relativ-, Hand-, Mess-, Restweg- und Synchronfahrten verwendet. Strecken werden passend zum Achstyp in Millimetern oder Grad berechnet.

- 2026-10-19 - V01_02_01: Claude
  - Simulation (bgSPS_SIMULATION): MK-Konfiguration wird jetzt auch im Simulationsmodus geladen (MK_GetAxisConfiguration). Vorher blieb l_ts_MKAxisConfig leer und die Achsen liefen mit den Notfall-Grenzen +-1000.
  - Simulation: rlGeschwindigkeit/rlBeschleunigung/rlVerzoegerung werden jetzt wie in Pruefe_Inputs_Langsamfahrt aus den Eingaengen gebildet und auf die MK-Maximalwerte begrenzt. Vorher waren sie im Simulationsmodus immer 0, die Achsen fuhren daher immer mit den Fallback-Werten (200 / 800).
  - Simulation: rpOverride wirkt jetzt auch auf die simulierte Geschwindigkeit.
  - Simulation: Scheibenmessung (SCHEIBENMESSUNG) und Restwegmessung liefern jetzt ein Messergebnis. Mangels Glasmodell gilt eine virtuelle Scheibenlaenge (globale Variable rgSimScheibenlaenge, Standard 1000 mm):
    Die Messung ist abgeschlossen, wenn die Achse seit Messstart (bzw. seit der ersten Flanke bei Restweg) diese Strecke verfahren hat. Vorzeichen wie im Echtbetrieb angenommen: Scheibenmessung negativ (positiv bei bpDrehrichtungsumkehrMessung), Restweg positiv.
    Die Messfahrt laeuft wie im Echtbetrieb immer in positive Richtung. bpMessungOk/bpMessungFehlerhaft/rpMessErgebnis bleiben bis zum Betriebsartenwechsel gespeichert (vorher nur 1 Zyklus).
  - Simulation: Neuer Eingang rpSimMessErgebnis (nur Simulation): Station gibt das Ergebnis der Scheibenmessung vor. Echtbetrieb-Konvention (aus Scheibenmessung_FB): Ergebnis = Scheibenlaenge - Messstrecke, Glaslaenge = ABS(Messstrecke + Ergebnis).
    Die Messfahrt dauert so lange wie der Betrag des Ergebnisses. Ist der Eingang 0, gilt weiter die virtuelle Scheibenlaenge rgSimScheibenlaenge (Vorzeichen negativ).
  - Simulation: bpBremseLoesen setzt SignalSteuerWort.15 (nur mit bpBremseLoesenFreigabe, sonst Fehler) und meldet bpBremseGeloest nach 300 ms zurueck.
  - Simulation: bpAbsolutSetzen durchlaeuft wie im Echtbetrieb Referenz loeschen -> setzen -> bpAbsolutSetzenDone.
  - Simulation: Langsamfahrnocken (bpAktiviereLangsamfahrtNocke) sind jetzt Low-aktiv (FALSE = belegt) wie im Echtbetrieb, an den Wegenden positioniert; bpLangsamfahrenAktiv begrenzt die Geschwindigkeit auf 10 % der MK-Maximalgeschwindigkeit.
  - Simulation: Abbildung Sensor -> Umrichter-Eingang wie im Echtbetrieb (Sensor_3 = XG31_6, Sensor_4 = XG31_7, Sensor_5 = XG37_4; vorher um eine Stelle verschoben). Sensor_6..9 kommen wie im Echtbetrieb vom Slave-Antrieb (wpSlaveNr).

- 2026-10-31 - V01_02_02: Tobias Brekerbohm, Claude
  Hinweis: Die Nummer V01_01_05 wurde doppelt vergeben: Dreisbusch/Regency 2026-10-14 TB (FreigabeEntziehen_Wiederanlauf) und Isophon 2026-10-06 Daniel Vogelsang (eigener Zweig).
  Dieser Stand baut auf V01_02_01 auf und uebernimmt die Punkte aus dem Isophon-Zweig. Ruck-Profil, StopVerwaltung und Simulation bleiben wie in V01_02_01.
  - Steuerwort-Bits zentral in _Steuerwort zusammengefasst; Referenz- und Bremsenbefehle ueber interne BOOL-Merker. _Steuerwort laeuft auch vor den RETURN-Pfaden (ausser Achse 65).
  - Neue Struktur stOptionen (Antrieb_Optionen_ST) in AntriebsInformationen; ersetzt bpHardwareLimits und bpBremseLoesenFreigabe.
  - Endschalterquelle (eEndschalterQuelle): KEINE, UMRICHTER (Signal-Statuswort Bit 0 = Min, Bit 1 = Max) oder SPS.
  - Quelle SPS: Neue Eingaenge bpEndschalterMinExtern/bpEndschalterMaxExtern auf Signal-Steuerwort Bit 10 (Min) und Bit 9 (Max). Oeffner, TRUE = frei, Default TRUE fuer eine nicht vorhandene Seite.
    Bei anderer Quelle bleiben Bit 9/10 auf TRUE. bpMinSchalterBelegt/bpMaxSchalterBelegt kommen auch bei Quelle SPS aus dem Signal-Statuswort.
    Korrektur zum Isophon-Zweig: Dort stehen Min/Max in Deklaration und Changelog vertauscht, gesendet wird Bit 9 = Max, Bit 10 = Min.
  - XVR-Modus (bVersorgungUeberXVR): brueckt bpHaupschalter400VEin und bpLS_150F02_230V, ersetzt die festen OR TRUE aus dem Isophon-Zweig.
  - BETRIEBSART_MasterSlave Schritt 1000: bpDone wurde per Vergleich gebildet und war dadurch TRUE, obwohl die Achse nicht synchron war bzw. ein Fehler anstand. Jetzt bpDone := l_mc_GearIn.InGear, in den Fehlerzweigen bpDone := FALSE.
  - Defaults setzt bpDone := FALSE. Vorher blieb ein altes bpDone waehrend Busausfall stehen und ein Reset-Auftrag galt sofort als fertig.
  - tonlMaxZeitStatusUngueltig wird jeden Zyklus vor der State Machine aufgerufen und in Defaults zurueckgesetzt. Vorher wurde er nie zurueckgesetzt und eine spaetere kurze Statusstoerung loeste sofort einen Stop aus.
  - BETRIEBSART_Reset Schritt 250: l_mc_Reset.Error wird bewusst nicht ausgewertet. Der Isophon-Changelog nennt diesen Punkt, der Code ist dort aber zu Recht auskommentiert.
  - BETRIEBSART_Reset: Neuer Schritt 260, wartet nach MC_Reset 1 s, bevor bei weiter anstehendem Fehler der Reset per CoE laeuft (aus dem Isophon-Zweig).
  - _Statusword und Simulation: Widerspruchspruefung der Software-Endschalter auf das Ergebnis (rpMinPosition > rpMaxPosition) umgestellt. Vorher nur, wenn beide externen Grenzen gesetzt waren.

*)
END_ACTION