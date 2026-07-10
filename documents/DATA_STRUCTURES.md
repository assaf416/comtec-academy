# SAATCG / SAATCGSL — Data Structure Reference

Field-level reference for every data structure used by the two programs.
See `DOCUMENTATION.md` for the functional overview.

- **Encoding:** source is EBCDIC Hebrew (IBM-424).
- **COBOL numeric notes:** `9(n)` = zoned decimal (n digits), `S` = signed,
  `V` = implied decimal point, `COMP-3` = packed decimal (BCD),
  `BINARY` = 2/4-byte integer, `X(n)` = character.
- **RPGLE type notes:** `a` = character, `s` = zoned, `p` = packed, `i` = integer,
  `n` = indicator, `d`/`t` = date/time, trailing `0`/`2` = decimal positions,
  `varying` = length-prefixed.

---

## 1. Shared transaction record (the central structure)

The same 703-byte record is passed through both programs. It carries the request
in and the authorization result out.

| In program | Name | Layout prefix |
|------------|------|---------------|
| COBOL `SAATCGSL` | `DCCGTRNE-REC` → `DCCGE-REC` | `DCCGE-xxx` |
| RPGLE `SAATCG` | `ECPTRNS` data structure (external) + `ecptrnsv` (703a varying) | `PTxxx` |

The two layouts describe the same bytes. The last 4 letters of the field name
match across languages: `DCCGE-CARN` = `PTCARN`, `DCCGE-RQSC` = `PTRQSC`, etc.

### 1.1 Full field list (`DCCGE-*` / `PTxxx`)

