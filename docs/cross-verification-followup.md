# クロス検証の不一致対応と次の優先順位

[English](cross-verification-followup.en.md) / [日本語](cross-verification-followup.md)

2026-11-04（日本時間）の更新です。2026-11-03の対応記録を保持し、固定回帰・正式Nightly・既存期待値・選択モデルを維持し、
既知の不一致の修正、未対応の整理、要精査の章対の確認の順に進めています。

[最新の正式確認](nightly-results.md#latest-verified-checkpoint)では、上流kirimasim `d73d8922dfa2`で全選択2,922件を実行し、
2,389 pass・529 unsupported・configの4 failでした。修正したinside・ラベル取消しは引き続きPASSです。
全選択ケースの入力・状態分類は保存済みcross79と一致しています。suite `e8d991a9`のCheck、Nightlyの5シミュレータ、公開処理はすべて成功しました。
以下の未コミットビルドは修正過程の記録であり、現在の上流の状態を示すものではありません。
kirimasim-testsのNightlyの1回の成功と、本体リポジトリの7連続Nightly条件は分けて扱います。

<a id="triage-of-the-eleven-failures"></a>
<a id="不一致11件の切り分け"></a>

## 当初の不一致11件の切り分け

- **inside比較の2件：修正を取り込み、PASSを確認。** kirimasimの既存ブランチの
  `b16163c7`にあった修正と機構別matrixを、2026-11-03の取り込み時点のmain作業ツリーへ反映しました。
  配列要素を自身の符号ではなく比較の共通型の符号で拡張する規則です。
  規則の実装箇所は`Lowerer::memberMatch`と`Lowerer::propagate`で、通常のinside、
  配列要素、case insideが同じ経路を使います。新しいアルゴリズムを別に作ったものではありません。
- **遅延アサーションの5件：承認後に修正し、PASSを確認。** 2026-11-03に仕様修正案が
  承認され、pass/fail両wrapperが同じ文IDを持ち、その未成熟報告だけを消す処理を実装しました。
  兄弟報告・評価済み副作用・成熟済み履歴は保持します。本体の
  `docs/notes/deferred-label-cancellation.ja.md`に実装と範囲を記載しています。
- **configの4件：固定版slang側へ切り分け。** front・SIR・VMを使わないパラメータ問合せでも、
  41件中同じ4件が不一致でした。分離した依存の診断用パッチでは41件すべて一致しました。
  本番の依存とkirimasimにはそのパッチを適用していません。本体の
  `docs/notes/config-reset-dependency-gap.ja.md`に記録しています。

[元の全選択実行](../coverage/interaction-results/cross75-kirimasim-f3ea0379.json)は
2,245 pass・529 unsupported・11 failです。
[inside修正後の全選択実行](../coverage/interaction-results/cross75-kirimasim-26a3e5a3-insidefix.json)は
**2,247 pass・529 unsupported・9 fail**でした。全2,785件の入力fingerprintは不変で、
状態の変化は上記2件のfail→passだけです。[11件の全出力再現](../coverage/interaction-qualification/cross-failures-20261103.json)も保持します。

当時記録したinside修正版はローカルmain `26a3e5a3`に未コミットの修正を加えたビルドです。
upstream mainの公開済み修正ではありません。[版・修正元・ソース・バイナリの記録](../coverage/interaction-qualification/insidefix-build.json)を併読してください。
機構別matrixはinitial/task/always/forkの4入力で各120出力行を比較し、関連12検査がPASSしました。
本体の全local CIもPASSしました。正式Nightlyと7連続Nightlyの証拠を更新したものではありません。

その後、承認済みラベル取消しをupstream main `7654825d`＋ローカル変更へ実装し、
未改変のslang pinも更新済みの`d02b7cda`で確認しました。
[全選択の実行](../coverage/interaction-results/cross75-kirimasim-7654825d-labelcancel-final.json)は
**2,252 pass・529 unsupported・4 fail**です。inside修正時点から変わったのは
ラベル取消し5件のfail→passだけで、入力はすべて同じです。遅延報告31件は全PASSです。
[ビルド記録](../coverage/interaction-qualification/labelcancel-build.json)と
[元の5件の全出力再実行](../coverage/interaction-qualification/labelcancel-replays.json)で、
実際の実装とバイナリを識別しています。本体の新規suite20入力と絞った37検査がPASSです。
本体の全local CIは21項目すべてPASSです（dev・ASan・UBSanは各11,827件、releaseは11,828件）。正式Nightlyとは区別します。

## 未対応529件の機構別整理

[指紋付きの全529件と19機構の一覧](../coverage/interaction-qualification/unsupported-triage-20261103.json)を保存しました。
同一snapshotの分類であり、新しいskip一覧やPASSの集計ではありません。主な系統は次のとおりです。

- 並行アサーション99件・checker27件。
- randomize52件・covergroup33件。
- DPIのrunner実行前判定67件。実行して得た未対応診断とは区別します。
- イベント値45件・mailbox36件。
- 集合の配列要素26件・許容差範囲16件・集合要素の副作用8件。
- clockingのゼロskew18件・ガード12件・virtual interface19件。
- 型付き連想配列18件。
- クラス配列プロパティ11件・プロパティ参照6件・ref実引数18件。
- 状態依存specifyパス12件・SDF注釈6件。

最初に詳細契約を確認する実装候補はSDF注釈です。固定Icarus oracleが登録済みの3件を含み、
[今回のIcarus 13.0再実行](../coverage/interaction-results/cross-followup-sdf-icarus13.json)も3件一致でした。
残るincrementの3件はknownのままで、oracleや期待値は変更していません。
現行の本体specify契約はSDFを未対応と明記しているため、先に規格上の範囲と仕様修正案を確定します。
件数の多さや別シミュレータの多数決だけで実装順・正しさ・P1完了を決めません。

## 要精査の章対と追加テストの方針

当初の見直しでは要精査Rを2章対だけ確認し、その時点で590章対を未評価のまま残しました。

- **第13×16章：レビュー時はE、現在はM。** 既存の遅延アクション引数テストが、登録時の値渡しとNBA後の
  参照値を同じ入力・期待値で観測しています。元のソースと期待値を確認し、
  [最新ローカルビルドでも再実行](../coverage/interaction-results/cross-followup-subroutine-kirimasim-26a3e5a3-insidefix.json)しました。
  この単独再実行を有限モデルの章間登録や、ラベル取消し全体のPASSへは加算していません。
  続く[遅延報告引数モデル](interaction-verification.md#deferred-argument-capture)で、
  幅・符号・渡し方・仮引数幅・サブルーチン・報告キュー・更新方式を明示し、29件を追加しました。
  この追加時点の全2,814件の単一snapshotで追加29件がPASSし、第13×16章をMへ移しました。
- **第11×33章：C。** 設定式の幅・符号と生成形状を追加候補にしました。
  現行configモデルの名前解決・優先順位の確認を保ち、語境界、式の型・符号、
  演算・条件式を将来の独立因子として検討します。合法な式と正の寸法の確定、
  既知のconfigリセット不一致の修正を先に行います。

現在の仕分けはM114・E3・C2・N117・R584です。
[章対の根拠と指紋](chapter-cross-triage.md)を参照してください。
既存の回帰matrixを先に活用し、原因が確定した機構に境界・操作列・故障対照を追加します。
同じ目的の別runnerや、ランダム結果を固定要求カバレッジへ加算する仕組みは追加していません。

続く[列挙型とgenerateのモデル](interaction-verification.md#generated-enum-navigation)では、未精査だった第6章×第27章を確認してMへ登録しました。上流`7554bb47`の全2,850件の単一実行で追加36件がPASSし、configの4 failと529 unsupportedは不変です。その追加時点で要精査Rは589章対でした。この資料内の以前の件数は、それぞれ記録時点の値です。

続く[packageのNBAモデル](interaction-verification.md#package-nba-capture)では、未精査の第10章×第26章・第4章×第26章・第7章×第26章をMへ移しました。上流`7554bb47`の全2,886件の単一実行で追加36件がPASSし、既存configの不一致と未対応は不変です。配列の対応は24件で、全選択ケースPASSはモデル全体36件の合格を必要とします。その時点の要精査Rは586章対でした。

続く[package変更の観測モデル](interaction-verification.md#package-change-observers)で、未精査の第9章×第26章と第11章×第26章をMへ移しました。前者は全36件、後者はlogicのX/Zを扱う12件に対応します。既登録の第4章×第26章・第7章×第26章にも観測を追加しました。上流`a682e19e3238`の全2,922件の単一実行で追加36件がPASSし、従来2,886件の入力と状態分類は不変です。要精査Rは584章対で、残る章対すべてを検証済みとするものではありません。
