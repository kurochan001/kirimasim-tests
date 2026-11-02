<a id="model-based-random-cross-comparisons"></a>

# モデルに基づくランダムクロス比較

[English](random-cross-verification.en.md)

Checkの固定クロス検証に加え、Nightlyで件数制限付きのランダム比較を行います。
同じ刺激をSystemVerilogの設計とPythonの参照モデルへ与え、規格で一意に定まる出力を照合します。
固定回帰のケース、oracle、有限モデルの分母は維持します。ランダム実行の本数や成功を、
固定スイートのテスト数・章間マトリクスの合格数・要求カバレッジへ加算しません。

<a id="scope"></a>

<a id="scope-and-generation"></a>

## 対象と生成方法

初期導入は、次の3プロファイルです。既存の有限モデル全体を任意の入力に対応させたものではありません。

- `expression_context`：幅・符号・代入先の幅・加減乗算を組み合わせ、任意の既知の入力ビット列を比較します。
  既存の`generators/interaction_expr.py`の参照関数を使います。
- `division_context`：自然幅と代入先の幅での商・剰余を比較します。
  `generators/interaction_divide.py`の参照関数を使い、符号付きの商は0方向へ切り捨てます。
  このプロファイルの入力は既知値で、除数は0以外です。ゼロ除算とX/Z入力は固定回帰に残します。
- `packed_write_sequence`：パック配列の昇順／降順、`+:`／`-:`、bit／logicを組み合わせます。
  ケースごとに選択幅を固定し、範囲内の位置、書込み値、読出しと書込みの操作列を変えます。
  全体のビット列を毎回観測して、選択していないビットの保持とX/Zの2状態変換も照合します。

幅は1・32・33・64・65・129を使い、算術式のオペランドと代入先にはモデルが許す±1ビットの差も含めます。
算術値は一様なランダム値と0・1・型の端点などを混ぜます。書込みプロファイルではX/Zも生成します。
各プロファイルをほぼ同数ずつ割り当て、順番と合法なパラメータをseedで選びます。
操作列の先頭は書込み、2操作目があれば読出しとし、以降は読出し／書込みを選びます。
同じ組合せが再び選ばれることはあります。ランダム抽出を2因子・3因子網羅の保証には使いません。

範囲外の添字、空コンテナ、並行スケジューリング、クラス、制約ソルバ、`randomize()`自体は今回の対象外です。
複数解のある乱数生成を確認するときは、生成値の完全一致ではなく制約の充足を判定する別の検査が必要です。

<a id="limits-and-verdicts"></a>

## 件数制限と判定

Nightlyの既定値は96ケース、各8ベクトル／操作、4並列、1ケース5秒、比較処理全体120秒です。
CLIの上限は256ケース、各32ベクトル／操作、8並列、1ケース30秒、全体600秒です。
全体の時間切れで着手できなかったケースは`not_run`、実行中の時間切れは`fail`にします。
ビルド時間はこの比較処理の制限とは別で、Nightlyの追加ステップ全体には15分の制限があります。

- `pass`：終了コード0、エラー診断なし、正規化した標準出力が期待値と一致。
- `fail`：出力差、非ゼロ終了、異常終了、エラー診断、実行時間切れなど。
- `unsupported`：kirimasimが終了コード2と未対応の診断を返した。
- `not_run`：全体の時間制限までに着手できなかった。
- `stale`：実行中にSV・期待値・manifest・参照コード・実行ファイルが変化した。

全ケースが有効な`pass`の場合だけ、比較のCLIは終了コード0になります。
未対応や未実行を合格へ読み替えません。`--generate-only`の終了コード0は生成成功だけを意味し、
実行の`pass`は0件です。正常な標準出力が出ても、非ゼロ終了なら失敗です。

<a id="run-locally"></a>

<a id="run-a-latest-build-locally"></a>

## 最新ビルドで実行する

実行直前に上流mainを取得し、そのコミットをビルドしてください。既存の作業を保持するため、
シミュレータには専用のクリーンなチェックアウトを使います。次はそのディレクトリからの例です。

