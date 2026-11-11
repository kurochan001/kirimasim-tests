<a id="clause-6-data-types"></a>

# 条項 6: データタイプ

[English](ch6.md) / [日本語](ch6.ja.md)

[すべての章](README.ja.md) .685 79 のテストを生成した。テストのメタデータから `tools/suite_catalog.py` がこのページを書きました。テストを編集しろ このページじゃない

初めて読む場合は、[実在テストを入力から期待値まで読み解く](../faq.md#q49-read-a-real-test)を参照してください。oracle欄は固定版による確認の記録です。[現在のビルドの合格を保証しない理由](../faq.md#q4-are-expected-outputs-copied-from-a-simulator)を確認してください。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_local_var_edge_cases`](../../tests/ch6/test_local_var_edge_cases.sv) |局所可変辺の場合| 6 | Icarus Verilog 13.0 ||
| [`test_data_type_of_parameter_variable_and_net`](../../tests/ch6/test_data_type_of_parameter_variable_and_net.sv) |同一の 4 - bit データ型のパラメータ、変数、およびネットは、いずれもその型の値を保持するため、範囲外の値はラップし、加算は 4 - bit となる。同じ 8 のビット列を持つ2変数でも、byte は符号付きで bit \[ 7:0 \] は符号付きではないため、読み取り値が異なる。| 6.2 6.18 6.20.2 6.11 | Icarus Verilog 13.0 ||
| [`test_user_types_built_from_other_types`](../../tests/ch6/test_user_types_built_from_other_types.sv) |ユーザ定義型は他のユーザ定義形式（4 - bit型のpacked配列、両者のpacked構造、構造のunpacked配列）から構築され、サイズと部品が構築型に従うオブジェクトを宣言する。| 6.2 6.18 7.2.1 7.4.1 | Verilator 5.052 ||
| [`test_ch6_extra_event_not_bit_storage`](../../tests/ch6/test_ch6_extra_event_not_bit_storage.sv) |イベントタイプにはストレージがありません。 4 つの状態 logic の値はイベント変数に割り当てられません。| 6.3.1 6.17 |標準のみ|違法なデザインだ|
| [`test_four_state_two_state_and_real_storage`](../../tests/ch6/test_four_state_two_state_and_real_storage.sv) |logicベクトルのbitとlogicから構築したタイプはそれぞれ0 , 1，x，zをそれぞれ持つが，2状態bitは0，1のみを持ち，実数は実数を持ち，xとzビットは0に変換される。| 6.3.1 6.11.2 6.12.1 6.8 | Icarus Verilog 13.0 | x/z |
| [`test_logic_basic`](../../tests/ch6/test_logic_basic.sv) |論理基礎テスト| 6.3.1 6.11 | Icarus Verilog 13.0 ||
| [`test_logic_value_meanings`](../../tests/ch6/test_logic_value_meanings.sv) |4つの基本値は，偽0，真1，未知x，高インピーダンスzとして振舞い，0と1は互いに補完する。| 6.3.1 12.4 11.4.7 6.6.1 | Icarus Verilog 13.0 | x/z |
| [`test_value_logic`](../../tests/ch6/test_value_logic.sv) |logic 値演算のテスト| 6.3.1 11.4.8 | Icarus Verilog 13.0 | x/z |
| [`test_z_input_acts_as_x_except_mos`](../../tests/ch6/test_z_input_acts_as_x_except_mos.sv) |logic MOS スイッチはzを通過し，ケースエクイティはxからzを指定する。| 6.3.1 28.4 28.5 28.7 11.4.3 11.4.5 11.4.8 11.4.11 | Icarus Verilog 13.0 | x/z |
| [`test_gate_drive_strength_beside_net_value`](../../tests/ch6/test_gate_drive_strength_beside_net_value.sv) |駆動強度を指定したゲートは、その強度で出力を駆動します。同じネットでは強いゲート出力が弱い出力に勝り、強度はネットの値と別に保持されます。強度が違うネット同士も値の比較では等しくなり、代入で伝えるのは値だけです。| 6.3.2 28.3.2 28.12.1 21.2.1.4 | Icarus Verilog 13.0 | x/z |
| [`test_illegal_charge_strength_on_tri1_net`](../../tests/ch6/test_illegal_charge_strength_on_tri1_net.sv) |tri1 ネットの宣言における電荷強度は拒否される| 6.3.2 6.3.2.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_charge_strength_on_wand_net`](../../tests/ch6/test_illegal_charge_strength_on_wand_net.sv) |ワンドネットの宣言における電荷強度を拒否した。| 6.3.2 6.3.2.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_charge_strength_on_wire_net`](../../tests/ch6/test_illegal_charge_strength_on_wire_net.sv) |wire ネットの宣言における電荷強度は拒否される| 6.3.2 6.3.2.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_drive_strength_without_assignment`](../../tests/ch6/test_illegal_drive_strength_without_assignment.sv) |ドライブ強度があるが連続代入がないネット宣言は拒否されます| 6.3.2 10.3.4 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_charge_strength_and_vectored_net_declarations`](../../tests/ch6/test_charge_strength_and_vectored_net_declarations.sv) |wire packed 次元をベクトル化またはスカラー化したネットを作成するトリレグキーワードで電荷強度を許容する。1は 5とAを 2本のワイヤーで運んでいます| 6.3.2.1 6.3.3 6.6.1 A.10 |標準のみ| x/z |
| [`test_trireg_retention_decay_and_recharge`](../../tests/ch6/test_trireg_retention_decay_and_recharge.sv) |トライレグは，分離後に未知の状態に減衰し，再充電できる。| 6.3.2.1 6.6.4.1 6.6.4.2 28.15.2 28.16.2.2 |標準のみ| x/z |
| [`test_net_declaration_drive_strength`](../../tests/ch6/test_net_declaration_drive_strength.sv) |ネットを代入るネット宣言は，その連続代入の駆動力を与え，それがネットを駆動する。| 6.3.2.2 10.3.1 10.3.4 21.2.1.4 | Icarus Verilog 13.0 | x/z |
| [`test_net_strength_and_scalared_select`](../../tests/ch6/test_net_strength_and_scalared_select.sv) |スケーラードネットパートは，非対称ドライバ強度を独立に解析する。| 6.3.2.2 6.9.2 | Icarus Verilog 13.0 ||
| [`test_aggregate_whole_copy_and_subroutine`](../../tests/ch6/test_aggregate_whole_copy_and_subroutine.sv) |unpacked 構造、ユニオン、配列は集合型であり、全体の値は代入でコピーされ、値ごとにサブルーティンに渡される。| 6.4 7.2.2 |標準のみ||
| [`test_singular_and_aggregate_value_copy`](../../tests/ch6/test_singular_and_aggregate_value_copy.sv) |パックされた単一値とunpacked集成値は、サブルーチンへ独立にコピーされます。| 6.4 7.7 | Verilator 5.052 ||
| [`test_singular_values_in_inside_sets`](../../tests/ch6/test_singular_values_in_inside_sets.sv) |内部演算子は、unpacked 配列に特異値まで下降し、スライス可能であるが一つの値であるpacked ベクトル、インデックス可能であるが一 つの値である文字列、クラスハンドルで停止します。| 6.4 11.4.13 | Verilator 5.052 ||
| [`test_ch6_extra_decl_init_mixed_writers`](../../tests/ch6/test_ch6_extra_decl_init_mixed_writers.sv) |宣言内の変数初期化は手続き代入として扱われるため、同じ変数に対する連続代入と競合する。| 6.5 11.5.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_ch6_extra_procedural_assign_mixed_writers`](../../tests/ch6/test_ch6_extra_procedural_assign_mixed_writers.sv) |プロセスの assign ステートメントはプロセス代入として計算され、同じ変数に対する連続代入と衝突します。| 6.5 10.6.1 11.5.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_continuous_assign_to_variable_converts_and_drops_strength`](../../tests/ch6/test_continuous_assign_to_variable_converts_and_drops_strength.sv) |変数にassignで書かれた連続的な代入は、 プリミティブ出力またはモジュール出力ポートによって、値を変数のタイプに変換し、ソースの強度を保持しない。| 6.5 10.3.2 23.3.3 6.11.2 6.12.1 10.3.4 |標準のみ| x/z |
| [`test_illegal_inout_port_declared_as_variable`](../../tests/ch6/test_illegal_inout_port_declared_as_variable.sv) |インアウトポートは変数として宣言できません| 6.5 23.2.2.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_input_port_variable_assigned`](../../tests/ch6/test_illegal_input_port_variable_assigned.sv) |モジュールは、ポートが変数のとき、自身の入力ポートに割り当てることができません。| 6.5 23.2.2.3 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_mixed_continuous_procedural`](../../tests/ch6/test_illegal_mixed_continuous_procedural.sv) |連続アセンブリで書き込まれる変数は、手続きアセンブリでは書き込めません。| 6.5 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_output_port_variable_also_assigned`](../../tests/ch6/test_illegal_output_port_variable_also_assigned.sv) |インスタンスの出力ポートに接続された変数は、他の場所に割り当てることはできません。| 6.5 23.3.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_overlapping_continuous_assigns`](../../tests/ch6/test_illegal_overlapping_continuous_assigns.sv) |変数の重なり合うビットに二つの連続的な代入は、他のビットが一度書かれても違法です。| 6.5 11.5.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_redeclaration`](../../tests/ch6/test_illegal_redeclaration.sv) |既にスコープに宣言された名前は、同じスコープにおいて再び宣言できません。| 6.5 3.13 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_variable_actual_on_inout_port`](../../tests/ch6/test_illegal_variable_actual_on_inout_port.sv) |変数をインスタンスの入出力ポートに接続できません| 6.5 23.3.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_variable_index_prefix_mixed_writers`](../../tests/ch6/test_illegal_variable_index_prefix_mixed_writers.sv) |変数インデックスを通しての手続き書きは、最長の静的接頭辞のすべての要素をカバーします。したがって、インデックスがそれを選択しない場合でも、それらのいずれかに対する連続的な代入と衝突します。| 6.5 11.5.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_variable_used_before_declaration`](../../tests/ch6/test_illegal_variable_used_before_declaration.sv) |変数はその宣言前に使用できません。暗黙のネットだけが 例外です| 6.5 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_net_driver_kinds_resolution_force`](../../tests/ch6/test_net_driver_kinds_resolution_force.sv) |連続割当，ゲート出力，モジュールポートがそれぞれネットを駆動し，その値はネットタイプの分解能で結合され，力がそれらをすべて上書きし，リリース後ネットは再びそのドライバの分解値を持つ。| 6.5 10.6.2 6.6.1 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_logic`](../../tests/ch6/test_net_logic.sv) |論理型の挙動| 6.5 10.3 | Icarus Verilog 13.0 | x/z |
| [`test_port_variable_net_implied_continuous`](../../tests/ch6/test_port_variable_net_implied_continuous.sv) |ポートの片側が変数、もう片側がネットの場合、暗黙の継続代入で接続されます。この代入はstrongの強度でネットを駆動し、すべての値変化に追従します。変数への書込みは、1つの継続代入または1つのoutputポートから行えます。| 6.5 23.3.3 21.2.1.4 | Icarus Verilog 13.0 ||
| [`test_ref_port_variable_shared_writers`](../../tests/ch6/test_ref_port_variable_shared_writers.sv) |2つのインスタンスのrefポートへ渡した変数は、両ポートで共有する1つの変数である。そのため、どちらかのインスタンスまたは親からの手続き的な書込みは、すべてのポートを通じて直ちに見える。| 6.5 23.3.3 | Verilator 5.052 ||
| [`test_variable_independent_element_writers`](../../tests/ch6/test_variable_independent_element_writers.sv) |unpacked unpacked 配列の異なる要素，ベクトルの異なるビットはそれぞれ別々の要素であり，それぞれ独自の連続代入または手続き書き込みが可能である。| 6.5 11.5.3 10.3.2 |標準のみ||
| [`test_variable_initializer_not_continuous`](../../tests/ch6/test_variable_initializer_not_continuous.sv) |変数宣言内の代入は変数を初期化するだけなので、その後の手続き的な書込みは保持され、初期化式のオペランドが後で変化しても変数には伝わらない。一方、net宣言内の代入はnetの駆動を継続する。| 6.5 6.8 10.3.1 | Icarus Verilog 13.0 ||
| [`test_variable_writer_override_order`](../../tests/ch6/test_variable_writer_override_order.sv) |変数に対して，フォースは手続き的割当を上書きし，手続き的書き込みは上書きされる。release、deassignの順に制御を戻す。連続代入を持つ変数にもforceを適用でき、複数の手続き的な書込み元がある場合は、最後の書込みで値が決まる。| 6.5 10.6.1 10.6.2 | Icarus Verilog 13.0 ||
| [`test_wire_logic`](../../tests/ch6/test_wire_logic.sv) |6.7 - 配線と論理テスト| 6.5 | Icarus Verilog 13.0 ||
| [`test_wire_reg`](../../tests/ch6/test_wire_reg.sv) |タイプ wire と reg のテスト| 6.5 6.7 6.8 | Icarus Verilog 13.0 ||
| [`test_builtin_net_undriven_values`](../../tests/ch6/test_builtin_net_undriven_values.sv) |ドライバなしでは、内蔵網はトリレグ以外はz、tri0・tri1はプル0・プル1 , supply0、supply1はサプラ0・サプラ1で、強いドライバに対してもドライバのみが切れる網はzに戻る。| 6.6 6.6.6 6.7.1 28.15.1 28.15.3 21.2.1.4 | Icarus Verilog 13.0 | x/z |
| [`test_net_type_forms`](../../tests/ch6/test_net_type_forms.sv) |triregを除くすべての内蔵ネットタイプのネットは、ドライバまたはタイプから値を取ります。サプライネットは定数、ワイヤーネットはドライバを解決し、tri0とtri1は下に引き上げ、uwire、wireとtriはドライバを1つ持っています。| 6.6 28.15 A.2.2.1 | Icarus Verilog 13.0 ||
| [`test_net_resolution`](../../tests/ch6/test_net_resolution.sv) |ネット解像度テスト| 6.6.1 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_tri`](../../tests/ch6/test_net_tri.sv) |トリネットタイプ（三状態）| 6.6.1 | Icarus Verilog 13.0 | x/z |
| [`test_net_types`](../../tests/ch6/test_net_types.sv) |ネットタイプテスト| 6.6.1 6.6.3 6.6.6 | Icarus Verilog 13.0 | x/z |
| [`test_net_types_2`](../../tests/ch6/test_net_types_2.sv) |wire，triおよび供給ネットは連続的な代入によって駆動される。| 6.6.1 6.6.6 | Icarus Verilog 13.0 | x/z |
| [`test_net_types_3`](../../tests/ch6/test_net_types_3.sv) |ネットタイプ: wire 、ワンド、ワー、トリ、supply0、supply1| 6.6.1 6.6.3 6.6.6 | Icarus Verilog 13.0 | x/z |
| [`test_net_types_edge_cases`](../../tests/ch6/test_net_types_edge_cases.sv) |ネットタイプのエッジケース| 6.6.1 6.6.3 6.6.5 | Icarus Verilog 13.0 | x/z |
| [`test_net_wire`](../../tests/ch6/test_net_wire.sv) |ワイヤーネット| 6.6.1 | Icarus Verilog 13.0 ||
| [`test_tri_edge_cases`](../../tests/ch6/test_tri_edge_cases.sv) |ドライバ付きと無いtri、tri0とtri1のネット| 6.6.1 6.6.5 | Icarus Verilog 13.0 | x/z |
| [`test_wire_edge_cases`](../../tests/ch6/test_wire_edge_cases.sv) |wire，トリ，ワンドおよびワーネットは1および2ドライバを持っていた。| 6.6.1 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_wire_tri_resolution_table`](../../tests/ch6/test_wire_tri_resolution_table.sv) |wireと3の解析における同じ強度の2つのドライバを，0 , 1，x，zの16対全てに対して同じ表で求めた。| 6.6.1 28.12 21.2.1.4 | Icarus Verilog 13.0 | x/z |
| [`test_illegal_uwire_on_tran_terminal`](../../tests/ch6/test_illegal_uwire_on_tran_terminal.sv) |トランススイッチの双方向端子に，単一の接続としても，ユーワイヤーネットは接続できない。| 6.6.2 28.8 |標準のみ|違法なデザインだ|
| [`test_illegal_uwire_overlapping_bit_drivers`](../../tests/ch6/test_illegal_uwire_overlapping_bit_drivers.sv) |bit bit を共有する uwire ベクトルの部分に二つの連続的な代入はエラーである。uwire のすべての［1］は一つのドライバしか持たない。| 6.6.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_uwire_two_drivers`](../../tests/ch6/test_illegal_uwire_two_drivers.sv) |2つのドライバを持つ uwire ネットはエラーです| 6.6.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_net_uwire`](../../tests/ch6/test_net_uwire.sv) |Uwire ネットタイプ (未解決 wire - 単一ドライバのみ)| 6.6.2 | Icarus Verilog 13.0 ||
| [`test_uwire_edge_cases`](../../tests/ch6/test_uwire_edge_cases.sv) |1つの連続的な任務を持つuwireネットは| 6.6.2 | Icarus Verilog 13.0 ||
| [`test_edge_wor_wand`](../../tests/ch6/test_edge_wor_wand.sv) |ワーネットとワンドネットは 2つの不変な要因を解決します| 6.6.3 4.4.2.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_resolution_multi`](../../tests/ch6/test_net_resolution_multi.sv) |tri0 / tri1 配線網，供給網，引力源，強度分解能| 6.6.3 6.6.5 6.6.6 28.10 28.12 | Icarus Verilog 13.0 | x/z |
| [`test_net_triand`](../../tests/ch6/test_net_triand.sv) |トリアンドネット型（三状態AND）| 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_trior`](../../tests/ch6/test_net_trior.sv) |トリオネット型（三状態OR）| 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_types_resolution`](../../tests/ch6/test_net_types_resolution.sv) |定数ドライバを持つwor，wand，tri，triand，tliorネットの分解能| 6.6.3 6.6.4 6.6.2 10.3.2 | Icarus Verilog 13.0 | x/z |
| [`test_net_wand`](../../tests/ch6/test_net_wand.sv) |ワンドネットタイプ (ワイヤー - AND )| 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_wor`](../../tests/ch6/test_net_wor.sv) |ワーネットタイプ (有線- OR)| 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_udn_resolution`](../../tests/ch6/test_udn_resolution.sv) |テスト: UDN (ユーザ定義ネット) 解像度関数| 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_wand_edge_cases`](../../tests/ch6/test_wand_edge_cases.sv) |2つのドライバを解決する| 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_wired_net_resolution_tables`](../../tests/ch6/test_wired_net_resolution_tables.sv) |ワンド、トリアンド、ワー、トリオネット上の同じ強度のドライバは、0 , 1、x、zのすべての16対に対して、ANDとORのテーブルで解決される。| 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_wor_edge_cases`](../../tests/ch6/test_wor_edge_cases.sv) |2つのドライバを解決するネットを| 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_trireg_driven_capacitive_states_and_decay`](../../tests/ch6/test_trireg_driven_capacitive_states_and_decay.sv) |0 , 1 または x を駆動するときのドライバの値と駆動力を取得し、全てのオフ時にその値をその電荷強度に保持し、第3の遅延の電荷減衰時間の後にx に保存された値を失い、再び駆動したときにその時間を再起動し、減衰時間なしに保持する。| 6.6.4 6.6.4.2 6.3.2.1 6.6 6.7 28.15.2 28.16.2 28.16.2.1 21.2.1.4 |標準のみ| x/z |
| [`test_trireg_holds_charge`](../../tests/ch6/test_trireg_holds_charge.sv) |ドライバが切れると，小型，中型，大型の電荷強度で最後の値を保持する。| 6.6.4 6.6.4.1 28.11 21.2.1.4 |標準のみ| x/z |
| [`test_trireg_capacitive_network_sharing`](../../tests/ch6/test_trireg_capacitive_network_sharing.sv) |tranif1を通して容量状態で三重項を接続すると，より大きな電荷がより小さい三重項の値と強度を設定し，異なるx値を持つ等しいサイズの三重項を作り，分離した小さい三重項は共有値を自身の電荷強度で保持する。| 6.6.4.1 6.3.2.1 6.6.4 28.13 21.2.1.4 |標準のみ| x/z |
| [`test_net_tri0`](../../tests/ch6/test_net_tri0.sv) |Tri0 ネットタイプ（浮動時は 0 に引き出す）| 6.6.5 | Icarus Verilog 13.0 | x/z |
| [`test_tri0_tri1_resolution_tables`](../../tests/ch6/test_tri0_tri1_resolution_tables.sv) |0 , 1，x，zの16対全てに対して，tri0とtri1の正味分解における2つの強いドライバは，両者がzでない限り強い強さを持ち，単一の弱いドライバまたはプルドライバは，暗黙的なプル値と結合する。| 6.6.5 28.12 21.2.1.4 | Icarus Verilog 13.0 | x/z |
| [`test_supply_edge_cases`](../../tests/ch6/test_supply_edge_cases.sv) |supply0 supply1 ネット、スカラー、ベクトル| 6.6.6 4.7 | Icarus Verilog 13.0 ||
| [`test_supply_wire`](../../tests/ch6/test_supply_wire.sv) |テスト電源線| 6.6.6 | Icarus Verilog 13.0 ||
| [`test_illegal_nettype_declares_variable`](../../tests/ch6/test_illegal_nettype_declares_variable.sv) |ユーザ定義のネットタイプで宣言された変数は拒否されます| 6.6.7 |標準のみ|違法なデザインだ|
| [`test_illegal_nettype_resolver_nonstatic_method`](../../tests/ch6/test_illegal_nettype_resolver_nonstatic_method.sv) |解像度関数が非静的クラスメソッドのネットタイプは拒否されます。| 6.6.7 8.10 |標準のみ|違法なデザインだ|
| [`test_illegal_nettype_resolver_resizes_driver_array`](../../tests/ch6/test_illegal_nettype_resolver_resizes_driver_array.sv) |ドライバ配列のサイズを変更する解像度関数は拒否されます| 6.6.7 |標準のみ|違法なデザインだ|
| [`test_illegal_nettype_resolver_return_type`](../../tests/ch6/test_illegal_nettype_resolver_return_type.sv) |解像度関数がネットタイプのデータタイプ以外のタイプを返すネットタイプは拒否されます| 6.6.7 |標準のみ|違法なデザインだ|
| [`test_illegal_nettype_resolver_side_effect`](../../tests/ch6/test_illegal_nettype_resolver_side_effect.sv) |副作用として，モジュールの変数を書き込む解像度関数を拒否した。| 6.6.7 |標準のみ|違法なデザインだ|
| [`test_illegal_nettype_resolver_writes_driver_array`](../../tests/ch6/test_illegal_nettype_resolver_writes_driver_array.sv) |ドライバ配列の要素を書き込む解像度関数は拒否されます| 6.6.7 |標準のみ|違法なデザインだ|
| [`test_illegal_nettype_unresolved_two_drivers`](../../tests/ch6/test_illegal_nettype_unresolved_two_drivers.sv) |2つの連続ドライバを持つ分解能関数のないネットタイプのネットを拒否する| 6.6.7 10.3 |標準のみ|違法なデザインだ|
| [`test_nettype_declarations_and_user_nets`](../../tests/ch6/test_nettype_declarations_and_user_nets.sv) |解決関数なしのネットタイプ宣言、直接、パッケージまたはクラスを通して名前付けられたもの、パッケージの範囲を持つまたは持たないネットタイプの新しい名前、これらのネットタイプのネットを遅延とネット宣言代入のリストを持って宣言し、解決値と変更時間を観察した。| 6.6.7 6.7.2 6.7.3 10.3.3 A.2.1.3 A.2.3 A.2.4 |標準のみ| x/z |
| [`test_nettype_identifier_and_net`](../../tests/ch6/test_nettype_identifier_and_net.sv) |ネットタイプ宣言はデータタイプと識別子を持つユーザ定義ネットタイプを名付け、その名前で宣言されたネットはそのデータタイプの四状態意味論を持つ駆動値を持つ。| 6.6.7 6.6.1 A.9.3 |標準のみ||
| [`test_nettype_resolution`](../../tests/ch6/test_nettype_resolution.sv) |ユーザ定義ネットタイプのネットは、出力ポートを含む全ドライバから、その解像度関数が計算した値を、ドライバが変更される度に再び取る。2番目のネットタイプ名は解像度を共有し フォースとリリースは解像度を上書きして復元します| 6.6.7 10.3 10.6.2 23.3.3 |標準のみ||
| [`test_user_nettype_resolution_forms`](../../tests/ch6/test_user_nettype_resolution_forms.sv) |4状態，2状態，実数，shortrealおよびunpackedデータ型のユーザ定義ネットタイプ，パッケージスコープを通じて直接名付けた解析器またはパラメータ化クラスの静的メソッドとして，パッケージスコープを通じて名前を変更し，遅延を伴って宣言し，配列として，解析器なしで，ネットを全体として解析する。| 6.6.7 6.6 6.7 6.7.2 6.7.3 13.8 |標準のみ| x/z |
| [`test_x_value_bitwise`](../../tests/ch6/test_x_value_bitwise.sv) |4 -state logic 真理値テーブル| 6.6.7 11.4.8 | Icarus Verilog 13.0 | x/z |
| [`test_a2_1_3_interconnect_declaration_identifiers`](../../tests/ch6/test_a2_1_3_interconnect_declaration_identifiers.sv) |暗黙のデータ型、ゼロ遅延、および2つの識別子を持ち、2番目の識別子にunpacked次元を指定したinterconnect宣言は、2つのinterconnect netを宣言する。各netは、ポートを介してドライバからリーフへ値を伝える。| 6.6.8 23.3.3.7 A.2.1.3 |標準のみ||
| [`test_illegal_interconnect_assigned`](../../tests/ch6/test_illegal_interconnect_assigned.sv) |相互接続ネットは連続代入のターゲットにはならない| 6.6.8 6.7.1 |標準のみ|違法なデザインだ|
| [`test_illegal_interconnect_continuous_assign`](../../tests/ch6/test_illegal_interconnect_continuous_assign.sv) |2つのポートを接続する相互接続ネットは連続代入のターゲットにはなりません| 6.6.8 |標準のみ|違法なデザインだ|
| [`test_illegal_interconnect_force`](../../tests/ch6/test_illegal_interconnect_force.sv) |2つのポートを接続する相互接続ネットは，フォースステートメントのターゲットとなりえない。| 6.6.8 10.6.2 |標準のみ|違法なデザインだ|
| [`test_illegal_interconnect_procedural_read`](../../tests/ch6/test_illegal_interconnect_procedural_read.sv) |2 つのポートを接続するインターコネクトネットは手続きコードで読めません| 6.6.8 |標準のみ|違法なデザインだ|
| [`test_interconnect_and_net_port_types`](../../tests/ch6/test_interconnect_and_net_port_types.sv) |unpacked 次元の 1 つまたは 2 つの識別子を持つ暗黙のデータ型、ゼロ遅延を持つ相互接続ネット宣言、 2 つのモジュールレベルを通して駆動値を持つ相互 接続ポート、内蔵ネットタイプ、データタイプのみ、ユーザネットタイプで書かれたネットポート。| 6.6.8 23.3.3.7 A.2.1.3 A.2.2.1 |標準のみ||
| [`test_interconnect_array_mixed_net_types`](../../tests/ch6/test_interconnect_array_mixed_net_types.sv) |1つの相互接続配列の要素は，それぞれが接続するポートのタイプを取って，異なるネットタイプに分解できる。| 6.6.8 23.3.3.7.1 6.6.3 |標準のみ||
| [`test_interconnect_net_alias`](../../tests/ch6/test_interconnect_net_alias.sv) |これは、ネットの一つに接続されたドライバが、他のネットに接続されたリーダに到達するように、エイリアス文を使って相互接続ネットに加入することができる。| 6.6.8 10.11 23.3.3.7.1 |標準のみ| x/z |
| [`test_illegal_charge_strength_in_tri_declaration`](../../tests/ch6/test_illegal_charge_strength_in_tri_declaration.sv) |電荷強度は trireg キーワードでのみ許可されるため tri 宣言には 電荷強度が存在できません| 6.7 | Icarus Verilog 13.0 |違法なデザイン x/z|
| [`test_illegal_scalared_net_without_packed_dimension`](../../tests/ch6/test_illegal_scalared_net_without_packed_dimension.sv) |少なくとも1つの packed次元を必要とする ベクトルまたはスカラーを使うネット宣言| 6.7 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_vectored_net_without_packed_dimension`](../../tests/ch6/test_illegal_vectored_net_without_packed_dimension.sv) |ベクトルを使うネット宣言には スカラーを使うような少なくとも1つの packed次元が必要です| 6.7 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_net_declaration_delay_forms`](../../tests/ch6/test_net_declaration_delay_forms.sv) |ネット宣言は、1つの遅延値または1つ、2つ、3つの遅延の括弧内リストを代入ることができる。それぞれの値は、min:typ:maxである。1つの値は全てのトランジションに適用され 2つ目は上昇と下降の遅延を与えます zは小さい値で 3つ目は上昇、下降、切り替えを与えます| 6.7 10.3.3 28.16 | Icarus Verilog 13.0 | x/z |
| [`test_net_declaration_drive_strength_pairs`](../../tests/ch6/test_net_declaration_drive_strength_pairs.sv) |ネット宣言の代入では、supply・strong・pull・weak・highzから選ぶ0側と1側の駆動強度を、どちらの順序でも指定できます。ベクタネットの各bitは、固有の4状態値と強度を持ちます。| 6.7 6.7.1 10.3.4 28.12 21.2.1.4 | Icarus Verilog 13.0 | x/z |
| [`test_net_declaration_legal_strength_pairs`](../../tests/ch6/test_net_declaration_legal_strength_pairs.sv) |許容される全ての駆動力ペア形式を受け入れ 表示された力をネットに供給します| 6.7 | Icarus Verilog 13.0 | x/z |
| [`test_net_delay_value_forms`](../../tests/ch6/test_net_delay_value_forms.sv) |net宣言の遅延には、符号なし数値、実数、識別子、時間リテラル、または1stepを使用でき、いずれもモジュールの時間単位でスケーリングする| 6.7 |標準のみ||
| [`test_wire_init`](../../tests/ch6/test_wire_init.sv) |初期化をテスト wire| 6.7 10.3.1 | Icarus Verilog 13.0 ||
| [`test_builtin_net_declaration_forms`](../../tests/ch6/test_builtin_net_declaration_forms.sv) |内蔵されたネット宣言は、スケールまたはベクトル化されたドライブ強度または電荷強度、暗黙的または明示的なデータタイプ、遅延、ネット宣言代入のリスト、値、強度、変化時間を通して観測される unpacked次元を持っています。| 6.7.1 6.9.2 10.3.1 10.3.3 10.3.4 6.6.4 A.2.1.3 A.2.3 A.2.4 21.2.1.4 |標準のみ| x/z |
| [`test_illegal_interconnect_charge_strength`](../../tests/ch6/test_illegal_interconnect_charge_strength.sv) |相互接続ネット宣言は電荷強度を指定できません| 6.7.1 6.6.8 |標準のみ|違法なデザインだ|
| [`test_illegal_interconnect_data_type`](../../tests/ch6/test_illegal_interconnect_data_type.sv) |相互接続ネットはデータタイプで宣言できません| 6.7.1 6.6.8 |標準のみ|違法なデザインだ|
| [`test_illegal_interconnect_declaration_assignment`](../../tests/ch6/test_illegal_interconnect_declaration_assignment.sv) |相互接続ネット宣言には代入表現はありません| 6.7.1 6.6.8 |標準のみ|違法なデザインだ|
| [`test_illegal_interconnect_drive_strength`](../../tests/ch6/test_illegal_interconnect_drive_strength.sv) |インターコネクトネット宣言はドライブ強度を指定できません| 6.7.1 6.6.8 |標準のみ|違法なデザインだ|
| [`test_illegal_interconnect_explicit_type`](../../tests/ch6/test_illegal_interconnect_explicit_type.sv) |明示的なデータ型を持つ相互接続宣言は違法です| 6.7.1 6.7 |標準のみ|違法なデザインだ|
| [`test_illegal_interconnect_initializer`](../../tests/ch6/test_illegal_interconnect_initializer.sv) |代入表現を持つ相互接続宣言は違法です| 6.7.1 |標準のみ|違法なデザインだ|
| [`test_illegal_interconnect_strength`](../../tests/ch6/test_illegal_interconnect_strength.sv) |ドライブ強度を持つインターコネクト宣言は違法です| 6.7.1 6.7 |標準のみ|違法なデザイン x/z|
| [`test_illegal_interconnect_two_delays`](../../tests/ch6/test_illegal_interconnect_two_delays.sv) |ネット間接続宣言は遅延値を 1 つ指定できますが 2 つはできません| 6.7.1 6.6.8 |標準のみ|違法なデザインだ|
| [`test_illegal_net_type_reg_in_port_declaration`](../../tests/ch6/test_illegal_net_type_reg_in_port_declaration.sv) |ネットタイプキーワード tri の後に直接キーワード reg が続くことはできません。| 6.7.1 23.2.2.3 |標準のみ|違法なデザインだ|
| [`test_illegal_net_type_then_reg`](../../tests/ch6/test_illegal_net_type_then_reg.sv) |net タイプのキーワードは、宣言の中で直接キーワード reg に続けられません。| 6.7.1 |標準のみ|違法なデザインだ|
| [`test_net_declaration_data_types`](../../tests/ch6/test_net_declaration_data_types.sv) |ネットは任意の4状態整数データ型，typedefまたはpacked構造を持ち，1つの構造を持たないネットはlogicであり，非駆動ネットはbit個のzを持つ。| 6.7.1 6.11.1 7.2.1 | Icarus Verilog 13.0 | x/z |
| [`test_net_declaration_lists_and_reg_keyword`](../../tests/ch6/test_net_declaration_lists_and_reg_keyword.sv) |1つのネット宣言で、個別のunpacked次元と任意の初期代入を持つ複数のネットを列挙でき、すべて先頭のネット型で解決します。ネット型キーワードとの間にscalaredや駆動強度などの別トークンがある場合、その後にregを指定できます。| 6.7.1 6.7 | Verilator 5.052 ||
| [`test_net_four_state_data_types`](../../tests/ch6/test_net_four_state_data_types.sv) |logic はデータ型を持たず、または範囲のみを持つネットであり、xとzを含む。ネットは 4 状態データ型で宣言することもできます。例えば logic , integer 、logic の typedef 、または packed 構造、または固定サイズの unpacked 配列として。| 6.7.1 6.11.1 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_net_unpacked_struct_union_data_types`](../../tests/ch6/test_net_unpacked_struct_union_data_types.sv) |ネットはunpacked構造またはユニオン型を持つか，またはunpacked構造とunpacked配列を含む構造を持つことができる。| 6.7.1 7.2 7.3 10.3 | Verilator 5.052 ||
| [`test_trireg_default_value_strength`](../../tests/ch6/test_trireg_default_value_strength.sv) |どのドライバも駆動していない間、triregネットはサイズで定める電荷強度（既定はmedium）でxを保持し、他のネットはzを保持します。| 6.7.1 6.3.2.1 21.2.1.4 |標準のみ| x/z |
| [`test_nettype_alias_resolution_and_empty_drivers`](../../tests/ch6/test_nettype_alias_resolution_and_empty_drivers.sv) |ネットタイプエイリアスの連鎖はポートドライバとドライブなし解決ネットを合わせ、空のドライバセットを評価します。| 6.7.2 6.7.3 6.22.6 |標準のみ||
| [`test_nettype_initial_value_resolution`](../../tests/ch6/test_nettype_initial_value_resolution.sv) |ユーザ定義のネットタイプのネットは、データタイプのデフォルト値で始まり、構造メンバー初期化子を含み、logic はzではなくxであり、解決されたネットタイプはドライバなしでも時間ゼロで解決します。| 6.7.3 6.7.2 6.6.7 |標準のみ| x/z |
| [`test_class_static_init_order`](../../tests/ch6/test_class_static_init_order.sv) |クラスのstaticプロパティとpackage変数の宣言時初期化は、すべてのinitial手続きより前に有効になります。そのため、時刻0の更新は初期値に基づいて行われ、後から初期化で上書きされません。| 6.8 8.9 26.2 | Verilator 5.052 ||
| [`test_enum_default_and_invalid_index`](../../tests/ch6/test_enum_default_and_invalid_index.sv) |変数 enum はそのベースタイプのデフォルトで始まり、 enum のインデックスが無効な場合も同様です。| 6.8 6.19 7.4.5 8.7 |標準のみ| x/z |
| [`test_illegal_automatic_module_variable`](../../tests/ch6/test_illegal_automatic_module_variable.sv) |プロセスの文脈以外のデータ宣言は 自動キーワードを使えません| 6.8 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_const_implicit_type_without_var`](../../tests/ch6/test_illegal_const_implicit_type_without_var.sv) |packed 範囲のみを与える変数宣言には var キーワードが必要です。範囲だけでコンストを作るのは違法です| 6.8 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_type_reference_without_var`](../../tests/ch6/test_illegal_type_reference_without_var.sv) |変数型として使う type_reference は var がないと違法です| 6.8 |標準のみ|違法なデザインだ|
| [`test_logic_type`](../../tests/ch6/test_logic_type.sv) |テスト logic タイプ| 6.8 | Icarus Verilog 13.0 ||
| [`test_logic_val`](../../tests/ch6/test_logic_val.sv) |論理値テスト| 6.8 | Icarus Verilog 13.0 ||
| [`test_package_call_matrix`](../../tests/imported/ch6/test_package_call_matrix.sv) |パッケージの関数、タスク、変数、変数を読み込む関数、初期から使用する、always_comb , always_ff、常に@*、連続代入、ネット宣言代入、初期値、モジュール関数、最終手順、生成ブロック、インスタンスとそのポート接続| 6.8 9.2 10.3 13.4 23.3.2 26.3 |標準のみ|上部モジュール x/z|
| [`test_reg_edge_cases`](../../tests/ch6/test_reg_edge_cases.sv) |変数 reg: 初期 x, x, z 値、選択、符号 reg| 6.8 6.11 | Icarus Verilog 13.0 | x/z |
| [`test_reg_init`](../../tests/ch6/test_reg_init.sv) |テストレジスタ初期化| 6.8 10.5 | Icarus Verilog 13.0 ||
| [`test_uninitialized_package_and_class_variables`](../../tests/ch6/test_uninitialized_package_and_class_variables.sv) |パッケージとクラスのプロパティにおける4-state変数は初期化子がないときはxで始まり、2-state変数は0で始まる。| 6.8 26.2 8.7 | Icarus Verilog 13.0 | x/z |
| [`test_var_declaration_implicit_logic`](../../tests/ch6/test_var_declaration_implicit_logic.sv) |これは、データ型を指定するための 文字列を指定するために使用されます。タイプがないか 範囲や符号だけがある場合 変数はlogicの変数で xとzを持ち 与えられた幅と符号を持つ| 6.8 | Icarus Verilog 13.0 | x/z |
| [`test_var_keyword_without_data_type_is_logic`](../../tests/ch6/test_var_keyword_without_data_type_is_logic.sv) |モジュール内および手続きブロック内で var の後のデータ型を省略した変数宣言は、記述された範囲と符号を持つ logic 型（4 状態、未初期化時は x）となり、明示的な型の前に var を置いた場合はその型が保たれる。| 6.8 A.2.1.3 A.10 | Icarus Verilog 13.0 | x/z |
| [`test_variable_categories_and_modifiers`](../../tests/ch6/test_variable_categories_and_modifiers.sv) |変数宣言は、すべてのデータ型分類、const・var・寿命の修飾子を受け付け、整数型と実数型の分類ではそれぞれの値の規則を維持する| 6.8 6.11.1 6.12 |標準のみ||
| [`test_variable_decl_assignment_entries`](../../tests/ch6/test_variable_decl_assignment_entries.sv) |固定・キュー・連想・動的次元と省略可能な初期化式を持つ名前からなる変数宣言代入リスト、new \[ n \]とnew \[ n \](array)を使う動的配列、およびnew・new(arguments)・型付きコンストラクタ呼出し・シャローコピー・初期化なしのクラス変数| 6.8 7.5.1 8.7 8.8 8.12 A.2.3 A.2.4 | Verilator 5.052 ||
| [`test_variable_declaration_forms_and_modifiers`](../../tests/ch6/test_variable_declaration_forms_and_modifiers.sv) |変数宣言はconst，var，static，integerベクトル型，integer原子型，packed次元，packed構造，enumタイプ，unpackedダイナミック配列，クラス宣言を持つ。変数は次の代入までその値を保持します| 6.8 7.2.1 7.3.1 6.19 7.5.1 8.8 | Icarus Verilog 13.0 ||
| [`test_variable_declaration_qualifiers`](../../tests/ch6/test_variable_declaration_qualifiers.sv) |変数の宣言は、オプションの const、var、static または automatic キーワードを順番に含み、暗黙型 (var 単独、シグニング、packed 次元) または明示型であり、 2 つの宣言代入のリストを持ち、 width、signness、x スタート値、呼び出し間に保持または再設定される値、タスク引数からの const セットを通して観察されます。| 6.8 6.20.6 6.21 A.2.1.3 A.2.3 |標準のみ| x/z |
| [`test_variable_default_values_nonintegral`](../../tests/ch6/test_variable_default_values_nonintegral.sv) |初期化子がないとき、 real、shortreal、realtime 変数は 0.0 から始まり、文字列は空で、 chandle、クラス、インタフェースクラスのハンドルは null で、各イベント変数は、トリガされ、待たれる新しいイベントを持つ。| 6.8 6.12 6.16 6.14 8.4 8.26 15.5 | Verilator 5.052 ||
| [`test_virtual_interface_type_forms`](../../tests/ch6/test_virtual_interface_type_forms.sv) |仮想interface変数の型は、interfaceキーワードの有無を選べ、interfaceのパラメータ値とmodportを指定できる。各変数は、そのパラメータ設定のインスタンスを参照する。| 6.8 25.9 | Verilator 5.052 ||
| [`test_logic_vector`](../../tests/ch6/test_logic_vector.sv) |論理ベクトルテスト| 6.9 | Icarus Verilog 13.0 ||
| [`test_illegal_vector_range_real_bound`](../../tests/ch6/test_illegal_vector_range_real_bound.sv) |定数 integer 表現を使うことで、ベクトル範囲の境界を定義できます。実際のパラメータは違法です| 6.9.1 |標準のみ|違法なデザインだ|
| [`test_illegal_vector_range_variable_bound`](../../tests/ch6/test_illegal_vector_range_variable_bound.sv) |ベクトル範囲の境界は一定の表現でなければなりません変数は違法です| 6.9.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_vector_range_x_bound`](../../tests/ch6/test_illegal_vector_range_x_bound.sv) |ベクトル範囲の境界は xbit を含めない| 6.9.1 | Verilator 5.052 |違法なデザイン x/z|
| [`test_illegal_vector_range_z_bound`](../../tests/ch6/test_illegal_vector_range_z_bound.sv) |ベクトル範囲の境界は zbit を含めない| 6.9.1 | Verilator 5.052 |違法なデザイン x/z|
| [`test_max_width`](../../tests/ch6/test_max_width.sv) |算術、ビット単位、シフト、連結 64 - から 512 - bit ベクトル| 6.9.1 11.4.12 | Icarus Verilog 13.0 ||
| [`test_overflow_results_no_diagnostic`](../../tests/ch6/test_overflow_results_no_diagnostic.sv) |これは、integer 操作がオーバーフローすると、 まだ規定された有限幅の結果を生成し、オーバーフローメッセージが必要でないことを意味します。| 6.9.1 | Icarus Verilog 13.0 ||
| [`test_vector_65536_bits`](../../tests/ch6/test_vector_65536_bits.sv) |実装が設定できる最小の最大長さである 65536 ビットのベクトルを宣言し，両端で読み込み，書き込みできる。| 6.9.1 20.9 | Icarus Verilog 13.0 ||
| [`test_vector_ranges_bit_order_and_arithmetic`](../../tests/ch6/test_vector_ranges_bit_order_and_arithmetic.sv) |範囲のないオブジェクトは 1 - bit スカラーである。範囲は降順・昇順・負の添字・単一添字を取れます。左端の添字が常に最上位の bit です。ベクトルは 2 ** n を法として折り返し、signedとして宣言するかsignedポートへ接続しない限り符号なしです。| 6.9.1 6.9 7.4.1 23.2.2.1 | Icarus Verilog 13.0 ||
| [`test_scalared_vectored_net_selects`](../../tests/ch6/test_scalared_vectored_net_selects.sv) |また，ベクトルネット宣言において，スケーラードとベクトル化されたアドバイスキーワードを受け入れる。スカラーネットは bit-selectやpart-selectを通して 読み込まれ 駆動されることができます ベクトルネットは全体として動作します| 6.9.2 6.7 10.3 6.6.5 | Icarus Verilog 13.0 ||
| [`test_vector_net_scalared`](../../tests/ch6/test_vector_net_scalared.sv) |bit-selectとpart-selectを許可するスカラー化されたベクトルネットは、連続的な代入は単一のビットを駆動できるが、他の代入はネットタイプの値を保持する。| 6.9.2 6.6.5 10.3.2 | Icarus Verilog 13.0 | x/z |
| [`test_illegal_procedural_checker_implicit_net`](../../tests/ch6/test_illegal_procedural_checker_implicit_net.sv) |プロセスチェッカーのインスタンスの 宣言されていない実際は 暗黙のネットではありません| 6.10 17.3 |標準のみ|違法なデザインだ|
| [`test_implicit_net_declarations`](../../tests/ch6/test_implicit_net_declarations.sv) |連続代入の左側にある未定義の名前は、ポート接続または原始端末リストで暗黙スカラーネットとなります。| 6.10 22.8 | Icarus Verilog 13.0 ||
| [`test_implicit_net_scope_and_lookup`](../../tests/ch6/test_implicit_net_scope_and_lookup.sv) |連続代入の左側にある未宣言名は、ポート接続または原始端末で、参照の範囲内でデフォルトのネットタイプのスカラーネットとなり、ルークが宣言を見つけない場合のみ、スカラーネットとなります。| 6.10 22.8 23.9 27.5 | Icarus Verilog 13.0 ||
| [`test_implicit_port_expression_nets`](../../tests/ch6/test_implicit_port_expression_nets.sv) |ポート表現とポート宣言にのみ表示される名前は、ポート宣言の幅に従ってデフォルトのネットタイプのネットになります。| 6.10 23.2.2.1 22.8 |標準のみ||
| [`test_bit_type`](../../tests/ch6/test_bit_type.sv) |テスト bit タイプ| 6.11 | Icarus Verilog 13.0 ||
| [`test_bit_type_edge_cases`](../../tests/ch6/test_bit_type_edge_cases.sv) |ビット型エッジケース| 6.11 11.4.8 11.4.10 11.4.9 | Icarus Verilog 13.0 ||
| [`test_byte_edge_cases`](../../tests/ch6/test_byte_edge_cases.sv) |バイトエッジケース| 6.11 11.4.3 11.4.8 6.24.1 | Icarus Verilog 13.0 ||
| [`test_byte_ops`](../../tests/ch6/test_byte_ops.sv) |テスト byte 操作| 6.11 11.6.1 | Icarus Verilog 13.0 ||
| [`test_cast_bit`](../../tests/ch6/test_cast_bit.sv) |2-stateタイプキャスト| 6.11 10.7 | Icarus Verilog 13.0 ||
| [`test_core_types`](../../tests/ch6/test_core_types.sv) |テストコアタイプ| 6.11 6.12 6.16 6.4 | Icarus Verilog 13.0 | x/z |
| [`test_data_type_keyword_forms`](../../tests/ch6/test_data_type_keyword_forms.sv) |キーワードで書かれたデータタイプ: integer個の原子と両記号を持つベクトルタイプ、3つの非integer型、文字列、チャンドル、イベント、原子、ベクトル、typedef基、名前範囲を持つenum、packed符号構造、randメンバーを持つ構造、packedの構造と結合の配列、ソフトユニオン、暗黙のデータタイプ、内蔵されたネットタイプのネット| 6.11 6.12 6.14 6.16 6.17 6.19 7.2 7.3 A.2.2.1 | Verilator 5.052 ||
| [`test_int_types_edge_cases`](../../tests/ch6/test_int_types_edge_cases.sv) |テスト: Integer タイプのエッジケース| 6.11 5.7.1 | Icarus Verilog 13.0 ||
| [`test_integer_edge_cases`](../../tests/ch6/test_integer_edge_cases.sv) |整数辺の場合| 6.11 | Icarus Verilog 13.0 | x/z |
| [`test_integer_ops`](../../tests/ch6/test_integer_ops.sv) |整数演算テスト| 6.11 | Icarus Verilog 13.0 ||
| [`test_integer_type`](../../tests/ch6/test_integer_type.sv) |テスト integer タイプ| 6.11 | Icarus Verilog 13.0 ||
| [`test_integer_types`](../../tests/ch6/test_integer_types.sv) |章 6：データタイプ| 6.11 6.11.1 6.11.2 6.11.3 | Icarus Verilog 13.0 | x/z |
| [`test_integer_types_state_and_signing`](../../tests/ch6/test_integer_types_state_and_signing.sv) |これらの値は、bit , byte , shortint , intとlongintはxとzを0として保存し、integer、logic、regは保持します。byte , shortint , int , integerとlongintは符号付きで時間、bit , reg , logicとそのpackedの配列は符号なしである。reg は 宣言された幅を持っています| 6.11 6.11.2 6.11.3 6.9 | Icarus Verilog 13.0 | x/z |
| [`test_longint_type`](../../tests/ch6/test_longint_type.sv) |テスト longint タイプ| 6.11 | Icarus Verilog 13.0 ||
| [`test_net_reg`](../../tests/ch6/test_net_reg.sv) |規則変数のタイプ| 6.11 | Icarus Verilog 13.0 ||
| [`test_reg_type`](../../tests/ch6/test_reg_type.sv) |テスト reg タイプ| 6.11 | Icarus Verilog 13.0 ||
| [`test_reg_wire_types`](../../tests/ch6/test_reg_wire_types.sv) |規則とワイヤータイプテスト| 6.11 6.5 | Icarus Verilog 13.0 ||
| [`test_shortint_byte`](../../tests/ch6/test_shortint_byte.sv) |ショートインタとバイトタイプのテスト| 6.11 | Icarus Verilog 13.0 ||
| [`test_shortint_edge_cases`](../../tests/ch6/test_shortint_edge_cases.sv) |shortint 初期値、範囲限界、算術| 6.11 | Icarus Verilog 13.0 ||
| [`test_shortint_type`](../../tests/ch6/test_shortint_type.sv) |テスト shortint タイプ| 6.11 | Icarus Verilog 13.0 ||
| [`test_signal_types_edge_cases`](../../tests/ch6/test_signal_types_edge_cases.sv) |変数 logic 、 bit 、 integer 、 int とそれらの間の代入| 6.11 | Icarus Verilog 13.0 ||
| [`test_type`](../../tests/ch6/test_type.sv) |整数型、実変換、文字列変換法の代入| 6.11 6.16.9 20.5 | Icarus Verilog 13.0 ||
| [`test_simple_bit_vector_types_and_packed_equivalents`](../../tests/ch6/test_simple_bit_vector_types_and_packed_equivalents.sv) |予め定義された幅のあるintegerのタイプは 一次元のpacked bitのベクトルで \[ n-1 : 0 \]ですpacked つの構造、packed つのユニオン、多次元packed つの配列は、同じ幅、状態、符号の単純なbit つのベクトル型に等価であるが、それらはその型のref引数に渡され、それから変換される。| 6.11.1 6.22.2 7.4.1 20.7 13.5.2 |標準のみ| x/z |
| [`test_ieee_compliance_dimensions_twostate`](../../tests/ch6/test_ieee_compliance_dimensions_twostate.sv) |$dimensions 2 状態変換のコンプライアンステスト| 6.11.2 7.4.1 8 20.7 | Icarus Verilog 13.0 | x/z |
| [`test_logic_reg_same_type`](../../tests/ch6/test_logic_reg_same_type.sv) |regとlogicは同じデータタイプを表し，同じ署名と範囲を持つregとlogicの宣言のタイプ参照は等しいが，bitと異なる署名は等しくない。| 6.11.2 6.23 6.22.1 | Verilator 5.052 ||
| [`test_longint_edge_cases`](../../tests/ch6/test_longint_edge_cases.sv) |長辺の場合| 6.11.2 | Icarus Verilog 13.0 ||
| [`test_integer_atom_defaults_and_widths`](../../tests/ch6/test_integer_atom_defaults_and_widths.sv) |整数原子型は固定幅と符号付きデフォルト算術を持つ| 6.11.3 6.11 6.8 | Icarus Verilog 13.0 | x/z |
| [`test_integer_unsigned_keyword`](../../tests/ch6/test_integer_unsigned_keyword.sv) |unsigned と宣言した integer は、すべてのビットが 1 の値を 4294967295 として保持し、integer と違って符号なしの値として比較・シフトされる| 6.11.3 11.4.4 11.4.10 | Verilator 5.052 ||
| [`test_illegal_real_bit_select`](../../tests/ch6/test_illegal_real_bit_select.sv) |実変数の bit -select は許可されていません| 6.12 11.5.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_real_edge_event`](../../tests/ch6/test_illegal_real_edge_event.sv) |実変数のエッジイベント制御は許可されていません| 6.12 9.4.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_real_index_bit_select`](../../tests/ch6/test_illegal_real_index_bit_select.sv) |ベクトルのbit選択に実数添字は使えない| 6.12 11.5.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_real_index_part_select`](../../tests/ch6/test_illegal_real_index_part_select.sv) |ベクトルの部分選択に実数添字は使えない| 6.12 11.5.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_real_operand_bitwise_and`](../../tests/ch6/test_illegal_real_operand_bitwise_and.sv) |二進ビット演算子には実ピラミッドは存在しません| 6.12 11.3.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_real_operand_modulus`](../../tests/ch6/test_illegal_real_operand_modulus.sv) |加法演算子は実オペランドを持たない| 6.12 11.3.1 |標準のみ|違法なデザインだ|
| [`test_illegal_real_operand_shift`](../../tests/ch6/test_illegal_real_operand_shift.sv) |シフト演算子には実ピラミッドはありません| 6.12 11.3.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_real_edge_cases`](../../tests/ch6/test_real_edge_cases.sv) |real、shortreal、realtimeの算術、キャスト、および比較| 6.12 6.12.1 | Icarus Verilog 13.0 ||
| [`test_real_ieee754_double_and_realtime`](../../tests/ch6/test_real_ieee754_double_and_realtime.sv) |real値は、Cのdoubleと同じIEEE 754の倍精度形式を持ち、bitではbitとなる。また、realtimeはrealと同じ型である| 6.12 6.13 20.5 6.23 35.5.6 | Verilator 5.052 | DPI |
| [`test_real_ops`](../../tests/ch6/test_real_ops.sv) |実数演算のテスト| 6.12 6.12.1 | Icarus Verilog 13.0 ||
| [`test_real_ops_edge_cases`](../../tests/ch6/test_real_ops_edge_cases.sv) |実数の算術 比較と変換 $rtoiと $itor| 6.12 20.5 | Icarus Verilog 13.0 ||
| [`test_real_type`](../../tests/ch6/test_real_type.sv) |real/shortreal タイプをテスト| 6.12 | Icarus Verilog 13.0 ||
| [`test_real_type_edge_cases`](../../tests/ch6/test_real_type_edge_cases.sv) |realの算術演算・比較・キャスト| 6.12 | Icarus Verilog 13.0 ||
| [`test_real_types`](../../tests/ch6/test_real_types.sv) |章 6：データタイプ| 6.12 6.12.1 | Icarus Verilog 13.0 ||
| [`test_reals_edge_cases`](../../tests/ch6/test_reals_edge_cases.sv) |実数演算、およびrealとintの間のキャスト| 6.12 6.12.1 | Icarus Verilog 13.0 ||
| [`test_realtime_ops`](../../tests/ch6/test_realtime_ops.sv) |リアルタイム操作テスト| 6.12 6.12.1 11.4.3 | Icarus Verilog 13.0 ||
| [`test_realtime_ops_2`](../../tests/ch6/test_realtime_ops_2.sv) |リアルタイム変数演算| 6.12 | Icarus Verilog 13.0 ||
| [`test_shortreal_single_precision`](../../tests/ch6/test_shortreal_single_precision.sv) |shortreal は、非ブロック代入、配列要素、キャストによって書かれたときにも、単一精度の値を保持します。| 6.12 6.24.1 20.5 |標準のみ||
| [`test_implicit_conversion`](../../tests/ch6/test_implicit_conversion.sv) |自動型昇格と変換をテスト| 6.12.1 6.24.1 11.8.1 10.7 | Verilator 5.052 ||
| [`test_real_arithmetic`](../../tests/ch6/test_real_arithmetic.sv) |実数演算、およびrealからintへの丸め変換| 6.12.1 6.24.1 11.4.3 | Icarus Verilog 13.0 ||
| [`test_real_conversion_wide_and_unknown`](../../tests/ch6/test_real_conversion_wide_and_unknown.sv) |64ビットより広いベクトル、負の符号ベクトル、xとzビットを持つベクトルの実数への変換| 6.12.1 | Icarus Verilog 13.0 | x/z |
| [`test_type_casts`](../../tests/ch6/test_type_casts.sv) |タイプキャスト| 6.12.1 6.24.1 | Icarus Verilog 13.0 ||
| [`test_shortreal_ieee754_single`](../../tests/ch6/test_shortreal_ieee754_single.sv) |値は shortreal 単一形式で IEEE 単一形 式で 754 単一形態で $shortrealtobits 単一精度のビットを返します。より精度の高い値は最も近い単一に丸めます。| 6.13 6.12 20.5 |標準のみ||
| [`test_void_function_and_cast`](../../tests/ch6/test_void_function_and_cast.sv) |void の返しタイプを持つ関数は値を返さず、ステートメントとして呼び出され、函数コールを void にキャストすると、その結果を捨てる。| 6.13 13.4.1 6.24.1 | Icarus Verilog 13.0 ||
| [`test_void_return_and_discard_side_effect`](../../tests/ch6/test_void_return_and_discard_side_effect.sv) |ヴォイド関数は早期に返り，ヴォイドキャストは副作用を排除せずに値を排除する| 6.13 | Icarus Verilog 13.0 ||
| [`test_void_return_and_tagged_union_void_member`](../../tests/ch6/test_void_return_and_tagged_union_void_member.sv) |void関数はデータを返しません タグ付けされたユニオン voidメンバーは タグのみを持ちます| 6.13 7.3.2 11.9 |標準のみ||
| [`test_chandle_edge_cases`](../../tests/ch6/test_chandle_edge_cases.sv) |テスト: チャンドルエッジケース| 6.14 | Verilator 5.052 ||
| [`test_chandle_null_boolean_and_uses`](../../tests/ch6/test_chandle_null_boolean_and_uses.sv) |チャンドルは null で始まり、C はそれをゼロポインタとして見る。0 1 は null のときのブーリアンであり、それ以外のときは===と!==は同じ結果を返します。as ==と!=;chandleは、クラスのプロパティや連想配列の添字に使用できる| 6.14 7.8 35.5.6 | Verilator 5.052 | DPI |
| [`test_chandle_ops`](../../tests/ch6/test_chandle_ops.sv) |チャンドルのヌルチェックと演算をテスト| 6.14 | Verilator 5.052 ||
| [`test_illegal_chandle_assigned_from_int`](../../tests/ch6/test_illegal_chandle_assigned_from_int.sv) |チャンドルに割り当てられるものは 別のチャンドルか null だけですintの値は代入できません。| 6.14 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_assigned_to_int`](../../tests/ch6/test_illegal_chandle_assigned_to_int.sv) |チャンドルは int のような他の変数に割り当てることはできません| 6.14 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_case_equality_with_int`](../../tests/ch6/test_illegal_chandle_case_equality_with_int.sv) |チャンドル上のケース同値 operator === は、他のチャンドルまたは null とのみ有効で、int とは無効です。| 6.14 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_case_inequality_with_int`](../../tests/ch6/test_illegal_chandle_case_inequality_with_int.sv) |チャンドル上のケース不等式演算子!== は、他のチャンドルや null とのみ有効で、int とは無効です。| 6.14 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_continuous_assignment`](../../tests/ch6/test_illegal_chandle_continuous_assignment.sv) |チャンドルは連続的な任務では使えません| 6.14 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_equality_with_int`](../../tests/ch6/test_illegal_chandle_equality_with_int.sv) |チャンドル上の等式 operator == は他のチャンドルまたは null とのみ有効であり、 int とは有効ではありません。| 6.14 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_event_control`](../../tests/ch6/test_illegal_chandle_event_control.sv) |チャンドルはイベント表現に使えません| 6.14 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_in_packed_struct`](../../tests/ch6/test_illegal_chandle_in_packed_struct.sv) |チャンドルは packed 型の構造物のメンバーのような packed 型の構築物では使えません| 6.14 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_chandle_in_untagged_union`](../../tests/ch6/test_illegal_chandle_in_untagged_union.sv) |チャンドルはタグ付けされていない組合のメンバーではありません| 6.14 7.3 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_inequality_with_int`](../../tests/ch6/test_illegal_chandle_inequality_with_int.sv) |チャンドル上の不等式演算子!= は、他のチャンドルや null とのみ有効で、int とは無効です。| 6.14 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_port`](../../tests/ch6/test_illegal_chandle_port.sv) |ポートはチャンドルデータタイプを持つことができません| 6.14 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_relational_operator`](../../tests/ch6/test_illegal_chandle_relational_operator.sv) |than == &lt;!=, ===,!==以外の演算子のオペランドにはチャンドルは使えません。| 6.14 |標準のみ|違法なデザインだ|
| [`test_comb_string_compare`](../../tests/ch6/test_comb_string_compare.sv) |テスト: 文字列比較演算子とメソッド| 6.16 | Verilator 5.052 ||
| [`test_edge_assoc_array_keys`](../../tests/ch6/test_edge_assoc_array_keys.sv) |関連配列に "\0" を含む文字列キー: "\0" は文字列リテラルから削除されます| 6.16 7.8.2 | Verilator 5.052 ||
| [`test_edge_case_strings`](../../tests/ch6/test_edge_case_strings.sv) |文字列演算のコーナーケーステスト| 6.16 | Verilator 5.052 ||
| [`test_expr_string`](../../tests/ch6/test_expr_string.sv) |文字列表現テスト| 6.16 11.4.12 | Verilator 5.052 ||
| [`test_illegal_string_assigned_int_without_cast`](../../tests/ch6/test_illegal_string_assigned_int_without_cast.sv) |整数値は 文字列変数に割り当てられるのは| 6.16 |標準のみ|違法なデザインだ|
| [`test_illegal_string_replication_empty_braces`](../../tests/ch6/test_illegal_string_replication_empty_braces.sv) |文字列の複製には 少なくとも1つのオペランドが必要です| 6.16 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_string_replication_negative_multiplier`](../../tests/ch6/test_illegal_string_replication_negative_multiplier.sv) |文字列複製の反復数は負にできません。| 6.16 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_string_replication_real_multiplier`](../../tests/ch6/test_illegal_string_replication_real_multiplier.sv) |文字列の複製の乗数は整数型でなければなりません実際の表現は違法です| 6.16 |標準のみ|違法なデザインだ|
| [`test_illegal_string_replication_x_multiplier`](../../tests/ch6/test_illegal_string_replication_x_multiplier.sv) |文字列の複製の乗数は xbit を含めない| 6.16 | Verilator 5.052 |違法なデザイン x/z|
| [`test_illegal_string_replication_z_multiplier`](../../tests/ch6/test_illegal_string_replication_z_multiplier.sv) |文字列の複製の乗数には zbit は含まれません| 6.16 | Verilator 5.052 |違法なデザイン x/z|
| [`test_string_basic`](../../tests/ch6/test_string_basic.sv) |文字列の基本テスト| 6.16 | Icarus Verilog 13.0 ||
| [`test_string_cmp`](../../tests/ch6/test_string_cmp.sv) |文字列比較テスト| 6.16 | Icarus Verilog 13.0 ||
| [`test_string_compare`](../../tests/ch6/test_string_compare.sv) |文字列比較演算子: ==,!=, &lt;, \>, &lt; =, \>=| 6.16 | Icarus Verilog 13.0 ||
| [`test_string_comparison_operators_and_literals`](../../tests/ch6/test_string_comparison_operators_and_literals.sv) |文字列の等価演算子と関係演算子は、compareの辞書順で条件が成立する場合に限り1を返す。文字列と比較するリテラルは、まず文字列へ変換され、2つのリテラル同士は整数型の値として比較される。| 6.16 6.16.8 11.4.5 11.4.4 | Verilator 5.052 ||
| [`test_string_concat_replication_typing`](../../tests/ch6/test_string_concat_replication_typing.sv) |文字列リテラルのみの連結または定数複製は、必要な場合のみ文字列に変換される整数値である。文字列オペランドまたは非定数乗法は、結果を文字列にする。零乗法は空の文字列を返します。| 6.16 11.4.12 11.4.12.2 5.9 | Verilator 5.052 ||
| [`test_string_corner`](../../tests/ch6/test_string_corner.sv) |文字列のメソッド、比較、特殊文字をテストします| 6.16 6.16.9 | Verilator 5.052 ||
| [`test_string_edge`](../../tests/ch6/test_string_edge.sv) |ストリングエッジ事例| 6.16 6.16.9 6.16.10 6.16.11 6.16.12 |標準のみ||
| [`test_string_edge_cases`](../../tests/ch6/test_string_edge_cases.sv) |ストリングエッジケーステスト| 6.16 | Verilator 5.052 ||
| [`test_string_edge_cases_2`](../../tests/ch6/test_string_edge_cases_2.sv) |テスト: ストリングエッジケース| 6.16 | Verilator 5.052 ||
| [`test_string_functions_comprehensive`](../../tests/ch6/test_string_functions_comprehensive.sv) |ストリングシステム関数総合テスト| 6.16 |標準のみ||
| [`test_string_ignores_null_characters`](../../tests/ch6/test_string_ignores_null_characters.sv) |文字列変数は文字列リテラルの null 文字を削除し、その文字列に書かれた null 文字は無視します。| 6.16 | Icarus Verilog 13.0 ||
| [`test_string_index_read_bounds`](../../tests/ch6/test_string_index_read_bounds.sv) |文字列のインデックスは文字コードを byte として読みます。index 0 は最左端の文字で、len() -1 は最右端の文字です。結果は getc に等しい。0 の下、長さの上、あるいは空の文字列にインデックスを入れると、0 となります。| 6.16 6.16.3 | Verilator 5.052 ||
| [`test_string_len`](../../tests/ch6/test_string_len.sv) |文字列長さテスト| 6.16 | Icarus Verilog 13.0 ||
| [`test_string_literal_and_integral_conversions`](../../tests/ch6/test_string_literal_and_integral_conversions.sv) |文字列はリテラル、空文字列、文字列表現で宣言できます。文字列に変換すると、NUL 文字を全て削除し、他に何も残っていないときは空の文字列を返します。部分的な byte を左側のゼロで埋め、文字列のサイズを変更します。| 6.16 6.24.1 | Icarus Verilog 13.0 ||
| [`test_string_methods`](../../tests/ch6/test_string_methods.sv) |文字列メソッド| 6.16 6.16.1 6.16.3 6.16.8 | Verilator 5.052 ||
| [`test_string_methods_2`](../../tests/ch6/test_string_methods_2.sv) |6.16 の文字列メソッド (§)| 6.16 | Verilator 5.052 ||
| [`test_string_methods_3`](../../tests/ch6/test_string_methods_3.sv) |文字列メソッド len, getc, putc, atoi, atohex| 6.16 | Verilator 5.052 ||
| [`test_string_methods_4`](../../tests/ch6/test_string_methods_4.sv) |テスト文字列メソッド: len, substr, getc, putc, toupper, tolower| 6.16 | Verilator 5.052 ||
| [`test_string_methods_corner`](../../tests/ch6/test_string_methods_corner.sv) |テスト文字列内蔵メソッド: len, putc, getc, toupper, tolower, compare, substr など| 6.16 | Verilator 5.052 ||
| [`test_string_methods_edge_cases`](../../tests/ch6/test_string_methods_edge_cases.sv) |テスト: ストリングメソッドエッジケース| 6.16 5.9 | Verilator 5.052 ||
| [`test_string_operations`](../../tests/ch6/test_string_operations.sv) |文字列演算拡張テスト| 6.16 | Verilator 5.052 ||
| [`test_string_ops`](../../tests/ch6/test_string_ops.sv) |文字列演算のテスト| 6.16 11.4.12 | Verilator 5.052 ||
| [`test_string_ops_2`](../../tests/ch6/test_string_ops_2.sv) |文字列の連結、連結、タッパー、トローワー、サブストラクト| 6.16 | Verilator 5.052 ||
| [`test_string_ops_3`](../../tests/ch6/test_string_ops_3.sv) |ストリング演算のエッジケース| 6.16 5.9 | Verilator 5.052 ||
| [`test_string_ops_edge_cases`](../../tests/ch6/test_string_ops_edge_cases.sv) |文字列演算のエッジケース| 6.16 |標準のみ||
| [`test_sv_string`](../../tests/ch6/test_sv_string.sv) |テスト: 文字列: len(), substr(), {concat}, toupper/tolower, atoi, comparison| 6.16 | Verilator 5.052 ||
| [`test_value_string`](../../tests/ch6/test_value_string.sv) |文字列値演算のテスト| 6.16 | Verilator 5.052 ||
| [`test_string_atoreal`](../../tests/ch6/test_string_atoreal.sv) |テスト：ストリングアトリアル法| 6.16.1 6.16.9 | Icarus Verilog 13.0 ||
| [`test_string_bintoa`](../../tests/ch6/test_string_bintoa.sv) |テスト: 文字列ビントア法| 6.16.1 6.16.10 | Icarus Verilog 13.0 ||
| [`test_string_itoa`](../../tests/ch6/test_string_itoa.sv) |テスト: 文字列 itoa 法| 6.16.1 6.16.10 | Icarus Verilog 13.0 ||
| [`test_string_len_2`](../../tests/ch6/test_string_len_2.sv) |文字列レンメソッド| 6.16.1 | Icarus Verilog 13.0 ||
| [`test_string_len_case_compare_types`](../../tests/ch6/test_string_len_case_compare_types.sv) |len()はintを返します。toupper()・tolower()は新しい文字列を返し、元の文字列は変更しません。compare()・icompare()は文字列を受け取り、intを返します。| 6.16.1 6.16.4 6.16.5 6.16.6 6.16.7 20.6.1 | Verilator 5.052 ||
| [`test_string_octtoa`](../../tests/ch6/test_string_octtoa.sv) |テスト: 文字列オクタメソッド| 6.16.1 6.16.10 | Icarus Verilog 13.0 ||
| [`test_string_substr`](../../tests/ch6/test_string_substr.sv) |テスト: 文字列の下位メソッド| 6.16.1 6.16.8 | Icarus Verilog 13.0 ||
| [`test_string_putc`](../../tests/ch6/test_string_putc.sv) |テスト文字列 putc| 6.16.2 | Verilator 5.052 ||
| [`test_string_putc_2`](../../tests/ch6/test_string_putc_2.sv) |テスト: 文字列プット法| 6.16.2 | Verilator 5.052 ||
| [`test_string_putc_getc`](../../tests/ch6/test_string_putc_getc.sv) |文字列データタイプ| 6.16.2 6.16.3 | Verilator 5.052 ||
| [`test_string_putc_index_rules`](../../tests/ch6/test_string_putc_index_rules.sv) |putc(i, c) は str \[ i \] = c のように動作し、len() -1 に対して 0 の外のインデックスとゼロ文字を無視し、長さを変更しない。引数を int と byte に変換します。| 6.16.2 6.16 | Verilator 5.052 ||
| [`test_string_getc`](../../tests/ch6/test_string_getc.sv) |テスト: 文字列 getc メソッド| 6.16.3 | Verilator 5.052 ||
| [`test_string_getc_2`](../../tests/ch6/test_string_getc_2.sv) |テスト文字列 getc| 6.16.3 | Verilator 5.052 ||
| [`test_string_getc_index_rules`](../../tests/ch6/test_string_getc_index_rules.sv) |getc(i) は int のインデックスを取って str \[ i \] に等しい byte を返します。 0 より下のインデックスや len() より下でない場合は 0 を返します| 6.16.3 6.16 20.6.1 |標準のみ||
| [`test_string_getc_is_byte`](../../tests/ch6/test_string_getc_is_byte.sv) |str.getc(i) は byte を返します。 つまり 2 つのコールの連結は 16 ビット幅です。| 6.16.3 11.4.12 |標準のみ||
| [`test_string_manipulation`](../../tests/ch6/test_string_manipulation.sv) |文字列データタイプ| 6.16.4 6.16.5 6.16.6 6.16.7 6.16.8 | Verilator 5.052 ||
| [`test_string_toupper`](../../tests/ch6/test_string_toupper.sv) |テスト:ストリングツーパー法| 6.16.4 | Verilator 5.052 ||
| [`test_string_toupper_2`](../../tests/ch6/test_string_toupper_2.sv) |テストストリングツーパー| 6.16.4 | Verilator 5.052 ||
| [`test_string_tolower`](../../tests/ch6/test_string_tolower.sv) |テスト: 文字列追加法| 6.16.5 | Verilator 5.052 ||
| [`test_string_tolower_2`](../../tests/ch6/test_string_tolower_2.sv) |テスト文字列トローア| 6.16.5 | Verilator 5.052 ||
| [`test_string_compare_2`](../../tests/ch6/test_string_compare_2.sv) |テスト: 文字列比較法| 6.16.6 | Verilator 5.052 ||
| [`test_string_icompare`](../../tests/ch6/test_string_icompare.sv) |テスト: 文字列 icompare 法 (大文字と小文字を区別しない比較)| 6.16.7 | Verilator 5.052 ||
| [`test_string_methods_extended`](../../tests/ch6/test_string_methods_extended.sv) |拡張ストリングメソッドテスト| 6.16.8 6.16.3 6.16.2 6.16.6 | Verilator 5.052 ||
| [`test_string_substr_2`](../../tests/ch6/test_string_substr_2.sv) |テスト文字列サブストリート| 6.16.8 | Icarus Verilog 13.0 ||
| [`test_string_substr_out_of_range`](../../tests/ch6/test_string_substr_out_of_range.sv) |substr は文字列の中に入っていない範囲の文字列を返します| 6.16.8 | Icarus Verilog 13.0 ||
| [`test_string_substr_types_negative_start`](../../tests/ch6/test_string_substr_types_negative_start.sv) |substr(i, j) は 2 つの int 指標を取って 文字列を返します i が負のときは空文字列を返し| 6.16.8 20.6.1 | Verilator 5.052 ||
| [`test_string_ato_integer_scan_rules`](../../tests/ch6/test_string_ato_integer_scan_rules.sv) |atoi(), atohex(), atooct(), atobin() は先頭の数字と下線をスキャンし、他の文字で停止し、数字なしで 0 を返します。プラス、サイズ、アポストロフ、ベースは解析しません。先頭のマイナスは読み取られる場合と読み取られない場合があり、先頭のアンダースコアも走査される場合とされない場合があります。| 6.16.9 |標準のみ||
| [`test_string_ato_method_result_types`](../../tests/ch6/test_string_ato_method_result_types.sv) |atoi() は引数を取らずに符号 32 - bit integer を返します。| 6.16.9 6.16.10 20.6.1 | Verilator 5.052 ||
| [`test_string_atobin`](../../tests/ch6/test_string_atobin.sv) |検査：ストリングアトビン法| 6.16.9 | Verilator 5.052 ||
| [`test_string_atobin_2`](../../tests/ch6/test_string_atobin_2.sv) |テスト文字列アトビン法| 6.16.9 | Verilator 5.052 ||
| [`test_string_atohex`](../../tests/ch6/test_string_atohex.sv) |テスト: 文字列 atohex 法| 6.16.9 | Icarus Verilog 13.0 ||
| [`test_string_atohex_2`](../../tests/ch6/test_string_atohex_2.sv) |テスト文字列 atohex メソッド| 6.16.9 | Icarus Verilog 13.0 ||
| [`test_string_atoi`](../../tests/ch6/test_string_atoi.sv) |テスト文字列 atoi メソッド| 6.16.9 | Icarus Verilog 13.0 ||
| [`test_string_atoi_2`](../../tests/ch6/test_string_atoi_2.sv) |テスト: 文字列アトイ法| 6.16.9 | Icarus Verilog 13.0 ||
| [`test_string_atooct`](../../tests/ch6/test_string_atooct.sv) |テスト: 文字列のアトオクトメソッド| 6.16.9 | Verilator 5.052 ||
| [`test_string_atooct_2`](../../tests/ch6/test_string_atooct_2.sv) |テスト文字列| 6.16.9 | Verilator 5.052 ||
| [`test_string_conversion`](../../tests/ch6/test_string_conversion.sv) |文字列データタイプ| 6.16.9 6.16.10 6.16.11 6.16.12 6.16.13 6.16.14 6.16.15 |標準のみ||
| [`test_string_atoreal_2`](../../tests/ch6/test_string_atoreal_2.sv) |テストストリングアトリアル法| 6.16.10 | Icarus Verilog 13.0 ||
| [`test_string_atoreal_scan_rules`](../../tests/ch6/test_string_atoreal_scan_rules.sv) |atoreal() は最長の実数定数を解析し、構文に合わない最初の文字または最後の文字で停止し、数字がない場合は 0 を返します。| 6.16.10 5.7.2 |標準のみ||
| [`test_string_itoa_2`](../../tests/ch6/test_string_itoa_2.sv) |テスト文字列 itoa メソッド| 6.16.11 | Icarus Verilog 13.0 ||
| [`test_string_hextoa`](../../tests/ch6/test_string_hextoa.sv) |テスト: 文字列 hextoa 法| 6.16.12 | Verilator 5.052 ||
| [`test_string_binary_octal_round_trip`](../../tests/ch6/test_string_binary_octal_round_trip.sv) |integerは2進および8進変換法により，既存の文字列およびラウンドトリップゼロに置き換えられた。| 6.16.13 6.16.14 | Verilator 5.052 ||
| [`test_string_octtoa_bintoa_negative_round_trip`](../../tests/ch6/test_string_octtoa_bintoa_negative_round_trip.sv) |次の例では、octoa() と bintoa() は負の整数を受け入れ、受け取る値を置き換えます。atooct() と atobin() は結果を同じ負の値として返します。| 6.16.13 6.16.14 6.16.9 | Verilator 5.052 ||
| [`test_string_realtoa`](../../tests/ch6/test_string_realtoa.sv) |テスト: 文字列実行メソッド| 6.16.15 6.16.10 | Icarus Verilog 13.0 ||
| [`test_event_rebinding_retains_old_wait`](../../tests/ch6/test_event_rebinding_retains_old_wait.sv) |イベント変数を再バインドすると、既にブロックされているプロセスを旧同期オブジェクトに再ターゲットしません。| 6.17 15.5.5.1 |標準のみ||
| [`test_event_triggered_state_lasts_time_step`](../../tests/ch6/test_event_triggered_state_lasts_time_step.sv) |トリガー状態は 時間ステップの残りの期間 真であり続けます 次の時間ステップでは 偽になります| 6.17 15.5.3 | Verilator 5.052 ||
| [`test_event_variable_alias_null`](../../tests/ch6/test_event_variable_alias_null.sv) |初期化子なしで宣言されたイベント変数は新しい同期オブジェクトを得ます。他のイベントから割り当てられたものはそのオブジェクトを共有します。割り当てられ た null はオブジェクトを持たない。| 6.17 15.5.5 15.5.1 |標準のみ||
| [`test_ch6_extra_unpacked_type_parameter`](../../tests/ch6/test_ch6_extra_unpacked_type_parameter.sv) |タイプパラメータとして使用される unpacked 配列タイプは、ユーザ定義のタイプ識別子で名付けられる必要があります。| 6.18 6.20.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_data_type_scoped_and_reference_forms`](../../tests/ch6/test_data_type_scoped_and_reference_forms.sv) |packed次元を伴いpackage/classスコープで指定するデータ型、クラス型と入れ子のクラス型、クラススコープの未完成型、パラメータ値指定を伴うクラススコープ、データ型およびキャスト型としての型参照、および単純型・定数一次式・符号指定・string・constをキャスト型とするキャスト| 6.18 6.23 6.24.1 A.2.2.1 |標準のみ||
| [`test_forward_typedef_forms_and_repeats`](../../tests/ch6/test_forward_typedef_forms_and_repeats.sv) |前進型定義は enum 、struct、union、class、interface クラスの種類と無種類のものが最終定義の前に合法であり、繰り返し可能であり、それに続くものも可能です。| 6.18 8.26 8.27 | Verilator 5.052 ||
| [`test_illegal_cast_to_unnamed_packed_array_type`](../../tests/ch6/test_illegal_cast_to_unnamed_packed_array_type.sv) |次元が packed のタイプは、キャストのターゲットになるにはユーザ定義のタイプ名が必要です。| 6.18 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_forward_enum_defined_as_struct`](../../tests/ch6/test_illegal_forward_enum_defined_as_struct.sv) |前向きの typedef が基本型 enum を名付けた場合、最終定義は enum でなければなりません。構造はエラーであり| 6.18 |標準のみ|違法なデザインだ|
| [`test_illegal_forward_type_scope_prefix_in_variable`](../../tests/ch6/test_illegal_forward_type_scope_prefix_in_variable.sv) |未完成の前方宣言型を経由し::で選択した型を使えるのは、typedef、型演算子、型パラメータ代入だけであり、変数宣言には使えません。| 6.18 |標準のみ|違法なデザインだ|
| [`test_illegal_forward_type_scope_prefix_not_class`](../../tests/ch6/test_illegal_forward_type_scope_prefix_not_class.sv) |クラスの範囲解決演算子の プレフィックスとして使われる 前向きタイプは クラスに解決しなければなりません| 6.18 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_forward_typedef_defined_in_generate_block`](../../tests/ch6/test_illegal_forward_typedef_defined_in_generate_block.sv) |前方 typedef の実際のタイプは同じスコープで定義される必要があります。生成ブロックの定義はモジュールの前方 typedef を解決しません| 6.18 |標準のみ|違法なデザインだ|
| [`test_illegal_forward_typedef_never_defined`](../../tests/ch6/test_illegal_forward_typedef_never_defined.sv) |前方 typedef はデータ型として定義されておらず、エラーとなります| 6.18 |標準のみ|違法なデザインだ|
| [`test_illegal_hierarchical_type_reference`](../../tests/ch6/test_illegal_hierarchical_type_reference.sv) |階層的な名前で参照できないモジュールのタイプ識別子は、ポートを通じて到達するインターフェースのタイプは、ローカルに再定義できる。| 6.18 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_typedef_used_before_declaration`](../../tests/ch6/test_illegal_typedef_used_before_declaration.sv) |ユーザ定義型の宣言は それらの名前の参照の前に来なければなりません| 6.18 | Verilator 5.052 |違法なデザインだ|
| [`test_type_def`](../../tests/ch6/test_type_def.sv) |Typedef テスト| 6.18 20.6.2 | Verilator 5.052 ||
| [`test_typedef`](../../tests/ch6/test_typedef.sv) |これは、typedef のベクトル、enum と packed の構造を持つ| 6.18 | Icarus Verilog 13.0 ||
| [`test_typedef_advanced`](../../tests/ch6/test_typedef_advanced.sv) |進んだ Typedef テスト| 6.18 | Icarus Verilog 13.0 ||
| [`test_typedef_advanced_2`](../../tests/ch6/test_typedef_advanced_2.sv) |Typedef 高度なテスト| 6.18 | Verilator 5.052 ||
| [`test_typedef_basic`](../../tests/ch6/test_typedef_basic.sv) |Typedef テスト| 6.18 | Icarus Verilog 13.0 ||
| [`test_typedef_corner`](../../tests/ch6/test_typedef_corner.sv) |様々な typedef 宣言と forward typedefs をテストします| 6.18 7.2 7.10 | Icarus Verilog 13.0 ||
| [`test_typedef_declaration_forms`](../../tests/ch6/test_typedef_declaration_forms.sv) |固定，キュー，連想，動的unpacked次元のデータ型のtypedefの宣言，bitセレクト付きおよび無いインタフェースポートを通じて到達するタイプ，フォワードクラスおよびそのネストされたパラメータ化クラスを通して選択されるタイプ，enumのフォワードタイプデフ，構造，ユニオン，クラス，インタフェースクラス，最終定義前に名前を使用するキーワードなし| 6.18 8.23 8.27 A.2.1.3 A.2.2.1 | Verilator 5.052 ||
| [`test_typedef_edge_cases`](../../tests/ch6/test_typedef_edge_cases.sv) |ベクトル、int、およびpackedの構造体のtypedef。| 6.18 | Icarus Verilog 13.0 ||
| [`test_typedef_param`](../../tests/ch6/test_typedef_param.sv) |テスト: パラメータ化 typedef| 6.18 6.20.2 8.25 | Verilator 5.052 ||
| [`test_typedef_struct_enum`](../../tests/ch6/test_typedef_struct_enum.sv) |構造と enum を持つ Typedef| 6.18 6.19 7.2 | Verilator 5.052 ||
| [`test_typedef_types_edge_cases`](../../tests/ch6/test_typedef_types_edge_cases.sv) |ベクトルの typedef、配列の packed、符号のない int の組み合わせ| 6.18 | Icarus Verilog 13.0 ||
| [`test_cast_enum`](../../tests/ch6/test_cast_enum.sv) |テスト：列挙型へのキャスト| 6.19 6.19.5 6.24.1 | Icarus Verilog 13.0 ||
| [`test_enum_base_type_forms_and_int_default`](../../tests/ch6/test_enum_base_type_forms_and_int_default.sv) |基底型がない enum は int enum であり、基底型は integer 符号付き原子型、 integer 符号付きベクトル型、 packed 次元、または どちらかのタイプ名である。| 6.19 6.11 | Icarus Verilog 13.0 | x/z |
| [`test_enum_base_type_typedef_names`](../../tests/ch6/test_enum_base_type_typedef_names.sv) |数列のベース型は，packed次元を持たないinteger原子型を表す型名または，1つの次元を持つintegerベクトル型を表す型である。数え上げはそのタイプの幅と符号を持ち| 6.19 A.2.2.1 A.10 | Icarus Verilog 13.0 ||
| [`test_enum_basic`](../../tests/ch6/test_enum_basic.sv) |基本テスト| 6.19 | Icarus Verilog 13.0 ||
| [`test_enum_basic_edge_cases`](../../tests/ch6/test_enum_basic_edge_cases.sv) |エンナム基本エッジケース| 6.19 | Icarus Verilog 13.0 ||
| [`test_enum_casts_and_values`](../../tests/ch6/test_enum_casts_and_values.sv) |数字の数値| 6.19 6.19.4 | Icarus Verilog 13.0 ||
| [`test_enum_declaration_syntax_forms`](../../tests/ch6/test_enum_declaration_syntax_forms.sv) |enum packed の宣言は、オプションのベースタイプ、1つ以上のコンマで区切られた名前、それぞれのオプションの範囲と値、および括弧の後のオプションの次元を持っています。| 6.19 6.19.2 7.4.1 | Verilator 5.052 ||
| [`test_enum_edge_cases`](../../tests/ch6/test_enum_edge_cases.sv) |テスト：エヌムエッジケース| 6.19 | Icarus Verilog 13.0 ||
| [`test_enum_encoding_cast_to_base`](../../tests/ch6/test_enum_encoding_cast_to_base.sv) |enum の名前の値表現はベースタイプにキャストしたように評価されます。 つまり、ベースの幅と符号を取得し、次の名前はキャスト値を増加させます。| 6.19 6.24.1 11.6.1 | Verilator 5.052 ||
| [`test_enum_four_state_base_x_z_values`](../../tests/ch6/test_enum_four_state_base_x_z_values.sv) |明示的な 4 状態ベースタイプを持つ enum は x と z ビットを持つ名前値を与えます。| 6.19 6.19.5.6 | Icarus Verilog 13.0 | x/z |
| [`test_enum_methods_typed`](../../tests/ch6/test_enum_methods_typed.sv) |数列型| 6.19 6.19.5 | Icarus Verilog 13.0 ||
| [`test_enum_named_constants`](../../tests/ch6/test_enum_named_constants.sv) |enum は、定数表現やケースアイテムに使える、宣言されたエンコーディングを持つ整数名付け定数を定義します。| 6.19 | Icarus Verilog 13.0 ||
| [`test_enum_operations`](../../tests/ch6/test_enum_operations.sv) |Enum 操作テスト| 6.19 6.19.4 | Icarus Verilog 13.0 ||
| [`test_enum_ops`](../../tests/ch6/test_enum_ops.sv) |enum 操作のテスト| 6.19 6.19.5 | Icarus Verilog 13.0 ||
| [`test_enum_ops_edge_cases`](../../tests/ch6/test_enum_ops_edge_cases.sv) |テスト：エナム演算のエッジケース| 6.19 | Icarus Verilog 13.0 ||
| [`test_enum_signed`](../../tests/ch6/test_enum_signed.sv) |符号付き enum 値と first, last, num, next, prev メソッド| 6.19 6.19.5 | Icarus Verilog 13.0 ||
| [`test_enum_type`](../../tests/ch6/test_enum_type.sv) |テスト enum タイプ| 6.19 6.19.4 | Icarus Verilog 13.0 ||
| [`test_enum_types_edge_cases`](../../tests/ch6/test_enum_types_edge_cases.sv) |テスト：エヌム型エッジケース| 6.19 | Icarus Verilog 13.0 ||
| [`test_enum_values_methods`](../../tests/ch6/test_enum_values_methods.sv) |数値とenumメソッド| 6.19 | Icarus Verilog 13.0 ||
| [`test_enums_edge_cases`](../../tests/ch6/test_enums_edge_cases.sv) |テスト:エナムスエッジケース| 6.19 | Icarus Verilog 13.0 ||
| [`test_illegal_enum_base_atom_typedef_dimension`](../../tests/ch6/test_illegal_enum_base_atom_typedef_dimension.sv) |integer 原子型の型名は enum 基底型として使われ、packed 次元を取ることはできません。| 6.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_base_packed_struct_typedef`](../../tests/ch6/test_illegal_enum_base_packed_struct_typedef.sv) |型名はenumベース型として使用される場合はinteger原子型またはintegerベクトル型を表す必要があります。packed構造ではありません。| 6.19 7.2.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_duplicate_value`](../../tests/ch6/test_illegal_enum_duplicate_value.sv) |二つのエナミネーション名は同じ値を持つことはできません。一つの値が自動増分から来ている場合でも同じ値を持ちません。| 6.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_implicit_after_x_value`](../../tests/ch6/test_illegal_enum_implicit_after_x_value.sv) |値のない enum 名前は、値が xbit の名前の後に続けることはできません。| 6.19 | Icarus Verilog 13.0 |違法なデザイン x/z|
| [`test_illegal_enum_increment_overflow`](../../tests/ch6/test_illegal_enum_increment_overflow.sv) |列挙のベースタイプの最大値を超える自動増分はエラーです| 6.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_repeated_name`](../../tests/ch6/test_illegal_enum_repeated_name.sv) |同じ名前を二度リストするエナミーは、異なる値であってもエラーです| 6.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_same_name_two_enums`](../../tests/ch6/test_illegal_enum_same_name_two_enums.sv) |2 つのエナミネーションは同じスコープ内で LOW の名前を持つことはできません。 enum の名前はオーバーロードされません。| 6.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_signed_value_out_of_range`](../../tests/ch6/test_illegal_enum_signed_value_out_of_range.sv) |符号 4 - bit enum 基底の場合、カットオフビットが結果の符号 bit に等しくないので、値 8 は範囲外です。| 6.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_sized_literal_width`](../../tests/ch6/test_illegal_enum_sized_literal_width.sv) |値 enum を設定するサイズリテラルはベースタイプの幅を持たなければなりません。| 6.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_value_const_variable`](../../tests/ch6/test_illegal_enum_value_const_variable.sv) |enum 名前の値はコンスト変数を使用できません| 6.19 6.20.6 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_value_from_variable`](../../tests/ch6/test_illegal_enum_value_from_variable.sv) |enum 名前の値がモジュール変数を読み込むときは、それは詳細化時間定数ではなく、エラーである。| 6.19 6.20 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_value_hierarchical_name`](../../tests/ch6/test_illegal_enum_value_hierarchical_name.sv) |enum 名前の値は階層的な名前を使えません。パラメータの名前もです。| 6.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_value_out_of_range`](../../tests/ch6/test_illegal_enum_value_out_of_range.sv) |値 enum はベースタイプの範囲外にありえません。| 6.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_x_value_default_int_base`](../../tests/ch6/test_illegal_enum_x_value_default_int_base.sv) |基底型がないenumは、基底が2-stateintであるため、xビットの値を名前に与えることはできません。| 6.19 | Icarus Verilog 13.0 |違法なデザイン x/z|
| [`test_illegal_enum_z_value_bit_base`](../../tests/ch6/test_illegal_enum_z_value_bit_base.sv) |明示的な 2 状態ベースタイプを持つ enum は、z ビットの値を名前に与えることはできません。| 6.19 | Icarus Verilog 13.0 |違法なデザイン x/z|
| [`test_enum_descending_names_and_wrap`](../../tests/ch6/test_enum_descending_names_and_wrap.sv) |降順 enum 名前範囲は最初の最後の数字と前の数字の宣言順序を保持します。| 6.19.1 6.19.2 6.19.5.1 6.19.5.2 6.19.5.4 6.19.5.5 6.19.5.7 | Icarus Verilog 13.0 ||
| [`test_enum_reuse_next_prev_encoding`](../../tests/ch6/test_enum_reuse_next_prev_encoding.sv) |enum タイプは再利用可能で、次のステップと前のステップは宣言順序に従い、範囲外の値はデフォルト値を返します。| 6.19.1 6.19.5.3 6.19.5.4 6.19 | Icarus Verilog 13.0 ||
| [`test_enum_name_count_with_first_value`](../../tests/ch6/test_enum_name_count_with_first_value.sv) |name \[ N \] = C は最初に生成された名前に値 C を与え、次の生成された名前には次の値を与えます| 6.19.2 6.19.5 | Icarus Verilog 13.0 ||
| [`test_enum_named_ranges`](../../tests/ch6/test_enum_named_ranges.sv) |数え上げでは，名前\[N\]は0から数えたN名前，名前\[N：M\]はNからMまでの数え上げで，それぞれの数え上げは，指定された定数から始まり，それが存在する場合は，それぞれの値を連続的に取る。| 6.19.2 6.19.1 6.19.5 | Icarus Verilog 13.0 ||
| [`test_illegal_enum_name_range_negative_first`](../../tests/ch6/test_illegal_enum_name_range_negative_first.sv) |enum の名前範囲 \[ N:M \] の最初の束 N は 非負の整数でなければなりません| 6.19.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_name_range_negative_last`](../../tests/ch6/test_illegal_enum_name_range_negative_last.sv) |enum の名前範囲 \[ N:M \] の 2 番目の限界 M は 非負の整数でなければなりません| 6.19.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_name_range_zero_count`](../../tests/ch6/test_illegal_enum_name_range_zero_count.sv) |enum \[ N \] 名前範囲名のカウント N は正の整数でなければなりません。\[ 0 \] は違法です| 6.19.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_enum_cast_outside_set_static_and_dynamic`](../../tests/ch6/test_enum_cast_outside_set_static_and_dynamic.sv) |変数の名前の集合以外の値を enum 変数に割り当てる。静的キャストはチェックを行わずに変数を変更しますが、 $cast は セット外の値に対して変数を変更しません。| 6.19.3 | Verilator 5.052 ||
| [`test_enum_values_in_integral_contexts`](../../tests/ch6/test_enum_values_in_integral_contexts.sv) |文脈に応じて enum 変数は 整数値に変換されます。 enum の名前は 結果が整数変数になる表現に使えます。| 6.19.3 6.19.4 | Icarus Verilog 13.0 ||
| [`test_illegal_enum_assign_out_of_set_literal`](../../tests/ch6/test_illegal_enum_assign_out_of_set_literal.sv) |メンバーが持たないリテラル値はキャストなしに enum 変数に割り当てることはできません。| 6.19.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_from_int`](../../tests/ch6/test_illegal_enum_from_int.sv) |int 値はキャストなしに enum 変数に割り当てられません| 6.19.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_enum_from_other_enum`](../../tests/ch6/test_illegal_enum_from_other_enum.sv) |タイプ enum のメンバーは、他のタイプ enum の変数に割り当てることはできません。| 6.19.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_enum_expression_uses_base_type`](../../tests/ch6/test_enum_expression_uses_base_type.sv) |表現の中の enum 変数または名前は、その基底型に変換されます。デフォルトでは int です。それゆえ、その基底の幅と符号を表現に取り入れます。| 6.19.4 11.6.1 11.8.1 | Icarus Verilog 13.0 ||
| [`test_illegal_enum_assign_arithmetic_without_cast`](../../tests/ch6/test_illegal_enum_assign_arithmetic_without_cast.sv) |enum 型と等価でない表現は、例えば enum 値と 1 のようなものは、enum 変数に割り当てるためにキャストが必要です。 typedef 型の値は、キャストが必要ありません。| 6.19.4 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_enum_comprehensive`](../../tests/ch6/test_enum_comprehensive.sv) |数値計算のメソッド first, last, num, name, next, prev を包み込み| 6.19.5 | Icarus Verilog 13.0 ||
| [`test_enum_edge`](../../tests/ch6/test_enum_edge.sv) |エナム端子| 6.19.5 6.19.4 | Icarus Verilog 13.0 ||
| [`test_enum_first_last`](../../tests/ch6/test_enum_first_last.sv) |テスト enum 初め/最後| 6.19.5 | Icarus Verilog 13.0 ||
| [`test_enum_method_edge`](../../tests/ch6/test_enum_method_edge.sv) |連続、非連続、単元、稀なエヌムのエヌム法 first、last、num、next、prev、name| 6.19.5 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 | Icarus Verilog 13.0 ||
| [`test_enum_methods`](../../tests/ch6/test_enum_methods.sv) |enum 拡張メソッドのテスト| 6.19.5 | Icarus Verilog 13.0 ||
| [`test_enum_methods_2`](../../tests/ch6/test_enum_methods_2.sv) |エンナム法テスト| 6.19.5 | Icarus Verilog 13.0 ||
| [`test_enum_methods_name_num`](../../tests/ch6/test_enum_methods_name_num.sv) |数列型| 6.19.5 6.19.5.5 6.19.5.6 | Icarus Verilog 13.0 ||
| [`test_enum_methods_navigation`](../../tests/ch6/test_enum_methods_navigation.sv) |数列型| 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.6 | Icarus Verilog 13.0 ||
| [`test_enum_non_sequential`](../../tests/ch6/test_enum_non_sequential.sv) |値が連続しない enum 上の Enum メソッド| 6.19.5 | Icarus Verilog 13.0 ||
| [`test_enum_ops_2`](../../tests/ch6/test_enum_ops_2.sv) |次の値を返します。| 6.19.5 | Icarus Verilog 13.0 ||
| [`test_enum_xz_member_methods`](../../tests/ch6/test_enum_xz_member_methods.sv) |xbitの項を持つ4状態数え上げの数え上げ法| 6.19.5 6.19 | Icarus Verilog 13.0 | x/z |
| [`test_enum_first_last_num`](../../tests/ch6/test_enum_first_last_num.sv) |次の例では、first() と last() は、宣言順序に従って最初の と最後のメンバーを返します。| 6.19.5.1 6.19.5.2 6.19.5.5 6.19.5.7 6.19.5.3 | Icarus Verilog 13.0 ||
| [`test_enum_last_in_declaration_order`](../../tests/ch6/test_enum_last_in_declaration_order.sv) |last() は最後に宣言されたメンバーを返しますが、最大値や最小値ではありません。 first() は最初に宣言されたメンバを返します。| 6.19.5.2 6.19.5.1 | Icarus Verilog 13.0 ||
| [`test_enum_next_prev`](../../tests/ch6/test_enum_next_prev.sv) |テスト enum 次/前| 6.19.5.3 6.19.5.4 | Icarus Verilog 13.0 ||
| [`test_enum_next_prev_from_non_member`](../../tests/ch6/test_enum_next_prev_from_non_member.sv) |次の値は、 メンバーではない値に対して、 int 基底の場合は enum , 0 のデフォルトの初期値を返し、 logic 基底の 場合は x を返します。| 6.19.5.3 6.19.5.4 6.8 | Icarus Verilog 13.0 | x/z |
| [`test_enum_num_name_result_types`](../../tests/ch6/test_enum_num_name_result_types.sv) |num() は引数を取らずに int を返します。 name() は引 数を取らず 文字列を返します。メンバーでない値は空です。| 6.19.5.5 6.19.5.6 20.6.1 |標準のみ||
| [`test_enum_name`](../../tests/ch6/test_enum_name.sv) |テスト enum 名前| 6.19.5.6 | Icarus Verilog 13.0 ||
| [`test_enum_name_2`](../../tests/ch6/test_enum_name_2.sv) |enum name() メソッド| 6.19.5.6 | Icarus Verilog 13.0 ||
| [`test_enum_wider_than_64_bits_name`](../../tests/ch6/test_enum_wider_than_64_bits_name.sv) |基本型が 64 ビットより広い enum の name() メソッドは、メンバーの名前を返します。| 6.19.5.6 6.19 |標準のみ||
| [`test_constant_edge_cases`](../../tests/ch6/test_constant_edge_cases.sv) |定辺の場合| 6.20 | Icarus Verilog 13.0 ||
| [`test_param`](../../tests/ch6/test_param.sv) |パラメータのテスト| 6.20 | Icarus Verilog 13.0 ||
| [`test_param_expr`](../../tests/ch6/test_param_expr.sv) |パラメータ表現テスト| 6.20 | Icarus Verilog 13.0 ||
| [`test_param_literal_initializers_follow_type`](../../tests/ch6/test_param_literal_initializers_follow_type.sv) |定数 localparam と specparam はリテラルに初期化され、 定数がリテラルの タイプに変換された後の値を取ります。| 6.20 5.9 6.12.1 6.16 | Verilator 5.052 ||
| [`test_param_local`](../../tests/ch6/test_param_local.sv) |テストパラメータとローカルパラメータ| 6.20 | Icarus Verilog 13.0 ||
| [`test_param_override_three_ways_module_interface_program`](../../tests/ch6/test_param_override_three_ways_module_interface_program.sv) |プログラムのインスタンスは、名前とdefparam で順序付けられたリストで上書きされ、それぞれが名前を付けたパラメータを正確に変更します。| 6.20 23.10.1 23.10.2.1 23.10.2.2 24.3 25.3 | Icarus Verilog 13.0 ||
| [`test_param_value`](../../tests/ch6/test_param_value.sv) |パラメータ値テスト| 6.20 | Icarus Verilog 13.0 ||
| [`test_parameter_advanced`](../../tests/ch6/test_parameter_advanced.sv) |高度なパラメータテスト| 6.20 23.10.2.2 | Icarus Verilog 13.0 ||
| [`test_parameter_and_const_lifetime`](../../tests/ch6/test_parameter_and_const_lifetime.sv) |localparamとspecparamは宣言幅に使われる 詳細化時間定数であり、constはスコープの寿命を持つランタイム定数です。| 6.20 | Icarus Verilog 13.0 ||
| [`test_parameter_types`](../../tests/ch6/test_parameter_types.sv) |パラメータタイプのテスト| 6.20 | Icarus Verilog 13.0 ||
| [`test_ch6_extra_body_parameter_local`](../../tests/ch6/test_ch6_extra_body_parameter_local.sv) |デザイン要素のボディにパラメータポートリストを持つパラメータ宣言は localparam として振る舞い、上書きできません。| 6.20.1 6.20.4 23.10.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_ch6_extra_class_body_parameter_local`](../../tests/ch6/test_ch6_extra_class_body_parameter_local.sv) |クラスボディのパラメータ代入は localparam であり、専門化はそれを上書きできません。| 6.20.1 6.20.4 8.25 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_class_parameter_without_default_default_specialization`](../../tests/ch6/test_illegal_class_parameter_without_default_default_specialization.sv) |パラメータにデフォルト値がないクラスの特化は それを上書きする必要がありますパラメータリストがないクラス名は| 6.20.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_localparam_type_without_default_in_port_list`](../../tests/ch6/test_illegal_localparam_type_without_default_in_port_list.sv) |タイプパラメータのポートリストにデフォルトタイプがない場合もありますが、 localparamタイプはデフォルトタイプではありません。| 6.20.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_localparam_value_without_default_in_port_list`](../../tests/ch6/test_illegal_localparam_value_without_default_in_port_list.sv) |値パラメータのポートリストには デフォルト値はありませんが、 localparam は存在しません。| 6.20.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_parameter_type_without_default_in_module_body`](../../tests/ch6/test_illegal_parameter_type_without_default_in_module_body.sv) |タイプパラメータはデフォルトタイプなしでパラメータポートリストでのみ宣言できます。モジュールアイテムではありません。| 6.20.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_parameter_value_without_default_in_module_body`](../../tests/ch6/test_illegal_parameter_value_without_default_in_module_body.sv) |値パラメータはデフォルト値なしでパラメータポートリストでのみ宣言できます。モジュールアイテムではありません。| 6.20.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_parameter_without_default_not_overridden`](../../tests/ch6/test_illegal_parameter_without_default_not_overridden.sv) |パラメータにデフォルト値がないモジュールの全てのインスタンスは| 6.20.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_param_constant_expr`](../../tests/ch6/test_param_constant_expr.sv) |定数表現で定義されたパラメータとローカルパラメータ| 6.20.1 6.20.4 11.2.1 | Verilator 5.052 ||
| [`test_param_declaration_contexts`](../../tests/ch6/test_param_declaration_contexts.sv) |localparam localparam パラメータはモジュール、インタフェース、プログラム、クラス、パッケージ、それらのパラメータポートリスト、生成ブロック、コンパイルユニットに表示されます。| 6.20.1 6.20.4 6.20 | Verilator 5.052 ||
| [`test_param_declaration_forms_aggregates_selects`](../../tests/ch6/test_param_declaration_forms_aggregates_selects.sv) |parameter宣言とlocalparam宣言では、データ型、または符号指定とpacked次元だけの指定、複数の代入、名前に付けたunpacked次元、および型代入のリストを使用できる。集合パラメータは要素とメンバーで読み、整数パラメータはbitとpart selectで読みます。| 6.20.1 6.20.2 | Verilator 5.052 ||
| [`test_param_without_default_not_implicit_top`](../../tests/ch6/test_param_without_default_not_implicit_top.sv) |なしで宣言されたパラメータは、その値をオーバーライドからのみ取得し、インスタンス化されないパラメータを持つモジュールはトップレベルインスタンスになりません。| 6.20.1 23.3.1 8.25 |標準のみ||
| [`test_parameter_declaration_forms`](../../tests/ch6/test_parameter_declaration_forms.sv) |定義するパラメータと localparam の宣言、データタイプ、暗黙型、 enum 制限付きまたは無いタイプパラメータ、値とタイプ代入のリスト、 unpacked 配列パラメータ、およびすべてのインスタンスが上書きするデフォルトのないパラメータ| 6.20.1 6.20.2 6.20.3 6.20.4 A.2.1.1 A.2.3 A.2.4 23.10.2.2 | Verilator 5.052 ||
| [`test_parameter_port_list_without_defaults`](../../tests/ch6/test_parameter_port_list_without_defaults.sv) |また，パラメータポートリストでは，値パラメータとタイプパラメータをデフォルトなしに宣言でき，それぞれのインスタンス化や特化化に値を与える。リストのlocalparamには まだ値表現がある| 6.20.1 6.20.3 8.25 23.10 A.2.1.1 A.10 | Verilator 5.052 ||
| [`test_specparam_declaration_with_pulse_control`](../../tests/ch6/test_specparam_declaration_with_pulse_control.sv) |specparam packed 次元、mintypmax 代入のリスト、特定のブロック内のパルス制御形式を選択します。| 6.20.1 | Icarus Verilog 13.0 ||
| [`test_generate_expr`](../../tests/ch6/test_generate_expr.sv) |範囲と生成条件で使用されるパラメータ表現| 6.20.2 27.5 | Icarus Verilog 13.0 ||
| [`test_generate_localparam_in_port_index`](../../tests/ch6/test_generate_localparam_in_port_index.sv) |ループ生成ブロックの localparam は、ポート接続のインデックスに使用される場合、その宣言幅を保持します。| 6.20.2 27.4 23.3.3 | Icarus Verilog 13.0 ||
| [`test_illegal_aggregate_parameter_element_defparam`](../../tests/ch6/test_illegal_aggregate_parameter_element_defparam.sv) |集計パラメータは全体としてのみ上書きされますdefparam unpacked 配列パラメータの 1 つの要素はエラーです| 6.20.2 |標準のみ|違法なデザインだ|
| [`test_illegal_enum_parameter_assigned_int`](../../tests/ch6/test_illegal_enum_parameter_assigned_int.sv) |明示的なタイプのパラメータに代入られた値は、そのタイプと相容れる代入でなければなりません。intの値は enum型のパラメータには 適用されません| 6.20.2 6.22.3 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_enum_parameter_overridden_with_int`](../../tests/ch6/test_illegal_enum_parameter_overridden_with_int.sv) |明示的なタイプのパラメータを上書きする値は、そのタイプと相容れる代入でなければなりません。intの値は enum型のパラメータには 適用されません| 6.20.2 6.22.3 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_parameter_value_from_variable`](../../tests/ch6/test_illegal_parameter_value_from_variable.sv) |値パラメータ表現はリテラル、パラメータ、localparams、genvars、enum名、パッケージパラメータ、それらの定数関数に限定されます。変数は許可されていません| 6.20.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_parameter_value_hierarchical_name`](../../tests/ch6/test_illegal_parameter_value_hierarchical_name.sv) |値パラメータの表現は 階層的な名前を使えません 別のインスタンスのパラメータを名付けたものでも| 6.20.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_param_basic_edge_cases`](../../tests/ch6/test_param_basic_edge_cases.sv) |表現と範囲で使用される無タイプ、タイプ、文字列パラメータ| 6.20.2 | Icarus Verilog 13.0 ||
| [`test_param_type_range_after_override`](../../tests/ch6/test_param_type_range_after_override.sv) |上書き後、タイプや範囲のないパラメータは、最終値のタイプと \[ size-1:0 \] の範囲を取得します。範囲のみのパラメータはその範囲と共に符号なしに残ります。符号のみのパラ メータは最終値のサイズを取得します。タイプや符号のある範囲のパラメータの場合は、そのタイプを保持します。実数値と integer 値は代入のように変換されます。| 6.20.2 6.12.1 23.10.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_param_value_2`](../../tests/ch6/test_param_value_2.sv) |値パラメータ| 6.20.2 23.10 | Icarus Verilog 13.0 ||
| [`test_parameter_edge_cases`](../../tests/ch6/test_parameter_edge_cases.sv) |パラメータ、localparams、および上書きされたインスタンスパラメータ、出力をチェック| 6.20.2 6.20.4 23.10 | Icarus Verilog 13.0 ||
| [`test_parameter_override_types`](../../tests/ch6/test_parameter_override_types.sv) |既定値と上書きを伴う、値・文字列・実数・型のパラメータ| 6.20.2 6.20.3 23.10 | Icarus Verilog 13.0 ||
| [`test_parameter_unbounded_value`](../../tests/ch6/test_parameter_unbounded_value.sv) |定数パラメータ表現とパラメータ表 現は、$で定義されたパラメータは無制限の値を持ち、データタイプは他の表現であり、$は他のパラメータに割り当てられ、$isunboundedはどのパラメータが$の値を持つかを報告します。| 6.20.2 6.20.3 20.6.3 A.8.3 |標準のみ||
| [`test_parameter_width_latitude`](../../tests/ch6/test_parameter_width_latitude.sv) |タイプなしのパラメータはサイズなしの値で 右辺の限界はゼロで 左辺の限界は少なくとも 31 で 、正確な幅はツールに任せます| 6.20.2 | Icarus Verilog 13.0 ||
| [`test_parameters_edge_cases`](../../tests/ch6/test_parameters_edge_cases.sv) |ローカルパラメータと上書きされたインスタンスパラメータ| 6.20.2 6.20.4 23.10 | Icarus Verilog 13.0 ||
| [`test_untyped_parameter_width_from_override`](../../tests/ch6/test_untyped_parameter_width_from_override.sv) |タイプも範囲もないパラメータは、その上位値の幅を取ります。| 6.20.2 23.10.2.1 23.10.2.2 | Icarus Verilog 13.0 ||
| [`test_illegal_enum_restricted_type_parameter_given_int`](../../tests/ch6/test_illegal_enum_restricted_type_parameter_given_int.sv) |型パラメータは、enum キーワードで制限され、エナメルタイプのみを与えられます。int はエラーです| 6.20.3 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_interface_class_restricted_type_parameter_given_class`](../../tests/ch6/test_illegal_interface_class_restricted_type_parameter_given_class.sv) |interface class で制限した型パラメータにはインタフェースクラスしか与えられない。インタフェースクラスを実装するクラスはエラーである| 6.20.3 8.26 |標準のみ|違法なデザインだ|
| [`test_illegal_struct_restricted_type_parameter_given_union`](../../tests/ch6/test_illegal_struct_restricted_type_parameter_given_union.sv) |struct キーワードで制限した型パラメータには構造体型しか与えられない。同じ幅の packed 共用体はエラーである| 6.20.3 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_type_parameter_assigned_value`](../../tests/ch6/test_illegal_type_parameter_assigned_value.sv) |タイプパラメータはデータタイプにのみ設定できます。データタイプはパッケージに適合したタイプ名でなければなりません。価値表現は違法です| 6.20.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_type_parameter_defparam`](../../tests/ch6/test_illegal_type_parameter_defparam.sv) |タイプパラメータは defparam ステートメントで上書きできませんが、| 6.20.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_type_parameter_hierarchical_type_name`](../../tests/ch6/test_illegal_type_parameter_hierarchical_type_name.sv) |タイプパラメータに与えられたデータタイプは階層的な名前を通じて名付けることはできませんが、パッケージに限定された名前は許可されています。| 6.20.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_type_parameter_scope_prefix_in_variable`](../../tests/ch6/test_illegal_type_parameter_scope_prefix_in_variable.sv) |タイプパラメータを通して :: で選択されたタイプは、typedef またはタイプパラメータ代入に使用できますが、変数宣言に直接使用できません。| 6.20.3 |標準のみ|違法なデザインだ|
| [`test_illegal_type_parameter_scope_prefix_not_class`](../../tests/ch6/test_illegal_type_parameter_scope_prefix_not_class.sv) |クラスの範囲解決演算子の プレフィックスとして使われるタイプパラメータは クラスに解決されなければなりません| 6.20.3 | Verilator 5.052 |違法なデザインだ|
| [`test_type_param_restricted_class_and_interface_lists`](../../tests/ch6/test_type_param_restricted_class_and_interface_lists.sv) |クラスとインタフェースのパラメータポートリストにある parameter キーワードも既定値もない制限付き型パラメータと、クラス本体の制限付きローカル型パラメータは、既定値、特殊化、上書きによって適合する型を受け取る| 6.20.3 6.20.1 6.20.4 8.25 25.8 | Verilator 5.052 ||
| [`test_type_param_restricted_conforming_types`](../../tests/ch6/test_type_param_restricted_conforming_types.sv) |制限付き型パラメータは、 enum の typedef 名、前方 typedef で宣言した enum 、派生クラス、パラメータ化クラスの特殊化、別のインタフェースクラスを拡張するインタフェースクラス、または同じ制限を持つ別の型パラメータを与えられたときに適合する| 6.20.3 6.18 8.25 8.26 | Verilator 5.052 ||
| [`test_type_param_restricted_kinds`](../../tests/ch6/test_type_param_restricted_kinds.sv) |タイプパラメータは enum に制限され、struct、union、class、interface クラスは単独またはタイプ代入のリストとして、デフォルトとオバーライドで適合型を取ります。| 6.20.3 6.20.1 8.26 | Verilator 5.052 ||
| [`test_ch6_extra_localparam_sticky`](../../tests/ch6/test_ch6_extra_localparam_sticky.sv) |パラメータポートリストでは、localparam の後の宣言は次のパラメータキーワードが入力されるまでローカルに残り、名前で上書きできません。| 6.20.4 23.10.2.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_generate_string_localparam`](../../tests/ch6/test_generate_string_localparam.sv) |テスト: ブロック文字列 localparam アクセスを生成| 6.20.4 27.5 | Icarus Verilog 13.0 ||
| [`test_illegal_localparam_defparam`](../../tests/ch6/test_illegal_localparam_defparam.sv) |defparam ステートメントはローカルパラメータを変更できません| 6.20.4 23.10.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_localparam_instance_override`](../../tests/ch6/test_illegal_localparam_instance_override.sv) |インスタンスのパラメータ値代入はローカルパラメータの名前を付けることができません| 6.20.4 23.10.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_localparam`](../../tests/ch6/test_localparam.sv) |テスト: 表現を持つ localparam| 6.20.4 6.20.3 20.8.1 | Verilator 5.052 ||
| [`test_localparam_edge_cases`](../../tests/ch6/test_localparam_edge_cases.sv) |テスト: Localparam 端のケース| 6.20.4 | Icarus Verilog 13.0 ||
| [`test_localparam_from_parameters`](../../tests/ch6/test_localparam_from_parameters.sv) |パラメータから計算されたローカルパラメータはインスタンスごとに異なり、階層的に読み込まれます。| 6.20.4 23.10 23.6 | Icarus Verilog 13.0 ||
| [`test_localparam_ops_edge_cases`](../../tests/ch6/test_localparam_ops_edge_cases.sv) |テスト: 局所パラメータ演算のエッジケース| 6.20.4 | Icarus Verilog 13.0 ||
| [`test_param_local_2`](../../tests/ch6/test_param_local_2.sv) |テスト: localparam の使用| 6.20.4 6.20.1 | Verilator 5.052 ||
| [`test_ch6_extra_defparam_specparam`](../../tests/ch6/test_ch6_extra_defparam_specparam.sv) |言語パラメータオーバーライド構造である defparam は specparam を修正できません。| 6.20.5 23.10.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_parameter_from_specparam`](../../tests/ch6/test_illegal_parameter_from_specparam.sv) |パラメータには指定パラメータを使用する値を与えられません| 6.20.5 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_parameter_in_specify_block`](../../tests/ch6/test_illegal_parameter_in_specify_block.sv) |特定のブロック内でパラメータを宣言することはできません。そこでは specparams のみが宣言されます。| 6.20.5 30.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_specparam_in_declaration_range`](../../tests/ch6/test_illegal_specparam_in_declaration_range.sv) |宣言の範囲指定の一部に specparam は含まれません| 6.20.5 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_specparam_in_interface`](../../tests/ch6/test_illegal_specparam_in_interface.sv) |specparam はモジュールボディまたは指定ブロックでのみ宣言できますが、インタフェースでは宣言できません。| 6.20.5 25.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_specparam_in_package`](../../tests/ch6/test_illegal_specparam_in_package.sv) |パッケージはモジュールでも指定ブロックでもないので、 specparam は宣言できません。| 6.20.5 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_specparam_used_before_declaration`](../../tests/ch6/test_illegal_specparam_used_before_declaration.sv) |これは、モジュールのボディに宣言された specparam は、その宣言の前に使用できないことを意味します。| 6.20.5 |標準のみ|違法なデザインだ|
| [`test_specify_specparam_delays`](../../tests/ch6/test_specify_specparam_delays.sv) |これは，パス遅延を，使用前に指定ブロックまたはモジュールにおいて宣言された指定パラメータで与えることもできる。| 6.20.5 30.3 30.5.1 | Icarus Verilog 13.0 ||
| [`test_specparam_declaration_forms`](../../tests/ch6/test_specparam_declaration_forms.sv) |これは、specparam を packed 範囲のあるまたはない、代入のリストと min:typ:max 値を持つモジュールのボディと、パス遅延を与える特定のブロックに宣言する。| 6.20.5 A.2.1.1 A.2.3 A.2.4 30.4.1 11.11 | Icarus Verilog 13.0 ||
| [`test_specparam_declared_and_inferred_range`](../../tests/ch6/test_specparam_declared_and_inferred_range.sv) |範囲を定義した specparam はその範囲を持ち、範囲を定義しないものは最終的に割り当てられた値の幅を取る。| 6.20.5 | Icarus Verilog 13.0 ||
| [`test_specparam_edge_cases`](../../tests/ch6/test_specparam_edge_cases.sv) |表現の値を変更するには、specparam を使用します。| 6.20.5 | Icarus Verilog 13.0 ||
| [`test_specparam_from_parameters_and_specparams`](../../tests/ch6/test_specparam_from_parameters_and_specparams.sv) |specparam はパラメータの定数表現と それ以前の specparams をモジュールボディと指定ブロックに取得し、 値はパラメータオーバーライドに従います。| 6.20.5 6.20.2 30.3 30.5.1 | Icarus Verilog 13.0 ||
| [`test_ch6_extra_const_handle_write`](../../tests/ch6/test_ch6_extra_const_handle_write.sv) |定義されたクラスハンドルは、そのオブジェクトのメンバーを変更することは可能ですが、その後は書き込めません。| 6.20.6 8.7 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_const_edge_cases`](../../tests/ch6/test_const_edge_cases.sv) |コンスト変数のエッジケース| 6.20.6 6.21 | Icarus Verilog 13.0 | x/z |
| [`test_const_ops_edge_cases`](../../tests/ch6/test_const_ops_edge_cases.sv) |テスト：コンスト演算のエッジケース| 6.20.6 6.21 | Icarus Verilog 13.0 ||
| [`test_const_runtime_automatic_and_class_handle`](../../tests/ch6/test_const_runtime_automatic_and_class_handle.sv) |automatic task内のconstは、シミュレーション中の呼出しごとに任意の式から新しい値を取得する。また、constのクラスハンドルが参照するオブジェクトのメンバーには、引き続き書き込むことができる。| 6.20.6 8.7 | Verilator 5.052 ||
| [`test_illegal_const_assigned`](../../tests/ch6/test_illegal_const_assigned.sv) |定数変数は宣言後に割り当てられません| 6.20.6 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_static_const_initializer_sources`](../../tests/ch6/test_static_const_initializer_sources.sv) |静的 const 初期化子はリテラル、パラメータ、localparams、genvars、enum 名前、定数関数、その他の定数、階層名を使用できます。| 6.20.6 | Icarus Verilog 13.0 ||
| [`test_dollar_covergroup_range`](../../tests/ch6/test_dollar_covergroup_range.sv) |値範囲 covergroup は \[ $:expression \] の下のすべての値を含み、 \[ expression:$ \] の上のすべての 値を含み、 0 からタイプの最大値まで。| 6.20.7 | Verilator 5.052 ||
| [`test_dollar_cycle_delay_and_actual`](../../tests/ch6/test_dollar_cycle_delay_and_actual.sv) |プロパティに送られたドル実際の引数をサイクル遅延範囲の上限として使用し，その範囲は数サイクル後のイベントを待つ。| 6.20.7 |標準のみ||
| [`test_dollar_parameter_unbounded`](../../tests/ch6/test_dollar_parameter_unbounded.sv) |$isunbounded は別のパラメータを通して報告するパラメータの値であり、$ は値範囲のオープンエンドとキューの最後の要素を表します。| 6.20.7 20.6.3 11.4.13 7.10.1 | Verilator 5.052 ||
| [`test_dollar_value_range_membership`](../../tests/ch6/test_dollar_value_range_membership.sv) |下限は他の限界の下にある全ての値を含み 上限は上限の上にある全ての価値を含みます| 6.20.7 | Verilator 5.052 ||
| [`test_illegal_dollar_assigned_to_real_parameter`](../../tests/ch6/test_illegal_dollar_assigned_to_real_parameter.sv) |値パラメータは単純な bit ベクトルタイプのみに割り当てられます。実際のパラメータは$ の値を持つことはできません| 6.20.7 |標準のみ|違法なデザインだ|
| [`test_illegal_dollar_in_ordinary_expression`](../../tests/ch6/test_illegal_dollar_in_ordinary_expression.sv) |例えば、int に代入る右側のように、$ は普通の表現として使えません。| 6.20.7 |標準のみ|違法なデザインだ|
| [`test_illegal_dollar_parameter_in_ordinary_expression`](../../tests/ch6/test_illegal_dollar_parameter_in_ordinary_expression.sv) |値が$のパラメータは$自体が使える場所にのみ使えます。従来の表現のオペランドとしては使えません。| 6.20.7 |標準のみ|違法なデザインだ|
| [`test_illegal_dollar_parameter_in_queue_select`](../../tests/ch6/test_illegal_dollar_parameter_in_queue_select.sv) |値が$のパラメータは、queue select のようなキューコンテキストでは使えません。| 6.20.7 |標準のみ|違法なデザインだ|
| [`test_illegal_dollar_with_operator_in_value_range`](../../tests/ch6/test_illegal_dollar_with_operator_in_value_range.sv) |を 使用して、 文字列を 選択する場合は、 文字列の 値を 指定 する必要があります。値範囲内の $ - 1 はエラーです| 6.20.7 |標準のみ|違法なデザインだ|
| [`test_isunbounded_package_and_hierarchical`](../../tests/ch6/test_isunbounded_package_and_hierarchical.sv) |$isunbounded はパッケージ範囲または階層的パラメータ名を取得し、 bit を返します。これは $ の値のパラメータに対してのみ 1 である。| 6.20.7 20.6.3 20.6.1 | Verilator 5.052 ||
| [`test_unbounded_queue_tail_after_resize`](../../tests/ch6/test_unbounded_queue_tail_after_resize.sv) |ドルキューインデックスはプッシュとポップの後に新しい最後の要素を追跡します| 6.20.7 | Verilator 5.052 ||
| [`test_automatic_data_declarations_in_static_procedural_scopes`](../../tests/ch6/test_automatic_data_declarations_in_static_procedural_scopes.sv) |静的タスク、静的関数、ループボディブロック、プロセスをフォークするブロックの内部に自動キーワードを持つデータ宣言は、それらの値を保持する明示的に静的なものに対して、各エントリに初期化された変数を与える。| 6.21 9.3.2 A.2.1.3 A.10 | Verilator 5.052 ||
| [`test_automatic_var`](../../tests/ch6/test_automatic_var.sv) |自動変数をテスト| 6.21 13.4.2 | Icarus Verilog 13.0 ||
| [`test_automatic_variable_in_static_subroutine`](../../tests/ch6/test_automatic_variable_in_static_subroutine.sv) |静的関数やタスクの自動変数は呼び出しごとに初期化されますが、静的変数はその値を保持します。| 6.21 13.3.1 13.4.2 | Verilator 5.052 ||
| [`test_ch6_extra_for_loop_automatic`](../../tests/ch6/test_ch6_extra_for_loop_automatic.sv) |forループの変数とクラスメソッド内の変数は既定でautomaticであるため、ループの各反復とメソッドの各呼出しは、それぞれ固有の値を保持する。| 6.21 12.7.1 8.4 | Verilator 5.052 ||
| [`test_design_element_static_lifetime`](../../tests/ch6/test_design_element_static_lifetime.sv) |設計要素が自動的であっても，モジュール，インタフェース，プログラム，チェッカのタスク，プロセス，関数以外の変数は静的な寿命を持ち，他の設計要素における同じ名前は異なる変数である。| 6.21 | Verilator 5.052 ||
| [`test_illegal_automatic_variable_nonblocking`](../../tests/ch6/test_illegal_automatic_variable_nonblocking.sv) |自動変数はブロックしない代入で書き込めません| 6.21 10.4.2 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_continuous_assign_reads_class_member`](../../tests/ch6/test_illegal_continuous_assign_reads_class_member.sv) |連続代入はクラスオブジェクトのメンバー、動的変数、またはクラスオブジャックのメンバーを参照できません。| 6.21 8.4 10.3 |標準のみ|違法なデザインだ|
| [`test_illegal_continuous_assign_reads_dynamic_element`](../../tests/ch6/test_illegal_continuous_assign_reads_dynamic_element.sv) |連続代入は動的配列の要素を参照できない。| 6.21 7.5 10.3 |標準のみ|違法なデザインだ|
| [`test_illegal_continuous_assign_to_class_property`](../../tests/ch6/test_illegal_continuous_assign_to_class_property.sv) |非静的なクラスプロパティは連続的な代入で書き込めません。| 6.21 8.4 10.3 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_continuous_assign_to_dynamic_element`](../../tests/ch6/test_illegal_continuous_assign_to_dynamic_element.sv) |動的にサイズを変更した配列の要素は連続的な代入で書き込めません| 6.21 7.5 10.3 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_declaration_after_statement_in_block`](../../tests/ch6/test_illegal_declaration_after_statement_in_block.sv) |プロセスブロックの変数宣言はそのステートメントの前に来る。言葉の後に言葉がつくのは間違いだ| 6.21 9.3.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_dynamic_array_element_continuous`](../../tests/ch6/test_illegal_dynamic_array_element_continuous.sv) |動的配列の要素は連続代入で駆動できません| 6.21 7.5 10.3 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_force_automatic_variable`](../../tests/ch6/test_illegal_force_automatic_variable.sv) |自動変数はforceのような手続き的な連続代入により書き込めない| 6.21 13.3.1 10.6.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_force_class_property`](../../tests/ch6/test_illegal_force_class_property.sv) |非静的なクラスプロパティは force のような手続き的な連続代入により書き込めない。| 6.21 8.4 10.6.2 |標準のみ|違法なデザインだ|
| [`test_illegal_force_dynamic_array_element`](../../tests/ch6/test_illegal_force_dynamic_array_element.sv) |動的にサイズを変更した配列の要素は，force のような手続き的な連続代入により書き込めない。| 6.21 7.5 10.6.2 |標準のみ|違法なデザインだ|
| [`test_illegal_initial_block_variable_initializer_no_keyword`](../../tests/ch6/test_illegal_initial_block_variable_initializer_no_keyword.sv) |プロシージャブロックでは、初期化子で宣言された変数にはキーワード static または automatic が必要です。| 6.21 9.2.1 |標準のみ|違法なデザインだ|
| [`test_illegal_nonblocking_to_automatic_variable`](../../tests/ch6/test_illegal_nonblocking_to_automatic_variable.sv) |自動変数はブロックしない代入で書き込めません| 6.21 13.3.1 10.4.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_nonblocking_to_dynamic_array_element`](../../tests/ch6/test_illegal_nonblocking_to_dynamic_array_element.sv) |動的にサイズを変更した配列の要素はブロックしない代入で書き込めません。| 6.21 7.5 10.4.2 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_static_task_variable_initializer_no_keyword`](../../tests/ch6/test_illegal_static_task_variable_initializer_no_keyword.sv) |静的タスクでは、初期化子で宣言された変数にはキーワード static または automatic が必要です。| 6.21 13.3 |標準のみ|違法なデザインだ|
| [`test_illegal_unnamed_block_variable_hierarchical`](../../tests/ch6/test_illegal_unnamed_block_variable_hierarchical.sv) |名前のないブロックで宣言された変数は、名前のあるブロックを通して階層的な名前でアクセスできません。| 6.21 9.3.4 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_variable_referenced_before_declaration`](../../tests/ch6/test_illegal_variable_referenced_before_declaration.sv) |変数はその宣言前に単純な名前で参照できません。| 6.21 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_lifetime_automatic_calls_blocks_static_locals`](../../tests/ch6/test_lifetime_automatic_calls_blocks_static_locals.sv) |各エントリに対して自動タスクや関数の変数とそのブロックが生成され、初期化される。 静的な変数は値を保持し、自動サブルーチンや名前付きブロックの静的変数も階層的な名前で読み取れる。| 6.21 13.3.1 13.4.2 | Verilator 5.052 ||
| [`test_lifetime_fork_keeps_automatic_scope`](../../tests/ch6/test_lifetime_fork_keeps_automatic_scope.sv) |フォークブロックとそれを包含するタスクの 自動変数は フォークによって生成されたプロセスが 実行されている間 生き続けます| 6.21 9.3.2 | Verilator 5.052 ||
| [`test_local_scope`](../../tests/ch6/test_local_scope.sv) |ローカルスコープテスト| 6.21 | Icarus Verilog 13.0 ||
| [`test_local_scope_edge_cases`](../../tests/ch6/test_local_scope_edge_cases.sv) |テスト：局所的範囲端の場合| 6.21 | Icarus Verilog 13.0 ||
| [`test_local_static`](../../tests/ch6/test_local_static.sv) |関数の静的変数は呼び出し間に値を保持します| 6.21 13.4.2 | Icarus Verilog 13.0 ||
| [`test_local_var_edge_cases_2`](../../tests/ch6/test_local_var_edge_cases_2.sv) |局所可変端の場合のテスト| 6.21 | Icarus Verilog 13.0 ||
| [`test_local_var_scope`](../../tests/ch6/test_local_var_scope.sv) |ブロック、関数、タスクのローカル変数、静的および自動| 6.21 13.4.2 | Icarus Verilog 13.0 ||
| [`test_module_automatic_lifetime`](../../tests/ch6/test_module_automatic_lifetime.sv) |自動的に宣言されたモジュールでは，そのタスクと関数の変数はデフォルトで自動的になり，静的に宣言されたものを除いて，呼び出し毎に再起動される。普通のモジュールでは 静止しているのに対し| 6.21 6.8 13.3.1 | Verilator 5.052 ||
| [`test_scope_resolution_edge_cases`](../../tests/ch6/test_scope_resolution_edge_cases.sv) |モジュール、ブロック、ネストブロック変数、内部ブロックで隠された名前| 6.21 | Icarus Verilog 13.0 ||
| [`test_static_initializer_runs_once`](../../tests/ch6/test_static_initializer_runs_once.sv) |プロセスブロックに宣言された静的変数の初期化子は、ブロックの各エントリではなく、時間 0 の前に一度実行されます。| 6.21 6.8 | Icarus Verilog 13.0 ||
| [`test_static_var`](../../tests/ch6/test_static_var.sv) |静的および自動的変数テスト| 6.21 13.4.2 | Icarus Verilog 13.0 ||
| [`test_static_var_edge_cases`](../../tests/ch6/test_static_var_edge_cases.sv) |モジュール変数は、ステートメント間で値を保持します。| 6.21 | Icarus Verilog 13.0 ||
| [`test_static_var_edge_cases_2`](../../tests/ch6/test_static_var_edge_cases_2.sv) |静的変数のエッジケース| 6.21 13.4.2 | Verilator 5.052 ||
| [`test_static_variable_of_block_not_yet_run`](../../tests/ch6/test_static_variable_of_block_not_yet_run.sv) |ブロックの静的変数はブロックが最初に実行される前に存在し、その階層的な名前を通して書き込めます。| 6.21 23.6 9.3.4 | Icarus Verilog 13.0 ||
| [`test_variables_and_subroutine_calls`](../../tests/ch6/test_variables_and_subroutine_calls.sv) |モジュール変数、ブロック変数、関数とタスクの呼び出し| 6.21 13.3 13.4 | Icarus Verilog 13.0 ||
| [`test_ch6_extra_instance_type_identity`](../../tests/ch6/test_ch6_extra_instance_type_identity.sv) |ユーザ定義型はインスタンス内で宣言され、その範囲内にインスタンスを含むので、2つのインスタンスで同じ宣言をすると2つの異なるタイプになります。| 6.22 6.19.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_typedef_package_type_shared`](../../tests/ch6/test_typedef_package_type_shared.sv) |パッケージに宣言された unpacked 構造、 packed 構造、および enum はインスタンス間で一致し、モジュールの 2 つのインスタンスのメンバー間で値を割り当てることができる。| 6.22 | Verilator 5.052 ||
| [`test_type_matching_rules_by_type_compare`](../../tests/ch6/test_type_matching_rules_by_type_compare.sv) |型参照の比較は、型の合致規則に従う。対象には、別名を付けるtypedefと型パラメータ、同一宣言内の無名型、構造体・列挙型・クラスのtypedef、冗長な符号指定、配列の種別・境界・要素、およびimport先を問わないpackageのtypedefが含まれる。他のペアは一致しません| 6.22.1 6.23 26.3 7.4.2 |標準のみ||
| [`test_ch6_extra_ref_dynamic_equiv`](../../tests/ch6/test_ch6_extra_ref_dynamic_equiv.sv) |intの動的配列とintの動的配列は等価であるため、ref引数で対応付けられる| 6.22.2 13.5.2 | Verilator 5.052 ||
| [`test_ch6_extra_ref_dynamic_kind`](../../tests/ch6/test_ch6_extra_ref_dynamic_kind.sv) |動的配列とキューは異なる種類の配列であり，同じ要素タイプであっても等価ではない。ref 引数はペアを作成できません| 6.22.2 13.5.2 | Verilator 5.052 |違法なデザインだ|
| [`test_ch6_extra_ref_equiv_closed`](../../tests/ch6/test_ch6_extra_ref_equiv_closed.sv) |intとlogic \[ 31:0 \]は等価ではなく、ref引数によってペア化できない。| 6.22.2 13.5.2 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_anonymous_struct_not_equivalent`](../../tests/ch6/test_illegal_anonymous_struct_not_equivalent.sv) |異なる宣言からの匿名 unpacked 構造は等価ではなく、一つを他に割り当てることはできません。| 6.22.2 6.22.3 |標準のみ|違法なデザインだ|
| [`test_type_equivalent_arrays`](../../tests/ch6/test_type_equivalent_arrays.sv) |元素型が等価なパッケージされていない配列（例えば、同じサイズ、状態、符号の packed 型）は、左から順に、それらの範囲に関係なく、互いに割り当てることができる。| 6.22.2 7.6 7.4.2 | Verilator 5.052 ||
| [`test_type_assignment_cast_compatible`](../../tests/ch6/test_type_assignment_cast_compatible.sv) |任意の型は暗黙的に変換される。enumはintegerに変換され、切り捨てを伴う整数型と丸めを伴う実数の間で変換される。integerはキャストを経てのみenumに変換される| 6.22.3 6.22.4 6.24.1 6.12.1 | Icarus Verilog 13.0 ||
| [`test_enum_explicit_cast_and_failed_dynamic_cast`](../../tests/ch6/test_enum_explicit_cast_and_failed_dynamic_cast.sv) |明示的な enum のキャストは整数値を許可し、失敗した動的キャストは目的地を変更しない| 6.22.4 6.24.2 | Verilator 5.052 ||
| [`test_illegal_class_handle_to_int`](../../tests/ch6/test_illegal_class_handle_to_int.sv) |クラスハンドルは他のすべてのタイプと互換性がなく、int に割り当てることはできません。| 6.22.5 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_handle_to_real_cast`](../../tests/ch6/test_illegal_handle_to_real_cast.sv) |クラスハンドルは、明示的なキャストでも実数に変換できません。| 6.22.5 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_nettype_matches_itself_across_ports`](../../tests/ch6/test_nettype_matches_itself_across_ports.sv) |ネットタイプは自分自身にマッチする それで それを宣言したネットは 異なるモジュールで そのネットタイプのポートを通して 接続し それらのドライバを通して 解決された 1つのネットに合体する| 6.22.6 6.6.7 23.3.3 |標準のみ||
| [`test_nettype_rename_matches`](../../tests/ch6/test_nettype_rename_matches.sv) |ユーザ定義のネットタイプの新しい名前として宣言されたネットタイプがそれに一致するので、新しい名前のネットが元のネットタイプのポートに接続します。| 6.22.6 6.6.7 23.3.3 |標準のみ||
| [`test_illegal_type_operator_dynamic_array_element`](../../tests/ch6/test_illegal_type_operator_dynamic_array_element.sv) |型演算子の式から、動的配列などの動的オブジェクトの要素を参照してはならない| 6.23 |標準のみ|違法なデザインだ|
| [`test_illegal_type_operator_hierarchical_reference`](../../tests/ch6/test_illegal_type_operator_hierarchical_reference.sv) |型演算子の表現には階層的な参照は含まれない| 6.23 |標準のみ|違法なデザインだ|
| [`test_illegal_type_reference_compared_with_value`](../../tests/ch6/test_illegal_type_reference_compared_with_value.sv) |等価比較における型参照は 別の型参照とのみ比較されるべきであり 値との比較はできない| 6.23 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_type_reference_variable_without_var`](../../tests/ch6/test_illegal_type_reference_variable_without_var.sv) |変数の宣言は var キーワードで始まります| 6.23 |標準のみ|違法なデザインだ|
| [`test_type_operator_matching_types`](../../tests/ch6/test_type_operator_matching_types.sv) |byteとbitの符号が\[ 7:0 \]のような 適合型に対しては タイプ(a) == タイプ(b) が真である| 6.23 6.22.1 |標準のみ||
| [`test_type_operator_self_determined_and_uses`](../../tests/ch6/test_type_operator_self_determined_and_uses.sv) |type(expression)は、式を評価せずに得られるその式の自己決定型である。型参照は、var宣言、キャスト、ローカル型パラメータ、型パラメータの上書き、および定数式となる比較に使用できる。| 6.23 11.6.1 11.8.1 11.2.1 | Verilator 5.052 ||
| [`test_type_reference_declare_cast_compare`](../../tests/ch6/test_type_reference_declare_cast_compare.sv) |型参照は、var の後に変数を、net の後に net 型キーワードを、その表現の型とともに宣言し、静的なキャストのキャストタイプであり、型マッチングによって with ==,!=, ===,!== を比較する。| 6.23 6.22.1 6.24.1 11.6.1 A.2.1.3 A.8.4 A.10 |標準のみ||
| [`test_cast_edge_cases`](../../tests/ch6/test_cast_edge_cases.sv) |キャストの境界ケース| 6.24 | Icarus Verilog 13.0 ||
| [`test_cast_ops_edge_cases`](../../tests/ch6/test_cast_ops_edge_cases.sv) |テスト：キャスト演算の境界ケース| 6.24 | Icarus Verilog 13.0 ||
| [`test_type_cast`](../../tests/ch6/test_type_cast.sv) |型キャストのテスト| 6.24 6.12.1 | Icarus Verilog 13.0 ||
| [`test_type_cast_advanced`](../../tests/ch6/test_type_cast_advanced.sv) |型キャストの追加テスト| 6.24 | Icarus Verilog 13.0 ||
| [`test_type_cast_int`](../../tests/ch6/test_type_cast_int.sv) |integer型へのキャストのテスト| 6.24 | Icarus Verilog 13.0 ||
| [`test_type_cast_real`](../../tests/ch6/test_type_cast_real.sv) |real型へのキャストのテスト| 6.24 | Icarus Verilog 13.0 ||
| [`test_type_casting_edge_cases`](../../tests/ch6/test_type_casting_edge_cases.sv) |型キャストの境界ケース| 6.24 | Icarus Verilog 13.0 ||
| [`test_type_casts_2`](../../tests/ch6/test_type_casts_2.sv) |型キャストのテスト| 6.24 | Icarus Verilog 13.0 ||
| [`test_unsigned_cast`](../../tests/ch6/test_unsigned_cast.sv) |テスト無符号キャスト| 6.24 | Icarus Verilog 13.0 ||
| [`test_cast_byte`](../../tests/ch6/test_cast_byte.sv) |バイト型変換| 6.24.1 6.11 | Icarus Verilog 13.0 ||
| [`test_cast_casting_type_forms_and_const`](../../tests/ch6/test_cast_casting_type_forms_and_const.sv) |すべてのキャスト型形式（integerとrealの型キーワード、typedef、package型、型パラメータ、定数サイズ、signed／unsigned、string、const）が機能する。オペランドが定数ならキャストも定数式となり、constキャストはオペランドの型を維持する| 6.24.1 6.12.2 6.16 | Verilator 5.052 ||
| [`test_cast_const`](../../tests/ch6/test_cast_const.sv) |コンスタントキャスト演算| 6.24.1 | Icarus Verilog 13.0 ||
| [`test_cast_corner`](../../tests/ch6/test_cast_corner.sv) |静的・動的キャスト、タイプ変換をテスト| 6.24.1 6.24.2 6.12.1 6.19.4 | Verilator 5.052 ||
| [`test_cast_dispatch_enum_and_bitstream`](../../tests/ch6/test_cast_dispatch_enum_and_bitstream.sv) |enum に変換するとベース型に切り捨てられます bit ストリーム変換は byte 配列のルールに従います| 6.24.1 6.24.3 | Icarus Verilog 13.0 ||
| [`test_cast_expr`](../../tests/ch6/test_cast_expr.sv) |表現テスト| 6.24.1 6.12.1 | Icarus Verilog 13.0 ||
| [`test_cast_expr_2`](../../tests/ch6/test_cast_expr_2.sv) |int enum とユーザ定義のタイプの間を変換します。| 6.24.1 6.12.1 | Icarus Verilog 13.0 ||
| [`test_cast_ext`](../../tests/ch6/test_cast_ext.sv) |テスト 1: int から shortint| 6.24.1 6.12.1 11.7 | Icarus Verilog 13.0 ||
| [`test_cast_logic`](../../tests/ch6/test_cast_logic.sv) |論理型キャスト| 6.24.1 | Icarus Verilog 13.0 ||
| [`test_cast_longint`](../../tests/ch6/test_cast_longint.sv) |longint型へのキャスト| 6.24.1 6.11 | Icarus Verilog 13.0 ||
| [`test_cast_operations`](../../tests/ch6/test_cast_operations.sv) |作業テスト| 6.24.1 6.12.1 | Icarus Verilog 13.0 ||
| [`test_cast_real`](../../tests/ch6/test_cast_real.sv) |real型へのキャスト| 6.24.1 6.12.1 | Icarus Verilog 13.0 ||
| [`test_cast_real_2`](../../tests/ch6/test_cast_real_2.sv) |整数型およびshortrealの値からrealへのキャスト| 6.24.1 6.12 | Icarus Verilog 13.0 ||
| [`test_cast_real_basic`](../../tests/ch6/test_cast_real_basic.sv) |テストリアルキャスト| 6.24.1 6.12.1 | Icarus Verilog 13.0 ||
| [`test_cast_shortint`](../../tests/ch6/test_cast_shortint.sv) |短文型キャスト| 6.24.1 6.11 | Icarus Verilog 13.0 ||
| [`test_cast_shortreal_round_vs_bit_pattern`](../../tests/ch6/test_cast_shortreal_round_vs_bit_pattern.sv) |shortrealは代入や転写で intビットや32ビットに変換されるが 丸められて分数が失われます $shortrealtobitsと$bitstoshortrealは bitビットのパターンに変換される| 6.24.1 6.12.2 20.5 | Icarus Verilog 13.0 ||
| [`test_cast_signed_2`](../../tests/ch6/test_cast_signed_2.sv) |signed'・unsigned'キャスト、$signed、$unsigned| 6.24.1 11.7 | Icarus Verilog 13.0 ||
| [`test_cast_size`](../../tests/ch6/test_cast_size.sv) |寸法試験| 6.24.1 | Icarus Verilog 13.0 ||
| [`test_cast_size_sign_keep_state_domain`](../../tests/ch6/test_cast_size_sign_keep_state_domain.sv) |大きさの変換と 記号の変換は \[ n-1:0 \]のベクトルを与えます 2状態のオペランドはbit 4状態のオペランはlogic つまりxとzは 4状態の変換のみを生き残ります| 6.24.1 20.6.1 |標準のみ| x/z |
| [`test_cast_string_literal_to_narrower_type`](../../tests/ch6/test_cast_string_literal_to_narrower_type.sv) |文字列リテラルを狭い整数型に変換すると、最右端の文字が保持されます。| 6.24.1 5.9 | Icarus Verilog 13.0 ||
| [`test_cast_to_enum_truncates`](../../tests/ch6/test_cast_to_enum_truncates.sv) |数列型に変換すると、結果がメンバーでない場合でも、値をベース型の幅に変換します。| 6.24.1 6.19.4 | Verilator 5.052 ||
| [`test_cast_unpacked_struct_bits_round_trip`](../../tests/ch6/test_cast_unpacked_struct_bits_round_trip.sv) |構造を unpacked にカストすると packed にカストされる 構造は最初のメンバーを最も重要なビット、フィールド、配列要素に順序付け、カストバックすると 4 の状態値を保持するときに復元されます| 6.24.1 6.24.3 |標準のみ| x/z |
| [`test_illegal_cast_real_array_to_unpacked_array`](../../tests/ch6/test_illegal_cast_real_array_to_unpacked_array.sv) |実数要素の unpacked 配列は、同じサイズの unpacked 配列にしても、他の型に変換できません。なぜなら、 packed 表現に対して real は有効ではないからです。| 6.24.1 |標準のみ|違法なデザインだ|
| [`test_illegal_cast_unpacked_struct_with_real_member`](../../tests/ch6/test_illegal_cast_unpacked_struct_with_real_member.sv) |実数部を持つ unpacked 構造は他のタイプに変換できません。 なぜなら、実数は packed 表現に対して有効ではないからです。| 6.24.1 |標準のみ|違法なデザインだ|
| [`test_illegal_signing_cast_of_real`](../../tests/ch6/test_illegal_signing_cast_of_real.sv) |表現は整数的でなければなりませんreal式をsigned'でキャストすることはできません。| 6.24.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_size_cast_negative`](../../tests/ch6/test_illegal_size_cast_negative.sv) |大きさの変換は正の定数でなければなりません負の大きさに変換するのは間違いです| 6.24.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_size_cast_of_real`](../../tests/ch6/test_illegal_size_cast_of_real.sv) |大きさの表現は整数でなければなりません実際の表現は 大きさに変換できません| 6.24.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_size_cast_zero`](../../tests/ch6/test_illegal_size_cast_zero.sv) |大きさの変換は正の定数でなければなりませんゼロサイズにカスタムするのは間違いです| 6.24.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_packed_union_size_and_implicit_conversion`](../../tests/ch6/test_packed_union_size_and_implicit_conversion.sv) |logicはbit，packedは最大のメンバーと同じ幅，packedは構造を暗黙的に変換し，enumは静的な強制を表す。| 6.24.1 6.19.4 6.24.3 20.6.2 | Verilator 5.052 ||
| [`test_signed_cast`](../../tests/ch6/test_signed_cast.sv) |テスト・サインキャスト| 6.24.1 | Icarus Verilog 13.0 ||
| [`test_size_cast_intermediate_context`](../../tests/ch6/test_size_cast_intermediate_context.sv) |算術中間子のサイズを変更し、オペランドの符号を保持するために実サイズのキャストを使う| 6.24.1 11.6 11.6.1 20.6.2 20.7 | Verilator 5.052 ||
| [`test_type_casting`](../../tests/ch6/test_type_casting.sv) |コーナーケース：型キャスト| 6.24.1 6.12.1 10.7 11.7 | Icarus Verilog 13.0 ||
| [`test_aggregate_dynamic_cast_incompatible`](../../tests/ch6/test_aggregate_dynamic_cast_incompatible.sv) |非単一型の変換元から、代入互換でない非単一型の変換先への動的キャストは失敗し、格納先を変更しない。一方、同じビットの静的なbitストリームキャストは成功する| 6.24.2 |標準のみ||
| [`test_cast_dynamic_array`](../../tests/ch6/test_cast_dynamic_array.sv) |配列要素に $cast を割り当てる| 6.24.2 7.5 7.10 | Verilator 5.052 ||
| [`test_cast_function`](../../tests/ch6/test_cast_function.sv) |IEEE 1800-2023 § 6.24.2 のテスト：$cast のシステム関数| 6.24.2 8.16 | Verilator 5.052 ||
| [`test_cast_function_and_static_enum_coercion`](../../tests/ch6/test_cast_function_and_static_enum_coercion.sv) |関数としての$castはintを返し、失敗時に目的地を変更しないでおく。一方、静的なenumはチェックを行わずに強制的にキャストします。| 6.24.2 6.24.1 |標準のみ||
| [`test_cast_packed_struct_member`](../../tests/ch6/test_cast_packed_struct_member.sv) |7.2 - $cast packed 構造要素アクセスを持つセクション| 6.24.2 7.2.1 | Verilator 5.052 ||
| [`test_ch6_extra_cast_task_runtime_error`](../../tests/ch6/test_ch6_extra_cast_task_runtime_error.sv) |コンパイル時に無効な $cast タスクコールは拒否されません。実行時エラーを報告し、格納先は変更しない| 6.24.2 6.19.3 | Verilator 5.052 ||
| [`test_class_cast_compatibility_dynamic`](../../tests/ch6/test_class_cast_compatibility_dynamic.sv) |クラスハンドル間の $cast は、オブジェクトが目的地と代入が互換性のある場合のみ成功します。| 6.24.2 | Verilator 5.052 ||
| [`test_member_access_cast`](../../tests/ch6/test_member_access_cast.sv) |メンバーアクセス表現で $cast をテスト| 6.24.2 8.16 | Verilator 5.052 ||
| [`test_bitstream_array_to_packed_order`](../../tests/ch6/test_bitstream_array_to_packed_order.sv) |ビットストリームキャストは最初の unpacked 要素を最も有意な端に置きます。| 6.24.3 |標準のみ||
| [`test_bitstream_cast_destination_layout`](../../tests/ch6/test_bitstream_cast_destination_layout.sv) |bit -ストリームキャストは、目的地のアイテムを左から右に埋め、残りのビットを最初の無制限動的アイテムに与え、すべての動的ソースアイテムを含む。| 6.24.3 |標準のみ||
| [`test_bitstream_cast_source_domain`](../../tests/ch6/test_bitstream_cast_source_domain.sv) |ソース部分が4状態のときは bit ストリームキャストは4状態であり、再帰的な bit ストリームタイプは文字列、クラス、動的、連想、キューデータを含む。| 6.24.3 |標準のみ| x/z |
| [`test_bitstream_cast_source_orders`](../../tests/ch6/test_bitstream_cast_source_orders.sv) |bitストリームキャストは、連想配列を添字順にパックし、動的配列・キュー・文字列では添字0を最上位側に置く| 6.24.3 |標準のみ||
| [`test_illegal_bitstream_cast_class_with_local_member`](../../tests/ch6/test_illegal_bitstream_cast_class_with_local_member.sv) |ローカルまたは保護されたメンバーを持つクラスのハンドルは、 bit -ストリームキャストのソースにはなりません。クラス内のハンドルを除いては、| 6.24.3 |標準のみ|違法なデザインだ|
| [`test_illegal_bitstream_cast_fixed_size_mismatch`](../../tests/ch6/test_illegal_bitstream_cast_fixed_size_mismatch.sv) |固定サイズの型の間に bit -ストリームをキャストすると、そのうちの一つが unpacked となる。| 6.24.3 |標準のみ|違法なデザインだ|
| [`test_illegal_bitstream_cast_to_assoc_array`](../../tests/ch6/test_illegal_bitstream_cast_to_assoc_array.sv) |関連性配列タイプは bit -ストリームキャストの 目的地タイプにはなりません| 6.24.3 |標準のみ|違法なデザインだ|
| [`test_illegal_bitstream_cast_to_class`](../../tests/ch6/test_illegal_bitstream_cast_to_class.sv) |クラスタイプは bit -ストリームキャストの ターゲットタイプにはなりません| 6.24.3 |標準のみ|違法なデザインだ|
| [`test_parameterized_data_types`](../../tests/ch6/test_parameterized_data_types.sv) |クラスパラメータを用いた仮想クラスの型定義は，クラスパラメーターによって特化したパラメータ化データ型を与える。| 6.25 8.25 8.23 | Verilator 5.052 ||
| [`test_parameterized_typedef_specializations`](../../tests/ch6/test_parameterized_typedef_specializations.sv) |クラスパラメータの特化は異なる typedef 幅を生成し、明示的なデフォルトパラメータを暴露します。| 6.25 8.25.1 | Verilator 5.052 ||

<a id="generated-by-generatorscombination_aggregatespy"></a>

## 生成者: `generators/combination_aggregates.py`

2 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_combo_struct_array_automatic_elements`](../../tests/gen/ch6/test_gen_combo_struct_array_automatic_elements.sv) |重なり合う自動構造配列は待ち時間に関係なく独立した値を保持する| 6.21 7.2 7.4.2 9.3.2 9.4.1 | Verilator 5.052 ||
| [`test_gen_combo_struct_array_automatic_member`](../../tests/gen/ch6/test_gen_combo_struct_array_automatic_member.sv) |重なり合う自動構造配列は待ち時間に関係なく独立した値を保持する| 6.21 7.2 7.4.2 9.3.2 9.4.1 | Verilator 5.052 ||

