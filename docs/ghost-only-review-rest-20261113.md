<a id="ghost-only-review-rest-2026-11-13"></a>

# Ghostだけが一致するテストの見直し：残りの章（2026-11-13）

[English](ghost-only-review-rest-20261113.en.md) / [日本語](ghost-only-review-rest-20261113.md)

Ghostだけが期待値と一致するテストのうち、[37章](ghost-only-review-ch37-20261113.md)、[16章](ghost-only-review-ch16-20261113.md)、[36・38・39・40章](ghost-only-review-vpi-20261113.md)の見直しで扱わなかった332本を、IEEE 1800-2023と照らした結果です。
期待値は規格だけから判定し、シミュレータの出力は判定に使っていません。
この見直しでは、テストを変えていません。

<a id="what-was-reviewed"></a>

## 見直した対象

- 2026-11-12のNightlyで、Ghostだけが一致するテストのうち、まだ見直していなかった332本です。章ごとの内訳は、32章44本、31章34本、17章32本、18章29本、20章23本、6章22本、19章18本、21章17本、23章15本、28章11本、35章11本、7章10本、30章10本、33章10本、9章8本、14章6本、4章5本、25章5本、5章3本、11章3本、15章3本、22章3本、10章2本、12章2本、26章2本、3章1本、8章1本、13章1本、24章1本です。このうち35本は生成テストです。
- 使用量を抑えるため、これまでの見直しと違い、レビューは1本につき1回です。章ごとに17の組に分け、それぞれ1つのレビューが読みました。
- 「正しい」以外の判定は、その根拠となる規格の文、構文、図を確かめ直しました。30.7.4.2の図30-7は、画像で確かめました。
- どのレビューもAIによるものです。人による独立したレビューではありません。

<a id="verdicts"></a>

## 判定

| 判定 | 本数 |
|---|---:|
| 期待値は正しい | 289 |
| 期待値が誤っている | 0 |
| テストに欠陥がある | 19 |
| 読み方が割れる | 24 |
| 合計 | 332 |

<a id="flawed"></a>

## 欠陥がある19本

| テスト | 節 | 内容 |
|---|---|---|
| `ch6/test_interconnect_and_net_port_types` | 6.6.8、A.2.1.3 | 説明にある「識別子が2つの宣言」が、コードにありません。配列の要素`arr[1]`は、どこにも接続されていません。表示される値は正しいです。 |
| `ch6/test_interconnect_net_alias` | A.2.1.3 | 1つの`interconnect`宣言で、4つの名前を宣言しています。構文が許すのは2つまでなので、設計が規格に合いません。 |
| `ch17/test_checker_always_comb_output` | 17.2、10.3.2 | 出力`z`に初期値を付け、`assign`でも駆動しています。17.2では出力の初期値は変数の初期化と同じ意味で、10.3.2は継続代入で駆動する変数の初期化を禁じています。 |
| `ch17/test_checker_free_activity` | 17.7.2 | `first = z;`の直後に`z != first`を調べるので、この条件は常に偽です。同じ時刻の中で`z`が変わらないことを確かめられません。`u[1]`も表示されません。 |
| `ch18/test_rand_join_length_bias` | 18.17.5 | `rand join`の偏りの大きさを、18.17.5は数値で定めていません。回数の大小関係は保証されません。 |
| `ch18/test_rand_real_uniform_and_dist` | 18.5.3、18.14.1 | 統計による判定です。規格どおりの乱数でも、およそ1.7%の確率で失敗します。 |
| `ch19/test_covergroup_bins_and_range_forms` | 19.5 | `bins fromset = set_vals;`の`set_vals`は、定数でないモジュール変数です。19.5がcovergroup_expressionで変数として認めるのは、定数、インスタンス定数、refでない引数だけです。 |
| `gen/ch21/test_gen_comb_fread_struct_array_member`、`gen/ch21/test_gen_comb_fread_struct_multidimensional`（2本） | 21.3.4.4、7.4.3 | unpacked構造体の配列（多次元のものを含む）への`$fread`を、21.3.4.4は定めていません。期待値は、規格の規則を自然に組み合わせたものです。直すのは生成器です。 |
| `ch23/test_port_collapse_trireg_charge_strength`、`ch23/test_port_collapse_trireg_external_charge`（2本） | 23.3.3.7、6.6.4.1 | ポートでネットを併合することを前提にしています。23.3.3.7は併合を「してもよい」としているだけです。併合しない場合、trireg同士は大きいほうの電荷強度を共有し、保持の行が変わります。 |
| `ch23/test_vpi_port_kind_defaults` | 23.2.2.3、6.7.1 | `input int in_int`は、23.2.2.3により既定のネット型の`wire int`になります。6.7.1はネットのデータ型を4値型に限るので、設計が規格に合いません。 |
| `ch26/test_std_package_system_types` | 15.3.4、6.21、9.7 | `try_get`の戻り値を1と比べています。15.3.4が決めているのは正の整数であることだけです。また、staticの初期化で`process::self()`を呼んでいますが、その時点では呼び出し元のプロセスがありません。 |
| `ch31/test_timing_edge_descriptors_all`、`ch32/test_sdf_tchk_edge_condition_match`（2本） | 4.9.6、6.7.1、31.5、31.3.2、4.7 | 時刻0に、セルのポートのネットがzから0に変わります。更新の順序によっては、時刻0にholdの違反が起き、表示が増えます。 |
| `ch32/test_sdf_recrem_limits` | 31.6、4.7 | 時刻12に、2つのnotifierが別々に変わります。`always @(u.nrec or u.nrem)`がその間に動くと、行が1つ増えます。 |
| `ch35/test_dpi_dynamic_array_actual` | 35.5.6 | サイズを決めた配列の仮引数に、動的配列を渡しています。35.5.6は、このような実引数を処理系が制限できるとしています。 |
| `ch35/test_dpi_export_task_result` | 35.8 | importしたfunctionのCコードから、exportしたtaskを呼んでいます。35.8はこれを禁じています。 |
| `ch35/test_dpi_unpacked_aggregate_arguments` | H.7.4 | Cの`char`に入った-4を足しています。`char`に符号があるかどうかはCの処理系で決まり、符号がなければ合計が変わります。 |

