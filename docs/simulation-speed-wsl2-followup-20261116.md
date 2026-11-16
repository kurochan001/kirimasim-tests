# WSL2 rerun and prototype verification received: 2026-11-16

[English](simulation-speed-wsl2-followup-20261116.md) / [日本語](simulation-speed-wsl2-followup-20261116.ja.md)

Additional results arrived via private Git relay `from-wsl/p1-speed-0.1.0-2026-11-16` at `ee544e7f233f3913583e04974066ce78b393ab36`. The same proposed patches reduce Linux elapsed time while matching all thirteen outputs and counter sets. The release rerun again overlapped external ctest/UVM work after a quiet start, so it remains a separate provisional record.

## Conditions and receipt checks

Pins and compiler remain kirimasim v0.1.0 `cfa2ccd75989c1ebb9ed63303271183377364cf0`, Icarus 14.0 devel `1eba3690d8314d79927df8690a7d97642dd93ce0`, Clang 20.1.8, Ryzen 9 7950X / WSL2. All three release binary hashes match the first run. Both patch hashes match Mac, and the parameterized Linux driver matches the requested Git blob.

The Mac verified all exits, full expectations and n=1 consistency across 286 rerun and 176 prototype invocations, and recalculated medians, min/max, MAD, baseline differences and ratios. Linux builds and unit tests were not executed again on the Mac.

## Release rerun

Measurement: 2026-11-16T00:20:36.193765+00:00 to 2026-11-16T00:36:50.920094+00:00 UTC. Start load [0.71, 1.96, 4.2], finish [4.63, 6.98, 5.75]. External ctest/UVM activity was reported during the run, so a quiet start does not establish an idle baseline. All-thirteen geometric mean KM/I is **1.220133**, or **1.240492** for the original twelve. The initial result was 1.193495.

| Design | First KM/I | Rerun KM/I | Rerun KM Δ s | Rerun Icarus Δ s |
|---|---:|---:|---:|---:|
| `casez_struct` | 1.203 | 1.196 | 4.663500 | 3.898983 |
| `comb_chain` | 1.178 | 1.159 | 11.381702 | 9.823417 |
| `dyn_queue` | 0.720 | 0.724 | 4.864935 | 6.716733 |
| `fork_join` | 1.457 | 1.413 | 6.309622 | 4.465652 |
| `func_call` | 0.798 | 0.815 | 6.164400 | 7.566682 |
| `gate_udp` | 1.715 | 1.705 | 6.362526 | 3.731126 |
| `mem_rw` | 1.688 | 1.707 | 6.440219 | 3.772494 |
| `nba_burst` | 1.067 | 1.125 | 0.139844 | 0.124347 |
| `nba_shift` | 1.354 | 1.302 | 34.702292 | 26.662716 |
| `proc_wait` | 1.473 | 1.575 | 9.768049 | 6.201116 |
| `string_fmt` | 0.563 | 0.678 | 6.336859 | 9.349520 |
| `wide_arith` | 2.415 | 2.526 | 5.180662 | 2.050841 |
| `fourstate_mix` | 1.004 | 1.000 | 1.585004 | 1.584398 |

The method remains five n=1/N repetitions, one warmup, serial alternating tool/count order, and Δ = `median(T(N))−median(T(1))`. Individual affected samples cannot be identified. Both release records remain separate provisional evidence; a definitive idle baseline requires coordination for the entire measurement window.

## Prototype timings

Five cases use five repetitions and the same baseline difference. Start 2026-11-16T01:17:08.330503+00:00, finish 2026-11-16T01:29:40.290249+00:00 UTC; load starts at [0.28, 1.91, 3.47] and ends at [1.0, 1.81, 3.0]. Low endpoint loads do not establish isolation throughout the run; these are descriptive five-round statistics.

| Design | Release Δ s | Prototype Δ s | Icarus Δ s | Time reduction | Prototype/Icarus |
|---|---:|---:|---:|---:|---:|
| `wide_arith` | 5.039562 | 2.451491 | 2.004558 | 51.36% | 1.223 |
| `gate_udp` | 8.301591 | 6.996493 | 4.735258 | 15.72% | 1.478 |
| `mem_rw` | 6.174759 | 5.300399 | 3.565430 | 14.16% | 1.487 |
| `nba_shift` | 30.833215 | 25.107765 | 22.793268 | 18.57% | 1.102 |
| `proc_wait` | 8.262478 | 7.104631 | 5.595700 | 14.01% | 1.270 |

Word operations alone reduce wide Δ to 2.590538 s. Combined wide-time reduction is about 51% on WSL2 versus 74% on Mac, showing environment-dependent gains. The Linux prototype still takes longer than Icarus in these five cases. No thirteen-design prototype aggregate is inferred.

## Functional and counter checks

- Release and combined prototype have matching expected lines and successful exits on all thirteen designs. All counters match between them and the stored Mac prototype counter records. Gains do not come from skipped logical events or instructions.
- Received WSL2 build records report a passing release flag check, Wide 7/7, Valsem 15/15 and 122,184 additional reference comparisons. These are attributed to the received execution records.
- Matching patch hashes, outputs and counters support word operations and immutable-type caching as adoption candidates on both platforms. Application to simulator main, full `local_ci.py`, sanitizers and large-design startup/RSS remain unperformed.

## Retained evidence

[All rerun samples](measurements/2026-11-16/wsl2-followup/quiet-rerun/results.json), [rerun provenance](measurements/2026-11-16/wsl2-followup/quiet-rerun/build-provenance.json), [prototype samples](measurements/2026-11-16/wsl2-followup/prototypes/prototype-results.json) and [prototype provenance](measurements/2026-11-16/wsl2-followup/prototypes/build-provenance.json) are byte-identical to the received blobs. The [counter check](measurements/2026-11-16/wsl2-followup/prototypes/counter-check.json) removes only successful stderr_tail fields containing temporary paths, retaining every result, exit and counter. Removed fields and the original blob hash are recorded; the original is preserved privately.

See [receipt hashes](measurements/2026-11-16/wsl2-followup/receipt.json), [recalculation verdict](measurements/2026-11-16/wsl2-followup/verification.json), [initial WSL2 record](simulation-speed-wsl2-20261116.md), [overview](simulation-speed-20261116.md) and [investigation](simulation-speed-analysis-20261116.md).
