<a id="ieee-1800-2023-第34章保護エンベロープ215-要求の境界監査"></a>

# IEEE 1800-2023 Chapter 34 (Protection Envelope) 215 Requirement Boundary Audit

[English](protected-envelope-boundary.en.md) / [日本語](protected-envelope-boundary.md)

> The following is an audit log for the 215 requirement prior to the denominator review. After merging the duplicate 1 lines in the review,
> Chapter 34 has 214 requirements: 5 mapped and 209 unmapped. The current values are
> See [Aggregated Summary](behavior-coverage-summary.en.md).

- Date of inspection: 2026-10-28
- Scope: 215 requirements whose clause in `coverage/behaviors.json` begins with `34` and has neither `checks` nor `check_groups`. Used the behavior text as the authoritative source. The contents of `kind` are normal 205 / error 9 / boundary 1.
- Tools: Icarus Verilog 13.0 and Verilator 5.052 (2026-09-05)
- Tests added: 4 for `tests/ch34/test_34_extra_*.sv`, 4 for `.expected`, and 1 for `tests/ch34/ch34_include/lexical_env.svh`. The existing test is not changed.
- Evidence files in [ `protected-envelope-boundary/` ](protected-envelope-boundary/) contain classifications and reasons for each requirement (`ch34-boundary.json`, referred to below as JSON), probe scripts (`probe.sh`), and raw output (`probe-log.txt`).
- Read and cited the local IEEE 1800-2023 PDF standard text using `pdftotext -layout` (the text is not distributed). All the following citations are taken from the corresponding sections of the chapter 34.

<a id="1-結果"></a>

## 1. Results

|Classification|Requirement count|Number of test files|
|---|---:|---:|
|Testing (new)| 5 | 4 |
| not_testable | 210 | – |
|Total| 215 | 4 |

- The 5 requirements given tests comprise 4 normal and 1 boundary requirements (`SV2023-34.2-EXTRACT-DECRYPTION-ENVELOPE`, the only boundary requirement in Clause 34). The not_testable 210 items are normal 201 items and error 9 items.
- Icarus 13.0: `2/2 tests match; 2 known differences not counted` (the 2 tests specific to Verilator are known because their payload is a syntax error under Icarus).
- Verilator 5.052: `4/4 tests match` （`python3 tools/run_verilator.py --all -j 4 ... tests/ch34/*.sv`）。
- `python3 tools/lint_metadata.py tests/ch34/*.sv` → `4 tests checked: 0 new problems, 0 known, 0 gone`（exit 0）。

Conclusion of this chapter: Neither tool does "decrypt" IEEE 34. Icarus ignores all `` `pragma protect ``, while Verilator discards only the base64 body of `data_block`/`key_block`. Thus, for most of the 215 requirements, the prescribed observations (cleartext substitution, key selection, digest comparison, licence checks, errors) cannot be produced in principle. Even the 5 tested requirements are limited to acceptance of syntax and exclusion of a region from parsing; no claim is made that protection worked.

<a id="2-方法"></a>

## 2. Methods

1. Extracted 215 entries for clause 34 with empty checks/check_groups from `coverage/behaviors.json` (confirmed the counts match with `python3 -c`).
2. Read Chapter 34's standard text (34.1–34.5.32), classifying whether each behavior concerns input syntax, encrypted output, decryption input, or errors.
3. I created a minimum `.sv` in the working directory and ran compile/lint/ with both tools. The reproduction script is `protected-envelope-boundary/probe.sh` (it also generates input `.sv`); raw output is `protected-envelope-boundary/probe-log.txt` (P0–P20). The section numbers of the logs are "P4" and so on, and the summary is given in one line in `probes` of JSON.
4. The criterion of "observable" is that the output or diagnosis is inherent in the rule. It is not tested simply because the compilation passes, or because it "passes as an ignored result".
5. Assigned all 215 cases to either 5 tested cases or 210 not_testable cases (`not_testable` in JSON gives reasons for 210 cases).

<a id="3-実測-2-つのツールは何をするか"></a>

## 3. Measurements: what the 2 tools do

### 3.1 Icarus Verilog 13.0

|Fact|Experimental measurement|
|---|---|
|No options for protect/decrypt|Protect related items to `iverilog -h` and `vvp -h` are 0 items (P0).|
|Ignore all rows in `` `pragma protect ``|Compiled successfully without diagnosis even with unknown keywords (P1)|
|The plaintext in the envelope is compiled as a normal source.|The `module` in `begin_protected` is executed and the `SECRET RAN` is output (P3). Also run `$display("inside")` in `initial` (P17)|
|base64 The main part is read as "source."|The next line of `data_block` is `syntax error` ( P4 ). The same across all include (P13)|
|Do not diagnose unmatched delimiters|Both isolated `end_protected` and unclosed `begin_protected` are successful ( P12 ).|
|8 levels of nesting also “succeed”|However, because the contents are not interpreted, this is not evidence of nesting support (P11)|
|There is no old form `` `protected `` / `` `endprotected ``.|Warning and syntax error for undefined macro (P18)|

