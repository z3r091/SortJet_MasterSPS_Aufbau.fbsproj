(* METADATA
{
	"v3Meta": {
		"objectGuid": "2d047442-6309-4b21-9bd9-5b87d945459b"
	}
}
*)
{attribute 'excludefrombuild'}
PROGRAM AuftragsManagement
VAR_INPUT
  blShuttle101Empty    : BOOL := TRUE;
  blAnlegeauftragAktiv : BOOL := FALSE;
END_VAR
VAR
  wlVisuBreite    : WORD := 4;
  wlVisuLaenge    : WORD := 1000;
  wlVisuHoehe     : WORD := 500;
  wlVisuZiel      : WORD := 1;
  wlVisuQuelle    : WORD := 201;
  wlVisuQuellSlot : WORD := 1;
  wlVisuZielSlot  : WORD := 1;
  blVisuDrehen    : BOOL := FALSE;

  blButtonCreateOrder : BOOL;
  blReset             : BOOL;
  i : INT := 0;
  wAktNewOrder : WORD := 0;
  rtlButtonCreateOrder : R_TRIG;
END_VAR
rtlButtonCreateOrder(CLK:=blButtonCreateOrder);
IF rtlButtonCreateOrder.Q THEN
  blButtonCreateOrder := FALSE;
  IF wlVisuQuelle = 201 THEN
    amsAuftraege[wAktNewOrder].ilAktuelleStation := -1;
    amsAuftraege[wAktNewOrder].wlNextStation := 201;
    amsAuftraege[wAktNewOrder].blMessungOK := FALSE;
  ELSE
    amsAuftraege[wAktNewOrder].ilAktuelleStation := wlVisuQuelle;
    amsAuftraege[wAktNewOrder].wlNextStation := 215;
    amsAuftraege[wAktNewOrder].blMessungOK := TRUE;
  END_IF
  amsAuftraege[wAktNewOrder].wlHoehe := wlVisuHoehe;
  amsAuftraege[wAktNewOrder].wlLaenge := wlVisuLaenge;
  amsAuftraege[wAktNewOrder].wlBreite := 4;
  amsAuftraege[wAktNewOrder].wlDestination := wlVisuZiel;
  amsAuftraege[wAktNewOrder].wlDestinationSlot := wlVisuZielSlot;
  amsAuftraege[wAktNewOrder].wlSource := wlVisuQuelle;
  amsAuftraege[wAktNewOrder].wlSourceSlot := wlVisuQuellSlot;
  amsAuftraege[wAktNewOrder].blDrehen := blVisuDrehen;
  amsAuftraege[wAktNewOrder].blAuftragAktiv := FALSE;
  amsAuftraege[wAktNewOrder].blShuttleAbgabePositionierungFertig := FALSE;
  amsAuftraege[wAktNewOrder].blShuttleAbgabePositionierungGestartet := FALSE;
  amsAuftraege[wAktNewOrder].blShuttleAbholungPositionierungFertig := FALSE;
  amsAuftraege[wAktNewOrder].blShuttleAbholungPositionierungGestartet := FALSE;
  wAktNewOrder := wAktNewOrder + 1;
  IF ( wAktNewOrder > 15 ) THEN
    wAktNewOrder := 0;
  END_IF
END_IF

ShuttlePositionen();

IF blReset THEN
  FOR i := 0 TO 15 DO
    amsAuftraege[i].ilAktuelleStation := 0;
    amsAuftraege[i].wlLaenge := 0;
    amsAuftraege[i].wlHoehe := 0;
    amsAuftraege[i].wlBreite := 4;
    amsAuftraege[i].wlDestination := 1;
    amsAuftraege[i].wlDestinationSlot := 1;
    amsAuftraege[i].wlSource := 201;
    amsAuftraege[i].wlSourceSlot := 1;
    amsAuftraege[i].wlNextStation := 0;
    amsAuftraege[i].blMessungOK := FALSE;
    amsAuftraege[i].blDrehen := FALSE;
    amsAuftraege[i].blAuftragAktiv := FALSE;
    amsAuftraege[i].blShuttleAbholungPositionierungGestartet := FALSE;
    amsAuftraege[i].blShuttleAbholungPositionierungFertig := FALSE;
    amsAuftraege[i].blShuttleAbgabePositionierungGestartet := FALSE;
    amsAuftraege[i].blShuttleAbgabePositionierungFertig := FALSE;
  END_FOR
  blShuttle101Empty    := TRUE;
  blAnlegeauftragAktiv := FALSE;
  blReset := FALSE;
END_IF

_214_Zu_217();
END_PROGRAM