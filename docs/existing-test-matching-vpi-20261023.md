# 既存テストの要求照合：VPIと10%到達（2026-10-23）

> この文書の件数・割合・保留状態は、各作業時点の記録です。
> 現在の値は[生成した集計概要](behavior-coverage-summary.md)、分母と解釈の承認経緯は
> [要求抽出の結果](requirement-extraction.md)を参照してください。

[現在の集計](behavior-coverage-summary.md) / [照合台帳](test-requirement-matching.md) / [累積の進捗・指摘](existing-test-matching-review-20261022.md)

暫定の要求カバレッジ（テスト設計）が10%を超えるまで、既存テストの照合を繰り返しました。
最終値は **10.081987%（1,242/12,319要求）** です。表示用の丸め値は **10.08%** です。
固定分母12,319では1,232行から10%を超えます。最終監査で不十分な仮対応を除外し、追加の証拠を確認した結果、1,242行になりました。
これは重複整理前の要求台帳に対する暫定値で、全入力の組合せを試した割合や、単一シミュレータの規格適合率ではありません。

## 最終結果

- 対応済み要求：810行 → **1,242行（432行追加）**。
- 追加した対応根拠：**442件、55本**。少なくとも一つの対応があるテストは975本 → **1,030本**。
- 全3,938本のうち対応未登録は **2,908本**。全テストの検証内容に基づく対応付けは引き続き未完了です。
- 暫定の要求カバレッジ（テスト設計）：6.58% → **10.08%**。
- 現行入力に対応するパス結果の記録のある要求：718行 → **754行（36行追加）**。
- 暫定実行確認率：5.83% → **6.12%（754/12,319）**。
- 確定値：**設計・実行とも未確定**。分母承認・意味上の重複整理・解釈保留の解決が残ります。
- 集合証拠：50要求 → **55要求**。今回の5要求も全メンバーをANDで扱います。
- 保留判断：39件を追加し、台帳は345本・465件 → **372本・504件**。

対応追加または保留を記録した57本の、確認した観測の範囲を対象としています。
55本の全機能を精査済みという意味ではありません。担当はCodex（AI）で、独立した人による確認済みではありません。

## 照合の反復と採用基準

最初に変数・net・parameter・型名・属性を確認し、866行まで進めました。
型情報・unpacked/packed配列・構造体・memoryでは942行、port・subroutine・clocking・selectでは1,028行、
generate・階層・class・constraintでは1,096行、property/sequence・let・文では1,179行となりました。
最後にdynamic prefix・frame・interface・VPI API・IO declarationを確認し、最終監査後の1,242行で到達を確認しました。
途中の仮登録は最終監査で見直し、誤った取得元やAPIの代用、親を識別しない3件は最終集計へ含めていません。
履歴には監査後の最終計測を追加し、今回作業前の履歴は全て保持しています。

提供資料の `IEEE_Std_1800-2023_SystemVerilog.pdf` と抽出済み本文の該当節を読み、関係図はPDFを描画して確認しました。
C helperが呼ぶAPI・property・relationと、SVの刺激、期待出力の実値を対応付けています。
要求ID・合格基準・分母を変えて件数を増やしていません。単なる引用、定義だけ、固定ラベルだけの表示は採用していません。
図のgroup memberとしての一般的な所属を、vpiTypeを一度読むだけで網羅した扱いにすることも避けています。

例えば以下を実際の取得結果として確認しました。

- net/variableの符号・幅・境界、初期値、配列要素名・full name・indexと親handle同一性。
- 多次元packed arrayの一段ずつのElement遷移、内側からのIndex順、直接struct memberと孫要素のflag差。
- typedef名・alias先・enum定数の名前と値、typespec memberの型・既定値、空rangeの両NULL境界とsize0。
- portの順・名前・方向・幅と上下接続、null formalの両NULL handleとsize0。
- clockingのblock既定skewと個別IO skew/edge、virtual prefixのnull時と代入後のActual。
- class/constraintの実名・宣言順、extern prototype位置、static keyword、solve順、dist種別・範囲・weight。
- property/sequenceのoperatorとoperand順、strong/weak、clock名、letの実argument順と未指定argumentの既定値。
- assignmentのLHS/RHS・blocking/compound operator、delay実値、force/release/assign/deassignの対象。
- frameからのautomatic variableと宣言の違い、allocation schemeの全3値、HasActualの条件別値。
- VPI registration情報の実routine pointer・NULL・user data、scaled time、負数/降順のmulti-index経由書込みとSV側読出し。

## 追加したAND集合証拠

- 37.11のindexed access：単一indexとmulti-indexの2本を必要とします。
- 37.19のconstant select：定数/変数indexと、static/dynamic親の条件を分担する2本。
- 37.58のbit-select constant：index条件と、非定数parent selectからの伝播を分担する2本。
- 37.34のconstraint順：extern prototypeの宣言位置と、内部itemの実内容順を分担する2本。
- 37.48のclocking defaults：block/IOのinput/output skewとedgeを分担する2本。

実行確認は、同じシミュレータ・同じ実行スナップショット内で全メンバーがfresh passの場合だけです。
異なる実行回の部分成功を合成しません。設計対応と実行成功も区別しています。

## M59：NULLそのものを検査していない

`test_vpi_parameters`の `if (left && right)` のelseは、一方だけNULLでもno rangeになります。
nettype、virtual interface、interface typespecの一部helperは、NULL handleと有効handleのNULL名を同じnoneへ変換します。
case/defaultの式0件も、非NULLで直ちにscan終端になるiteratorと区別しません。
これらを「両境界NULL」「With/Expr/Parent/iteratorがNULL」という義務の証拠には使っていません。
一方、typespecの空rangeは片方欠落を別表示し、size0も読むため、その要求には採用しました。

