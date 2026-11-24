(* METADATA
{
	"v3Meta": {
		"objectGuid": "3b7a5a60-5636-4bff-91d8-1a58b4269c51"
	}
}
*)
PROGRAM PRG_NcErrors
VAR
    xInit            : BOOL;
    NCGlobalControl  : NC_GlobalControl;
    NCReadError      : NC_ReadErrorMessage;
    NCResetError     : NC_ResetErrorMessage;
    uiErrorCnt       : UINT;
    ui               : UINT;
    xQuit            : BOOL;
    xOverrun         : BOOL;
    xResetLog        : BOOL;
    udiErrorsRead    : UDINT;   (* alle gelesenen Einträge inkl. Meldungen *)
    udiErrorsLogged  : UDINT;   (* nur Klasse >= 1 *)
    uiLogIdx         : UINT;    (* nächster Schreibindex *)
    aCategory        : ARRAY[0..15] OF BYTE;
    aModule          : ARRAY[0..15] OF BYTE;
    aInstance        : ARRAY[0..15] OF UINT;    (* Achsnummer *)
    aCode            : ARRAY[0..15] OF DINT;
    aInfo            : ARRAY[0..15] OF STRING(63);
    aMessage         : ARRAY[0..15] OF STRING(255);
END_VAR


IF NOT xInit THEN NCGlobalControl.xErrorReporting := TRUE; xInit := TRUE; END_IF
NCGlobalControl();

IF xResetLog THEN
    xResetLog := FALSE; xOverrun := FALSE; udiErrorsLogged := 0; uiLogIdx := 0;
END_IF

IF NCGlobalControl.xErrorPending THEN
    xQuit := FALSE;
    NCReadError(xEnable := FALSE);
    uiErrorCnt := NCReadError.uiErrorCount;
    FOR ui := 1 TO uiErrorCnt DO
        NCReadError(xEnable := TRUE);
        IF NCReadError.xBufferOverrun THEN xOverrun := TRUE; END_IF
        IF NCReadError.xValid THEN
            udiErrorsRead := udiErrorsRead + 1;
            IF NCReadError.byErrorCategory >= 1 THEN   (* Meldungen (Klasse 0) ignorieren *)
                aCategory[uiLogIdx] := NCReadError.byErrorCategory;
                aModule[uiLogIdx]   := NCReadError.byErrorModule;
                aInstance[uiLogIdx] := NCReadError.uiErrorInstance;
                aCode[uiLogIdx]     := NCReadError.diErrorCode;
                aInfo[uiLogIdx]     := NCReadError.sErrorInfo;
                aMessage[uiLogIdx]  := NCReadError.sErrorMessage;
                uiLogIdx := (uiLogIdx + 1) MOD 16;
                udiErrorsLogged := udiErrorsLogged + 1;
            END_IF
            IF NCReadError.byErrorCategory > 2 THEN xQuit := TRUE; END_IF   (* Klasse 3/4 muss quittiert werden *)
        ELSE
            EXIT;
        END_IF
    END_FOR
    NCResetError(xEnable := xQuit);
END_IF
END_PROGRAM