# 連想配列のレビューで不足していた観測へのテスト追加（2026-10-23）

[元のレビューとM45–M50](existing-test-matching-associative-arrays-20261023.md) / [現在のカバレッジ](behavior-coverage-summary.md)

レビューで判別力が不足していた箇所に、15本のテストと期待出力を追加しました。
提供資料のIEEE 1800-2023、7.8–7.9.11、Table 7-1、20.6.1–20.6.2を確認して期待値を決めています。
今回、既存テストの刺激・期待値・メタデータは変更していません。

## 追加した観測

- M45：戻り値の型と正確なstatus。
  [test_assoc_method_expression_types.sv](../tests/ch7/test_assoc_method_expression_types.sv)は、
  num/size/exists/first/last/next/prevの式そのものを`$typename`と`$bits`へ渡します。
  int変数への代入によって元の型が隠れることを避け、実際の呼出しでは1/0とkey更新も表示します。
  [test_assoc_count_expression_types.sv](../tests/ch7/test_assoc_count_expression_types.sv)は、
  num/sizeの型と空・非空・全削除後の個数を別ファイルで確認します。
  他のメソッドの未対応がnum/sizeの成功証跡を妨げないようにしています。
- M46：未存在の開始keyと失敗時のkey保持。
  [test_assoc_traversal_gaps_and_preserved_keys.sv](../tests/ch7/test_assoc_traversal_gaps_and_preserved_keys.sv)は、
  present/absentの両方からnext/prevを呼び、正確なstatusと選ばれたkeyを比較します。
  空配列・終端の失敗では入力keyが維持されることも確認します。
- M47：ref actualの確保をcalleeの操作より前に観測。
  [test_assoc_ref_allocates_before_callee_write.sv](../tests/ch7/test_assoc_ref_allocates_before_callee_write.sv)は、
  calleeがelementを読む前にcontainerのnum/existsを表示し、elementへ一度も書きません。
  [test_assoc_read_modify_defaults_without_ref.sv](../tests/ch7/test_assoc_read_modify_defaults_without_ref.sv)は、
  refから分離し、type/user defaultからの`+=`・`++`と、structの未更新memberの初期値を検査します。
- M48：warningの有無。
  [test_assoc_missing_read_reports_diagnostic.sv](../tests/ch7/test_assoc_missing_read_reports_diagnostic.sv)は、
  missing readの4-state既定値、非確保、既存entryの保持とwarningを要求します。
  [test_assoc_invalid_write_reports_diagnostic.sv](../tests/ch7/test_assoc_invalid_write_reports_diagnostic.sv)は、
  Xを含むkeyへのwriteを無視し、warningを出すことを要求します。
  [test_assoc_default_and_delete_silent.sv](../tests/ch7/test_assoc_default_and_delete_silent.sv)は、
  user defaultのmissing readと、空／非空配列でのmissing deleteにwarningがないことを確認します。
- M49：signedness、cast文脈、wildcardの幅と正規化。
  [test_assoc_signed_and_unsigned_key_order.sv](../tests/ch7/test_assoc_signed_and_unsigned_key_order.sv)は、
  同じ8bit patternの全key・値を、signed/unsignedそれぞれの順序で検査します。
  [test_assoc_integral_index_cast_context.sv](../tests/ch7/test_assoc_integral_index_cast_context.sv)は、
  幅を縮めたkeyのaliasと、4bit同士の加算が8bit index文脈で16になることを区別します。
  [test_assoc_wildcard_width_and_sign_aliases.sv](../tests/ch7/test_assoc_wildcard_width_and_sign_aliases.sv)は、
  8/64/128bitの先頭ゼロのalias、64bitを超えるkey、8bit signed値のunsigned解釈を確認します。
  [test_assoc_wildcard_string_literal_bits.sv](../tests/ch7/test_assoc_wildcard_string_literal_bits.sv)は、
  文字列literalと等幅bit vectorが同じentryを上書きすることを確認します。
- M49：任意順序の安定性と複合key。
  [test_assoc_class_key_order_is_stable.sv](../tests/ch7/test_assoc_class_key_order_is_stable.sv)と
  [test_assoc_composite_empty_null_key_order.sv](../tests/ch7/test_assoc_composite_empty_null_key_order.sv)は、
  key集合を変えない2回の全走査列を比較し、全keyのmembershipと値も確認します。
  class handleの具体的な順序は固定しません。後者はempty string/nullを含むstruct keyも使います。
- M50：全entryのコピー。
  [test_assoc_assignment_copies_every_entry.sv](../tests/ch7/test_assoc_assignment_copies_every_entry.sv)は、
  全3entryの値、copy先の古いkeyの消失、source更新／削除後の独立性、空sourceによる全消去を確認します。
  scalar値のcopyであり、class objectの再帰的なdeep copyを要求するものではありません。

## 実行結果

Icarus Verilog 13.0 stable（v13_0-dirty）とVerilator 5.052（2026-09-05、vUNKNOWN-built20260905）で実行しました。
Verilatorは初期値seed 1と73で確認しています。