Icarus treats `` `pragma `` as an unknown pragma line and does not parse any Chapter 34 syntax. Icarus 34 Chapter tests, therefore, only indicate that the line is by chance a standard-correct ignored text.

### 3.2 Verilator 5.052

|Fact|Experimental measurement|
|---|---|
|Lexically analyze only some protect keywords|Accepts 12 of the 32 words in Table 34-1 plus nonstandard `version`, and rejects 20 words with ``Unknown '`pragma protect' error`` (P19).|
|`begin_protected` / `end_protected` will be accepted.|Exit with empty pair 0 ( P2 )|
|However, plain text in the envelope is not excluded.|The `$display` between `begin_protected` and `end_protected` is executed (P17). `module` is also compiled normally (P3).|
|Read and discard only the base64 body of `data_block` / `key_block`|With warning of ``A '`pragma protected data_block' encrypted section was detected and will be skipped.``, consuming the declared `bytes` (P4)|
|The main part is from the next line.|If you put `data_block` on the same line as base64, you get ``Unknown '`pragma protect' error`` (P16).|
|`encoding` is reserved for base64|The `uuencode`, `quoted-printable`, and `raw` are `Unsupported: only BASE64 is recognized` ( P7 ). Error if `line_length` is not a multiple of 4 (P8)|
|`bytes` for 1 `encoding` is shared across all blocks|Placing `key_block` and `data_block` in 1 envelope fails with `BASE64 encoding (too short)`/`length mismatch` (P6). If `encoding` is placed in each block, it is rejected by ``Multiple '`pragma protected encoding sections'`` (P20). The actual envelope with the key block cannot be accepted.|
|Does not decrypt|Passing `--protect-key` does not change the handling of the IEEE envelope; the same skip warning appears (P14). If you put the module in `data_block`, it will be `Cannot find file containing module` (P15).|
|There's no old form `` `protected ``.| `Define or directive not defined`（P18） |

The "skip" of Verilator is a deletion rather than a decoding. The contents of `data_block` are not passed to source parsing, but are not converted back to cleartext either. Thus, neither 34.2's “conversion to cleartext” nor 34.3's “decryption” can be observed.

<a id="33-表-34-1-のキーワード認識p19"></a>

### 3.3 Table 34-1 Keyword Recognition (P19)

Verilator 5.052 accepts (13):

```
end  begin_protected  end_protected  version  encrypt_agent
encrypt_agent_info  encoding  data_method  key_keyowner  key_method
key_keyname  data_block  key_block
```

Reject with ``Unknown '`pragma protect' error`` (20):

```
begin  author  author_info  data_keyowner  data_keyname  data_public_key
data_decrypt_key  digest_keyowner  digest_key_method  digest_keyname
digest_public_key  digest_decrypt_key  digest_method  digest_block
key_public_key  decrypt_license  runtime_license  comment  reset  viewport
```

Icarus ignores all 32 words as "unknown pragma" (neither accepts nor rejects). This asymmetry is the biggest branch of whether or not to write the test in the 34 chapter.

<a id="34-観測できた事実とできなかったこと"></a>

### 3.4 What we could observe and what we couldn't

