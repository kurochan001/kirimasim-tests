# IEEE 1800-2023 第34章（保護エンベロープ）215 要求の境界監査

> 以下は分母レビュー前の215要求に対する監査記録です。レビューで重複1行を統合した後は、
> 34章は214要求、対応済み5要求、未対応209要求です。現在の値は
> [生成した集計概要](behavior-coverage-summary.md)を参照してください。

- 監査日: 2026-10-28
- 対象: `coverage/behaviors.json` の clause が `34` で始まり、`checks` も
  `check_groups` も持たない **215 要求**。behavior 本文を正本とした。
  `kind` の内訳は normal 205 / error 9 / boundary 1。
- ツール: Icarus Verilog 13.0 と Verilator 5.052（2026-09-05）
- 追加したテスト: `tests/ch34/test_34_extra_*.sv` 4 本、`.expected` 4 本、
  `tests/ch34/ch34_include/lexical_env.svh` 1 本。既存テストは変更していない。
- 根拠ファイル: [`protected-envelope-boundary/`](protected-envelope-boundary/) に、
  要求ごとの分類と理由（`ch34-boundary.json`、以下「JSON」）、プローブの
  スクリプト（`probe.sh`）と生の出力（`probe-log.txt`）を置いた。
- 規格本文はローカルの IEEE 1800-2023 PDF を `pdftotext -layout` で読んで引用した
  （テキストは配布しない）。以下の引用はすべて 34 章の該当節から取っている。

## 1. 結果

| 分類 | 要求数 | テストファイル数 |
|---|---:|---:|
| テスト化（new） | 5 | 4 |
| not_testable | 210 | – |
| 合計 | 215 | 4 |

- テスト化した 5 要求は normal 4 件と boundary 1 件
  （`SV2023-34.2-EXTRACT-DECRYPTION-ENVELOPE`、34 章で唯一の boundary）。
  not_testable 210 件は normal 201 件と error 9 件。
- Icarus 13.0: `2/2 tests match; 2 known differences not counted`
  （Verilator 専用の 2 本は Icarus では payload が構文エラーになるため known）。
- Verilator 5.052: `4/4 tests match`
  （`python3 tools/run_verilator.py --all -j 4 ... tests/ch34/*.sv`）。
- `python3 tools/lint_metadata.py tests/ch34/*.sv`
  → `4 tests checked: 0 new problems, 0 known, 0 gone`（exit 0）。

**この章の結論**: 両ツールとも IEEE 34 の「復号」を行わない。Icarus は
`` `pragma protect `` をすべて無視し、Verilator は `data_block`/`key_block` の
base64 本体だけを読み捨てる。したがって 215 要求の大部分は、規格が定める観測
（平文への置換、鍵選択、digest 照合、ライセンス判定、エラー）を原理的に生じさせ
られない。テスト化した 5 要求も「構文が受理される」「領域が解析対象から外れる」
という範囲に限り、**保護が機能したとは主張しない**。

## 2. 方法

1. `coverage/behaviors.json` から clause 34・checks/check_groups 空の 215 件を抽出
   （`python3 -c` で件数一致を確認）。
2. 34 章の規格本文（34.1〜34.5.32）を読み、各 behavior が「入力の構文」「暗号化
   出力」「復号入力」「エラー」のどれを問題にしているかを分類した。
3. 最小の `.sv` を作業ディレクトリに作り、両ツールで compile / lint / 実行した。
   再現スクリプトは `protected-envelope-boundary/probe.sh`（入力の `.sv` も
   生成する）、生の出力は `protected-envelope-boundary/probe-log.txt`（P0〜P20）。
   本文の「P4」等はこのログの節番号で、JSON の `probes` に一行要約がある。
4. 「観測できた」の基準は、**その規則に固有の出力または診断が出たこと**とした。
   単にコンパイルが通るだけ、あるいは「無視された結果として通る」だけでは
   テスト化していない。
5. 215 件すべてを、テスト化した 5 件か not_testable 210 件のどちらかに割り当てた
   （JSON の `not_testable` に 210 件分の理由がある）。

## 3. 実測: 2 つのツールは何をするか

### 3.1 Icarus Verilog 13.0

| 事実 | 実測 |
|---|---|
| protect/decrypt 用のオプションは無い | `iverilog -h` と `vvp -h` に protect 関連の項目は 0 件（P0） |
| `` `pragma protect `` の行はすべて無視される | 未知キーワードでも診断なしでコンパイル成功（P1） |
| エンベロープ内の平文は普通のソースとしてコンパイルされる | `begin_protected` の中の `module` が実行され `SECRET RAN` を出力（P3）。`initial` 内の `$display("inside")` も実行（P17） |
| base64 本体は「ソース」として読まれる | `data_block` の次の行で `syntax error`（P4）。include 越しでも同じ（P13） |
| 対応の取れない delimiter も診断しない | 孤立した `end_protected`、閉じない `begin_protected` とも成功（P12） |
| 8 レベルの入れ子も「成功」する | ただし中身を解釈していないので、これは入れ子サポートの証拠にならない（P11） |
| 旧形式 `` `protected `` / `` `endprotected `` も無い | マクロ未定義の警告と構文エラー（P18） |

