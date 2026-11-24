# kirimasim-tests の夜間実行結果

[English](README.md) / [日本語](README.ja.md)

[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) の[夜間ワークフロー](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)がこのブランチを更新します。毎晩、main ブランチのシミュレーションテストを各シミュレータで実行し、結果を `history.json` に追加して、以下の図を生成します。スイート総数には形式検証専用テストも含みます。各シミュレータの行はシミュレーションテストの集計です。ローカル実行の結果も取り込むことができ、`local` と表示します。出力と指定された検査が期待結果に一致する場合、または不正な設計が必要な診断付きで拒否される場合に、テストを「一致」と数えます。各ステータスの意味はスイートの README を参照してください。

最新の実行: 2026-11-24 07:22 UTC、スイートのコミット [`cbbd51a`](https://github.com/kurochan001/kirimasim-tests/commit/cbbd51a3258858ad65d0759ba41cb7d4b44fd540)、テスト16371件、[ワークフロー実行](https://github.com/kurochan001/kirimasim-tests/actions/runs/45325586796)。

## シミュレータごとの最新結果

各行と章別表の各列には、そのシミュレータの最新の実行記録を使います。実行日時、スイートのコミット、テスト数は異なる場合があります。古い結果の日時はそのまま保持し、最新の実行に含まれる結果としては扱いません。

緑のworkflowは全テストの合格を意味しません。[Nightlyが緑でもDifferが残る理由](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/docs/faq.md#q11-why-can-nightly-be-green-with-differ-results)と、[区分・個別テストの確認先](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/docs/faq.md#q9-what-do-match-differ-known-difference-and-unsupported-mean)を読んでから件数を比較してください。

| シミュレータ | バージョン | 実行 (UTC) | スイート | 取り込み元 | 一致 (pass) | 不一致 (fail) | 既知の差異 (known) | 未対応 (unsupported) |
| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-1283-gaddeab31) | 2026-11-24 07:22 | [`cbbd51a`](https://github.com/kurochan001/kirimasim-tests/commit/cbbd51a3258858ad65d0759ba41cb7d4b44fd540) | nightly | 10351 (64.3%) | 12 | 5741 | 0 |
| Verilator | Verilator 5.055 devel rev v5.054-373-g9dee5c5f | 2026-11-24 07:22 | [`cbbd51a`](https://github.com/kurochan001/kirimasim-tests/commit/cbbd51a3258858ad65d0759ba41cb7d4b44fd540) | nightly | 9175 (57.0%) | 29 | 6900 | 0 |
| kirimasim | kirimasim 0.2.1 (commit e93839fdcbea), built with GNU 13.3.0 | 2026-11-24 07:22 | [`cbbd51a`](https://github.com/kurochan001/kirimasim-tests/commit/cbbd51a3258858ad65d0759ba41cb7d4b44fd540) | nightly | 13180 (81.8%) | 296 | 0 | 2628 |
| Lyra | Lyra (commit 3a8b6c77f2a9) | 2026-11-24 07:22 | [`cbbd51a`](https://github.com/kurochan001/kirimasim-tests/commit/cbbd51a3258858ad65d0759ba41cb7d4b44fd540) | nightly | 13497 (83.8%) | 861 | 0 | 1746 |
| Ghost | private build ddc1a7154d2d | 2026-11-24 07:22 | [`cbbd51a`](https://github.com/kurochan001/kirimasim-tests/commit/cbbd51a3258858ad65d0759ba41cb7d4b44fd540) | nightly | 16102 (100.0%) | 2 | 0 | 0 |

Ghost は正式公開前に参加している匿名のシミュレータです。現在公開しているのはテスト結果のみです。名称、ソースコード、ビルドログは非公開で、ビルドIDには実行ファイルのハッシュを使用します。

![期待結果に一致するテスト数](charts/overview.ja.svg?v=20261124T072208)

![一致したテストの割合](charts/rate.ja.svg?v=20261124T072208)

## 最新の実行での変化

同じシミュレータの前回実行では一致せず今回は一致したテストと、前回は一致したものの今回は一致しなくなったテストです。スイートに追加されたテストの件数は上の表に示します。

### Icarus Verilog

新たに一致（10件）: `ch21/test_sscanf_format_from_variables`, `ch31/test_31_extra_negative_condition_args`, `ch31/test_timing_check_forms_and_arguments`, `gen/ch21/test_gen_cross_scansel_129_bit_known_bin_empty_plus_target_low_runtime`, `gen/ch21/test_gen_cross_scansel_129_logic_z_hex_long_first_minus_word_high_runtime`, `gen/ch21/test_gen_cross_scansel_1_logic_x_hex_bad_second_minus_word_low_runtime`, `gen/ch21/test_gen_cross_scansel_32_bit_known_bin_bad_second_plus_target_low_runtime`, `gen/ch21/test_gen_cross_scansel_32_logic_z_bin_empty_whole_target_low_runtime`, `gen/ch21/test_gen_cross_scansel_33_bit_known_bin_long_first_plus_target_low_runtime`, `gen/ch21/test_gen_cross_scansel_64_bit_known_bin_bad_second_whole_target_low_runtime`

### Verilator

新たに一致（1件）: `gen/ch28/test_gen_cross_gatearray_not_offset_whole_up_scalar_none_two_known`

### Lyra

新たに一致（1件）: `ch18/test_illegal_solve_before_unpacked_array`

### Ghost

一致しなくなったテスト（1件）:

- `gen/ch4/test_gen_cross_sense_comb_fnglobal_same_blocking`: 不一致 (fail) — output differs

## 章別の結果

各セルは一致数／結果登録数で、known・unsupportedも分母に含みます。[8/10の具体例](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/docs/faq.md#q12-what-percentage-does-by-chapter-show)と、[要求カバレッジとの違い](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/docs/faq.md#q15-is-the-nightly-match-rate-requirement-coverage)を確認してください。

![章別の一致テスト数](charts/chapters.ja.svg?v=20261124T072208)

## シミュレータごとの推移

![Icarus Verilog：ステータス別の結果](charts/status-icarus.ja.svg?v=20261124T072208)

![Verilator：ステータス別の結果](charts/status-verilator.ja.svg?v=20261124T072208)

![kirimasim：ステータス別の結果](charts/status-kirimasim.ja.svg?v=20261124T072208)

![Lyra：ステータス別の結果](charts/status-lyra.ja.svg?v=20261124T072208)

![Ghost：ステータス別の結果](charts/status-ghost.ja.svg?v=20261124T072208)

## 最近の実行

各シミュレータの一致したテスト数と、その前回実行からの増減です。バージョンは変更されたときに表示します。

| 実行 (UTC) | スイート | テスト数 | Icarus Verilog | Verilator | kirimasim | Lyra | Ghost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| [2026-11-24 07:22](https://github.com/kurochan001/kirimasim-tests/actions/runs/45325586796) | [`cbbd51a`](https://github.com/kurochan001/kirimasim-tests/commit/cbbd51a3258858ad65d0759ba41cb7d4b44fd540) | 16371 | 10351 (+24 −0) `14.0 devel addeab3` | 9175 (+31 −0) `5.055 devel 9dee5c5` | 13180 (+20 −0) `e93839fdc` | 13497 (+31 −0) `3a8b6c77f` | 16102 (+32 −1) `private build ddc1a7154d2d` |
| [2026-11-23 04:25](https://github.com/kurochan001/kirimasim-tests/actions/runs/45088300638) | [`c317984`](https://github.com/kurochan001/kirimasim-tests/commit/c3179844ed6b0dcb893e4e3f3f5aa45044560de5) | 16338 | 10327 (+6 −1) `14.0 devel 8a4ce42` | 9144 `5.055 devel a53cbcd` | 13160 `1d2cac97a` | 13466 (+8 −4) `12bffd35e` | 16071 (+24 −0) `private build d495d11ae498` |
| [2026-11-22 03:51](https://github.com/kurochan001/kirimasim-tests/actions/runs/44963740828) | [`8569148`](https://github.com/kurochan001/kirimasim-tests/commit/8569148236db9a89e43ebd5bd56fa5ffe904aaf1) | 16338 | 10322 `14.0 devel a225510` | 9144 `5.055 devel 005ee50` | 13160 (+17 −0) `ad004a67d` | 13462 (+19 −1) `387248dcd` | 16047 (+3 −0) `private build 1663bc821744` |
| [2026-11-21 05:35](https://github.com/kurochan001/kirimasim-tests/actions/runs/44846517415) | [`82b5713`](https://github.com/kurochan001/kirimasim-tests/commit/82b5713ffacca6048e89ffac200dd42bcca8e93a) | 16338 | 10322 (+13 −4) `14.0 devel c20d73f` | 9144 (+16 −0) `5.055 devel 9b3b1d9` | 13143 (+22 −0) `256839f71` | 13444 (+50 −0) `e17c9a53c` | 16044 (+34 −3) `private build dbabb459b24a` |
| [2026-11-20 06:49](https://github.com/kurochan001/kirimasim-tests/actions/runs/44656954132) | [`7e233e9`](https://github.com/kurochan001/kirimasim-tests/commit/7e233e9afefc1a6e975ef85ed0ea7cffddb158de) | 16298 | 10313 (+42 −3) `14.0 devel befc352` | 9128 | 13121 | 13394 | 16013 |
| [2026-11-20 06:26](https://github.com/kurochan001/kirimasim-tests/actions/runs/44656954132) | [`7e233e9`](https://github.com/kurochan001/kirimasim-tests/commit/7e233e9afefc1a6e975ef85ed0ea7cffddb158de) | 16298 | — | 9128 `5.055 devel 53a7271` | 13121 | 13394 | 16013 (+5 −0) `private build da2a4afe0dc9` |
| [2026-11-20 04:35](https://github.com/kurochan001/kirimasim-tests/actions/runs/44652861270) | [`3be3ed0`](https://github.com/kurochan001/kirimasim-tests/commit/3be3ed023e92bd9d8bd8c28f3aaa29cda54acc4d) | 16291 | 10274 (+10 −0) | 9128 (+8 −0) `5.055 devel 8dfa22d` | 13121 (+9 −0) `cb97fc93b` | 13394 (+10 −0) | 16008 (+20 −1) `private build 8afc1893d8a1` |
| [2026-11-20 01:21](https://github.com/kurochan001/kirimasim-tests/actions/runs/44631823505) | [`03b2e10`](https://github.com/kurochan001/kirimasim-tests/commit/03b2e107c60de3163952376dc1c1944f9d95f781) | 16271 | 10264 (+14 −0) `14.0 devel c717fc3` | 9120 (+11 −0) `5.055 devel 3bdc686` | 13112 (+16 −0) | 13384 (+1849 −0) `9a9813a48` | 15989 (+341 −0) `private build d72b3e26ad6a` |
| [2026-11-19 20:50](https://github.com/kurochan001/kirimasim-tests/actions/runs/44540686011) | [`68ce2bc`](https://github.com/kurochan001/kirimasim-tests/commit/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e) | 16244 | 10250 (+1466 −1) `14.0 devel 6550412` | 9109 (+830 −0) `5.055 devel 464643f` | 13096 (+1886 −0) `bd81035d9` | — | 15648 (+2361 −12) `private build 0b90acaa7ed6` |
| [2026-11-19 06:47](https://github.com/kurochan001/kirimasim-tests/actions/runs/44435742536) | [`a00ad6a`](https://github.com/kurochan001/kirimasim-tests/commit/a00ad6ad86a9a6da1bb76e7622969c35057e14b9) | 14310 | 8785 (+129 −1) `14.0 devel cf020c5` | 8279 (+324 −0) `5.055 devel b3694de` | 11210 (+314 −0) `a6222f065` | 11535 (+311 −0) `f164508a8` | — |
| [2026-11-18 05:07](https://github.com/kurochan001/kirimasim-tests/actions/runs/44217725110) | [`befffe9`](https://github.com/kurochan001/kirimasim-tests/commit/befffe9069ef17894f2559328d1b8494732917d3) | 13842 | 8657 (+3 −0) `14.0 devel ec433ed` | 7955 `5.055 devel 4c85863` | 10896 `441dddbd0` | 11224 | 13299 (+1 −0) `private build 15d7fdeeb7d9` |
| [2026-11-17 08:08](https://github.com/kurochan001/kirimasim-tests/actions/runs/44003441634) | [`77dc1f7`](https://github.com/kurochan001/kirimasim-tests/commit/77dc1f7657aab90277f65cb008524ef7bd9ae323) | 13842 | 8654 (+72 −2) `14.0 devel 98bdb3a` | 7955 (+18 −0) `5.055 devel 2d6aba6` | 10896 (+42 −0) `26f359bcd` | 11224 (+43 −0) `5d2288cdc` | 13298 (+98 −3) `private build 5a7fd8588bb0` |
| [2026-11-16 05:12](https://github.com/kurochan001/kirimasim-tests/actions/runs/43774666796) | [`9f9121f`](https://github.com/kurochan001/kirimasim-tests/commit/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a) | 13800 | 8584 (+1007 −5) `14.0 devel 32d891a` | 7937 (+986 −0) `5.055 devel 1e30e73` | 10854 (+1106 −0) `c152d237a` | 11181 (+1120 −0) `05225260a` | 13203 (+1423 −8) `private build c82f33747734` |
| [2026-11-15 06:20](https://github.com/kurochan001/kirimasim-tests/actions/runs/43651437455) | [`ed5ded9`](https://github.com/kurochan001/kirimasim-tests/commit/ed5ded9a0130470fb1e36fa46a9094a3326b0ad6) | 12630 | 7582 (+166 −4) `14.0 devel 77bb46f` | 6951 (+108 −0) `5.055 devel 9fc843a` | 9748 (+174 −0) `c3571569b` | 10061 (+193 −0) | — |
| [2026-11-14 07:31](https://github.com/kurochan001/kirimasim-tests/actions/runs/43533749064) | [`aef04b9`](https://github.com/kurochan001/kirimasim-tests/commit/aef04b93c6ebe776c598f3a40474eeea1e88dfec) | 12344 | 7420 (+53 −0) `14.0 devel 27a70c8` | 6843 (+40 −1) `5.055 devel afacb7a` | 9574 (+82 −0) `c093a2a97` | 9868 (+76 −0) `2f842a92f` | 11788 (+132 −2) `private build 17224fd34b2f` |
| [2026-11-13 06:56](https://github.com/kurochan001/kirimasim-tests/actions/runs/43338039082) | [`67d26cf`](https://github.com/kurochan001/kirimasim-tests/commit/67d26cfdbe3799438b00a2117c56689b0be5f446) | 12272 | 7367 (+7 −0) `14.0 devel c489c3a` | 6804 (+6 −13) `5.055 devel ab558b4` | 9492 (+15 −0) `614332613` | 9792 (+7 −0) | 11658 (+7 −3) `private build ace38e2ddc53` |
| [2026-11-12 08:32](https://github.com/kurochan001/kirimasim-tests/actions/runs/43135452856) | [`68f5ecc`](https://github.com/kurochan001/kirimasim-tests/commit/68f5ecc7507d6157f7944b48aa50c61fcc6fa2e1) | 12262 | 7360 (+17 −0) `14.0 devel 3c970ad` | 6811 (+11 −0) `5.055 devel 12ce860` | 9477 (+17 −0) `cae3134e4` | 9785 (+49 −1) `0d94fc7d2` | 11654 (+46 −1) `private build 909f828b22b0` |
| [2026-11-11 07:32](https://github.com/kurochan001/kirimasim-tests/actions/runs/42928672063) | [`a155aec`](https://github.com/kurochan001/kirimasim-tests/commit/a155aec8d7a87178f5abfa352286105aa5afbb58) | 12268 | 7362 (+1 −1) `14.0 devel bd5af29` | 6813 (+3 −0) `5.055 devel 18c1650` | 9479 | 9759 | 11638 (+2 −3) `private build 8d5097472bdb` |
| [2026-11-10 11:08](https://github.com/kurochan001/kirimasim-tests/actions/runs/42741584464) | [`a155aec`](https://github.com/kurochan001/kirimasim-tests/commit/a155aec8d7a87178f5abfa352286105aa5afbb58) | 12268 | 7362 (+33 −0) | 6810 (+45 −0) `5.055 devel 4ab62c3` | 9479 (+62 −0) `7de185f77` | 9759 (+85 −0) `eaaea0380` | 11639 (+407 −0) `private build edda91f4108d` |
| [2026-11-09 06:18](https://github.com/kurochan001/kirimasim-tests/actions/runs/42532762726) | [`9eab9bf`](https://github.com/kurochan001/kirimasim-tests/commit/9eab9bf2f4316112651e9637bcb03fe555016b95) | 12165 | 7329 (+23 −0) `14.0 devel 3e2189b` | 6765 (+2 −2) `5.055 devel 448e1ab` | 9417 `82b300377` | — | 11232 (+11 −1) `private build b0ba803c6b49` |
| [2026-11-08 18:32](https://github.com/kurochan001/kirimasim-tests/actions/runs/42477954992) | [`36ba5dd`](https://github.com/kurochan001/kirimasim-tests/commit/36ba5dd11df6c382c8bcfbc1ece5137a536e9fb9) | 12165 | 7306 | 6765 | 9417 | 9674 (+1235 −0) `ed6c62dc8` | 11222 |
| [2026-11-08 12:39](https://github.com/kurochan001/kirimasim-tests/actions/runs/42477954992) | [`36ba5dd`](https://github.com/kurochan001/kirimasim-tests/commit/36ba5dd11df6c382c8bcfbc1ece5137a536e9fb9) | 12165 | 7306 (+297 −5) `14.0 devel beb32f3` | 6765 (+317 −0) `5.055 devel 423f871` | 9417 (+379 −0) `33cee3fa2` | — | 11222 (+402 −1) `private build 9997c689a2e6` |
| [2026-11-08 06:25](https://github.com/kurochan001/kirimasim-tests/actions/runs/42422374691) | [`89df6e9`](https://github.com/kurochan001/kirimasim-tests/commit/89df6e9b015c88b996199997ff8cfb6eee13c63b) | 11773 | 7014 (+586 −0) `14.0 devel 66f0e8a` | 6448 (+532 −4) `5.055 devel cd99c77` | 9038 (+807 −2) `f029ddd0e` | — | 10821 (+871 −41) `private build c2138e5f3a5c` |
| [2026-11-07 06:16](https://github.com/kurochan001/kirimasim-tests/actions/runs/42313961551) | [`3c3a5ab`](https://github.com/kurochan001/kirimasim-tests/commit/3c3a5ab8cdb179aaa9d38d97990803dbc44f5cd6) | 11028 | 6428 (+19 −7) `14.0 devel 257f08d` | 5920 (+14 −3) `5.055 devel 9d9dd1c` | 8233 (+42 −0) `b279f5627` | — | 9991 (+85 −12) `private build 56cfd9e560f1` |
| [2026-11-06 05:05](https://github.com/kurochan001/kirimasim-tests/actions/runs/42136599265) | [`6732107`](https://github.com/kurochan001/kirimasim-tests/commit/673210797a4e131a47f75524b4662f93de866206) | 10994 | 6417 (+131 −0) `14.0 devel 3b5615f` | 5911 (+77 −1) `5.055 devel ab53e01` | 8191 (+216 −0) `6f5c69841` | 8440 (+225 −2) `3ee7454cc` | 9918 (+126 −1) `private build 63199c0a337a` |
| [2026-11-05 04:44](https://github.com/kurochan001/kirimasim-tests/actions/runs/41941310616) | [`19cd790`](https://github.com/kurochan001/kirimasim-tests/commit/19cd790a5f639348ad67fd63959dce9811d3ab56) | 10778 | 6286 (+36 −0) `14.0 devel 9f26050` | 5835 (+74 −6) `5.055 devel 57bbb29` | 7975 (+107 −0) `50a897dee` | 8217 (+107 −0) `ccfc8aa4f` | 9793 (+92 −0) `private build 3314f9902a64` |
| [2026-11-04 03:25](https://github.com/kurochan001/kirimasim-tests/actions/runs/41743702063) | [`9926160`](https://github.com/kurochan001/kirimasim-tests/commit/9926160a1397f514cdd09f84384392c832de2cc5) | 10672 | 6250 (+6 −0) `14.0 devel 16efc8c` | 5767 (+1 −2) `5.055 devel c0e51ca` | 7868 (+5 −0) `911395591` | 8110 `7c55e9f93` | 9701 (+0 −1) `private build 1c85ee891430` |
| [2026-11-03 16:13](https://github.com/kurochan001/kirimasim-tests/actions/runs/41650010801) | [`e8d991a`](https://github.com/kurochan001/kirimasim-tests/commit/e8d991a97b2abb12a41a1fb6b89c2406f9aa7292) | 10672 | 6244 (+36 −0) | 5768 (+66 −0) `5.055 devel a9e5a51` | 7863 (+160 −0) `d73d8922d` | 8110 (+164 −2) `fff84e924` | 9702 (+248 −2) `private build e629cbd964b4` |
| [2026-11-03 05:51](https://github.com/kurochan001/kirimasim-tests/actions/runs/41561194045) | [`9064ac9`](https://github.com/kurochan001/kirimasim-tests/commit/9064ac95375dae023c6128b1ef30ac464715009c) | 10511 | 6208 (+3 −0) | 5702 (+135 −0) `5.055 devel 094b04d` | 7703 (+28 −0) `f3ea0379a` | 7948 (+170 −1) `554db457a` | 9456 (+269 −0) `private build 3499c4a8842c` |
| [2026-11-02 15:52](https://github.com/kurochan001/kirimasim-tests/actions/runs/41454861438) | [`0afc896`](https://github.com/kurochan001/kirimasim-tests/commit/0afc89659c16a22f88c82816358e305de3f34d93) | 10289 | 6205 (+44 −0) `14.0 devel 61dbc3c` | 5567 (+119 −1) `5.055 devel 4298d7b` | 7675 (+252 −1) `2edfebbc6` | 7779 (+137 −1) `099acd527` | 9187 (+281 −2) `private build 4d414f2efa2c` |

## ファイル

- `history.json`: 実行ごとに1件の記録。各シミュレータのステータス別・章別の件数と、結果が変わったテストを保存します。
- `latest/<simulator>.json`: 各シミュレータの最新実行における全テストの結果。次回実行の比較元になります。
- `latest/previous/<simulator>.json`: 最新の1つ前の実行。最新の実行を再実行したときの比較元になります。
- `charts/*.svg`: 上記の図。日本語版は `.ja.svg`、英語版は `.svg` です。
