# 機能間クロス検証の補助証跡

このディレクトリは、固定版の確認元選別、独立検算、最小例、故障注入、ビルド版の確認記録を
保存します。現在の入力に対応する回帰実行は[`interaction-results/`](../interaction-results/)、
充足状況は[クロス検証レポート](../../docs/interaction-coverage.md)を参照してください。
補助証跡の正常・故障条件の件数を、スイートの合格数や要求カバレッジへ加算しません。
入力ハッシュが古くなった記録は履歴として残し、新しいハッシュへ書き換えず再確認を別途記録します。
「最新」のビルドは各記録の確認時点での意味です。コミットと日時を確認してください。

## 固定リリースの確認元選別

`20261029-query/`はIcarus Verilog 13.0での予備確認と再実行のJSONです。
初回は追加3モデルの132件、続く5回はビットベクタ関数モデルの60件を実行しました。
この60件の一致数は順に54、52、55、56、53、54件で、全6回で一致したのは51件です。
幅64超の連結・複製式で、引数幅が32の倍数でない9件は結果に変動がありました。

この9件にIcarusのoracleは登録しません。Verilatorの両seedで一致した2値ケースは
Verilatorを確認元とし、残りは規格に基づく期待値を保持します。
モデルの分母から除外したり、期待値を緩めたりするための記録ではありません。

