# 機能間クロスの計画と実行確認

このレポートは登録した有限モデルだけを対象にします。要求カバレッジや全言語の
組合せ網羅率ではありません。計画上の網羅と、実行結果に基づく合格確認を分けます。
既存テストは削減していません。選択数の削減率は実行時間の削減率ではありません。

生成元・利用手順・適用限界は[導入手順](interaction-verification.md)を参照してください。

## scheduling_visibility / model 1

- 制約を満たす組合せ数: 325。
- 利用できる既存・新規テスト: 325。
- 短時間実行の選択: 51。
- 個別に保持する必須ケース: 0。
- 2因子の計画上の網羅: 126/126。
- 3因子の計画上の網羅: 51/51。

既存の8ビットの書き込みを、書き込み元・待機中の別プロセス・strobe・monitorから指定の時刻とイベント領域で観測する。既存の生成テストと期待値は変更しない。

- writer: blocking, nba, nbadelay, assign, force。
- reader: same, wait, strobe, monitor。
- home: initial, always, task, function, fork, interface, generate。
- delay: nodelay, delay0, delay1。

制約: 既存のscheduling.allowedに従い、観測結果が定まらない組合せや関数内の遅延付きNBAなどを除外。シミュレータの未対応による除外はしない

## nba_capture / model 1

- 制約を満たす組合せ数: 432。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 3。
- 2因子の計画上の網羅: 162/162。
- 3因子の計画上の網羅: 44/44。

代入直後・刺激変更後・時刻1・最終結果の出力で、値と代入先の確定、隣接要素の保持、Active領域とNBA領域の順序、automaticタスクからの復帰後の更新を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- storage: scalar, array。
- direction: none, ascending, descending。
- home: initial, task。
- timing: immediate, delayed。

制約: スカラの添字方向は非該当。配列では昇順または降順を選ぶ

## expression_context / model 1

- 制約を満たす組合せ数: 588。
- 利用できる既存・新規テスト: 51。
- 短時間実行の選択: 51。
- 個別に保持する必須ケース: 3。
- 2因子の計画上の網羅: 143/143。
- 3因子の計画上の網羅: 63/63。

4組の入力で加減乗算の結果を確認する。演算前の符号・ゼロ拡張、代入先からの幅の伝播、キャリー、最終的な切り捨てを組み合わせる。

- width: 1, 32, 33, 64, 65, 129。
- rhs_width: narrow, same, wide。
- result_width: narrow, same, wide。
- sign_a: unsigned, signed。
- sign_b: unsigned, signed。
- operator: add, sub, mul。

制約: 幅1に対するnarrowは幅0になるため除外。幅の差は1ビット

## packed_part_select / model 1

- 制約を満たす組合せ数: 744。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 3。
- 2因子の計画上の網羅: 162/162。
- 3因子の計画上の網羅: 48/48。

部分選択への書き込み前後にベクタ全体と選択範囲を表示し、添字方向・選択方向・X/Z変換に加え、選択していないビットの保持も確認する。

- width: 1, 32, 33, 64, 65, 129。
- direction: ascending, descending。
- select: plus, minus。
- span: single, half。
- position: low, high, interior。
- state: bit, logic。
- value: known, x, z。

制約: 幅0の選択を除外。high/interiorがlowと同じ位置になる組合せを除外。選択範囲はベクタ内。添字の下限は4

## conditional_merge / model 1

- 制約を満たす組合せ数: 1408。
- 利用できる既存・新規テスト: 32。
- 短時間実行の選択: 32。
- 個別に保持する必須ケース: 3。
- 2因子の計画上の網羅: 185/185。
- 3因子の計画上の網羅: 76/76。

両分岐の入力と条件演算の結果を表示し、分岐選択・X/Zのビットごとの結合・符号拡張・代入先の幅と2状態変換を一連の式で確認する。

- width: 1, 33, 65, 129。
- sign_a: unsigned, signed。
- sign_b: unsigned, signed。
- condition: 0, 1, x, z。
- pattern: equal, opposite, same_xz, mixed_xz。
- result_width: narrow, same, wide。
- state: bit, logic。

制約: 幅1のnarrowは幅0になるため除外。両分岐の元の幅は同じで、代入先の幅だけを1ビット増減。条件は1ビット

## shift_context / model 1

- 制約を満たす組合せ数: 5520。
- 利用できる既存・新規テスト: 56。
- 短時間実行の選択: 56。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 298/298。
- 3因子の計画上の網羅: 92/92。

シフト前の値・シフト量・結果を表示し、代入先から伝わる幅、符号付きの埋め込み、X/Zの移動、未知のシフト量、最後の2状態変換を確認する。