## M60：存在や個数だけでは取得対象が正しいといえない

control statementの多くのchild relationとdo-whileは、handleの存在しか検査しません。
instance-arrayの全element、Use集合、waiting-process集合なども個数または型別個数だけの検査があります。
親frameの非active・同じthreadという条件も、正しいactivating frameの識別としては不十分です。
また、module hierarchyの `vpiModule` 取得を、netから `vpiInstance` への別relationの証拠にはできません。
実値・名前・型・同一性で識別できる個別の関係へ限定し、これらの広い主張を保留しました。

## M61：提供2023版と参照節番号が合わない

`test_vpi_delay_expressions`は37.75をcontinuous assignment、37.80をprimitiveとして説明していますが、
提供PDFではそれぞれDo-while/foreachとCallbackです。対応するモデルは37.47と37.35です。
`test_vpi_time_queue`のget_time引用も38.11で、提供版のAPI定義は38.13です。
今回は既存メタデータ・入力ハッシュを保つため引用を変更せず、その節への対応を保留しています。
参照番号を直す場合は、更新後の入力に対する証跡の再取得も必要です。

## M62：複合要求の一部を行全体へ広げない

scalar/vectorの全種別、packed-arrayの親と全leafのflag、bit幅とrange積による要素数、
typespecの全unwind終端、queueを含む全range順、struct/union双方のmember型、
DPI import/export/pure/context、関数自身のsizeとreturn-variableのsize、
classのstatic/automatic/event/built-in除外などを分けて確認しました。
部分的な観測は、そのまま複合行全体に対応付けていません。成立する図中property/relationの個別行か、AND集合へ限定しています。
constraintの非externも、`!= vpiExternAcc`を0表示するだけでは実取得値0の証明になりません。

## M63：Object IDの64bit値を検査していない

`test_vpi_class_obj_id.c`は `vpi_get(vpiObjId, ...)` と `PLI_INT32` を使います。
規格の64bit propertyを低位だけの比較で検証した扱いにはできないため、Object IDの行は登録していません。
同じテストが実名itemを取得するclass-variable→typespec relationは、別の観測として採用しました。

## M64：kindに合わないLHS問い合わせ

`test_vpi_case_loop_force_stmts.c`のdescribe_stmtは、switch前に全statementへLhs queryを行います。
LHSを持たないcase/foreach/do-whileにも問い合わせる構造なので、対応するkindの分岐内へ移す整理が必要です。
今回の照合では刺激・helperを変更せず、do-whileの非NULLだけの観測も承認しませんでした。

## 実行証跡・保全・検査

元のシミュレーションテストは今回再実行していません。
保存済みのIcarus 13.0／Verilator 5.052と部分実行の結果に、現在の入力SHA-256とランナー識別子を照合しました。
新規432行のうち実行確認が増えたのは36行です。known・未対応・古い結果をpassへ読み替えていません。
全754行の実行確認率と1,242行の要求カバレッジ（テスト設計）の差には、この未成功分も含まれます。

要求12,319行の定義、分母識別子、資料監査結果、既存checks/check_groups、既存保留判断を機械的に比較し保持しました。
既存テスト・期待値・メタデータ・C helper・ランナーは変更せず、新規テストも追加していません。
分母SHA-256は `d9e94724b317c8668673f4f4883c4923bf94caad46d79ba7c79e1fd16302e6ac`、計測規則は版3です。

管理ツールの74テスト、提供資料ハッシュ、要求対応・判断台帳・保存済み実行証跡の整合性、
カタログ・統計・depth・生成物・メタデータ、およびdiffの整合検査を実施しました。
未登録2,908本と保留504件は完了扱いにせず、次回の照合対象として残しています。

## 今回追加した対応の索引

以下は今回追加した442件の索引です。各要求の完全なIDには `SV2023-` が付きます。
刺激・期待出力・Cアンカー・入力SHA-256・担当・日付は [behaviors.json](../coverage/behaviors.json) のchecksにあります。
索引はファイル全体の精査完了を意味しません。

