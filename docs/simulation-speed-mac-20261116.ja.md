# kirimasim 0.1.0 と Icarus 14.0 devel の速度比較（Mac、2026-11-16）

[English](simulation-speed-mac-20261116.md) / [日本語](simulation-speed-mac-20261116.ja.md)

> **2026-11-17追記：** このページは以前のソース・日時・測定値を保持しています。採用した変更、新しい全13入力比較、別の最終3入力比較は [0.1.1の速度改善記録](simulation-speed-20261117.ja.md)を参照してください。以下の試作・未採用という記述は、当時のcheckpointを示します。

この Mac では、比較可能な 13/13 本の幾何平均で **kirimasim/Icarus の時間比は 1.065**、この指標では kirimasim の時間が約 6.5% 長くなりました。既存 12 本だけでは 1.080、追加 1 本込みでは 5/13 本で kirimasim の基線差分 Δ が小さくなりました。比が 1 より小さいほど kirimasim が速い値です。幾何平均は各ベンチを等重みで集約し、実利用の負荷配分を表すものではありません。

ベンチごとの比は 0.520（`string_fmt`）〜3.316（`wide_arith`）です。集約値は Icarus に近い一方、広幅演算（3.316）、ゲート／UDP（1.831）、メモリ読み書き（1.423）に差があり、これらの負荷で全般に同等とはまだ言い切れません。次にプロファイリングする候補ですが、この時間比較だけでは原因を特定していません。この測定で P1 の合格閾値は新設せず、Linux や別の設計へ結果を一般化しません。

## 対象と環境