- width: 1, 32, 33, 64, 65, 129。
- sign: unsigned, signed。
- operator: shl, shr, ashl, ashr。
- count: zero, one, last, width, beyond, x, z。
- value: known, x, z。
- result_width: narrow, same, wide。
- state: bit, logic。

制約: 幅1のnarrowは幅0のため除外。幅1で数値が重複するone/lastはwidth/zeroへ統合。countのwidth/last/beyondは元の左オペランド幅を基準とする

## cast_pipeline / model 1

- 制約を満たす組合せ数: 1512。
- 利用できる既存・新規テスト: 32。
- 短時間実行の選択: 32。
- 個別に保持する必須ケース: 3。
- 2因子の計画上の網羅: 214/214。
- 3因子の計画上の網羅: 76/76。

元の値・キャスト直後の値・後続演算の結果を分けて表示し、キャストの幅と符号、演算前のX/Z変換、外側の代入コンテキストと最終変換の順序を確認する。

- width: 1, 32, 33, 64, 65, 129。
- sign: unsigned, signed。
- value: known, x, z。
- cast: size, signed, unsigned, typed_bit, typed_logic。
- cast_width: narrow, same, wide。
- operation: plain, add。
- state: bit, logic。

制約: signing castは幅を変えないのでcast_width=same。幅1のnarrowは除外。代入先は元の幅+2。typed castの型はunsigned

## task_argument_visibility / model 1

- 制約を満たす組合せ数: 576。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 3。
- 2因子の計画上の網羅: 144/144。
- 3因子の計画上の網羅: 52/52。

タスク内部・復帰直前・復帰後から実引数を観測し、コピー渡しと参照渡しの更新時点の違い、値と隣接要素の保持を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- mode: input, output, inout, ref。
- storage: scalar, element。
- timing: immediate, delayed。

制約: 全行でautomaticタスクを使い、実引数と仮引数の型を同じtypedefにする。配列は[2:3]の固定長。呼出し中に実引数の添字は変更しない

## 入力指紋が一致した実行の確認

各スナップショットを独立に評価します。複数の版・実行の部分成功を合成しません。
passだけを合格の証跡とし、known・unsupported・staleを合格へ含めません。
この集計は期待値との一致を確認した組合せの割合です。失敗実行からの生の到達率は未計測です。

### coverage/interaction-results/cross-20261029-expanded-icarus13.json

- 環境: Icarus Verilog version 13.0 (stable) (v13_0-dirty)。
- 実行日時: 2026-10-29T12:33:28.581713+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 126/126。
  - 3因子の合格確認済み組合せ: 51/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 44/44。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- expression_context:
  - 2因子の合格確認済み組合せ: 143/143。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 3/3。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 48/48。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 182/185。
  - 3因子の合格確認済み組合せ: 71/76。
  - 必須ケース: 2/3。
  - ケース状態: pass=30, fail=0, known=2, unsupported=0, stale=0, not_run=0。
- shift_context:
  - 2因子の合格確認済み組合せ: 0/298。
  - 3因子の合格確認済み組合せ: 0/92。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=56。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 0/214。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 0/144。
  - 3因子の合格確認済み組合せ: 0/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。

### coverage/interaction-results/cross-20261029-expanded-kirimasim-f8408ea.json

- 環境: kirimasim 0.0.0 (commit f8408ea37ac1), built with AppleClang 21.0.0.21000334。
- 実行日時: 2026-10-29T12:33:29.639908+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 126/126。
  - 3因子の合格確認済み組合せ: 51/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 44/44。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- expression_context:
  - 2因子の合格確認済み組合せ: 143/143。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 3/3。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 48/48。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 185/185。
  - 3因子の合格確認済み組合せ: 76/76。
  - 必須ケース: 3/3。
  - ケース状態: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- shift_context:
  - 2因子の合格確認済み組合せ: 0/298。
  - 3因子の合格確認済み組合せ: 0/92。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=56。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 0/214。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 0/144。
  - 3因子の合格確認済み組合せ: 0/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。

### coverage/interaction-results/cross-20261029-expanded-verilator5052-seed1.json

- 環境: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905。
- 実行日時: 2026-10-29T12:30:27.749600+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 119/126。
  - 3因子の合格確認済み組合せ: 43/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=43, fail=0, known=8, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 98/162。
  - 3因子の合格確認済み組合せ: 17/44。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- expression_context:
  - 2因子の合格確認済み組合せ: 143/143。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 3/3。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 100/162。
  - 3因子の合格確認済み組合せ: 18/48。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 93/185。
  - 3因子の合格確認済み組合せ: 22/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=8, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- shift_context:
  - 2因子の合格確認済み組合せ: 0/298。
  - 3因子の合格確認済み組合せ: 0/92。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=56。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 0/214。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 0/144。
  - 3因子の合格確認済み組合せ: 0/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。

