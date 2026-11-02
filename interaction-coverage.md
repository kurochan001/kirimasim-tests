<a id="plan-and-execution-of-crossfunctionality-verification"></a>

# 機能間クロスの計画と実行確認

[English](interaction-coverage.en.md) / [日本語](interaction-coverage.md)

このレポートは登録した有限モデルだけを対象にします。要求カバレッジや全言語の 組合せ網羅率ではありません。計画上の網羅と、実行結果に基づく合格確認を分けます。 既存テストは削減していません。選択数の削減率は実行時間の削減率ではありません。

生成元・利用手順・適用限界は[導入手順](https://github.com/kurochan001/kirimasim-tests/blob/0afc89659c16a22f88c82816358e305de3f34d93/docs/interaction-verification.md)を参照してください。

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

制約: signing castは幅を変えないので cast_width =same。幅 1 のnarrowは除外。代入先は元の幅 +2 。typed castの型はunsigned

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

## argument_binding_index / model 1

- 制約を満たす組合せ数: 972。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 162/162。
- 3因子の計画上の網羅: 63/63。

呼出し後に添字を同値・次要素・-1へ変更し、実引数と仮引数の複数時刻の値を観測して、元の要素への結合、inputの値コピー、refの双方向の可視性、const refのライブな読取り、復帰時の書戻しや隣接要素の破壊がないことを確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- mode: input, ref, const_ref。
- storage: fixed, dynamic, queue。
- index: same, next, invalid。

制約: 全行でautomaticタスクを使用。固定配列は[2:4]、動的配列とキューは3要素。実引数の添字は呼出し時に先頭を指し、1 tick後に同値・次要素・-1へ変更。変更後の添字で配列を読まない。型は同じtypedefでrefの型変換を避ける。3組の入力を巡回し、X/Z行にも既知値の対照条件を含める。output/inoutの復帰先評価、サイズ変更、副作用付き実引数、NBAは対象外

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

制約: zeroの位置はnone。その他の値はlow/middle/high。幅 1 ではlowだけを使い、many/mixedとhalfを除外。halfは下位半分。制御ビットは 1 ビット定数

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

## queue_element_reference / model 1

- 制約を満たす組合せ数: 2160。
- 利用できる既存・新規テスト: 60。
- 短時間実行の選択: 60。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 257/257。
- 3因子の計画上の網羅: 96/96。

3組の入力で保持中の参照値・変更後の全要素・2回の書込み後・値コピーを観測し、要素の移動後の同一性、削除・全体代入後の古い参照の存続と書込みの分離、容量超過での末尾要素の破棄、bit/logicの引数変換を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- capacity: unbounded, three。
- held: first, middle, last。
- operation: push_front, push_back, insert, pop_front, pop_back, delete_held, delete_other, copy, concat, clear。
- value: known, x, z。

制約: 初期要素数は3、容量は無制限または3。insertは添字1。delete_otherは参照先がfirstなら添字2、それ以外は添字0。添字は呼出し中に変更しない。3組の既知入力を巡回し、X/Z行にも既知値の対照条件を含める。同時刻の競合、ref static、動的/連想配列、物理的メモリ回収は対象外。未対応による除外はしない

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

制約: zero/onesの位置はnone、他はlow/middle/high。幅 1 はlowだけを使い、mixedと幅 0 になるhalfを除外。halfは下位半分。各行で全 6 リダクションと!を観測。入力と代入先の状態型を分け、全行で既知の全 1 入力も観測する。入力はsignedに固定し、演算結果がunsignedであることを確認する

## logical_short_circuit / model 1

- 制約を満たす組合せ数: 2088。
- 利用できる既存・新規テスト: 92。
- 短時間実行の選択: 92。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 214/214。
- 3因子の計画上の網羅: 236/236。

4演算ごとに左右の関数の呼出し回数・観測値・独立した副作用を表示し、短絡による右辺の評価抑止、未知値の真偽変換、結果と最終格納先の状態変換を確認する。

- width: 1, 32, 33, 64, 65, 129。
- rhs_width: narrow, same, wide。
- state: bb, bl, lb, ll。
- value_a: zero, one, unknown, mixed。
- value_b: zero, one, unknown, mixed。
- result_state: bit, logic。

制約: 幅0の右入力を除外。mixedは最上位X/Zと最下位1なので幅1では除外。stateは左／右のbit/logic。未知値はX/Zを同じ行の別刺激で両方確認。全行で4演算を実行し、左右の副作用は独立。入力はsignedに固定

## edge_event_expression / model 1

- 制約を満たす組合せ数: 4096。
- 利用できる既存・新規テスト: 64。
- 短時間実行の選択: 64。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 260/260。
- 3因子の計画上の網羅: 152/152。

両背景で初期イベントを除外し、更新直後の値と次時刻の3カウンタを観測して、X/Z遷移、式の変化、ベクタのLSB規則、状態変換、NBAの更新時点を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- expression: vector, lsb, msb, reduce_or。
- position: low, middle, high。
- before: 0, 1, x, z。
- after: 0, 1, x, z。
- update: blocking, nba。

制約: 幅1の注目位置はlowに統一。各行で背景0/1、既知0→1と指定遷移を観測。全体／LSB／MSB／OR式を対象に、posedge・negedge・非エッジの変化を同時に測る。初期設定を収束させてカウンタをクリアし、更新の次時刻に計数。イベントOR・iff・複数更新・グリッチ・複数クロックは対象外

## event_or_iff / model 1

- 制約を満たす組合せ数: 252。
- 利用できる既存・新規テスト: 27。
- 短時間実行の選択: 27。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 104/104。
- 3因子の計画上の網羅: 59/59。

独立した左右のイベント数と条件付きORの起床数、条件だけを変えた後の保持を観測し、iffの項ごとの結合、orとカンマの同義性、名前付きイベントの再発火、X/Zを含む条件の真偽、ブロッキング/NBAの更新時点を確認する。

- join: or, comma。
- source: signals, named, mixed。
- edge: change, posedge, negedge。
- filter: both, first, second。
- guard: known, xz, mixed。
- update: blocking, nba。

制約: 名前付きイベントだけの行はedge=changeに統一。mixedは左が信号、右が名前付き。エッジ指定は信号項だけに適用。条件と二つのイベントを別時刻で更新し、初期設定後に計数をクリアする。同時発火、グリッチ、sequenceイベント、条件式の副作用は対象外。未対応による除外はしない

## heap_file_monitor_context / model 1

- 制約を満たす組合せ数: 36。
- 利用できる既存・新規テスト: 18。
- 短時間実行の選択: 18。
- 個別に保持する必須ケース: 3。
- 2因子の計画上の網羅: 40/40。

9種類の登録場所と2種類のコンテナ・記述子を組み合わせ、ファイルを読み戻して、Postponedの最終値、非選択要素、選択・置換、monitoroff、閉鎖後の出力抑止を確認する。

- context: initial, task, function, fork, generate, interface, program, package, always。
- storage: queue, dynamic。
- descriptor: mcd, fd。

制約: 全36行は合法。contextは登録を行う場所で、監視対象はstatic変数。programには別の存続プロセスを置く。各行で選択・サイズ・置換・同時刻の複数更新・monitoroff・close後不出力を観測する。native callbackからの再入・再配置は別の未確認API範囲

## compound_shift_target / model 1

- 制約を満たす組合せ数: 7560。
- 利用できる既存・新規テスト: 40。
- 短時間実行の選択: 40。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 308/308。
- 3因子の計画上の網羅: 90/90。

複合シフト代入の前後にスカラ・配列全要素・親ベクタ・拡張値と添字関数の回数を観測し、左辺の1回評価、部分選択の符号、シフト量の独立した幅と型変換を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- sign: unsigned, signed。
- target: scalar, element, part。
- operator: shl, shr, ashr。
- count: zero, last, width, ones, x, z。
- count_width: 8, 65。
- value: known, x, z。

制約: 幅1でlastがzeroと同値になる行だけを除く。左辺は同型のスカラ・固定配列要素・幅wのpacked部分選択。部分選択は親の符号にかかわらずunsigned。countはsignedな8/65ビット変数で、onesは全1（宣言上は-1）だがシフト量はunsigned。左辺と右辺の副作用競合、無効な添字、NBA、複合左辺の重複は対象外

## membership_container / model 1

- 制約を満たす組合せ数: 5984。
- 利用できる既存・新規テスト: 46。
- 短時間実行の選択: 46。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 305/305。
- 3因子の計画上の網羅: 174/174。

個別列挙・固定配列・動的配列・キューの要素とサイズ、異なる幅・符号の入力、生の判定値・拡張・bit変換・逆順リストを観測し、片側ワイルドカードとORを確認する。

- width: 1, 32, 33, 64, 65, 129。
- needle_width: narrow, same, wide。
- needle_sign: unsigned, signed。
- set_sign: unsigned, signed。
- set_state: bit, logic。
- container: list, fixed, dynamic, queue。
- size: 0, 1, 3。
- value: known, lhs_x, rhs_x, rhs_z, both_unknown。

制約: 幅1のnarrowは幅0になるため除外。空集合は動的配列・キューだけで表し、空の個別列挙や0要素の固定配列は作らない。空集合にはRHSの値がないためknown/lhs_xだけを残す。集合の全要素は同じ型・幅。範囲、非整数、異種の集合要素、入れ子配列、副作用付き式と走査順の観測は対象外

## membership_range / model 1

- 制約を満たす組合せ数: 5680。
- 利用できる既存・新規テスト: 46。
- 短時間実行の選択: 46。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 303/303。
- 3因子の計画上の網羅: 178/178。

閉区間・逆順・$端点・絶対/相対許容差の範囲で、端点の格納値、各端点の前後の入力、生の判定値・拡張・bit変換と関係演算子での同じ判定を観測し、範囲の比較と集合値のワイルドカードの違い、許容差の端点の入れ替えと切り捨てを確認する。

- width: 1, 32, 33, 64, 65, 129。
- needle_width: narrow, same, wide。
- needle_sign: unsigned, signed。
- bound_sign: unsigned, signed。
- bound_state: bit, logic。
- form: closed, reversed, low_open, high_open, abs_tol, rel_tol。
- value: known, lhs_x, bound_x, bound_z。
- members: single, mixed。

制約: 幅1のnarrowは幅0になるため除外。逆順の範囲は、符号の解釈によらず左端が大きい正の2値（3と1）で表すため幅1を除き、X/Zを含む空の範囲の扱いは本文が定めないので既知値だけにする。全端点と集合要素は同じ型・幅で、許容差は型の範囲を超えない値に限る。閉区間の端点X/Zでは、もう一方の端点を満たす入力だけを使う。非整数、異種の集合要素、副作用付き式は対象外

## case_inside_selection / model 1

- 制約を満たす組合せ数: 8704。
- 利用できる既存・新規テスト: 34。
- 短時間実行の選択: 34。
- 個別に保持する必須ケース: 7。
- 2因子の計画上の網羅: 315/315。
- 3因子の計画上の網羅: 154/154。

値・範囲・固定配列・2値のリストを先頭項目にしたcase insideで、各項目とdefaultを狙う4組のケース式、格納後の項目値、選ばれた分岐、ケース式と数える項目の評価回数を観測し、Xの比較を不一致として後続へ進むこと、端点の拡張、unique0の評価を確認する。

- width: 1, 32, 33, 64, 65, 129。
- expr_width: narrow, same, wide。
- expr_sign: unsigned, signed。
- item_sign: unsigned, signed。
- item_state: bit, logic。
- first: value, range, array, list。
- value: known, expr_x, item_x, item_z。
- qualifier: plain, unique0。
- third: variable, call。

制約: 幅1のnarrowは幅0になるため除外。全項目は同じ型・幅で、整数リテラルの項目は使わない。priority・uniqueは一致がないときの違反報告とdefaultの関係を本文が明記しないため対象外とし、unique0では一致する項目が1つ以下の入力だけを使う。項目内の複数の式の評価回数、副作用の順序、caseのcasez/casexは対象外

## clocking_input_sampling / model 1

- 制約を満たす組合せ数: 864。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 5。
- 2因子の計画上の網羅: 165/165。
- 3因子の計画上の網羅: 72/72。

3組の背景値でクロック前の値と更新後の値、cbでのサンプルとライブ値、起床回数を観測し、#1step/#0、blocking/NBA、状態型、クロック方向とlocal/interface/virtual modportの参照経路の相互作用を確認する。X/Z行にも既知値の対照を保持する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- access: local, interface, virtual。
- skew: step, zero。
- edge: posedge, negedge。
- update: blocking, nba。

制約: 全864行は合法。更新はmodule側のクロックエッジで行い、観測はcbイベントを待つ。刺激の準備・初期値の設定・観測は別時刻。X/Z行にも既知値の対照を置く。program由来のクロック、複数クロック、出力スキュー、inout、iff、同一時刻内の複数エッジは対象外。未対応による除外はしない

## assertion_sample_visibility / model 1

- 制約を満たす組合せ数: 2592。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 7。
- 2因子の計画上の網羅: 225/225。
- 3因子の計画上の網羅: 96/96。

更新前後の既知値とX/Zで、assertionのpass/fail回数、サンプル値と1ビットの式の値、Reactiveのライブ値と最終値を観測する。型、式、エッジ、blocking/NBA、更新時点、module/interfaceを組み合わせ、サンプリング時点とaction実行時点を区別する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- expression: reduce_or, equal, case_equal。
- edge: posedge, negedge。
- update: blocking, nba。
- timing: before, edge, after。
- home: module, interface。

制約: 全2592行は合法。単一クロックの単一サイクルBoolean propertyで、pass/failの両actionを明示する。初期化・刺激準備・最終観測は別時刻。X/Z行も既知値の正負対照を含む。program、clocking変数、automatic変数、disable iff、アサーション制御、時間演算と履歴関数は対象外。未対応では除外しない

## container_wait_visibility / model 1

- 制約を満たす組合せ数: 1440。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 214/214。
- 3因子の計画上の網羅: 88/88。

サイズ・先頭要素・両条件を待ち、動的配列とキューの作成・拡大・縮小・削除・同サイズ置換の前後で起床時刻・回数と全要素を観測する。無関係なコンテナ変更での早期起床を区別し、既に真の場合と、型変換後のX/Zをcase等価で待つ場合も確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- container: dynamic, queue。
- change: create, grow, shrink, clear, replace。
- condition: size, element, both。
- timing: waiting, ready。

制約: 空を含むcreate/clearはsize条件だけとし、無効な要素アクセスを作らない。同サイズのreplaceはelement/both条件だけとし、待機開始前の条件を偽にする。ready行は変更後に待機を開始。動的配列は準備済み配列からnewで置換し、キューはpush_front/pop_front/delete/全体代入で変更。未対応では除外しない。並行した複数変更・参照引数・連想配列・無効な添字は対象外

## class_method_reference / model 1

- 制約を満たす組合せ数: 1944。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 202/202。
- 3因子の計画上の網羅: 99/99。

2個の派生インスタンスをA/B/A順に呼び、virtual/非virtualの実行本体と所有者、再帰の入口・出口の仮引数とプロパティ、戻り値・カウンタ・ガードを観測する。inputのフレーム別コピーとref/const refの同一実体への参照、2状態変換を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- dispatch: direct, base_virtual, base_nonvirtual。
- kind: function, task。
- mode: input, ref, const_ref。
- depth: 0, 1, 3。

制約: 同一typedefのプロパティと仮引数を用い、型不一致を作らない。2個の派生インスタンスをA/B/A順に呼び、基底ハンドル経由のvirtual/非virtualと派生ハンドル直呼びを区別。クラスメソッドはautomatic、深さは有限、タスクも時間を消費しない。const ref自身には書かず、同じ実体のプロパティを更新。未対応では除外しない。配列・並行呼出し・super・時間制御は対象外

## function_loop_return / model 1

- 制約を満たす組合せ数: 864。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 161/161。
- 3因子の計画上の網羅: 120/120。

for/while/repeat内で最初の非0ビットからreturnし、戻り値・走査回数と添字の総和・末尾到達・return後の副作用を観測する。A/B/A呼出しでインスタンス別状態とpackageの共有状態、呼出し元の同名変数の保持、X/Zの2状態変換も確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- loop: for, while, repeat。
- stop: head, middle, tail, none。
- scope: local, package。

制約: 同じ幅・状態型のinputと戻り値を用い、0から幅未満までLSBから走査する。幅1のhead/middle/tailは同じ位置になる合法な境界条件として保持。!==0でX/Zも停止対象とし、bitへの変換による走査継続を区別。2インスタンスをA/B/A順に呼び、localの個別状態とpackageの共有状態を観測。未対応による除外なし。再帰・break/continue・並行呼出し・時間制御は対象外

## loop_assignment_order / model 1

- 制約を満たす組合せ数: 3888。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 246/246。
- 3因子の計画上の網羅: 111/111。

for/while/repeat内の複数代入で、途中結果を使うblockingと旧値からNBAを予約する動作を区別する。A/B/A呼出しの各反復の値・添字、ActiveとNBA後の全要素・カウンタ・ガードを観測し、書込み順序、状態変換、module/interfaceの独立した格納先を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- loop: for, while, repeat。
- count: 2, 3, 5。
- storage: scalar, same, rotate。
- update: blocking, nba。
- home: module, interface。

制約: 全行は合法。NBAの左辺は静的なスカラまたは固定配列要素だけとし、automaticタスクは右辺の一時値と添字を計算する。固定配列は[2:4]、sameは添字2、rotateは2+(i%3)。同じプロセスからA/B/A順に呼び、競合する別の書込み元を置かない。Activeでの観測後に1 tick進めてNBA完了後を観測する。未対応による除外なし。遅延付きNBA、動的配列、並行書込み、modportは対象外

## implicit_process_visibility / model 1

- 制約を満たす組合せ数: 1728。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 242/242。
- 3因子の計画上の網羅: 96/96。

宣言時初期値による時刻0の起動、data/maskと関数内部の読取りによる再実行、0/X/Zでのcombの既定値とlatchの保持を観測する。1変数ずつ変更して両インスタンスの出力・評価回数を確認し、無関係なnoiseと自己更新による余分な起動も区別する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- process: comb, latch。
- access: direct, function。
- home: module, interface。
- gate: zero, one, x, z。
- idle: zero, one, hold。

制約: combは無効時の出力をzero/oneへ代入し、latchだけがholdを選ぶ。入力の宣言時初期化を終えてから時刻0の自動実行を観測。各刺激で変えるのは1インスタンスの1変数だけで、1 tick後に両方を観測する。評価回数は単一プロセス内でだけ更新し、誤った自己再実行でも512回で止まる。functionは引数なしで同じインスタンスのdata/maskを読む。未対応による除外なし。並行ドライバ・遅延関数・動的添字・フィードバックを持つデータパスは対象外

## generate_scope_lookup / model 1

- 制約を満たす組合せ数: 576。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 148/148。
- 3因子の計画上の網羅: 68/68。

2インスタンスのgenerate要素を階層名で読み、選択分岐・局所宣言・genvar定数・型幅・package定数と連続代入の値を観測する。importと明示修飾、入れ子、型と定数の隠蔽、X/Zを含む入力変更への追従と各スコープの独立性を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- access: import, qualified。
- shadow: none, local。
- depth: one, two。
- branch: if, case。

制約: 全576行は合法。ワイルドカードimportと局所宣言の隠蔽を使い、衝突して不正になる明示importは使わない。2インスタンスのSELECTを0/1とし、それぞれ2個の生成要素を作る。分岐0だけが局所WIDTH/ORIGIN/word_tを宣言し、幅を1増やし状態型を逆にする。明示修飾は局所宣言があってもpackageの型・定数を使う。未対応による除外なし。動的な階層添字・config・defparam・無名generate・符号付き演算は対象外

## default_argument_scope / model 1

- 制約を満たす組合せ数: 720。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 159/159。
- 3因子の計画上の網羅: 128/128。

A/B/Aの階層呼出しで既定値の元を毎回変え、両仮引数・戻り値と宣言側/呼出し元の関数評価回数を観測する。省略・空欄・名前付き・明示0での評価抑止、呼出し時の宣言スコープへの束縛、型変換とmodule/interfaceの各インスタンスの独立性を確認する。

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- home: module, interface。
- expression: variable, function。
- passing: omitted, empty_data, named_data, explicit_zero, named_both。

制約: 全720行は合法。同じ型のinputと戻り値を用い、ANSI形式の2引数に既定値を定義する。呼出し元と2インスタンスに同名の変数・関数を用意する。A/B/A順に呼び、既定値の元を各呼出し前に更新する。2個の既定値関数は別々のカウンタだけを増やし、引数評価順序に依存する刺激・観測を作らない。未対応による除外なし。class・virtual interface・output/inout/ref・時間制御・再帰は対象外

## event_task_scope / model 1

- 制約を満たす組合せ数: 288。
- 利用できる既存・新規テスト: 13。
- 短時間実行の選択: 13。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 109/109。
- 3因子の計画上の網羅: 52/52。

module/interfaceの別インスタンスまたはpackageの2イベントをinput/refで渡し、1/2/3待機者の時刻・回数・値を観測する。待機前のトリガの不保持、通常/NBA起床の値の可視性、トリガ経路、逆順での再待機、noiseと完了後の余計な起動を区別する。

- home: module, interface, package。
- passing: input, ref。
- emitter: direct, task。
- trigger: blocking, nba。
- listeners: 1, 2, 3。
- order: a_b, b_a。
- arrival: early, late。

制約: 全288行は合法。静的寿命のイベントをautomatic taskのinput/refで渡す。待機は@だけで、呼出し後1/6 tickで登録する。トリガと観測は別tickに置き、複数待機者は別々の配列要素だけを更新する。静的stampへのNBAをトリガより先に予約し、Active/NBAで起床した観測値を区別する。イベント変数の代入・比較・null待機、triggered・wait_order・遅延付き非ブロッキングトリガ・virtual interface・自動変数の寿命は対象外。input/refの再結合の差は検査しない。未対応による除外なし

## continuous_delay_inertial / model 1

- 制約を満たす組合せ数: 504。
- 利用できる既存・新規テスト: 63。
- 短時間実行の選択: 63。
- 個別に保持する必須ケース: 7。
- 2因子の計画上の網羅: 141/141。
- 3因子の計画上の網羅: 129/129。

幅1のスカラと幅2以上のベクタで1/2/3個の遅延を使い、短パルスの除去と予約の取消しを観測する。bit/logic格納と反転後の値、X/Zの遅延選択、全体値の更新時刻・回数・最終変化時刻を毎tick照合する。

- width: 1, 2, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- profile: one, two, three。
- pulse: short, long。
- expression: direct, invert。

制約: 全504行は合法。幅1はスカラnet、幅2以上はベクタnetを使う。1ビットpacked vectorは対象外。遅延は5、(7,3)、(7,5,2)で、パルス幅1/10は遅延と一致しない。20 tickの初期整定後、Postponedで毎tick観測する。短パルスの復帰と既知値の再予約は、予約済み更新より前に実行する。net宣言の遅延・複数ドライバ・強度・SDF・min/typ/max・未知値の遅延は対象外。未対応による除外なし

## port_import_scope / model 1

- 制約を満たす組合せ数: 540。
- 利用できる既存・新規テスト: 39。
- 短時間実行の選択: 39。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 158/158。
- 3因子の計画上の網羅: 141/141。

packageのwildcard/明示import、局所宣言、.*・.name・明示接続で入力の接続先と既定値を区別する。既定値0/全1の2子と独立した対照スコープを観測し、ライブ値の追従・隠蔽・型変換を確認する。

- width: 1, 32, 33, 64, 65, 129。
- sample_state: bit, logic。
- value: known, x, z。
- import_style: wild, explicit。
- shadow: none, local。
- binding: star, short, named, qualified, zero。

制約: 明示importと同名の局所宣言の併用180行は26.3で不正なため除外し、合法540行を対象とする。すべての接続型・幅を揃え、input/outputは明示した4状態wire。bit/logicは整定後のサンプル型。各親に既定値0/全1の2子を置き、別の親スコープの対照は常にwildcard importと.*だけを使う。.*だけのスコープに別の無修飾p参照を作らない。default_nettype noneで暗黙netを禁止する。空の実引数・幅変換・競合する複数package・inout/refは対象外。未対応による除外なし

## typed_memory_file / model 1

- 制約を満たす組合せ数: 2880。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 248/248。
- 3因子の計画上の網羅: 82/82。

bit/logicと列挙型のメモリファイルを出力し、元配列の変更後に別の添字範囲へ読み込む。独立に用意した入力も読み込み、要素の値・範囲外の保持・宣言方向と読込み順・上書きを照合する。

- width: 1, 32, 33, 64, 65, 129。
- source_state: bit, logic。
- kind: plain, enum。
- value: known, x, z。
- format: bin, hex。
- span: all, middle, single。
- declaration: up, down。
- target_state: bit, logic。
- read_order: forward, reverse。

制約: 固定1次元配列を使う。singleの逆順は開始/終了が同じで等価なため順方向に代表させ、576行を重複削減して2880行とする。全行は合法で未対応による除外なし。元配列は[2:6]、書込みは2:6/3:5/4:4、読込み先は[10:16]または[16:10]で11からの1/3/5要素だけを更新する。enumへの格納は明示キャスト。未知値はニブル単位に揃え、hexでの部分ニブルの情報損失を混ぜない。動的/連想配列・多次元・幅変換・符号変換は対象外

## program_descendant_shutdown / model 1

- 制約を満たす組合せ数: 288。
- 利用できる既存・新規テスト: 18。
- 短時間実行の選択: 18。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 109/109。
- 3因子の計画上の網羅: 38/38。

programの自然終了と直接/タスク内の$exit、複数initial、子/孫プロセスの待機を組み合わせる。終了前の進捗と終了後の書込み取消し、同じ待機条件を持つ別programの起床、最後のprogramによる暗黙終了を観測する。

- finish: natural, exit, task。
- initials: one, two。
- waiting: delay, event, level。
- topology: flat, nested。
- progress: waiting, partial。
- spawn: none, any。
- keepers: one, two。

制約: 288行はすべて合法で未対応による除外なし。対象programの主initialは時刻4で終了または$exitを呼び、追加initialは6で終わる。子の観測点は5、解放は7/8で、自然終了の全initial待ちと明示終了を区別する。別programは12/15まで存続し、moduleの20の番兵より先に暗黙の$finishが起きる。データ幅・状態型は因子に水増ししない

## implicit_port_nettype / model 1

- 制約を満たす組合せ数: 576。
- 利用できる既存・新規テスト: 40。
- 短時間実行の選択: 40。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 156/156。
- 3因子の計画上の網羅: 72/72。

ANSI/非ANSIのポート宣言でnet型を省略し、default_nettypeによるvectorとscalarの解決値・幅を親子で照合する。vectorだけの明示wireによる上書きと、指示解除後の別moduleを同じ刺激で比較し、既定型の適用範囲を確認する。

- nettype: wire, tri, wand, triand, wor, trior。
- width: 1, 32, 33, 64, 65, 129。
- style: nonansi, ansi。
- override: implicit, wire。
- value: binary, xz。
- reset: wire, resetall。

制約: 576行はすべて合法で未対応による除外なし。等強度の2ドライバでwire/tri、wand/triand、wor/triorを検査する。各別名は指示の字句と宣言規則の検査のため保持する。暗黙のscalar出力を対照にし、vector出力だけを明示wireで上書きできる。後続moduleはdefault_nettype wireまたはresetall後に定義する。none/uwireの不正な多重駆動、tri0/tri1のpull、triregの電荷保持、強度差・遅延は対象外。binary刺激にもwireの競合によるXがあるため全件fourstate=yes

## generated_interface_binding / model 1

- 制約を満たす組合せ数: 864。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 165/165。
- 3因子の計画上の網羅: 74/74。

generate要素ごとに幅の違うinterfaceを2個置き、if/caseで選択した側をwhole/modportのwriter/readerへ接続する。bit/logicへの格納前の反転、非選択側の対照、実際の幅・識別タグ・接続先と全要素の独立性を観測する。

- base_width: 1, 32, 33, 64, 65, 129。
- count: 1, 2, 3。
- form: if, case。
- route: a, b。
- access: whole, modport。
- state: bit, logic。
- value: known, x, z。

制約: 864行はすべて合法で未対応による除外なし。generate要素iの幅は基底幅+i、最大131ビット。各要素に同じ型のinterfaceを2個置き、選択した側だけwriter/readerへ接続し、他方を対照として駆動する。if/caseの二つの選択肢には同じroute名を使う。b側は反転後にinterfaceのbit/logic型へ格納する。13回の既知刺激で全要素・ビット位置・active/guardを識別し、X/Zには3回の追加刺激を与える。virtual interface、interface配列ポート、clocking、modportの不正アクセスは対象外

## program_reactive_handoff / model 1

- 制約を満たす組合せ数: 1296。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 183/183。
- 3因子の計画上の網羅: 84/84。

moduleのNBA連鎖の完了前後を、早いmodule内の対照とReactiveで動くprogramで観測する。連続代入・blocking・Re-NBAの出力と採取値、型変換、全段の値・NBA予約回数・採取した文脈を照合する。

- width: 1, 32, 33, 64, 65, 129。
- source_state: bit, logic。
- value: known, x, z。
- depth: 1, 2, 3。
- update: blocking, nba。
- producer: continuous, blocking, nba。
- operation: direct, invert。

制約: 1296行はすべて合法で未対応による除外なし。moduleのsource更新から1/2/3段のNBA連鎖を起こす。programは連続代入またはイベント待機後のblocking/NBAで出力する。module内の同じ式は早い対照。16回の既知刺激でビット位置を識別し、X/Zの各刺激直前には全1を与えて変化を保証する。各刺激を10時刻離し、1時刻後に値と採取済み文脈を観測する。自動変数へのNBA、clocking、複数書込みの競合、同時刻の外部刺激は対象外

## configuration_generated_shape / model 1

- 制約を満たす組合せ数: 1056。
- 利用できる既存・新規テスト: 41。
- 短時間実行の選択: 41。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 213/213。
- 3因子の計画上の網羅: 80/80。

configの設定・Wだけのリセット・全パラメータのリセットを、既定値・インスタンス指定・defparamと比較する。通常階層の親パラメータとconfig localparamの隠蔽、生成した幅・個数・if/case分岐、対象外の兄弟を観測する。

- base_width: 1, 32, 33, 64, 65, 129。
- prior: default, instance, defparam, both。
- action: set, reset_w, reset_all。
- mode: 0, 1, 2。
- form: if, case。
- rhs: literal, local, parent。
- hierarchy: direct, wrapped。

制約: 全直積2592行のうち、resetで使わないmode/rhsは0/literalに代表させ、1536行の重複を省いて1056行とする。全行は合法で未対応による除外なし。configは通常のmodule階層にあるtargetのW/MODEを設定し、そのパラメータでgenerateの幅・個数・分岐を決める。reset_wはWだけ、reset_allは全パラメータを既定値へ戻す。対照guardはconfig/defparamの対象外。RHSは数値・config localparam・通常の親moduleパラメータのみ。generate内部へのconfig参照、セル置換、ライブラリ差替え、未知値パラメータは対象外

## udp_array_strength / model 1

- 制約を満たす組合せ数: 1152。
- 利用できる既存・新規テスト: 25。
- 短時間実行の選択: 25。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 182/182。
- 3因子の計画上の網羅: 80/80。

組合せUDPの配列へベクタをビット分配し、スカラーを共通接続する。単独出力・競合する別ドライバ付きの出力・名前なしの単一UDPを比較し、強度・全4状態の入力対・位置識別を照合する。

- width: 1, 32, 33, 64, 65, 129。
- udp: andnot, ornot。
- drive: default, pull, strong_weak, weak_strong。
- contender: weak, pull, strong。
- array_order: down, up。
- port_order: down, up。
- input_mode: scalar, vector。

制約: 全1152行が合法。組合せUDPのみ。両配列は同じ強度と入力を持ち、一方だけ別ドライバと競合する。既知入力の識別刺激では競合値0/1/Zをすべて観測する。4状態の全入力対では競合側をZに解放する。逐次UDP・遅延・%v・名前付き配列要素の階層参照・個別要素への設定は対象外。未対応による除外なし

## generated_udp_state / model 1

- 制約を満たす組合せ数: 864。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 165/165。
- 3因子の計画上の網羅: 68/68。

generateで初期値の異なる逐次UDPをビットごとに選択し、共通/交互のクロックで個別の状態を採取・保持する。bit/logicへのX/Z格納、未知入力前の全1準備、既知値への回復、別クロックの対照の保持と後の採取を照合する。

- width: 1, 32, 33, 64, 65, 129。
- storage: bit, logic。
- value: known, x, z。
- edge: rise, fall。
- offset: 0, 1, 2。
- form: if, case。
- clocks: shared, masked。

制約: 全864行が合法。generateの各ビットで初期値0/1/初期指定なしを(i+offset)%3で選択し、対照は一つずらした初期値を持つ別UDPとする。既知の0/1クロックのみで、データ更新とは1 ns離す。先にtargetだけ、後でguardだけを駆動する。未知入力の前には全1を採取させ、最後に既知値へ回復する。未知クロック・同時入力変化・逐次UDPの遅延・駆動強度・配列形式のプリミティブは対象外。未対応による除外なし

## interface_header_import / model 1

- 制約を満たす組合せ数: 1296。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 183/183。
- 3因子の計画上の網羅: 78/78。

interfaceヘッダのimportでパラメータ既定値・型・package関数を結合し、targetだけの幅/タグ変更をguardと比較する。同名の呼出し側宣言を対照に、bit/logicの仮引数変換がpackage関数の演算前に行われる順序と実際の幅・中間値を照合する。

- width: 1, 32, 33, 64, 65, 129。
- storage: bit, logic。
- value: known, x, z。
- package: a, b。
- imports: wildcard, explicit, export。
- header: ansi, nonansi。
- override: defaults, narrow, wide。

制約: 全1296行が合法。ヘッダのimportはパラメータ既定値・入力型・本体の型と関数を供給する。export経路は中継packageで5項目を明示importしてからexportし、未使用のwildcard候補を再公開しない。targetだけの幅/タグの上書きと、既定値のguardを比較する。入力はlogic型、package関数の仮引数はbit/logic型。競合するimport、型パラメータの変更、modport、virtual interface、時間を使うpackageサブルーチンは対象外。未対応による除外なし

## mailbox_class_alias / model 1

- 制約を満たす組合せ数: 3456。
- 利用できる既存・新規テスト: 36。
- 短時間実行の選択: 36。
- 個別に保持する必須ケース: 9。
- 2因子の計画上の網羅: 245/245。
- 3因子の計画上の網羅: 92/92。

classハンドルをtyped/typelessのmailboxへ渡し、FIFO・get/peek・容量制限・nullメッセージと取得前後の双方向のメンバ更新を確認する。別mailboxの保持と後の更新、空の非ブロッキング戻り値も観測する。

- width: 1, 32, 33, 64, 65, 129。
- storage: bit, logic。
- value: known, x, z。
- typing: typed, typeless。
- operation: get, try_get, peek, try_peek。
- update: before, after, both。
- capacity: bounded, unbounded。
- tail: object, null。

制約: 全3456行が合法。同じpacket型のハンドルだけを送り、型不一致は対象外。満杯/空の確認には非ブロッキングメソッドを使い、get/peekは格納後に呼ぶ。1プロセス内の直列操作で、待機プロセスの選択順や同時実行の競合は対象外。typeless、4状態、nullも未対応を理由に除外しない。

## array_reduction_constraint / model 1

- 制約を満たす組合せ数: 192。
- 利用できる既存・新規テスト: 13。
- 短時間実行の選択: 13。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 96/96。
- 3因子の計画上の網羅: 40/40。

固定配列と動的配列の一意な解と矛盾を切り替え、要素型とwith式の型でのリダクション、演算前の拡張、失敗時の全要素とサイズの保持、独立した対照オブジェクトを照合する。

- width: 4, 8, 33。
- sign: unsigned, signed。
- kind: fixed, dynamic。
- method: sum, product。
- projection: element, wide。
- length: 2, 3。
- sequence: sat_fail_sat, fail_sat_fail。

制約: 全192行が合法。各要素の制約で成功時の解を一意にし、リダクション条件だけを矛盾させる。先頭を型の端点、残りを3または-3にして、要素幅とlongint拡張後の結果を区別する。動的配列は初期サイズを要求より1要素多くし、失敗時のサイズと値の保持を観測する。別オブジェクトは毎回成功する対照とする。乱数列の一致を要求しない。全演算は拡張後64ビットの範囲内。空配列、X/Z、キュー、soft制約、継承、コールバック、並行実行は対象外。未対応による除外なし。

## associative_array_queries / model 1

- 制約を満たす組合せ数: 216。
- 利用できる既存・新規テスト: 18。
- 短時間実行の選択: 18。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 93/93。
- 3因子の計画上の網羅: 54/54。

連想配列の挿入・上書き・削除・再利用で、添字型の範囲と割当て済みの範囲、問い合わせのinteger変換とfirst/lastの幅・符号、要素数と全キー/値を照合する。

- width: 4, 8, 33。
- sign: unsigned, signed。
- keys: compact, extreme。
- order: ascending, descending, zigzag。
- delete: low, middle, high。
- dimension: implicit, explicit。

制約: 全216行が合法。既知の整数型添字を使い、3個の異なるキーを挿入する。型の範囲と割当て済みの範囲、上書きと新規割当て、単独削除と全削除を区別する。問い合わせの戻り値は32ビット符号付きintegerへ変換する。空配列のlow/highとfirst/lastの出力引数は読まない。X/Zの添字、文字列/ワイルドカード添字、多次元配列、並行更新は対象外。未対応による除外なし。

## clocking_event_iff / model 1

- 制約を満たす組合せ数: 288。
- 利用できる既存・新規テスト: 12。
- 短時間実行の選択: 12。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 109/109。
- 3因子の計画上の網羅: 44/44。

iffで選別したclocking eventとrawエッジを別計数し、通過時の採取と不通過時のサンプル保持を照合する。ガードだけの前後の変更、33ビットの上位1、入力skew・更新方式を交差し、cbと観測器の値を比較する。

- width: 1, 8, 33。
- state: bit, logic。
- edge: posedge, negedge。
- skew: step, zero。
- update: blocking, nba。
- guard_shape: scalar, wide_low, wide_high。
- guard_timing: before, after。

制約: 全288行が合法。既知の0/1ガードだけを使い、33ビットの下位/上位1による真偽も確認する。ウォームアップでclockvarを既知の0にし、ガードだけの変更・rawエッジ・後続のガード変更を別時刻にする。入力はmoduleのrawエッジで更新し、cbイベントを待つ観測器で採取する。通過しないエッジとガードだけの変更では前のサンプルを保持する。blocking/NBAはObservedより後の同じ結果を照合する経路対照。X/Z、同時刻のガード更新、出力skew、program、interface、複数クロック、アサーションは対象外。未対応による除外なし。

## class_virtual_interface / model 1

- 制約を満たす組合せ数: 192。
- 利用できる既存・新規テスト: 13。
- 短時間実行の選択: 13。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 96/96。
- 3因子の計画上の網羅: 48/48。

クラスのvirtual interfaceの結合を浅いコピー/ハンドル代入で比較し、再結合とnull時の書込み抑止を照合する。別に保存した参照・元/コピーの結合先・成功回数・guardを、メソッド/直接経路とfull/modport型で確認する。

- width: 1, 8, 33。
- state: bit, logic。
- port: full, modport。
- initial: a, b。
- copy: shallow, alias。
- actor: source, copy。
- access: method, property。

制約: 全192行が合法。3個のinterfaceは同じ型で、tagは11/22/33とする。full型またはdataをrefとして公開する同じmodport型を一貫して使う。クラスの浅いコピーはvirtual interface変数を別々に持ち、ハンドル代入はクラス実体を共有する。元/コピーの片方を別interface→null→元interfaceへ再結合し、保存した参照を別に観測する。null時は比較とガードだけを行い、メンバを参照せず書込み回数も変えない。既知値だけを使い、bit/logicは等価性の対照とする。X/Z、型不一致、null参照の異常終了、継承、clocking、時間制御、並行駆動は対象外。未対応による除外なし。

## resolved_strength_format / model 1

- 制約を満たす組合せ数: 180。
- 利用できる既存・新規テスト: 31。
- 短時間実行の選択: 31。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 87/87。
- 3因子の計画上の網羅: 78/78。

2ドライバの競合・解放とtri0/tri1のpull既定値を、3種類のformat APIで値と強度を分けて照合する。強度差・更新順・極性を交差し、全11観測の上書きと独立したsupply対照を確認する。

- net: wire, tri0, tri1。
- strengths: equal_weak, equal_pull, equal_strong, a_stronger, b_stronger。
- order: ab, ba。
- api: display, sformatf, swrite。
- polarity: normal, inverse。

制約: 全180行が合法。2個の連続代入は0/1それぞれで同じ単一強度を持つ。ドライバには既知の0/1とZだけを与え、Xは同強度の0/1競合で作る。wireの解放時とtri0/tri1の既定pullを比較し、各書込みと観測を1tick離す。全11観測でscalar netを直接format APIへ渡し、stringは毎回上書きする。別のsupply0/supply1を強度表示の対照にする。曖昧な駆動強度、L/H、強度範囲の数字表示、trireg、wired logic、ベクタ、遅延付きゲート、変数経由の強度伝達、ファイル出力は対象外。未対応による除外なし。

## class_array_shallow_copy / model 1

- 制約を満たす組合せ数: 240。
- 利用できる既存・新規テスト: 18。
- 短時間実行の選択: 18。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 108/108。
- 3因子の計画上の網羅: 60/60。

クラスの浅いコピーとハンドル代入を対照に、配列領域の独立性と要素ハンドルの参照先の共有を照合する。元/コピーからの要素置換・拡大/縮小、保存ハンドルの存続、コンストラクタ回数と別guardの保持を確認する。

- container: fixed, dynamic, queue。
- width: 1, 8, 33。
- length: 1, 3。
- position: first, last。
- copy: shallow, alias。
- writer: source, copy。
- operation: element, resize。

制約: 直積288行のうち合法240行。固定配列のresizeだけを水準の意味から除く。未対応を理由とする除外なし。各holderは同じ形状のbitベクタ配列とクラスハンドル配列を持つ。浅いコピーでは配列の要素格納領域を独立させ、要素ハンドルの参照先は共有する。ハンドル代入を共有の対照とし、元/コピーのどちらかから変更する。サイズ変更は1→3または3→1で、残す接頭部と追加要素の既定値を確認する。保存した要素ハンドルは、置換や縮小後も参照先を保持する。初回長1のfirst/lastは等価な対照。X/Z、空配列、継承、rand状態、covergroup、ref、並行実行は対象外。

## dpi_openarray_shape / model 1

- 制約を満たす組合せ数: 168。
- 利用できる既存・新規テスト: 30。
- 短時間実行の選択: 30。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 100/100。
- 3因子の計画上の網羅: 72/72。

固定/動的配列/キューをopen arrayとしてDPIへ渡し、各呼出しの範囲・全要素・復帰後の書戻しを照合する。入力方向・数値順の走査方向・符号パターン・繰返し前の拡大/縮小を交差し、別のguard配列の保持も確認する。

- actual: ascending, descending, dynamic, queue。
- direction: input, output, inout。
- length: 1, 3, 5。
- pattern: positive, mixed。
- walk: ascending, descending。
- calls: stable, resize。

制約: 直積288行のうち合法168行。7.7で禁止される動的配列/キューのopen outputを除き、固定配列のresizeは水準の意味に合わないため除く。未対応による除外なし。int要素の1次元open arrayだけを使い、2回の呼出しで全要素を再設定する。resizeは1→3、3→5、5→2とし、Cの各呼出しの範囲と全要素、復帰後の書戻しを照合する。outputの初期値は読まない。Cでは要素ポインタを毎回取得し、全体の連続配置を仮定しない。X/Z、空配列、多次元、sized formal、ref、Cからの再入、ハンドルの持越しは対象外。

## clocking_assertion_sampling / model 1

- 制約を満たす組合せ数: 288。
- 利用できる既存・新規テスト: 18。
- 短時間実行の選択: 18。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 109/109。
- 3因子の計画上の網羅: 50/50。

既定/明示の#1step clocking入力を、そのイベントと後続の別クロックのアサーションで観測する。更新の前後とblocking/NBA、独立したエッジ極性を組み合わせ、sampled値・Reactiveの生信号・判定回数を分けて照合し、別クロックでの誤った再サンプリングを検出する。

- width: 1, 8, 33。
- state: bit, logic。
- sample_edge: posedge, negedge。
- probe_edge: posedge, negedge。
- timing: early, edge, between。
- update: blocking, nba。
- declaration: default, explicit。

制約: 全288行が合法。アサーションが参照するclocking入力は16.5.1に従い#1stepだけを使い、既定と明示指定を比較する。サンプル用と評価用のクロックは別信号で、各周期の時刻8と12に駆動する。更新は時刻6/8/10、観測は時刻14に分離する。同じslotの#1step値とReactiveの生信号、後続の別クロックでの保持値を照合する。X/Z、非#1step入力の不正な使用、出力skew、program、時間演算、disable iff、同時クロックは対象外。未対応による除外なし。

## constraint_inheritance / model 1

- 制約を満たす組合せ数: 96。
- 利用できる既存・新規テスト: 13。
- 短時間実行の選択: 13。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 70/70。
- 3因子の計画上の網羅: 40/40。

基底/派生ハンドルから3階層の継承制約を解き、同名の置換・別名の追加とpure/externの完了を照合する。一意解と矛盾を交互に与え、初回失敗時の初期値・成功後の値の保持と、別オブジェクトの独立した成功を確認する。

- handle: base, derived。
- rule: replace, add。
- origin: concrete, pure。
- definition: inline, extern。
- sequence: sat_fail_sat, fail_sat_fail。
- width: 4, 8, 33。

制約: 全96行が合法。3階層の継承でpure制約は中間クラスが実装し、派生クラスの同名制約は置換、別名制約は追加になる。成功時の解は一意で、乱数の値や探索順序に依存しない。非randフラグで充足可能と矛盾を切り替え、失敗時の初期値または直前の解を保持する。別オブジェクトは反対の静的型のハンドルから毎回成功する対照とする。X/Z、randc、soft、constraint_mode、rand_mode、乱数列の一致は対象外。未対応による除外なし。

## dpi_nba_capture / model 1

- 制約を満たす組合せ数: 144。
- 利用できる既存・新規テスト: 18。
- 短時間実行の選択: 18。
- 個別に保持する必須ケース: 4。
- 2因子の計画上の網羅: 81/81。
- 3因子の計画上の網羅: 48/48。

DPIのinput/output/inoutとNBA予約の前後、同じ/別の配列要素を組み合わせる。幅・符号・bit/logicからintへの変換、復帰直後の書戻し、予約後の添字・値の変更、Postponedと次時刻の全要素を照合し、NBAの値と代入先の確定を確認する。

- direction: input, output, inout。
- order: nba_first, dpi_first。
- actual: same, other。
- width: 8, 32, 65。
- signedness: unsigned, signed。
- state: bit, logic。

制約: 全144行が合法。固定長配列の静的寿命の要素だけを使用する。DPIのint仮引数に既知値を渡し、入力の幅・符号変換と復帰直後の書戻しを観測する。同一プロセスでNBA予約とDPI呼出しを順序付け、予約後に添字・右辺・元要素を変更する。outputの初期値は読まない。X/Z、open array、CからのSV再入、時間を消費するDPI task、競合する別プロセスは対象外。未対応による除外なし。

## event_rebinding / model 1

- 制約を満たす組合せ数: 648。
- 利用できる既存・新規テスト: 27。
- 短時間実行の選択: 27。
- 個別に保持する必須ケース: 6。
- 2因子の計画上の網羅: 138/138。
- 3因子の計画上の網羅: 69/69。

静的イベントをタスク呼出し前・待機登録前・登録後に再結合し、inputのコピーとref/直接参照、登録済み待機の保持、複数待機者、後着待機者、別名の独立性とActive/NBAの観測値を照合する。

- home: module, interface, package。
- passing: direct, input, ref。
- rebind: before_call, before_arm, after_arm。
- trigger: blocking, nba。
- aliases: single, chain。
- order: old_new, new_old。
- listeners: 1, 2, 3。

制約: 全648行が合法。静的寿命のイベントを使用し、呼出しは時刻2、待機登録は時刻4、再結合は時刻1/3/5に分離する。inputは呼出し時のハンドルをコピーし、refと直接参照は待機登録時の値を用いる。登録済みの@は再結合後も元の同期オブジェクトを待つ。nullは全待機完了後の代入・比較・無効果のトリガだけに使用する。nullへの待機、triggered、wait_order、自動イベントの回収、同一tickの再結合と登録の競合は対象外。未対応による除外なし。

<a id="verify-that-the-input-fingerprint-matches-the-execution"></a>

## 入力指紋が一致した実行の確認

各スナップショットを独立に評価します。複数の版・実行の部分成功を合成しません。 passだけを合格の証跡とし、known・unsupported・staleを合格へ含めません。 この集計は期待値との一致を確認した組合せの割合です。失敗実行からの生の到達率は未計測です。

### results/ghost.json

- 環境: private build 4d414f2efa2c。
- 実行日時: 2026-11-02T14:07:17.692135+00:00。

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
- argument_binding_index:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 5/5。
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
  - 2因子の合格確認済み組合せ: 260/261。
  - 3因子の合格確認済み組合せ: 154/162。
  - 必須ケース: 7/8。
  - ケース状態: pass=69, fail=3, known=0, unsupported=0, stale=0, not_run=0。
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
- queue_element_reference:
  - 2因子の合格確認済み組合せ: 257/257。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 5/5。
  - ケース状態: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0。
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
- logical_short_circuit:
  - 2因子の合格確認済み組合せ: 214/214。
  - 3因子の合格確認済み組合せ: 236/236。
  - 必須ケース: 5/5。
  - ケース状態: pass=92, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- edge_event_expression:
  - 2因子の合格確認済み組合せ: 235/260。
  - 3因子の合格確認済み組合せ: 121/152。
  - 必須ケース: 4/5。
  - ケース状態: pass=48, fail=16, known=0, unsupported=0, stale=0, not_run=0。
- event_or_iff:
  - 2因子の合格確認済み組合せ: 85/104。
  - 3因子の合格確認済み組合せ: 32/59。
  - 必須ケース: 2/4。
  - ケース状態: pass=12, fail=15, known=0, unsupported=0, stale=0, not_run=0。
- heap_file_monitor_context:
  - 2因子の合格確認済み組合せ: 40/40。
  - 必須ケース: 3/3。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- compound_shift_target:
  - 2因子の合格確認済み組合せ: 271/308。
  - 3因子の合格確認済み組合せ: 72/90。
  - 必須ケース: 2/4。
  - ケース状態: pass=33, fail=7, known=0, unsupported=0, stale=0, not_run=0。
- membership_container:
  - 2因子の合格確認済み組合せ: 305/305。
  - 3因子の合格確認済み組合せ: 174/174。
  - 必須ケース: 5/5。
  - ケース状態: pass=46, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- membership_range:
  - 2因子の合格確認済み組合せ: 301/303。
  - 3因子の合格確認済み組合せ: 175/178。
  - 必須ケース: 6/6。
  - ケース状態: pass=45, fail=1, known=0, unsupported=0, stale=0, not_run=0。
- case_inside_selection:
  - 2因子の合格確認済み組合せ: 306/315。
  - 3因子の合格確認済み組合せ: 128/154。
  - 必須ケース: 6/7。
  - ケース状態: pass=28, fail=6, known=0, unsupported=0, stale=0, not_run=0。
- clocking_input_sampling:
  - 2因子の合格確認済み組合せ: 165/165。
  - 3因子の合格確認済み組合せ: 72/72。
  - 必須ケース: 5/5。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- assertion_sample_visibility:
  - 2因子の合格確認済み組合せ: 225/225。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 7/7。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- container_wait_visibility:
  - 2因子の合格確認済み組合せ: 214/214。
  - 3因子の合格確認済み組合せ: 88/88。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- class_method_reference:
  - 2因子の合格確認済み組合せ: 172/202。
  - 3因子の合格確認済み組合せ: 65/99。
  - 必須ケース: 3/6。
  - ケース状態: pass=26, fail=10, known=0, unsupported=0, stale=0, not_run=0。
- function_loop_return:
  - 2因子の合格確認済み組合せ: 157/161。
  - 3因子の合格確認済み組合せ: 91/120。
  - 必須ケース: 5/6。
  - ケース状態: pass=27, fail=9, known=0, unsupported=0, stale=0, not_run=0。
- loop_assignment_order:
  - 2因子の合格確認済み組合せ: 246/246。
  - 3因子の合格確認済み組合せ: 111/111。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- implicit_process_visibility:
  - 2因子の合格確認済み組合せ: 242/242。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- generate_scope_lookup:
  - 2因子の合格確認済み組合せ: 148/148。
  - 3因子の合格確認済み組合せ: 68/68。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- default_argument_scope:
  - 2因子の合格確認済み組合せ: 159/159。
  - 3因子の合格確認済み組合せ: 128/128。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- event_task_scope:
  - 2因子の合格確認済み組合せ: 109/109。
  - 3因子の合格確認済み組合せ: 52/52。
  - 必須ケース: 6/6。
  - ケース状態: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- continuous_delay_inertial:
  - 2因子の合格確認済み組合せ: 141/141。
  - 3因子の合格確認済み組合せ: 129/129。
  - 必須ケース: 7/7。
  - ケース状態: pass=63, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- port_import_scope:
  - 2因子の合格確認済み組合せ: 158/158。
  - 3因子の合格確認済み組合せ: 141/141。
  - 必須ケース: 6/6。
  - ケース状態: pass=39, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- typed_memory_file:
  - 2因子の合格確認済み組合せ: 248/248。
  - 3因子の合格確認済み組合せ: 82/82。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- program_descendant_shutdown:
  - 2因子の合格確認済み組合せ: 109/109。
  - 3因子の合格確認済み組合せ: 38/38。
  - 必須ケース: 4/4。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- implicit_port_nettype:
  - 2因子の合格確認済み組合せ: 156/156。
  - 3因子の合格確認済み組合せ: 72/72。
  - 必須ケース: 6/6。
  - ケース状態: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- generated_interface_binding:
  - 2因子の合格確認済み組合せ: 0/165。
  - 3因子の合格確認済み組合せ: 0/74。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=36, known=0, unsupported=0, stale=0, not_run=0。
- program_reactive_handoff:
  - 2因子の合格確認済み組合せ: 183/183。
  - 3因子の合格確認済み組合せ: 84/84。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- configuration_generated_shape:
  - 2因子の合格確認済み組合せ: 207/213。
  - 3因子の合格確認済み組合せ: 72/80。
  - 必須ケース: 6/6。
  - ケース状態: pass=37, fail=4, known=0, unsupported=0, stale=0, not_run=0。
- udp_array_strength:
  - 2因子の合格確認済み組合せ: 182/182。
  - 3因子の合格確認済み組合せ: 80/80。
  - 必須ケース: 6/6。
  - ケース状態: pass=25, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- generated_udp_state:
  - 2因子の合格確認済み組合せ: 165/165。
  - 3因子の合格確認済み組合せ: 68/68。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- interface_header_import:
  - 2因子の合格確認済み組合せ: 0/183。
  - 3因子の合格確認済み組合せ: 0/78。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=36, known=0, unsupported=0, stale=0, not_run=0。
- mailbox_class_alias:
  - 2因子の合格確認済み組合せ: 245/245。
  - 3因子の合格確認済み組合せ: 92/92。
  - 必須ケース: 9/9。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- array_reduction_constraint:
  - 2因子の合格確認済み組合せ: 44/96。
  - 3因子の合格確認済み組合せ: 11/40。
  - 必須ケース: 1/4。
  - ケース状態: pass=3, fail=10, known=0, unsupported=0, stale=0, not_run=0。
- associative_array_queries:
  - 2因子の合格確認済み組合せ: 93/93。
  - 3因子の合格確認済み組合せ: 54/54。
  - 必須ケース: 4/4。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- clocking_event_iff:
  - 2因子の合格確認済み組合せ: 109/109。
  - 3因子の合格確認済み組合せ: 44/44。
  - 必須ケース: 4/4。
  - ケース状態: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- class_virtual_interface:
  - 2因子の合格確認済み組合せ: 96/96。
  - 3因子の合格確認済み組合せ: 48/48。
  - 必須ケース: 4/4。
  - ケース状態: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- resolved_strength_format:
  - 2因子の合格確認済み組合せ: 87/87。
  - 3因子の合格確認済み組合せ: 78/78。
  - 必須ケース: 4/4。
  - ケース状態: pass=31, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- class_array_shallow_copy:
  - 2因子の合格確認済み組合せ: 108/108。
  - 3因子の合格確認済み組合せ: 60/60。
  - 必須ケース: 4/4。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- dpi_openarray_shape:
  - 2因子の合格確認済み組合せ: 93/100。
  - 3因子の合格確認済み組合せ: 57/72。
  - 必須ケース: 3/4。
  - ケース状態: pass=25, fail=5, known=0, unsupported=0, stale=0, not_run=0。
- clocking_assertion_sampling:
  - 2因子の合格確認済み組合せ: 109/109。
  - 3因子の合格確認済み組合せ: 50/50。
  - 必須ケース: 4/4。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- constraint_inheritance:
  - 2因子の合格確認済み組合せ: 70/70。
  - 3因子の合格確認済み組合せ: 40/40。
  - 必須ケース: 4/4。
  - ケース状態: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- dpi_nba_capture:
  - 2因子の合格確認済み組合せ: 55/81。
  - 3因子の合格確認済み組合せ: 16/48。
  - 必須ケース: 1/4。
  - ケース状態: pass=6, fail=12, known=0, unsupported=0, stale=0, not_run=0。
- event_rebinding:
  - 2因子の合格確認済み組合せ: 0/138。
  - 3因子の合格確認済み組合せ: 0/69。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=27, known=0, unsupported=0, stale=0, not_run=0。

### results/icarus.json

- 環境: Icarus Verilog version 14.0 (devel) (s20260301-802-g61dbc3c2)。
- 実行日時: 2026-11-02T13:43:50.902943+00:00。

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
- argument_binding_index:
  - 2因子の合格確認済み組合せ: 104/162。
  - 3因子の合格確認済み組合せ: 27/63。
  - 必須ケース: 1/5。
  - ケース状態: pass=18, fail=0, known=18, unsupported=0, stale=0, not_run=0。
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
- queue_element_reference:
  - 2因子の合格確認済み組合せ: 0/257。
  - 3因子の合格確認済み組合せ: 0/96。
  - 必須ケース: 0/5。
  - ケース状態: pass=0, fail=0, known=60, unsupported=0, stale=0, not_run=0。
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
- logical_short_circuit:
  - 2因子の合格確認済み組合せ: 214/214。
  - 3因子の合格確認済み組合せ: 236/236。
  - 必須ケース: 5/5。
  - ケース状態: pass=92, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- edge_event_expression:
  - 2因子の合格確認済み組合せ: 260/260。
  - 3因子の合格確認済み組合せ: 152/152。
  - 必須ケース: 5/5。
  - ケース状態: pass=64, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- event_or_iff:
  - 2因子の合格確認済み組合せ: 0/104。
  - 3因子の合格確認済み組合せ: 0/59。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=27, unsupported=0, stale=0, not_run=0。
- heap_file_monitor_context:
  - 2因子の合格確認済み組合せ: 0/40。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- compound_shift_target:
  - 2因子の合格確認済み組合せ: 293/308。
  - 3因子の合格確認済み組合せ: 82/90。
  - 必須ケース: 3/4。
  - ケース状態: pass=34, fail=0, known=6, unsupported=0, stale=0, not_run=0。
- membership_container:
  - 2因子の合格確認済み組合せ: 0/305。
  - 3因子の合格確認済み組合せ: 0/174。
  - 必須ケース: 0/5。
  - ケース状態: pass=0, fail=0, known=46, unsupported=0, stale=0, not_run=0。
- membership_range:
  - 2因子の合格確認済み組合せ: 0/303。
  - 3因子の合格確認済み組合せ: 0/178。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=46, unsupported=0, stale=0, not_run=0。
- case_inside_selection:
  - 2因子の合格確認済み組合せ: 0/315。
  - 3因子の合格確認済み組合せ: 0/154。
  - 必須ケース: 0/7。
  - ケース状態: pass=0, fail=0, known=34, unsupported=0, stale=0, not_run=0。
- clocking_input_sampling:
  - 2因子の合格確認済み組合せ: 0/165。
  - 3因子の合格確認済み組合せ: 0/72。
  - 必須ケース: 0/5。
  - ケース状態: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0。
- assertion_sample_visibility:
  - 2因子の合格確認済み組合せ: 0/225。
  - 3因子の合格確認済み組合せ: 0/96。
  - 必須ケース: 0/7。
  - ケース状態: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0。
- container_wait_visibility:
  - 2因子の合格確認済み組合せ: 194/214。
  - 3因子の合格確認済み組合せ: 63/88。
  - 必須ケース: 3/6。
  - ケース状態: pass=26, fail=0, known=10, unsupported=0, stale=0, not_run=0。
- class_method_reference:
  - 2因子の合格確認済み組合せ: 111/202。
  - 3因子の合格確認済み組合せ: 30/99。
  - 必須ケース: 2/6。
  - ケース状態: pass=15, fail=0, known=21, unsupported=0, stale=0, not_run=0。
- function_loop_return:
  - 2因子の合格確認済み組合せ: 161/161。
  - 3因子の合格確認済み組合せ: 120/120。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- loop_assignment_order:
  - 2因子の合格確認済み組合せ: 246/246。
  - 3因子の合格確認済み組合せ: 111/111。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- implicit_process_visibility:
  - 2因子の合格確認済み組合せ: 242/242。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- generate_scope_lookup:
  - 2因子の合格確認済み組合せ: 148/148。
  - 3因子の合格確認済み組合せ: 68/68。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- default_argument_scope:
  - 2因子の合格確認済み組合せ: 159/159。
  - 3因子の合格確認済み組合せ: 128/128。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- event_task_scope:
  - 2因子の合格確認済み組合せ: 0/109。
  - 3因子の合格確認済み組合せ: 0/52。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=13, unsupported=0, stale=0, not_run=0。
- continuous_delay_inertial:
  - 2因子の合格確認済み組合せ: 134/141。
  - 3因子の合格確認済み組合せ: 114/129。
  - 必須ケース: 5/7。
  - ケース状態: pass=57, fail=0, known=6, unsupported=0, stale=0, not_run=0。
- port_import_scope:
  - 2因子の合格確認済み組合せ: 158/158。
  - 3因子の合格確認済み組合せ: 141/141。
  - 必須ケース: 6/6。
  - ケース状態: pass=39, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- typed_memory_file:
  - 2因子の合格確認済み組合せ: 248/248。
  - 3因子の合格確認済み組合せ: 82/82。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- program_descendant_shutdown:
  - 2因子の合格確認済み組合せ: 0/109。
  - 3因子の合格確認済み組合せ: 0/38。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- implicit_port_nettype:
  - 2因子の合格確認済み組合せ: 90/156。
  - 3因子の合格確認済み組合せ: 28/72。
  - 必須ケース: 2/6。
  - ケース状態: pass=14, fail=0, known=26, unsupported=0, stale=0, not_run=0。
- generated_interface_binding:
  - 2因子の合格確認済み組合せ: 0/165。
  - 3因子の合格確認済み組合せ: 0/74。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0。
- program_reactive_handoff:
  - 2因子の合格確認済み組合せ: 0/183。
  - 3因子の合格確認済み組合せ: 0/84。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0。
- configuration_generated_shape:
  - 2因子の合格確認済み組合せ: 0/213。
  - 3因子の合格確認済み組合せ: 0/80。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=41, unsupported=0, stale=0, not_run=0。
- udp_array_strength:
  - 2因子の合格確認済み組合せ: 21/182。
  - 3因子の合格確認済み組合せ: 4/80。
  - 必須ケース: 1/6。
  - ケース状態: pass=1, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- generated_udp_state:
  - 2因子の合格確認済み組合せ: 165/165。
  - 3因子の合格確認済み組合せ: 68/68。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- interface_header_import:
  - 2因子の合格確認済み組合せ: 183/183。
  - 3因子の合格確認済み組合せ: 78/78。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- mailbox_class_alias:
  - 2因子の合格確認済み組合せ: 0/245。
  - 3因子の合格確認済み組合せ: 0/92。
  - 必須ケース: 0/9。
  - ケース状態: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0。
- array_reduction_constraint:
  - 2因子の合格確認済み組合せ: 0/96。
  - 3因子の合格確認済み組合せ: 0/40。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=13, unsupported=0, stale=0, not_run=0。
- associative_array_queries:
  - 2因子の合格確認済み組合せ: 0/93。
  - 3因子の合格確認済み組合せ: 0/54。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- clocking_event_iff:
  - 2因子の合格確認済み組合せ: 0/109。
  - 3因子の合格確認済み組合せ: 0/44。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=12, unsupported=0, stale=0, not_run=0。
- class_virtual_interface:
  - 2因子の合格確認済み組合せ: 0/96。
  - 3因子の合格確認済み組合せ: 0/48。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=13, unsupported=0, stale=0, not_run=0。
- resolved_strength_format:
  - 2因子の合格確認済み組合せ: 87/87。
  - 3因子の合格確認済み組合せ: 78/78。
  - 必須ケース: 4/4。
  - ケース状態: pass=31, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- class_array_shallow_copy:
  - 2因子の合格確認済み組合せ: 0/108。
  - 3因子の合格確認済み組合せ: 0/60。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- dpi_openarray_shape:
  - 2因子の合格確認済み組合せ: 0/100。
  - 3因子の合格確認済み組合せ: 0/72。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=30, unsupported=0, stale=0, not_run=0。
- clocking_assertion_sampling:
  - 2因子の合格確認済み組合せ: 0/109。
  - 3因子の合格確認済み組合せ: 0/50。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- constraint_inheritance:
  - 2因子の合格確認済み組合せ: 0/70。
  - 3因子の合格確認済み組合せ: 0/40。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=13, unsupported=0, stale=0, not_run=0。
- dpi_nba_capture:
  - 2因子の合格確認済み組合せ: 0/81。
  - 3因子の合格確認済み組合せ: 0/48。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- event_rebinding:
  - 2因子の合格確認済み組合せ: 0/138。
  - 3因子の合格確認済み組合せ: 0/69。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=27, unsupported=0, stale=0, not_run=0。

### results/kirimasim.json

- 環境: kirimasim 0.0.0 (commit 2edfebbc6270), built with GNU 13.3.0。
- 実行日時: 2026-11-02T13:52:52.499974+00:00。

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
- argument_binding_index:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 5/5。
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
- queue_element_reference:
  - 2因子の合格確認済み組合せ: 257/257。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 5/5。
  - ケース状態: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0。
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
- logical_short_circuit:
  - 2因子の合格確認済み組合せ: 214/214。
  - 3因子の合格確認済み組合せ: 236/236。
  - 必須ケース: 5/5。
  - ケース状態: pass=92, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- edge_event_expression:
  - 2因子の合格確認済み組合せ: 260/260。
  - 3因子の合格確認済み組合せ: 152/152。
  - 必須ケース: 5/5。
  - ケース状態: pass=64, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- event_or_iff:
  - 2因子の合格確認済み組合せ: 104/104。
  - 3因子の合格確認済み組合せ: 59/59。
  - 必須ケース: 4/4。
  - ケース状態: pass=27, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- heap_file_monitor_context:
  - 2因子の合格確認済み組合せ: 40/40。
  - 必須ケース: 3/3。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- compound_shift_target:
  - 2因子の合格確認済み組合せ: 308/308。
  - 3因子の合格確認済み組合せ: 90/90。
  - 必須ケース: 4/4。
  - ケース状態: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- membership_container:
  - 2因子の合格確認済み組合せ: 208/305。
  - 3因子の合格確認済み組合せ: 84/174。
  - 必須ケース: 1/5。
  - ケース状態: pass=19, fail=1, known=0, unsupported=26, stale=0, not_run=0。
- membership_range:
  - 2因子の合格確認済み組合せ: 252/303。
  - 3因子の合格確認済み組合せ: 117/178。
  - 必須ケース: 4/6。
  - ケース状態: pass=30, fail=0, known=0, unsupported=16, stale=0, not_run=0。
- case_inside_selection:
  - 2因子の合格確認済み組合せ: 274/315。
  - 3因子の合格確認済み組合せ: 115/154。
  - 必須ケース: 3/7。
  - ケース状態: pass=25, fail=1, known=0, unsupported=8, stale=0, not_run=0。
- clocking_input_sampling:
  - 2因子の合格確認済み組合せ: 118/165。
  - 3因子の合格確認済み組合せ: 38/72。
  - 必須ケース: 2/5。
  - ケース状態: pass=24, fail=0, known=0, unsupported=12, stale=0, not_run=0。
- assertion_sample_visibility:
  - 2因子の合格確認済み組合せ: 0/225。
  - 3因子の合格確認済み組合せ: 0/96。
  - 必須ケース: 0/7。
  - ケース状態: pass=0, fail=0, known=0, unsupported=36, stale=0, not_run=0。
- container_wait_visibility:
  - 2因子の合格確認済み組合せ: 214/214。
  - 3因子の合格確認済み組合せ: 88/88。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- class_method_reference:
  - 2因子の合格確認済み組合せ: 135/202。
  - 3因子の合格確認済み組合せ: 39/99。
  - 必須ケース: 2/6。
  - ケース状態: pass=18, fail=0, known=0, unsupported=18, stale=0, not_run=0。
- function_loop_return:
  - 2因子の合格確認済み組合せ: 161/161。
  - 3因子の合格確認済み組合せ: 120/120。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- loop_assignment_order:
  - 2因子の合格確認済み組合せ: 246/246。
  - 3因子の合格確認済み組合せ: 111/111。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- implicit_process_visibility:
  - 2因子の合格確認済み組合せ: 242/242。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- generate_scope_lookup:
  - 2因子の合格確認済み組合せ: 148/148。
  - 3因子の合格確認済み組合せ: 68/68。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- default_argument_scope:
  - 2因子の合格確認済み組合せ: 159/159。
  - 3因子の合格確認済み組合せ: 128/128。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- event_task_scope:
  - 2因子の合格確認済み組合せ: 109/109。
  - 3因子の合格確認済み組合せ: 52/52。
  - 必須ケース: 6/6。
  - ケース状態: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- continuous_delay_inertial:
  - 2因子の合格確認済み組合せ: 141/141。
  - 3因子の合格確認済み組合せ: 129/129。
  - 必須ケース: 7/7。
  - ケース状態: pass=63, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- port_import_scope:
  - 2因子の合格確認済み組合せ: 158/158。
  - 3因子の合格確認済み組合せ: 141/141。
  - 必須ケース: 6/6。
  - ケース状態: pass=39, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- typed_memory_file:
  - 2因子の合格確認済み組合せ: 248/248。
  - 3因子の合格確認済み組合せ: 82/82。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- program_descendant_shutdown:
  - 2因子の合格確認済み組合せ: 109/109。
  - 3因子の合格確認済み組合せ: 38/38。
  - 必須ケース: 4/4。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- implicit_port_nettype:
  - 2因子の合格確認済み組合せ: 156/156。
  - 3因子の合格確認済み組合せ: 72/72。
  - 必須ケース: 6/6。
  - ケース状態: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- generated_interface_binding:
  - 2因子の合格確認済み組合せ: 165/165。
  - 3因子の合格確認済み組合せ: 74/74。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- program_reactive_handoff:
  - 2因子の合格確認済み組合せ: 183/183。
  - 3因子の合格確認済み組合せ: 84/84。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- configuration_generated_shape:
  - 2因子の合格確認済み組合せ: 207/213。
  - 3因子の合格確認済み組合せ: 72/80。
  - 必須ケース: 6/6。
  - ケース状態: pass=37, fail=4, known=0, unsupported=0, stale=0, not_run=0。
- udp_array_strength:
  - 2因子の合格確認済み組合せ: 182/182。
  - 3因子の合格確認済み組合せ: 80/80。
  - 必須ケース: 6/6。
  - ケース状態: pass=25, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- generated_udp_state:
  - 2因子の合格確認済み組合せ: 165/165。
  - 3因子の合格確認済み組合せ: 68/68。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- interface_header_import:
  - 2因子の合格確認済み組合せ: 183/183。
  - 3因子の合格確認済み組合せ: 78/78。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- mailbox_class_alias:
  - 2因子の合格確認済み組合せ: 0/245。
  - 3因子の合格確認済み組合せ: 0/92。
  - 必須ケース: 0/9。
  - ケース状態: pass=0, fail=0, known=0, unsupported=36, stale=0, not_run=0。
- array_reduction_constraint:
  - 2因子の合格確認済み組合せ: 0/96。
  - 3因子の合格確認済み組合せ: 0/40。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=13, stale=0, not_run=0。
- associative_array_queries:
  - 2因子の合格確認済み組合せ: 0/93。
  - 3因子の合格確認済み組合せ: 0/54。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0。
- clocking_event_iff:
  - 2因子の合格確認済み組合せ: 0/109。
  - 3因子の合格確認済み組合せ: 0/44。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=12, stale=0, not_run=0。
- class_virtual_interface:
  - 2因子の合格確認済み組合せ: 0/96。
  - 3因子の合格確認済み組合せ: 0/48。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=13, stale=0, not_run=0。
- resolved_strength_format:
  - 2因子の合格確認済み組合せ: 87/87。
  - 3因子の合格確認済み組合せ: 78/78。
  - 必須ケース: 4/4。
  - ケース状態: pass=31, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- class_array_shallow_copy:
  - 2因子の合格確認済み組合せ: 67/108。
  - 3因子の合格確認済み組合せ: 21/60。
  - 必須ケース: 1/4。
  - ケース状態: pass=6, fail=0, known=0, unsupported=12, stale=0, not_run=0。
- dpi_openarray_shape:
  - 2因子の合格確認済み組合せ: 0/100。
  - 3因子の合格確認済み組合せ: 0/72。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=30, stale=0, not_run=0。
- clocking_assertion_sampling:
  - 2因子の合格確認済み組合せ: 0/109。
  - 3因子の合格確認済み組合せ: 0/50。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0。
- constraint_inheritance:
  - 2因子の合格確認済み組合せ: 0/70。
  - 3因子の合格確認済み組合せ: 0/40。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=13, stale=0, not_run=0。
- dpi_nba_capture:
  - 2因子の合格確認済み組合せ: 0/81。
  - 3因子の合格確認済み組合せ: 0/48。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0。
- event_rebinding:
  - 2因子の合格確認済み組合せ: 0/138。
  - 3因子の合格確認済み組合せ: 0/69。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=0, unsupported=27, stale=0, not_run=0。

### results/lyra.json

- 環境: Lyra (commit 099acd527059)。
- 実行日時: 2026-11-02T15:45:56.045037+00:00。

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
- argument_binding_index:
  - 2因子の合格確認済み組合せ: 162/162。
  - 3因子の合格確認済み組合せ: 63/63。
  - 必須ケース: 5/5。
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
- queue_element_reference:
  - 2因子の合格確認済み組合せ: 257/257。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 5/5。
  - ケース状態: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0。
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
- logical_short_circuit:
  - 2因子の合格確認済み組合せ: 214/214。
  - 3因子の合格確認済み組合せ: 236/236。
  - 必須ケース: 5/5。
  - ケース状態: pass=92, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- edge_event_expression:
  - 2因子の合格確認済み組合せ: 260/260。
  - 3因子の合格確認済み組合せ: 152/152。
  - 必須ケース: 5/5。
  - ケース状態: pass=64, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- event_or_iff:
  - 2因子の合格確認済み組合せ: 104/104。
  - 3因子の合格確認済み組合せ: 59/59。
  - 必須ケース: 4/4。
  - ケース状態: pass=27, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- heap_file_monitor_context:
  - 2因子の合格確認済み組合せ: 0/40。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0。
- compound_shift_target:
  - 2因子の合格確認済み組合せ: 308/308。
  - 3因子の合格確認済み組合せ: 90/90。
  - 必須ケース: 4/4。
  - ケース状態: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- membership_container:
  - 2因子の合格確認済み組合せ: 302/305。
  - 3因子の合格確認済み組合せ: 164/174。
  - 必須ケース: 4/5。
  - ケース状態: pass=44, fail=2, known=0, unsupported=0, stale=0, not_run=0。
- membership_range:
  - 2因子の合格確認済み組合せ: 252/303。
  - 3因子の合格確認済み組合せ: 117/178。
  - 必須ケース: 4/6。
  - ケース状態: pass=30, fail=0, known=0, unsupported=16, stale=0, not_run=0。
- case_inside_selection:
  - 2因子の合格確認済み組合せ: 314/315。
  - 3因子の合格確認済み組合せ: 149/154。
  - 必須ケース: 6/7。
  - ケース状態: pass=33, fail=1, known=0, unsupported=0, stale=0, not_run=0。
- clocking_input_sampling:
  - 2因子の合格確認済み組合せ: 0/165。
  - 3因子の合格確認済み組合せ: 0/72。
  - 必須ケース: 0/5。
  - ケース状態: pass=0, fail=0, known=0, unsupported=36, stale=0, not_run=0。
- assertion_sample_visibility:
  - 2因子の合格確認済み組合せ: 225/225。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 7/7。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- container_wait_visibility:
  - 2因子の合格確認済み組合せ: 214/214。
  - 3因子の合格確認済み組合せ: 88/88。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- class_method_reference:
  - 2因子の合格確認済み組合せ: 202/202。
  - 3因子の合格確認済み組合せ: 99/99。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- function_loop_return:
  - 2因子の合格確認済み組合せ: 161/161。
  - 3因子の合格確認済み組合せ: 120/120。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- loop_assignment_order:
  - 2因子の合格確認済み組合せ: 246/246。
  - 3因子の合格確認済み組合せ: 111/111。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- implicit_process_visibility:
  - 2因子の合格確認済み組合せ: 242/242。
  - 3因子の合格確認済み組合せ: 96/96。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- generate_scope_lookup:
  - 2因子の合格確認済み組合せ: 148/148。
  - 3因子の合格確認済み組合せ: 68/68。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- default_argument_scope:
  - 2因子の合格確認済み組合せ: 159/159。
  - 3因子の合格確認済み組合せ: 128/128。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- event_task_scope:
  - 2因子の合格確認済み組合せ: 109/109。
  - 3因子の合格確認済み組合せ: 52/52。
  - 必須ケース: 6/6。
  - ケース状態: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- continuous_delay_inertial:
  - 2因子の合格確認済み組合せ: 141/141。
  - 3因子の合格確認済み組合せ: 129/129。
  - 必須ケース: 7/7。
  - ケース状態: pass=63, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- port_import_scope:
  - 2因子の合格確認済み組合せ: 158/158。
  - 3因子の合格確認済み組合せ: 141/141。
  - 必須ケース: 6/6。
  - ケース状態: pass=39, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- typed_memory_file:
  - 2因子の合格確認済み組合せ: 248/248。
  - 3因子の合格確認済み組合せ: 82/82。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- program_descendant_shutdown:
  - 2因子の合格確認済み組合せ: 109/109。
  - 3因子の合格確認済み組合せ: 38/38。
  - 必須ケース: 4/4。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- implicit_port_nettype:
  - 2因子の合格確認済み組合せ: 156/156。
  - 3因子の合格確認済み組合せ: 72/72。
  - 必須ケース: 6/6。
  - ケース状態: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- generated_interface_binding:
  - 2因子の合格確認済み組合せ: 165/165。
  - 3因子の合格確認済み組合せ: 74/74。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- program_reactive_handoff:
  - 2因子の合格確認済み組合せ: 183/183。
  - 3因子の合格確認済み組合せ: 84/84。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- configuration_generated_shape:
  - 2因子の合格確認済み組合せ: 77/213。
  - 3因子の合格確認済み組合せ: 23/80。
  - 必須ケース: 0/6。
  - ケース状態: pass=11, fail=30, known=0, unsupported=0, stale=0, not_run=0。
- udp_array_strength:
  - 2因子の合格確認済み組合せ: 0/182。
  - 3因子の合格確認済み組合せ: 0/80。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=25, known=0, unsupported=0, stale=0, not_run=0。
- generated_udp_state:
  - 2因子の合格確認済み組合せ: 0/165。
  - 3因子の合格確認済み組合せ: 0/68。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=0, unsupported=36, stale=0, not_run=0。
- interface_header_import:
  - 2因子の合格確認済み組合せ: 183/183。
  - 3因子の合格確認済み組合せ: 78/78。
  - 必須ケース: 6/6。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- mailbox_class_alias:
  - 2因子の合格確認済み組合せ: 245/245。
  - 3因子の合格確認済み組合せ: 92/92。
  - 必須ケース: 9/9。
  - ケース状態: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- array_reduction_constraint:
  - 2因子の合格確認済み組合せ: 96/96。
  - 3因子の合格確認済み組合せ: 40/40。
  - 必須ケース: 4/4。
  - ケース状態: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- associative_array_queries:
  - 2因子の合格確認済み組合せ: 77/93。
  - 3因子の合格確認済み組合せ: 32/54。
  - 必須ケース: 3/4。
  - ケース状態: pass=8, fail=10, known=0, unsupported=0, stale=0, not_run=0。
- clocking_event_iff:
  - 2因子の合格確認済み組合せ: 0/109。
  - 3因子の合格確認済み組合せ: 0/44。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=12, stale=0, not_run=0。
- class_virtual_interface:
  - 2因子の合格確認済み組合せ: 76/96。
  - 3因子の合格確認済み組合せ: 25/48。
  - 必須ケース: 2/4。
  - ケース状態: pass=7, fail=0, known=0, unsupported=6, stale=0, not_run=0。
- resolved_strength_format:
  - 2因子の合格確認済み組合せ: 0/87。
  - 3因子の合格確認済み組合せ: 0/78。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=31, stale=0, not_run=0。
- class_array_shallow_copy:
  - 2因子の合格確認済み組合せ: 83/108。
  - 3因子の合格確認済み組合せ: 32/60。
  - 必須ケース: 1/4。
  - ケース状態: pass=9, fail=0, known=0, unsupported=9, stale=0, not_run=0。
- dpi_openarray_shape:
  - 2因子の合格確認済み組合せ: 0/100。
  - 3因子の合格確認済み組合せ: 0/72。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=24, known=0, unsupported=6, stale=0, not_run=0。
- clocking_assertion_sampling:
  - 2因子の合格確認済み組合せ: 0/109。
  - 3因子の合格確認済み組合せ: 0/50。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0。
- constraint_inheritance:
  - 2因子の合格確認済み組合せ: 70/70。
  - 3因子の合格確認済み組合せ: 40/40。
  - 必須ケース: 4/4。
  - ケース状態: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- dpi_nba_capture:
  - 2因子の合格確認済み組合せ: 81/81。
  - 3因子の合格確認済み組合せ: 48/48。
  - 必須ケース: 4/4。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- event_rebinding:
  - 2因子の合格確認済み組合せ: 138/138。
  - 3因子の合格確認済み組合せ: 69/69。
  - 必須ケース: 6/6。
  - ケース状態: pass=27, fail=0, known=0, unsupported=0, stale=0, not_run=0。

### results/verilator.json

- 環境: Verilator 5.055 devel rev v5.054-30-g4298d7b7。
- 実行日時: 2026-11-02T14:53:51.526605+00:00。

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
- argument_binding_index:
  - 2因子の合格確認済み組合せ: 75/162。
  - 3因子の合格確認済み組合せ: 15/63。
  - 必須ケース: 2/5。
  - ケース状態: pass=8, fail=0, known=28, unsupported=0, stale=0, not_run=0。
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
- queue_element_reference:
  - 2因子の合格確認済み組合せ: 135/257。
  - 3因子の合格確認済み組合せ: 30/96。
  - 必須ケース: 3/5。
  - ケース状態: pass=20, fail=0, known=40, unsupported=0, stale=0, not_run=0。
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
- logical_short_circuit:
  - 2因子の合格確認済み組合せ: 123/214。
  - 3因子の合格確認済み組合せ: 74/236。
  - 必須ケース: 0/5。
  - ケース状態: pass=32, fail=0, known=60, unsupported=0, stale=0, not_run=0。
- edge_event_expression:
  - 2因子の合格確認済み組合せ: 130/260。
  - 3因子の合格確認済み組合せ: 41/152。
  - 必須ケース: 1/5。
  - ケース状態: pass=16, fail=0, known=48, unsupported=0, stale=0, not_run=0。
- event_or_iff:
  - 2因子の合格確認済み組合せ: 71/104。
  - 3因子の合格確認済み組合せ: 26/59。
  - 必須ケース: 2/4。
  - ケース状態: pass=9, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- heap_file_monitor_context:
  - 2因子の合格確認済み組合せ: 0/40。
  - 必須ケース: 0/3。
  - ケース状態: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- compound_shift_target:
  - 2因子の合格確認済み組合せ: 157/308。
  - 3因子の合格確認済み組合せ: 28/90。
  - 必須ケース: 1/4。
  - ケース状態: pass=10, fail=0, known=30, unsupported=0, stale=0, not_run=0。
- membership_container:
  - 2因子の合格確認済み組合せ: 95/305。
  - 3因子の合格確認済み組合せ: 19/174。
  - 必須ケース: 0/5。
  - ケース状態: pass=6, fail=0, known=40, unsupported=0, stale=0, not_run=0。
- membership_range:
  - 2因子の合格確認済み組合せ: 108/303。
  - 3因子の合格確認済み組合せ: 25/178。
  - 必須ケース: 1/6。
  - ケース状態: pass=7, fail=0, known=39, unsupported=0, stale=0, not_run=0。
- case_inside_selection:
  - 2因子の合格確認済み組合せ: 128/315。
  - 3因子の合格確認済み組合せ: 27/154。
  - 必須ケース: 0/7。
  - ケース状態: pass=5, fail=0, known=29, unsupported=0, stale=0, not_run=0。
- clocking_input_sampling:
  - 2因子の合格確認済み組合せ: 109/165。
  - 3因子の合格確認済み組合せ: 29/72。
  - 必須ケース: 2/5。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- assertion_sample_visibility:
  - 2因子の合格確認済み組合せ: 133/225。
  - 3因子の合格確認済み組合せ: 34/96。
  - 必須ケース: 3/7。
  - ケース状態: pass=11, fail=0, known=25, unsupported=0, stale=0, not_run=0。
- container_wait_visibility:
  - 2因子の合格確認済み組合せ: 126/214。
  - 3因子の合格確認済み組合せ: 36/88。
  - 必須ケース: 3/6。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- class_method_reference:
  - 2因子の合格確認済み組合せ: 130/202。
  - 3因子の合格確認済み組合せ: 43/99。
  - 必須ケース: 3/6。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- function_loop_return:
  - 2因子の合格確認済み組合せ: 102/161。
  - 3因子の合格確認済み組合せ: 44/120。
  - 必須ケース: 3/6。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- loop_assignment_order:
  - 2因子の合格確認済み組合せ: 160/246。
  - 3因子の合格確認済み組合せ: 46/111。
  - 必須ケース: 3/6。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- implicit_process_visibility:
  - 2因子の合格確認済み組合せ: 0/242。
  - 3因子の合格確認済み組合せ: 0/96。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0。
- generate_scope_lookup:
  - 2因子の合格確認済み組合せ: 90/148。
  - 3因子の合格確認済み組合せ: 30/68。
  - 必須ケース: 3/6。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- default_argument_scope:
  - 2因子の合格確認済み組合せ: 100/159。
  - 3因子の合格確認済み組合せ: 47/128。
  - 必須ケース: 3/6。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- event_task_scope:
  - 2因子の合格確認済み組合せ: 79/109。
  - 3因子の合格確認済み組合せ: 27/52。
  - 必須ケース: 3/6。
  - ケース状態: pass=6, fail=0, known=7, unsupported=0, stale=0, not_run=0。
- continuous_delay_inertial:
  - 2因子の合格確認済み組合せ: 90/141。
  - 3因子の合格確認済み組合せ: 41/129。
  - 必須ケース: 2/7。
  - ケース状態: pass=17, fail=0, known=46, unsupported=0, stale=0, not_run=0。
- port_import_scope:
  - 2因子の合格確認済み組合せ: 0/158。
  - 3因子の合格確認済み組合せ: 0/141。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=39, unsupported=0, stale=0, not_run=0。
- typed_memory_file:
  - 2因子の合格確認済み組合せ: 161/248。
  - 3因子の合格確認済み組合せ: 32/82。
  - 必須ケース: 3/6。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- program_descendant_shutdown:
  - 2因子の合格確認済み組合せ: 0/109。
  - 3因子の合格確認済み組合せ: 0/38。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- implicit_port_nettype:
  - 2因子の合格確認済み組合せ: 0/156。
  - 3因子の合格確認済み組合せ: 0/72。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=40, unsupported=0, stale=0, not_run=0。
- generated_interface_binding:
  - 2因子の合格確認済み組合せ: 98/165。
  - 3因子の合格確認済み組合せ: 26/74。
  - 必須ケース: 3/6。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- program_reactive_handoff:
  - 2因子の合格確認済み組合せ: 0/183。
  - 3因子の合格確認済み組合せ: 0/84。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0。
- configuration_generated_shape:
  - 2因子の合格確認済み組合せ: 0/213。
  - 3因子の合格確認済み組合せ: 0/80。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=41, unsupported=0, stale=0, not_run=0。
- udp_array_strength:
  - 2因子の合格確認済み組合せ: 0/182。
  - 3因子の合格確認済み組合せ: 0/80。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=25, unsupported=0, stale=0, not_run=0。
- generated_udp_state:
  - 2因子の合格確認済み組合せ: 27/165。
  - 3因子の合格確認済み組合せ: 6/68。
  - 必須ケース: 1/6。
  - ケース状態: pass=2, fail=0, known=34, unsupported=0, stale=0, not_run=0。
- interface_header_import:
  - 2因子の合格確認済み組合せ: 108/183。
  - 3因子の合格確認済み組合せ: 28/78。
  - 必須ケース: 2/6。
  - ケース状態: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0。
- mailbox_class_alias:
  - 2因子の合格確認済み組合せ: 138/245。
  - 3因子の合格確認済み組合せ: 34/92。
  - 必須ケース: 6/9。
  - ケース状態: pass=11, fail=0, known=25, unsupported=0, stale=0, not_run=0。
- array_reduction_constraint:
  - 2因子の合格確認済み組合せ: 0/96。
  - 3因子の合格確認済み組合せ: 0/40。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=13, unsupported=0, stale=0, not_run=0。
- associative_array_queries:
  - 2因子の合格確認済み組合せ: 0/93。
  - 3因子の合格確認済み組合せ: 0/54。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0。
- clocking_event_iff:
  - 2因子の合格確認済み組合せ: 65/109。
  - 3因子の合格確認済み組合せ: 16/44。
  - 必須ケース: 1/4。
  - ケース状態: pass=4, fail=0, known=8, unsupported=0, stale=0, not_run=0。
- class_virtual_interface:
  - 2因子の合格確認済み組合せ: 96/96。
  - 3因子の合格確認済み組合せ: 48/48。
  - 必須ケース: 4/4。
  - ケース状態: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- resolved_strength_format:
  - 2因子の合格確認済み組合せ: 0/87。
  - 3因子の合格確認済み組合せ: 0/78。
  - 必須ケース: 0/4。
  - ケース状態: pass=0, fail=0, known=31, unsupported=0, stale=0, not_run=0。
- class_array_shallow_copy:
  - 2因子の合格確認済み組合せ: 108/108。
  - 3因子の合格確認済み組合せ: 60/60。
  - 必須ケース: 4/4。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- dpi_openarray_shape:
  - 2因子の合格確認済み組合せ: 93/100。
  - 3因子の合格確認済み組合せ: 59/72。
  - 必須ケース: 3/4。
  - ケース状態: pass=26, fail=0, known=4, unsupported=0, stale=0, not_run=0。
- clocking_assertion_sampling:
  - 2因子の合格確認済み組合せ: 109/109。
  - 3因子の合格確認済み組合せ: 50/50。
  - 必須ケース: 4/4。
  - ケース状態: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- constraint_inheritance:
  - 2因子の合格確認済み組合せ: 70/70。
  - 3因子の合格確認済み組合せ: 40/40。
  - 必須ケース: 4/4。
  - ケース状態: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0。
- dpi_nba_capture:
  - 2因子の合格確認済み組合せ: 79/81。
  - 3因子の合格確認済み組合せ: 37/48。
  - 必須ケース: 3/4。
  - ケース状態: pass=14, fail=0, known=4, unsupported=0, stale=0, not_run=0。
- event_rebinding:
  - 2因子の合格確認済み組合せ: 0/138。
  - 3因子の合格確認済み組合せ: 0/69。
  - 必須ケース: 0/6。
  - ケース状態: pass=0, fail=0, known=27, unsupported=0, stale=0, not_run=0。