| COBOL field | PIC | RPGLE | Meaning |
|-------------|-----|-------|---------|
| `DCCGE-TERN` | `9(10)` | `PTTERN` | Terminal number (masof) |
| `DCCGE-PTID` | `9(06)` | `PTPTID` | Point id |
| `DCCGE-RQSC` | `X(02)` | `PTRQSC` | Request code — `01`=ishur ragil, `11`=itchul kupa; also drives transaction type (see §1.2) |
| `DCCGE-PCSC` | `X(02)` | `PTPCSC` | Process code |
| `DCCGE-QUEP` | `X(02)` | `PTQUEP` | Queue |
| `DCCGE-WRKS` | `X(10)` | `PTWRKS` | Workstation (also gets tranId 1–10 on return) |
| `DCCGE-PRSL` | `X(10)` | `PTPRSL` | Personal (also gets tranId 11–20 on return) |
| `DCCGE-USRP` | `X(10)` | `PTUSRP` | User profile |
| `DCCGE-USRC` | `X(10)` | `PTUSRC` | User code |
| `DCCGE-RPGM` | `X(10)` | `PTRPGM` | Program |
| `DCCGE-CMPC` | `X(03)` | `PTCMPC` | Company code |
| `DCCGE-SERN` | `9(05) COMP-3` | `PTSERN` | Serial number |
| `DCCGE-DOCN` | `9(12) COMP-3` | `PTDOCN` | Document number |
| `DCCGE-LINN` | `X(03)` | `PTLINN` | Line number |
| `DCCGE-DOCT` | `X(02)` | `PTDOCT` | Document type |
| `DCCGE-RQDT` | `9(08) COMP-3` | `PTRQDT` | Request/transaction date (CCYYMMDD) |
| `DCCGE-TRNO` | `9(06) COMP-3` | `PTTRNO` | Transaction number |
| `DCCGE-RTIM` | `9(06) COMP-3` | `PTRTIM` | Transaction time |
| `DCCGE-TRST` | `X(03)` | `PTTRST` | Transaction status (`000`/spaces = OK) — **set on return** from `Ostatus` |
| `DCCGE-STSD` | `X(79)` | `PTSTSD` | Status description text — **set on return** (extended status text) |
| `DCCGE-REFN` | `9(10) COMP-3` | `PTREFN` | Reference number — **set on return** from tranId |
| `DCCGE-REF1` | `X(30)` | `PTREF1` | Reference 1 |
| `DCCGE-REF2` | `X(20)` | `PTREF2` | Reference 2 — **set on return** to card id / card no |
| `DCCGE-REF3` | `X(08)` | `PTREF3` | Reference 3 — non-numeric auth number storage |
| `DCCGE-TRSM` | `S9(6)V9(2) COMP-3` | `PTTRSM` | Transaction amount (× 100 → `Itotal`) |
| `DCCGE-CRET` | `X(01)` | `PTCRET` | Credit type (see §1.2) |
| `DCCGE-FRSM` | `S9(6)V9(2) COMP-3` | `PTFRSM` | First-payment amount |
| `DCCGE-FXSM` | `S9(6)V9(2) COMP-3` | `PTFXSM` | Fixed/periodical-payment amount |
| `DCCGE-PAYN` | `9(02) COMP-3` | `PTPAYN` | Number of payments |
| `DCCGE-SRSM` | `S9(6)V9(2) COMP-3` | `PTSRSM` | Additional amount |
| `DCCGE-DILC` | `X(01)` | `PTDILC` | Validation/deal code — `2`=bdika, `4`=iska, `5`=isur; drives `iValidation` (see §1.2) |
| `DCCGE-VENN` | `9(07) COMP-3` | `PTVENN` | Supplier/vendor — **set on return** |
| `DCCGE-CURT` | `X(01)` | `PTCURT` | Currency code (see §1.2) |
| `DCCGE-CLBC` | `X(01)` | `PTCLBC` | Club code |
| `DCCGE-APPN` | `9(07) COMP-3` | `PTAPPN` | Approval number — **set on return** (`-9999999` = non-numeric) |
| `DCCGE-APSR` | `X(01)` | `PTAPSR` | Approval source — **set on return** |
| `DCCGE-CRCO` | `X(01)` | `PTCRCO` | Credit company — `1`=Isracard, `2`=Visa-Cal, `3`=Diners, `4`=American Express, `5`=JCB, `6`=Leumi-Card — **set on return** |
| `DCCGE-CANM` | `X(15)` | `PTCANM` | Card name — **set on return** |
| `DCCGE-FORF` | `X(01)` | `PTFORF` | Foreign flag — **set on return** (card type code) |
| `DCCGE-FILN` | `9(02) COMP-3` | `PTFILN` | File number — **set on return** |
| `DCCGE-CHSN` | `9(04) COMP-3` | `PTCHSN` | Kupa code |
| `DCCGE-CSHS` | `9(03)` | `PTCSHS` | Cashier |
| `DCCGE-TRTO` | `X(02)` | `PTTRTO` | Transaction type — **set on return** |
| `DCCGE-DILR` | `X(01)` | `PTDILR` | Deal indicator |
| `DCCGE-SRVC` | `9(03) COMP-3` | `PTSRVC` | Service code |
| `DCCGE-CRDT` | `9(08) COMP-3` | `PTCRDT` | Credit/pay date — **set on return** |
| `DCCGE-TRNC` | `X(02)` | `PTTRNC` | Transaction code — `00`=Regular, `50`=Phone, `60`=Signature, `70`=Internet |
| `DCCGE-CARN` | `9(18) COMP-3` | `PTCARN` | Card number / card-id token (prefix `10`/`15`) |
| `DCCGE-VLDT` | `9(04)` | `PTVLDT` | Card expiration (MMYY) — **set on return** |
| `DCCGE-CIDN` | `9(09) COMP-3` | `PTCIDN` | Card-holder id |
| `DCCGE-CUSN` | `9(12) COMP-3` | `PTCUSN` | Customer number |
| `DCCGE-CUNM` | `X(30)` | `PTCUNM` | Customer name |
| `DCCGE-CUSF` | `X(01)` | `PTCUSF` | Customer flag |
| `DCCGE-TEL1` | `X(15)` | `PTTEL1` | Customer phone |
| `DCCGE-CNTC` | `9(03)` | `PTCNTC` | Country code |
| `DCCGE-STTC` | `X(03)` | `PTSTTC` | State code |
| `DCCGE-CNCA` | `X(02)` | `PTCNCA` | Country abbr. |
| `DCCGE-CTYC` | `9(04) COMP-3` | `PTCTYC` | City code |
| `DCCGE-CTYD` | `X(15)` | `PTCTYD` | City description |
| `DCCGE-ADDR` | `X(30)` | `PTADDR` | Address |
| `DCCGE-ZIPC` | `9(05) COMP-3` | `PTZIPC` | Zip code |
| `DCCGE-T180` | `X(80)` | `PTT180` | Track 2 magnetic-stripe data |
| `DCCGE-BRNC` | `9(04) COMP-3` | `PTBRNC` | Branch |
| `DCCGE-BRS1` | `9(04) COMP-3` | `PTBRS1` | Branch sub 1 |
| `DCCGE-BRS2` | `9(04) COMP-3` | `PTBRS2` | Branch sub 2 |
| `DCCGE-GRUP` | `9(04) COMP-3` | `PTGRUP` | Group |
| `DCCGE-GRS1` | `9(04) COMP-3` | `PTGRS1` | Group sub 1 |
| `DCCGE-GRS2` | `9(04) COMP-3` | `PTGRS2` | Group sub 2 |
| `DCCGE-BNPS` | `9(03) COMP-3` | `PTBNPS` | Payments (bank) |
| `DCCGE-BPYN` | `9(03) COMP-3` | `PTBPYN` | Bank payment number |
| `DCCGE-BCRD` | `9(08) COMP-3` | `PTBCRD` | Bank credit date |
| `DCCGE-BCLD` | `9(08) COMP-3` | `PTBCLD` | Original clearing date (refund key) |
| `DCCGE-BBLD` | `9(08) COMP-3` | `PTBBLD` | Original balance date (refund key) |
| `DCCGE-LOCN` | `9(04) COMP-3` | `PTLOCN` | Location |
| `DCCGE-LOS1` | `9(04) COMP-3` | `PTLOS1` | Location sub |
| `DCCGE-COID` | `X(06)` | `PTCOID` | Company id |
| `DCCGE-MGTF` | `X(01)` | `PTMGTF` | Magnetic flag |
| `DCCGE-LFFL` | `X(01)` | `PTLFFL` | Life flag |
| `DCCGE-SCRN` | `X(01)` | `PTSCRN` | Screen flag |
| `DCCGE-PSLF` | `X(01)` | `PTPSLF` | Policy flag |
| `DCCGE-TRCF` | `X(01)` | `PTTRCF` | Transaction flag |
| `DCCGE-MSGT` | `9(02)` | `PTMSGT` | Message type |
| `DCCGE-MMSR` | `X(02)` | `PTMMSR` | Message reason |
| `DCCGE-CA12` | `X(02)` | `PTCA12` | Card attr 12 — **set on return** (card brand code) |
| `DCCGE-CA14` | `X(04)` | `PTCA14` | Card attr 14 |
| `DCCGE-CA16` | `X(06)` | `PTCA16` | Card attr 16 |
| `DCCGE-CN12` | `9(02)` | `PTCN12` | Card num 12 |
| `DCCGE-CN14` | `9(04)` | `PTCN14` | Card num 14 |
| `DCCGE-CN16` | `9(06)` | `PTCN16` | Card num 16 — **set on return** (slave terminal × 1000 + sequence) |
| `DCCGE-CVV2` | `X(04)` | `PTCVV2` | CVV2 |
| `DCCGE-LS4D` | `X(04)` | `PTLS4D` | Last 4 digits — **set on return** |
| `DCCGE-CL4D` | `X(04)` | `PTCL4D` | Clearing last 4 |
| `DCCGE-BRCO` | `X(01)` | `PTBRCO` | Branch company |
| `DCCGE-CLCO` | `X(01)` | `PTCLCO` | Clearing/acquirer company (same codes as `CRCO`) — **set on return** |
| `DCCGE-ISUR-NEW` | `X(07)` | — | New authorization number — set by COBOL `B80` from API auth number |
| `DCCGE-FILR` | `X(68)` | `PTFILR` | Filler / reserved |

