# クロス検証の不一致対応と次の優先順位

[English](cross-verification-followup.en.md) / [日本語](cross-verification-followup.md)

2026-11-05（日本時間）の更新です。2026-11-03の対応記録を保持し、固定回帰・正式Nightly・既存期待値・選択モデルを維持し、
既知の不一致の修正、未対応の整理、要精査の章対の確認の順に進めています。

現在の[全クロスのローカル選択](../coverage/interaction-results/cross85-kirimasim-92001039-genexpr.json)は85モデル・3,136件で、
2,603 pass・529 unsupported・configの4 failです。定数式とgenerateの追加36件は全PASSで、従来3,100件の入力・状態分類は不変です。
今回の36件は正式Check・Nightlyでは未実行です。

[基点8df0dde9のCheck](https://github.com/kurochan001/kirimasim-tests/actions/runs/42029700354)は成功し、前回までの84モデルの固定版比較・静的検査を確認済みです。
[確認済み正式Nightly](nightly-results.md#latest-verified-checkpoint)は19cd790aの82モデルが対象で、今回の36件はCheck・Nightlyの両方で未実行です。
以下の未コミットビルドは修正過程の記録であり、現在の上流の状態を示すものではありません。
kirimasim-testsのNightlyの1回の成功と、本体リポジトリの7連続Nightly条件は分けて扱います。

2026-11-04の固定suiteの確認時点で、第30章の通常のspecify条件テスト5件がunsupportedからPASSへ改善しました。
この5件は有限クロスの選択外です。選択内の状態依存specifyパス12件・SDF注釈6件の未対応は変わっていません。
[今回の確認記録](../coverage/interaction-qualification/formal-ci-9926160a-20261104.json)に5件の識別と固定入力の不変を記載しています。

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

現在の仕分けはM126・E3・C2・N117・R572です。
[章対の根拠と指紋](chapter-cross-triage.md)を参照してください。
既存の回帰matrixを先に活用し、原因が確定した機構に境界・操作列・故障対照を追加します。
同じ目的の別runnerや、ランダム結果を固定要求カバレッジへ加算する仕組みは追加していません。

続く[列挙型とgenerateのモデル](interaction-verification.md#generated-enum-navigation)では、未精査だった第6章×第27章を確認してMへ登録しました。上流`7554bb47`の全2,850件の単一実行で追加36件がPASSし、configの4 failと529 unsupportedは不変です。その追加時点で要精査Rは589章対でした。この資料内の以前の件数は、それぞれ記録時点の値です。

続く[packageのNBAモデル](interaction-verification.md#package-nba-capture)では、未精査の第10章×第26章・第4章×第26章・第7章×第26章をMへ移しました。上流`7554bb47`の全2,886件の単一実行で追加36件がPASSし、既存configの不一致と未対応は不変です。配列の対応は24件で、全選択ケースPASSはモデル全体36件の合格を必要とします。その時点の要精査Rは586章対でした。

続く[package変更の観測モデル](interaction-verification.md#package-change-observers)で、未精査の第9章×第26章と第11章×第26章をMへ移しました。前者は全36件、後者はlogicのX/Zを扱う12件に対応します。既登録の第4章×第26章・第7章×第26章にも観測を追加しました。上流`a682e19e3238`の全2,922件の単一実行で追加36件がPASSし、従来2,886件の入力と状態分類は不変です。この追加時点で要精査Rは584章対で、残る章対すべてを検証済みとするものではありません。

2026-11-04の[クラスメソッド×packageのモデル](interaction-verification.md#class-method-package-lookup)で、未精査だった第8章×第26章をMへ移しました。
上流`9113955914d8`の全2,956件の単一実行で追加34件がPASSし、従来2,922件の入力・状態分類は不変です。
この追加時点では80モデル・115章対、全選択ケースPASSは53モデルで、2,423 pass・529 unsupported・configの4 failです。
この時点の要精査Rは583章対です。このローカル結果は正式Check・Nightlyと区別し、クラス×package全体の網羅を示すものではありません。

2026-11-05の[生成サブルーチンモデル](interaction-verification.md#generated-subroutine-binding)で、第13章×第27章・第7章×第27章をRからMへ移し、既存の第7章×第13章も補強しました。
上流`162222153c57`の全2,992件の単一実行で追加36件は全PASS、従来2,956件の入力ハッシュ・状態分類は不変です。
81モデル・117章対・全選択ケースPASS 54モデルで、要精査Rは581章対です。固定Icarusは全36件が一致し、
固定Verilatorのseed 1/73は各11 pass・25 knownです。符号付きtaskのcopy-outの差異とfunction対照を保持し、
この比較によって期待値・回帰ゲート・ランダムプロファイル・要求の対応付けは変更しません。

続く2026-11-05の[クラスの条件選択モデル](interaction-verification.md#class-conditional-return)で、第8章×第11章・第8章×第12章をRからMへ移しました。
上流`162222153c57`の全3,028件の単一実行で追加36件は全PASS、従来2,992件の入力・状態分類は不変です。
82モデル・119章対・全選択ケースPASSは55モデル、2,495 pass・529 unsupported・既存configの4 failです。
要精査Rは579章対です。合法1,296プログラムの独立解釈が一致し、正常対照5件・SVへの9故障で観測を検算しました。
固定Verilatorのseed 1/73は各12 pass・24 known、固定Icarusは全36件のクラスハンドル比較を拒否します。
X/Zの期待値と[knownの全出力再実行](../coverage/interaction-qualification/classsel-known-replays.json)を保持し、nativeのPASSや4値oracleとは分けます。

生成ループの追加で第12章×第27章・第9章×第27章を精査し、第7章×第27章も補強しました。合法6,912行から因子対293組・重点3因子160組・必須6件を保持する36件を選びました。
最新ビルド`50a897dee62a`の全3,064件の単一実行で追加36件は全PASS、従来3,028件の入力ハッシュ・分類は不変です。
83モデル・121章対・全選択ケースPASS 56モデル、仕分けはM121 / E3 / C2 / N117 / R577です。
Icarusは31入力に一致し、repeat回数1の5件は拒否を保持して、独立に解釈した回数3対照と分けています。
全6,912ソースの独立解釈が一致し、正常対照5件・実際のSVへの9故障で観測を検算しました。
基点19cd790aの正式Check・Nightlyとランダム96 PASSも確認しましたが、新しい有限ケースはローカル証跡です。
[設計と全記録](interaction-verification.md#generated-process-loop-transfer)を参照してください。

## interface配列問い合わせによる走査（2026-11-05）

[第7×25・20×25・13×20章のモデル](interaction-verification.md#interface-array-query-walk)を追加しました。
合法4,608通りから36件を選び、全行の独立検算と、正常対照5件・実行可能な9故障を確認しました。
最新取得・ビルドの`50a897dee62a`で全3,100件を一度に実行し、追加36件はparse成功・全PASS、従来3,064件の入力・分類は不変です。
固定IcarusはX/Zを含む全36件に一致し、固定Verilatorの既知値12件は両seedで一致しました。2値の偶然の一致を4値の確認やoracle登録に使いません。
要求対応付け・ランダム13プロファイル・既存回帰・本体コードは不変です。
