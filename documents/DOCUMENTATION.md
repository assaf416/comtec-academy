# SAATCG / SAATCGSL — CreditGuard Credit-Card Gateway

Documentation for two IBM i (AS/400) programs that together form a credit-card
authorization / clearing interface to the **CreditGuard ("Ashrait")** payment
gateway over SOAP/HTTP.

> **Note on encoding.** Both source files are stored in **EBCDIC Hebrew code
> page 424** (IBM-424). Read/edit them with a 424-aware tool, or convert with
> `iconv -f IBM424 -t UTF-8`. Opening them as ASCII/UTF-8 shows garbage. The
> comments are Hebrew (right-to-left); the code itself is standard COBOL/RPGLE.

---

## 1. Overview

| Program | Language | Role |
|---------|----------|------|
| `SAATCGSL` (`saatcgsl.cbl`) | ILE COBOL | **Wrapper / monitor.** Called by the business application. Validates and packs the parameters, calls the API program, and unpacks the response back into the transaction record. |
| `SAATCG` (`saatcg.rpgle`) | ILE RPGLE (free-form) | **API engine.** Builds a SOAP XML request from the transaction record, sends it to the CreditGuard server over HTTP, parses the XML response, and maps the results back into the transaction record. |

Call chain:

```
Business app
   │  (DCCGTRNE-REC, SAATCG-1-PARAM, SAATCG-2-PARAM)
   ▼
SAATCGSL  (COBOL wrapper)
   │  CALL 'SAATCG'  (SAATCGR-1, SAATCGR-2, DCCGTRNE-IO)
   ▼
SAATCG    (RPGLE)  ──HTTP/SOAP──►  CreditGuard "Ashrait" server
   │                              ◄──XML response──
   ▼
transaction record (ECPTRNS / DCCGE) updated with authorization result
```

The transaction record is the shared data structure. In COBOL it is the
`DCCGE-*` layout (linkage `DCCGTRNE-REC`); in RPGLE it is the externally
described `ECPTRNS` data structure with `PTxxx` field names. They describe the
same 703-byte record.

---

## 2. SAATCGSL — COBOL wrapper (`saatcgsl.cbl`)

### 2.1 Purpose (from the source header)

A monitor/wrapper routine invoked **before** the CG API. It performs:

- parameter validity checks (תקינות פרמטרים)
- building the API parameters (בניית פרמטרים ל-API)
- calling the API (קריאה ל-API)
- processing the parameters returned from the API (עיבוד פרמטרים חוזרים)
- adding USER DATA — e.g. policy branch (תוספת USER DATA)

### 2.2 Program parameters (`PROCEDURE DIVISION USING`)

| # | Name | Size | Direction | Contents |
|---|------|------|-----------|----------|
| 1 | `DCCGTRNE-REC` | 703 | in/out | The credit-card transaction record (`DCCGE-*` layout: terminal, card, amounts, payments, customer, references, and the returned status/authorization). |
| 2 | `SAATCG-1-PARAM` | 400 | in | Request options. |
| 3 | `SAATCG-2-PARAM` | 200 | out | Response summary. |

**`SAATCG-1-PARAM` (input)**

| Field | Values |
|-------|--------|
| `SAATCG-1-LANGUAGE` | `1`=Hebrew, `2`=English |
| `SAATCG-1-CONFIG-CODE` | `1`=Gvia/Direct-debit (`CONFIG-GVIA-DBT`), `2`=Tvia/Credit (`CONFIG-TVIA-CRD`) |
| `SAATCG-1-USER-DATA` | 19-char user data (e.g. policy branch) |
| `SAATCG-1-FILLER` | 379-char reserved |

**`SAATCG-2-PARAM` (output)**

| Field | Meaning |
|-------|---------|
| `SAATCG-2-AUTH-NUMBER` | 7-char authorization number |
| `SAATCG-2-INTERFACE-RET` | 5-char interface return (`00000` = OK) |
| `SAATCG-2-INTERFACE-TEXT` | 10-char interface text |
| `SAATCG-2-CLCO` | 2-char clearing / acquirer code |
| `SAATCG-2-RETURN` | 5-char return code (`00000`/blanks = OK) |
| `SAATCG-2-ERROR-TEXT` | 80-char error text |