### 1.2 Coded-value cross reference

**Request code `RQSC` → transaction type (RPGLE `ItransactionType`)**

| `RQSC` | Type | `RQSC` | Type |
|--------|------|--------|------|
| `01` | Debit | `55` | CashBack |
| `11` | RecurringDebit | `56` | Cash |
| `51` | Credit | `57` | RecurringDebit |
| `52` | Refund | `59` | BalanceInquiry |
| `54` | Forced | `60` | Load |
|  |  | `61` | Discharge |

**Credit type `CRET`**: `1`=RegularCredit, `2`=IsraCredit, `3`=AdHock,
`4`=ClubDeal, `5`=SpecialAlpha, `6`=SpecialCredit, `8`=Payments, `9`=PaymentsClub.

**Currency `CURT`**: `1`=ILS, `2`=USD, `3`=GBP, `4`=HKD, `5`=JPY, `6`=EUR.

**Transaction code `TRNC`**: `00`=Regular, `50`=Phone, `60`=Signature, `70`=Internet.

**Validation `DILC` → `iValidation`**: `1`=NoComm, `2`=Normal, `B`=Token,
`3`=CreditLimit, `4`=AutoComm, `5`=Verify, `6`=Dealer, `9`=AutoCommHold,
`R`=AutoCommRelease, `Q`=cardNo.

