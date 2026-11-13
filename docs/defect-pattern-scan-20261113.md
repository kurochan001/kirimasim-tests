<a id="defect-pattern-scan-2026-11-13"></a>

# 見直しで見つかった欠陥の型の全体検索（2026-11-13）

[English](defect-pattern-scan-20261113.en.md) / [日本語](defect-pattern-scan-20261113.md)

Ghostだけが一致するテストの見直し（[37章](ghost-only-review-ch37-20261113.md)、[36・38・39・40章](ghost-only-review-vpi-20261113.md)、[残りの章](ghost-only-review-rest-20261113.md)）で、ほかのテストにもありそうな欠陥の型が3つ見つかりました。
その3つを、テスト全体で探した結果です。
判定は規格だけから行い、シミュレータの出力は使っていません。
この検索では、テストを変えていません。

<a id="method"></a>

## 方法

- 型1と型2は、テストのCファイル626本を、保存しないスクリプトで機械的に探しました。見つかった箇所は、すべて私がコードを読んで確かめました。
- 型3は、タイミングチェックを含むシミュレーションのテスト63本が対象です。そのうちGhostだけが一致する31章・32章の42本は、見直しの中で時刻0の変化も確かめました。残りの21本（Ghostだけが一致する31章・32章以外の7本と、ほかの14本）を、1つのAIレビューが時刻0の変化に絞って読みました。
- どの確認もAIによるものです。人による独立したレビューではありません。

<a id="pattern-1"></a>

## 型1：`vpi_get_str`の結果を2つ同時に使う

38.11では、`vpi_get_str`の文字列は、どの呼び出しでも同じ一時バッファに入ります。そのため、結果を2つ、1回の呼び出しの引数にすると、表示される文字列が規格からは決まりません。

- 機械的な検索では、27ファイルの34か所が候補になりました。ほとんどは、`vpi_get_str(…) ? vpi_get_str(…) : "…"`のように、1つ目の結果をNULLの確認にだけ使う形か、すぐに文字列を複写する補助関数を通す形で、問題はありません。
- ポインタを保存してから次の呼び出しのあとで使う形の候補（9ファイルの10か所）も、すべて問題がありませんでした。`ch38/test_vpi_string_buffers`は、共有されるバッファそのものを確かめるテストです。
- 欠陥があるのは、次の6本です。37章の見直しの記録にあった「37章のCファイル29本」という粗い検索の数は、この6本に置き換わります。

| テスト | 状況 |
|---|---|
| `ch37/test_vpi_class_internal_scopes` | 37章の見直しで記録済み |
| `ch37/test_vpi_frame_automatics_thread` | 37章の見直しで記録済み |
| `ch37/test_vpi_interconnect_net_typespec` | 37章の見直しで記録済み |
| `ch37/test_vpi_io_direction_undefined` | 37章の見直しで記録済み |
| `ch37/test_vpi_local_connectivity_ports` | 37章の見直しで記録済み |
| `ch37/test_vpi_struct_and_tagged_patterns` | 新たに見つかったもの。いまはどのシミュレータでも一致しません |

<a id="pattern-2"></a>

## 型2：起動時の関数で認められていないことをする

36.10.2では、`vlog_startup_routines`の関数から呼べるのは`vpi_register_systf`と`vpi_register_cb`だけで、登録できるコールバックの理由も6つに限られます。

- 欠陥があるのは、次の16本です。10本は36・38・39・40章の見直しで記録済みです。

| テスト | 内容 | 状況 |
|---|---|---|
| `ch36/test_vpi_compatibility_h_1364v1995`、`_1364v2001`、`_1364v2005`、`_1800v2005`、`_1800v2009`、`_1800v2012`（6本） | `vpi_printf`を呼びます | 記録済み |
| `ch38/test_vpi_array_get_errors`、`ch38/test_vpi_array_put_formats`、`ch38/test_vpi_net_array_deposit`（3本） | `cbAfterDelay`を登録します | 記録済み |
| `ch39/test_vpi_assertion_system_control` | `cbAssertionSys…`を登録します | 記録済み |
| `ch36/test_vpi_compatibility_1800v2017_mode`、`ch36/test_vpi_compatibility_1800v2023_mode`（2本） | `vpi_printf`などを呼びます | 新たに見つかったもの。いまはどのシミュレータでも一致しません |
| `ch20/test_assertcontrol_callbacks_system` | `cbAssertionSys…`を登録します | 新たに見つかったもの。いまはどのシミュレータでも一致しません |
| `ch38/test_vpi_array_get_formats`、`ch38/test_vpi_get_array_static`（2本） | `cbAfterDelay`を登録します | 新たに見つかったもの。VerilatorとGhostで一致します |
| `ch38/test_vpi_release_remove_signatures` | `cbAfterDelay`を登録します | 新たに見つかったもの。IcarusとGhostで一致します |

- 次のものは欠陥に数えていません。`ch36/test_vpi_end_of_simulation_after_final`などは、登録に失敗したときだけ`vpi_printf`を呼び、期待値には関わりません。`ch38/test_vpi_startup_routines_null_end`の`vpi_printf`は、配列のNULLのあとにある呼ばれない関数の中にあり、それを確かめるのがこのテストです。

<a id="pattern-3"></a>

## 型3：時刻0の変化でタイミングチェックの結果が変わる

時刻0に、ポートのネットはzから値に変わります（6.7.1、4.9.1、4.9.6）。その変化がタイミングチェックの基準や違反になると、表示が変わることがあります。

- 確かめた21本は、どれも時刻0の変化で表示が変わりません。時刻0の変化が、チェックが待つ向きのエッジでないか、変化があっても表示に届かないためです。
- テスト全体で欠陥があるのは、残りの章の見直しで記録した`ch31/test_timing_edge_descriptors_all`と`ch32/test_sdf_tchk_edge_condition_match`の2本だけです。

<a id="next"></a>

## このあとの扱い

- 新たに見つかった7本（型1の1本と型2の6本）は、Ghostだけが一致するテストではありません。ほかの欠陥と同じく、次にGhostの結果を保存し直すときに直します。そのうち3本は、IcarusかVerilatorの結果も変わります。
- Ghostだけが一致するテストの見直しの数字は変わりません。カバレッジの数字も変わりません。
