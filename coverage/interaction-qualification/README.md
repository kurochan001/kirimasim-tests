<a id="auxiliary-evidence-for-cross-functional-verification"></a>

# 機能間クロス検証の補助証跡

[English](README.en.md) / [日本語](README.md)

このディレクトリは、固定版の確認元選別、独立検算、最小例、故障注入、ビルド版の確認記録を 保存します。現在の入力に対応する回帰実行は[`interaction-results/`](../interaction-results/)、 充足状況は[クロス検証レポート](../../docs/interaction-coverage.md)を参照してください。 補助証跡の正常・故障条件の件数を、スイートの合格数や要求カバレッジへ加算しません。 入力ハッシュが古くなった記録は履歴として残し、新しいハッシュへ書き換えず再確認を別途記録します。 「最新」のビルドは各記録の確認時点での意味です。コミットと日時を確認してください。

<a id="current-evidence-checkpoint"></a>

## 最新証跡の確認（2026-11-06 日本時間）

現行は110モデル・4,416件で、[moduleとgenerateブロックのクラス・case項目のリテラル・構造体リテラルの独立確認](#scope-case-literal-qualification)を参照してください。
[`handoff-ci-67321079-20261106.json`](handoff-ci-67321079-20261106.json)は、基点67321079のCheck/Nightlyと全ジョブの成功を記録します。個別artifactは未照合です。以下の旧基点は詳細照合の範囲を区別して保持します。
[`check-9c39d865-20261106.json`](check-9c39d865-20261106.json)は前回までの86モデルの固定版比較・静的検査のCheck成功を確認します。
[`formal-ci-19cd790a-20261105.json`](formal-ci-19cd790a-20261105.json)は82モデルを対象にした正式Nightly・publish・ランダム96 PASSの記録であり、実行を混同しません。
今回の36件はCheck・Nightlyでは未実行です。生成ループ以降の252件は、この個別artifactまで照合済みの旧Nightlyの範囲外です。

<a id="checkpoint-9926160a"></a>

## 前回の正式証跡（2026-11-04 日本時間）

[`formal-ci-9926160a-20261104.json`](formal-ci-9926160a-20261104.json)に、suite `9926160a`のCheck・Nightly・公開処理の成功を記録しています。
kirimasim `9113955914d8`の有限クロス全2,922件はcross79と入力ハッシュ・状態分類が一致し、
2,389 pass・529 unsupported・configの4 fail、全選択ケースPASSは52モデル、対応する章対は114組です。
13プロファイルのランダム96件はすべて有効なPASSで、固定suiteの証跡とは区別します。
記録には元artifactのハッシュと全ランダム出力の照合を含み、保存SVの独立解釈は配列14件・package 8件です。
既存証跡の読取りによる確認であり、シミュレータの新しい実行やカバレッジの追加ではありません。
固定suiteでは、通常のspecify条件テスト5件がunsupportedからPASSへ改善しています。
テストの識別と入力ハッシュの不変を、有限クロスの選択やratchetのゲートとは別に記録しています。
[前回の確認記録](formal-ci-e8d991a9-20261104.json)も変更せず保持します。
版・日時・workflowのリンクは[最新の正式確認](../../docs/nightly-results.md#latest-verified-checkpoint)を参照してください。

ランダム検証の開発時の証跡は、日時を付けて別に保持します。

- 拡張記録と実際のreplay manifest：[5個](random-cross-five-profiles.json)／[manifest](random-cross-five-profiles-manifest.json)、
  [7個](random-cross-seven-profiles.json)／[manifest](random-cross-seven-profiles-manifest.json)、
  [9個](random-cross-nine-profiles.json)／[manifest](random-cross-nine-profiles-manifest.json)、
  [11個](random-cross-eleven-profiles.json)／[manifest](random-cross-eleven-profiles-manifest.json)、
  [13個](random-cross-thirteen-profiles.json)／[manifest](random-cross-thirteen-profiles-manifest.json)。
- [13プロファイルの安定化](random-stabilization-20261103.json)：ローカル1,152 PASS、保存済み配列・packageの864件を独立解釈しています。
  パック書込み288件は既存の実行・参照比較です。[範囲とコマンド](../../docs/random-cross-verification.md#thirteen-profile-stabilization)を参照してください。

直近の有限モデルの追加は、[遅延報告の引数](deferarg.json)、[generate内enum](genenum.json)、
[packageのNBA取得](pkgnba.json)、[package変更の観測](pkgwatch.json)です。
それぞれの`*-build.json`と`*-fixed-replays.json`もこのディレクトリで別に保持します。
設計・対照・固定版の既知差・制限は[モデル別ガイド](../../docs/interaction-verification.md)を参照してください。
以下の元の失敗や導入時の未コミットビルドの記録は、当時の証跡として保持します。

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

<a id="independent-associative-query-checks"></a>

## 連想配列問い合わせの独立検算

[`assocquery.json`](assocquery.json)は`associative_array_queries@1`の全216行を、別のエントリ列と境界値表で照合した記録です。
6種類のPython仕様モデルの変異を、選択済みケースの期待出力で区別します。SystemVerilogへの故障注入実行や、シミュレータの正常対照成功ではありません。
固定Verilatorは両seedとも全18件が出力不一致、固定Icarusは全18件をビルド時に拒否し、固定版oracleは追加していません。
[`assocquery-build.json`](assocquery-build.json)は実行直前に確認した最新kirimasimのコミット・ビルド版・バイナリ指紋と解析結果を記録します。
解析は18件とも成功し、実行は型付き連想配列変数が未対応です。通常の保存実行は`interaction-results/cross64-*.json`です。
[設計と限界](../../docs/interaction-verification.md#associative-array-domains-and-allocation)も参照してください。

<a id="array-reduction-constraints-and-auxiliary-controls"></a>

## 配列リダクション制約と補助対照

[`randreduce.json`](randreduce.json)は全192行を端点の定数表とビット単位の演算で独立に照合します。
固定配列の補助対照4件は、通常の観測値にだけ要素型のキャストを追加し、制約式と期待値を保持します。7故障を正常終了時の出力差で検出しました。
これは元の13件の実行成功でも、動的配列のサイズ保持の実行確認でもありません。元のケースは固定Verilatorの両seedとも全13件が出力不一致、固定Icarusはビルド時の拒否です。
[`randreduce-build.json`](randreduce-build.json)に実行直前に確認した上流コミット、ビルド版、バイナリ指紋、解析を記録します。
解析は13件とも成功し、固定8件はrandomize、動的5件はクラス内配列操作が未対応です。通常の保存実行は`interaction-results/cross65-*.json`です。
[設計と確認限界](../../docs/interaction-verification.md#array-reduction-constraints-and-retention)を参照してください。

<a id="bounded-random-comparison-qualification"></a>

## 件数制限付きランダム比較の導入確認

[`random-cross.json`](random-cross.json)は、上流mainを実行直前に確認してビルドしたkirimasim `866abf4d86d1`でのローカル検証です。
seed 1・73の各96ケースとseed 20261102の256ケース、計448件がPASSし、保存刺激からの1件再現はSV・期待値がバイト一致しました。
演算子を意図的に変更したSVは正常終了して出力差で検出されました。固定Icarus Verilog 13.0でも3プロファイルの計12サンプルが一致しました。
[`random-cross-manifest.json`](random-cross-manifest.json)に96ケースの実際の刺激を保存しています。
ランダム実行、再現、故障注入を固定スイートの本数や合格モデル数へ加算せず、GitHub Nightly成功とも読み替えません。
[対象・制限・再現手順](../../docs/random-cross-verification.md)を参照してください。

<a id="aggregate-event-lifetime-checks"></a>

<a id="independent-aggregate-event-lifetime-checks"></a>

## 構造体内イベントの寿命の独立検算

[`eventlife.json`](eventlife.json)は全432行のSV刺激を独立したオブジェクト・フレーム・イベントキューで解釈し、期待値と照合した記録です。
8種類のソース変異を解釈上の出力差・残存待機で識別します。SVの故障注入実行や正常対照の実行成功ではありません。
固定Icarus／Verilatorは全18件をビルド時に拒否し、oracleは追加していません。
[`eventlife-build.json`](eventlife-build.json)は実行直前に確認した上流コミット、ビルド版、バイナリ指紋、解析成功18件と全クロス実行先を記録します。
kirimasimの実行はイベント値操作が未対応です。[設計と限界](../../docs/interaction-verification.md#aggregate-event-lifetime)を参照してください。

<a id="sv-dpi-array-query-checks"></a>

<a id="independent-svdpi-array-query-checks-and-execution"></a>

## SV/DPI配列問い合わせの独立検算と実行

[`dpiquery.json`](dpiquery.json)は、生成宣言・問い合わせ式による全1,152行の独立検算と、実際のCプローブをテスト専用ABIスタブで2,304回呼び出した照合を記録します。
合成した形状のスタブは、シミュレータのマーシャリングの確認ではありません。元の正規化済みpackedの対照3件と、SV/Cの6故障は全て実行し、終了コード0で出力差を検出しました。
オフセット付きpackedとopen packedの実行確認はこの対照の範囲外です。通常の固定Verilator実行は11 pass・8 knownです。
[`dpiquery-v2.json`](dpiquery-v2.json)は、model version 2（2026-11-12）の同じ検算です。全832行、1,664呼出し、対照3件、故障6件の検出を記録します。16件の通常の固定Verilator実行は6 pass・10 knownです。
[全行の記録](edgedpiquery-all-rows.json)は、`edge_event_expression`のversion 2の全4,032行と、このモデルの全832行の一度きりの実行で、固定suiteや要求カバレッジへ加算しません。エッジの行は、kirimasimとIcarusがすべて一致します。このモデルの行を実行するのはVerilatorだけで、176行が一致し、240行が異なり、416行を拒否します。
[`dpiquery-build.json`](dpiquery-build.json)は最新上流と照合したビルド版・バイナリ指紋・19件の解析成功・全クロス実行先を記録します。
kirimasimランナーはCコード付きテストを実行前に未対応へ分類するため、DPI実行は未確認です。
[設計と限界](../../docs/interaction-verification.md#sv-dpi-array-queries)を参照してください。

<a id="sdf-conditional-path-checks"></a>

<a id="sdf-conditional-path-checks-and-execution"></a>

## SDF条件付きパスの検算と実行

[`sdfpath.json`](sdfpath.json)は、生成specify・SDF・刺激列を独立したパーサとイベントヒープで全288行照合した記録です。
元の通常パス・ABSOLUTEの正常対照3件とSV/SDFの6故障は、固定Icarusで全て終了コード0となり、故障を出力差で検出しました。
COND／CONDELSE／INCREMENTに関する3変異は独立解釈だけで、実行による故障検出とは分けます。
通常の固定Icarus実行は3 pass・15 known、固定Verilatorは両seedで18 knownです。
[`sdfpath-build.json`](sdfpath-build.json)は実行直前に確認した上流コミット・ビルド版・バイナリ指紋・18件の解析成功・全クロス実行先を記録します。
kirimasimの実行は条件付きパスまたは$sdf_annotateが未対応です。[設計と限界](../../docs/interaction-verification.md#sdf-conditional-paths)を参照してください。

<a id="checker-assertion-sampling-checks"></a>

<a id="independent-checker-sampling-checks-and-execution"></a>

## checkerサンプリングの独立検算と実行

[`checksample.json`](checksample.json)は、生成した接続・clocking・刺激を別の領域モデルで全1,296行照合した記録です。
元の正常対照5件とSVの7故障は全て終了コード0で、故障を出力差として検出しました。
別の2件の不一致再現は、正常対照や故障検出に加算しません。1ビットベクタの同時刻NBAでは、checkerとmodule参照が同じ古い生値を返しました。
通常の固定Verilator実行は両seedで25 pass・2 known、固定Icarusは全27件をビルド時に拒否しています。
[`checksample-build.json`](checksample-build.json)は最新上流と照合したビルド版・バイナリ指紋・27件の解析成功・全クロス実行先を記録します。
kirimasimの実行はcheckerインスタンスが未対応です。[設計と共通の誤りの検出](../../docs/interaction-verification.md#checker-assertion-sampling)を参照してください。

[`checksample-m4.json`](checksample-m4.json)は、M4の既存トレースによる再照合で7一致・44明示保留を記録します。
追加したchecker候補2件は、入力ハッシュと理由付きでM4では保留とし、クロス専用の検算やシミュレータ再現とは区別します。

<a id="program-assertion-attempt-checks"></a>

<a id="independent-program-assertion-attempt-checks-and-execution"></a>

## programアサーション試行の独立検算と実行

[`progassert.json`](progassert.json)は、生成された接続・刺激・property・アクションを独立に解析する全648行の検算です。
単周期/同サイクル含意の正常対照6件と実際のSV故障7件は終了コード0で実行し、出力差で故障を検出します。
次サイクル含意の既知差2件の再実行は、正常対照や故障検出には数えません。
固定Verilatorは両seedで18 pass・9 knownです。別途再実行した2件ではprogramとmoduleの両方が最初の次サイクル試行の完了前に成功を数えるため、
実装同士の比較に加えて独立した試行開始・完了の期待値を使います。
[`progassert-build.json`](progassert-build.json)に、実行直前の上流取得・版・バイナリハッシュ・解析と全クロス結果を保存します。
[設計と確認範囲](../../docs/interaction-verification.md#program-assertion-attempts)を参照してください。

[`progassert-m4.json`](progassert-m4.json)は既存入力トレースによる7 match・53 deferredです。
新規9候補にはソースハッシュ付き保留理由を追加し、M4成功や新規シミュレータ実行に数えません。

<a id="container-coverage-sampling-checks"></a>

<a id="independent-container-mutation-and-sample-checks"></a>

## コンテナ更新とsampleの独立検算・実行

[`cgsample.json`](cgsample.json)は、格納・コピー・更新・sample順序・引数・ガード・bin履歴を別に解釈した全1,056行の検算です。
正常対照6件と実際のSV故障7件はすべて終了コード0で実行し、出力差で故障を検出しました。
固定Verilatorは両seedで33件すべて一致しました。空コンテナ用の単独binを使い、at_leastは各coverpointへ直接指定します。
単一coverpointのgroupから割合を取得するため、coverpoint単位の問い合わせやref出力・既定値継承は確認範囲に含めません。
[`cgsample-build.json`](cgsample-build.json)に、実行直前の上流取得・版・バイナリハッシュ・解析33件と全クロス結果を保存します。
kirimasimのcovergroup実行は未対応です。[設計と確認範囲](../../docs/interaction-verification.md#container-coverage-sampling)を参照してください。

<a id="deferred-disable-report-checks"></a>

<a id="independent-disabledeferred-report-checks-and-replays"></a>

## disableと遅延報告の独立検算・再現

[`deferdis.json`](deferdis.json)はAST・制御移動・プロセス別キューと引数取得を別に解釈する全720行の検算です。
固定Verilatorの正常対照6件・SV故障7件・既知差3件は全16実行が終了コード0です。既知差は正常対照や検出故障には数えません。
両seedの通常実行は13 pass・18 knownで、この対照だけではラベル取消し・最外flush・Reactive実行時点を確認できません。
[`deferdis-build.json`](deferdis-build.json)は最新上流からのビルド・解析31件と、26 pass・ラベル取消し5 failの記録です。
[`deferdis-native.json`](deferdis-native.json)は、改めて最新を取得・ビルドし、5件を出力差として再現した全出力です。
他サイトと引数評価回数は一致し、内側/task/最外/liveの正常対照4件もPASSしました。stderrの実行パスのみ公開用に置換しています。
別の対象報告がないcover対照1件は、ラベル取消しの成功を示しません。
[設計と確認範囲](../../docs/interaction-verification.md#deferred-disable-reports)を参照してください。

<a id="class-method-package-lookup-checks"></a>

## クラスメソッド×package参照の独立確認

[`classimp-final.json`](classimp-final.json)では、実際に生成した合法3,264プログラムを、宣言型・字句スコープのimport・
オブジェクト識別・整数の値/X/Zの各ビット面で独立に解釈しています。ネイティブの正常対照4件・実際のSVへの8故障は全て正常終了し、
全故障を出力差で検出しました。補助確認であり、スイートのPASS件数へ加算しません。
[`classimp-build-final.json`](classimp-build-final.json)に、最新mainの取得・構成・ビルド、新規34件の解析成功、
単一の全2,956件のネイティブ実行を記録しています。結果は2,423 pass・529 unsupported・既存configの4 failです。
追加34件は全PASS、従来2,922件の入力・状態分類は不変です。章間表はこの単一ローカル実行を使い、
80モデル・115章対・全選択ケースPASS 53モデルです。正式CIの範囲は追加前の選択のままです。
[`classimp-fixed-replays-final.json`](classimp-fixed-replays-final.json)に固定Verilatorのseed 1/73（各18 pass・16 known）、
固定Icarus 13.0（34件ともビルド拒否のknown）、driver/runtimeの実行ファイルのハッシュを保持します。
4値を必要とせず固定Verilatorの両seedに一致した18件だけに、そのoracleを登録し、他の期待値は維持しています。
[設計・制限・再実行コマンド](../../docs/interaction-verification.md#class-method-package-lookup)を参照してください。

[`classimp-metadata-correction.json`](classimp-metadata-correction.json)に、4値入力が必要な8件のタグ修正を保持します。SV本体・期待値は不変で、先行スナップショットの古いハッシュを最終の成功へ合成しません。

<a id="generated-subroutine-qualification"></a>

## 生成サブルーチンと配列結合の独立確認

[`gensub.json`](gensub.json)は、実際のSVから全合法2,304プログラムを独立に展開・解釈しています。
正常対照4件と実際のSVへの9故障は全て正常終了し、全故障を出力差で検出しました。
確認中のソース・入力・バイナリのハッシュの不変も照合しています。[`gensub-build.json`](gensub-build.json)に、
最新main `162222153c57`、36件の解析成功、単一の全2,992件の実行を記録しています。
2,459 pass・529 unsupported・既存configの4 failで、追加36件は全PASS、従来2,956件の入力・状態分類は不変です。
この追加時点の章間表はこの実行を使い、81モデル・117章対・全選択ケースPASS 54モデルでした。
[`gensub-fixed-replays.json`](gensub-fixed-replays.json)に、固定Icarus 13.0（36 pass）と固定Verilator 5.052のseed 1/73（各11 pass・25 known）を保持します。
全36件にIcarusのoracleを登録し、2値での観測を4値の確認に使いません。
[`gensub-known-replays.json`](gensub-known-replays.json)には、元のtaskの全出力と、期待値が変わらない[function対照の実際のSV](gensub-function-control/)を保持します。
元のtaskの差異は保持した結果だけで、IcarusとVerilatorの両seedはfunction対照に一致します。
これらは固定suiteの外の対照であり、PASS件数・カバレッジへ加算しません。
[設計・制限・再実行コマンド](../../docs/interaction-verification.md#generated-subroutine-binding)を参照してください。

<a id="class-selection-qualification"></a>

## クラスの条件選択とreturnの独立確認

[`classsel.json`](classsel.json)は合法1,296行の実際のSVを独立に解釈します。
主参照の関数を使わず、静的/virtualな呼出し先、型付き戻り値、X/Zのマージ、制御文、ハンドルの同一性を追います。
正常対照5件・SVへの9故障は全て正常終了し、全故障を出力差で検出しました。
[`classsel-build.json`](classsel-build.json)は、最新main取得・構成・ビルドの`162222153c57`、parse成功36件、
全3,028件の単一実行（2,495 pass・529 unsupported・既存configの4 fail）を記録します。追加は全PASS、従来2,992件の入力・状態分類は不変です。
82モデル・119章対・全選択ケースPASSは55モデルで、第8章×第12章の対応はif/caseの24件です。
[`classsel-fixed-replays.json`](classsel-fixed-replays.json)は固定Icarusのクラスハンドル比較の拒否36 knownと、
Verilatorのseed 1/73の各12 pass・24 knownを識別します。既知値で一致したものだけにVerilatorのoracleを登録します。
[`classsel-known-replays.json`](classsel-known-replays.json)には、変更していない期待値、代表X入力の両seedの出力、
Zのビルド診断、Icarusの拒否を保持します。2値の観測でX/Zの動作を検証済みとはせず、外部4値の確認は未確認です。
これらはローカル/補助の記録で、正式CI・固定要求カバレッジ・13ランダムプロファイルと分けます。
[設計・コマンド・制限](../../docs/interaction-verification.md#class-conditional-return)を参照してください。

<a id="generated-loop-qualification"></a>

## 生成ループの独立確認

[`genloop.json`](genloop.json)は合法6,912行の実際のSVを独立に展開・実行します。
正常対照5件とSVへの9故障で、局所配列・制御移動先・集約・クロックエッジ・guardの観測を検算します。
[`genloop-build.json`](genloop-build.json)は直前取得・ビルドの本体`50a897dee62a`、parse成功36件、全3,064件の単一実行を記録します。
2,531 pass・529 unsupported・既存configの4 failで、追加は全PASS、従来3,028件の入力・分類は不変です。
現在は83モデル・121章対・全選択ケースPASS 56モデルです。
[`genloop-fixed-replays.json`](genloop-fixed-replays.json)にIcarus 13.0の31 pass・5 known、Verilatorのseed 1/73の各12 pass・24 knownを保持します。
[`genloop-known-replays.json`](genloop-known-replays.json)はrepeat回数1の拒否5件と独立に解釈した回数3の対照2件を記録し、
[対照SV・期待値](genloop-repeat-controls/)を固定テストの外に保存します。期待値や失敗記録は置き換えません。
[設計・範囲・再実行手順](../../docs/interaction-verification.md#generated-process-loop-transfer)を参照してください。

<a id="interface-query-qualification"></a>

## interface配列問い合わせの独立確認

[`ifquery.json`](ifquery.json)は実際のSVの宣言・問い合わせ・型付き呼出し・走査を全4,608行で独立に解釈します。
正常対照5件と9種類の実際のソース故障をnativeで実行し、全て正常終了して全故障を出力差で検出しました。
[`ifquery-build.json`](ifquery-build.json)は直前に取得・ビルドした`50a897dee62a`と、追加36件のparse成功、単一の全3,100件の実行を記録します。
2,567 pass・529 unsupported・既存configの4 failで、追加は全PASS、従来3,064件の入力・分類は不変です。
84モデル・124章対・全選択ケースPASSは57モデルです。
[`ifquery-fixed-replays.json`](ifquery-fixed-replays.json)はIcarus 13.0の36 pass、Verilator 5.052のseed 1（12 pass・24 known）と73（13 pass・23 known）を識別します。
両seedで一致した既知値12件だけにVerilatorのoracleを登録し、seed 73で偶然一致したbit/X入力は4値の確認とはしません。
全36件はIcarusの確認元を保持します。[設計・範囲・コマンド](../../docs/interaction-verification.md#interface-array-query-walk)を参照してください。

<a id="generated-expression-qualification"></a>

## 定数式とgenerateの独立確認

[`genexpr.json`](genexpr.json)は型付き定数式・分岐・ループ・連続代入を実際のSVから全6,912行で独立に解釈します。
正常対照5件と実際のSV故障9件は全て正常終了し、全故障を出力差で検出しました。
[`genexpr-build.json`](genexpr-build.json)は最新取得・ビルドの`92001039e896`、parse成功36件、単一の全3,136件の実行を記録します。
2,603 pass・529 unsupported・既存configの4 failで、追加36件は全PASS、従来3,100件の入力・分類は不変です。
85モデル・126章対・全選択ケースPASSは58モデルです。[固定版比較](genexpr-fixed-replays.json)はIcarusの36 passとVerilatorの両seed各12 pass・24 knownを識別します。
既存の入力・期待値を変更せず、2値の結果でX/Zを検証済みとはしません。[設計とコマンド](../../docs/interaction-verification.md#generated-constant-expression-shape)を参照してください。

<a id="formatted-scan-qualification"></a>

## 書式付き読取りの独立確認

[`scansel.json`](scansel.json)は実際の文字列と書式、停止位置、型付きの部分書込みを全5,760行で独立に解釈します。
正常対照6件と9故障は全て正常終了し、全故障を出力差で検出しました。[ビルド記録](scansel-build.json)は単一の全3,172件で
2,639 pass・529 unsupported・既存configの4 failを記録し、追加36件はparse成功・全PASS、従来3,136件の入力・分類は不変です。
[固定版比較](scansel-fixed-replays.json)はIcarusの17 pass・19 knownと、Verilatorの各seed 3 pass・33 knownを識別します。
[元の19件とVの3例の全出力](scansel-known-replays.json)、[別の12 literal対照](scansel-literal-controls/)を保持し、対照7件の一致で元の結果を上書きしません。
86モデル・128章対・全選択ケースPASSは59モデルです。[設計・範囲・コマンド](../../docs/interaction-verification.md#formatted-scan-partial-write)を参照してください。

<a id="program-task-frame-qualification"></a>

## programとautomatic taskの独立確認

[`progframe.json`](progframe.json)は全3,456行の実際のSVを、型付きの局所フレームとイベント列で独立解釈します。
正常対照6件と実行可能な誤り9件はすべて正常終了し、誤りを出力差で検出しました。
[ビルド記録](progframe-build.json)は最新取得・ビルドの`6f5c69841228`、36件の解析成功と全3,208件の単一実行を識別します。
全体は2,675 pass・529 unsupported・既存configの4 failで、追加36件は全PASS、従来3,172件の入力・状態分類は不変です。
[固定版比較](progframe-fixed-replays.json)はIcarus 6 pass・30 known、Verilator両seedとも36 knownです。
[全30件のIcarus診断と代表Verilator再現](progframe-known-replays.json)を保持し、既存期待値は変更しません。
87モデル・130章対・全選択ケースPASSは60モデルです。[設計・制約・再実行](../../docs/interaction-verification.md#program-task-frame-lifetime)を参照してください。

<a id="package-query-qualification"></a>

## package問い合わせの独立確認

[`pkgquery.json`](pkgquery.json)は全3,456行の実際のSVを、別の配列・型・名前解決・問い合わせ・走査として解釈します。
正常対照6件と実行できる誤り9件はすべて正常終了し、誤りを出力差で検出しました。
[ビルド記録](pkgquery-build.json)は最新取得・ビルドの`6f5c69841228`、36件の解析成功と単一の全3,244件を識別します。
追加36件は全PASS、従来3,208件の入力・状態分類は不変で、全体は2,711 pass・529 unsupported・既存configの4 failです。
[固定版比較](pkgquery-fixed-replays.json)はIcarus 36 known、Verilator seed 1が12 pass・24 known、seed 73が13 pass・23 knownです。
[全36件のIcarus診断と代表的な両seedのX/Z出力](pkgquery-known-replays.json)を保持し、偶然一致したbit/Xを4状態の確認へ流用しません。
全体は88モデル・131章対・全選択ケースPASSは61モデルです。[設計・制約・再実行](../../docs/interaction-verification.md#package-array-query-scope)を参照してください。

<a id="event-loop-qualification"></a>

## イベント受信ループの独立確認

[`eventflow.json`](eventflow.json)は全2,016行を独立したActive/NBAキューとループ・待機・取消しの解釈で照合します。
正常対照6件・誤ったSVの9件は正常終了し、誤りはすべて出力差で検出しました。
[ビルド記録](eventflow-build.json)は`6f5c69841228`の全3,280件（2,747 pass・529 unsupported・既存4 fail）を識別します。
追加36件は全PASS、従来3,244件の入力・分類は不変です。89モデル・132章対・全選択ケースPASSは62モデルです。
[固定版比較](eventflow-fixed-replays.json)はIcarus 36 known、Verilator両seedとも8 pass・28 knownです。
[元の診断・出力](eventflow-known-replays.json)と[別のblocking発火対照4件](eventflow-blocking-controls/)を保存しました。
後者のVerilator両seed計8一致を元のNBAケースのPASSへ数えません。[設計と再実行](../../docs/interaction-verification.md#named-event-loop-transfer)を参照してください。

<a id="time-literal-gate-qualification"></a>

## 時間スコープ・リテラル・ゲート配列の独立確認

[`timescope.json`](timescope.json)は全8,064行、[`literal.json`](literal.json)は全6,552行、[`gatearray.json`](gatearray.json)は全4,464行を独立した解釈で照合します。
正常対照は順に5件・6件・6件、誤ったSVは各9件で、誤りはすべて正常終了後の出力差で検出しました。
[ビルド記録](timelitgate-build.json)は`60c26d7c8113`の全3,445件（2,912 pass・529 unsupported・既存4 fail）を識別します。
追加165件は全PASS、従来3,280件の入力・分類は不変です。92モデル・151章対・全選択ケースPASSは65モデルです。
[固定版比較](timelitgate-fixed-replays.json)はIcarus 144 pass・21 known、Verilator両seedとも38 pass・127 knownです。
[全Icarusの差とVerilatorの代表出力](timelitgate-known-replays.json)を保存しました。
[全行の記録](timelitgate-all-rows.json)は全19,080行の一度きりの実行で、固定suiteや要求カバレッジへ加算しません。リテラルの期待値を直した経緯も記録します。
[設計と再実行](../../docs/interaction-verification.md#time-scope-delay)を参照してください。

<a id="macro-force-sense-qualification"></a>

## マクロ展開・force/release・暗黙の感度の独立確認

[`macro.json`](macro.json)は全7,679行、[`force.json`](force.json)は全2,160行、[`sense.json`](sense.json)は全630行を独立した解釈で照合します。
正常対照は順に9件・8件・9件、誤ったSVは順に10件・10件・9件で、誤りはすべて正常終了後の出力差で検出しました。
[ビルド記録](macroforcesense-build.json)は`97d5b0001e7c`の全3,692件（3,159 pass・529 unsupported・既存4 fail）を識別します。
追加247件は全PASS、従来3,445件の入力・分類は不変です。95モデル・168章対・全選択ケースPASSは68モデルです。
[固定版比較](macroforcesense-fixed-replays.json)はIcarus 192 pass・55 known、Verilator両seedとも179 pass・68 knownです。
[全Icarusの差とVerilatorの代表出力](macroforcesense-known-replays.json)を保存しました。
[全行の記録](macroforcesense-all-rows.json)は全10,469行の一度きりの実行で、固定suiteや要求カバレッジへ加算しません。kirimasimの差は0件です。
[設計と再実行](../../docs/interaction-verification.md#macro-expansion-context)を参照してください。

<a id="interface-loop-literal-qualification"></a>

## インタフェースの式・ループの制御・リテラルの表示の独立確認

[`ifexpr.json`](ifexpr.json)は全2,940行、[`loopsched.json`](loopsched.json)は全165行、[`litfmt.json`](litfmt.json)は全1,778行を独立した解釈で照合します。
正常対照は順に7件・6件・9件、誤ったSVは順に7件・6件・9件で、誤りはすべて正常終了後の出力差で検出しました。
[ビルド記録](ifexprloopfmt-build.json)は`6e32b04ed6ec`の全3,887件（3,404 pass・479 unsupported・既存4 fail）を識別します。
追加195件は全PASS、従来3,692件の入力は不変で、50件がunsupportedからPASSになりました。98モデル・173章対・全選択ケースPASSは74モデルです。
[固定版比較](ifexprloopfmt-fixed-replays.json)はIcarus 134 pass・61 known、Verilator両seedとも188 pass・7 knownです。
[全Icarusの差とVerilatorの代表出力](ifexprloopfmt-known-replays.json)を保存しました。
[全行の記録](ifexprloopfmt-all-rows.json)は全4,883行の一度きりの実行で、固定suiteや要求カバレッジへ加算しません。kirimasimの差は0件です。
Icarusがインタフェースのポートを解析できないので、インタフェースとループのモデルの全行はVerilatorでも一度実行しました。
[設計と再実行](../../docs/interaction-verification.md#interface-member-expression)を参照してください。

<a id="param-assert-literal-qualification"></a>

## パラメータの上書き・アサーションのビットベクタ関数・リテラルの引数の独立確認

[`paramtype.json`](paramtype.json)は全252行、[`assertquery.json`](assertquery.json)は全450行、[`litarg.json`](litarg.json)は全472行を独立した解釈で照合します。
正常対照は順に8件・6件・8件、誤ったSVは順に8件・6件・8件で、誤りはすべて正常終了後の出力差で検出しました。
パラメータの正常対照は、kirimasimが取り違える`defparam`の行を避けて選びました。その行は選択ケースのfailとして現れます。
[ビルド記録](paramassertlit-build.json)は`eee8cd16ba1d`の全4,023件（3,536 pass・479 unsupported・8 fail）を識別し、追加のfail 4件の理由も保存します。
従来3,887件の入力と状態は不変です。101モデル・177章対・全選択ケースPASSは76モデルです。
[固定版比較](paramassertlit-fixed-replays.json)はIcarus 111 pass・25 known、Verilator両seedとも111 pass・25 knownです。
[全Icarusの差とVerilatorの代表出力](paramassertlit-known-replays.json)を保存しました。
[全行の記録](paramassertlit-all-rows.json)は全1,174行の一度きりの実行で、固定suiteや要求カバレッジへ加算しません。kirimasimの差はパラメータの24行だけです。
Icarusが受理しない行を補うため、パラメータとリテラルの引数のモデルの全行はVerilatorでも一度実行しました。
[設計と再実行](../../docs/interaction-verification.md#parameter-override-type)を参照してください。

<a id="hier-array-qualification"></a>

## 階層名によるプロセスの制御・%mの階層名・配列の問い合わせ関数とループの独立確認

[`hierproc.json`](hierproc.json)は全252行、[`hiername.json`](hiername.json)は全177行、[`arrayloop.json`](arrayloop.json)は全440行を独立した解釈で照合します。
正常対照はどれも7件、誤ったSVもどれも7件で、誤りはすべて正常終了後の出力差で検出しました。
[ビルド記録](hierloop-build.json)は`28c6c1a1cb83`の全4,170件（3,683 pass・479 unsupported・8 fail）を識別します。追加147件は全PASSです。
従来4,023件の入力と状態は不変で、failは前回と同じconfigの4件と`defparam`の4件です。104モデル・181章対・全選択ケースPASSは79モデルです。
[固定版比較](hierloop-fixed-replays.json)はIcarus 95 pass・52 known、Verilator両seedとも136 pass・11 knownです。
[全Icarusの差とVerilatorの代表出力](hierloop-known-replays.json)を保存しました。Icarusが終わらない1件は60秒で打ち切って記録しています。
[全行の記録](hierloop-all-rows.json)は全869行の一度きりの実行で、固定suiteや要求カバレッジへ加算しません。kirimasimの差は0件です。
Icarusが受理しない行を補うため、3モデルの全行はVerilatorでも一度実行しました。
[設計と再実行](../../docs/interaction-verification.md#hierarchical-process-control)を参照してください。

<a id="delay-package-escape-qualification"></a>

## 遅延の値の書き方・packageの名前の探索・エスケープした識別子の独立確認

[`delayval.json`](delayval.json)は全222行、[`pkglookup.json`](pkglookup.json)は全148行、[`escname.json`](escname.json)は全126行を独立した解釈で照合します。
正常対照はどれも7件、誤ったSVもどれも7件で、誤りはすべて正常終了後の出力差で検出しました。
[ビルド記録](delaypkgesc-build.json)は`28c6c1a1cb83`の全4,296件（3,809 pass・479 unsupported・8 fail）を識別します。追加126件は全PASSです。
従来4,170件の入力と状態は不変で、failは前回と同じconfigの4件と`defparam`の4件です。107モデル・185章対・全選択ケースPASSは82モデルです。
[固定版比較](delaypkgesc-fixed-replays.json)はIcarus 126 pass、Verilatorはseed 1で112 pass・14 known、seed 73で109 pass・17 knownです。
Icarusの差はなく、Verilatorのknownは二値で読むxとzの遅延だけなので、[再実行の記録](delaypkgesc-known-replays.json)の代表出力は空です。
[全行の記録](delaypkgesc-all-rows.json)は全496行の一度きりの実行で、固定suiteや要求カバレッジへ加算しません。kirimasimとIcarusの差は0件です。
[設計と再実行](../../docs/interaction-verification.md#delay-value-form)を参照してください。

<a id="scope-case-literal-qualification"></a>

## moduleとgenerateブロックのクラス・case項目のリテラル・構造体リテラルの独立確認

[`scopeclass.json`](scopeclass.json)は全240行、[`casedigit.json`](casedigit.json)は全312行、[`agglit.json`](agglit.json)は全192行を独立した解釈で照合します。
正常対照はどれも7件、誤ったSVもどれも7件で、誤りはすべて正常終了後の出力差で検出しました。正常対照はkirimasimがPASSする行から選びました。
[ビルド記録](scopecaselit-build.json)は、最新のmainをビルドした`f029ddd0eee1`の全4,416件（3,915 pass・487 unsupported・14 fail）を識別します。追加120件のうち106件がPASSです。
新しいfail 6件はクラスの内部エラー、unsupported 8件は構造体のlocalparamです。従来4,296件の入力と状態は不変です。110モデル・189章対・全選択ケースPASSは83モデルです。
[固定版比較](scopecaselit-fixed-replays.json)はIcarus 29 pass・91 known、Verilatorはseed 1・73とも63 pass・57 knownです。
[再実行の記録](scopecaselit-known-replays.json)は、Icarusの91件すべてと、二値の入力でのVerilatorの差の代表を保存します。
[全行の記録](scopecaselit-all-rows.json)は全744行の一度きりの実行で、固定suiteや要求カバレッジへ加算しません。
kirimasimはcase項目の全行で一致し、クラスの30行が内部エラー、構造体のlocalparamの48行がunsupportedです。Verilatorはクラスの全240行で一致します。
[設計と再実行](../../docs/interaction-verification.md#scoped-class-declaration)を参照してください。
