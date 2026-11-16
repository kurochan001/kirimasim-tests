# kirimasim 0.1.1 に採用する速度改善：Mac、2026-11-17

[English](simulation-speed-20261117.md) / [日本語](simulation-speed-20261117.ja.md)

0.1.1 では、広幅演算のワード化、不変な先頭オペランド型のキャッシュ、整数・void 命令の実行経路分類を採用します。**最新の3入力の直接比較で Icarus を上回ったのは `proc_wait` だけで、時間比は gate 1.467、memory 1.093、waiting 0.977（kirimasim/Icarus）でした。** 最終ソースが全13入力で Icarus より速いと示した結果ではありません。

先行する最適化版 `7f5a9134` は全13入力を測定し、時間比の幾何平均が Icarus 比0.823、最適化前比0.774、Icarus より短い入力は10/13でした。追加の経路分類版 `1745b8fc` の時間測定は3入力です。別の測定同士を掛け合わせたり合算したりして、新たな全13入力の成績にはしません。

## 範囲と方法

- Apple M5 Max、18論理CPU、128 GiB、macOS 27.2.1。kirimasim は AppleClang 21.0.0.21000401、release `-O3 -DNDEBUG -ffp-contract=off`、fast-math なしです。release flags の検査は成功しています。
- 基準版 `c152d237ac8dbd1b81349e7d578c25504d4ae8d5` は、v0.1.0 と `src/`・CMake のビルド設定が同一です。先行最適化版は `7f5a9134f227e3d42491397105c745e11a5ed54a`、追加の経路分類版は `1745b8fc4e712d2b04fda5416184d3fc060358be` です。測定は版番号変更前のソースで行い、0.1.1 がその kernel/VM 変更を採用します。
- Icarus は14.0 devel `1eba3690d8314d79927df8690a7d97642dd93ce0` に固定し、前の Mac 測定と同じ実行ファイルの hash です。ブラックボックスとして実行し、実装ソースは読んでいません。
- 元の `kirimasim/bench/*.sv` 12本と `kirimasim-tests/bench/fourstate_mix.sv` は、N と期待する行を保持しています。各版で n=1 のウォームアップ1回、n=1 と N を各5回、直列・順序交替で実行しました。
- 指標 Δ は `median(T(N)) - median(T(1))`、単位は秒です。Icarus のコンパイルは別記、kirimasim の解析・elaboration は呼び出し時間に含みます。基線の差し引きは frontend の完全分離を保証しません。呼び出し全体の中央値・min/max/MAD・RSS・コマンド・版・hash を保存しています。
- **並行 local CI の影響を含む参考計測です。** 別の ctest/kirimasim と負荷平均を記録し、ユーザー了承のもとで先行計測しました。5反復の記述統計で、信頼区間や性能 gate を設けたものではありません。
- 採用ソースの Linux 専用性能・RSS 再計測は、WSL2 が別件で混雑中のため保留です。[以前の Linux 試作測定](simulation-speed-wsl2-followup-20261116.ja.md)は、別ソースの日時付きの証拠として保持します。

## 7f5a9134 の全13入力

基準版・最適化版・Icarus を同じ直列測定内で比較し、13 × 3 ×（ウォームアップ1回＋短い実行5回＋本測定5回）=429回すべての実行・出力照合が成功しました。全入力・binary の hash は不変です。幾何平均は各設計を同じ重みで扱い、実案件の構成比を表しません。