Icarus にとって `` `pragma `` は「知らない pragma 行」であり、34 章の構文は
一切パースされない。したがって Icarus で pass する 34 章テストは、**その行が
たまたま規格上正しい無視対象テキストである**ことしか示さない。

### 3.2 Verilator 5.052

| 事実 | 実測 |
|---|---|
| protect キーワードの一部だけを字句解析する | 表 34-1 の 32 語のうち 12 語 + 非規格の `version` を受理し、20 語を ``Unknown '`pragma protect' error`` で拒否（P19） |
| `begin_protected`/`end_protected` は受理する | 空の対で exit 0（P2） |
| ただしエンベロープ内の平文は除外しない | `begin_protected`〜`end_protected` の間の `$display` が実行される（P17）。`module` も普通にコンパイルされる（P3） |
| `data_block`/`key_block` の base64 本体だけを読み捨てる | ``A '`pragma protected data_block' encrypted section was detected and will be skipped.`` の警告付きで、宣言した `bytes` 分を消費（P4） |
| 本体は「次の行」から | `data_block` と同じ行に base64 を置くと ``Unknown '`pragma protect' error``（P16） |
| `encoding` は base64 専用 | `uuencode`・`quoted-printable`・`raw` は `Unsupported: only BASE64 is recognized`（P7）。`line_length` が 4 の倍数でないとエラー（P8） |
| 1 つの `encoding` の `bytes` は全ブロックで共有 | `key_block` と `data_block` を 1 つのエンベロープに置くと、`BASE64 encoding (too short)` / `length mismatch` で失敗（P6）。ブロックごとに `encoding` を置くと ``Multiple '`pragma protected encoding sections'`` で拒否（P20）。鍵ブロック付きの実エンベロープは受理できない |
| 復号はしない | `--protect-key` を渡しても IEEE エンベロープの扱いは変わらず、同じ skip 警告（P14）。モジュールを `data_block` に入れると `Cannot find file containing module`（P15） |
| 旧形式 `` `protected `` も無い | `Define or directive not defined`（P18） |

Verilator の「skip」は復号ではなく**削除**である。`data_block` の中身は
ソース解析に渡らないが、平文にも戻らない。したがって 34.2 の
「cleartext への変換」も 34.3 の「復号」も観測できない。

### 3.3 表 34-1 のキーワード認識（P19）

Verilator 5.052 が受理する（13）:

```
end  begin_protected  end_protected  version  encrypt_agent
encrypt_agent_info  encoding  data_method  key_keyowner  key_method
key_keyname  data_block  key_block
```

``Unknown '`pragma protect' error`` で拒否する（20）:

```
begin  author  author_info  data_keyowner  data_keyname  data_public_key
data_decrypt_key  digest_keyowner  digest_key_method  digest_keyname
digest_public_key  digest_decrypt_key  digest_method  digest_block
key_public_key  decrypt_license  runtime_license  comment  reset  viewport
```

Icarus は 32 語すべてを「知らない pragma」として無視する（受理とも拒否とも
言えない）。この非対称が、34 章のテストを書けるかどうかの最大の分岐になる。

### 3.4 観測できた事実と、できなかったこと

1. `begin_protected`/`end_protected` の**裸の綴り**は受理され、引数を付けると
   Verilator は拒否する（P2, P19）。
