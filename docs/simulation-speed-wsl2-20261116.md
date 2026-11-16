# WSL2 speed measurement with concurrent load: 2026-11-16

[English](simulation-speed-wsl2-20261116.md) / [日本語](simulation-speed-wsl2-20261116.ja.md)

**Received as provisional performance evidence.** All thirteen designs and 286 invocations, output checks, statistics and the common source/adapter/driver hashes were verified. The geometric mean KM/Icarus ratio is 1.193495, or 1.210850 for the original twelve. External ctest/UVM activity overlapped, so this is not treated as an idle-machine measurement. The original record is preserved; the [rerun and prototype results](simulation-speed-wsl2-followup-20261116.md) were subsequently received separately.

## Receipt and environment

- Retrieved from private Git relay `from-wsl/p1-speed-0.1.0-2026-11-16`, commit `f88c63e5557cd1b28f52715f0546fedbd8418ec2`. These are verified WSL2-side records; Linux binaries were not executed on the Mac.
- AMD Ryzen 9 7950X, 32 logical CPUs, 110 GiB visible to WSL2, Ubuntu 24.04.4 LTS, kernel 6.18.58.1-microsoft-standard-WSL2. The received environment record reports Windows 10.0.26300.9974 and WSL 3.0.5.0.
- kirimasim v0.1.0 `cfa2ccd75989c1ebb9ed63303271183377364cf0`, Clang 20.1.8, release `-O3 -DNDEBUG -ffp-contract=off`. The WSL2 record reports a successful release flag check.
- Icarus 14.0 devel `1eba3690d8314d79927df8690a7d97642dd93ce0`, same Clang 20.1.8, standard configure `-g -O2`. Displayed version `14.0 (devel) (s20260301-1076-g1eba3690d)` names the same commit as Mac.
- Measurement: 2026-11-15T22:14:19.180376+00:00 to 2026-11-15T22:30:01.830101+00:00 UTC. Start load averages [1.05, 3.8, 6.35]; finish [7.88, 5.41, 4.9].

## Method and results

The same original twelve designs plus X/Z addition, N values, expectations and measurement code are used. Each tool has one n=1 warmup and five repetitions each of n=1 and N, serially alternating tool/count order. Primary Δ is `median(T(N))−median(T(1))`. Icarus compilation is separate; kirimasim parsing/elaboration remains in each invocation. These are five-round descriptive statistics without confidence intervals or a significance claim.

| Design | N | KM Δ s | Icarus Δ s | KM/I |
|---|---:|---:|---:|---:|
| `casez_struct` | 5,000,000 | 4.648588 | 3.862831 | 1.203 |
| `comb_chain` | 3,000,000 | 11.294246 | 9.590667 | 1.178 |
| `dyn_queue` | 4,000,000 | 4.809413 | 6.679349 | 0.720 |
| `fork_join` | 4,000,000 | 6.362014 | 4.366547 | 1.457 |
| `func_call` | 1,500,000 | 6.017984 | 7.543269 | 0.798 |
| `gate_udp` | 400,000 | 6.340829 | 3.696448 | 1.715 |
| `mem_rw` | 4,000,000 | 5.765813 | 3.415025 | 1.688 |
| `nba_burst` | 500,000 | 0.128035 | 0.120045 | 1.067 |
| `nba_shift` | 1,000,000 | 31.054540 | 22.943028 | 1.354 |
| `proc_wait` | 1,000,000 | 8.386494 | 5.693771 | 1.473 |
| `string_fmt` | 500,000 | 6.207118 | 11.022416 | 0.563 |
| `wide_arith` | 1,500,000 | 5.549363 | 2.298124 | 2.415 |
| `fourstate_mix` | 1,000,000 | 1.622729 | 1.616811 | 1.004 |

## Elapsed times and spread

