# OpenCode への引き継ぎ

[English](HANDOFF.md) / [日本語](HANDOFF.ja.md)

## 目標と現在地

IEEE 1800-2023 の要求台帳12,332件すべてに、原典に照らして妥当なテストを対応づけます。現在の対応件数、未対応件数、全ツールの実行確認件数、公開ツールで再現できる件数は集計JSONで確認できます。[集計JSON](coverage/behavior-summary.json) · [集計の読み方](docs/behavior-coverage-summary.md)

## 作業の再開

リポジトリのルートを OpenCode で開き、このファイルを参照させます。`git status --short --branch` と `git log -1 --oneline` でブランチと作業ツリーを確認します。

```sh
python3 - <<'PY'
import json
from pathlib import Path

ledger = json.loads(Path('coverage/behaviors.json').read_text())
for row in ledger['requirements']:
    if not row['checks']:
        print(row['id'], row['acceptance'])
PY
```

対象要件の `source_spans` から規格本文の節とブロックを特定し、手元の IEEE 1800-2023 本文と `tests/chNN/` を確認します。テスト追加後は該当ランナーで再実行し、入力のフィンガープリント、照合条件、実測差分を記録してから台帳に対応を追加します。規格が複数の結果を許す場合は、必要な事前条件や対照の成立を確認して観測を残します。[要求台帳](coverage/behaviors.json) · [原典索引](coverage/requirement-source-index.json) · [対応づけの手順](docs/requirements-to-tests-method.md)

## 検証コマンド

```sh
python3 tools/lint_metadata.py tests/chNN/test_example.sv
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/suite_catalog.py --check
python3 tools/suite_stats.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/documentation_languages.py --check
python3 -m unittest discover -s tools -p 'test_*.py'
```

テスト追加時は、対応する生成コマンドを `--update` で実行します。手書きの日英文書を更新した場合は `python3 tools/documentation_languages.py --record` で記録を更新します。Ghostの再実行にはアクセス可能な実行ファイルと strict プロファイルが必要です。公開ツールだけで再現できる範囲は各記録に記載しています。[検証記録と再実行手順](coverage/README.md) · [CIの定義](.github/workflows/check.yml)

## 直近の結果と未対応候補