### 2.3 Control flow

```
A-TOCHNIT-RASHIT (main)
├─ ZA-ATCHALAT-TOCHNIT      initialize working storage & switches
├─ B-TIPUL                  main processing
│  ├─ B20-TIPUL-PER-CONFIG  per-config setup
│  │  ├─ B21-TIPUL-CONFIG-ALL   get numerator via SAGETBKR → SAATCGR-1-NUMERATOR
│  │  ├─ B22-CONFIG-GVIA-DBT    (config 1) call SAATCGSL#P; default credit co. = Isracard
│  │  └─ B24-CONFIG-TVIA-CRD    (config 2) reserved / no-op
│  ├─ B40-EDIT-FIELDS       build the varying-length API-1 parameters
│  │  ├─ B42-MOVE-LANG      language  → SAATCGR-1-LANG   (via F00)
│  │  ├─ B44-MOVE-CONF      config    → SAATCGR-1-CONFIG (via F00)
│  │  ├─ B46-MOVE-DCCGTRNE  703-byte record → DCCGTRNE-IO-REC
│  │  └─ B48-MOVE-UD        user data → SAATCGR-1-USER-DATA (via F00)
│  ├─ R00-CALL-API-CG       CALL 'SAATCG'  (the RPGLE engine)
│  └─ B80-TIPUL-RESPONSE    copy SAATCGR-2 results → SAATCG-2-PARAM & DCCGE-ISUR-NEW
└─ ZZ-SIYUM-TOCHNIT         end; for config 1 default credit co. = Isracard
```

Helper section **`F00-TIPUL-FLD`** trims/compresses a field by calling the
`DCSTRING` utility (peula `Z` = *zimzum*/compress) and computing the significant
length (`F20-GET-LENGTH`). This produces the length-prefixed varying fields the
RPGLE engine expects (`SAATCGR-1-*` each carry a `-L` length and `-V` value).

### 2.4 External programs called

| Program | Via | Purpose |
|---------|-----|---------|
| `SAATCG` | `R00-CALL-API-CG` | The RPGLE API engine (see §3). |
| `SAGETBKR` | `R30-CALL-SAGETBKR` | Fetch the *numerator* / razes number for the request. |
| `SAATCGSL#P` | `R20-CALL-CHGSSID` | Session/SSID change helper (config 1). |
| `DCSTRING` | `F10-READ-DCSTRING` | String utility (compress/trim). |
| `TBERR` | `S-CALL-ERRORTV` | Fetch error-message text (`ERRTV-*` params). |
| `DCPCIMSF` | `R10-CALL-DCPCIMSF` | Present but not invoked in the main flow. |

### 2.5 Return-code reference (from level-88s)

- `SA-RETURN` — file-op status (`00` OK, `02` EOF, `05` lock, `99` bad peula…).
- `DTW-RETURN-KOD` — date-utility status (`00` OK, `71`–`99` various validation errors). The large `DT2TRN` / `DTW-PARM` blocks are a **date-conversion copybook** carried in working storage (many format redefinitions DMY/MDY/YMD in 6/7/8-digit forms).

---

## 3. SAATCG — RPGLE API engine (`saatcg.rpgle`)

### 3.1 Purpose (from the source header)

> `ws generic program` — Prepare XML request into a SOAP variable, send it to the
> server (`SendToServer`), parse the reply, and build the response.

It integrates with **CreditGuard's "Ashrait" `doDeal`** SOAP web service using
Scott Klement's **HTTPAPI** (`bnddir('QC2LE':'TFHTTP')`,
`/include libhttp/qrpglesrc,httpapi_h`).

### 3.2 Entry parameters (`*ENTRY PLIST`)

| # | Name | Meaning |
|---|------|---------|
| 1 | `SAATCGI` | Input structure: language, config code, numerator, user data (`SACGLANG`, `SACGCONF`, `SACGNUMR`, `SACGUD`). |
| 2 | `SAATCGO` | Output structure: auth code, 5-digit status, error text, 2-digit clearing code, interface status/text (`SACGCGAU`, `SACGREST`, `SACGERTX`, `SACGCLCO`, `SACGINST`, `SACGINTX`). |
| 3 | `ecptrnsv` | The 703-byte transaction record (varying), corresponding to `ECPTRNS` (`PTxxx` fields). In/out. |