### coverage/interaction-results/cross-20261029-expanded-verilator5052-seed73.json

- 環境: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905。
- 実行日時: 2026-10-29T12:30:39.015433+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 119/126。
  - 3因子の合格確認済み組合せ: 43/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=43, fail=0, known=8, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 98/162。
  - 3因子の合格確認済み組合せ: 17/44。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- expression_context:
  - 2因子の合格確認済み組合せ: 143/143。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 3/3。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 100/162。
  - 3因子の合格確認済み組合せ: 18/48。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 93/185。
  - 3因子の合格確認済み組合せ: 22/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=8, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- shift_context:
  - 2因子の合格確認済み組合せ: 0/298。
  - 3因子の合格確認済み組合せ: 0/92。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=56。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 0/214。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 0/144。
  - 3因子の合格確認済み組合せ: 0/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。

### coverage/interaction-results/cross-20261029-icarus13.json

- 環境: Icarus Verilog version 13.0 (stable) (v13_0-dirty)。
- 実行日時: 2026-10-29T09:54:52.354221+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 126/126。
  - 3因子の合格確認済み組合せ: 51/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 44/44。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- expression_context:
  - 2因子の合格確認済み組合せ: 0/143。
  - 3因子の合格確認済み組合せ: 0/63。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=51。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 0/162。
  - 3因子の合格確認済み組合せ: 0/48。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 0/185。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- shift_context:
  - 2因子の合格確認済み組合せ: 0/298。
  - 3因子の合格確認済み組合せ: 0/92。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=56。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 0/214。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 0/144。
  - 3因子の合格確認済み組合せ: 0/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。

### coverage/interaction-results/cross-20261029-kirimasim-dd2c018.json

- 環境: kirimasim 0.0.0 (commit dd2c01887e0a), built with AppleClang 21.0.0.21000334。
- 実行日時: 2026-10-29T10:01:24.113669+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 126/126。
  - 3因子の合格確認済み組合せ: 51/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 44/44。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- expression_context:
  - 2因子の合格確認済み組合せ: 0/143。
  - 3因子の合格確認済み組合せ: 0/63。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=51。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 0/162。
  - 3因子の合格確認済み組合せ: 0/48。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 0/185。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- shift_context:
  - 2因子の合格確認済み組合せ: 0/298。
  - 3因子の合格確認済み組合せ: 0/92。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=56。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 0/214。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 0/144。
  - 3因子の合格確認済み組合せ: 0/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。

### coverage/interaction-results/cross-20261029-paths-icarus13.json

- 環境: Icarus Verilog version 13.0 (stable) (v13_0-dirty)。
- 実行日時: 2026-10-29T13:08:05.301332+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 126/126。
  - 3因子の合格確認済み組合せ: 51/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 44/44。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- expression_context:
  - 2因子の合格確認済み組合せ: 143/143。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 3/3。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 48/48。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 182/185。
  - 3因子の合格確認済み組合せ: 71/76。
  - 必須ケース: 2/3。
  - ケース状態: pass=30, fail=0, known=2, unsupported=0, stale=0, not_run=0。
- shift_context:
  - 2因子の合格確認済み組合せ: 298/298。
  - 3因子の合格確認済み組合せ: 92/92。
  - 必須ケース: 4/4。
  - ケース状態: pass=56, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 214/214。
  - 3因子の合格確認済み組合せ: 76/76。
  - 必須ケース: 3/3。
  - ケース状態: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 126/144。
  - 3因子の合格確認済み組合せ: 42/52。
  - 必須ケース: 2/3。
  - ケース状態: pass=30, fail=0, known=6, unsupported=0, stale=0, not_run=0。

### coverage/interaction-results/cross-20261029-paths-kirimasim-b86ccb6.json

- 環境: kirimasim 0.0.0 (commit b86ccb6eeee4), built with AppleClang 21.0.0.21000334。
- 実行日時: 2026-10-29T13:08:07.770902+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 126/126。
  - 3因子の合格確認済み組合せ: 51/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 44/44。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- expression_context:
  - 2因子の合格確認済み組合せ: 143/143。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 3/3。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 48/48。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 185/185。
  - 3因子の合格確認済み組合せ: 76/76。
  - 必須ケース: 3/3。
  - ケース状態: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- shift_context:
  - 2因子の合格確認済み組合せ: 298/298。
  - 3因子の合格確認済み組合せ: 92/92。
  - 必須ケース: 4/4。
  - ケース状態: pass=56, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 214/214。
  - 3因子の合格確認済み組合せ: 76/76。
  - 必須ケース: 3/3。
  - ケース状態: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 144/144。
  - 3因子の合格確認済み組合せ: 52/52。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。