- §4.3の参照スケジューラは、通常系と競合する書き込みを持つ2条件の全てで、Icarus、Ghost、Verilator、kirimasimの実測が許容トレースに一致しました。[検証記録](coverage/qualification/scheduler-reference-20261125.json)
- §11.4.14.1の循環クラスのストリーミングでは、Ghostで通常系が値 `35` を返し、自己参照を確認した別実行はシグナル11で終了しました。循環時の結果は規格上未定義です。[検証記録](coverage/qualification/class-stream-cycle-20261125.json)
- §36.12.3では、Verilog-1995の区画にあるメモリを旧互換VPIアプリケーションで読み取るケースを追加しました。IcarusとGhostで値 `29` と `61` を確認しました。[検証記録](coverage/qualification/vpi-legacy-partition-memory-20261125.json)
- §25.9の仮想インターフェイスは、合法な待ちと4件の拒否を同時に確認するテスト群に対応づけました。Ghost strictでは `always_comb` が受理され、シミュレーションは値 `47` を出力しました。実行結果は不一致です。[検証記録](coverage/qualification/virtual-sensitivity-20261126.json)
- §34.5.10.2と§34.5.16.2の所有者別の鍵登録では、6件の重複を検出し、別の所有者に登録した鍵でモデルとダイジェストを復元しました。[検証記録](coverage/qualification/protect-owner-key-uniqueness-20261127.json)
- 第34章に残っていたviewportの3要件を登録しました。参照試験では、二つの順序とアクセス方針で復元モデルのオブジェクトをVPIから読み書きしました。Slangは別エンベロープ・平文領域・未定義の名前を指定した6ケースを受理しました。[検証記録](coverage/qualification/protect-viewport-20261127.json)
- §37.2.2の再起動テストでは、Ghostがチェックポイントを復元した後も、調べた8本のキーが内部表に残りました。以前の値変更とシミュレーション終了のコールバックは再起動後も発火しました。[検証記録](coverage/qualification/vpi-restart-release-20261127.json)
- 第30章に残っていたパルス制御の6要件を登録しました。参照ランナーが起動設定をspecifyとSDFに反映し、Ghostで遷移波形を測定しました。[検証記録](coverage/qualification/global-pulse-options-20261127.json)
- 第4章に残っていた12要件を、公開VPIとアサーションの出力、および概念上の制御点を扱う参照試験に対応づけました。Ghostの内部スケジューラを単独で動かすと、保留中のReactive処理より先にActive処理が実行されました。[検証記録](coverage/qualification/pli-region-controls-20261127.json)
- 第31章に残っていた4要件を登録しました。Ghostで明示的に展開した幅検査3件とセットアップ検査6件が通知変数を共有することを確認しました。負の検査を等価な形に置き換えた結果は一致し、元の負値の検査では差分を記録しました。[検証記録](coverage/qualification/timing-options-20261127.json)
- 第17章に残っていた4要件を登録しました。Yosysが定数値を保持する2ステップの解を21通り列挙し、Ghostで全件の再生に成功しました。元のソースを6シードで実行すると、定数は毎回ゼロのままで、各ステップで同じ仮定が失敗しました。[検証記録](coverage/qualification/checker-free-choices-20261127.json)
- 附属書Kの全要件を登録しました。CとC++の検査で、VPIオブジェクト型の既存の別名を保持しつつ、予約範囲の両端に追加した型番号を検出しました。[検証記録](coverage/qualification/vpi-base-object-codes-20261127.json)
- §37.14の入力ポートの測定では、Ghostは設定した遅延値を読み返せました。有効な添字でポートビットを取得できず、信号は即時に伝わりました。参照実行では宣言された添字範囲と遅延後のエッジを照合しました。[検証記録](coverage/qualification/vpi-input-port-delays-20261127.json)
- 附属書Hの全要件にテストが対応しました。旧DPIヘッダーの2マクロをCとC++で確認しました。ヘッダーに依存しない版は二つの参照実行環境とGhostで同じ共有ライブラリを再利用できました。ヘッダーを使う版は、参照実行環境間でライブラリを交換すると配置の不一致を検出しました。[検証記録](coverage/qualification/dpi-legacy-source-layout-20261127.json)
- 第40章の全要件にテストが対応しました。参照ランナーで論理名に異なる保存先を割り当て、GhostとVerilatorのCLIで相補的な記録をマージすると、いずれも各カバープロパティが3ヒットになりました。Ghostの標準システム関数は保存対象もマージ対象も見つからない状態を返しました。[検証記録](coverage/qualification/coverage-database-storage-20261127.json)
- 第19章の全要件にテストが対応しました。Verilatorは実装上限を5、9、13、20に変えると、同じ4ビットのカバーポイントに5、9、13、13の自動ビンを生成しました。2ビットの対照は常に4ビンで、全入力値を走査すると両方が100%になりました。[検証記録](coverage/qualification/automatic-bin-limit-20261127.json)
- §7.3.1では、Verilatorが生成した非パック共用体とC宣言のメンバー配置が一致し、両方向の値の転送が成立しました。生成された片側の構造体で2フィールドを入れ替えると、転送前に配置の違いを検出しました。[検証記録](coverage/qualification/unpacked-union-c-layout-20261127.json)
- 第36章の全要件にテストが対応しました。テスト用アダプターで一つの既定モードを選ぶと、モード未指定の2ライブラリはGhostの現行版または1995年版のVPI結果を共有し、コンパイル時に固定した2ライブラリはそれぞれの結果を保ちました。Ghostの通常実行では、未指定の両ライブラリから現行版の結果を観測しました。[検証記録](coverage/qualification/vpi-host-default-modes-20261127.json)
- 第33章の全要件にテストが対応しました。参照リンカーはSystemVerilogの一時コピーを削除した後、4セルのYosysコンパイル済みオブジェクトとコンパイル済みの構成を読み込んで結合しました。Slangはソースから同じ階層を選び、GhostはYosysが証明した値を出力しました。Verilator 5.054は2インスタンスとも同じ末端セルを選びました。 [検証記録](coverage/qualification/config-precompiled-cells-20261127.json)
- §38.15では、ビットプレーンと4状態の個数を参照実装の別々の形式識別子に割り当てました。GhostとIcarusで40ビットと10ビットの元のベクター値が一致し、参照実装側のビットプレーン識別子だけを変更すると、その出力だけが得られなくなりました。 [検証記録](coverage/qualification/vpi-misc-format-extensions-20261127.json)
- 保護オブジェクトのVPIテストでは、同じ設計で二つの暗号化範囲を反対側に移すと、参照アダプターが拒否する属性取得と階層探索も反対側に移りました。型、保護フラグ、引数列挙、式の幅は引き続き取得できました。復元後の実行にはGhostのVPIオブジェクトを使いました。 [検証記録](coverage/qualification/vpi-protected-access-20261127.json)
- 保護された文のコールバック試験では、二つの名前付きブロックで保護範囲を入れ替えました。参照アダプターは個別登録を拒否し、一括登録から保護されたブロック・遅延・代入を外しました。どちらの配置でもGhostは両側の文を実行しました。 [検証記録](coverage/qualification/vpi-protected-callbacks-20261127.json)
- 第8章の全要件にテストが対応しました。参照アダプターでVerilatorが生成したオブジェクトと弱参照ラッパーの破棄を観測しました。最後の強参照を外すと二つの弱参照が同時にクリアされ、IDを再利用してもSystemVerilogの連想配列には数値キーが残りました。 [検証記録](coverage/qualification/weak-reference-collection-20261127.json)
- 第38章の全要件にテストが対応しました。参照アダプターでVerilatorの実際の破棄を観測し、型と個体の登録条件でコールバックを振り分け、復帰後に対象のハンドルを削除しました。Ghostの対照試験では、タスクの終了後も静的ローカル変数とそのコールバックが有効でした。 [検証記録](coverage/qualification/vpi-class-reclaim-20261127.json)
- 第37章のライフタイム試験では、クラス回収試験と並行する二つの自動タスク試験を組み合わせました。参照アダプターではコールバック中に実際のローカル変数を読み、呼び出し元スレッドがまだ生存している間にフレーム側のハンドルを解放しました。Ghostではタスク本体より先に開始通知が届き、本体に入ってからローカル変数を取得できました。 [検証記録](coverage/qualification/vpi-automatic-frame-lifetime-20261127.json)
- その他の一時オブジェクトはGhostで一括確認しました。配列の古い参照とブロック内の参照、スレッド終了、イテレータの最終走査、予約イベントの実行と解放、二つのタイマーのうち片方の取り消しを観測しました。 [検証記録](coverage/qualification/vpi-other-transient-20261127.json)
- §37.83ではプリミティブ端子、パス端子、モジュールパス、タイミングチェック、ユーザー定義プリミティブの表エントリの属性を両方向にたどりました。Ghostが生成したオブジェクトに補助コードで属性を設定し、列挙先と逆参照先を変えた対照試験では両方の誤りを検出しました。 [検証記録](coverage/qualification/vpi-extended-attributes-20261127.json)
- インターフェース所有関係の試験では、Ghostが生成したプログラム、インターフェース、パスの間を公開VPIで両方向にたどりました。内部の親階層を使った対照では、Ghostの旧モジュール参照がインターフェースのパスから外側のモジュールを返しました。 [検証記録](coverage/qualification/vpi-interface-ownership-20261127.json)
- 純粋制約と構造体パターンの試験では、Slangの解析結果をGhostのVPIオブジェクトに渡し、公開APIでフラグと名前を取得しました。通常のGhost実行では純粋制約のフラグが偽で、名前付きの内側パターンから名前を取得できませんでした。 [検証記録](coverage/qualification/vpi-pattern-constraint-20261127.json)
- 図記号の検査では台帳に登録したIEEE PDFの囲み線と書体を分類しました。Ghostの試験では4種類のインスタンスで共通のVPI属性と関係を確認しました。 [検証記録](coverage/qualification/vpi-diagram-key-20261127.json)
- §37.41では、タスクと関数のVPIビューから得た参照オブジェクトの同一性を確認しました。二つの親を入れ替えた対照では両方の同一性判定が変わり、通常の宣言の親はモジュールのままでした。 [検証記録](coverage/qualification/vpi-task-reference-parent-20261127.json)
- §7.8.5では、可変長のキーと実数を含むキーに対するSlangの拒否を確認しました。Ghostはイベントの同一性を正しく比較しましたが、別々のイベントを一つの項目に割り当てました。通常テストは2項目を期待します。 [検証記録](coverage/qualification/associative-key-equality-20261127.json)
- §9.7では、initialとalwaysおよびそのforkの子孫として生成された5つのプロセスを実際に制御しました。参照試験ではfinal由来のハンドルへの4操作を拒否しました。対照ではGhostの内部APIが4操作を受け付けました。 [検証記録](coverage/qualification/process-control-target-origins-20261127.json)
- 第2章の試験では、台帳のIEEE PDFと発行元の記録から、版指定ありと版指定なしの参照を解決しました。同じ配列を二つのVPIの版で読むと、オブジェクト型が異なりました。過去の発行時点を使い、発行済みの追補1件と正誤票2件の適用を確認しました。 [検証記録](coverage/qualification/normative-reference-editions-20261127.json)
- 台帳の全12,332要件にレビュー済みのテストが対応しました。保存済みの実行証跡で確認した要件は11,204件です。 [条項別の対応状況](docs/behavior-coverage.md)