**Credit company `CRCO` / `CLCO`**: `1`=Isracard, `2`=Visa-Cal, `3`=Diners,
`4`=American Express, `5`=JCB, `6`=Leumi-Card.

---

## 2. COBOL `SAATCGSL` structures

### 2.1 Program parameters (LINKAGE)

| Structure | Size | Dir | Fields |
|-----------|------|-----|--------|
| `DCCGTRNE-REC` | 703 | in/out | The transaction record — see §1. |
| `SAATCG-1-PARAM` | 400 | in | `SAATCG-1-LANGUAGE X(1)` (88 `HEB`=1/`ENG`=2), `SAATCG-1-CONFIG-CODE X(1)` (88 `GVIA-DBT`=1/`TVIA-CRD`=2), `SAATCG-1-USER-DATA X(19)`, `SAATCG-1-FILLER X(379)`. |
| `SAATCG-2-PARAM` | 200 | out | `SAATCG-2-AUTH-NUMBER X(7)`, `SAATCG-2-FILLER X(91)`, `SAATCG-2-INTERFACE-RET X(5)` (88 `TAKIN`=`00000`), `SAATCG-2-INTERFACE-TEXT X(10)`, `SAATCG-2-CLCO X(2)`, `SAATCG-2-RETURN X(5)` (88 `TAKIN`=blanks/`00000`), `SAATCG-2-ERROR-TEXT X(80)`. |

### 2.2 API-call parameter blocks (varying, length-prefixed)

These pass data to the RPGLE engine. Each field has a `-L` (`9(3) BINARY` length)
and a `-V` (value) part — matching RPGLE `varying` fields.

**`SAATCGR-1-PARAM`** (request → API)

| Group | Length fld | Value fld | Notes |
|-------|-----------|-----------|-------|
| `SAATCGR-1-LANG` | `-LANG-L 9(3)B` | `-LANG-V X(1)` | Language |
| `SAATCGR-1-CONFIG-CODE` | `-CONF-L 9(3)B` | `-CONF-V X(1)` | Config code |
| `SAATCGR-1-NUMERATOR` | `-NUMR-L 9(3)B` | `-NUMR-V X(16)` | Numerator (from `SAGETBKR`) |
| `SAATCGR-1-USER-DATA` | `-UD-L 9(3)B` | `-UD-V X(19)` | User data |