<a id="contested"></a>

## 読み方が割れる24本

| テスト | 節 | 割れる点 |
|---|---|---|
| `ch6/test_a2_1_3_interconnect_declaration_identifiers` | 23.3.3.7.1 | 接続されない`ib[0]`がinterconnectのまま残ります。23.3.3.7.1の最後の規則がこれを違法とするかどうかが割れます。 |
| `ch6/test_builtin_net_declaration_forms` | 10.3.4、6.7.1 | ベクタのネットにドライブ強度を付けています。10.3.4は強度をスカラーのネットに限っています。期待値は、各ビットに強度が付く読み方です。 |
| `ch7/test_array_ordering_methods_and_index_queries` | 7.12.3、7.12.4 | 2次元配列の`with`で、`item`が要素か行かが割れます。7.12.3の例は行と読めます。期待値は要素ごとの読み方です。 |
| `ch11/test_equality_class_interface_chandle_handles` | 11.4.6、表11-1、8.4、6.14 | 11.4.6の最後の段落は、ハンドルの`==?`を`==`と同じとしています。表11-1、8.4、6.14は、ハンドルに使える演算子に`==?`を含めていません。 |
| `ch17/test_checker_assertion_placement` | 17.7.3、16.14.6、4.5 | Reactive領域で投入された並行アサーションが、同じ時刻のうちに評価されるかどうかが割れます。 |
| `ch18/test_inline_local_scope_binding` | 18.7.1、8.4 | `local::r`が、クラスのstaticメンバーか、ランダム化される対象のオブジェクト自身かが割れます。 |
| `ch18/test_rand_mode_inactive_handle`、`ch18/test_randomize_callback_override`（2本） | 18.8 | `o.h.rand_mode(0)`が、ハンドル`h`を止めるのか、`h`が指すオブジェクトの変数をすべて止めるのかが割れます。18.8の構文はどちらにも読めます。 |
| `ch19/test_cg_option_levels_readback` | 19.7、19.7.1 | インスタンスを作る前に読む`type_option`が、定義に書いた値か、既定値かが割れます。 |
| `ch20/test_pla_all_forms`、`ch20/test_pla_sync_snapshot_versus_async_update`（2本） | 20.16.1、20.16.4 | 非同期のPLAタスクが、呼ばれた時点で1回評価するかどうかが割れます。20.16.1の文は入力かpersonalityの変化だけを挙げ、20.16.4の例は呼ばれた時点の評価を前提にしています。 |
| `gen/ch20/test_gen_cross_dpiquery_1_up_neg_one_4_sized_offset_same_variable`、`gen/ch20/test_gen_cross_dpiquery_2_up_pos_one_4_sized_offset_same_variable`、`gen/ch20/test_gen_cross_dpiquery_3_up_neg_one_4_open_offset_switch_literal`（3本） | H.12.2、20.7 | `svDimensions`がpackedの次元も数えるかどうかが割れます。H.12.2は20.7と同じ意味としています。期待値はunpackedの次元だけを数える読み方です。 |
| `ch21/test_fwrite_unformatted_aggregates` | 21.2.1.1 | 21.2.1.1は、unpackedの集合型に`%u`を使うことを禁じる一方で、unpacked構造体への`%u`の動作を定めています。期待値は後者に従います。 |
| `ch23/test_defparam_block_task_function_parameters` | 6.20.1、23.10 | パラメータポートリストを持つモジュールで、ブロック、task、functionの中のparameterがlocalparamになるかどうかが割れます。 |
| `ch31/test_timing_check_condition_x` | 31.7、31.2 | 条件`en !== 1'b1`で`en`がxのとき、チェックが有効かどうかが割れます。31.7の文では有効になりません。式の値は1です。 |
| `ch32/test_sdf_scale_type_members` | 32.9（表32-6） | `FROM_MINIMUM`などが、1つの値に3つの係数をかけるのか、その値だけをその係数でかけるのかが割れます。 |
| `ch33/test_config_cell_parameter`、`gen/ch33/test_gen_cross_config_1_both_reset_all_0_if_literal_direct`、`gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_case_literal_wrapped`、`gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_if_literal_direct`、`gen/ch33/test_gen_cross_config_64_both_reset_all_0_if_literal_wrapped`（5本） | 33.4.1（構文33-4）、A.1.5、33.4.3 | use句の`#( )`です。構文にはなく、33.4.3の例にはあります。[既に記録した食い違い](simulator-differences.ja.md#config-use-parameter-form)と同じです。 |
| `ch33/test_duplicate_cell_last_definition_wins` | 33.3.1.1、3.13 | 同じ名前のモジュールが2つあります。33.3.1.1は最後の定義を使って警告するとし、3.13 a)は同じ名前の宣言を禁じています。 |

