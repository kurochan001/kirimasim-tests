# テストのない要求の仕分け（2026-11-20）

[English](unmapped-requirements-20261120.en.md) / [日本語](unmapped-requirements-20261120.md)

要求台帳（`coverage/behaviors.json`）でテストのない847行（main `d631c049`時点）を、1回の実行で観測できるかどうかで仕分けました。仕分けはAIによるもので、人の確認ではありません。分母から外すかどうかは決めていません。所有者が決めます。行ごとの区分・理由・観測の案は[データ](measurements/2026-11-20/unmapped-requirements.json)にあります。

<a id="categories"></a>

## 区分

- 1回の実行で観測できる：1つの設計を1回実行し、標準出力の比較か、違反の行でのエラー（VPI・DPIのCコードを含む）で、行の動作と受入条件の全体を示せる。規格が決めない値に出力が左右されない。
- 準備が要る：2回の実行、ツールのオプション、ライブラリのmapファイル、別々のコンパイル、暗号化の道具、APIのない制御点、どのシミュレータも1回の実行では提供しないとみられる機能のどれかが要る。
- 対象外の候補：規格が結果を決めない（未定義・実装依存・任意）、定義・許可・推奨だけを述べる、シミュレータ以外の道具の規則、規格全体についての記述。

34章は[保護エンベロープの境界](protected-envelope-boundary.md)の扱いに従いました。定義の行は対象外の候補、暗号化の道具が要る行は準備が要る、としています。

<a id="counts"></a>

## 章ごとの本数

| 章・附属書 | 1回の実行で観測できる | 準備が要る | 対象外の候補 | 計 |
| --- | ---: | ---: | ---: | ---: |
| 2 | 0 | 0 | 2 | 2 |
| 3 | 4 | 5 | 5 | 14 |
| 4 | 0 | 5 | 12 | 17 |
| 5 | 1 | 0 | 8 | 9 |
| 6 | 2 | 0 | 7 | 9 |
| 7 | 7 | 0 | 3 | 10 |
| 8 | 4 | 0 | 12 | 16 |
| 9 | 2 | 0 | 7 | 9 |
| 10 | 2 | 0 | 7 | 9 |
| 11 | 4 | 1 | 6 | 11 |
| 12 | 9 | 0 | 5 | 14 |
| 13 | 5 | 0 | 3 | 8 |
| 14 | 1 | 0 | 0 | 1 |
| 15 | 2 | 0 | 2 | 4 |
| 16 | 3 | 0 | 5 | 8 |
| 17 | 4 | 0 | 8 | 12 |
| 18 | 1 | 0 | 7 | 8 |
| 19 | 3 | 2 | 3 | 8 |
| 20 | 9 | 0 | 11 | 20 |
| 21 | 9 | 0 | 12 | 21 |
| 22 | 1 | 0 | 7 | 8 |
| 23 | 3 | 1 | 2 | 6 |
| 24 | 1 | 0 | 3 | 4 |
| 25 | 4 | 0 | 1 | 5 |
| 26 | 3 | 0 | 0 | 3 |
| 27 | 4 | 0 | 0 | 4 |
| 28 | 8 | 0 | 2 | 10 |
| 29 | 3 | 0 | 0 | 3 |
| 30 | 0 | 6 | 1 | 7 |
| 31 | 2 | 22 | 1 | 25 |
| 32 | 0 | 12 | 0 | 12 |
| 33 | 0 | 20 | 2 | 22 |
| 34 | 0 | 109 | 100 | 209 |
| 35 | 6 | 3 | 13 | 22 |
| 36 | 2 | 10 | 3 | 15 |
| 37 | 56 | 17 | 18 | 91 |
| 38 | 25 | 28 | 12 | 65 |
| 39 | 13 | 0 | 0 | 13 |
| 40 | 2 | 0 | 4 | 6 |
| A | 10 | 3 | 2 | 15 |
| C | 7 | 0 | 4 | 11 |
| G | 7 | 0 | 0 | 7 |
| H | 3 | 17 | 10 | 30 |
| I | 8 | 4 | 1 | 13 |
| J | 0 | 12 | 4 | 16 |
| K | 2 | 0 | 1 | 3 |
| L | 0 | 2 | 1 | 3 |
| M | 3 | 0 | 2 | 5 |
| N | 0 | 0 | 4 | 4 |
| 計 | 245 | 279 | 323 | 847 |