2. 8 レベルの delimiter 入れ子を両ツールが受理する（P11）。
3. Verilator は `encoding` の `bytes` を使って data_block の本体を**次の行から**
   ちょうど消費し、ソース解析から外す（P4, P16）。
4. Verilator はエンベロープ状態と base64 残バイト数を include 境界の向こうへ
   持ち越す（P13）。
5. 上記以外——復号、鍵選択、digest、ライセンス、可視性、エラー——は観測できない。

## 4. カテゴリ別の境界

件数は 215 要求の排他的な分類。`kind` は behaviors.json の値。

| カテゴリ | 件数 | うちテスト化 | 主な blocker |
|---|---:|---:|---|
| directive構文 | 43 | 2 | キーワード値と既定値が読めない／20 語は未実装 |
| envelope構造 | 24 | 2 | 復号器が無く、平文置換も delimiter 検査も起きない |
| key block | 26 | 0 | 鍵ストアが無い。key_block + data_block は Verilator でも失敗 |
| digest | 38 | 0 | digest_* は Verilator で全滅、Icarus は無視 |
| 暗号化/encoding | 51 | 1 | 暗号器も復号器も無い。base64 以外は未対応 |
| 可視性 | 17 | 0 | 暗号化出力が存在しない |
| エラー | 9 | 0 | 誤り条件に到達できない。規格はメッセージを定めない |
| 実装定義 | 7 | 0 | 規格が実装に委ねている |
| 合計 | 215 | 5 | |

### 4.1 directive構文（43 件、テスト化 2）

対象: 34.4 のキーワード定義 32 件と既定値 1 件、34.5.1.1〜4.1 の裸の綴り 4 件、
34.5.28.1/29.1/31.1/32.1 の文法 4 件、34.5.31.2 の reset 2 件（34.4 のうち lexical region/scope/self-containment は envelope 側）。

- 観測できた: 受理される綴りと拒否される綴り（P19）。`begin_protected` に
  引数を付けると拒否され、裸なら通る（P2）。`author`・`data_keyname`・
  `digest_*`・`reset`・`viewport` などは Verilator が読まない。
- 観測できない: キーワードが運ぶ**値**、既定値、reset による復元。両ツールとも
  キーワード状態を保持せず、暗号化出力も復号も無い。Icarus は全行を無視する。
- 規格: 34.4「The scope of protect pragma directives is completely lexical …」
  「In protected envelopes where a specific pragma keyword is absent, the
  SystemVerilog tool shall use the default value.」
- テスト化した 2 件: 34.5.3.1 / 34.5.4.1（裸の delimiter）。
  代表的な not_testable: `SV2023-34.4-EXTRACT-KEYWORD-AUTHOR`、
  `SV2023-34.4-EXTRACT-PROTECT-DEFAULTS`、
  `SV2023-34.5.31.2-EXTRACT-RESET-PROTECT`。

### 4.2 envelope構造（24 件、テスト化 2）

対象: 34.2 の 5 件、34.3 の 2 件、34.3.1 の 2 件、34.3.2 の 1 件、
34.4 の lexical region/scope/self-containment 3 件、
34.5.1.2/2.2/3.2/4.2 の 11 件。

- 観測できた: delimiter の受理（P2）、8 レベルの入れ子（P11）、
  include をまたぐ状態（P13）、対応の取れない delimiter が診断されないこと
  （P12）。
- 観測できない: 34.3 の「decryption envelope を cleartext に置換する」、
  34.3.2 の「data_block の復号文で置換し、その後マクロ展開と入れ子復号をする」、
  34.5.1.2 の「begin/end 間の全内容を data_block に入れる」、暗号化入力の
  再暗号化。いずれも暗号器／復号器が必要。
- 規格: 34.2「Protected envelopes specify a region of text that shall be
  transformed prior to analysis by the source language processor.」
  34.3「Tools that process SystemVerilog source code shall perform envelope
  decryption for all decryption envelopes contained in the source text, where
  the proper key is supplied by the user.」
- テスト化した 2 件: 34.2（入れ子の下限 8）と 34.4（lexical scope）。
  34.2 のテストは**空の対**しか使えない。規格が問題にするのは
  「encrypted data が内側に別の envelope を含む」場合であり、それは復号できて
  初めて作れる。テストの `limitation` に明記した。