1. The bare spellings `begin_protected` / `end_protected` are accepted, but Verilator rejects them when arguments are supplied (P2, P19).
2. Both tools accept 8 levels of delimiter nesting (P11).
3. Verilator uses `bytes` from `encoding` to consume exactly the data_block body starting on the next line and exclude it from source analysis (P4, P16).
4. Verilator carries the envelope state and the remaining base64 byte count across include boundaries (P13).
5. Other than the above, decryption, key selection, digest, license, visibility, and error are not observed.

<a id="4-カテゴリ別の境界"></a>

## 4. Boundaries by category

The counts form mutually exclusive categories of the 215 requirements. `kind` is behaviors.json.

|Category|Number of cases|Of these, tested|Main blocker|
|---|---:|---:|---|
|Directive syntax| 43 | 2 |Keyword values/defaults cannot be read; 20 keywords are unimplemented|
|Envelope structure| 24 | 2 |No decoder, no plaintext substitution, no delimiter check.|
| key block | 26 | 0 |There is no key store. key_block + data_block failed even with Verilator|
| digest | 38 | 0 |All digest_* forms fail with Verilator; Icarus ignores them|
|Encryption/encoding| 51 | 1 |There is no encryptor or decryptor. Not supported except for base64|
|Visibility| 17 | 0 |No encrypted output.|
|Error| 9 | 0 |The error condition cannot be reached. The standard does not specify a message.|
|Implementation-defined| 7 | 0 |The standard leaves this to the implementation|
|Total| 215 | 5 ||

<a id="41-directive構文43-件テスト化-2"></a>

### 4.1 directive syntax (43 item, tested 2)

Scope: 32 keyword-definition and 1 default-value items in 34.4, 4 bare-spelling items in 34.5.1.1–4.1, 4 grammar items in 34.5.28.1/29.1/31.1/32.1, and 2 reset items in 34.5.31.2 (among 34.4, lexical region/scope/self-containment belong to the envelope side).

- Observed: The acceptable spelling and the rejected spelling (P19) are shown. If `begin_protected` is given an argument, it is rejected, and if it is naked, it is passed (P2 ). Verilator does not read `author`, `data_keyname`, `digest_*`, `reset`, `viewport`, or similar items.
- Not observed: The values carried by the keywords, default values, and reset. Both tools do not maintain the keyword state, and neither encryption output nor decryption are available. Icarus ignores all lines.
- Standard: 34.4「The scope of protect pragma directives is completely lexical …」 「In protected envelopes where a specific pragma keyword is absent, the SystemVerilog tool shall use the default value.」
- Tested 2 items: 34.5.3.1 / 34.5.4.1 (bare delimiter). The representative not_testable are: `SV2023-34.4-EXTRACT-KEYWORD-AUTHOR`, `SV2023-34.4-EXTRACT-PROTECT-DEFAULTS`, and `SV2023-34.5.31.2-EXTRACT-RESET-PROTECT`.

<a id="42-envelope構造24-件テスト化-2"></a>

### 4.2 envelope structure (24 item, tested 2)

Scope: 5 cases in 34.2, 2 in 34.3, 2 in 34.3.1, 1 in 34.3.2, 3 lexical region/scope/self-containment cases in 34.4, and 11 in 34.5.1.2/2.2/3.2/4.2.

- Observed: Delimiter acceptance (P2), 8-level nesting (P11), state across includes (P13), and absence of diagnostics for unmatched delimiters (P12).
- Not observed: “Replace the decryption envelope with cleartext” in 34.3; “replace it with the decrypted text of data_block, then perform macro expansion and nested decryption” in 34.3.2; “put all content between begin/end into data_block” in 34.5.1.2; and re-encryption of encrypted input. Both require a cipher/decipherer.
- Standard: 34.2「Protected envelopes specify a region of text that shall be transformed prior to analysis by the source language processor.」 34.3「Tools that process SystemVerilog source code shall perform envelope decryption for all decryption envelopes contained in the source text, where the proper key is supplied by the user.」
- The 2 cases converted into tests: 34.2 (nested lower bound 8) and 34.4 (lexical scope). The test of 34.2 can only be used against null. The standard addresses encrypted data containing another envelope, which can be constructed only with decryption support. Stated explicitly in the test's `limitation`.
- 34.3.1's "Source text that is not contained in an encryption envelope shall not be modified" can be observed at first glance because both tools compile the outside as it is. However, this is also because the inside is left unchanged; a tool without protection support gives the same result. The rule is not tested because it does not show the implementation of the rule (the reason is `SV2023-34.3.1-EXTRACT-OUTSIDE-ENCRYPTION-PRESERVED` of JSON).

