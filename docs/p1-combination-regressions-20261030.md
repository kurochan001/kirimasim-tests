# Issue #21：組合せ境界の回帰取り込み

[追跡Issue](https://github.com/kurochan001/kirimasim-tests/issues/21) / [元の観測記録](p1-combination-gaps-20261030.md) / [照合台帳](../coverage/combination-gaps.json)

Issue #21の20候補を、既存の主観測・対照と、新しい境界条件の回帰テストへ対応付けます。元の34件の探索記録は履歴として保存します。この台帳の登録完了はkirimasim本体の機能実装完了を意味しません。要求分母へ自動加算せず、未対応を成功の期待値に使わず、解釈保留とネイティブAPIの範囲を明示します。

- 確認者: Codex GPT-6（AI確認。event・NBA・複合型の作成とは別に、独立した担当が規格と期待値を照合）。確認日: 2026-10-30。
- 候補20項目、重複を除く対象88件。新規74件、残りは既存テストを再利用。
- 登録・規格確認が済んだことと、実装が合格したことを分けます。unsupported・known・未実行は合格に含めません。
- 各実行の入力・期待値・ランナー指紋を照合し、異なる実行の部分成功は合成しません。
- 保留した解釈と範囲外のAPIは下記に残し、実装不足や成功へ読み替えません。

- 最新版確認時のコミットとビルド前後のバイナリ指紋は[ビルド証跡](../coverage/combination-qualification/issue21-build.json)に保存しています。これは実行開始時に確認した上流版であり、その後の更新への追従を自動保証しません。
- VCD検査器は、正常・program欠落・moduleのみ・scope終端の過剰という[故障注入4条件](../coverage/combination-qualification/issue21-vcd-checker.json)でも判定を確認しています。

## E01：automaticなstructのeventメンバと寿命

6.8、6.21、15.5に従い、呼出しごとに異なるイベントと、forkで延長される自動変数の寿命を確認します。

- [test_gen_combo_event_automatic_scalar_control_capture](../tests/gen/ch6/test_gen_combo_event_automatic_scalar_control_capture.sv)（主観測・新規）。
  2回の呼出しのイベント識別、task復帰後の捕捉値、個別の起床、別名解除後の独立性。条項: 6.21、6.8、6.17、9.3.2、15.5.2、15.5.5.2。
- [test_gen_combo_event_automatic_struct_capture](../tests/gen/ch6/test_gen_combo_event_automatic_struct_capture.sv)（主観測・新規）。
  2回の呼出しのイベント識別、task復帰後の捕捉値、個別の起床、別名解除後の独立性。条項: 6.21、6.8、6.17、9.3.2、15.5.2、15.5.5.2、7.2.2。

- 範囲・制限: SV出力で観測できるのは識別と参照の寿命です。GCが回収した実メモリ量は確認しません。

## E02：eventを返す関数と条件付き初期化

eventの戻り値と既知の条件式によるハンドル選択を確認します。nullと同一性も観測します。

- [test_gen_combo_event_conditional_initializer](../tests/gen/ch15/test_gen_combo_event_conditional_initializer.sv)（主観測・新規）。
  戻り値・条件選択後のハンドル一致と不一致、および対応する待機プロセスだけの起床。条項: 15.5.5.1、15.5.5.3、6.17、6.21、13.4、15.5.2、11.4.11。
- [test_gen_combo_event_return_initializer](../tests/gen/ch15/test_gen_combo_event_return_initializer.sv)（主観測・新規）。
  戻り値・条件選択後のハンドル一致と不一致、および対応する待機プロセスだけの起床。条項: 15.5.5.1、15.5.5.3、6.17、6.21、13.4、15.5.2。

- 範囲・制限: 不明値を条件としたマージ規則は本項目の対象外です。

## E03：always_ffと計算したエッジ式

always_ffに1個のイベント制御を置き、その式を計算式とします。9.2.2.4、9.4.2のエッジ判定を刺激列から求めます。

- [test_gen_combo_always_ff_computed_edge_capture](../tests/gen/ch9/test_gen_combo_always_ff_computed_edge_capture.sv)（主観測・新規）。
  入力の複数の変化から実際の計算式エッジだけを捕捉し、書込み回数と値を確認。条項: 9.2.2.4、9.4.2、10.4.2。

- 範囲・制限: 複数プロセスからの同一変数書込みは行いません。

## E04：iffガードと副作用を持つ関数

ガード関数が評価される時点と、ガード通過時の本体実行を分けて確認します。

- [test_gen_combo_iff_function_side_effect_accept](../tests/gen/ch9/test_gen_combo_iff_function_side_effect_accept.sv)（主観測・新規）。
  ガードの呼出し回数、通過・不通過、イベント本体の回数と最終値。条項: 9.4.2.3、9.4.2、13.4。
- [test_gen_combo_iff_function_side_effect_reject](../tests/gen/ch9/test_gen_combo_iff_function_side_effect_reject.sv)（主観測・新規）。
  ガードの呼出し回数、通過・不通過、イベント本体の回数と最終値。条項: 9.4.2.3、9.4.2、13.4。

- 範囲・制限: 同時刻に競合する別プロセスからガード用変数へ書き込みません。

## E05：イベント制御付きノンブロッキングトリガ

15.5.1のイベント制御付きトリガを、発行元の終了後にも観測します。基本の非同期トリガは既存テストを再利用します。

- [test_gen_combo_event_control_trigger_after_issuer_end](../tests/gen/ch15/test_gen_combo_event_control_trigger_after_issuer_end.sv)（主観測・新規）。
  発行直後は未起床、指定イベント後の時刻2で1回だけ起床、後続時刻でも重複しないこと。条項: 15.5.1、4.4.2.4、9.4.2。
- [test_event_nonblocking_trigger](../tests/ch15/test_event_nonblocking_trigger.sv)（主観測・既存再利用）。
  既存の即時・非同期トリガと待機の基本動作。条項: 15.5.1、4.4.2.4、9.4。

- 範囲・制限: 単なる ->> の基本動作と、発行元終了後に残るイベント制御を分けて観測します。

## E06：名前付きforkとdisable

名前付きブロックのdisableで、待機中の子プロセスと遅延中の子プロセスを終了させます。

- [test_gen_combo_named_fork_disable_waiters](../tests/gen/ch9/test_gen_combo_named_fork_disable_waiters.sv)（主観測・新規）。
  disable対象の遅延・イベント待機は完了せず、無関係な子だけが完了することとjoin復帰時刻。条項: 9.6.2、9.3.2、9.3.4、15.5.2。
- [test_named_blocks_scope_items_and_disable](../tests/ch9/test_named_blocks_scope_items_and_disable.sv)（主観測・既存再利用）。
  既存の名前付きブロック・forkのスコープとdisable。条項: 9.3.4、9.6.2。

- 範囲・制限: disableされたtaskが予約済みのNBAを残す場合の扱いは、9.6.2の未規定範囲として期待値に使いません。

## N01：ref staticと遅延NBA

ref staticには静的な実引数を渡します。10.4.2、9.4.5、13.5.2に従い、予約時の値と書込み先を保持することを確認します。

- [test_gen_ref_static_delayed_nba_w65_logic](../tests/gen/ch10/test_gen_ref_static_delayed_nba_w65_logic.sv)（主観測・新規）。
  2回の自動task復帰後も実引数の識別を保持し、時刻2のActiveでは旧値、NBA後には予約時の値になること。条項: 10.4.2、9.4.5、13.5.2、4.4.2.2、4.4.2.4。
- [test_gen_ref_static_delayed_nba_w8_bit](../tests/gen/ch10/test_gen_ref_static_delayed_nba_w8_bit.sv)（主観測・新規）。
  2回の自動task復帰後も実引数の識別を保持し、時刻2のActiveでは旧値、NBA後には予約時の値になること。条項: 10.4.2、9.4.5、13.5.2、4.4.2.2、4.4.2.4。
- [test_illegal_automatic_task_variable_nonblocking_target](../tests/ch13/test_illegal_automatic_task_variable_nonblocking_target.sv)（対照・既存再利用）。
  自動task変数をNBAの書込み先にする不正記述の拒否。条項: 13.3.2。

- 範囲・制限: 自動変数をref static実引数に使いません。自動変数への遅延NBAは既存の不正記述テストで区別します。

## N02：ref経由の固定配列要素とイベント待ちNBA

8/65ビット、配列添字の昇順/降順を組み合わせ、予約後に選択用変数と入力値を変更します。

- [test_gen_ref_static_array_event_nba_w65_ascending](../tests/gen/ch10/test_gen_ref_static_array_event_nba_w65_ascending.sv)（主観測・新規）。
  イベント発生までは旧値を保ち、発生後は予約時に選択した配列要素だけに捕捉値を書き込むこと。条項: 10.4.2、9.4.5、13.5.2、7.4.1、4.4.2.3、4.4.2.4。
- [test_gen_ref_static_array_event_nba_w65_descending](../tests/gen/ch10/test_gen_ref_static_array_event_nba_w65_descending.sv)（主観測・新規）。
  イベント発生までは旧値を保ち、発生後は予約時に選択した配列要素だけに捕捉値を書き込むこと。条項: 10.4.2、9.4.5、13.5.2、7.4.1、4.4.2.3、4.4.2.4。
- [test_gen_ref_static_array_event_nba_w8_ascending](../tests/gen/ch10/test_gen_ref_static_array_event_nba_w8_ascending.sv)（主観測・新規）。
  イベント発生までは旧値を保ち、発生後は予約時に選択した配列要素だけに捕捉値を書き込むこと。条項: 10.4.2、9.4.5、13.5.2、7.4.1、4.4.2.3、4.4.2.4。
- [test_gen_ref_static_array_event_nba_w8_descending](../tests/gen/ch10/test_gen_ref_static_array_event_nba_w8_descending.sv)（主観測・新規）。
  イベント発生までは旧値を保ち、発生後は予約時に選択した配列要素だけに捕捉値を書き込むこと。条項: 10.4.2、9.4.5、13.5.2、7.4.1、4.4.2.3、4.4.2.4。

- 範囲・制限: 同一要素への順序未定の競合書込みを作りません。

## N03：ref経由の多段packed選択とイベント待ちNBA

親の選択範囲内だけを子選択の書込み先とし、11.5.1の範囲外規則を適用します。

- [test_gen_ref_static_nested_packed_event_nba_w65_outside_parent](../tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_outside_parent.sv)（主観測・新規）。
  8/65ビットの親選択と子選択を捕捉し、親の範囲外にある子ビットは更新しないこと。条項: 10.4.2、9.4.5、13.5.2、11.5.1、7.4.5、4.4.2.3、4.4.2.4。
- [test_gen_ref_static_nested_packed_event_nba_w65_valid](../tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_valid.sv)（主観測・新規）。
  8/65ビットの親選択と子選択を捕捉し、親の範囲外にある子ビットは更新しないこと。条項: 10.4.2、9.4.5、13.5.2、11.5.1、7.4.5、4.4.2.3、4.4.2.4。
- [test_gen_ref_static_nested_packed_event_nba_w8_outside_parent](../tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_outside_parent.sv)（主観測・新規）。
  8/65ビットの親選択と子選択を捕捉し、親の範囲外にある子ビットは更新しないこと。条項: 10.4.2、9.4.5、13.5.2、11.5.1、7.4.5、4.4.2.3、4.4.2.4。
- [test_gen_ref_static_nested_packed_event_nba_w8_valid](../tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_valid.sv)（主観測・新規）。
  8/65ビットの親選択と子選択を捕捉し、親の範囲外にある子ビットは更新しないこと。条項: 10.4.2、9.4.5、13.5.2、11.5.1、7.4.5、4.4.2.3、4.4.2.4。

- 範囲・制限: 静的な範囲外選択には診断が許されます。正しい範囲外処理を単純なコンパイル拒否テストへ置換しません。

## N04：stringの文字選択と遅延NBA

文字添字と右辺を予約時に評価し、更新までに添字・右辺・隣接文字を変更します。

- [test_gen_string_character_delayed_nba_index1](../tests/gen/ch10/test_gen_string_character_delayed_nba_index1.sv)（主観測・新規）。
  予約時の文字位置へ捕捉したバイトだけを書き込み、隣接文字への別の更新を保持すること。条項: 10.4.2、9.4.5、6.16、6.16.1、4.4.2.2、4.4.2.4。
- [test_gen_string_character_delayed_nba_index3](../tests/gen/ch10/test_gen_string_character_delayed_nba_index3.sv)（主観測・新規）。
  予約時の文字位置へ捕捉したバイトだけを書き込み、隣接文字への別の更新を保持すること。条項: 10.4.2、9.4.5、6.16、6.16.1、4.4.2.2、4.4.2.4。

- 範囲・制限: 予約中に文字列全体を短縮・置換する場合の意味は本項目から分離します。文字列長は固定です。

## A01：unpacked structと書込み可能なref

13.5.2に従う等価型のstructを自動taskへrefで渡し、コピー戻しと異なる即時反映を観測します。

- [test_gen_combo_struct_ref_immediate_and_return](../tests/gen/ch13/test_gen_combo_struct_ref_immediate_and_return.sv)（主観測・新規）。
  task復帰前の呼出し元観測でもメンバ更新が見え、遅延後の更新と再呼出し後の保護値が正しいこと。条項: 13.5.2、7.2、6.21、9.4.1。

- 範囲・制限: 実引数は静的寿命です。const refへの書込みは行いません。

## A02：struct配列とautomatic・inputコピー

自動task内のstruct配列と、配列inputの値渡しを別々に確認します。

- [test_gen_combo_struct_array_input_copy_ascending](../tests/gen/ch13/test_gen_combo_struct_array_input_copy_ascending.sv)（主観測・新規）。
  呼出しごとの初期化と独立性、昇順/降順配列のinputコピー、呼出し元変更との分離。条項: 13.5.1、7.6、7.2。
- [test_gen_combo_struct_array_input_copy_descending](../tests/gen/ch13/test_gen_combo_struct_array_input_copy_descending.sv)（主観測・新規）。
  呼出しごとの初期化と独立性、昇順/降順配列のinputコピー、呼出し元変更との分離。条項: 13.5.1、7.6、7.2。
- [test_gen_combo_struct_array_automatic_elements](../tests/gen/ch6/test_gen_combo_struct_array_automatic_elements.sv)（主観測・新規）。
  呼出しごとの初期化と独立性、昇順/降順配列のinputコピー、呼出し元変更との分離。条項: 6.21、7.2、7.4.2、9.3.2、9.4.1。

- 範囲・制限: inputコピーとrefの別名参照を混同しません。

## A03：structの固定配列メンバとautomatic

自動変数としてのstructに固定配列メンバを持たせ、複数呼出しで値と時刻を観測します。

- [test_gen_combo_struct_array_automatic_member](../tests/gen/ch6/test_gen_combo_struct_array_automatic_member.sv)（主観測・新規）。
  各呼出しのメンバ配列の独立性、task実行中の値、呼出し元の保護値。条項: 6.21、7.2、7.4.2、9.3.2、9.4.1。

- 範囲・制限: 構造体メンバの実メモリ配置やGC回収量は観測しません。

## A04：固定配列スライスとoutput/inoutコピー戻し

13.5.1のoutput/inout値渡しと復帰時コピー戻しを、昇順/降順の固定配列スライスに適用します。

- [test_gen_fixed_array_slice_inout_copyback_ascending](../tests/gen/ch13/test_gen_fixed_array_slice_inout_copyback_ascending.sv)（主観測・新規）。
  task実行中は呼出し元を保ち、復帰時に指定スライスだけ更新し、外側の要素は保持すること。条項: 13.5、13.5.1、7.4.6、7.6。
- [test_gen_fixed_array_slice_inout_copyback_descending](../tests/gen/ch13/test_gen_fixed_array_slice_inout_copyback_descending.sv)（主観測・新規）。
  task実行中は呼出し元を保ち、復帰時に指定スライスだけ更新し、外側の要素は保持すること。条項: 13.5、13.5.1、7.4.6、7.6。
- [test_gen_fixed_array_slice_output_copyback_ascending](../tests/gen/ch13/test_gen_fixed_array_slice_output_copyback_ascending.sv)（主観測・新規）。
  task実行中は呼出し元を保ち、復帰時に指定スライスだけ更新し、外側の要素は保持すること。条項: 13.5、13.5.1、7.4.6、7.6。
- [test_gen_fixed_array_slice_output_copyback_descending](../tests/gen/ch13/test_gen_fixed_array_slice_output_copyback_descending.sv)（主観測・新規）。
  task実行中は呼出し元を保ち、復帰時に指定スライスだけ更新し、外側の要素は保持すること。条項: 13.5、13.5.1、7.4.6、7.6。

- 範囲・制限: スライスの境界は定数です。task実行中に実引数を別プロセスで変更しません。

## S01：実行時packed親選択と子選択

33ビット×2要素のpacked配列を用い、親/子添字方向、2/4状態、blocking/NBAを交差させます。

- [test_gen_combo_packed_parent_runtime_aa_bit_nba](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_aa_bit_nba.sv)（主観測・新規）。
  実行時に選ぶ親・子位置の書込み、範囲外読出しと無効書込み、隣接ビットの保持。条項: 11.5.1、7.4.1、7.4.5、10.4.2。
- [test_gen_combo_packed_parent_runtime_aa_logic_blocking](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_aa_logic_blocking.sv)（主観測・新規）。
  実行時に選ぶ親・子位置の書込み、範囲外読出しと無効書込み、隣接ビットの保持。条項: 11.5.1、7.4.1、7.4.5、10.4.1。
- [test_gen_combo_packed_parent_runtime_ad_bit_blocking](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_ad_bit_blocking.sv)（主観測・新規）。
  実行時に選ぶ親・子位置の書込み、範囲外読出しと無効書込み、隣接ビットの保持。条項: 11.5.1、7.4.1、7.4.5、10.4.1。
- [test_gen_combo_packed_parent_runtime_ad_logic_nba](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_ad_logic_nba.sv)（主観測・新規）。
  実行時に選ぶ親・子位置の書込み、範囲外読出しと無効書込み、隣接ビットの保持。条項: 11.5.1、7.4.1、7.4.5、10.4.2。
- [test_gen_combo_packed_parent_runtime_da_bit_blocking](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_da_bit_blocking.sv)（主観測・新規）。
  実行時に選ぶ親・子位置の書込み、範囲外読出しと無効書込み、隣接ビットの保持。条項: 11.5.1、7.4.1、7.4.5、10.4.1。
- [test_gen_combo_packed_parent_runtime_da_logic_nba](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_da_logic_nba.sv)（主観測・新規）。
  実行時に選ぶ親・子位置の書込み、範囲外読出しと無効書込み、隣接ビットの保持。条項: 11.5.1、7.4.1、7.4.5、10.4.2。
- [test_gen_combo_packed_parent_runtime_dd_bit_nba](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_dd_bit_nba.sv)（主観測・新規）。
  実行時に選ぶ親・子位置の書込み、範囲外読出しと無効書込み、隣接ビットの保持。条項: 11.5.1、7.4.1、7.4.5、10.4.2。
- [test_gen_combo_packed_parent_runtime_dd_logic_blocking](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_dd_logic_blocking.sv)（主観測・新規）。
  実行時に選ぶ親・子位置の書込み、範囲外読出しと無効書込み、隣接ビットの保持。条項: 11.5.1、7.4.1、7.4.5、10.4.1。
- [test_packed_array_bitsel_write](../tests/ch7/test_packed_array_bitsel_write.sv)（対照・既存再利用）。
  固定packed配列の要素書込みと範囲外の対照。条項: 7.4.1、7.4.5、11.5.1、10.4.2。

- 範囲・制限: 8件は親方向×子方向×状態の全組合せと代入方式との全ペアを含みます。全4因子組合せや登録済みt-wayモデルの網羅率は主張しません。

## S02：streamingのwith・string左辺・入れ子左辺

with範囲指定は既存2件を再利用します。string左辺の長さ決定と入れ子streaming左辺の並びを追加します。

- [test_gen_combo_stream_nested_target_ll](../tests/gen/ch11/test_gen_combo_stream_nested_target_ll.sv)（主観測・新規）。
  with範囲の要素選択と部分書込み、string長と文字列値、左右streamingを重ねた際のバイト順。条項: 11.4.14.3、11.4.14.2、11.4.14。
- [test_gen_combo_stream_nested_target_lr](../tests/gen/ch11/test_gen_combo_stream_nested_target_lr.sv)（主観測・新規）。
  with範囲の要素選択と部分書込み、string長と文字列値、左右streamingを重ねた際のバイト順。条項: 11.4.14.3、11.4.14.2、11.4.14。
- [test_gen_combo_stream_nested_target_rl](../tests/gen/ch11/test_gen_combo_stream_nested_target_rl.sv)（主観測・新規）。
  with範囲の要素選択と部分書込み、string長と文字列値、左右streamingを重ねた際のバイト順。条項: 11.4.14.3、11.4.14.2、11.4.14。
- [test_gen_combo_stream_nested_target_rr](../tests/gen/ch11/test_gen_combo_stream_nested_target_rr.sv)（主観測・新規）。
  with範囲の要素選択と部分書込み、string長と文字列値、左右streamingを重ねた際のバイト順。条項: 11.4.14.3、11.4.14.2、11.4.14。
- [test_gen_combo_stream_string_target_resize](../tests/gen/ch11/test_gen_combo_stream_string_target_resize.sv)（主観測・新規）。
  with範囲の要素選択と部分書込み、string長と文字列値、左右streamingを重ねた際のバイト順。条項: 11.4.14.3、11.4.14.4、6.24.3。
- [test_stream_expression_with_range_forms](../tests/ch11/test_stream_expression_with_range_forms.sv)（主観測・既存再利用）。
  既存のstreaming with範囲とサイズ・部分更新の観測。条項: 11.4.14.4、11.4.14、11.4.14.2、11.4.14.3、A.8.1。
- [test_stream_with_range_extent_timing_and_partial](../tests/ch11/test_stream_with_range_extent_timing_and_partial.sv)（主観測・既存再利用）。
  既存のstreaming with範囲とサイズ・部分更新の観測。条項: 11.4.14.4。

- 範囲・制限: 期待値はバイトの置換を独立計算し、処理系の出力から転記しません。

## F01：freadと動的配列・structメンバ・多次元メモリ

21.3.4.4のバイト単位の読込みとメンバ順序を、ファイルの残りバイトと更新対象外の値も含めて確認します。

- [test_gen_comb_fread_dynamic_selection](../tests/gen/ch21/test_gen_comb_fread_dynamic_selection.sv)（主観測・新規）。
  動的配列のstart/count、struct配列のメンバ順、2次元の全4要素と読込バイト数、末尾センチネル。条項: 21.3.4.4、21.3.1、21.3.2。
- [test_gen_comb_fread_struct_array_member](../tests/gen/ch21/test_gen_comb_fread_struct_array_member.sv)（主観測・新規）。
  動的配列のstart/count、struct配列のメンバ順、2次元の全4要素と読込バイト数、末尾センチネル。条項: 21.3.4.4、21.3.1、21.3.2。
- [test_gen_comb_fread_struct_multidimensional](../tests/gen/ch21/test_gen_comb_fread_struct_multidimensional.sv)（主観測・新規）。
  動的配列のstart/count、struct配列のメンバ順、2次元の全4要素と読込バイト数、末尾センチネル。条項: 21.3.4.4、21.3.1、21.3.2。
- [test_fread_unpacked_struct_union](../tests/ch21/test_fread_unpacked_struct_union.sv)（対照・既存再利用）。
  既存の固定メモリ・struct読込み、部分語とEOFの対照。条項: 21.3.4.4。
- [test_fread_partial_word_and_eof](../tests/ch21/test_fread_partial_word_and_eof.sv)（対照・既存再利用）。
  既存の固定メモリ・struct読込み、部分語とEOFの対照。条項: 21.3.4.4。

- 範囲・制限: realメンバの外部バイト表現は規格から確定できず保留です。多次元間の走査順は同一の2バイト組を反復して期待値から切り離します。

## F02：VCDのprogram/interface階層と変数

21.7.1.2の引数なしdumpvarsと明示変数指定を使います。program内の変数はprogram内部から指定し、24.3の外部参照禁止を守ります。

- [test_gen_comb_vcd_program_interface_all_model](../tests/gen/ch21/test_gen_comb_vcd_program_interface_all_model.sv)（主観測・新規）。
  生成VCDを再読込みし、module/interface/programのscope、1ビット変数名、scope終端の対応、enddefinitionsを検査。条項: 21.7.1.2、21.7.1.6、21.7.2.1、21.7.2.3、21.7.5。
- [test_gen_comb_vcd_program_interface_explicit](../tests/gen/ch21/test_gen_comb_vcd_program_interface_explicit.sv)（主観測・新規）。
  生成VCDを再読込みし、module/interface/programのscope、1ビット変数名、scope終端の対応、enddefinitionsを検査。条項: 21.7.1.2、21.7.1.6、21.7.2.1、21.7.2.3、21.7.5。
- [test_vcd_dump_readback](../tests/ch21/test_vcd_dump_readback.sv)（対照・既存再利用）。
  既存のmoduleと信号のVCD成果物検査。条項: 21.7.1.1、21.7.1.2、21.7.1.3、21.7.1.4、21.7.1.6、21.7.2.1、21.7.2.2、21.7.2.3、21.7.5。

- 範囲・制限: 日時、version、識別子コード、scope種別表記などは固定しません。dumpvars(0,dut)でのprogram/interface再帰包含の義務は未確定で、元の欠落観測と分離します。

## H01：動的コンテナと暗黙の感度

queue/動的配列とalways_comb、always @*、連続代入、always_latchを交差させます。連続代入は20.7の$sizeだけを参照します。

- [test_gen_comb_heap_sensitivity_dynamic_continuous](../tests/gen/ch10/test_gen_comb_heap_sensitivity_dynamic_continuous.sv)（主観測・新規）。
  サイズ変更、選択要素と非選択要素の更新、コンテナ置換・空化、enableとlatch保持の段階的な値。条項: 10.3.2、20.7、7.5.1。
- [test_gen_comb_heap_sensitivity_queue_continuous](../tests/gen/ch10/test_gen_comb_heap_sensitivity_queue_continuous.sv)（主観測・新規）。
  サイズ変更、選択要素と非選択要素の更新、コンテナ置換・空化、enableとlatch保持の段階的な値。条項: 10.3.2、20.7、7.10。
- [test_gen_comb_heap_sensitivity_dynamic_comb](../tests/gen/ch9/test_gen_comb_heap_sensitivity_dynamic_comb.sv)（主観測・新規）。
  サイズ変更、選択要素と非選択要素の更新、コンテナ置換・空化、enableとlatch保持の段階的な値。条項: 9.2.2.2.1、9.2.2.2、7.5.1。
- [test_gen_comb_heap_sensitivity_dynamic_latch](../tests/gen/ch9/test_gen_comb_heap_sensitivity_dynamic_latch.sv)（主観測・新規）。
  サイズ変更、選択要素と非選択要素の更新、コンテナ置換・空化、enableとlatch保持の段階的な値。条項: 9.2.2.3、9.2.2.2.1、7.5.1。
- [test_gen_comb_heap_sensitivity_dynamic_star](../tests/gen/ch9/test_gen_comb_heap_sensitivity_dynamic_star.sv)（主観測・新規）。
  サイズ変更、選択要素と非選択要素の更新、コンテナ置換・空化、enableとlatch保持の段階的な値。条項: 9.4.2.2、7.5.1。
- [test_gen_comb_heap_sensitivity_queue_comb](../tests/gen/ch9/test_gen_comb_heap_sensitivity_queue_comb.sv)（主観測・新規）。
  サイズ変更、選択要素と非選択要素の更新、コンテナ置換・空化、enableとlatch保持の段階的な値。条項: 9.2.2.2.1、9.2.2.2、7.10。
- [test_gen_comb_heap_sensitivity_queue_latch](../tests/gen/ch9/test_gen_comb_heap_sensitivity_queue_latch.sv)（主観測・新規）。
  サイズ変更、選択要素と非選択要素の更新、コンテナ置換・空化、enableとlatch保持の段階的な値。条項: 9.2.2.3、9.2.2.2.1、7.10。
- [test_gen_comb_heap_sensitivity_queue_star](../tests/gen/ch9/test_gen_comb_heap_sensitivity_queue_star.sv)（主観測・新規）。
  サイズ変更、選択要素と非選択要素の更新、コンテナ置換・空化、enableとlatch保持の段階的な値。条項: 9.4.2.2、7.10。
- [test_always_comb_vs_always_star](../tests/ch9/test_always_comb_vs_always_star.sv)（対照・既存再利用）。
  静的変数のalways_combとalways @*の対照。条項: 9.2.2.2.2、9.2.2.2.1、9.4.2.2。

- 範囲・制限: 6.21により手続き外の動的要素参照を避けます。連続代入では要素値への感度を主張しません。@*開始時の無条件実行にも依存しません。

## U01：heap値のfile monitorと登録元の記述位置

静的寿命のqueue/動的配列を、9種類の記述位置からMCD/FDへ監視登録します。36通りから18件を選び40ペアと3必須条件を含めます。

- [test_gen_comb_file_monitor_dynamic_fd_always](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_always.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.5.1。
- [test_gen_comb_file_monitor_dynamic_fd_fork](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_fork.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.5.1。
- [test_gen_comb_file_monitor_dynamic_fd_function](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_function.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.5.1。
- [test_gen_comb_file_monitor_dynamic_fd_generate](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_generate.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.5.1。
- [test_gen_comb_file_monitor_dynamic_fd_initial](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_initial.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.5.1。
- [test_gen_comb_file_monitor_dynamic_fd_interface](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_interface.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.5.1。
- [test_gen_comb_file_monitor_dynamic_fd_task](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_task.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.5.1。
- [test_gen_comb_file_monitor_dynamic_mcd_package](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_mcd_package.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.5.1。
- [test_gen_comb_file_monitor_dynamic_mcd_program](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_mcd_program.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.5.1。
- [test_gen_comb_file_monitor_queue_fd_package](../tests/gen/ch21/test_gen_comb_file_monitor_queue_fd_package.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.10。
- [test_gen_comb_file_monitor_queue_fd_program](../tests/gen/ch21/test_gen_comb_file_monitor_queue_fd_program.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.10。
- [test_gen_comb_file_monitor_queue_mcd_always](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_always.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.10。
- [test_gen_comb_file_monitor_queue_mcd_fork](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_fork.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.10。
- [test_gen_comb_file_monitor_queue_mcd_function](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_function.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.10。
- [test_gen_comb_file_monitor_queue_mcd_generate](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_generate.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.10。
- [test_gen_comb_file_monitor_queue_mcd_initial](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_initial.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.10。
- [test_gen_comb_file_monitor_queue_mcd_interface](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_interface.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.10。
- [test_gen_comb_file_monitor_queue_mcd_task](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_task.sv)（主観測・新規）。
  Postponedでの同時刻更新の集約、非選択要素と選択変更、コンテナ置換、monitoroff、close後の出力停止と再open先への漏出防止。条項: 21.3.2、21.2.3、21.3.1、21.3.4.2、4.4.2.9、7.10。
- [test_file_fmonitor_fstrobe](../tests/ch21/test_file_fmonitor_fstrobe.sv)（対照・既存再利用）。
  静的変数のfile monitor、記述子の寿命、closeと再利用の対照。条項: 21.3.2、21.2.2、21.2.3、21.3.1、21.3.4.2。
- [test_fclose_cancels_fmonitor_fstrobe](../tests/ch21/test_fclose_cancels_fmonitor_fstrobe.sv)（対照・既存再利用）。
  静的変数のfile monitor、記述子の寿命、closeと再利用の対照。条項: 21.3.1、21.3.2、21.3.4.2。
- [test_file_close_fd](../tests/imported/ch21/test_file_close_fd.sv)（対照・既存再利用）。
  静的変数のfile monitor、記述子の寿命、closeと再利用の対照。条項: 21.3.1、21.3.2、21.3.4.2。
- [test_file_output_initial](../tests/imported/ch21/test_file_output_initial.sv)（対照・既存再利用）。
  静的変数のfile monitor、記述子の寿命、closeと再利用の対照。条項: 21.3.1、21.3.2、21.3.4.2。

- 範囲・制限: 選択対象は登録元9種類×コンテナ2種類×記述子2種類だけです。全36個の3因子組合せや全ての構文を網羅しません。
- 範囲・制限: closeの結果は出力不在で観測します。内部GCルートの除去や実メモリの解放は確認しません。
- 範囲・制限: ネイティブcallback実行中の登録・再確保は別のAPI試験範囲で未確認です。副作用付きSV関数を無条件に同等とみなしません。

## 分離した解釈・API範囲

- automatic_nba_illegal_control：不正記述を既存テストで再利用。10.4.2および13.3.2により自動変数へのNBAは不可。N01の合法なref staticと混同しません。
- strobe_auto：解釈保留。13.3.2の自動変数のtracing禁止にstrobeが含まれるか、個別に確認する必要があります。元のフロントエンド拒否だけで違法とは断定しません。
- packed_parent_constant_oob：合法な範囲外操作・診断は許容。11.5.1の範囲外読出し/無効書込みを確認します。診断の存在だけで違法とは分類しません。
- fread_real_member：期待値の解釈保留。21.3.4.4からrealメンバの外部バイト符号化を確定できません。未対応や違法へ読み替えず、正の期待値を捏造しません。
- vcd_recursive_program_interface：元の観測と規格上の義務を分離。dumpvars(0,dut)でmoduleだけ出力した元の結果は残します。program/interfaceを子moduleと同等に含む義務は未確定です。全変数または明示変数指定の合法な回帰を追加しました。
- program_external_variable_reference：24.3による禁止を回避。program変数をmoduleから階層参照せず、program内部からdumpvarsを呼びます。#0で同時刻のdumpfile設定との順序も確保します。
- continuous_dynamic_element：6.21による手続き外参照の禁止を回避。手続き外で動的要素を選択せず$sizeを用います。手続き内の感度テストでは要素とサイズを観測します。
- native_callback_reentry：別API範囲・未確認。4.4.2.9のPostponed制約と監視引数の評価を考慮すると、任意のネイティブcallback内の登録再入とSVの副作用関数は同等とはいえません。dispatch中の登録解除・再確保・GCルート保持をネイティブAPIで検証する課題として残します。

## 現在の入力に対応する実行証跡

### coverage/combination-results/issue21-icarus-13.json

- 版: Icarus Verilog version 13.0 (stable) (v13_0-dirty)。
- 実行日時: 2026-10-30T00:40:13.297515+00:00。
- 対象全件: pass=11, fail=0, known=77, unsupported=0, stale=0, not_run=0。
- E01: 主観測に未達あり。known=2。
- E02: 主観測に未達あり。known=2。
- E03: 主観測すべて合格。pass=1。
- E04: 主観測に未達あり。known=2。
- E05: 主観測に未達あり。known=2。
- E06: 主観測すべて合格。pass=2。
- N01: 主観測に未達あり。known=2。
- N02: 主観測に未達あり。known=4。
- N03: 主観測に未達あり。known=4。
- N04: 主観測に未達あり。known=2。
- A01: 主観測に未達あり。known=1。
- A02: 主観測に未達あり。known=3。
- A03: 主観測に未達あり。known=1。
- A04: 主観測に未達あり。known=4。
- S01: 主観測に未達あり。known=8。
- S02: 主観測に未達あり。known=7。
- F01: 主観測に未達あり。known=3。
- F02: 主観測すべて合格。pass=2。
- H01: 主観測に未達あり。known=8。
- U01: 主観測に未達あり。known=18。

### coverage/combination-results/issue21-kirimasim-latest.json

- 版: kirimasim 0.0.0 (commit 1ca363e2c922), built with AppleClang 21.0.0.21000334。
- 実行日時: 2026-10-30T00:41:13.175003+00:00。
- 対象全件: pass=26, fail=3, known=0, unsupported=59, stale=0, not_run=0。
- E01: 主観測に未達あり。unsupported=2。
- E02: 主観測に未達あり。unsupported=2。
- E03: 主観測に未達あり。unsupported=1。
- E04: 主観測に未達あり。unsupported=2。
- E05: 主観測に未達あり。unsupported=2。
- E06: 主観測に未達あり。unsupported=2。
- N01: 主観測に未達あり。unsupported=2。
- N02: 主観測に未達あり。unsupported=4。
- N03: 主観測に未達あり。unsupported=4。
- N04: 主観測に未達あり。unsupported=2。
- A01: 主観測に未達あり。unsupported=1。
- A02: 主観測に未達あり。unsupported=3。
- A03: 主観測に未達あり。unsupported=1。
- A04: 主観測に未達あり。unsupported=4。
- S01: 主観測に未達あり。unsupported=8。
- S02: 主観測に未達あり。unsupported=7。
- F01: 主観測に未達あり。unsupported=3。
- F02: 主観測に未達あり。fail=2。
- H01: 主観測に未達あり。unsupported=8。
- U01: 主観測すべて合格。pass=18。

### coverage/combination-results/issue21-verilator-5.052-seed1.json

- 版: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905。
- 実行日時: 2026-10-30T00:40:20.650747+00:00。
- 対象全件: pass=27, fail=0, known=50, unsupported=0, stale=0, not_run=11。
- E01: 主観測に未達あり。known=2。
- E02: 主観測に未達あり。known=2。
- E03: 主観測すべて合格。pass=1。
- E04: 主観測に未達あり。known=2。
- E05: 主観測に未達あり。known=2。
- E06: 主観測すべて合格。pass=2。
- N01: 主観測に未達あり。known=1, not_run=1。
- N02: 主観測に未達あり。known=2, not_run=2。
- N03: 主観測に未達あり。known=3, not_run=1。
- N04: 主観測に未達あり。known=2。
- A01: 主観測すべて合格。pass=1。
- A02: 主観測すべて合格。pass=3。
- A03: 主観測すべて合格。pass=1。
- A04: 主観測すべて合格。pass=4。
- S01: 主観測に未達あり。known=4, not_run=4。
- S02: 主観測に未達あり。pass=4, known=2, not_run=1。
- F01: 主観測に未達あり。known=3。
- F02: 主観測に未達あり。known=2。
- H01: 主観測すべて合格。pass=8。
- U01: 主観測に未達あり。known=18。

### coverage/combination-results/issue21-verilator-5.052-seed73.json

- 版: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905。
- 実行日時: 2026-10-30T00:40:24.278982+00:00。
- 対象全件: pass=27, fail=0, known=50, unsupported=0, stale=0, not_run=11。
- E01: 主観測に未達あり。known=2。
- E02: 主観測に未達あり。known=2。
- E03: 主観測すべて合格。pass=1。
- E04: 主観測に未達あり。known=2。
- E05: 主観測に未達あり。known=2。
- E06: 主観測すべて合格。pass=2。
- N01: 主観測に未達あり。known=1, not_run=1。
- N02: 主観測に未達あり。known=2, not_run=2。
- N03: 主観測に未達あり。known=3, not_run=1。
- N04: 主観測に未達あり。known=2。
- A01: 主観測すべて合格。pass=1。
- A02: 主観測すべて合格。pass=3。
- A03: 主観測すべて合格。pass=1。
- A04: 主観測すべて合格。pass=4。
- S01: 主観測に未達あり。known=4, not_run=4。
- S02: 主観測に未達あり。pass=4, known=2, not_run=1。
- F01: 主観測に未達あり。known=3。
- F02: 主観測に未達あり。known=2。
- H01: 主観測すべて合格。pass=8。
- U01: 主観測に未達あり。known=18。

## 再実行と更新

台帳の指紋は自動で更新しません。刺激・観測・規格根拠を再確認してから変更してください。
`--check`は台帳とレポートの整合性検査で、実装の全件合格を要求しません。

```sh
python3 tools/combination_gaps.py --list-tests
python3 tools/combination_gaps.py --update
python3 tools/combination_gaps.py --check
```

`--list-tests`の出力を既存ランナーのテスト引数へ渡し、`--json`で新しい結果を
`coverage/combination-results/`へ保存してからレポートを更新します。
kirimasimは実行直前の上流コミットを確認し、その版からビルドしてください。