- 34.3.1 の「Source text that is not contained in an encryption envelope
  shall not be modified」は、両ツールが外側をそのままコンパイルするので
  一見観測できる。しかしそれは「内側もそのまま」だからでもあり、保護の無い
  ツールでも同じ結果になる。規則の実装を示さないのでテスト化しなかった
  （理由は JSON の `SV2023-34.3.1-EXTRACT-OUTSIDE-ENCRYPTION-PRESERVED`）。

### 4.3 key block（26 件、テスト化 0）

対象: 34.5.14 の 6 件、34.5.23〜27 の 19 件、34.3.1 の session key 1 件。

- 観測できた: `key_block` が base64 本体の開始として読まれること。ただし
  Verilator の `bytes` カウンタは 1 つの `encoding` に 1 本しかなく、
  `key_block` と `data_block` を同じエンベロープに置くと失敗する（P6）。
- 観測できない: 鍵の選択（key_keyowner + key_keyname / key_public_key）、
  key_block の復号・展開、data_decrypt_key の格納、digital signature 形式、
  所有者ごとの一意性。鍵ストアが無い。
- 規格: 34.5.27.2「Decode key_block then decrypt and parse its text for
  data_block keys …」
- 代表: `SV2023-34.5.27.2-EXTRACT-KEY-BLOCK-DECRYPT`、
  `SV2023-34.5.25.2-EXTRACT-KEY-NAME-DECRYPT-TEXT`。
- Verilator が `key_block` と `data_block` を同時に扱えないことは、規格違反の
  観測ではあるが、規格が「エラーにせよ」と言っているわけではないので
  should_fail テストにはしていない（P6 の記録に留める）。

### 4.4 digest（38 件、テスト化 0）

対象: 34.5.16〜22 の 38 件。

- 観測できた: 無い。`digest_block`・`digest_method`・`digest_keyowner`・
  `digest_key_method`・`digest_keyname`・`digest_public_key`・
  `digest_decrypt_key` はすべて Verilator で unknown（P9, P19）、Icarus は無視。
- 観測できない: digest の生成、暗号化、data_block 直後への配置、復号データからの
  再計算と比較（34.5.22.2）。復号データと digest 鍵が要る。
- 規格: 34.5.22.2「Decode/decrypt the data and digest, generate a digest from
  decrypted data and compare; mismatch indicates modification …」
- 代表: `SV2023-34.5.22.2-EXTRACT-DIGEST-AUTHENTICATE`、
  `SV2023-34.5.16.2-EXTRACT-DIGEST-OWNER`。

### 4.5 暗号化/encoding（51 件、テスト化 1）

対象: 34.5.9 の 12 件、34.5.10 の 5 件、34.5.11 の 21 件、34.5.12 の 4 件、
34.5.13 の 4 件、34.5.15 の 4 件、34.3.1 の exchange key 1 件。

- 観測できた: base64 が唯一の enctype（P7）、`bytes` が捨てる文字数を決める
  （P4）、`line_length` は 4 の倍数（P8）、本体は次の行から（P16）。
- 観測できない: 暗号アルゴリズム（aes256-cbc などの識別子は一切使われない）、
  IV の前置・除去、data_keyowner/keyname/public_key/decrypt_key による鍵選択、
  uuencode（規格は Table 34-2 で **Required** としている）、quoted-printable、
  raw、フィールドごとの encoding、復号。
- 規格: 34.5.9.2 Table 34-2 は `uuencode` と `base64` を Required、
  `quoted-printable` と `raw` を Optional とする。34.5.15.2「The data_block
  pragma expression indicates that a data block begins on the next line in the
  file.」
- テスト化した 1 件: 34.5.15.2 の output 側（次の行から始まり、宣言バイト数だけ
  解析から外れる）。暗号化そのものは観測していない。
- 代表: `SV2023-34.5.11.2-EXTRACT-ALGORITHM-AES256-CBC`、
  `SV2023-34.5.9.2-EXTRACT-UUENCODE-REQUIRED`。

### 4.6 可視性（17 件、テスト化 0）

対象: author/author_info/encrypt_agent/encrypt_agent_info の 10 件、
comment 4 件、licence の output 2 件、viewport の object 1 件。

