(* METADATA
{
  "v3Meta": {
    "objectGuid": "789214cb-2f8c-42e6-9b5c-a501299e6a14"
  }
}
*)
{attribute 'excludefrombuild'}
PROGRAM Checkliste_Neues_Projekt
(* !!! CHECKLISTE NEUES PROJEKT - NUR DOKUMENTATION, WIRD NICHT UEBERSETZT !!!

Alles Projektspezifische liegt hier unter der Applikation, in derselben Ordnerstruktur wie auf der
POU-Seite. Die POU-Seite wird fuer ein neues Projekt nicht angefasst.

1. Anlagenaufbau festlegen
   - 00_Basis/Stations_Konfig: Anzahl Antriebe, Ampeln, Hupen, Waende; erste/letzte Station,
     Shuttle (Input/Output), Transfershuttle, Faecherwagenstation, Fremdanlage (Ein-/Auslauf),
     Terminals; Automatikkreise, Sicherheitskreise, Tueren, Durchgaenge
   - Neue Stationsnummern: Konstanten cSTATION_xxx in 00_Basis/Stations_Konstanten (POU-Seite)

2. Instanzen und Aufrufe
   - 02_Global Variables/Globale_Bausteine: eine Instanz je Station mit dem versionierten Baustein
     (z. B. Foerderer_FB_V01_00_00), Arrays fuer Shuttle, Transfershuttle, Faecherwagen, Schnittstellen
   - 09_Station/StationsAufrufe: Aufruf je Station mit starrStationBasisParameter[cSTATION_xxx]
   - 00_Basis/StationBasisZuweisungen: Aktion Zuweisung_xxx je Station (MKs, Antriebsinformationen,
     Ein- und Austransporte) und Aufruf in M_AufrufeZuweisungen

3. Je Station ein Ordner 0_Konfig unter 09_Station/...
   - MK_*: Maschinenkonstanten, ganze ungenutzte Strukturen nur als Kommentar mit ihrem Namen
   - Antriebsinformationen_*: AchsIDs, Grenzen, Optionen
   - Konfiguration_*: IOs per AT nach Schaltplan, Praefix in_b / out_b

4. Anlagenweite Konstanten und IOs
   - 03_Maschinenkonstanten: MK_Basis (Automatikkreise), Allgemeine_MKs
   - 00_Basis/IO_Konfig_Basisbausteine: Druckluft, Ampeln, Hupen usw.
   - 09_Station/Shuttle/Bewegung/MK_Verfahrparameter, 09_Station/Shuttle/Zentralschmierung/MK_Zentralschmierung
   - 09_Station/Stationen/Faecherwagen/0_Konfig: Konfiguration_FW_Basis, MK_Faecherwagen

5. Sicherheit
   - 05_Sicherheitstechnik/0_Konfig: Konfiguration_Sicherheit, MK_Sicherheitskreise
   - 05_Sicherheitstechnik/Interface_SLC: Austausch mit der Sicherheitssteuerung (SLC) an das Safety-Projekt anpassen
   - 05_Sicherheitstechnik/NotHalt: Not-Halt-Kreise und ihre Meldungen (Aktion Meldungen) anpassen
   - Safety Exchange (Austauschvariablen) und das Safety-Projekt passend dazu

6. Schnittstellen zu Fremdanlagen
   - 10_Schnittstellen: Konfiguration_Schnittstelle_xxx, MK_Station_xxx, MK_Schnittstelle_Sortjet

7. Geraete und Tasks
   - EtherCAT-Teilnehmer und Achsen im Geraetebaum nach Schaltplan
   - Taskkonfiguration pruefen

8. Danach
   - Uebersetzen, Warnungen pruefen
   - Meldungen aus StartUpCheck beachten: doppelte AchsIDs, Automatikkreise, Stationstyp,
     Meldungsnummern und Stationsnummern aus den MKs
*)
END_PROGRAM