<a id="generated-by-generatorscombination_eventspy"></a>

## 生成者: `generators/combination_events.py`

2 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_combo_event_automatic_scalar_control_capture`](../../tests/gen/ch6/test_gen_combo_event_automatic_scalar_control_capture.sv) |自動イベントハンドルは独立していて、フォークオーナーが戻ってきた後も生き残ります。| 6.21 6.8 6.17 9.3.2 15.5.2 15.5.5.2 |標準のみ||
| [`test_gen_combo_event_automatic_struct_capture`](../../tests/gen/ch6/test_gen_combo_event_automatic_struct_capture.sv) |自動イベントハンドルは独立していて、フォークオーナーが戻ってきた後も生き残ります。| 6.21 6.8 6.17 9.3.2 15.5.2 15.5.5.2 7.2.2 |標準のみ||

<a id="generated-by-generatorsinteraction_castpy"></a>

## 生成者: `generators/interaction_cast.py`

32 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_cast_w129_s_x_typed_bit_n_add_l`](../../tests/gen/ch6/test_gen_cross_cast_w129_s_x_typed_bit_n_add_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w129_s_z_unsigned_s_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w129_s_z_unsigned_s_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w129_u_k_signed_s_plain_l`](../../tests/gen/ch6/test_gen_cross_cast_w129_u_k_signed_s_plain_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w129_u_k_size_w_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w129_u_k_size_w_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w129_u_k_typed_logic_n_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w129_u_k_typed_logic_n_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w1_s_k_typed_bit_w_add_l`](../../tests/gen/ch6/test_gen_cross_cast_w1_s_k_typed_bit_w_add_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w1_s_x_unsigned_s_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w1_s_x_unsigned_s_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w1_s_z_size_s_add_b`](../../tests/gen/ch6/test_gen_cross_cast_w1_s_z_size_s_add_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w1_u_x_signed_s_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w1_u_x_signed_s_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w1_u_z_typed_logic_s_plain_l`](../../tests/gen/ch6/test_gen_cross_cast_w1_u_z_typed_logic_s_plain_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w32_s_k_signed_s_add_l`](../../tests/gen/ch6/test_gen_cross_cast_w32_s_k_signed_s_add_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w32_s_x_typed_logic_w_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w32_s_x_typed_logic_w_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w32_u_k_size_n_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w32_u_k_size_n_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w32_u_k_unsigned_s_add_l`](../../tests/gen/ch6/test_gen_cross_cast_w32_u_k_unsigned_s_add_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w32_u_z_typed_bit_n_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w32_u_z_typed_bit_n_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w33_s_k_size_n_add_b`](../../tests/gen/ch6/test_gen_cross_cast_w33_s_k_size_n_add_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w33_s_k_typed_logic_n_add_l`](../../tests/gen/ch6/test_gen_cross_cast_w33_s_k_typed_logic_n_add_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w33_u_k_unsigned_s_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w33_u_k_unsigned_s_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w33_u_x_signed_s_add_b`](../../tests/gen/ch6/test_gen_cross_cast_w33_u_x_signed_s_add_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w33_u_x_size_s_plain_l`](../../tests/gen/ch6/test_gen_cross_cast_w33_u_x_size_s_plain_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w33_u_z_typed_bit_w_add_b`](../../tests/gen/ch6/test_gen_cross_cast_w33_u_z_typed_bit_w_add_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w64_s_k_typed_logic_s_plain_l`](../../tests/gen/ch6/test_gen_cross_cast_w64_s_k_typed_logic_s_plain_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w64_s_x_typed_bit_s_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w64_s_x_typed_bit_s_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w64_u_x_size_n_add_l`](../../tests/gen/ch6/test_gen_cross_cast_w64_u_x_size_n_add_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w64_u_x_unsigned_s_add_b`](../../tests/gen/ch6/test_gen_cross_cast_w64_u_x_unsigned_s_add_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w64_u_z_signed_s_add_b`](../../tests/gen/ch6/test_gen_cross_cast_w64_u_z_signed_s_add_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w64_u_z_typed_logic_w_add_b`](../../tests/gen/ch6/test_gen_cross_cast_w64_u_z_typed_logic_w_add_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w65_s_z_signed_s_plain_b`](../../tests/gen/ch6/test_gen_cross_cast_w65_s_z_signed_s_plain_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w65_s_z_size_w_plain_l`](../../tests/gen/ch6/test_gen_cross_cast_w65_s_z_size_w_plain_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w65_u_k_typed_bit_s_plain_l`](../../tests/gen/ch6/test_gen_cross_cast_w65_u_k_typed_bit_s_plain_l.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_cast_w65_u_x_typed_logic_n_add_b`](../../tests/gen/ch6/test_gen_cross_cast_w65_u_x_typed_logic_n_add_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_cast_w65_u_z_unsigned_s_add_b`](../../tests/gen/ch6/test_gen_cross_cast_w65_u_z_unsigned_s_add_b.sv) |明示的なキャストによる変換は、外側の算術演算と格納先への変換より前に行われる| 6.24.1 6.11.2 11.6.1 11.8.1 11.8.2 | Icarus Verilog 13.0 | x/z |

<a id="generated-by-generatorsinteraction_genenumpy"></a>

## 生成者: `generators/interaction_genenum.py`

36 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_genenum_129_signed_case_high_3_prev_beyond`](../../tests/gen/ch6/test_gen_cross_genenum_129_signed_case_high_3_prev_beyond.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_129_signed_if_dense_2_prev_zero`](../../tests/gen/ch6/test_gen_cross_genenum_129_signed_if_dense_2_prev_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_129_signed_if_descending_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_129_signed_if_descending_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_129_unsigned_case_high_2_prev_cycle`](../../tests/gen/ch6/test_gen_cross_genenum_129_unsigned_case_high_2_prev_cycle.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_129_unsigned_if_dense_2_next_beyond`](../../tests/gen/ch6/test_gen_cross_genenum_129_unsigned_if_dense_2_next_beyond.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_129_unsigned_if_descending_3_prev_one`](../../tests/gen/ch6/test_gen_cross_genenum_129_unsigned_if_descending_3_prev_one.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_1_signed_if_dense_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_1_signed_if_dense_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_1_signed_if_descending_2_next_one`](../../tests/gen/ch6/test_gen_cross_genenum_1_signed_if_descending_2_next_one.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_1_signed_if_high_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_1_signed_if_high_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_1_unsigned_case_dense_2_prev_cycle`](../../tests/gen/ch6/test_gen_cross_genenum_1_unsigned_case_dense_2_prev_cycle.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_1_unsigned_if_descending_2_prev_beyond`](../../tests/gen/ch6/test_gen_cross_genenum_1_unsigned_if_descending_2_prev_beyond.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_1_unsigned_if_high_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_1_unsigned_if_high_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_32_signed_case_dense_3_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_32_signed_case_dense_3_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_32_signed_if_descending_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_32_signed_if_descending_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_32_signed_if_high_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_32_signed_if_high_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_32_unsigned_case_high_2_next_beyond`](../../tests/gen/ch6/test_gen_cross_genenum_32_unsigned_case_high_2_next_beyond.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_32_unsigned_if_dense_3_prev_one`](../../tests/gen/ch6/test_gen_cross_genenum_32_unsigned_if_dense_3_prev_one.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_32_unsigned_if_descending_2_next_cycle`](../../tests/gen/ch6/test_gen_cross_genenum_32_unsigned_if_descending_2_next_cycle.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_33_signed_if_dense_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_33_signed_if_dense_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_33_signed_if_descending_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_33_signed_if_descending_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_33_signed_if_high_3_next_cycle`](../../tests/gen/ch6/test_gen_cross_genenum_33_signed_if_high_3_next_cycle.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_33_unsigned_case_descending_3_prev_zero`](../../tests/gen/ch6/test_gen_cross_genenum_33_unsigned_case_descending_3_prev_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_33_unsigned_case_high_2_prev_one`](../../tests/gen/ch6/test_gen_cross_genenum_33_unsigned_case_high_2_prev_one.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_33_unsigned_if_dense_2_prev_beyond`](../../tests/gen/ch6/test_gen_cross_genenum_33_unsigned_if_dense_2_prev_beyond.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 | Verilator 5.052 ||
| [`test_gen_cross_genenum_64_signed_case_dense_2_next_cycle`](../../tests/gen/ch6/test_gen_cross_genenum_64_signed_case_dense_2_next_cycle.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_64_signed_case_descending_3_next_beyond`](../../tests/gen/ch6/test_gen_cross_genenum_64_signed_case_descending_3_next_beyond.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_64_signed_if_high_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_64_signed_if_high_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_64_unsigned_if_dense_3_next_one`](../../tests/gen/ch6/test_gen_cross_genenum_64_unsigned_if_dense_3_next_one.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_64_unsigned_if_descending_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_64_unsigned_if_descending_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_64_unsigned_if_high_2_prev_zero`](../../tests/gen/ch6/test_gen_cross_genenum_64_unsigned_if_high_2_prev_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_65_signed_if_dense_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_65_signed_if_dense_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_65_signed_if_descending_3_prev_cycle`](../../tests/gen/ch6/test_gen_cross_genenum_65_signed_if_descending_3_prev_cycle.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_65_signed_if_high_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_65_signed_if_high_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_65_unsigned_case_dense_3_next_beyond`](../../tests/gen/ch6/test_gen_cross_genenum_65_unsigned_case_dense_3_next_beyond.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_65_unsigned_case_descending_2_next_zero`](../../tests/gen/ch6/test_gen_cross_genenum_65_unsigned_case_descending_2_next_zero.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||
| [`test_gen_cross_genenum_65_unsigned_if_high_2_next_one`](../../tests/gen/ch6/test_gen_cross_genenum_65_unsigned_if_high_2_next_one.sv) |生成スコープごとに異なるenumの値表・巡回・保持値を照合する| 6.19 6.19.1 6.19.5 6.19.5.1 6.19.5.2 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6 27.4 27.5 |標準のみ||

<a id="generated-by-generatorswide_pathspy"></a>

## 生成者: `generators/wide_paths.py`

7 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_wide_values_w127`](../../tests/gen/ch6/test_gen_wide_values_w127.sv) |広い，狭い，2状態のターゲットに127 - bit値を代入る| 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w128`](../../tests/gen/ch6/test_gen_wide_values_w128.sv) |広い，狭い，2状態のターゲットに128 - bit値を代入る| 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w129`](../../tests/gen/ch6/test_gen_wide_values_w129.sv) |広い，狭い，2状態のターゲットに129 - bit値を代入る| 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w200`](../../tests/gen/ch6/test_gen_wide_values_w200.sv) |広い，狭い，2状態のターゲットに200 - bit値を代入る| 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w63`](../../tests/gen/ch6/test_gen_wide_values_w63.sv) |広い，狭い，2状態のターゲットに63 - bit値を代入る| 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w64`](../../tests/gen/ch6/test_gen_wide_values_w64.sv) |広い，狭い，2状態のターゲットに64 - bit値を代入る| 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w65`](../../tests/gen/ch6/test_gen_wide_values_w65.sv) |広い，狭い，2状態のターゲットに65 - bit値を代入る| 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