- 観測できた: 無い。暗号化出力そのものが無いので、data_block の外に何が平文で
  出るかを比べる対象が存在しない。
- 観測できない: author などの配置、comment の data_block 直前への出力、
  decrypt_license/runtime_license の無変更出力、viewport が指すオブジェクトの
  envelope 内包含。
- 規格: 34.5.30.2「Emit the entire comment including the initial pragma in
  cleartext immediately before the data_block …」。34.5.32.2「The specified
  object name shall be contained within the current envelope.」
- 代表: `SV2023-34.5.5.2-EXTRACT-AUTHOR-CLEARTEXT-OUTPUT`、
  `SV2023-34.5.30.2-EXTRACT-COMMENT-OUTPUT`。

### 4.7 エラー（9 件、テスト化 0）

対象（すべて `kind: error`）: 34.5.1.2 の入れ子暗号化、34.5.12.2 の未知の
data_keyname、34.5.15.2 の不正な data_block、34.5.18.2 の未知の
digest_keyname、34.5.25.2 の未知の key_keyname、34.5.27.2 の不正な key_block と
複数 key_block の矛盾、34.5.28.2/29.2 のライセンス拒否。

- 観測できた: 規格が定めるこれらのエラーは 1 つも出ない。ツールが出す
  protect 関連のエラー（unknown keyword、base64 長）はツール自身の都合で、
  規格の条件とは別物。
- 観測できない: 鍵検索の失敗、暗号化入力の誤り、ライセンス拒否。暗号器・
  鍵ストア・ライセンスマネージャのいずれかが必要。
- 規格はエラー時の**メッセージ文字列や値**を定めない（34.5.28.2 は
  「an error message that includes the return value of the entry function」と
  だけ言う）。したがって仮に条件に到達しても、比較できる期待値は
  ツール固有になる。
- 代表: `SV2023-34.5.12.2-EXTRACT-NAME-SELECT`、
  `SV2023-34.5.28.2-EXTRACT-LICENSE-DENIAL`。

### 4.8 実装定義（7 件、テスト化 0）

対象: 34.5.11.2 の暗号識別子拡張、34.5.21.2 の digest 識別子拡張、
34.5.32.2 の viewport access、34.5.28.2/29.2 の licence entry/exit（4 件）。

- 観測できた: 無い（移植可能な期待値が存在しない）。
- 観測できない: 追加識別子の意味、ライブラリの呼び出し規約、viewport の
  access 値。Verilator は viewport 自体を unknown で拒否し、Icarus は無視する。
- 規格: 34.5.32.2「The access value is an implementation-specific relaxation
  of protection.」34.5.9.2「Additional identifier values and their
  corresponding encoding algorithms are implementation-defined.」
- 代表: `SV2023-34.5.32.2-EXTRACT-VIEWPORT-ACCESS`、
  `SV2023-34.5.11.2-EXTRACT-ALGORITHM-EXTENSIONS`。

## 5. テスト化した 5 要求（4 ファイル）

| テスト | 要求 | `:lrm:` | `:oracle:` | Icarus | Verilator |
|---|---|---|---|---:|---:|
| `test_34_extra_envelope_keywords.sv` | 34.5.3.1, 34.5.4.1 | 34.5.3.1 34.5.4.1 34.2 | spec iverilog@13.0 verilator@5.052 | pass | pass |
| `test_34_extra_nested_envelopes.sv` | 34.2 | 34.2 34.5.3.2 34.5.4.2 | spec iverilog@13.0 verilator@5.052 | pass | pass |
| `test_34_extra_data_block_skipped.sv` | 34.5.15.2 | 34.5.15.2 34.5.9.2 34.2 | spec verilator@5.052 | known | pass |
| `test_34_extra_include_envelope.sv` | 34.4 | 34.4 22.4 34.5.3.2 34.5.15.2 | spec verilator@5.052 | known | pass |

「known」は、そのテストの期待出力が Icarus のものではないという意味で、
Icarus では payload が構文エラーになるため。

### 5.1 `test_34_extra_envelope_keywords.sv`