<a id="43-key-block26-件テスト化-0"></a>

### 4.3 key block (26 item, tested 0)

Scope: 6 cases for 34.5.14, 19 for 34.5.23–27, and 1 session keys for 34.3.1.

- Observed: `key_block` is read as the beginning of the base64 entity. However, Verilator has only 1 `bytes` counter(s) for 1 `encoding`, so placing `key_block` and `data_block` in the same envelope fails (P6).
- Not observed: Key selection (key_keyowner + key_keyname/key_public_key), decryption/decompression of key_block, storage of data_decrypt_key, digital-signature formats, and per-owner uniqueness. There is no key store.
- Standard: 34.5.27.2「Decode key_block then decrypt and parse its text for data_block keys …」
- Representative: `SV2023-34.5.27.2-EXTRACT-KEY-BLOCK-DECRYPT`, `SV2023-34.5.25.2-EXTRACT-KEY-NAME-DECRYPT-TEXT`.
- Verilator being unable to handle `key_block` and `data_block` together is an observed nonconformance, but the standard does not require an error, so it is recorded in P6 rather than turned into a should_fail test.

<a id="44-digest38-件テスト化-0"></a>

### 4.4 digest (38 item, tested 0)

Scope: The 34.5.16 to 22 38 items are shown.

- Observed: None. `digest_block`, `digest_method`, `digest_keyowner`, `digest_key_method`, `digest_keyname`, `digest_public_key`, and `digest_decrypt_key` are all unknown in Verilator (P9, P19); Icarus is ignored.
- Not observed: Digest generation, encryption, placement immediately after data_block, and recalculation/comparison from decrypted data (34.5.22.2). Decryption data and digest key required.
- Standard: 34.5.22.2「Decode/decrypt the data and digest, generate a digest from decrypted data and compare; mismatch indicates modification …」
- Representative: `SV2023-34.5.22.2-EXTRACT-DIGEST-AUTHENTICATE`, `SV2023-34.5.16.2-EXTRACT-DIGEST-OWNER`.

<a id="45-暗号化encoding51-件テスト化-1"></a>

### 4.5 Encryption/encoding (51 item, 1 test)

Scope: 12 cases for 34.5.9, 5 for 34.5.10, 21 for 34.5.11, 4 for 34.5.12, 4 for 34.5.13, 4 for 34.5.15, and 1 exchange keys for 34.3.1.

- Observed: base64 is the only enctype (P7); `bytes` determines how many characters to discard (P4); `line_length` is a multiple of 4 (P8); the body begins on the next line (P16).
- Not observed: Cryptographic algorithms (identifiers such as aes256-cbc are never used), prepending/removing IV, key selection by data_keyowner/keyname/public_key/decrypt_key, uuencode (Required in Table 34-2), quoted-printable, raw, per-field encoding, and decryption.
- Standard: 34.5.9.2 Table 34-2 marks `uuencode` and `base64` as Required, and `quoted-printable` and `raw` as Optional. 34.5.15.2 「The data_block pragma expression indicates that a data block begins on the next line in the file.」
- Tested 1 item: the output side of 34.5.15.2 (starts at the next line, only the number of declared bytes is excluded from parsing). The encryption itself has not been observed.
- Representative: `SV2023-34.5.11.2-EXTRACT-ALGORITHM-AES256-CBC`, `SV2023-34.5.9.2-EXTRACT-UUENCODE-REQUIRED`.

<a id="46-可視性17-件テスト化-0"></a>

### 4.6 Visibility (17 items, tested 0)

Scope: 10 author/author_info/encrypt_agent/encrypt_agent_info cases, 4 comment cases, 2 licence-output cases, and 1 viewport-object cases.