```sh
git fetch origin main
git switch --detach FETCH_HEAD
cmake --preset release
cmake --build --preset release
git rev-parse HEAD
build/release/src/driver/kirimasim --version
```

表示された完全なコミットと、そのバイナリのパスを指定して本リポジトリから実行します。

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/kirimasim/build/release/src/driver/kirimasim \
  --commit VERIFIED_FULL_COMMIT --seed 731 \
  --cases 96 --vectors 8 --jobs 4 --timeout 5 --time-budget 120 \
  --output my-results/random-cross-731
```

`--commit`は40桁のコミットを要求し、バイナリの`--version`が示すコミットと照合します。
この照合だけで上流の最新性が証明されるわけではありません。取得・ビルドは呼出し側の責任です。
出力先は新規または空のディレクトリに限ります。以前の証跡を上書きしません。

<a id="replay"></a>

<a id="replay-saved-stimuli"></a>

## 保存した刺激から再現する

出力先には`manifest.json`、`run.json`、日英の`report.md`／`report.ja.md`、`events.jsonl`と、
`cases/`内のSV・期待値・標準出力・標準エラーを保存します。
manifestにはseedだけでなく、実際の入力値と操作列をすべて記録します。
runにはスイートのコミットと参照コードの変更有無、生成器の版、コードのハッシュ、
シミュレータのコミット・版・バイナリ指紋、各入力と期待値のハッシュ、終了コードと判定を記録します。

同じseedでも生成器や実行環境の変更で同じ刺激になるとは限らないため、再現時はmanifestを使います。
再実行時も、その直前に取得・ビルドしたシミュレータのコミットを指定してください。

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay my-results/random-cross-731/manifest.json \
  --case case_0007 --output my-results/random-cross-731-replay
```

`--case`を省くと保存した全ケースを再実行します。再現時はseed・件数・モデルなどの生成オプションを併用できません。
再抽選せず、保存された刺激を使います。参照コードが変わった場合は今回の期待値も変わり得るため、
元のartifactのコード指紋・期待値と比較します。自動的な反例最小化は未実装です。

シミュレータを起動せずに刺激と期待値を確認することもできます。

```sh
python3 tools/run_random_cross.py --generate-only --seed 731 --cases 12 \
  --output my-results/random-cross-731-generated
```

<a id="ci"></a>

<a id="check-and-nightly-responsibilities"></a>

## CheckとNightlyの役割

[Check](../.github/workflows/check.yml)は、従来の固定回帰と整合性検査を維持します。
追加した検査は、生成・保存manifestからの1ケース再現・SVと期待値のバイト一致、およびツールの単体テストです。
Checkに最新kirimasimでのランダム実行を追加してはいません。

[Nightly](../.github/workflows/nightly.yml)のkirimasimジョブは、固定スイートの後に上流mainを再取得・ビルドし、
直後にランダム比較します。seedはGitHubのrun IDです。同じrunの再試行では同じ刺激を生成できますが、
上流版が変わっていればその版での新しい実行になります。
非PASSが一つでもあればステップを失敗させ、通常の固定回帰のratchetも別に確認します。

再現資料は`random-cross-kirimasim`という専用artifactに保存し、日英レポートのうち英語版をStep Summaryへ載せます。
このartifactは`results-*`という公開処理の取得対象に含めません。固定回帰の履歴・グラフ・要求カバレッジへ混ぜません。
保存結果やローカルでの成功は、GitHub上のNightly実行成功を意味しません。

<a id="validation"></a>

<a id="initial-validation"></a>

## 導入時の検証

実際の版・件数・seed・指紋と故障検出の記録は[補助証跡](../coverage/interaction-qualification/random-cross.json)を参照してください。
[保存した96ケースのmanifest](../coverage/interaction-qualification/random-cross-manifest.json)は、CLIの`--replay`で読み込めます。
固定スイートの合格数へは加算しません。通常の境界ケースと少数因子網羅は引き続き固定回帰で保持します。
