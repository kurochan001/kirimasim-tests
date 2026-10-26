# NightlyのDifferから見つかったテスト側の問題の修正

2026-10-26の[Nightly実行40333187203](https://github.com/kurochan001/kirimasim-tests/actions/runs/40333187203)は、スイート`5fb3c45d`・kirimasim `5563871fcd96`で174本をDifferとしました。そのうち、診断位置の不一致27本と、正常系のpacked unionテスト1本を規格と照合し、計28本を修正しました。2026-10-27のユーザー指示に基づく修正です。

修正の基点はスイート`9783d9fd`です。以下の集計前後の比較はこのスナップショットで行い、並行して進む別の要求照合作業の増分は含めていません。

Differは失敗したテストの本数です。出力差分、コンパイル失敗、違法設計の受理、診断・終了コードの不一致を含み、独立したバグの数ではありません。今回の調査は174本すべての正誤を確定するものではありません。

## 設計自体を直した4本

| テスト | 問題と修正 | 規格根拠 |
| --- | --- | --- |
| `ch7/test_packed_struct_union_dimensions_and_rand_member` | 通常の`union packed`のメンバーが6ビットと3ビットだった。両方を6ビットに揃えた。`matches`を表示引数として使っていた箇所も、`if`の条件で判定したビットを表示する形にした。期待出力の`packed 12 12 5a9 56a`と`tag 1 rand 1 3`は変わらない | 7.3.1、12.6.2、附属書Aの構文 |
| `ch20/test_illegal_bits_function_dynamic_return` | `function int[] f()`という構文が先に拒否され、意図した`$bits(f())`の違反まで到達しなかった。動的配列型をtypedefし、合法な関数宣言にした。診断対象は`$bits`の行に限定する | 20.6.2、関数の戻り型の構文 |
| `ch33/test_illegal_config_design_is_config` | 複数のconfigから対象を選ぶ情報がなく、トップ選択のエラーになった。`:top_module: cfgdc`を指定し、configをdesignのセルとして使う違反を検査する | 33.4.1.1 |
| `ch33/test_illegal_config_instance_inside_other_config` | 同様に`:top_module: cfgio`を指定。他のconfigが指定した階層内へinstanceルールを適用する違反を検査する | 33.4.2 |

packed unionのメンバー幅が異なる場合の拒否は、既存の`ch7/test_illegal_hard_packed_union_sizes`で引き続き検査します。これを再実行の対照にも含めました。

## 診断を検査する位置と内容

違法設計の診断は、規格違反を起こした使用箇所のほか、その宣言や展開された本体に付くことがあります。以下の24本は、関連する位置を明示して受け入れます。意図した違反を示す診断内容も検査し、構文未対応や無関係なエラーによる成功を防ぎます。

| 対象 | 本数 | 認める位置・内容 |
| --- | ---: | --- |
| final deferred assertion | 1 | アクション呼び出し、または呼ばれたタスク内のPostponed領域での書き込み |
| `$inferred_clock` | 1 | 既定実引数、クロック使用箇所、またはassertionのインスタンス。クロックが解決できない診断 |
| 再帰propertyの否定・strong演算子 | 7 | 違法な使用箇所、または展開先の再帰本体。再帰propertyへの禁止演算を指摘する診断 |
| property実引数の展開後の合法性 | 1 | インスタンス、または展開先。property式をsequenceとして使用できない診断 |
| sequenceのlocal output | 1 | 仮引数、系列本体、またはインスタンス。未代入を指摘する診断 |
| PLAのメモリ添字方向 | 1 | メモリ宣言、またはシステムタスク呼び出し。昇順の要件を示す診断 |
| ANSI／non-ANSIポートの再宣言 | 4 | 元のポート宣言、または再宣言。重複宣言の診断 |
| modport prototypeの個数・型 | 2 | prototype、または対応する関数宣言。引数の個数・型の不一致 |
| package importの競合 | 3 | 違法な宣言・import、または先に名前を取り込んだ参照箇所。import競合の診断 |
| UDPの`endtable`欠落 | 1 | 次の`endprimitive`、または直前の表の末尾。後者は`endtable`を要求する診断に限る |
| 関数内のfork-join／join_any | 2 | `fork`、または閉じる`join`／`join_any`。時間制御禁止の診断 |
| **合計** | **24** | |

残り3本の違法系は、前節の関数宣言1本とconfig選択2本です。メタデータ検査も、宣言済みのconfigを`:top_module:`として指定できるようにし、存在しない名前は引き続き拒否します。config選択の誤りを、意図した規格違反の診断として受け入れる変更はしていません。

位置と関連するエラー内容を結び付けるため、一部の正規表現では英語の概念語も検査します。特定ツールの診断全文には固定していませんが、別ツールの同義の診断を追加するときも、規格と照合して判断する必要があります。

## 誤ったoracle認定の訂正

再帰propertyなどの8本、local outputの1本、modport prototypeの2本には、本文コメントで未対応と説明されているIcarus 13.0が`:oracle:`に登録されていました。生の診断を確認すると、構文未対応やその派生エラーが位置だけの検査に一致したものでした。計11本から`iverilog@13.0`を取り消し、`spec`を維持しました。

したがって、当初「174本中83本はIcarusかVerilatorが成功」と数えた機械判定にも偽陽性が含まれます。この83本を、規格上の独立検証済み件数としては扱いません。

要求との対応26件と保留判断6件を再確認し、入力ハッシュ・診断の根拠・レビュー記録を更新しました。複合証拠の基準ハッシュ8件も理由付きで更新しています。要求の削除、合格条件やグループのメンバー構成の変更はありません。

再集計では分母12,319件、設計対応10,209件は変わらず、実行確認は5,639件から**5,634件（45.734232%）**になりました。取り消した認定や古い入力での成功を、現行テストの実行証拠に使わない結果です。

## mainへの統合後の集計

main `6094cbaf`への統合では、並行作業で追加された148本と要求照合を保持しました。対象テストとのファイル重複はありません。統合後は全7,292本、分母12,319件、設計対応10,434件です。mainの修正前の実行確認5,727件に対し、修正後は**5,722件（46.448575%）**となります。

要求の内容、対応するテストの集合、複合証拠のメンバー構成はmainから変えていません。更新した基準は診断・入力ハッシュ等に結び付く8件と更新理由です。下記4回の再実行の全116件は、統合後の入力・ランナーハッシュにも一致しています。

## 検証結果と残る差分

修正28本と既存のpacked union負例1本、計29本を再実行しました。

| 実行環境 | 結果 | 証跡 |
| --- | --- | --- |
| Icarus Verilog 13.0 | 9 pass、20 known、0 fail | [JSON](../coverage/results/nightly-suite-corrections-20261027-icarus13.json) |
| Verilator 5.052、seed 1 | 8 pass、21 known、0 fail | [JSON](../coverage/results/nightly-suite-corrections-20261027-verilator-seed1.json) |
| Verilator 5.052、seed 73 | 8 pass、21 known、0 fail | [JSON](../coverage/results/nightly-suite-corrections-20261027-verilator-seed73.json) |
| ローカルkirimasim `a2aa75737147` | 27 pass、1 unsupported、1 fail | [JSON](../coverage/results/nightly-suite-corrections-20261027-kirimasim.json) |

kirimasimの成功27本には、修正対象26本と既存の負例1本を含みます。正常系のpacked unionテストは、無関係なコンパイルエラーがなくなった後、tagged union自体が未対応として報告されます。合法な戻り型へ直した`$bits`負例はkirimasim・Icarus・Verilatorとも受理してしまい、意図した違反の未検出が残ります。成功に合わせてテストを弱めていません。

このローカルkirimasimはNightlyと異なるコミットです。174件から何件減るかは、同じ条件で次のNightlyを実行した結果で確認します。kirimasimによる違法設計の成功は固定版oracleとして認定しておらず、上の27 passをそのまま実行確認率へ加算しません。

その後、kirimasimのmain `f0799b3c04d4`をビルドし、合法な関数宣言を使う独立した最小例でも`$bits`の未検出を確認して、[Bug Issue #53](https://github.com/kurochan001/kirimasim/issues/53)を発行しました。同じNightly調査から規格と最小例で確認した別件は、[foreachのbreak #52](https://github.com/kurochan001/kirimasim/issues/52)、[条件演算子と論理含意の優先順位 #54](https://github.com/kurochan001/kirimasim/issues/54)、[空の名前付きポート接続 #55](https://github.com/kurochan001/kirimasim/issues/55)、[未サイズ指定X/Zリテラルの拡張 #56](https://github.com/kurochan001/kirimasim/issues/56)、[atorealの走査 #57](https://github.com/kurochan001/kirimasim/issues/57)に分けて記録しています。いずれも`bug`ラベル付きで、規格本文や他プロジェクトのコードの転載を含みません。

[診断fixture](../tools/fixtures/nightly_diagnostics_20261027.json)と[6件の回帰検査](../tools/test_nightly_diagnostics.py)には、確認した診断、固定版ツールの未対応エラー、および合成した無関係・未対応のエラーを含めています。`$bits`の正しい診断例だけは、ソルバーやシミュレータの実測ではない合成例として明記しました。

```sh
python3 -m unittest discover -s tools -p 'test_nightly_diagnostics.py'
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
```

既存205件の単体テストと追加6件の回帰検査が成功しました。README集計、生成テスト、カタログ、網羅深度、メタデータ、動作網羅率、要求照合の整合性検査も成功しています。基本40モデルと追加111ケースのフォーマル証跡は現行ソースに対応したままです（ソルバーは再実行していません）。