**`SAATCGR-2-PARAM`** (response ← API)

| Group | Length fld | Value fld |
|-------|-----------|-----------|
| `SAATCGR-2-AUTH-NUMBER` | `-AUTH-NUMBER-L 9(3)B` | `-AUTH-NUMBER-V X(7)` |
| `SAATCGR-2-RETRN` | `-RETRN-L 9(3)B` | `-RETRN-V X(5)` |
| `SAATCGR-2-ERROR-TEXT` | `-ERROR-L 9(3)B` | `-ERROR-V X(80)` |
| `SAATCGR-2-CLCO` | `-CLCO-L 9(3)B` | `-CLCO-V X(2)` |
| `SAATCGR-2-INTERFACE-RETURN` | `-INT-RTN-L 9(3)B` | `-INT-RTN-V X(5)` |
| `SAATCGR-2-INTERFACE-ERR-TEXT` | `-INT-TXT-L 9(3)B` | `-INT-TXT-V X(10)` |

**`DCCGTRNE-IO`** — `DCCGTRNE-IO-REC-L 9(3) BINARY` + `DCCGTRNE-IO-REC-V X(703)`
(the length-prefixed transaction record handed to RPGLE as `ecptrnsv`).

### 2.3 Called-program parameter areas (WORKING-STORAGE)

**`SAGETBKR-PARAM`** — numerator fetch:
`SAGETBKR-PEULA X(1)` (88 `CLOSE`=C / `UPDATE`=U), `SAGETBKR-KNUM 9(4)`
(88 `HIDRQ`=1 / `HIDRE`=2), `SAGETBKR-NUM-RAZ 9(16)`,
`SAGETBKR-RETURN X(3)` (88 `TAKIN`=000 / `ERROR`=002), `SAGETBKR-ERROR-TEXT X(76)`.

**`DCSTRING-PARAM`** — string utility:
`DCSTRING-STRING-IN` (300 × `X`), `DCSTRING-STRING-OUT X(300)`,
`DCSTRING-PEULA X(1)` (88 values: `C`lose, `Z`imzum/compress, `R`evers,
`U`pper-case, `S`oundex, `X`=zimzum-no-space, `I`=simun-ri, `H`=revers-char,
`L`=revers-char-sl, `E`=remove-err-val), `DCSTRING-IN-LEN 999`,
`DCSTRING-OUT-LEN 999`, `DCSTRING-LANG X(1)` (88 `HEB`=H / `ENG`=E),
`DCSTRING-RETURN X(2)` (88 `TAKIN`=00 / `PEULA`=01 / `IO-ERR`=02 / `ERR`=99).

**`ERRTV-PARAM`** — error-message fetch (`TBERR`):
`ERRTV-PEULA X(1)` (88 `READ`=R / `CLOSE`=C), `ERRTV-MSG-NO X(5)`,
`ERRTV-RETURN X(2)` (88 `OK`=00 / `ERR`=01 / `NOT-FOUND`=02),
`ERRTV-MSG-TXT X(76)` (redefined to expose an embedded `ERRTV-MSG-MSG-NO X(5)`).

**`PRM-DCPCIMSF-*`** — (declared, `DCPCIMSF` not called in main flow):
`KVUZ X(2)`, `TERN7 X(7)`, `RETURN X(2)` (88 `TAKIN`=00), `TERN10 X(10)`.

### 2.4 File-operation / status enumerations

**`SA-PEULA 9(2)`** — file action code: `0`=close, `1`=read-random,
`2`=read S EQ, `3`=read S not-less, `4`=read-next, `5`=read-prior, `6`=read-last,
`7`=S-not-less, `8`=S-greater, `9`=delete, `10`=rewrite, `11`=write,
`12`=delete-no-chk, `13`=rewrite-no-chk.

