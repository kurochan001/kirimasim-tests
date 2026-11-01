<a id="auxiliary-evidence-for-cross-functional-verification"></a>

# 機能間クロス検証の補助証跡

[English](README.en.md) / [日本語](README.md)

このディレクトリは、固定版の確認元選別、独立検算、最小例、故障注入、ビルド版の確認記録を 保存します。現在の入力に対応する回帰実行は[`interaction-results/`](../interaction-results/)、 充足状況は[クロス検証レポート](../../docs/interaction-coverage.md)を参照してください。 補助証跡の正常・故障条件の件数を、スイートの合格数や要求カバレッジへ加算しません。 入力ハッシュが古くなった記録は履歴として残し、新しいハッシュへ書き換えず再確認を別途記録します。 「最新」のビルドは各記録の確認時点での意味です。コミットと日時を確認してください。

<a id="selecting-verification-sources-from-fixed-releases"></a>

## 固定リリースの確認元選別

`20261029-query/`はIcarus Verilog 13.0での予備確認と再実行のJSONです。 初回は追加3モデルの132件、続く5回はビットベクタ関数モデルの60件を実行しました。 この60件の一致数は順に54、52、55、56、53、54件で、全6回で一致したのは51件です。 幅64超の連結・複製式で、引数幅が32の倍数でない9件は結果に変動がありました。

この9件にIcarusのoracleは登録しません。Verilatorの両seedで一致した2値ケースは Verilatorを確認元とし、残りは規格に基づく期待値を保持します。 モデルの分母から除外したり、期待値を緩めたりするための記録ではありません。