- Verilator：現在の入力について両seedとも8本一致、7本既知不一致・コンパイル不可。
- Icarus：15本とも連想配列等のコンパイル不可によるknown。実際にコンパイルを試行しており、成功には含めません。

15本の初回実行は次の3ファイルです。

- [associative-gaps-20261023-icarus13.json](../coverage/results/associative-gaps-20261023-icarus13.json)
- [associative-gaps-20261023-verilator-seed1.json](../coverage/results/associative-gaps-20261023-verilator-seed1.json)
- [associative-gaps-20261023-verilator-seed73.json](../coverage/results/associative-gaps-20261023-verilator-seed73.json)

その後wildcardの上書き前の観測を追加し、countテストのコメント幅を修正しました。
変更した2本だけをそれぞれ再実行した結果は次の6ファイルです。
古い入力の成功は採用せず、15本の一括再実行や一つの実行回への合成として扱っていません。

- [wildcard / Icarus](../coverage/results/associative-wildcard-refinement-20261023-icarus13.json)
- [wildcard / Verilator seed 1](../coverage/results/associative-wildcard-refinement-20261023-verilator-seed1.json)
- [wildcard / Verilator seed 73](../coverage/results/associative-wildcard-refinement-20261023-verilator-seed73.json)
- [count / Icarus](../coverage/results/associative-count-refinement-20261023-icarus13.json)
- [count / Verilator seed 1](../coverage/results/associative-count-refinement-20261023-verilator-seed1.json)
- [count / Verilator seed 73](../coverage/results/associative-count-refinement-20261023-verilator-seed73.json)

Verilatorに残る7件は、method式の型、未存在inputからのnext、ref actualの受理、signed key順、
index加算のcast文脈、missing readの4-state値、invalid writeの無視です。
[シミュレータ差](simulator-differences.md#cases-added-after-the-2026-10-23-associative-array-review)へ具体値を記録しました。
規格由来の期待値を実装へ合わせて変更せず、これら7本のoracleは`spec`のみです。

## 規格との対応と割合

要求定義12,319行と分母の識別子は変更せず、28件の対応根拠を追加しました。

- 全テスト：3,923本から3,938本。
- 対応登録済み：928本から943本。未登録は2,995本。
- 対応済み要求：768行から792行（24行追加）。
- 実行確認済み要求：688行から700行（12行追加）。
- 暫定設計網羅率：6.23%から**6.43%（792/12,319）**。
- 暫定実行確認率：5.58%から**5.68%（700/12,319）**。
- 確定値：設計・実行とも未確定。分母承認、重複整理、解釈保留の解決が残ります。

新規対応24行のうち11行に成功証跡があります。
従来は設計対応のみだったread/modify/writeの1行も、分離した新テストで実行確認できたため、増分は12行です。
集合証拠の要求は44行から45行へ増えました。既存グループを保持し、
type/user defaultのread/modify/writeとpresent/absentのstrict successorに、それぞれ独立に完全な代替証拠を追加しました。
user defaultの無警告とdefaultなしの診断は2本のANDグループです。
同じ実行回で全メンバーが成功するまで、この行全体を実行確認済みにしません。
基準値更新の理由も`coverage/behavior-baseline.json`へ記録しました。

これはM45–M50の不足した観測への追加です。規格全機能、全key型、全幅、全診断経路の網羅完了ではありません。
例えばX/Zを含むkeyのread、narrowな走査引数の全条件など、広い複合要求の未観測部分は残しています。
5本・5件の範囲別の未採用理由を[判断台帳](../coverage/test-matching-reviews.json)へ追加しました。
一つ以上の対応登録や範囲別判断は、ファイル全体の精査完了を意味しません。
対応付けはAIによるもので、独立した人の確認済みではありません。

## 判別力と管理ファイルの検査

一時的なソース変種11種類をVerilatorでコンパイル・実行し、すべて期待結果との不一致として検出しました。
entryの欠落、sourceへの誤った追従、defaultの欠落、wildcard上位bit切捨て／符号拡張、
literal keyの別entry化、2種類の走査順変更、余分なwarning、count式の型変更です。
コンパイルできない変種を検出成功に数えていません。
wildcardの符号拡張は当初後続の上書きに隠れたため、上書き前の値と個数・非存在を追加して再確認しました。

warning条件は`:expected_stderr_regex:`をrawのstdout＋stderrへ適用します。
余分な`$warning`が通常のstdout正規化で取り除かれても、無警告テストは失敗します。
warning必須の2本では、正しい値の出力からwarningだけを除いた合成入力を不合格、
WARNINGを加えた入力を合格とする対照確認を行いました。
これは判定器の確認であり、未対応シミュレータで診断動作が成功したという証跡ではありません。
文言やソース行は固定しませんが、診断に`warn`/`warning`の識別語がある形式を対象にしています。

管理ツールの74テスト、規格資料ハッシュ、対応根拠・実行証跡の鮮度、
カタログ・統計・depth・生成物・メタデータの整合性を検査しています。
既存の要求定義、対応根拠、集合証拠、保留判断と、前回までの未コミット変更は保持しています。