| 入力 | N | 基準版 Δ 秒 | 7f5a9134 Δ 秒 | Icarus Δ 秒 | 7f/Icarus | 基準版からの短縮 % |
|---|---:|---:|---:|---:|---:|---:|
| `casez_struct` | 5,000,000 | 3.629 | 2.744 | 3.208 | 0.855 | 24.4 |
| `comb_chain` | 3,000,000 | 8.144 | 7.052 | 8.049 | 0.876 | 13.4 |
| `dyn_queue` | 4,000,000 | 3.220 | 2.754 | 5.470 | 0.503 | 14.5 |
| `fork_join` | 4,000,000 | 4.162 | 3.819 | 4.076 | 0.937 | 8.2 |
| `func_call` | 1,500,000 | 4.348 | 3.911 | 7.364 | 0.531 | 10.0 |
| `gate_udp` | 400,000 | 4.977 | 4.111 | 2.713 | 1.515 | 17.4 |
| `mem_rw` | 4,000,000 | 4.097 | 3.486 | 2.923 | 1.193 | 14.9 |
| `nba_burst` | 500,000 | 0.092 | 0.076 | 0.091 | 0.837 | 17.0 |
| `nba_shift` | 1,000,000 | 21.786 | 18.094 | 18.800 | 0.962 | 16.9 |
| `proc_wait` | 1,000,000 | 5.999 | 5.413 | 5.165 | 1.048 | 9.8 |
| `string_fmt` | 500,000 | 3.742 | 3.163 | 7.169 | 0.441 | 15.5 |
| `wide_arith` | 1,500,000 | 6.932 | 1.773 | 2.023 | 0.877 | 74.4 |
| `fourstate_mix` | 1,000,000 | 1.133 | 0.924 | 1.287 | 0.718 | 18.5 |

広幅・型の変更を併用した `wide_arith` は、この測定では74.4%短縮しました。この併用結果からワード処理単独の寄与を推定しません。この版の `gate_udp`・`mem_rw`・`proc_wait` は、まだ Icarus より時間がかかっています。

[429実行の全記録](measurements/2026-11-17/main-7f5a9134-three-way.json)。測定期間：2026-11-17 01:38:08 JST ～ 2026-11-17 01:54:41 JST。

## 1745b8fc の追加の経路分類

全 body の結果型・block parameter 型が揃った後、結果が整数または void で、全オペランドの静的型が整数の命令を分類します。関係しない class/container/string/real の判定を省き、参照・typed handle の経路、kernel の値演算、scheduler の呼び出しは保ちます。最初の試作は整数結果だけを分類し、採用ソースは void 結果の代入も含めています。

| 入力 | 7f5a9134 Δ 秒 | 最初の試作 Δ 秒 | 1745b8fc Δ 秒 | 7fからの短縮 % |
|---|---:|---:|---:|---:|
| `gate_udp` | 4.070 | 3.971 | 3.899 | 4.2 |
| `mem_rw` | 3.450 | 3.149 | 3.105 | 10.0 |
| `proc_wait` | 5.364 | 5.158 | 5.107 | 4.8 |

別に行った3版比較で、99回すべての実行照合が成功しました。期間は 2026-11-16T17:25:22.875115+00:00 ～ 2026-11-16T17:29:22.364149+00:00 UTC です。この短縮率は 7f5a9134 からの改善で、Icarus からの短縮率ではありません。

[比較サンプルと全カウンタ](measurements/2026-11-17/dispatch-paired.json)。親7f5a9134＋差分でビルドした測定時のソース差分は、その後の commit 1745b8fc の差分とバイト単位で一致します。生記録の調査中という状態は測定時点のまま残し、採用状況はこの本文で示します。

## 1745b8fc と Icarus の直接比較

コミット済みソースを再ビルドし、変更していない `tools/benchmark_compare.py` で直接比較しました。各版・各回数5反復とウォームアップの66回すべてが実行・出力照合に成功し、全 fingerprint は不変です。期間は 2026-11-16T20:52:29.557147+00:00 ～ 2026-11-16T20:54:21.543282+00:00 UTC です。

| 入力 | 1745b8fc Δ 秒 | Icarus Δ 秒 | 1745/Icarus |
|---|---:|---:|---:|
| `gate_udp` | 3.815 | 2.600 | 1.467 |
| `mem_rw` | 3.039 | 2.781 | 1.093 |
| `proc_wait` | 4.975 | 5.093 | 0.977 |

対象3本で Icarus より中央値 Δ が小さいのは `proc_wait` だけです。最終ソースの全13入力の時間成績はまだなく、残る10入力は出力・全カウンタの一致を確認し、この追補では時間を再測定していません。

[直接比較66実行の全記録](measurements/2026-11-17/dispatch-icarus.json)。

## 残るCPU処理

