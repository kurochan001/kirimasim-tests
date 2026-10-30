# 機能間クロスの計画と実行確認

このレポートは登録した有限モデルだけを対象にします。要求カバレッジや全言語の
組合せ網羅率ではありません。計画上の網羅と、実行結果に基づく合格確認を分けます。
既存テストは削減していません。選択数の削減率は実行時間の削減率ではありません。

生成元・利用手順・適用限界は[導入手順](https://github.com/kurochan001/kirimasim-tests/blob/360ef70c73218de1f44dd83c1cda24f60e242537/docs/interaction-verification.md)を参照してください。

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

## packed_structure / model 1

- 制約を満たす組合せ数: 1152。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 3。
- 2因子の計画上の網羅: 186/186。
- 3因子の計画上の網羅: 52/52。

構造体の全ビット・payload・tagと、メンバ／全体の拡張結果を観測し、配置、更新領域、NBAの値の確定、各式の符号属性を確認する。

- width: 1, 32, 33, 64, 65, 129。
- layout: first, last。
- aggregate_sign: unsigned, signed。
- member_sign: unsigned, signed。
- state: bit, logic。
- value: known, x, z。
- access: member, whole。
- update: blocking, nba。

制約: payloadと3ビットのtagは同じ2/4状態型。tagは101に固定。拡張先はpayload幅+4。パック構造体はstaticで、NBA後は#1で観測

## case_matching / model 1

- 制約を満たす組合せ数: 2448。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 3。
- 2因子の計画上の網羅: 220/220。
- 3因子の計画上の網羅: 82/82。

セレクタと項目値を表示し、重複項目とフォールバック項目の2回の分岐結果から、幅・符号の統一、X/Zの扱い、最初に一致した項目の優先を確認する。

- width: 1, 32, 33, 64, 65, 129。
- selector_sign: unsigned, signed。
- item_sign: unsigned, signed。
- item_width: narrow, same, wide。
- kind: case, casez, casex。
- value: known, x, z。
- pattern: equal, flip_low, wild_high, unknown_low。

制約: 幅1のnarrowは幅0になるため除外。2つの項目は同じ型・幅。unique/priority修飾、inside、matches、式の副作用は対象外

## port_connection / model 1

- 制約を満たす組合せ数: 1632。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 204/204。
- 3因子の計画上の網羅: 56/56。

親と子の間で幅が変わる接続を使い、元の値・4状態の接続線・サンプル変数を観測して、接続方向、駆動元の符号、宣言と接続形式、最後の2状態変換を確認する。

- width: 1, 32, 33, 64, 65, 129。
- direction: input, output。
- sign: unsigned, signed。
- sink_width: narrow, same, wide。
- value: known, x, z。
- sample_state: bit, logic。
- binding: named, positional。
- declaration: ansi, nonansi。

制約: 幅1のnarrowは除外。ポートと接続線は明示した4状態wire。bit/logicは#1後のサンプル変数の型で、ポート自体の型ではない。inout/refは対象外

## unpacked_array_copy / model 1

- 制約を満たす組合せ数: 576。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 3。
- 2因子の計画上の網羅: 148/148。
- 3因子の計画上の網羅: 52/52。

2組の入力を配列全体／スライスへコピーし、宣言順の対応、非選択要素の保持、コピー元変更後の独立性と、読み出した要素の符号拡張を確認する。

- width: 1, 32, 33, 64, 65, 129。
- sign: unsigned, signed。
- state: bit, logic。
- source_order: ascending, descending。
- target_order: ascending, descending。
- value: known, x, z。
- operation: whole, slice。

制約: 両配列の要素型は同じtypedef。各3要素、sliceは宣言順の先頭2要素。非ゼロ添字の固定長配列を使い、動的配列・キュー・要素型変換は対象外

## bit_vector_queries / model 1

- 制約を満たす組合せ数: 3320。
- 利用できる既存・新規テスト: 60。
- 短時間実行の選択: 60。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 285/285。
- 3因子の計画上の網羅: 108/108。

引数の実ビット列・幅と各関数の結果を表示し、式の形、状態変換、X/Zの位置、制御ビットの重複除去、one-hot判定と未知値の有無を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- expression: direct, half, prefix, repeat。
- value: zero, one, many, x, z, mixed。
- position: none, low, middle, high。
- controls: zero, one, unknown, mixed, duplicate。

制約: zeroの位置はnone。他の値はlow/middle/high。幅1ではlowだけを使い、many/mixedとhalfを除外。halfは下位半分。制御ビットは1ビット定数

## streaming_permutation / model 1

- 制約を満たす組合せ数: 1152。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 182/182。
- 3因子の計画上の網羅: 68/68。

入力ストリームと結果を比較し、ブロック順、端数ブロック、複数項目の連結、packとunpackの逆変換、2状態の格納先への変換を確認する。

- width: 1, 32, 33, 64, 65, 129。
- direction: left, right。
- slice: 1, 4, 8, 16。
- form: plain, tagged。
- operation: pack, unpack。
- state: bit, logic。
- value: known, x, z。

制約: スライス幅は正の定数。taggedは先頭に101を追加。入出力のビット数を同一にし、パックベクタだけを使う。動的配列、with範囲、サイズ不一致は対象外

## comparison_context / model 1

- 制約を満たす組合せ数: 3400。
- 利用できる既存・新規テスト: 100。
- 短時間実行の選択: 100。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 302/302。
- 3因子の計画上の網羅: 174/174。

4組の入力で幅・符号の統一、未知値と既知の不一致、右辺だけのワイルドカードを確認し、1ビットの比較結果を広いlogic/bitへ直接代入して変換順序を観測する。

- width: 1, 32, 33, 64, 65, 129。
- rhs_width: narrow, same, wide。
- sign_a: unsigned, signed。
- sign_b: unsigned, signed。
- operator: lt, le, gt, ge, eq, ne, ceq, cne, weq, wne。
- value: known, lhs_x, rhs_x, rhs_z, both_unknown。

制約: 幅1に対するnarrowは幅0になるため除外。比較対象はパック整数。4組の入力を使い、both_unknownはX/X・Z/Z・X/Z・Z/Xを先頭ビットへ置く

## array_reduction_pipeline / model 1

- 制約を満たす組合せ数: 4320。
- 利用できる既存・新規テスト: 72。
- 短時間実行の選択: 72。
- 個別に保持する必須ケース: 8。
- 2因子の計画上の網羅: 261/261。
- 3因子の計画上の網羅: 162/162。

固定長配列・動的配列・キューの集計を2組の背景値で観測し、with式による要素の型変換、戻り値の幅、オーバーフロー、X/Z伝播と呼出し後の拡張を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- sign: unsigned, signed。
- storage: fixed, dynamic, queue。
- method: sum, product, and, or, xor。
- transform: plain, widen, int, integer。
- value: known, high_x, high_z。

制約: 各コンテナは3要素。固定長配列は[3:1]。widenは要素幅+1のサイズキャスト、int/integerは32ビットsignedの2/4状態型へのキャスト。空配列、連想配列、副作用付きwith式は対象外

## variable_bit_index / model 1

- 制約を満たす組合せ数: 2880。
- 利用できる既存・新規テスト: 44。
- 短時間実行の選択: 44。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 253/253。
- 3因子の計画上の網羅: 106/106。

可変インデックスのビット列と書き込み前後の全ビットを観測し、添字の符号、範囲の始点と向き、無効な読み取りの既定値、無効な書き込み時の保持を確認する。

- width: 1, 32, 33, 64, 65, 129。
- origin: zero, offset, negative。
- direction: ascending, descending。
- state: bit, logic。
- index_sign: unsigned, signed。
- index: low, high, middle, before, after, x, z。
- value: known, x, z。

制約: 範囲は0始点・5始点・全添字が負の3種。インデックスは16ビットのlogic。幅1のhigh/middleはlowと同じなので除外。全ケースで読み取りと書き込みを確認

## queue_update_capacity / model 1

- 制約を満たす組合せ数: 3456。
- 利用できる既存・新規テスト: 48。
- 短時間実行の選択: 48。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 258/258。
- 3因子の計画上の網羅: 120/120。

2組の入力でサイズと全要素、取り出した値、操作前のコピーを観測し、追加位置と容量による破棄、空の既定値、型変換、値コピーの独立性を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- sign: unsigned, signed。
- capacity: unbounded, two, three。
- size: 0, 2, 3。
- operation: push_front, push_back, insert, write_end, pop_front, pop_back。
- value: known, x, z。

制約: 初期サイズは0・2・3。容量2のサイズ3は除外。容量は要素数で表す。追加値は要素幅+1、insertは中央、write_endはsize()への書き込み。2組の入力を使い、操作前コピーも観測する。要素参照の有効期間は対象外

## division_context / model 1

- 制約を満たす組合せ数: 4704。
- 利用できる既存・新規テスト: 72。
- 短時間実行の選択: 72。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 283/283。
- 3因子の計画上の網羅: 98/98。

両オペランドと演算結果を観測し、演算前の幅・符号の統一、商の0方向への丸め、剰余の符号、ゼロ除算とX/Zの伝播、最終的な2状態変換を確認する。

- width: 1, 32, 33, 64, 65, 129。
- rhs_width: narrow, same, wide。
- result_width: narrow, same, wide。
- sign_a: unsigned, signed。
- sign_b: unsigned, signed。
- operator: div, mod。
- value: known, zero, lhs_x, lhs_z, rhs_x, rhs_z。
- state: bit, logic。

制約: 幅1に対するnarrowは幅0になるため除外。両入力はlogicのパック整数。stateは代入先の型で、演算後に2状態変換する。全行で既知値4組を確認し、zero/X/Z行は同じ4組に指定値も適用する。最小負値/-1と正負の商・剰余を確認。実数は対象外

## dynamic_array_resize / model 1

- 制約を満たす組合せ数: 2016。
- 利用できる既存・新規テスト: 38。
- 短時間実行の選択: 38。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 219/219。
- 3因子の計画上の網羅: 96/96。

再確保前後のサイズと全要素を観測し、別配列コピー・自己リサイズ・初期化式なしの再生成、切り詰め、追加領域の型別既定値、コピー後の独立性を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- sign: unsigned, signed。
- value: known, x, z。
- old_size: 0, 2, 3。
- new_size: 0, 1, 2, 4。
- operation: copy, self, reset。

制約: 初期サイズ0では値因子をknownに固定し、値を持たない重複を除く。同じtypedefの動的配列に対する別配列コピー・自己リサイズ・初期化式なしの再生成を比較。サイズは実行時変数。要素参照の有効期間・多次元配列は対象外

## concatenated_assignment / model 1

- 制約を満たす組合せ数: 4608。
- 利用できる既存・新規テスト: 72。
- 短時間実行の選択: 72。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 265/265。
- 3因子の計画上の網羅: 126/126。

2組の既知入力とX/Zの入力で、連結全体への拡張と分割、各項の状態変換、即時更新とNBAの値確定、各項と連結を読み出す際の符号の違いを確認する。

- width: 2, 32, 33, 64, 65, 129。
- split: head_bit, halves, tail_bit。
- rhs_width: narrow, same, wide。
- rhs_sign: unsigned, signed。
- state: bb, bl, lb, ll。
- member_sign: unsigned, signed。
- update: blocking, nba。
- value: known, x, z。

制約: widthは連結全体の幅で最小2、各項は正幅。幅2では同じ分割をhead_bitに統一。別々のstatic変数2個を連結し、両項の符号は共通。stateは左／右のbit/logic。既知2組と必要ならX/Zの2組を観測。重複した代入先、部分選択、多次元配列は対象外

## packed_logical_reduction / model 1

- 制約を満たす組合せ数: 1180。
- 利用できる既存・新規テスト: 70。
- 短時間実行の選択: 70。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 218/218。
- 3因子の計画上の網羅: 142/142。

各行で全6リダクションと論理否定の入力・実際の式・結果を観測し、支配値とX/Z、演算前後の状態変換、1ビットunsigned結果の拡張、入力の自己決定幅を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- expression: direct, half, prefix_zero, prefix_one。
- value: zero, ones, one, x, z, mixed。
- position: none, low, middle, high。
- result_state: bit, logic。

制約: zero/onesの位置はnone、他はlow/middle/high。幅1はlowだけを使い、mixedと幅0になるhalfを除外。halfは下位半分。各行で全6リダクションと!を観測。入力と代入先の状態型を分け、全行で既知の全1入力も観測する。入力はsignedに固定し、演算結果がunsignedであることを確認する

## 入力指紋が一致した実行の確認

各スナップショットを独立に評価します。複数の版・実行の部分成功を合成しません。
passだけを合格の証跡とし、known・unsupported・staleを合格へ含めません。
この集計は期待値との一致を確認した組合せの割合です。失敗実行からの生の到達率は未計測です。

### results/ghost.json

- 環境: private build 2d76b598f1c1。
- 実行日時: 2026-10-30T00:00:38.640933+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 126/126。
  - 3因子の合格確認済み組合せ: 51/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=324, fail=1, known=0, unsupported=0, stale=0, not_run=0。
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
  - 2因子の合格確認済み組合せ: 137/144。
  - 3因子の合格確認済み組合せ: 48/52。
  - 必須ケース: 2/3。
  - ケース状態: pass=34, fail=2, known=0, unsupported=0, stale=0, not_run=0。
- packed_structure:
  - 2因子の合格確認済み組合せ: 164/186。
  - 3因子の合格確認済み組合せ: 43/52。
  - 必須ケース: 2/3。
  - ケース状態: pass=31, fail=5, known=0, unsupported=0, stale=0, not_run=0。
- case_matching:
  - 2因子の合格確認済み組合せ: 215/220。
  - 3因子の合格確認済み組合せ: 75/82。
  - 必須ケース: 3/3。
  - ケース状態: pass=32, fail=4, known=0, unsupported=0, stale=0, not_run=0。
- port_connection:
  - 2因子の合格確認済み組合せ: 204/204。
  - 3因子の合格確認済み組合せ: 56/56。
  - 必須ケース: 5/5。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- unpacked_array_copy:
  - 2因子の合格確認済み組合せ: 134/148。
  - 3因子の合格確認済み組合せ: 44/52。
  - 必須ケース: 2/3。
  - ケース状態: pass=32, fail=4, known=0, unsupported=0, stale=0, not_run=0。
- bit_vector_queries:
  - 2因子の合格確認済み組合せ: 278/285。
  - 3因子の合格確認済み組合せ: 89/108。
  - 必須ケース: 3/4。
  - ケース状態: pass=49, fail=11, known=0, unsupported=0, stale=0, not_run=0。
- streaming_permutation:
  - 2因子の合格確認済み組合せ: 167/182。
  - 3因子の合格確認済み組合せ: 53/68。
  - 必須ケース: 2/4。
  - ケース状態: pass=31, fail=5, known=0, unsupported=0, stale=0, not_run=0。
- comparison_context:
  - 2因子の合格確認済み組合せ: 302/302。
  - 3因子の合格確認済み組合せ: 174/174。
  - 必須ケース: 4/4。
  - ケース状態: pass=100, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- array_reduction_pipeline:
  - 2因子の合格確認済み組合せ: 238/261。
  - 3因子の合格確認済み組合せ: 102/162。
  - 必須ケース: 2/8。
  - ケース状態: pass=44, fail=28, known=0, unsupported=0, stale=0, not_run=0。
- variable_bit_index:
  - 2因子の合格確認済み組合せ: 219/253。
  - 3因子の合格確認済み組合せ: 68/106。
  - 必須ケース: 3/4。
  - ケース状態: pass=26, fail=18, known=0, unsupported=0, stale=0, not_run=0。
- queue_update_capacity:
  - 2因子の合格確認済み組合せ: 204/258。
  - 3因子の合格確認済み組合せ: 71/120。
  - 必須ケース: 2/5。
  - ケース状態: pass=28, fail=20, known=0, unsupported=0, stale=0, not_run=0。
- division_context:
  - 2因子の合格確認済み組合せ: 283/283。
  - 3因子の合格確認済み組合せ: 98/98。
  - 必須ケース: 5/5。
  - ケース状態: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- dynamic_array_resize:
  - 2因子の合格確認済み組合せ: 219/219。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 5/5。
  - ケース状態: pass=38, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- concatenated_assignment:
  - 2因子の合格確認済み組合せ: 254/265。
  - 3因子の合格確認済み組合せ: 108/126。
  - 必須ケース: 5/5。
  - ケース状態: pass=60, fail=12, known=0, unsupported=0, stale=0, not_run=0。
- packed_logical_reduction:
  - 2因子の合格確認済み組合せ: 218/218。
  - 3因子の合格確認済み組合せ: 142/142。
  - 必須ケース: 6/6。
  - ケース状態: pass=70, fail=0, known=0, unsupported=0, stale=0, not_run=0。

### results/icarus.json

- 環境: Icarus Verilog version 14.0 (devel) (s20260301-776-g69914455)。
- 実行日時: 2026-10-29T23:41:48.731028+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 126/126。
  - 3因子の合格確認済み組合せ: 51/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=325, fail=0, known=0, unsupported=0, stale=0, not_run=0。
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
- packed_structure:
  - 2因子の合格確認済み組合せ: 186/186。
  - 3因子の合格確認済み組合せ: 52/52。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- case_matching:
  - 2因子の合格確認済み組合せ: 220/220。
  - 3因子の合格確認済み組合せ: 82/82。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- port_connection:
  - 2因子の合格確認済み組合せ: 198/204。
  - 3因子の合格確認済み組合せ: 52/56。
  - 必須ケース: 3/5。
  - ケース状態: pass=34, fail=0, known=2, unsupported=0, stale=0, not_run=0。
- unpacked_array_copy:
  - 2因子の合格確認済み組合せ: 107/148。
  - 3因子の合格確認済み組合せ: 30/52。
  - 必須ケース: 1/3。
  - ケース状態: pass=26, fail=0, known=10, unsupported=0, stale=0, not_run=0。
- bit_vector_queries:
  - 2因子の合格確認済み組合せ: 285/285。
  - 3因子の合格確認済み組合せ: 108/108。
  - 必須ケース: 4/4。
  - ケース状態: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- streaming_permutation:
  - 2因子の合格確認済み組合せ: 0/182。
  - 3因子の合格確認済み組合せ: 0/68。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0。
- comparison_context:
  - 2因子の合格確認済み組合せ: 302/302。
  - 3因子の合格確認済み組合せ: 174/174。
  - 必須ケース: 4/4。
  - ケース状態: pass=100, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- array_reduction_pipeline:
  - 2因子の合格確認済み組合せ: 129/261。
  - 3因子の合格確認済み組合せ: 34/162。
  - 必須ケース: 0/8。
  - ケース状態: pass=12, fail=0, known=60, unsupported=0, stale=0, not_run=0。
- variable_bit_index:
  - 2因子の合格確認済み組合せ: 217/253。
  - 3因子の合格確認済み組合せ: 68/106。
  - 必須ケース: 3/4。
  - ケース状態: pass=26, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- queue_update_capacity:
  - 2因子の合格確認済み組合せ: 245/258。
  - 3因子の合格確認済み組合せ: 100/120。
  - 必須ケース: 4/5。
  - ケース状態: pass=41, fail=0, known=7, unsupported=0, stale=0, not_run=0。
- division_context:
  - 2因子の合格確認済み組合せ: 283/283。
  - 3因子の合格確認済み組合せ: 98/98。
  - 必須ケース: 5/5。
  - ケース状態: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- dynamic_array_resize:
  - 2因子の合格確認済み組合せ: 219/219。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 5/5。
  - ケース状態: pass=38, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- concatenated_assignment:
  - 2因子の合格確認済み組合せ: 244/265。
  - 3因子の合格確認済み組合せ: 113/126。
  - 必須ケース: 4/5。
  - ケース状態: pass=66, fail=0, known=6, unsupported=0, stale=0, not_run=0。
- packed_logical_reduction:
  - 2因子の合格確認済み組合せ: 218/218。
  - 3因子の合格確認済み組合せ: 142/142。
  - 必須ケース: 6/6。
  - ケース状態: pass=70, fail=0, known=0, unsupported=0, stale=0, not_run=0。

### results/kirimasim.json

- 環境: kirimasim 0.0.0 (commit 51cda3143aed), built with GNU 13.3.0。
- 実行日時: 2026-10-29T23:53:35.025046+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 126/126。
  - 3因子の合格確認済み組合せ: 51/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=325, fail=0, known=0, unsupported=0, stale=0, not_run=0。
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
- packed_structure:
  - 2因子の合格確認済み組合せ: 186/186。
  - 3因子の合格確認済み組合せ: 52/52。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- case_matching:
  - 2因子の合格確認済み組合せ: 220/220。
  - 3因子の合格確認済み組合せ: 82/82。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- port_connection:
  - 2因子の合格確認済み組合せ: 204/204。
  - 3因子の合格確認済み組合せ: 56/56。
  - 必須ケース: 5/5。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- unpacked_array_copy:
  - 2因子の合格確認済み組合せ: 122/148。
  - 3因子の合格確認済み組合せ: 38/52。
  - 必須ケース: 2/3。
  - ケース状態: pass=30, fail=0, known=0, unsupported=6, stale=0, not_run=0。
- bit_vector_queries:
  - 2因子の合格確認済み組合せ: 285/285。
  - 3因子の合格確認済み組合せ: 108/108。
  - 必須ケース: 4/4。
  - ケース状態: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- streaming_permutation:
  - 2因子の合格確認済み組合せ: 182/182。
  - 3因子の合格確認済み組合せ: 68/68。
  - 必須ケース: 4/4。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- comparison_context:
  - 2因子の合格確認済み組合せ: 302/302。
  - 3因子の合格確認済み組合せ: 174/174。
  - 必須ケース: 4/4。
  - ケース状態: pass=100, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- array_reduction_pipeline:
  - 2因子の合格確認済み組合せ: 261/261。
  - 3因子の合格確認済み組合せ: 162/162。
  - 必須ケース: 8/8。
  - ケース状態: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- variable_bit_index:
  - 2因子の合格確認済み組合せ: 253/253。
  - 3因子の合格確認済み組合せ: 106/106。
  - 必須ケース: 4/4。
  - ケース状態: pass=44, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- queue_update_capacity:
  - 2因子の合格確認済み組合せ: 258/258。
  - 3因子の合格確認済み組合せ: 120/120。
  - 必須ケース: 5/5。
  - ケース状態: pass=48, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- division_context:
  - 2因子の合格確認済み組合せ: 283/283。
  - 3因子の合格確認済み組合せ: 98/98。
  - 必須ケース: 5/5。
  - ケース状態: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- dynamic_array_resize:
  - 2因子の合格確認済み組合せ: 219/219。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 5/5。
  - ケース状態: pass=38, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- concatenated_assignment:
  - 2因子の合格確認済み組合せ: 265/265。
  - 3因子の合格確認済み組合せ: 126/126。
  - 必須ケース: 5/5。
  - ケース状態: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_logical_reduction:
  - 2因子の合格確認済み組合せ: 218/218。
  - 3因子の合格確認済み組合せ: 142/142。
  - 必須ケース: 6/6。
  - ケース状態: pass=70, fail=0, known=0, unsupported=0, stale=0, not_run=0。

### results/lyra.json

- 環境: Lyra (commit 8eff7abdc335)。
- 実行日時: 2026-10-30T01:42:51.203867+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 111/126。
  - 3因子の合格確認済み組合せ: 36/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=226, fail=3, known=0, unsupported=96, stale=0, not_run=0。
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
- packed_structure:
  - 2因子の合格確認済み組合せ: 186/186。
  - 3因子の合格確認済み組合せ: 52/52。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- case_matching:
  - 2因子の合格確認済み組合せ: 220/220。
  - 3因子の合格確認済み組合せ: 82/82。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- port_connection:
  - 2因子の合格確認済み組合せ: 204/204。
  - 3因子の合格確認済み組合せ: 56/56。
  - 必須ケース: 5/5。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- unpacked_array_copy:
  - 2因子の合格確認済み組合せ: 148/148。
  - 3因子の合格確認済み組合せ: 52/52。
  - 必須ケース: 3/3。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- bit_vector_queries:
  - 2因子の合格確認済み組合せ: 285/285。
  - 3因子の合格確認済み組合せ: 108/108。
  - 必須ケース: 4/4。
  - ケース状態: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- streaming_permutation:
  - 2因子の合格確認済み組合せ: 178/182。
  - 3因子の合格確認済み組合せ: 62/68。
  - 必須ケース: 2/4。
  - ケース状態: pass=34, fail=2, known=0, unsupported=0, stale=0, not_run=0。
- comparison_context:
  - 2因子の合格確認済み組合せ: 302/302。
  - 3因子の合格確認済み組合せ: 174/174。
  - 必須ケース: 4/4。
  - ケース状態: pass=100, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- array_reduction_pipeline:
  - 2因子の合格確認済み組合せ: 261/261。
  - 3因子の合格確認済み組合せ: 162/162。
  - 必須ケース: 8/8。
  - ケース状態: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- variable_bit_index:
  - 2因子の合格確認済み組合せ: 253/253。
  - 3因子の合格確認済み組合せ: 106/106。
  - 必須ケース: 4/4。
  - ケース状態: pass=44, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- queue_update_capacity:
  - 2因子の合格確認済み組合せ: 258/258。
  - 3因子の合格確認済み組合せ: 120/120。
  - 必須ケース: 5/5。
  - ケース状態: pass=48, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- division_context:
  - 2因子の合格確認済み組合せ: 283/283。
  - 3因子の合格確認済み組合せ: 98/98。
  - 必須ケース: 5/5。
  - ケース状態: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- dynamic_array_resize:
  - 2因子の合格確認済み組合せ: 219/219。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 5/5。
  - ケース状態: pass=38, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- concatenated_assignment:
  - 2因子の合格確認済み組合せ: 265/265。
  - 3因子の合格確認済み組合せ: 126/126。
  - 必須ケース: 5/5。
  - ケース状態: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_logical_reduction:
  - 2因子の合格確認済み組合せ: 218/218。
  - 3因子の合格確認済み組合せ: 142/142。
  - 必須ケース: 6/6。
  - ケース状態: pass=70, fail=0, known=0, unsupported=0, stale=0, not_run=0。

### results/verilator.json

- 環境: Verilator 5.053 devel rev v5.052-645-g453b02a3。
- 実行日時: 2026-10-30T00:03:27.436477+00:00。

- scheduling_visibility:
  - 2因子の合格確認済み組合せ: 126/126。
  - 3因子の合格確認済み組合せ: 48/51。
  - 個別の必須ケース: 対象なし。
  - ケース状態: pass=300, fail=0, known=25, unsupported=0, stale=0, not_run=0。
- nba_capture:
  - 2因子の合格確認済み組合せ: 104/162。
  - 3因子の合格確認済み組合せ: 18/44。
  - 必須ケース: 0/3。
  - ケース状態: pass=13, fail=0, known=23, unsupported=0, stale=0, not_run=0。
- expression_context:
  - 2因子の合格確認済み組合せ: 143/143。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 3/3。
  - ケース状態: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- packed_part_select:
  - 2因子の合格確認済み組合せ: 129/162。
  - 3因子の合格確認済み組合せ: 28/48。
  - 必須ケース: 1/3。
  - ケース状態: pass=20, fail=0, known=16, unsupported=0, stale=0, not_run=0。
- conditional_merge:
  - 2因子の合格確認済み組合せ: 122/185。
  - 3因子の合格確認済み組合せ: 31/76。
  - 必須ケース: 0/3。
  - ケース状態: pass=12, fail=0, known=20, unsupported=0, stale=0, not_run=0。
- shift_context:
  - 2因子の合格確認済み組合せ: 166/298。
  - 3因子の合格確認済み組合せ: 34/92。
  - 必須ケース: 2/4。
  - ケース状態: pass=23, fail=0, known=33, unsupported=0, stale=0, not_run=0。
- cast_pipeline:
  - 2因子の合格確認済み組合せ: 131/214。
  - 3因子の合格確認済み組合せ: 32/76。
  - 必須ケース: 1/3。
  - ケース状態: pass=12, fail=0, known=20, unsupported=0, stale=0, not_run=0。
- task_argument_visibility:
  - 2因子の合格確認済み組合せ: 121/144。
  - 3因子の合格確認済み組合せ: 32/52。
  - 必須ケース: 1/3。
  - ケース状態: pass=21, fail=0, known=15, unsupported=0, stale=0, not_run=0。
- packed_structure:
  - 2因子の合格確認済み組合せ: 133/186。
  - 3因子の合格確認済み組合せ: 24/52。
  - 必須ケース: 0/3。
  - ケース状態: pass=13, fail=0, known=23, unsupported=0, stale=0, not_run=0。
- case_matching:
  - 2因子の合格確認済み組合せ: 81/220。
  - 3因子の合格確認済み組合せ: 18/82。
  - 必須ケース: 1/3。
  - ケース状態: pass=6, fail=0, known=30, unsupported=0, stale=0, not_run=0。
- port_connection:
  - 2因子の合格確認済み組合せ: 133/204。
  - 3因子の合格確認済み組合せ: 24/56。
  - 必須ケース: 2/5。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- unpacked_array_copy:
  - 2因子の合格確認済み組合せ: 95/148。
  - 3因子の合格確認済み組合せ: 21/52。
  - 必須ケース: 1/3。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- bit_vector_queries:
  - 2因子の合格確認済み組合せ: 140/285。
  - 3因子の合格確認済み組合せ: 34/108。
  - 必須ケース: 1/4。
  - ケース状態: pass=18, fail=0, known=42, unsupported=0, stale=0, not_run=0。
- streaming_permutation:
  - 2因子の合格確認済み組合せ: 105/182。
  - 3因子の合格確認済み組合せ: 22/68。
  - 必須ケース: 0/4。
  - ケース状態: pass=11, fail=0, known=25, unsupported=0, stale=0, not_run=0。
- comparison_context:
  - 2因子の合格確認済み組合せ: 117/302。
  - 3因子の合格確認済み組合せ: 42/174。
  - 必須ケース: 1/4。
  - ケース状態: pass=16, fail=0, known=84, unsupported=0, stale=0, not_run=0。
- array_reduction_pipeline:
  - 2因子の合格確認済み組合せ: 187/261。
  - 3因子の合格確認済み組合せ: 58/162。
  - 必須ケース: 3/8。
  - ケース状態: pass=23, fail=0, known=49, unsupported=0, stale=0, not_run=0。
- variable_bit_index:
  - 2因子の合格確認済み組合せ: 109/253。
  - 3因子の合格確認済み組合せ: 24/106。
  - 必須ケース: 1/4。
  - ケース状態: pass=9, fail=0, known=35, unsupported=0, stale=0, not_run=0。
- queue_update_capacity:
  - 2因子の合格確認済み組合せ: 141/258。
  - 3因子の合格確認済み組合せ: 35/120。
  - 必須ケース: 0/5。
  - ケース状態: pass=17, fail=0, known=31, unsupported=0, stale=0, not_run=0。
- division_context:
  - 2因子の合格確認済み組合せ: 142/283。
  - 3因子の合格確認済み組合せ: 21/98。
  - 必須ケース: 4/5。
  - ケース状態: pass=12, fail=0, known=60, unsupported=0, stale=0, not_run=0。
- dynamic_array_resize:
  - 2因子の合格確認済み組合せ: 116/219。
  - 3因子の合格確認済み組合せ: 30/96。
  - 必須ケース: 1/5。
  - ケース状態: pass=11, fail=0, known=27, unsupported=0, stale=0, not_run=0。
- concatenated_assignment:
  - 2因子の合格確認済み組合せ: 181/265。
  - 3因子の合格確認済み組合せ: 48/126。
  - 必須ケース: 3/5。
  - ケース状態: pass=24, fail=0, known=48, unsupported=0, stale=0, not_run=0。
- packed_logical_reduction:
  - 2因子の合格確認済み組合せ: 146/218。
  - 3因子の合格確認済み組合せ: 72/142。
  - 必須ケース: 2/6。
  - ケース状態: pass=36, fail=0, known=34, unsupported=0, stale=0, not_run=0。