空の `begin_protected`/`end_protected` 対を 2 つの `localparam` の間に置き、
両側が elaborate されて `envelope keywords: 13` を出力する。Verilator は
`` `pragma protect begin_protected foo `` を unknown で拒否するので、裸の綴りが
受理されたことは構文の観測になる。**復号は観測していない**。Icarus の pass は
「無視しても規格上正しいテキストだった」以上の意味を持たない旨をコメントに書いた。

### 5.2 `test_34_extra_nested_envelopes.sv`

8 対の空エンベロープを開いて逆順に閉じ、`nested envelope levels: 8` を出力。
34.2 の「no less than 8」に対する delimiter 深さの観測。規格が問題にする
「data_block の中に入れ子になった envelope」は復号できないと作れないため、
空の対で深さだけを見ている。テストのコメントと JSON の `limitation` に明記。

### 5.3 `test_34_extra_data_block_skipped.sv`

`encoding=(enctype="base64", line_length=76, bytes=24)` の下に 32 文字
（=24 バイト）の base64 を置く。Verilator はちょうどその 24 バイトを消費して
`data_block skipped, bytes=24` を出力し、後続のモジュールを elaborate する。
base64 列はそのままでは識別子として不当なので、**ソースとして読まれていない**
ことの観測になる。バイト列は任意の 24 バイトで、暗号文ではない。復号は主張
しない。Icarus は同じファイルを payload 行の構文エラーで拒否する。

### 5.4 `test_34_extra_include_envelope.sv`

`ch34_include/lexical_env.svh` が `begin_protected`・`encoding`・24 バイトの
`data_block` を書き、`end_protected` は include する側のファイルに置く。
Verilator は base64 残バイト数とエンベロープ状態をファイル境界の向こうへ
持ち越し、24 バイトを消費してから include 側の `end_protected` で閉じる。
状態がファイル境界で切れていれば payload 行がソースとして読まれて構文エラーに
なるので、これは 34.4 の字句スコープの観測になる。復号はしていない。

## 6. not_testable 210 件の理由の型

JSON の `not_testable` は 1 件ずつ `reason`・`evidence`・`citation` を持つ。
型としては次の 7 つに集約できる（重複あり）。

1. **復号器が無い**（envelope 構造、可視性、digest 照合、data_block の復号）。
   両ツールとも鍵を受け取る手段が無い（P0, P14）。
2. **暗号器が無い**（暗号化出力、session key、comment の出力、author の出力、
   padding、self-containment）。出力そのものが作れない。
3. **鍵ストアが無い**（data/key/digest の owner・name・public_key による選択）。
   `--protect-key` は Verilator 自身のシンボル保護で、IEEE エンベロープには
   影響しない（P14）。
4. **キーワードが未実装**（34.4 の 20 語、digest 系全部、viewport、comment、
   licence、reset、author 系）。Verilator は unknown で拒否（P19）。
5. **encoding が base64 のみ**（uuencode は規格で Required なのに未対応、P7）。
6. **ライセンスマネージャが無い**（decrypt_license / runtime_license の
   entry/exit、拒否時のエラー）。
7. **規格が値を定めない／実装定義**（エラー時のメッセージと戻り値、viewport の
   access、追加識別子、入れ子数の実装上限）。

代表例（すべて JSON に理由がある）:

| 要求 | 型 | 一言 |
|---|---|---|
| `SV2023-34.2-EXTRACT-ENVELOPE-TRANSFORMATION` | 1 | 領域は解析前に変換される、が変換が起きない |
| `SV2023-34.3.2-EXTRACT-DECRYPT-THEN-EXPAND` | 1 | 復号文が無いのでマクロ展開も入れ子復号も起きない |
| `SV2023-34.5.9.2-EXTRACT-UUENCODE-REQUIRED` | 5 | Verilator は uuencode を明示的に Unsupported |
| `SV2023-34.5.27.2-EXTRACT-KEY-BLOCK-DECRYPT` | 3 | key_block は捨てられるだけ |
| `SV2023-34.5.22.2-EXTRACT-DIGEST-AUTHENTICATE` | 1,4 | digest 系は全語 unknown、照合する平文も無い |
| `SV2023-34.5.30.2-EXTRACT-COMMENT-OUTPUT` | 2,4 | 出力エンベロープが無く、comment も unknown |
| `SV2023-34.5.28.2-EXTRACT-LICENSE-DENIAL` | 6,7 | ライセンス判定に到達せず、文言も規格が定めない |
| `SV2023-34.5.32.2-EXTRACT-VIEWPORT-ACCESS` | 7 | 規格自身が implementation-specific と言う |

## 7. 規格が観測値を定めない箇所（テスト設計上の限界）

- **エラー**: 34.5.12.2・34.5.15.2・34.5.18.2・34.5.25.2・34.5.27.2 は「error」
  とだけ定め、メッセージも終了状態も定めない。34.5.28.2 は「return value を
  含むエラー」とだけ定める。したがって仮に条件に到達しても、比較できるのは
  ツール固有の文字列になる。
- **入れ子数**: 34.2 は「implementation-specific; however, … no less than 8」。
  8 は下限であって、9 以上や「暗号化された入れ子の復号」は保証されない。
- **暗号方式**: 34.5.11.2 は識別子と参照規格を対応づけるが、実装がどの識別子を
  サポートするかは Required/Optional の別で決まり、鍵の入手方法は規格外。
- **符号化**: 34.5.9.2 は uuencode と base64 を Required、他を Optional とし、
  追加識別子は implementation-defined。
- **可視性**: 34.5.32.2 の access は implementation-specific。
- **ライセンス**: 34.5.28.2/29.2 の entry/exit は外部ライブラリの呼び出しで、
  その ABI は規格の外。

## 8. なぜ 215 件をリンクしなかったか

- 34 章の要求は「暗号化された出力」か「復号された平文」を比較対象にするものが
  大半で、両ツールにはそのどちらも無い。無理にリンクすると、無視された結果の
  「コンパイルが通った」を合格にしてしまい、保護が機能したという虚偽の主張に
  なる。
- したがって new は 4 ファイル・5 要求に留めた。うち 2 ファイルは片方の
  ツールでしか動かず（`known`）、残り 2 ファイルも空のエンベロープ／任意バイト
  列という構文レベルの観測である。各テストの `:description:` とコメントに
  「復号は観測していない」と書いた。
- 既存テストの再利用（reuse）は 0 件。34 章を対象にした既存テストは無く、
  監査前の `README.md` も「Clause 34 … has no tests」と記していた。

## 9. 再現手順

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

リポジトリのルートで実行する。分類 JSON は監査時の記録で、生成スクリプトは
配布していない。プローブのログは、スクリプト自身のパスが出る 1 行
（第 10 節で述べる `say` の不具合）を除いて保存済みのものと一致する。

実測値:

```
Icarus:    2/2 tests match; 2 known differences not counted
Verilator: 4/4 tests match
lint:      4 tests checked: 0 new problems, 0 known, 0 gone
```

## 10. 残るリスクと注意

- **Icarus の pass は弱い**。Icarus は 34 章の構文を一切パースしないので、
  34 章のテストが Icarus で通ることは「保護が正しい」証拠にならない。
  テストのコメントにその旨を書いた。
- **Verilator の data_block テストは 5.052 の実装に依存する**。`bytes` を
  ちょうど消費する挙動と、1 エンベロープ 1 base64 ブロックという制約
  （P6）は規格ではなく実装の都合である。期待出力は 5.052 で記録したもので、
  将来の版で変わり得る。
- **include テストも同じ制約に依存する**。base64 残バイト数がファイル境界を
  越えることを前提にしている。
- **暗号の正しさは一切検証していない**。バイト列は任意で、鍵も無い。テスト名や
  説明に「decrypt」「protect が機能した」と読める主張は入れていない。
- **P19 のキーワード表**は `probe.sh` の shell ループで取ったもので、節見出しの
  バッククォートが `say` に食われるが、結果行はそのまま残っている。
- **分類の粒度**: カテゴリは「その要求が規制する対象」で 1 件 1 カテゴリに
  割り当てた。34.5.x.1 の `KEYWORD-SYNTAX` は、そのフィールドの節
  （例: digest_keyowner なら digest）に入れている。節をまたぐ判断が必要な
  もの（licence の output、viewport の object）は本文 4 章に注記した。
- 監査していない範囲: clause 34 で `checks`/`check_groups` を持つ要求は 0 件
  だったため、既存チェックとの重複や矛盾は無い。