- Observed: None. There is no encrypted output itself, so there is no object to compare what is output in plain text other than data_block.
- Not observed: Placement of author and related directives, output of comment immediately before data_block, unchanged output of decrypt_license / runtime_license, and inclusion within the envelope of the object referenced by viewport.
- Standard: 34.5.30.2「Emit the entire comment including the initial pragma in cleartext immediately before the data_block …」。34.5.32.2「The specified object name shall be contained within the current envelope.」
- Representative: `SV2023-34.5.5.2-EXTRACT-AUTHOR-CLEARTEXT-OUTPUT`, `SV2023-34.5.30.2-EXTRACT-COMMENT-OUTPUT`.

<a id="47-エラー9-件テスト化-0"></a>

### 4.7 error (9 instance, tested 0)

Targets (all `kind: error`): nested encryption in 34.5.1.2, unknown data_keyname in 34.5.12.2, invalid data_block in 34.5.15.2, unknown digest_keyname in 34.5.18.2, unknown key_keyname in 34.5.25.2, invalid key_block and conflicting multiple key_block in 34.5.27.2, and license denial in 34.5.28.2/29.2.

- Observed: 1 of these errors defined by the standard do not occur. The protect-related errors (unknown keyword, base64 long) that the tool gives are due to the tool itself and are not related to the conditions of the specification.
- Not observed: Failed key retrieval, encryption input error, license denied. Requires an encryptor, key store, or licence manager.
- 34.5.28.2 is simply described as "an error message that includes the return value of the entry function". Therefore, even if the condition is reached, the comparable expected value is tool specific.
- Representative: `SV2023-34.5.12.2-EXTRACT-NAME-SELECT`, `SV2023-34.5.28.2-EXTRACT-LICENSE-DENIAL`.

<a id="48-実装定義7-件テスト化-0"></a>

### 4.8 Implementation-defined behavior (7 items, 0 tested)

Scope: Encryption-identifier extension in 34.5.11.2, digest-identifier extension in 34.5.21.2, viewport access in 34.5.32.2, and licence entry/exit in 34.5.28.2/29.2 (4 items).

- Observed: None (there is no transferable expected value).
- Not observed: The meaning of the additional identifier, the library call protocol, and the access value of the viewport. Verilator rejects viewport itself as unknown, while Icarus ignores it.
- Standard: 34.5.32.2「The access value is an implementation-specific relaxation of protection.」34.5.9.2「Additional identifier values and their corresponding encoding algorithms are implementation-defined.」
- Representative: `SV2023-34.5.32.2-EXTRACT-VIEWPORT-ACCESS`, `SV2023-34.5.11.2-EXTRACT-ALGORITHM-EXTENSIONS`.

<a id="5-テスト化した-5-要求4-ファイル"></a>

## 5. 5 requirements implemented as tests (4 files)

|Test|Requirements| `:lrm:` | `:oracle:` | Icarus | Verilator |
|---|---|---|---|---:|---:|
| `test_34_extra_envelope_keywords.sv` | 34.5.3.1, 34.5.4.1 | 34.5.3.1 34.5.4.1 34.2 | spec iverilog@13.0 verilator@5.052 | pass | pass |
| `test_34_extra_nested_envelopes.sv` | 34.2 | 34.2 34.5.3.2 34.5.4.2 | spec iverilog@13.0 verilator@5.052 | pass | pass |
| `test_34_extra_data_block_skipped.sv` | 34.5.15.2 | 34.5.15.2 34.5.9.2 34.2 | spec verilator@5.052 | known | pass |
| `test_34_extra_include_envelope.sv` | 34.4 | 34.4 22.4 34.5.3.2 34.5.15.2 | spec verilator@5.052 | known | pass |

known means that the test's expected output is not from Icarus: the payload is a syntax error under Icarus.

### 5.1 `test_34_extra_envelope_keywords.sv`

