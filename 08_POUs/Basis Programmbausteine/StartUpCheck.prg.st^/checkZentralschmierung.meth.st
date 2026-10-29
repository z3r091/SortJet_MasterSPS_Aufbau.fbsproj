(* METADATA
{
	"v3Meta": {
		"objectGuid": "5eb94ffc-f2d1-4fcc-9867-11fb69ff17a0"
	}
}
*)
METHOD checkZentralschmierung
VAR_INPUT
END_VAR
VAR
  x, y : WORD;
END_VAR

FOR x := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
    FOR y := 1 TO 2 DO
        IF apgMKShuttleZentralschmierung[x].aiAnzahlHuebe[y] = 0 THEN
            CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000030, i, 'Shuttle-Zentralschmierung: Anzahl Huebe = 0');
            SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
            NullRef := TRUE;
        END_IF;

        IF apgMKShuttleZentralschmierung[x].adiZuFahrenderWegBisSchmierung[y] = 0 THEN
            CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000031, i, 'Shuttle-Zentralschmierung: Weg bis Schmierung = 0');
            SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
            NullRef := TRUE;
        END_IF
    END_FOR
END_FOR

FOR x := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
    FOR y := 1 TO 2 DO
        IF apgMKTransfershuttleZentralschmierung[x].aiAnzahlHuebe[y] = 0 THEN
            CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000032, i, 'Transfershuttle-Zentralschmierung: Anzahl Huebe = 0');
            SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
            NullRef := TRUE;
        END_IF;

        IF apgMKTransfershuttleZentralschmierung[x].adiZuFahrenderWegBisSchmierung[y] = 0 THEN
            CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000033, i, 'Transfershuttle-Zentralschmierung: Weg bis Schmierung = 0');
            SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
            NullRef := TRUE;
        END_IF
    END_FOR
END_FOR
END_METHOD