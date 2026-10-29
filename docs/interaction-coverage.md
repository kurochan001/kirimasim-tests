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

## 入力指紋が一致した実行の確認

各スナップショットを独立に評価します。複数の版・実行の部分成功を合成しません。
passだけを合格の証跡とし、known・unsupported・staleを合格へ含めません。
この集計は期待値との一致を確認した組合せの割合です。失敗実行からの生の到達率は未計測です。

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