### coverage/interaction-results/cross-20261029-paths-verilator5052-seed1.json

- 環境: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905。
- 実行日時: 2026-10-29T13:08:25.994595+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 119/126。
  - 3因子の合格確認済み組合せ: 43/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=43, fail=0, known=8, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 98/162。
  - 3因子の合格確認済み組合せ: 17/44。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- expression_context:
  - 2因子の合格確認済み組合せ: 143/143。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 3/3。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 100/162。
  - 3因子の合格確認済み組合せ: 18/48。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 93/185。
  - 3因子の合格確認済み組合せ: 22/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=8, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- shift_context:
  - 2因子の合格確認済み組合せ: 166/298。
  - 3因子の合格確認済み組合せ: 34/92。
  - 必須ケース: 2/4。
  - ケース状態: pass=23, fail=0, known=0, unsupported=0, stale=0, not_run=33。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 131/214。
  - 3因子の合格確認済み組合せ: 32/76。
  - 必須ケース: 1/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=20。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 80/144。
  - 3因子の合格確認済み組合せ: 18/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=11, fail=0, known=1, unsupported=0, stale=0, not_run=24。

### coverage/interaction-results/cross-20261029-paths-verilator5052-seed73.json

- 環境: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905。
- 実行日時: 2026-10-29T13:08:42.998657+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 119/126。
  - 3因子の合格確認済み組合せ: 43/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=43, fail=0, known=8, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 98/162。
  - 3因子の合格確認済み組合せ: 17/44。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- expression_context:
  - 2因子の合格確認済み組合せ: 143/143。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 3/3。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 100/162。
  - 3因子の合格確認済み組合せ: 18/48。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 93/185。
  - 3因子の合格確認済み組合せ: 22/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=8, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- shift_context:
  - 2因子の合格確認済み組合せ: 166/298。
  - 3因子の合格確認済み組合せ: 34/92。
  - 必須ケース: 2/4。
  - ケース状態: pass=23, fail=0, known=0, unsupported=0, stale=0, not_run=33。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 131/214。
  - 3因子の合格確認済み組合せ: 32/76。
  - 必須ケース: 1/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=20。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 80/144。
  - 3因子の合格確認済み組合せ: 18/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=11, fail=0, known=1, unsupported=0, stale=0, not_run=24。

### coverage/interaction-results/cross-20261029-verilator5052-seed1.json

- 環境: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905。
- 実行日時: 2026-10-29T09:55:17.350492+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 119/126。
  - 3因子の合格確認済み組合せ: 43/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=43, fail=0, known=8, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 98/162。
  - 3因子の合格確認済み組合せ: 17/44。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- expression_context:
  - 2因子の合格確認済み組合せ: 0/143。
  - 3因子の合格確認済み組合せ: 0/63。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=51。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 0/162。
  - 3因子の合格確認済み組合せ: 0/48。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 0/185。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- shift_context:
  - 2因子の合格確認済み組合せ: 0/298。
  - 3因子の合格確認済み組合せ: 0/92。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=56。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 0/214。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 0/144。
  - 3因子の合格確認済み組合せ: 0/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。

### coverage/interaction-results/cross-20261029-verilator5052-seed73.json

- 環境: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905。
- 実行日時: 2026-10-29T09:55:23.072987+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 119/126。
  - 3因子の合格確認済み組合せ: 43/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=43, fail=0, known=8, unsupported=0, stale=0, not_run=274。
- nba_capture:
  - 2因子の合格確認済み組合せ: 98/162。
  - 3因子の合格確認済み組合せ: 17/44。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=24。
- expression_context:
  - 2因子の合格確認済み組合せ: 0/143。
  - 3因子の合格確認済み組合せ: 0/63。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=51。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 0/162。
  - 3因子の合格確認済み組合せ: 0/48。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 0/185。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- shift_context:
  - 2因子の合格確認済み組合せ: 0/298。
  - 3因子の合格確認済み組合せ: 0/92。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=56。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 0/214。
  - 3因子の合格確認済み組合せ: 0/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=32。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 0/144。
  - 3因子の合格確認済み組合せ: 0/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=0, stale=0, not_run=36。