### 3.3 Files used

| File | Type | Purpose |
|------|------|---------|
| `SAMAINPF` | input, keyed | Parameter master — holds user, password, URL, detail flags, terminal, non-token flag per environment/system name. |
| `SAATCGLG` | output | Application log (severity-controlled `WriteLog`). |
| `SACGTRNS` | output | Full transaction log, written on both send and receive. |

Data area **`SAMAINDA`** supplies the environment name (`Daenv`) used to look up
parameters.

### 3.4 Main flow (`/free`)

```
InitProgram()      → BuildWS()  → SendToServer(SoapAction) → BuildResponse()
```

If `InitProgram` returns non-zero (missing config), the request is skipped and an
error status is returned.

### 3.5 Procedures

| Procedure | Responsibility |
|-----------|----------------|
| **`InitProgram`** | Reads `SAMAINDA`; fetches USR/PWD/URL/DTL/TRM/NTKN from `SAMAINPF` via `GetParmValue` (missing → status `99005`, Hebrew "general credit-interface error"). Maps the `ECPTRNS` (`PTxxx`) transaction into `InputParm` (`Ixxx`): request id, terminal, card number vs. **card-id/token** (prefixes `10`/`15`), expiration, CVV, holder id, and translates coded fields to CreditGuard text — transaction type (`PTRQSC` → Debit/Credit/Refund/Load/…), credit type (`PTCRET`), currency (`PTCURT` → ILS/USD/GBP/HKD/JPY/EUR), transaction code (`PTTRNC` → Regular/Phone/Signature/Internet), validation (`PTDILC` → Normal/Token/AutoComm/…), payments/recurring, club code. Writes the "send" transaction log. |
| **`BuildWS`** | Concatenates `Header + Body + Footer` into `Soap`. |
| **`BuildWSHeader`** | SOAP envelope + `<xpo:user>`/`<xpo:password>` + opening `<xpo:int_in>`. |
| **`BuildWSBody`** | The `<![CDATA[ <ashrait><request><command>doDeal</command> … ]]>` payload: request id, version (`2000`), language, `doDeal` with terminal, track2 / cardNo / cardId, expiration, cvv, id, recurring EMV data, transaction type/credit/currency/code, auth number, total, validation, payments, club code, `user`, refund key, and `customerData` (phone, docType/docNum, compCode, customerNumber, userData1, codeKupa). |
| **`BuildWSFooter`** | Closing `int_in` / `ashraitTransaction` / envelope tags. |
| **`SendToServer`** | Sets CCSID 1208 (UTF-8); masks the PAN in the log; converts the buffer 424→1208 (`ConvertBuf`); POSTs via `http_url_post_xml` to `url` with SOAPAction `http://tempuri.org/ashraitTransaction`, 60-s timeout; parses the reply with `http_parse_xml_string` using `EndElement` as the end-element handler. Sets status `99002` on comms failure, `99010` if no valid XML end was seen. Masks `cardBin`/`cardMask` in logs. |
| **`EndElement`** | XML-parse callback. For path `/ashrait/response` fills header fields (command, dateTime, requestId, tranId, result, messages, version, language). For `/ashrait/response/doDeal` (and `refundDeal`) fills the full deal result into `OutputParm` (`Oxxx`): status/extendedStatus (+ text), card details (id/bin/mask/no/name/expiration/length), card type/brand/acquirer/credit company (+ codes), amounts (total/balance/starTotal/payments), club, validation, id/cvv/auth source, auth number, file & slave-terminal numbers, credit group, eci/cavv, user, supplier, intIn/intOt, payDate. All numeric conversions are wrapped in `MONITOR` blocks that set interface status `99003` on bad data. `status` marks XML end (`swEndXML`). |
| **`ConvertBuf`** | Code-page conversion between EBCDIC-Hebrew **424** and UTF-8 **1208** via the `CONVERT` program; also writes the buffer to an IFS file for debugging. |
| **`BuildResponse`** | Maps `OutputParm` back into the `ECPTRNS` (`PTxxx`) record: status (`PTTRST`), 5-digit extended status (`SACGREST`), credit-company code, acquirer/clearing codes, transaction-type/auth-source codes, tran id → reference & work/personal fields, card number/id handling incl. **token** logic (`NONTKN`), card name, auth number (numeric vs. non-numeric via `MONITOR`), file number, card brand/type, expiration, supplier, slave terminal, pay date. Sets Hebrew error text for `99002`/`99003`/`99006`/`99010`. Writes the "receive" transaction log and returns the updated record in `ecptrnsv`. |
| **`WriteLog`** | Writes a record to `SAATCGLG` when the message level ≥ `swLog` (default `INFO`=3). Severity constants: DEBUG 1, INFO 3, WARNING 5, ERROR 7, SEVERE 9. |
| **`GetParmValue`** | `CHAIN (systemName : parmName)` on `SAMAINPF`; returns `SAVALUE` or `*NotFound`. |
| **`WriteTrnsLog`** | Copies every `PTxxx` field into the `SACGTRNS` record (masking the PAN for non-token cards) plus job/user/date/time, and writes it. Called once on send (`SRInd='1'`) and once on receive (`SRInd='2'`). |
| **`WriteFile`** | Writes the request/response XML to `/tmpcgg/<pgm>_<date>_<time>_<msec>_<suffix>.xml` on the IFS for troubleshooting. |