<a id="notes"></a>

## 判定を変えない指摘

次の5本は期待値が正しいものの、引用する節が違います。

- `ch9/test_wait_sequence_same_slot_twice`：引用の16.13.5 → 16.13.6
- `ch14/test_clocking_net_outputs_strong_drivers_resolved`：引用の21.2.1.5 → 21.2.1.4
- `ch28/test_trireg_charge_strength`：引用の28.15.1 → 28.15.2
- `ch32/test_sdf_cond_iopath`：引用の30.4.4.3 → 30.4.4.4
- `ch32/test_sdf_iopath_retain_forms`：引用の30.4.4.3 → 30.4.4.4

このほか、コメントの細かな誤りや、説明にある形をテストが実際には使っていない点が、いくつかのテストで指摘されました。どれも期待値には影響しません。

<a id="all-756"></a>

## 756本全体の結果

| 対象 | 本数 | 正しい | 誤り | 欠陥 | 規格の不備 | 割れる |
|---|---:|---:|---:|---:|---:|---:|
| 37章 | 193 | 142 | 4 | 26 | 4 | 17 |
| 16章 | 90 | 85 | 0 | 0 | 0 | 5 |
| 36・38・39・40章 | 141 | 108 | 3 | 19 | 0 | 11 |
| 残りの章 | 332 | 289 | 0 | 19 | 0 | 24 |
| 合計 | 756 | 624 | 7 | 64 | 4 | 57 |

<a id="next"></a>

## このあとの扱い

- 欠陥の19本は、次にGhostの結果を保存し直すときに直します。生成テストの2本は生成器を直します。
- 読み方が割れる24本は、判断を待ちます。
- 時刻0にポートのネットがzから変わることで、タイミングチェックが違反を出しうるテストは、Ghost以外でも一致しているテストにもありえます。次の見直しで全体を検索します。
- カバレッジの数字は変わりません。