Place an empty `begin_protected`/`end_protected` pair between 2 `localparam` declarations, and check that both sides elaborate and print `envelope keywords: 13`. Since Verilator rejects `` `pragma protect begin_protected foo `` as unknown, the acceptance of the naked spelling is a syntactic observation. The decoding was not observed. Added a comment that a Icarus pass means only that the text was standard-compliant even when ignored.

### 5.2 `test_34_extra_nested_envelopes.sv`

Open 8 pairs of empty envelopes, close them in reverse order, and output `nested envelope levels: 8`. The delimiter depth of 34.2 is observed for "no less than 8". Because the standard's “envelope nested inside data_block” requires decryption to construct, the test checks only depth using empty pairs. The test comments and the `limitation` of JSON are clearly stated.

### 5.3 `test_34_extra_data_block_skipped.sv`

Put base64 of 32 characters (= 24 bytes) below `encoding=(enctype="base64", line_length=76, bytes=24)`. Verilator consumes exactly those 24 bytes, outputs `data_block skipped, bytes=24`, and elaborates the following module. Because the base64 sequence is invalid as an identifier as written, it provides evidence that it is not being read as source. The byte string is an arbitrary 24 byte, not a ciphertext. No claim to decryption. Icarus rejects the same file with a syntax error in the payload line.

### 5.4 `test_34_extra_include_envelope.sv`

`ch34_include/lexical_env.svh` writes `data_block` of `begin_protected`, `encoding`, and 24 bytes; `end_protected` is placed in the including file. Verilator carries the remaining base64 byte count and envelope state across the file boundary, consumes 24 bytes, then closes at `end_protected` in the included file. If state ended at the file boundary, the payload line would be parsed as source and cause a syntax error; this therefore observes 34.4's lexical scope. No decryption was performed.

<a id="6-not_testable-210-件の理由の型"></a>

## 6 . not_testable Types of reasons for the 210 cases

`not_testable` in JSON has 1 cases each of `reason`, `evidence`, and `citation`. These can be grouped into the following 7 types (with overlap).

1. No decryptor (envelope structure, visibility, digest comparison, decryption of data_block). Both tools have no means of receiving keys ( P0, P14 ).
2. No encryption (encryption output, session key, comment output, author output, padding, self-containment). The output itself cannot be created.
3. No key store (chosen by owner, name, public_key of data/key/digest). `--protect-key` protects Verilator's own symbols and does not affect the IEEE envelope (P14).
4. Keywords are unimplemented (20 keywords in 34.4, all digest keywords, viewport, comment, licence, reset, and author-related keywords). Verilator is rejected as unknown ( P19 ).
5. The encoding is only base64 (uuencode is not supported, P7, although it is Required in the standard).
6. No license manager (entry/exit of decrypt_license / runtime_license, error when refused).
7. Values unspecified by the standard / implementation-defined (error messages and return values, viewport access, additional identifiers, implementation nesting limit).

Representative examples (all with a reason in JSON):

|Requirements|Type|Brief assessment|
|---|---|---|
| `SV2023-34.2-EXTRACT-ENVELOPE-TRANSFORMATION` | 1 |The region is converted before parsing, but no conversion occurs.|
| `SV2023-34.3.2-EXTRACT-DECRYPT-THEN-EXPAND` | 1 |Without decrypted text, neither macro expansion nor nested decryption occurs|
| `SV2023-34.5.9.2-EXTRACT-UUENCODE-REQUIRED` | 5 |Verilator explicitly reports uuencode as Unsupported|
| `SV2023-34.5.27.2-EXTRACT-KEY-BLOCK-DECRYPT` | 3 |key_block can only be thrown away.|
| `SV2023-34.5.22.2-EXTRACT-DIGEST-AUTHENTICATE` | 1,4 |All digest keywords are unknown, and no cleartext is available for comparison|
| `SV2023-34.5.30.2-EXTRACT-COMMENT-OUTPUT` | 2,4 |No output envelope; comment is also unknown|
| `SV2023-34.5.28.2-EXTRACT-LICENSE-DENIAL` | 6,7 |Licence checks are never reached, and the standard does not prescribe the diagnostic wording|
| `SV2023-34.5.32.2-EXTRACT-VIEWPORT-ACCESS` | 7 |The standard itself calls this implementation-specific|

<a id="7-規格が観測値を定めない箇所テスト設計上の限界"></a>

## 7. Cases whose observable result is not specified by the standard (limits of test design)

- Errors: 34.5.12.2, 34.5.15.2, 34.5.18.2, 34.5.25.2, and 34.5.27.2 require only an error; neither the message nor the exit status is specified. 34.5.28.2 is defined only as "error containing return value". Therefore, even if the condition is met, the only string that can be compared is the tool-specific string.
- Nesting count: 34.2 is “implementation-specific; however, … no less than 8 」。 8 is a lower bound; 9 or greater and “decryption of encrypted nesting” are not guaranteed.
- Encryption algorithms: 34.5.11.2 maps identifiers to reference standards; Required/Optional status determines which identifiers implementations support, while key acquisition is outside the standard's scope.
- Encoding: 34.5.9.2 marks uuencode and base64 as Required and others as Optional; additional identifiers are implementation-defined.
- Visibility: Access to 34.5.32.2 is implementation-specific.
- License: 34.5.28.2/29.2's entry/exit is a call to an external library, while ABI is out of specification.

<a id="8-なぜ-215-件をリンクしなかったか"></a>

## 8. Why didn't you link the 215 case?

- Most Chapter 34 requirements compare against encrypted output or decrypted cleartext; neither tool provides either. If you forcefully link, you will pass the ignored result as "compilation passed" and make a false claim that the protection functioned.
- Therefore, limited new to 4 files and 5 requirements. Of these, 2 files run on only one tool (`known`); the remaining 2 files also provide only syntax-level observations of empty envelopes / arbitrary byte sequences. Wrote “decryption is not observed” in each test's `:description:` and comments.
- The reuse of existing tests is 0. No existing tests target Chapter 34; before the audit, `README.md` also stated “Clause 34 … has no tests.”

<a id="9-再現手順"></a>

## 9. Reproduction procedure

```sh
# ICARUS_BIN は Icarus Verilog 13.0 の bin ディレクトリ、OUT は結果の置き場所
export ICARUS_BIN=<Icarus Verilog 13.0 の bin>
ROOT=$(pwd)
OUT=$(mktemp -d)