<a id="priority"></a>

## 優先する章の、1回の実行で観測できる行

指示書の優先順（33、38、31、35、20、21章）です。これらにテストを足します。

- 33章：なし。
- 38章（25行）：`SV2023-38.16-EXTRACT-ARRAY-FORMAT-ERROR`, `SV2023-38.16-EXTRACT-ARRAY-GET-ELIGIBILITY`, `SV2023-38.17-EXTRACT-VLOG-ARGUMENTS`, `SV2023-38.30-EXTRACT-PRINTF-OUTPUT`, `SV2023-38.34-EXTRACT-PROCEDURAL-FORCE-RELEASE`, `SV2023-38.34-EXTRACT-PUT-FORMAT-ERROR`, `SV2023-38.34-EXTRACT-PUT-VALUE-TARGETS`, `SV2023-38.34-EXTRACT-UDP-NO-DELAY`, `SV2023-38.35-EXTRACT-PUT-ARRAY-NO-DELAY`, `SV2023-38.35-EXTRACT-PUT-ARRAY-TARGET`, `SV2023-38.35-EXTRACT-PUT-ARRAY-UNSUPPORTED-FORMAT`, `SV2023-38.36.1-EXTRACT-BITSELECT-CALLBACK-ERROR`, `SV2023-38.36.1-EXTRACT-CALLBACK-FORMAT-VPISCALARVAL`, `SV2023-38.36.1-EXTRACT-EVENT-CALLBACK-OBJECT`, `SV2023-38.36.1-EXTRACT-EVENT-CBCREATEOBJ`, `SV2023-38.36.1-EXTRACT-EVENT-CBENDOFFRAME`, `SV2023-38.36.1-EXTRACT-EVENT-CBENDOFTHREAD`, `SV2023-38.36.1-EXTRACT-EVENT-CBSTARTOFFRAME`, `SV2023-38.36.1-EXTRACT-EVENT-CBSTARTOFTHREAD`, `SV2023-38.36.1-EXTRACT-EVENT-CBVALUECHANGE`, `SV2023-38.36.2-EXTRACT-READWRITE-READONLY-ERROR`, `SV2023-38.36.2-EXTRACT-START-ZERO-DELAY-ERROR`, `SV2023-38.36.2-EXTRACT-TIME-CALLBACK-STRUCTURE`, `SV2023-38.36.2-EXTRACT-TIME-CBREADONLYSYNCH`, `SV2023-38.38-EXTRACT-RELEASE-HANDLE-RESULT`
- 31章（2行）：`SV2023-31.3.3-EXTRACT-DATA-ROLE`, `SV2023-31.3.3-EXTRACT-REFERENCE-ROLE`
- 35章（6行）：`SV2023-35.5.3-EXTRACT-CONTEXT-NONTRANSITIVE`, `SV2023-35.5.3-EXTRACT-OPTIMIZATION-BARRIER`, `SV2023-35.8-EXTRACT-NO-TASK-FROM-FUNCTION`, `SV2023-35.9-EXTRACT-DISABLE-PROTOCOL-FATAL`, `SV2023-35.9-EXTRACT-DISABLED-NO-EXPORT`, `SV2023-35.9-EXTRACT-FUNCTION-DISABLE-ACK`
- 20章（9行）：`SV2023-20.6.2-EXTRACT-BITS-DYNAMIC-RESTRICTIONS`, `SV2023-20.6.3-EXTRACT-ISUNBOUNDED`, `SV2023-20.10.1-EXTRACT-ELABORATION-CONTEXT`, `SV2023-20.10.1-EXTRACT-ELABORATION-DIAGNOSTICS`, `SV2023-20.10.1-EXTRACT-ELABORATION-ERROR`, `SV2023-20.10.1-EXTRACT-ELABORATION-EXECUTION`, `SV2023-20.10.1-EXTRACT-ELABORATION-FATAL`, `SV2023-20.10.1-EXTRACT-ELABORATION-NONERROR`, `SV2023-20.16-EXTRACT-PLA-OUTPUT-VARIABLE`
- 21章（9行）：`SV2023-21.3.4.3-EXTRACT-SCAN-SUPPRESSION`, `SV2023-21.4-EXTRACT-FILE-ADDRESS-RANGE-ERROR`, `SV2023-21.4-EXTRACT-MEMORY-TEXT-LEXICAL`, `SV2023-21.4.2-EXTRACT-ENUM-LOAD`, `SV2023-21.7.3.6.1-EXTRACT-VCDCLOSE`, `SV2023-21.7.4.1-EXTRACT-EXTENDED-HEADER-GRAMMAR`, `SV2023-21.7.4.1-EXTRACT-EXTENDED-NO-PARTS`, `SV2023-21.7.4.1-EXTRACT-EXTENDED-REAL`, `SV2023-21.7.4.2-EXTRACT-PORT-NODE-GRAMMAR`