**`SA-RETURN X(2)`** — file result: `00`=OK, `01`=error, `02`=EOF, `03`=BOF,
`04`=change, `05`=lock, `06`=out-of-range/EOTV, `99`=bad peula.

### 2.5 Date-conversion copybook

**`DT2TRN`** — a large block of redefinitions of one date value in every common
format and length. Groups: `DMY`/`MDY`/`YMD` at 6, 7, and 8 digits (plus
"ARUCH" = punctuated `X(8)`/`X(10)` variants with `SL` separators), plus
`YM`/`MY`/`CYY`/`YYMM`/`MMYY`/`CYYMM`/`CYM`/`YYM`/`MYY`/`YYYY` sub-forms. Each
sub-field breaks out `-DD`/`-MM`/`-YY`/`-CC`/`-C` components.
`DT2TRN-SW-EDIT X(1)` selects DMY vs MDY editing.

**`DTW-PARM`** — date-utility call block:
`DTW-PEULA X(2)` (dozens of 88s: return-date, hef/add days-months-years,
reverse, system date, new month/year end, day-in-week…),
`DTW-DATE1-DEF` / `DTW-DATE2-DEF` (each `MIVNE X(1)` `S`=DMY/`F`=YMD +
`LENGTH X(1)` 6/7/8), `DTW-PARAM1`/`DTW-PARAM2` (`DTW-DATE1`/`DTW-DATE2 9(8)`
with `-C`/`-YMD`/`-14`/`-56`/`-78` redefines), `DTW-PARAM3` (`DTW-DAYS S9(6)`),
`DTW-PARAM4` (`DTW-RETURN-KOD X(2)`: `00`=OK, `01`/`02`/`41`=date errors,
`71`–`77`=numeric/structure/length errors, `99`=days error).

### 2.6 Work areas & switches

**`EZER`** — general work fields: `EZ-UDATE 9(8)`, `EZ-UDATE-YMD X(8)`,
`EZ-TIME` (`HH`/`MM`/`SS 9(2)`), `EZ-DT` (`YYYY`/`MM`/`DD`), `EZ-DT10`
(punctuated), `EZ-SUG-N 9(3)`, `EZ-TVIA-N 9(13)`, `EZ-STRING X(300)`,
`EZ-TXT-300-IN/-OUT X(300)` + `-LEN 9(3)`, `EZ-LEN 9(3)`, `EZ-ERR-TXT X(9)`,
`EZ-ERR-KTXT X(5)`, `EZ-MOB` (`KOD X(3)` + `NUM X(7)`), and an input/output
block (`EZ-IN-LANG`, `EZ-IN-CONFIG-CODE`, `EZ-IN-UD X(19)`, `EZ-IN-FILLER X(379)`,
`EZ-OUT-AUTH-NUMBER X(7)`, `EZ-OUT-FILLER X(108)`, `EZ-OUT-RETRN X(5)`,
`EZ-OUT-ERROR X(80)`).

**Others:** `MAS-USR`/`MAS-JOB X(10)`, `MAS-JOBNUM X(6)`; `INDEXX` (`I`/`J`/`LENN 9(3)`);
`SWITCH` (`SW-END-JOB`, `SW-BEG-END`, `SW-ERROR`, each `9(1)` with on/off 88s).

---

## 3. RPGLE `SAATCG` structures

### 3.1 Entry parameters

| Name | Kind | Purpose |
|------|------|---------|
| `SAATCGI` (`saatcgi` DS) | in | `SACGLANG 1a`, `SACGCONF 1a`, `SACGNUMR 16a`, `SACGUD 19a` — all `varying`. |
| `SAATCGO` (`saatcgo` DS) | out | `SACGCGAU 7a` (auth), `SACGREST 5a` (status), `SACGERTX 80a` (error text), `SACGCLCO 2a` (clearing), `SACGINST 5a` (interface status), `SACGINTX 10a` (interface text) — all `varying`. |
| `ecptrnsv` | in/out | `703a varying` — the transaction record; copied to/from `ecptrns`. |