その後、[CheckのUbuntu 24.04環境](https://github.com/kurochan001/kirimasim-tests/actions/runs/40893253924)で、
手元の6回では一致していた12件にも`$countones`の差が出ました。
[失敗行の抜粋](20261029-query-linux-check.log)は当時のコミットとジョブURLを付けて保存しています。
追加12件の引数幅は2・33・34ビットです。前の9件と合わせ、連結・複製後の引数幅が
32の倍数でない21件にはIcarus oracleを登録しません。残る39件をIcarusの確認済みとします。
追加12件は4値ケースとして分類し、Verilatorの確認対象から外しています。
Verilator確認済みへの付け替えは行わず、規格のみとします。

JSONはoracleメタデータと差異コメントを追記する前の入力ハッシュをそのまま保存しています。
現行の実行カバレッジには使いません。現行ソースに対応する結果は
[`interaction-results/`](../interaction-results/)へ別途、再実行して保存します。
当時のJSONのハッシュを現行値へ書き換えてはいけません。

## 複合シフト代入の確認

[`20261030-compound-shift.json`](20261030-compound-shift.json)には、実行開始時に確認した
kirimasimの上流コミットとビルド前後のバイナリ指紋、独立した期待値の照合方法、
左辺添字を2回評価する故障注入、Verilatorの部分選択2件の両seedでの詳細出力を保存しています。
故障注入のソースは回帰テストへ採用せず、検出の確認用です。
このファイルを現行の合格数へ加算しません。入力が変わったら検査を再実行してください。

## 集合所属判定の確認

[`20261030-inside.json`](20261030-inside.json)は、実行直前に確認したkirimasimのビルド版・バイナリ指紋、
配列/個別列挙/直接比較を照合する2/3ビットの最小例、bit/logicと符号の対照条件、
個別列挙で先頭要素だけを読む故障注入の証跡です。
実装の不一致と検査器の故障検出を分けて保存し、通常の実行カバレッジへ加算しません。
現行の回帰結果は`interaction-results/cross27-*.json`です。

[`20261030-inside-fc4cc356.json`](20261030-inside-fc4cc356.json)は同日の再確認です。
実行直前に確認した上流main `fc4cc356`のビルド版・バイナリ指紋、上の2つの最小例の再実行、
左辺の値と要素数を変えた追加の最小例、定数として評価した同じ比較、
手書きテスト[`test_inside_array_set_mixed_sign_width`](../../tests/ch11/test_inside_array_set_mixed_sign_width.sv)の
kirimasimの出力と、Verilator 5.052のseed 1・73での出力を保存しています。
追加の最小例では、左辺`111`と`011`で配列形式の結果が逆向きにずれ、配列の符号付き要素を
符号拡張して比較していることがわかります。定数として評価した比較は期待値どおりです。

## 範囲指定の確認

[`20261030-range.json`](20261030-range.json)は`membership_range@1`の確認記録です。
実行直前に確認した上流main `f303beca`のビルド版・バイナリ指紋、独立した期待値の照合方法、
`$`を端点にした範囲の小さな例と、そのkirimasimとVerilator 5.052のseed 1・73での出力を保存しています。
kirimasimは期待値どおりで、Verilatorは両seedで同じ結果が期待値と異なります。
参照モデルの規則を一つずつ誤りに置き換えた7種類の故障注入について、出力が変わるケース数も記録しています。
故障注入は検出力の確認用で、通常のスイートや実行カバレッジへ加算しません。
現行の回帰結果は`interaction-results/cross28-*.json`です。

## case insideの確認

[`20261030-case-inside.json`](20261030-case-inside.json)は`case_inside_selection@1`の確認記録です。
実行直前に確認した上流main `f303beca`のビルド版・バイナリ指紋、独立した期待値の照合方法、
符号付き配列の項目と同じ値の項目を比べる2/3ビットの最小例と、そのkirimasimの出力、
不一致になった生成テストのkirimasimの出力、Verilator 5.052で最小例がビルドできなかったことを保存しています。
参照モデルの規則を一つずつ誤りに置き換えた7種類の故障注入について、観測が変わるケース数も記録しています。
故障注入は検出力の確認用で、通常のスイートや実行カバレッジへ加算しません。
現行の回帰結果は`interaction-results/cross29-*.json`です。

## イベントORとiffの確認

[`20261031-event-iff.json`](20261031-event-iff.json)は`event_or_iff@1`の確認記録です。
上流mainと版を照合したkirimasim `17b7192b4f05`で、選択済みの4行がすべて一致し、
条件の取り違え・両項への誤った条件付け・右項の欠落・条件での誤起床・既知の1とXの混在の拒否・
名前付きイベントの再発火の欠落・NBAの即時化、の7種類をすべて出力の相違として検出しました。
元の生成器、確認ツール、作ったSVと期待値の指紋、各変更箇所と判定を保存しています。
通常のスイートの件数や実行カバレッジには故障注入を加算しません。

再確認は、実行直前に最新上流を取得・ビルドして版の一致を確認した後、次の形で実行します。
過去の証跡を上書きせず、新しいファイル名を指定してください。

```sh
python3 tools/qualify_event_iff.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --json coverage/interaction-qualification/NEW-event-iff.json
```

通常の保存実行は`interaction-results/cross30-kirimasim-17b7192b.json`と
`interaction-results/event-or-iff-20261031-*.json`です。

## キュー要素の参照の確認

[`20261031-queue-ref.json`](20261031-queue-ref.json)は`queue_element_reference@1`の確認記録です。
上流mainとビルド版を照合したkirimasim `29ad73153518`で、選択済みの正の対照条件4件が一致し、
要素の取り違え・値渡し化・メソッドの全体代入化・書込みの欠落・全体代入後の参照の誤保持・
削除済み参照から現在のキューへの書込み・容量制限の欠落・logic入力のbit化の8種類を検出しました。
構文エラー、未対応、異常終了は故障検出として数えません。
ビルド版とバイナリ、生成器、確認ツール、SVと期待値の指紋、変更箇所と判定を保存しています。
故障注入は通常の実行カバレッジへ加算しません。

最新上流を取得・ビルドして版を照合した後、新しい保存先を指定して再実行できます。

```sh
python3 tools/qualify_queue_ref.py --kirimasim BIN --commit VERIFIED_COMMIT \
  --json coverage/interaction-qualification/NEW-queue-ref.json
```

通常の保存実行は`interaction-results/cross31-kirimasim-29ad7315.json`と
`interaction-results/queue-ref-20261031-*.json`です。
[`20261031-queue-ref-verilator.json`](20261031-queue-ref-verilator.json)は、通常のランナーが
出力なしと記録した上限付き連結代入の1件について、固定版を同じオプションで再実行した記録です。
ビルドは成功し、両seedともSIGBUSで終了しました。ソースコードは調べていません。
