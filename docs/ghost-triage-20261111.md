<a id="ghost-triage-2026-11-11"></a>

# Ghost 2026-11-11 実行の仕分け

[English](ghost-triage-20261111.en.md) / [日本語](ghost-triage-20261111.md)

`kirimasim-tests` `36ba5dd1` に対する Ghost の全件実行1回の仕分けである。公開できる件数とテスト側の対応を記録する。非公開のプロファイル、実行ファイルの版、パス、生の診断は転載せず、ビルドの識別には実行ファイルのハッシュだけを使う。

<a id="scope"></a>

## 対象

- スイート: `36ba5dd1`、非 formal のシミュレーションテスト 11,897 本。
- Ghost: 非公開ビルド、実行ファイル sha256 `6154f1bce2d75faddde2022961a140d1d2228462b73a5893e6fac315118a0d44`。
- ランナー: `tools/run_ghost.py` と保存済みの非公開プロファイル。DPI/VPI の C ソースは共有ライブラリにビルドして読み込む。
- 実行: 全件を `-j 24`、そのあと失敗した全ファイルを `-j 8` で再実行。

<a id="result"></a>

## 結果

最初の実行は 350 本の失敗を報告した。`-j 8` の再実行で残ったのは 345 本で、内訳は違法設計の受理が 221 本、それ以外が 124 本である。厳格な LRM 検査を有効にした別の実行は 210 本の失敗を報告し、`-j 8` の再実行で 124 本の決定的な失敗が残った。うち 119 本は同じテストである。消えた 86 本は負荷依存の flaky として扱い、結果に数えない。

124 本の分類は次のとおり。

| 分類 | 本数 | 起票先 |
| --- | ---: | --- |
| 既定プロファイルが違法設計を受理。厳格な LRM 検査では拒否される | 221 | テスト側 [#70](https://github.com/kurochan001/kirimasim-tests/issues/70) |
| 拒否はされるが診断の位置または文言が違う | 15 | テスト側 [#71](https://github.com/kurochan001/kirimasim-tests/issues/71) |
| 合法設計の fixture が 6.21 に違反（static 初期化子） | 1 | テスト側 [#72](https://github.com/kurochan001/kirimasim-tests/issues/72) |
| VPI 以外の製品側の不具合 | 63 | 非公開の製品トラッカーに 20 件 |
| VPI オブジェクトモデル・UDP put・2つの残件 | 30 | 非公開のオブジェクトモデル/UDP Issue、公開 #65、閉じた制約の残件 |
| covergroup の tolerance bin | 1 | 非公開トラッカーの既存 coverage Issue |
| 既存のテスト側 Issue #58〜#69 で追跡済み | 14 | 新規起票なし |

診断の比較と製品の挙動が同じテストで同時に失敗するため、複数の行に現れるテストがある。各行の合計は分割を意味しない。

<a id="test-side"></a>

## テスト側の Issue

公開 Issue を3件起票した。

- [#70](https://github.com/kurochan001/kirimasim-tests/issues/70): 適合性実行に使うプロファイルが厳格な LRM 検査を有効にしていない。同じバイナリで厳格な検査を有効にすると、受理された 221 本の違法設計はすべて期待どおりの診断で拒否される。プロファイルへの追加を提案している。
- [#71](https://github.com/kurochan001/kirimasim-tests/issues/71): 違法設計 15 本は拒否されるが、診断が場所を示さないか、文言が異なる。#27 の判断の残件である。設計は違法で、比較だけが失敗している。
- [#72](https://github.com/kurochan001/kirimasim-tests/issues/72): `ch10` の assignment pattern の fixture が、初期化子付きのブロック変数を `static` も `automatic` も付けずに宣言しており、6.21 に反する。閉じた #46 と同じ fixture の誤りが別のテストに残っている。

124 本のうち 14 本は、既存のテスト側 Issue #58〜#69 がすでに説明している。deferred assertion と multiclock の fixture、空マッチ、DPI open array、ch23 の明示ポートの `%h`、ch31 の fullskew、ch19 の transition bin である。

<a id="product-side"></a>

## 製品側の Issue

非公開の製品トラッカーに 20 件起票した。まとめは次のとおり。

| 領域 | 本数 | 主な所見 |
| --- | ---: | --- |
| ポート折り畳みと net delay | 12 | 両方の net delay が残り（3+7 が 10 になる）、wire/tri ポートが `x` のまま、終了しない実行もある |
| 制約ソルバと分布 | 11 | 充足可能な制約で解なし、soft 優先度、`solve...before`、randc、オブジェクトの seeding が誤り |
| covergroup の option と bin | 5 | `option.x` がインスタンス単位でない、real の区間分割が誤り、block event がサンプリングしない |
| ユーティリティ関数 | 3 | 空の連想配列の `$bits`、unpacked 集約への縮約関数、`$bitstoshortreal` |
| assertion VPI と coverage VPI | 4 | カウンタが 0 のまま、一致しない cover property が failure を報告、`vpiCoveredMax` が -1 |
| アサーション | 3 | アサーション内の `dist` が無評価、ブール式のエッジがオペランドのエッジでも発火 |
| force・release・streaming | 3 | part-select force が未 force ビットを固定、release が連続代入を再評価しない、class handle への streaming が暗黙状態を書く |
| FST とファイル入出力 | 3 | FST の先頭ブロックが破損、語数警告がない、`wait_order` が file:line を出さない |
| コンパイル単位・config・リテラル | 4 | include されたコンパイル単位変数が 0 で初期化、config の `use` 節が拒否、fill リテラルが 32bit のまま |
| DPI・interconnect・interface | 4 | `svGetPartselBit` が幅より上のビットを残す、継承 interconnect ポートがループを報告、2つの interface インスタンスが関数結果を共有 |
| elaboration を通過する違法設計 | 2 | vif の連続代入と、出力 open-array DPI 仮引数への動的配列が実行時まで失敗しない |

非公開トラッカーには、VPI オブジェクトモデルの既存 Issue に今回追加で失敗した fixture を、制約ソルバの Issue に生成された積制約の fixture を、それぞれコメントで追記した。

<a id="flakiness"></a>

## Flaky

`-j 24` で失敗し、同じ 124 本の失敗ファイルを `-j 8` で再実行すると通ったテストが 86 本ある。失敗として数えず、Issue も起票していない。負荷依存の出力欠落か終了遅延の形で、再現する差分ではない。並列度を下げた Nightly で再発するかを確認する必要がある。

<a id="reproduction"></a>

## 再現

公開部分は、このリポジトリのランナーと、外に置いた非公開プロファイルで再現できる。

```sh
cd kirimasim-tests
python3 tools/run_ghost.py --simulator /path/to/private/simulator \
  --profile /path/to/private-profile.json --include /path/to/include \
  -j 8 --json out/ghost.json
```

受理された 221 本の違法設計は、非公開プロファイルで厳格な LRM 検査を有効にした場合としない場合の `:should_fail_because:` テストの判定を比べると再現できる。

<a id="notes"></a>

## 注記

- 実行中に非公開側の main が進んだ。再実行の前に実行ファイルのコピーを固定し、上の件数は対象に書いたハッシュのビルドに対するものである。その後の main で再ビルドすると個々の結果は変わりうる。
- 受理された 221 本はプロファイルの判断1つであり、221 個の独立した不具合ではない。製品側の件数には数えていない。
- この仕分けのために商用シミュレータは実行しておらず、その出力も記録していない。