### 3.2 `InputParm` — values sent to CreditGuard (`Ixxx`)

Populated by `InitProgram`/`BuildWSBody` from the `PTxxx` record.

| Field | Type | Field | Type |
|-------|------|-------|------|
| `IRequestId` | `20a` | `Iid` | `9s 0` |
| `ITerminalId` | `10a` | `ItransactionType` | `20a` |
| `ICardNumber` | `19a` | `ICreditType` | `20a` |
| `ICardId` | `16a` | `ICurrency` | `10a` |
| `IcardExpiration` | `4s 0` | `ItransactionCode` | `20a` |
| `Icvv` | `4s 0` | `ITotal` | `10s 0` |
| `IauthNumber` | `7a` | `IfirstPayment` | `10s 0` |
| `Ivalidation` | `15a` | `IperiodicalPayment` | `10s 0` |
| `IClubCode` | `1a` | `InumberOfPayments` | `10s 0` |
| `ITimeout` | `3s 0` | `IrecurringTotalNo` | `3s 0` |
| `IrecurringTotalSum` | `10s 2` | `IrecurringNo` | `3s 0` |
| `IrecurringFrequency` | `3s 0` | | |

### 3.3 `OutputParm` — values received from CreditGuard (`Oxxx`)

Populated by the `EndElement` XML callback; consumed by `BuildResponse`.

| Field | Type | Field | Type |
|-------|------|-------|------|
| `ODateTime` | `20a` | `OcardAcquirer(+Code/Code2)` | `20a`/`1s`/`2s` |
| `ORequestId` | `20a` | `OserviceCode` | `20a` |
| `OTranId` / `OTranId20` | `9s 0` / `20a` | `Otransaction­Type(+Code)` | `20a` / `2s 0` |
| `OLanguage` | `3a` | `OcreditType(+Code)` | `20a` / `1s 0` |
| `OResult` | `3s 0` | `Ocurrency(+Code)` | `10a` / `1s 0` |
| `OMessage` | `80a` | `Otransaction­Code(+Code)` | `20a` / `2s 0` |
| `OUserMessage` | `80a` | `Ototal` / `Obalance` / `OStarTotal` | `10s 0` |
| `OAdditionalInfo` | `80a` | `OFirstPayment` / `OPeriodicalpayment` | `10s 0` |
| `OVersion` | `4a` | `ONumberOfPayments` | `2s 0` |
| `OStatus` | `3s 0` | `OclubId` / `OclubCode` | `8s` / `1s` |
| `OstatusText` | `80a` | `Ovalidation(+Code)` | `20a` / `3s 0` |
| `OTerminalNumber` | `10a` | `OcommReason(+Code)` | `20a` / `1a` |
| `OcardName` | `20a` | `OidStatus(+Code)` / `OidSource(+Code)` | `20a` / `1s` |
| `OcardType(+Code)` | `20a` / `2s 0` | `OcvvStatus(+Code)` | `20a` / `1s 0` |
| `OcreditCompany(+Code)` | `20a` / `2s 0` | `OauthSource(+Code)` | `20a` / `1s 0` |
| `OcardBrand(+Code)` | `20a` / `1s 0` | `OauthNumber` | `7a` |
| `OCardId` / `OCardBin` / `OCardMask` | `16a` | `OFileNumber` | `2s 0` |
| `OCardLength` | `2s 0` | `OslaveTerminalNumber/Sequence` | `3s 0` |
| `OCardNo` | `19a` | `OcreditGroup` / `OpinKeyIn` / `Opfsc` / `Oeci` | `20a` |
| `OCardExpiration` | `4s 0` | `Ocavv(+Code)` | `50a` / `1a` |
| `Ouser` | `19a` | `OaddonData` | `8s 0` |
| `OsupplierNumber` | `20a` | `OintIn` / `OintOt` | `120a` |
| `OpayDate` | `10a` | `OextendedStatus(+Text)` | `5s 0` / `80a` |