その後、[CheckのUbuntu 24.04環境](https://github.com/kurochan001/kirimasim-tests/actions/runs/40893253924)で、 手元の6回では一致していた12件にも`$countones`の差が出ました。 [失敗行の抜粋](20261029-query-linux-check.log)は当時のコミットとジョブURLを付けて保存しています。 追加12件の引数幅は2・33・34ビットです。前の9件と合わせ、連結・複製後の引数幅が 32の倍数でない21件にはIcarus oracleを登録しません。残る39件をIcarusの確認済みとします。 追加12件は4値ケースとして分類し、Verilatorの確認対象から外しています。 Verilator確認済みへの付け替えは行わず、規格のみとします。

JSONはoracleメタデータと差異コメントを追記する前の入力ハッシュをそのまま保存しています。 現行の実行カバレッジには使いません。現行ソースに対応する結果は [`interaction-results/`](../interaction-results/)へ別途、再実行して保存します。 当時のJSONのハッシュを現行値へ書き換えてはいけません。

<a id="verify-the-assignment-of-the-compound-shift"></a>

## 複合シフト代入の確認

[`20261030-compound-shift.json`](20261030-compound-shift.json)には、実行開始時に確認した kirimasimの上流コミットとビルド前後のバイナリ指紋、独立した期待値の照合方法、 左辺添字を2回評価する故障注入、Verilatorの部分選択2件の両seedでの詳細出力を保存しています。 故障注入のソースは回帰テストへ採用せず、検出の確認用です。 このファイルを現行の合格数へ加算しません。入力が変わったら検査を再実行してください。

<a id="checking-set-membership"></a>

## 集合所属判定の確認

[`20261030-inside.json`](20261030-inside.json)は、実行直前に確認したkirimasimのビルド版・バイナリ指紋、 配列/個別列挙/直接比較を照合する2/3ビットの最小例、bit/logicと符号の対照条件、 個別列挙で先頭要素だけを読む故障注入の証跡です。 実装の不一致と検査器の故障検出を分けて保存し、通常の実行カバレッジへ加算しません。 現行の回帰結果は`interaction-results/cross27-*.json`です。

[`20261030-inside-fc4cc356.json`](20261030-inside-fc4cc356.json)は同日の再確認です。 実行直前に確認した上流main `fc4cc356`のビルド版・バイナリ指紋、上の2つの最小例の再実行、 左辺の値と要素数を変えた追加の最小例、定数として評価した同じ比較、 手書きテスト[`test_inside_array_set_mixed_sign_width`](../../tests/ch11/test_inside_array_set_mixed_sign_width.sv)の kirimasimの出力と、Verilator 5.052のseed 1・73での出力を保存しています。 追加の最小例では、左辺`111`と`011`で配列形式の結果が逆向きにずれ、配列の符号付き要素を 符号拡張して比較していることがわかります。定数として評価した比較は期待値どおりです。

<a id="checking-range-specifications"></a>

## 範囲指定の確認

[`20261030-range.json`](20261030-range.json)は`membership_range@1`の確認記録です。 実行直前に確認した上流main `f303beca`のビルド版・バイナリ指紋、独立した期待値の照合方法、 `$`を端点にした範囲の小さな例と、そのkirimasimとVerilator 5.052のseed 1・73での出力を保存しています。 kirimasimは期待値どおりで、Verilatorは両seedで同じ結果が期待値と異なります。 参照モデルの規則を一つずつ誤りに置き換えた7種類の故障注入について、出力が変わるケース数も記録しています。 故障注入は検出力の確認用で、通常のスイートや実行カバレッジへ加算しません。 現行の回帰結果は`interaction-results/cross28-*.json`です。

<a id="check-case-inside"></a>

## case insideの確認

[`20261030-case-inside.json`](20261030-case-inside.json)は`case_inside_selection@1`の確認記録です。 実行直前に確認した上流main `f303beca`のビルド版・バイナリ指紋、独立した期待値の照合方法、 符号付き配列の項目と同じ値の項目を比べる2/3ビットの最小例と、そのkirimasimの出力、 不一致になった生成テストのkirimasimの出力、Verilator 5.052で最小例がビルドできなかったことを保存しています。 参照モデルの規則を一つずつ誤りに置き換えた7種類の故障注入について、観測が変わるケース数も記録しています。 故障注入は検出力の確認用で、通常のスイートや実行カバレッジへ加算しません。 現行の回帰結果は`interaction-results/cross29-*.json`です。

<a id="checking-events-or-and-iff"></a>

## イベントORとiffの確認

[`20261031-event-iff.json`](20261031-event-iff.json)は`event_or_iff@1`の確認記録です。 上流mainと版を照合したkirimasim `17b7192b4f05`で、選択済みの4行がすべて一致し、 条件の取り違え・両項への誤った条件付け・右項の欠落・条件での誤起床・既知の1とXの混在の拒否・ 名前付きイベントの再発火の欠落・NBAの即時化、の7種類をすべて出力の相違として検出しました。 元の生成器、確認ツール、作ったSVと期待値の指紋、各変更箇所と判定を保存しています。 通常のスイートの件数や実行カバレッジには故障注入を加算しません。

再確認は、実行直前に最新上流を取得・ビルドして版の一致を確認した後、次の形で実行します。 過去の証跡を上書きせず、新しいファイル名を指定してください。

```sh
python3 tools/qualify_event_iff.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --json coverage/interaction-qualification/NEW-event-iff.json
```

通常の保存実行は`interaction-results/cross30-kirimasim-17b7192b.json`と `interaction-results/event-or-iff-20261031-*.json`です。

<a id="checking-references-to-queue-elements"></a>

## キュー要素の参照の確認

[`20261031-queue-ref.json`](20261031-queue-ref.json)は`queue_element_reference@1`の確認記録です。 上流mainとビルド版を照合したkirimasim `29ad73153518`で、選択済みの正の対照条件4件が一致し、 要素の取り違え・値渡し化・メソッドの全体代入化・書込みの欠落・全体代入後の参照の誤保持・ 削除済み参照から現在のキューへの書込み・容量制限の欠落・logic入力のbit化の8種類を検出しました。 構文エラー、未対応、異常終了は故障検出として数えません。 ビルド版とバイナリ、生成器、確認ツール、SVと期待値の指紋、変更箇所と判定を保存しています。 故障注入は通常の実行カバレッジへ加算しません。

最新上流を取得・ビルドして版を照合した後、新しい保存先を指定して再実行できます。

```sh
python3 tools/qualify_queue_ref.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --json coverage/interaction-qualification/NEW-queue-ref.json
```

通常の保存実行は`interaction-results/cross31-kirimasim-29ad7315.json`と `interaction-results/queue-ref-20261031-*.json`です。 [`20261031-queue-ref-verilator.json`](20261031-queue-ref-verilator.json)は、通常のランナーが 出力なしと記録した上限付き連結代入の1件について、固定版を同じオプションで再実行した記録です。 ビルドは成功し、両seedともSIGBUSで終了しました。ソースコードは調べていません。

<a id="checking-argument-binding-and-index-changes"></a>

## 引数の結合と添字変更の確認

[`20261031-binding.json`](20261031-binding.json)は`argument_binding_index@1`の確認記録です。 上流mainとビルド版を照合したkirimasim `a08e3489b8ab`で、選択済みの正の対照条件4件が一致し、 誤った要素への結合、refの値渡し化、refの書込みの欠落、const refの値渡し化、 inputの参照化、遅い時刻の親の更新の欠落、logicのbit化、保護用要素の破壊の8種類を検出しました。 構文エラー・未対応・異常終了は検出として数えず、正常終了時の出力相違で確認しています。 バイナリ・生成器・確認ツール・作成したSV・期待値の指紋と、各変更箇所・判定を保存しています。 故障注入を通常のスイートや実行カバレッジへ加算しません。

最新上流を取得・ビルドして版を照合した後、新しい保存先を指定して再実行できます。

```sh
python3 tools/qualify_binding.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --json coverage/interaction-qualification/NEW-binding.json
```

通常の保存実行は`interaction-results/cross32-kirimasim-a08e3489.json`と `interaction-results/binding-20261031-*.json`です。

<a id="mailbox-class-handles-and-updates-through-aliases"></a>

## mailboxのclassハンドルと別名経由の更新

[`20261101-mailbox.json`](20261101-mailbox.json)は、 [`mailbox_class_alias`](../../docs/interaction-verification.md#mailboxのclassハンドルと別名経由の更新)の補助記録です。 固定Verilator 5.052の既知値・typedの必須6ケースが正常対照として一致し、FIFO・ハンドルの共有・ 双方向の更新、容量・null、別mailboxの独立性など19種類の誤りを正常終了後の出力差として検出しました。 コンパイルエラー・異常終了だけを故障検出へ数えません。typelessやX/Zはこの故障注入の対象外です。

[`20261101-mailbox-build.json`](20261101-mailbox-build.json)は、全体回帰直前に確認したkirimasimの 上流コミット・ビルド版・バイナリ指紋と、従来2,292件の入力・結果区分を保持したことの記録です。 [`20261101-mailbox-prior-digests.json`](20261101-mailbox-prior-digests.json)には、従来の生成物・保存実行・ モデル計画・集計結果を変更していないことの指紋を記録します。補助記録を通常の合格数へ加算しません。

```sh
python3 tools/qualify_mailbox.py --verilator verilator --seed 1 \
  --output coverage/interaction-qualification/NEW-mailbox.json
```

出力先は既存の証跡を上書きしない新規ファイルを指定してください。

<a id="re-association-of-event-variables-and-retention-of-registered-waits"></a>

## イベント変数の再結合と登録済み待機の保持

[`20261101-event-rebind-build.json`](20261101-event-rebind-build.json)は、 [`event_rebinding`](../../docs/interaction-verification.md#イベント変数の再結合と登録済み待機の保持)を実行した kirimasimの上流・ビルド版の一致、バイナリの不変性、27件の構文・意味解析の成功と、 従来2,328件の入力・結果区分の保持を記録します。 [`20261101-event-rebind-prior-digests.json`](20261101-event-rebind-prior-digests.json)は、 従来6,786生成ファイル、54モデルの計画、157保存実行と従来モデル集計の指紋です。

動作はkirimasimで未対応、固定Icarus/Verilatorではビルド失敗なので、 SystemVerilogの故障注入を実行できたとの記録はありません。 独立参照モデルで確認した13種の抽象的な誤りへの観測感度も、実行での故障検出数へ加算しません。

<a id="dpi-copyback-and-nba-checks"></a>

## DPIの書戻しとNBAの確認

[`dpi-nba.json`](dpi-nba.json)は、144行の独立したビット列計算とC ABIの照合、正常対照と4故障の出力差による検出を記録します。
[`dpi-nba-build.json`](dpi-nba-build.json)は、実行直前に確認した最新kirimasimのコミット・バイナリ指紋・18件の解析成功と全クロス実行先です。
固定Verilatorの両seedは14 pass・4 known、kirimasimでは新規18件がC読込み未対応です。部分成功を合成せず、補助実験は通常の合格数へ加算しません。
[モデルの範囲と再確認手順](../../docs/interaction-verification.md#dpi-copyback-and-nba-capture)を参照してください。

<a id="constraint-inheritance-and-failure-retention-checks"></a>

## 継承制約と失敗時の値の保持の確認

[`constraint-inheritance.json`](constraint-inheritance.json)は、96行の独立した制約ブロックの合成・候補列挙と、2正常対照・5故障の出力差による検出を記録します。
[`constraint-inheritance-build.json`](constraint-inheritance-build.json)は、最新kirimasimの上流確認済みコミット・バイナリ指紋・13件の解析成功と全クロス実行先です。
固定Verilatorの両seedは全13件がPASSで、kirimasimではrandomize未対応です。補助実験は通常の合格数へ加算しません。
[範囲と再確認手順](../../docs/interaction-verification.md#constraint-inheritance-and-failure-retention)を参照してください。

<a id="clocking-input-and-assertion-checks"></a>

## clocking変数とアサーションの確認

[`clockassert.json`](clockassert.json)は、全288行の独立した時刻・イベント領域の履歴検算と、2正常対照・5故障の出力差による検出を記録します。
[`clockassert-build.json`](clockassert-build.json)は、最新kirimasimの上流確認済みコミット・バイナリ指紋・18件の解析成功と全クロス実行先です。
固定Verilatorの両seedで全18件がPASS、kirimasimでは並行アサーションが未対応です。補助実験は通常の合格数へ加算しません。
[範囲と再確認手順](../../docs/interaction-verification.md#clocking-inputs-and-assertion-clocks)を参照してください。

<a id="dpi-open-array-shape-and-copyback-checks"></a>

## DPI open arrayの形状と書戻しの確認

[`dpi-array.json`](dpi-array.json)は全168行の独立検算、実Cヘルパーとテスト専用ABIの全168行×2初期値の照合、正常対照1件と5故障の出力差による検出を記録します。
ABIスタブは離れた要素とcanaryを使い、シミュレータの動的配列・キューの受渡しを確認した結果には加えません。
[`dpi-array-build.json`](dpi-array-build.json)は最新上流と照合したkirimasimの版・バイナリ指紋・全30件の解析結果です。
通常ランナーはC読込み未対応で全30件を実行前に止めますが、別途の解析は24件が成功し、合法なキュー6件が型照合で拒否されました。
固定Verilatorは両seedとも固定配列18件がPASS、動的配列・キュー12件は既知のビルド失敗です。
[範囲と再確認手順](../../docs/interaction-verification.md#dpi-open-array-shape-and-copyback)を参照してください。

<a id="class-shallow-copy-and-array-checks"></a>

## クラスの浅いコピーと配列の確認

[`class-array.json`](class-array.json)は、全240行の独立したオブジェクトグラフとの照合、正常対照2件、6故障の出力差による検出を記録します。
[`class-array-build.json`](class-array-build.json)は、最新上流と照合したkirimasimの版・バイナリ指紋・全18件の解析成功と全クロス実行先です。
固定Verilatorは両seedとも全18件がPASS、kirimasimでは固定配列6件がPASS、動的配列・キュー12件が未対応です。補助実験は通常の合格数へ加算しません。
[範囲と再確認手順](../../docs/interaction-verification.md#class-array-storage-and-shared-elements)を参照してください。

<a id="resolved-strength-formatting-checks"></a>

## 解決済み駆動強度の表示の確認

[`strength-format.json`](strength-format.json)は、全180行の独立した駆動寄与・優先順位表との照合、3種類のformat APIの正常対照、5故障の出力差による検出を記録します。
[`strength-format-build.json`](strength-format-build.json)は、最新上流と照合したkirimasimの版・バイナリ指紋・全31件の解析成功と全クロス実行先です。
固定Icarus Verilog 13.0は全31件がPASSです。追加時点のkirimasim `f2d9a1136576`の`%v`未対応記録を保持し、今回のkirimasim `80859f34f0aa`では全31件がPASSしました。補助実験は通常の合格数へ加算しません。
[範囲と再確認手順](../../docs/interaction-verification.md#resolved-strength-formatting)を参照してください。

<a id="class-held-virtual-interface-rebinding-checks"></a>

## クラス内virtual interfaceの再結合の確認

[`vif-class.json`](vif-class.json)は、全192行の独立した結合グラフとの照合、正常対照3件、6故障の出力差による検出を記録します。
[`vif-class-build.json`](vif-class-build.json)は、最新上流と照合したkirimasimの版・バイナリ指紋・全13件の解析成功と全クロス実行先です。
固定Verilatorは両seedとも全13件がPASS、kirimasimではクラス内のvirtual interface型が未対応です。補助実験は通常の合格数へ加算しません。
[範囲と再確認手順](../../docs/interaction-verification.md#class-virtual-interface-rebinding)を参照してください。

<a id="clocking-event-iff-and-sample-retention-checks"></a>

## clocking eventのiffとサンプル保持の確認

[`clockiff.json`](clockiff.json)は、全288行の独立イベントキューとの照合、正常対照3件、6故障の出力差による検出を記録します。
ベクタの補助対照2件では条件を明示的なリダクションORへ変更し、元のケースの合格とは区別します。
[`clockiff-build.json`](clockiff-build.json)は、最新上流と照合したkirimasimの版・バイナリ指紋・全12件の解析成功と全クロス実行先です。
固定Verilatorは両seedともスカラ条件4件がPASS、ベクタ条件8件は既知の内部ビルドエラーです。kirimasimではガード付きclocking eventが未対応です。
[範囲と再確認手順](../../docs/interaction-verification.md#clocking-event-guards-and-held-samples)を参照してください。