31章は、負の制限値と遅延した信号の検査がツールのオプションに依存するので、正の制限値の2行だけを観測できるとしました。

<a id="coverage-database"></a>

## `$set_coverage_db_name`と`$load_coverage_db`

19.9は、`$set_coverage_db_name`を実行の終わりにカバレッジの情報を保存するデータベースの名前を決めるもの、`$load_coverage_db`を別のファイルから累積の情報を読み込むものとしています。前者は保存が実行の後で、データベースの形式はツールが決めます。後者は前の実行が作ったデータベースが要ります。どちらも1回の実行の出力では観測できないので、テストを作りません。`SV2023-19.9-EXTRACT-SET-DATABASE-NAME`と`SV2023-19.9-EXTRACT-LOAD-DATABASE`は「準備が要る」です。

<a id="single-use"></a>

## 1本のテストにしか出ないシステムタスク・関数

次の21個は、いまも1本のテストのコードにしか出ません。刺激の異なる2本目を足します：`$async$and$plane`, `$async$nand$array`, `$async$nand$plane`, `$async$nor$array`, `$async$nor$plane`, `$async$or$array`, `$changing_gclk`, `$fdisplayh`, `$fdisplayo`, `$fmonitorb`, `$fmonitorh`, `$fmonitoro`, `$fstrobeb`, `$fstrobeh`, `$fstrobeo`, `$fwriteb`, `$fwriteo`, `$monitorh`, `$monitoro`, `$strobeb`, `$strobeo`。

<a id="no-fixed-oracle"></a>

## 固定版のoracleを持つテストがない条項

対象の末端条項930のうち188には、固定版のoracle（`iverilog@13.0`、`verilator@5.052`、`verilator@5.054`）を持つテストがありません。3〜15章と20〜28章に限ると次の39条項です。Icarus Verilog 13.0かVerilatorの固定版で再現できる書き方のテストを足せるかを検討します。

4.4.2.5 4.9.2 6.6.4.1 6.6.4.2 6.6.8 6.7.2 6.7.3 6.22.6 7.3.2 7.9.8 8.26.4 8.26.6.2 8.29 8.30.1 8.30.2 8.30.3 8.30.4 8.30.5 9.4.4 10.10.3 11.9 12.6.1 12.6.2 12.6.3 15.5.4 15.5.5.1 15.5.5.2 15.5.5.3 20.16.1 20.16.2 20.16.3 20.16.4 23.3.3.7.1 23.3.3.7.2 24.6 25.6 28.15.2 28.16.2.1 28.16.2.2