### 3.4 Configuration & runtime standalones

| Field | Type | Purpose |
|-------|------|---------|
| `samainda` (DS, `dtaara`) | `Daguid 36a`, `Dalng 1a`, `Daenv 10a`, `Dfiller 953a` | Data area — supplies environment name. |
| `WSUSR/WSPWD/WSURL/WSDTL/WSTRM/WSNTKN` | `10a` | Parameter **names** looked up in `SAMAINPF` (`CGGCOMTUSR`, `CGGCOMTPWD`, `CGGCOMTURL`, `CGGCOMTDTL`, `CGGCOMTTRM`, `CGGCOMNTKN`). |
| `usr` / `pwd` | `100a` | Resolved credentials. |
| `url` | `128a` | Endpoint URL. |
| `TRM` | `100a` | Logical terminal (config 2). |
| `NONTKN` | `1a` | Non-token flag. |
| `Soap` / `tmpsoap` | `32000a varying` | SOAP request buffer. |
| `Header` / `Body` / `Footer` | `1024a varying` | XML fragments. |
| `wCustomerData` | `512a` | `<customerData>` fragment. |
| `tmpBuff` / `logBuff` | `8196a` | HTTP/convert buffers. |
| `logString` | `2048a` | Log message. |
| `cvtInBuff` / `cvtOutBuff` | `8196a` | Code-page conversion buffers. |
| `frmCCSID` / `toCCSID` | `6a` | `00424` (EBCDIC-Heb) / `01208` (UTF-8). |
| `swLog` | `10i 0` inz(3) | Minimum log level (DEBUG 1 … SEVERE 9). |
| `swCardId` / `swCredit` / `swEndOk` / `swEndXML` | `n` | State flags. |
| `Language` | `3a` | `Heb`/`Eng`. |
| `Version` | `4a` inz(`2000`) | Protocol version. |
| `TimeOut` | `10i 0` | HTTP timeout (set to 60). |
| `ABCDEFGHJK` | `10a` | Per-step debug-log toggle string (`CGGCOMTDTL`); each position enables a log point. |

**Named constants:** `DEBUG`=1, `INFO`=3, `WARNING`=5, `ERROR`=7, `SEVERE`=9.

### 3.5 Files & externally-described structures

| Object | Kind | Notes |
|--------|------|-------|
| `SAMAINPF` | input, keyed (`if e k disk`) | Parameter master; keyed by system name + parm name; field `SAVALUE`. |
| `SAATCGLG` | output (`o e disk`) | Log file; record `SAATCGR` (`jldate`, `jltime`, `jljname`, `jljusr`, `jljnbr`, `jlprog`, `jlproc`, `jlsts`, `jltext`). |
| `SACGTRNS` | output (`o e disk`) | Transaction log; record `SACGTRNSR` with `SAxxx` fields mirroring the `PTxxx` record + job/user/date/time + `SASRIN` (1=send/2=receive). |
| `ecptrns` | ext DS (`extname(ecptrns)`) | The transaction record (`PTxxx`). |
| `int_ot` | ext DS (`extname(int_ot)`) | Interface-output structure. |
| PSDS | `/include psds` | Program status (`program`, `jobname`, `jobusr`, `jobnbr`, `uyear`/`umonth`/`uday`). |

### 3.6 Extended status codes (returned in `SACGREST` / `OextendedStatus`)

| Code | Meaning |
|------|---------|
| `00000` | Permitted transaction |
| `99002` | Communication problem with the credit interface |
| `99003` | Data problem in the CG response (parse/convert) |
| `99005` | General credit-interface problem (missing config) |
| `99006` | TOKEN problem |
| `99010` | Error in the credit interface (no valid XML end) |