- kirimasim [v0.1.0](https://github.com/kurochan001/kirimasim/releases/tag/v0.1.0)、commit `cfa2ccd75989c1ebb9ed63303271183377364cf0`。AppleClang 21.0.0.21000401、release（`-O3 -DNDEBUG -ffp-contract=off`、fast-math なし）、フラグ検査合格。
- Icarus [master](https://github.com/steveicarus/iverilog/tree/1eba3690d8314d79927df8690a7d97642dd93ce0) を作業開始時に取得し、commit `1eba3690d8314d79927df8690a7d97642dd93ce0` に固定。実行表示は `14.0 (devel) (1eba369)`。同じ Apple clang 21.0.0、標準 configure の `-g -O2`。
- Apple M5 Max、arm64、18 論理 CPU、128 GiB、macOS 27.2.1（26B131）。CPU affinity や周波数の固定は適用していません。
- 開始 `2026-11-15T21:26:12.058953+00:00`、終了 `2026-11-15T21:37:49.785805+00:00`（UTC。日本時間では 11 月 16 日）。開始時 load average [10.23, 10.99, 11.37]、終了時 [10.62, 10.07, 10.25]。OS の索引作成やエディタなどの活動があり、無負荷の専用機という条件ではありません。計測中に本作業の別ビルドやテストスイートは走らせていません。

## 測定方法

同じ release の既存 `bench/*.sv` 12 本を変更せず使い、既存群が明示的な X/Z 入力を含まないため、[fourstate_mix](../bench/fourstate_mix.sv) を追加しました。両ツールは同じソース、同じ N と期待値を使います。

1. Icarus は各設計を `iverilog -g2012` で 1 回コンパイルし、`vvp -n` を計時します。コンパイル時間は別に記録します。kirimasim はソースを直接実行し、パースと elaboration も実行時間に入ります。
2. 各 tool に n=1 の warmup を 1 回行い、n=1 と N を各 5 回、直列で実行します。tool 順は case/round ごと、n 順は round ごとに反転します。待ち時間は単調時計で測ります。1 実行の制限は 600 秒です。
3. 主指標 Δ は `median(T(N)) − median(T(1))`、比は `Δkirimasim / ΔIcarus` です。これは基線を実測して差し引いた値で、起動や front-end の完全な分離を証明しません。反復数の比例換算はしていません。full の実測値も下に載せています。5 回の記述統計であり、信頼区間や差の統計的有意性は主張しません。
4. 全本測定の出力を既存の期待行と完全一致で検査し、全 n=1 の行も tool/round 間で一致を確認します。追加ベンチの n=1 は規格由来の期待行とも照合します。終了異常、timeout、不一致、不完全な反復、非正の差分は比率から外します。ソース・driver・adapter・バイナリの SHA-256 が途中で不変であることも検査します。

## 結果

| ベンチ | N | kirimasim Δ 秒 | Icarus Δ 秒 | 比 KM/I |
|---|---:|---:|---:|---:|
| `casez_struct` | 5,000,000 | 3.475524 | 3.111596 | 1.117 |
| `comb_chain` | 3,000,000 | 8.094163 | 7.876193 | 1.028 |
| `dyn_queue` | 4,000,000 | 3.218709 | 5.464449 | 0.589 |
| `fork_join` | 4,000,000 | 4.119411 | 4.119934 | 1.000 |
| `func_call` | 1,500,000 | 4.333494 | 7.292099 | 0.594 |
| `gate_udp` | 400,000 | 4.949989 | 2.703258 | 1.831 |
| `mem_rw` | 4,000,000 | 4.045235 | 2.842332 | 1.423 |
| `nba_burst` | 500,000 | 0.089609 | 0.089082 | 1.006 |
| `nba_shift` | 1,000,000 | 21.787320 | 18.457518 | 1.180 |
| `proc_wait` | 1,000,000 | 5.915084 | 5.021758 | 1.178 |
| `string_fmt` | 500,000 | 3.704463 | 7.125530 | 0.520 |
| `wide_arith` | 1,500,000 | 6.701178 | 2.020566 | 3.316 |
| `fourstate_mix` | 1,000,000 | 1.139078 | 1.273255 | 0.895 |

### 実行時間とばらつき

各値は秒です。full は N 回の実行全体、n=1 は基線です。MAD は full の中央値絶対偏差です。

| ベンチ | tool | full 中央値 | n=1 中央値 | full min–max | full MAD |
|---|---|---:|---:|---:|---:|
| `casez_struct` | kirimasim | 3.482588 | 0.007064 | 3.397827–3.499184 | 0.014591 |
| `casez_struct` | icarus | 3.117500 | 0.005904 | 3.024863–3.179745 | 0.062156 |
| `comb_chain` | kirimasim | 8.101501 | 0.007338 | 8.045990–8.277816 | 0.049022 |
| `comb_chain` | icarus | 7.881441 | 0.005247 | 7.772372–7.973193 | 0.049315 |
| `dyn_queue` | kirimasim | 3.226375 | 0.007666 | 3.168336–3.250636 | 0.024261 |
| `dyn_queue` | icarus | 5.470586 | 0.006137 | 5.416148–5.503133 | 0.032547 |
| `fork_join` | kirimasim | 4.126998 | 0.007588 | 4.122964–4.189692 | 0.001584 |
| `fork_join` | icarus | 4.125825 | 0.005891 | 4.114671–4.209971 | 0.011154 |
| `func_call` | kirimasim | 4.340832 | 0.007337 | 4.315741–4.377881 | 0.024242 |
| `func_call` | icarus | 7.298112 | 0.006013 | 7.225969–7.308245 | 0.010134 |
| `gate_udp` | kirimasim | 4.957692 | 0.007704 | 4.926173–5.045257 | 0.031519 |
| `gate_udp` | icarus | 2.709707 | 0.006449 | 2.650870–2.770765 | 0.008645 |
| `mem_rw` | kirimasim | 4.053659 | 0.008424 | 4.010041–4.086705 | 0.019087 |
| `mem_rw` | icarus | 2.848539 | 0.006207 | 2.821233–2.893246 | 0.021252 |
| `nba_burst` | kirimasim | 0.096886 | 0.007277 | 0.096129–0.097607 | 0.000358 |
| `nba_burst` | icarus | 0.094657 | 0.005575 | 0.093887–0.095956 | 0.000588 |
| `nba_shift` | kirimasim | 21.794651 | 0.007332 | 21.514410–21.997767 | 0.172663 |
| `nba_shift` | icarus | 18.463639 | 0.006121 | 18.329879–18.731632 | 0.133760 |
| `proc_wait` | kirimasim | 5.923610 | 0.008526 | 5.903763–5.962519 | 0.019847 |
| `proc_wait` | icarus | 5.028180 | 0.006422 | 5.013378–5.055429 | 0.014802 |
| `string_fmt` | kirimasim | 3.712126 | 0.007663 | 3.669652–3.767028 | 0.042474 |
| `string_fmt` | icarus | 7.131563 | 0.006034 | 7.094122–7.228829 | 0.033475 |
| `wide_arith` | kirimasim | 6.708965 | 0.007787 | 6.677806–6.720462 | 0.005353 |
| `wide_arith` | icarus | 2.026584 | 0.006018 | 2.021719–2.054379 | 0.003006 |
| `fourstate_mix` | kirimasim | 1.146992 | 0.007915 | 1.116061–1.150318 | 0.003116 |
| `fourstate_mix` | icarus | 1.279502 | 0.006246 | 1.275192–1.289583 | 0.004098 |

## 追加ベンチの根拠

`fourstate_mix` は 32 bit の連続ビット演算、X/Z を含む入力、case equality、`$isunknown` を組み合わせ、毎回 #1 の後に観測します。IEEE 1800-2023 の 11.4.5、11.4.8、20.9 と 32 bit unsigned の剰余計算から期待値を作り、元の PDF の AND/XOR 表も確認しました。

[Python 参照計算](../bench/reference_fourstate_mix.py) はシミュレータを使いません。別の AI 担当が 4 状態ビットマスクの別実装と位相別の集計で再計算しました。参照ファイルを先に読んだ事実があるため、参照実装を見ない検証とは呼びません。`spec_check: ai` のままです。100 万回では `checksum=a0ea5e58 unknowns=250000 x_hits=250000 z_hits=500000`、n=1 では `checksum=00008abc unknowns=0 x_hits=0 z_hits=0` になります。適合テスト台帳の要求・分母・網羅率は変更していません。

## 再現と証跡

```sh
# Set BENCHMARK_ROOT to the pinned kirimasim v0.1.0 source worktree;
# set KIRIMASIM and IVERILOG to the freshly built executables.
# vvp must be installed beside iverilog.
python3 tools/benchmark_compare.py \
  --benchmark-root "$BENCHMARK_ROOT" \
  --kirimasim "$KIRIMASIM" --iverilog "$IVERILOG" \
  --kirimasim-commit cfa2ccd75989c1ebb9ed63303271183377364cf0 \
  --icarus-commit 1eba3690d8314d79927df8690a7d97642dd93ce0 \
  --extra-bench bench/fourstate_mix.sv --runs 5 --out "$RESULTS"
```

[全サンプルと実行検査](measurements/2026-11-16/mac-results.json)には 13 本×2 tool×（warmup 1＋n=1 5＋N 5）の実測、期待行、実行コマンド、Icarus のコンパイル時間、RSS、版、ソースと実行ファイルの hash を保存しています。[ビルドと検証の情報](measurements/2026-11-16/build-provenance.json)も参照してください。RSS は macOS の ru_maxrss であり、WSL2 の VmHWM と同じ指標ではありません。

## Linux / WSL2

WSL2 の結果は私有 Git リレーの `from-wsl/p1-speed-0.1.0-2026-11-16`（`f88c63e5`）で受領し、全13本・286実行と入力のhashを照合しました。[WSL2 の詳細](simulation-speed-wsl2-20261116.ja.md)は別のctest/UVM実行が重なった参考値として保存しています。[両環境の概要](simulation-speed-20261116.ja.md)と合わせて参照してください。

[原因調査と対策案](simulation-speed-analysis-20261116.ja.md)で、遅い負荷のprofileと別の試作比較を記録しています。