7f5a9134 のワーカーを、macOS `sample`・1 ms間隔で各入力2回採取しました。join 待ちの親スレッドは除外します。自己観測は親の回数から直接の子の回数を差し引き、execute 系には compiler 生成 lambda も含めます。配下を含む分類には重複があり、正確なCPU時間ではありません。6回すべての出力が期待値と一致し、計測器付きの実時間は速度比較に使いません。

| 入力 | ワーカー観測数 | execute系 自己 % | runBody 自己 % | waitTriggers 配下 % | udpOutput 配下 % |
|---|---:|---:|---:|---:|---:|
| `gate_udp` | 5206 | 31.1 | 19.0 | 13.6 | 3.7 |
| `mem_rw` | 5187 | 32.4 | 14.5 | 2.8 | 0.0 |
| `proc_wait` | 6906 | 28.1 | 25.6 | 0.0 | 0.0 |

次の候補は、operand kind/temp offset/PC の事前デコード、gate の静的待機条件の再利用、mem の小幅 slot/NBA 登録経路です。効果は未計測です。命令数上限、NBA 発行順、delta cycle、iff/watch/strength、frame/GC の寿命、force、VPI 通知を保持します。ゼロ遅延NBAはすでに arena を使っており、新しい payload allocator の導入を前提にしません。

[プロファイル集計](measurements/2026-11-17/dispatch-profile.json)。

## 起動・メモリ・正しさ

この Mac では、先頭オペランド型 cache で `InstrInfo` が72から88バイトに増え、経路分類bitは既存 padding に置くため88バイトを保ちます。先の404,001命令の試験では、最初の型cacheによって peak RSS が約6 MiB増えました。追加の経路分類bitは別の検証済みSIR load＋空実行probeで、規模・版ごとに1ウォームアップ後7回ずつ交互に測定しました。

| SIR命令数 | 7f相当 load ms | 経路分類 load ms | load MAD ms 前/後 | peak RSS MiB 前/後 |
|---|---:|---:|---:|---:|
| 101,001 | 2.719 | 2.750 | 0.069 / 0.065 | 36.52 / 36.50 |
| 404,001 | 10.969 | 11.044 | 0.106 / 0.128 | 134.17 / 134.16 |

404,001命令での差は約0.076 ms、MADは0.106/0.128 msです。source frontend を含まず、一般的な追加コストの上限を示しません。[全loadサンプル](measurements/2026-11-17/dispatch-load.json)。

全13入力の標準出力と全counterのkey/valueが、ソースの同じ親版の参照と一致します。論理イベント数も同じで、期待値・性能閾値・言語契約・依存を変更していません。記録したdev実行は13,858件成功です。0.1.1ソースの全local CIは、速度測定とは別のpush前検証です。

## 証拠と再実行

[measurements/2026-11-17/](measurements/2026-11-17/) に、版・hash・全サンプルと[ビルド・ソースの来歴](measurements/2026-11-17/build-and-source-provenance.json)を保存しています。home path とホスト・ユーザー識別子は除き、生のsample logは非公開です。以前の [0.1.0比較](simulation-speed-20261116.ja.md)と[試作の解析](simulation-speed-analysis-20261116.ja.md)は日時・数値を保持しています。

最後の3入力比較は、固定したビルドとtest repoのdriverで実行できます。

```sh
python3 tools/benchmark_compare.py \
  --benchmark-root "$SOURCE" --kirimasim "$KIRIMASIM" --iverilog "$IVERILOG" \
  --kirimasim-commit 1745b8fc4e712d2b04fda5416184d3fc060358be \
  --icarus-commit 1eba3690d8314d79927df8690a7d97642dd93ce0 \
  --only gate_udp mem_rw proc_wait --runs 5 --out "$RESULTS"
```

測定したリリース前のソースを固定する指定で、0.1.1のcheckoutは版番号・文書の後続commitを含みます。選んだcommitとbinaryの版・source hashを照合してください。先の基準版/7f/Icarusの順序には[可搬3版driver](measurements/2026-11-17/three_way_measure.py)、読み込みには[記録したSIR probe](measurements/2026-11-17/metadata_load.cpp)と[build helper](measurements/2026-11-17/prepare_load.py)を使います。測定中はシミュレータsource・期待値を変更しません。