### 3.6 Extended status codes (RPGLE)

| Code | Meaning (Hebrew original) |
|------|---------------------------|
| `00000` | Permitted transaction / הניקת הקסע |
| `99002` | Communication problem with the credit interface (תרושקת) |
| `99003` | Data problem in the CG response (parse/convert error) |
| `99005` | General credit-interface problem (missing config) |
| `99006` | TOKEN problem |
| `99010` | Error in the credit interface (no valid XML) |

### 3.7 Security / logging notes

- The PAN (card number) is masked with `*` in `SACARN` for non-token cards before
  being written to `SACGTRNS`, and `cardNo` / `cardBin` / `cardMask` are masked in
  the `SAATCGLG` log strings.
- User/password/URL come from `SAMAINPF` keyed by environment, not hard-coded
  (only the *parameter names* `CGGCOMTUSR`, `CGGCOMTPWD`, `CGGCOMTURL`, etc. are
  in source).
- `WriteFile` dumps full request/response XML to `/tmpcgg/` — useful for
  debugging but be aware it can contain sensitive data.

---

## 4. Field-name conventions (quick reference)

| Prefix | Where | Meaning |
|--------|-------|---------|
| `PTxxx` | RPGLE | Fields of the `ECPTRNS` transaction record (shared record). |
| `DCCGE-xxx` | COBOL | Same transaction record, COBOL linkage layout. |
| `Ixxx` | RPGLE `InputParm` | Values sent **to** CreditGuard. |
| `Oxxx` | RPGLE `OutputParm` | Values received **from** CreditGuard. |
| `SACGxxx` | both | The `SAATCGI`/`SAATCGO` API interface fields. |
| `SAATCGR-1/2` | COBOL | Length-prefixed (varying) parameter blocks passed to the RPGLE engine. |
| `DTW-/DT2TRN-` | COBOL | Date-conversion copybook (working storage). |

---

## 5. Build / environment notes

- **RPGLE** `SAATCG`: requires HTTPAPI (`TFHTTP` binding directory + `libhttp`
  source includes), `QC2LE`, and the `qsysinc` / `ifsio` / `stdio` includes.
  Uses `dftactgrp(*no)`.
- **COBOL** `SAATCGSL`: ILE COBOL, `PROCESS APOST`, target `AS-400`.
- Both rely on external DDS objects: `SAMAINPF`, `SAATCGLG`, `SACGTRNS`,
  `ECPTRNS`, `INT_OT`, and the `SAATCG`/`SAATCGSL#P`/`SAGETBKR`/`DCSTRING`/`TBERR`
  programs being present on the library list.