# 1. プローブ（P0〜P20 の生ログ）。入力の .sv は空のディレクトリに生成される
(cd "$OUT" && sh "$ROOT/docs/protected-envelope-boundary/probe.sh" > probe-log.txt 2>&1)

# 2. 新規テスト
python3 tools/run_icarus.py --iverilog-bin "$ICARUS_BIN" -j 4 \
  --json "$OUT/ch34-extra-icarus.json" tests/ch34/*.sv
python3 tools/run_verilator.py --all -j 4 \
  --json "$OUT/ch34-extra-verilator.json" tests/ch34/*.sv
python3 tools/lint_metadata.py tests/ch34/*.sv
```

Run from the repository root. The JSON class is a record from the audit, and the generation script is not distributed. The probe log matches the saved log except for the 1 line showing the script's own path (the `say` bug discussed in Section 10).

Actual value:

```
Icarus:    2/2 tests match; 2 known differences not counted
Verilator: 4/4 tests match
lint:      4 tests checked: 0 new problems, 0 known, 0 gone
```

<a id="10-残るリスクと注意"></a>

## 10. Remaining risks and precautions.

- The pass of Icarus is weak. Icarus does not parse any Clause 34 syntax, so passing Clause 34 tests under Icarus is not evidence that protection is correct. This was noted in the commentary of the test.
- The data_block test of Verilator depends on the implementation of 5.052. Consuming exactly `bytes` and requiring a 1 envelope with 1 base64 block(s) (P6) are implementation choices rather than standard requirements. The expected output is recorded in 5.052, and may change in future versions.
- The include test depends on the same constraints. Assumes that the remaining base64 byte count carries across file boundaries.
- The correctness of the encryption has not been verified at all. The byte sequence is arbitrary and has no key. The test name and description do not contain any claims that read "decrypt" or "protect worked".
- The keyword table in P19 was obtained through the shell loop in `probe.sh`; `say` consumed the backticks in section headings, but the result rows remain unchanged.
- Classification granularity: assigned 1 items to 1 categories according to what each requirement governs. 34.5 .x. `KEYWORD-SYNTAX` in 1 is placed in that field's clause (for example, digest for digest_keyowner). The output of license and the object of viewport are described in the 4 chapter of this paper.
- Unaudited scope: there were 0 requirements with `checks`/`check_groups` in Clause 34, so there was no overlap or contradiction with existing checks.