- [test_vpi_array_var](../tests/ch37/test_vpi_array_var.sv) / [C](../tests/ch37/test_vpi_array_var.c): `37.17-EXTRACT-ARRAY-SIZE`, `37.17-EXTRACT-DIAGRAM-039`, `37.17-EXTRACT-DIAGRAM-040`, `37.17-EXTRACT-DIAGRAM-041`, `37.17-EXTRACT-DIAGRAM-045`, `37.17-EXTRACT-DIAGRAM-046`, `37.17-EXTRACT-DIAGRAM-074`, `37.17-EXTRACT-DIAGRAM-075`, `37.17-EXTRACT-DIAGRAM-076`, `37.17-EXTRACT-VARIABLE-ARRAY-INDICES`.
- [test_vpi_attribute_object](../tests/ch37/test_vpi_attribute_object.sv) / [C](../tests/ch37/test_vpi_attribute_object.c): `37.83-EXTRACT-DIAGRAM-001`, `37.83-EXTRACT-DIAGRAM-049`, `37.83-EXTRACT-DIAGRAM-050`, `37.83-EXTRACT-DIAGRAM-053`.
- [test_vpi_case_loop_force_stmts](../tests/ch37/test_vpi_case_loop_force_stmts.sv) / [C](../tests/ch37/test_vpi_case_loop_force_stmts.c): `37.12-EXTRACT-DIAGRAM-017`, `37.72-EXTRACT-DIAGRAM-001`, `37.72-EXTRACT-DIAGRAM-005`, `37.72-EXTRACT-DIAGRAM-006`, `37.75-EXTRACT-DIAGRAM-003`, `37.75-EXTRACT-DIAGRAM-005`, `37.75-EXTRACT-FOREACH-INDEXED-OBJECT`, `37.75-EXTRACT-FOREACH-INDICES`, `37.79-EXTRACT-DIAGRAM-001`, `37.79-EXTRACT-DIAGRAM-002`, `37.79-EXTRACT-DIAGRAM-003`, `37.79-EXTRACT-DIAGRAM-004`, `37.79-EXTRACT-DIAGRAM-005`, `37.79-EXTRACT-DIAGRAM-006`.
- [test_vpi_class_definitions](../tests/ch37/test_vpi_class_definitions.sv) / [C](../tests/ch37/test_vpi_class_definitions.c): `37.31-EXTRACT-CLASS-PARAMETERS`, `37.31-EXTRACT-DERIVED-CLASSES`, `37.31-EXTRACT-DIAGRAM-002`, `37.31-EXTRACT-DIAGRAM-003`, `37.31-EXTRACT-DIAGRAM-004`, `37.31-EXTRACT-DIAGRAM-006`, `37.31-EXTRACT-DIAGRAM-010`, `37.31-EXTRACT-DIAGRAM-012`, `37.31-EXTRACT-DIAGRAM-014`, `37.31-EXTRACT-DIAGRAM-016`, `37.31-EXTRACT-DIAGRAM-026`, `37.31-EXTRACT-DIAGRAM-027`.
- [test_vpi_class_obj_id](../tests/ch37/test_vpi_class_obj_id.sv) / [C](../tests/ch37/test_vpi_class_obj_id.c): `37.33-EXTRACT-DIAGRAM-002`.
- [test_vpi_clocking_blocks](../tests/ch37/test_vpi_clocking_blocks.sv) / [C](../tests/ch37/test_vpi_clocking_blocks.c): `37.48-EXTRACT-CLOCKING-DEFAULTS`, `37.48-EXTRACT-CLOCKING-IO-EXPRESSION`, `37.48-EXTRACT-DIAGRAM-001`, `37.48-EXTRACT-DIAGRAM-002`, `37.48-EXTRACT-DIAGRAM-003`, `37.48-EXTRACT-DIAGRAM-004`, `37.48-EXTRACT-DIAGRAM-006`, `37.48-EXTRACT-DIAGRAM-016`, `37.48-EXTRACT-DIAGRAM-017`, `37.48-EXTRACT-DIAGRAM-020`, `37.48-EXTRACT-DIAGRAM-024`.
- [test_vpi_clocking_edges_prefix](../tests/ch37/test_vpi_clocking_edges_prefix.sv) / [C](../tests/ch37/test_vpi_clocking_edges_prefix.c): `37.48-EXTRACT-CLOCKING-DEFAULTS`, `37.48-EXTRACT-CLOCKING-VIRTUAL-PREFIX`, `37.48-EXTRACT-DIAGRAM-005`, `37.48-EXTRACT-DIAGRAM-012`, `37.48-EXTRACT-DIAGRAM-013`, `37.48-EXTRACT-DIAGRAM-014`, `37.48-EXTRACT-DIAGRAM-015`, `37.48-EXTRACT-DIAGRAM-018`, `37.48-EXTRACT-DIAGRAM-019`, `37.48-EXTRACT-DIAGRAM-021`, `37.48-EXTRACT-DIAGRAM-022`.
- [test_vpi_constant_select](../tests/ch37/test_vpi_constant_select.sv) / [C](../tests/ch37/test_vpi_constant_select.c): `37.19-EXTRACT-DIAGRAM-006`, `37.19-EXTRACT-SELECT-CONSTANT`, `37.58-EXTRACT-BIT-SELECT-CONSTANT`, `37.58-EXTRACT-DIAGRAM-014`.
- [test_vpi_constraint_items](../tests/ch37/test_vpi_constraint_items.sv) / [C](../tests/ch37/test_vpi_constraint_items.c): `37.34-EXTRACT-CONSTRAINT-ORDER`, `37.34-EXTRACT-CONSTRAINT-STATIC`, `37.34-EXTRACT-DIAGRAM-008`, `37.34-EXTRACT-DIAGRAM-010`, `37.34-EXTRACT-DIAGRAM-011`, `37.38-EXTRACT-DIAGRAM-017`, `37.38-EXTRACT-DIAGRAM-018`, `37.38-EXTRACT-FOREACH-ARRAY`, `37.38-EXTRACT-FOREACH-LOOP-VARS`.
- [test_vpi_constraint_orderings_dists](../tests/ch37/test_vpi_constraint_orderings_dists.sv) / [C](../tests/ch37/test_vpi_constraint_orderings_dists.c): `37.34-EXTRACT-CONSTRAINT-ORDER`, `37.34-EXTRACT-DIAGRAM-002`, `37.34-EXTRACT-DIAGRAM-003`, `37.34-EXTRACT-DIAGRAM-004`, `37.34-EXTRACT-DIAGRAM-013`, `37.34-EXTRACT-DIAGRAM-014`, `37.34-EXTRACT-DIAGRAM-015`, `37.34-EXTRACT-DIAGRAM-016`, `37.34-EXTRACT-DIAGRAM-018`, `37.34-EXTRACT-DIAGRAM-019`, `37.34-EXTRACT-DIAGRAM-020`, `37.34-EXTRACT-DIAGRAM-021`, `37.38-EXTRACT-DIAGRAM-008`, `37.38-EXTRACT-DIAGRAM-009`, `37.38-EXTRACT-DIAGRAM-010`, `37.38-EXTRACT-DIAGRAM-011`, `37.38-EXTRACT-DIAGRAM-015`, `37.38-EXTRACT-DIAGRAM-016`.
- [test_vpi_cont_assign_bits_delays](../tests/ch37/test_vpi_cont_assign_bits_delays.sv) / [C](../tests/ch37/test_vpi_cont_assign_bits_delays.c): `37.47-EXTRACT-ASSIGN-BIT-SCALAR`, `37.47-EXTRACT-ASSIGN-VALUE-CALLBACK`, `37.47-EXTRACT-DIAGRAM-001`, `37.47-EXTRACT-DIAGRAM-003`, `37.47-EXTRACT-DIAGRAM-004`, `37.47-EXTRACT-DIAGRAM-006`, `37.47-EXTRACT-DIAGRAM-008`.
- [test_vpi_control_statement_child_relations](../tests/ch37/test_vpi_control_statement_child_relations.sv) / [C](../tests/ch37/test_vpi_control_statement_child_relations.c): `37.66-EXTRACT-DIAGRAM-003`, `37.77-EXTRACT-DIAGRAM-003`.
- [test_vpi_file_line](../tests/ch37/test_vpi_file_line.sv) / [C](../tests/ch37/test_vpi_file_line.c): `37.3.3-EXTRACT-LOCATION`, `37.10-EXTRACT-DIAGRAM-061`, `37.10-EXTRACT-DIAGRAM-062`.
- [test_vpi_frames_threads_alloc](../tests/ch37/test_vpi_frames_threads_alloc.sv) / [C](../tests/ch37/test_vpi_frames_threads_alloc.c): `37.3.7-EXTRACT-ALLOCATION-SCHEME`, `37.12-EXTRACT-DIAGRAM-034`, `37.33-EXTRACT-DIAGRAM-004`, `37.43-EXTRACT-DIAGRAM-002`, `37.43-EXTRACT-DIAGRAM-005`, `37.43-EXTRACT-DIAGRAM-007`, `37.43-EXTRACT-DIAGRAM-009`, `37.44-EXTRACT-DIAGRAM-006`, `37.61-EXTRACT-HAS-ACTUAL-AUTOMATIC-FRAME`, `37.61-EXTRACT-HAS-ACTUAL-STATIC-ELABORATED`, `37.61-EXTRACT-NO-ACTUAL-AUTOMATIC-DECLARATION`.
- [test_vpi_generate_scope_contents](../tests/ch37/test_vpi_generate_scope_contents.sv) / [C](../tests/ch37/test_vpi_generate_scope_contents.c): `37.12-EXTRACT-DIAGRAM-046`, `37.12-EXTRACT-DIAGRAM-048`, `37.12-EXTRACT-DIAGRAM-055`, `37.85-EXTRACT-DIAGRAM-066`, `37.85-EXTRACT-DIAGRAM-070`, `37.85-EXTRACT-GENERATE-LOCALPARAMS`.
- [test_vpi_generate_scopes](../tests/ch37/test_vpi_generate_scopes.sv) / [C](../tests/ch37/test_vpi_generate_scopes.c): `37.85-EXTRACT-DIAGRAM-006`, `37.85-EXTRACT-DIAGRAM-007`, `37.85-EXTRACT-DIAGRAM-009`, `37.85-EXTRACT-DIAGRAM-010`, `37.85-EXTRACT-DIAGRAM-012`, `37.85-EXTRACT-DIAGRAM-016`, `37.85-EXTRACT-DIAGRAM-018`, `37.85-EXTRACT-DIAGRAM-020`, `37.85-EXTRACT-DIAGRAM-070`, `37.85-EXTRACT-GENERATE-ARRAY-SIZE`, `37.85-EXTRACT-UNNAMED-GENERATE`.
- [test_vpi_instance_array_kinds](../tests/ch37/test_vpi_instance_array_kinds.sv) / [C](../tests/ch37/test_vpi_instance_array_kinds.c): `37.6-EXTRACT-DIAGRAM-001`, `37.6-EXTRACT-INSTANCE-INDEX`, `37.9-EXTRACT-DIAGRAM-001`, `37.9-EXTRACT-INSTANCE-INDEX`, `37.11-EXTRACT-ARRAY-RANGE-ORDER`, `37.11-EXTRACT-DIAGRAM-008`, `37.11-EXTRACT-DIAGRAM-009`, `37.11-EXTRACT-DIAGRAM-016`, `37.11-EXTRACT-DIAGRAM-019`, `37.11-EXTRACT-DIAGRAM-023`, `37.35-EXTRACT-DIAGRAM-010`, `37.35-EXTRACT-PRIMITIVE-INDEX`.
- [test_vpi_instance_arrays](../tests/ch37/test_vpi_instance_arrays.sv) / [C](../tests/ch37/test_vpi_instance_arrays.c): `37.11-EXTRACT-DIAGRAM-010`, `37.11-EXTRACT-DIAGRAM-011`, `37.11-EXTRACT-DIAGRAM-021`, `37.11-EXTRACT-DIAGRAM-022`, `37.11-EXTRACT-DIAGRAM-023`.
- [test_vpi_interconnect_elements](../tests/ch37/test_vpi_interconnect_elements.sv) / [C](../tests/ch37/test_vpi_interconnect_elements.c): `37.24-EXTRACT-DIAGRAM-005`, `37.24-EXTRACT-INTERCONNECT-ELEMENT-LEVEL`.
- [test_vpi_interface_typespecs](../tests/ch37/test_vpi_interface_typespecs.sv) / [C](../tests/ch37/test_vpi_interface_typespecs.c): `37.30-EXTRACT-DIAGRAM-001`, `37.30-EXTRACT-DIAGRAM-004`, `37.30-EXTRACT-DIAGRAM-005`, `37.30-EXTRACT-INTERFACE-TYPE-DEFINITION`.
- [test_vpi_io_decl_ref_objs](../tests/ch37/test_vpi_io_decl_ref_objs.sv) / [C](../tests/ch37/test_vpi_io_decl_ref_objs.c): `37.13-EXTRACT-DIAGRAM-001`, `37.13-EXTRACT-DIAGRAM-007`, `37.13-EXTRACT-DIAGRAM-010`, `37.13-EXTRACT-DIAGRAM-011`, `37.13-EXTRACT-DIAGRAM-018`, `37.15-EXTRACT-DIAGRAM-008`, `37.15-EXTRACT-DIAGRAM-012`, `37.15-EXTRACT-DIAGRAM-013`, `37.15-EXTRACT-REF-DEFINITION`, `37.15-EXTRACT-REF-PARENT`, `37.15-EXTRACT-REF-TYPESPEC`.
- [test_vpi_iterator_objects](../tests/ch37/test_vpi_iterator_objects.sv) / [C](../tests/ch37/test_vpi_iterator_objects.c): `37.84-EXTRACT-DIAGRAM-001`, `37.84-EXTRACT-DIAGRAM-002`, `37.84-EXTRACT-ITERATOR-REFERENCE`.
- [test_vpi_let_expr_arguments](../tests/ch37/test_vpi_let_expr_arguments.sv) / [C](../tests/ch37/test_vpi_let_expr_arguments.c): `37.57-EXTRACT-LET-ARGUMENT-ORDER`.
- [test_vpi_lifetime_properties](../tests/ch37/test_vpi_lifetime_properties.sv) / [C](../tests/ch37/test_vpi_lifetime_properties.c): `37.10-EXTRACT-DIAGRAM-074`, `37.17-EXTRACT-DIAGRAM-079`, `37.41-EXTRACT-DIAGRAM-019`.
- [test_vpi_memory_word_objects](../tests/ch37/test_vpi_memory_word_objects.sv) / [C](../tests/ch37/test_vpi_memory_word_objects.c): `37.10-EXTRACT-DIAGRAM-032`, `37.10-EXTRACT-MEMORY-ARRAY`, `37.12-EXTRACT-DIAGRAM-044`, `37.20-EXTRACT-DIAGRAM-001`, `37.20-EXTRACT-DIAGRAM-003`, `37.20-EXTRACT-DIAGRAM-005`, `37.20-EXTRACT-DIAGRAM-006`, `37.20-EXTRACT-DIAGRAM-007`, `37.20-EXTRACT-DIAGRAM-008`, `37.20-EXTRACT-DIAGRAM-009`, `37.20-EXTRACT-DIAGRAM-010`, `37.20-EXTRACT-DIAGRAM-011`, `37.20-EXTRACT-MEMORY-METHODS`.
- [test_vpi_module_hierarchy](../tests/ch37/test_vpi_module_hierarchy.sv) / [C](../tests/ch37/test_vpi_module_hierarchy.c): `37.10-EXTRACT-DIAGRAM-012`, `37.10-EXTRACT-DIAGRAM-028`, `37.10-EXTRACT-DIAGRAM-063`, `37.16-EXTRACT-DIAGRAM-029`, `37.16-EXTRACT-DIAGRAM-074`, `37.17-EXTRACT-DIAGRAM-022`.
- [test_vpi_module_relations](../tests/ch37/test_vpi_module_relations.sv) / [C](../tests/ch37/test_vpi_module_relations.c): `37.5-EXTRACT-DIAGRAM-002`, `37.5-EXTRACT-DIAGRAM-003`, `37.5-EXTRACT-DIAGRAM-004`, `37.5-EXTRACT-DIAGRAM-005`, `37.5-EXTRACT-DIAGRAM-037`, `37.5-EXTRACT-DIAGRAM-042`, `37.5-EXTRACT-MODULE-INDEX`, `37.76-EXTRACT-DIAGRAM-001`, `37.76-EXTRACT-DIAGRAM-003`, `37.76-EXTRACT-DIAGRAM-004`.
- [test_vpi_named_events](../tests/ch37/test_vpi_named_events.sv) / [C](../tests/ch37/test_vpi_named_events.c): `37.27-EXTRACT-DIAGRAM-001`, `37.27-EXTRACT-DIAGRAM-005`, `37.27-EXTRACT-DIAGRAM-009`, `37.27-EXTRACT-DIAGRAM-011`, `37.27-EXTRACT-DIAGRAM-018`, `37.27-EXTRACT-DIAGRAM-022`, `37.27-EXTRACT-DIAGRAM-027`.
- [test_vpi_net_properties](../tests/ch37/test_vpi_net_properties.sv) / [C](../tests/ch37/test_vpi_net_properties.c): `37.16-EXTRACT-DIAGRAM-046`, `37.16-EXTRACT-DIAGRAM-047`, `37.16-EXTRACT-DIAGRAM-060`, `37.16-EXTRACT-DIAGRAM-061`, `37.16-EXTRACT-DIAGRAM-072`, `37.16-EXTRACT-DIAGRAM-077`, `37.16-EXTRACT-DIAGRAM-079`, `37.16-EXTRACT-DIAGRAM-081`, `37.16-EXTRACT-DIAGRAM-082`, `37.16-EXTRACT-DIAGRAM-086`, `37.16-EXTRACT-IMPLICIT-NET-LOCATION`.
- [test_vpi_nettype_alias_chain_relations](../tests/ch37/test_vpi_nettype_alias_chain_relations.sv) / [C](../tests/ch37/test_vpi_nettype_alias_chain_relations.c): `37.23-EXTRACT-DIAGRAM-001`, `37.23-EXTRACT-DIAGRAM-004`, `37.23-EXTRACT-NETTYPE-ALIAS`.
- [test_vpi_nettype_declarations](../tests/ch37/test_vpi_nettype_declarations.sv) / [C](../tests/ch37/test_vpi_nettype_declarations.c): `37.23-EXTRACT-DIAGRAM-003`.
- [test_vpi_object_access_basics](../tests/ch37/test_vpi_object_access_basics.sv) / [C](../tests/ch37/test_vpi_object_access_basics.c): `37.3.1-EXTRACT-HANDLE-ACCESS`, `37.3.1-EXTRACT-ONE-TO-ONE`, `37.5-EXTRACT-DIAGRAM-001`, `37.5-EXTRACT-DIAGRAM-021`, `37.5-EXTRACT-DIAGRAM-041`, `37.5-EXTRACT-TOP-MODULES`, `37.10-EXTRACT-DIAGRAM-065`, `37.10-EXTRACT-DIAGRAM-066`, `37.10-EXTRACT-DIAGRAM-068`, `37.10-EXTRACT-DIAGRAM-069`, `37.10-EXTRACT-ROOT-TIME`.
- [test_vpi_packed_array_levels](../tests/ch37/test_vpi_packed_array_levels.sv) / [C](../tests/ch37/test_vpi_packed_array_levels.c): `37.17-EXTRACT-DIAGRAM-047`, `37.17-EXTRACT-DIAGRAM-067`, `37.17-EXTRACT-DIAGRAM-084`, `37.17-EXTRACT-VARIABLE-STRUCT-MEMBER`, `37.18-EXTRACT-PACKED-ELEMENT-LEVEL`, `37.18-EXTRACT-PACKED-INDEX-ORDER`, `37.18-EXTRACT-PACKED-MEMBER-FLAG`, `37.18-EXTRACT-PACKED-STRUCT-FLAG`, `37.26-EXTRACT-DIAGRAM-002`.
- [test_vpi_packed_array_vars](../tests/ch37/test_vpi_packed_array_vars.sv) / [C](../tests/ch37/test_vpi_packed_array_vars.c): `37.18-EXTRACT-DIAGRAM-001`, `37.18-EXTRACT-DIAGRAM-002`, `37.18-EXTRACT-DIAGRAM-003`, `37.18-EXTRACT-DIAGRAM-004`, `37.18-EXTRACT-DIAGRAM-005`.
- [test_vpi_parameters](../tests/ch37/test_vpi_parameters.sv) / [C](../tests/ch37/test_vpi_parameters.c): `37.28-EXTRACT-DIAGRAM-003`, `37.28-EXTRACT-DIAGRAM-007`, `37.28-EXTRACT-DIAGRAM-008`, `37.28-EXTRACT-DIAGRAM-011`, `37.28-EXTRACT-DIAGRAM-015`, `37.28-EXTRACT-DIAGRAM-016`, `37.28-EXTRACT-DIAGRAM-017`, `37.28-EXTRACT-DIAGRAM-024`, `37.28-EXTRACT-DIAGRAM-028`.
- [test_vpi_ports](../tests/ch37/test_vpi_ports.sv) / [C](../tests/ch37/test_vpi_ports.c): `37.14-EXTRACT-DIAGRAM-003`, `37.14-EXTRACT-DIAGRAM-005`, `37.14-EXTRACT-DIAGRAM-009`, `37.14-EXTRACT-DIAGRAM-010`, `37.14-EXTRACT-DIAGRAM-013`, `37.14-EXTRACT-DIAGRAM-015`, `37.14-EXTRACT-DIAGRAM-016`, `37.14-EXTRACT-DIAGRAM-018`, `37.14-EXTRACT-DIAGRAM-019`, `37.14-EXTRACT-DIAGRAM-020`, `37.14-EXTRACT-NULL-PORT`, `37.14-EXTRACT-PORT-NAME`, `37.14-EXTRACT-PORT-ORDER`.
- [test_vpi_prefix_has_actual](../tests/ch37/test_vpi_prefix_has_actual.sv) / [C](../tests/ch37/test_vpi_prefix_has_actual.c): `37.61-EXTRACT-DIAGRAM-001`, `37.61-EXTRACT-DIAGRAM-002`, `37.61-EXTRACT-HAS-ACTUAL-PREFIX-PRESENT`, `37.61-EXTRACT-NO-ACTUAL-PREFIX-ABSENT`.
- [test_vpi_process_statements](../tests/ch37/test_vpi_process_statements.sv) / [C](../tests/ch37/test_vpi_process_statements.c): `37.63-EXTRACT-DIAGRAM-004`, `37.63-EXTRACT-DIAGRAM-006`, `37.63-EXTRACT-DIAGRAM-011`, `37.64-EXTRACT-ASSIGNMENT-OP-TYPE`, `37.64-EXTRACT-DIAGRAM-001`, `37.64-EXTRACT-DIAGRAM-002`, `37.64-EXTRACT-DIAGRAM-003`, `37.64-EXTRACT-DIAGRAM-006`, `37.64-EXTRACT-DIAGRAM-007`, `37.65-EXTRACT-DIAGRAM-001`, `37.65-EXTRACT-DIAGRAM-002`, `37.68-EXTRACT-DIAGRAM-001`, `37.68-EXTRACT-DIAGRAM-003`.
- [test_vpi_property_sequence_decls](../tests/ch37/test_vpi_property_sequence_decls.sv) / [C](../tests/ch37/test_vpi_property_sequence_decls.c): `37.12-EXTRACT-DIAGRAM-024`, `37.12-EXTRACT-DIAGRAM-026`, `37.51-EXTRACT-DIAGRAM-002`, `37.51-EXTRACT-DIAGRAM-007`, `37.51-EXTRACT-DIAGRAM-011`, `37.51-EXTRACT-DIAGRAM-012`, `37.51-EXTRACT-PROPERTY-FORMAL-TYPE`, `37.53-EXTRACT-DIAGRAM-003`, `37.53-EXTRACT-DIAGRAM-007`, `37.53-EXTRACT-DIAGRAM-008`, `37.53-EXTRACT-DIAGRAM-009`, `37.53-EXTRACT-SEQUENCE-FORMAL-ORDER`, `37.53-EXTRACT-SEQUENCE-FORMAL-TYPE`.
- [test_vpi_property_sequence_operators](../tests/ch37/test_vpi_property_sequence_operators.sv) / [C](../tests/ch37/test_vpi_property_sequence_operators.c): `37.51-EXTRACT-DIAGRAM-004`, `37.51-EXTRACT-DIAGRAM-009`, `37.52-EXTRACT-DIAGRAM-002`, `37.52-EXTRACT-DIAGRAM-003`, `37.52-EXTRACT-DIAGRAM-010`, `37.52-EXTRACT-DIAGRAM-011`, `37.52-EXTRACT-DIAGRAM-012`, `37.52-EXTRACT-DIAGRAM-013`, `37.52-EXTRACT-DIAGRAM-014`, `37.52-EXTRACT-DIAGRAM-015`, `37.52-EXTRACT-DIAGRAM-016`, `37.52-EXTRACT-DIAGRAM-018`, `37.52-EXTRACT-PROPERTY-OP-VPIALWAYSOP`, `37.52-EXTRACT-PROPERTY-OP-VPICOMPANDOP`, `37.52-EXTRACT-PROPERTY-OP-VPINEXTTIMEOP`, `37.52-EXTRACT-PROPERTY-OP-VPIOVERLAPIMPLYOP`, `37.52-EXTRACT-PROPERTY-OP-VPIUNTILOP`, `37.53-EXTRACT-DIAGRAM-004`, `37.53-EXTRACT-DIAGRAM-005`, `37.54-EXTRACT-DIAGRAM-005`, `37.54-EXTRACT-DIAGRAM-006`, `37.54-EXTRACT-SEQUENCE-OP-VPIFIRSTMATCHOP`, `37.54-EXTRACT-SEQUENCE-OP-VPIGOTOREPEATOP`, `37.54-EXTRACT-SEQUENCE-OP-VPIINTERSECTOP`, `37.54-EXTRACT-SEQUENCE-OP-VPIREPEATOP`, `37.54-EXTRACT-SEQUENCE-OP-VPITHROUGHOUTOP`, `37.54-EXTRACT-SEQUENCE-OP-VPIUNARYCYCLEDELAYOP`, `37.54-EXTRACT-SEQUENCE-OP-VPIWITHINOP`, `37.56-EXTRACT-DIAGRAM-001`, `37.56-EXTRACT-DIAGRAM-002`, `37.57-EXTRACT-DIAGRAM-001`, `37.57-EXTRACT-DIAGRAM-002`, `37.57-EXTRACT-DIAGRAM-004`, `37.57-EXTRACT-DIAGRAM-005`.
- [test_vpi_ref_obj_actual](../tests/ch37/test_vpi_ref_obj_actual.sv) / [C](../tests/ch37/test_vpi_ref_obj_actual.c): `37.15-EXTRACT-DIAGRAM-001`, `37.15-EXTRACT-DIAGRAM-009`, `37.15-EXTRACT-DIAGRAM-010`, `37.15-EXTRACT-REF-ACTUAL`.
- [test_vpi_relationships_and_tags](../tests/ch37/test_vpi_relationships_and_tags.sv) / [C](../tests/ch37/test_vpi_relationships_and_tags.c): `37.3.1-EXTRACT-HANDLE-ACCESS`, `37.3.1-EXTRACT-ONE-TO-ONE`.
- [test_vpi_select_objects_event_arrays](../tests/ch37/test_vpi_select_objects_event_arrays.sv) / [C](../tests/ch37/test_vpi_select_objects_event_arrays.c): `37.19-EXTRACT-DIAGRAM-002`, `37.19-EXTRACT-DIAGRAM-005`, `37.19-EXTRACT-DIAGRAM-009`, `37.19-EXTRACT-SELECT-CONSTANT`, `37.27-EXTRACT-DIAGRAM-007`, `37.27-EXTRACT-DIAGRAM-013`, `37.27-EXTRACT-DIAGRAM-015`, `37.27-EXTRACT-DIAGRAM-016`, `37.27-EXTRACT-DIAGRAM-017`, `37.27-EXTRACT-EVENT-INDICES`, `37.27-EXTRACT-EVENT-RANGES`, `37.58-EXTRACT-BIT-SELECT-CONSTANT`, `37.58-EXTRACT-DIAGRAM-010`, `37.58-EXTRACT-DIAGRAM-011`.
- [test_vpi_struct_typespecs](../tests/ch37/test_vpi_struct_typespecs.sv) / [C](../tests/ch37/test_vpi_struct_typespecs.c): `37.17-EXTRACT-DIAGRAM-032`, `37.17-EXTRACT-DIAGRAM-066`, `37.17-EXTRACT-DIAGRAM-068`, `37.25-EXTRACT-DIAGRAM-028`, `37.25-EXTRACT-DIAGRAM-030`, `37.25-EXTRACT-DIAGRAM-031`, `37.25-EXTRACT-DIAGRAM-032`, `37.25-EXTRACT-DIAGRAM-034`, `37.25-EXTRACT-DIAGRAM-036`, `37.26-EXTRACT-DIAGRAM-001`, `37.26-EXTRACT-DIAGRAM-005`, `37.26-EXTRACT-DIAGRAM-006`, `37.26-EXTRACT-DIAGRAM-010`.
- [test_vpi_systf_argument_expressions](../tests/ch37/test_vpi_systf_argument_expressions.sv) / [C](../tests/ch37/test_vpi_systf_argument_expressions.c): `37.42-EXTRACT-DIAGRAM-008`, `37.42-EXTRACT-DIAGRAM-028`, `37.59-EXTRACT-DIAGRAM-021`.
- [test_vpi_task_function_properties](../tests/ch37/test_vpi_task_function_properties.sv) / [C](../tests/ch37/test_vpi_task_function_properties.c): `37.12-EXTRACT-DIAGRAM-050`, `37.13-EXTRACT-DIAGRAM-005`, `37.13-EXTRACT-DIAGRAM-009`, `37.13-EXTRACT-DIAGRAM-014`, `37.13-EXTRACT-DIAGRAM-015`, `37.41-EXTRACT-DIAGRAM-003`, `37.41-EXTRACT-DIAGRAM-011`, `37.41-EXTRACT-DIAGRAM-015`, `37.41-EXTRACT-DIAGRAM-016`, `37.41-EXTRACT-DIAGRAM-017`, `37.41-EXTRACT-DIAGRAM-018`, `37.41-EXTRACT-DIAGRAM-022`, `37.41-EXTRACT-DIAGRAM-023`, `37.41-EXTRACT-SUBROUTINE-FULLNAME`, `37.41-EXTRACT-SUBROUTINE-VISIBILITY`.
- [test_vpi_type_strings](../tests/ch37/test_vpi_type_strings.sv) / [C](../tests/ch37/test_vpi_type_strings.c): `37.3.2-EXTRACT-TYPE-INTEGER`, `37.3.2-EXTRACT-TYPE-STRING`.
- [test_vpi_typespec_relations](../tests/ch37/test_vpi_typespec_relations.sv) / [C](../tests/ch37/test_vpi_typespec_relations.c): `37.22-EXTRACT-DIAGRAM-001`, `37.22-EXTRACT-DIAGRAM-002`, `37.22-EXTRACT-DIAGRAM-003`, `37.22-EXTRACT-EMPTY-RANGE-RESULT`, `37.24-EXTRACT-DIAGRAM-006`, `37.24-EXTRACT-DIAGRAM-008`, `37.25-EXTRACT-ALIAS-KIND`, `37.25-EXTRACT-DIAGRAM-026`, `37.25-EXTRACT-DIAGRAM-032`, `37.25-EXTRACT-DIAGRAM-035`, `37.25-EXTRACT-DIAGRAM-036`, `37.25-EXTRACT-DIAGRAM-048`, `37.25-EXTRACT-DIAGRAM-049`, `37.25-EXTRACT-DIAGRAM-053`, `37.25-EXTRACT-DIAGRAM-054`, `37.25-EXTRACT-DIAGRAM-055`, `37.25-EXTRACT-DIAGRAM-057`, `37.25-EXTRACT-DIAGRAM-059`, `37.25-EXTRACT-DIAGRAM-060`, `37.25-EXTRACT-DIAGRAM-061`, `37.25-EXTRACT-MEMBER-DEFAULT`, `37.25-EXTRACT-TYPE-BOUNDS`, `37.25-EXTRACT-TYPEDEF-NAME`.
- [test_vpi_variable_properties](../tests/ch37/test_vpi_variable_properties.sv) / [C](../tests/ch37/test_vpi_variable_properties.c): `37.17-EXTRACT-DIAGRAM-031`, `37.17-EXTRACT-DIAGRAM-051`, `37.17-EXTRACT-DIAGRAM-052`, `37.17-EXTRACT-DIAGRAM-054`, `37.17-EXTRACT-DIAGRAM-055`, `37.17-EXTRACT-DIAGRAM-061`, `37.17-EXTRACT-DIAGRAM-070`, `37.17-EXTRACT-DIAGRAM-077`, `37.17-EXTRACT-DIAGRAM-078`, `37.17-EXTRACT-DIAGRAM-085`, `37.17-EXTRACT-DIAGRAM-087`, `37.17-EXTRACT-VARIABLE-INITIALIZER`.
- [test_vpi_virtual_interface_vars](../tests/ch37/test_vpi_virtual_interface_vars.sv) / [C](../tests/ch37/test_vpi_virtual_interface_vars.c): `37.29-EXTRACT-DIAGRAM-007`, `37.29-EXTRACT-DIAGRAM-008`, `37.29-EXTRACT-DIAGRAM-009`, `37.29-EXTRACT-DIAGRAM-011`.
- [test_vpi_get_property_values](../tests/ch38/test_vpi_get_property_values.sv) / [C](../tests/ch38/test_vpi_get_property_values.c): `38.6-EXTRACT-GET-SIGNATURE`, `38.6-EXTRACT-GET-VALUES`.
- [test_vpi_get_systf_info_function_types](../tests/ch38/test_vpi_get_systf_info_function_types.sv) / [C](../tests/ch38/test_vpi_get_systf_info_function_types.c): `38.12-EXTRACT-SYSTF-INFO-ALLOCATION`, `38.12-EXTRACT-SYSTF-INFO-SIGNATURE`, `38.37.1-EXTRACT-SYSTF-NAME`, `38.37.1-EXTRACT-SYSTF-TYPE`, `38.37.1-EXTRACT-USER-SYSTF-REGISTER`.
- [test_vpi_get_time_scaled](../tests/ch38/test_vpi_get_time_scaled.sv) / [C](../tests/ch38/test_vpi_get_time_scaled.c): `38.13-EXTRACT-GET-TIME-FORMAT`, `38.13-EXTRACT-GET-TIME-SIGNATURE`.
- [test_vpi_get_vlog_info](../tests/ch38/test_vpi_get_vlog_info.sv) / [C](../tests/ch38/test_vpi_get_vlog_info.c): `38.17-EXTRACT-VLOG-INFO-CONTENTS`, `38.17-EXTRACT-VLOG-INFO-SIGNATURE`.
- [test_vpi_handle_by_multi_index_ranges](../tests/ch38/test_vpi_handle_by_multi_index_ranges.sv) / [C](../tests/ch38/test_vpi_handle_by_multi_index_ranges.c): `38.20-EXTRACT-MULTI-INDEX-ORDER`, `38.20-EXTRACT-MULTI-INDEX-SIGNATURE`.