| Design | Tool | Full median s | n=1 median s | Full min–max s | Full MAD s |
|---|---|---:|---:|---:|---:|
| `casez_struct` | kirimasim | 4.653088 | 0.004500 | 4.546782–4.685345 | 0.032257 |
| `casez_struct` | icarus | 3.866205 | 0.003373 | 3.790279–4.178953 | 0.044798 |
| `comb_chain` | kirimasim | 11.302266 | 0.008020 | 11.128568–11.409332 | 0.036394 |
| `comb_chain` | icarus | 9.593815 | 0.003147 | 9.502011–9.756316 | 0.077790 |
| `dyn_queue` | kirimasim | 4.814245 | 0.004832 | 4.746124–4.947273 | 0.039313 |
| `dyn_queue` | icarus | 6.682633 | 0.003284 | 6.558447–6.914721 | 0.063625 |
| `fork_join` | kirimasim | 6.368014 | 0.005999 | 6.201455–6.584169 | 0.125220 |
| `fork_join` | icarus | 4.369469 | 0.002922 | 4.300026–4.935792 | 0.069443 |
| `func_call` | kirimasim | 6.022428 | 0.004445 | 5.942980–6.130294 | 0.016879 |
| `func_call` | icarus | 7.546645 | 0.003376 | 7.313160–7.789583 | 0.208185 |
| `gate_udp` | kirimasim | 6.349025 | 0.008195 | 6.247759–6.460457 | 0.010210 |
| `gate_udp` | icarus | 3.700191 | 0.003743 | 3.654309–3.815262 | 0.039537 |
| `mem_rw` | kirimasim | 5.771417 | 0.005604 | 5.610046–6.159458 | 0.161370 |
| `mem_rw` | icarus | 3.418592 | 0.003568 | 3.335112–3.440124 | 0.021531 |
| `nba_burst` | kirimasim | 0.132087 | 0.004052 | 0.127540–0.157349 | 0.003615 |
| `nba_burst` | icarus | 0.123145 | 0.003100 | 0.118436–0.125230 | 0.001976 |
| `nba_shift` | kirimasim | 31.059515 | 0.004976 | 30.300064–33.976007 | 0.435847 |
| `nba_shift` | icarus | 22.946644 | 0.003616 | 22.618005–23.271796 | 0.195753 |
| `proc_wait` | kirimasim | 8.394307 | 0.007814 | 8.318780–8.504262 | 0.055098 |
| `proc_wait` | icarus | 5.697685 | 0.003914 | 5.611302–5.703113 | 0.005428 |
| `string_fmt` | kirimasim | 6.213597 | 0.006479 | 5.775515–9.267119 | 0.438082 |
| `string_fmt` | icarus | 11.026008 | 0.003593 | 8.392531–12.411190 | 1.385181 |
| `wide_arith` | kirimasim | 5.557117 | 0.007754 | 5.276629–6.380216 | 0.108874 |
| `wide_arith` | icarus | 2.301452 | 0.003329 | 2.009508–2.966041 | 0.231823 |
| `fourstate_mix` | kirimasim | 1.627633 | 0.004904 | 1.610275–1.662360 | 0.010403 |
| `fourstate_mix` | icarus | 1.620217 | 0.003406 | 1.590556–1.706872 | 0.029661 |

## Data quality and rerun

`string_fmt`, `wide_arith` and other designs have substantial spread. External ctest and UVM processes were reported by the WSL2 side. Because affected individual samples cannot be identified, the entire record is retained as provisional evidence under concurrent load. Correct outputs and unchanged inputs do not remove timing interference.

The rerun started at low load but again overlapped external ctest/UVM work. It remains a second provisional record in the [follow-up](simulation-speed-wsl2-followup-20261116.md), alongside the received prototype checks.

## Evidence

[All samples](measurements/2026-11-16/wsl2-results.json) and [build provenance](measurements/2026-11-16/wsl2-build-provenance.json) are byte-identical to the received blobs. [Receipt hashes](measurements/2026-11-16/wsl2-receipt.json) and the [Mac-side recalculation verdict](measurements/2026-11-16/wsl2-verification.json) are retained. Linux executable contents were not independently verified on the Mac. RSS uses VmHWM, unlike Mac ru_maxrss.

See the [overview](simulation-speed-20261116.md), [Mac details](simulation-speed-mac-20261116.md) and [investigation/prototypes](simulation-speed-analysis-20261116.md).
