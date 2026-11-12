<a id="ghost-only-review-vpi-2026-11-13"></a>

# Ghostだけが一致するテストの見直し：36・38・39・40章（2026-11-13）

[English](ghost-only-review-vpi-20261113.en.md) / [日本語](ghost-only-review-vpi-20261113.md)

Ghostだけが期待値と一致するテストのうち、36章（PLI/VPIの概要）、38章（VPIのルーチン）、39章（アサーションAPI）、40章（カバレッジAPI）の141本を、IEEE 1800-2023と照らした結果です。
方法は[37章の見直し](ghost-only-review-ch37-20261113.md)と同じです。
期待値は規格だけから判定し、シミュレータの出力は判定に使っていません。
この見直しでは、テストを変えていません。

<a id="what-was-reviewed"></a>

## 見直した対象

- 2026-11-12のNightlyで、Ghostだけが一致するテストは、36章が28本、38章が41本、39章が37本、40章が35本です。
- 二つのレビューが、互いの結果を見ずに、141本すべてを読みました。判定が違うテストは、規格の文、表、図で決めました。
- どのレビューもAIによるものです。人による独立したレビューではありません。

<a id="verdicts"></a>

## 判定

| 判定 | 本数 |
|---|---:|
| 期待値は正しい | 108 |
| 期待値が誤っている | 3 |
| テストに欠陥がある | 19 |
| 読み方が割れる | 11 |
| 合計 | 141 |

二つのレビューは、105本で「正しい」と一致しました。

<a id="wrong"></a>

## 期待値が誤っている3本

| テスト | 節 | 内容 |
|---|---|---|
| `ch39/test_vpi_assertion_system_task_control` | 20.11、39.4.2 | 引数付きの`$assertkill`に、`cbAssertionKill`のコールバックを期待しています。20.11の表20-8は、この場合のコールバックを`cbAssertionReset`と`cbAssertionDisable`としています。時刻36の行はdisableになります。 |
| `ch40/test_coverage_control_interface_scope` | 40.3.2.1、40.3.2.2 | インスタンスの階層パスを文字列で渡しています。表40-2の注記では、文字列は定義名で、インスタンスは階層パスで示します。その名前の定義はないので、結果は`SV_COV_ERROR`と-1で、2行とも0になります。 |
| `ch40/test_coverage_control_program_scope` | 40.3.2.1、40.3.2.2 | 同じく、プログラムのインスタンスのパスを文字列で渡しています。2行とも0になります。 |

<a id="flawed"></a>

## 欠陥がある19本

| テスト | 節 | 内容 |
|---|---|---|
| `ch36/test_vpi_compatibility_h_1364v1995`、`_1364v2001`、`_1364v2005`、`_1800v2005`、`_1800v2009`、`_1800v2012`（6本） | 36.10.2 | `vlog_startup_routines`の関数の中で`vpi_printf`を呼んでいます。36.10.2では、この段階で呼べるのは`vpi_register_systf`と`vpi_register_cb`だけです。表示する内容は附属書Lのとおりです。 |
| `ch38/test_vpi_array_get_errors`、`ch38/test_vpi_array_put_formats`、`ch38/test_vpi_net_array_deposit`（3本） | 36.10.2 | 起動時の関数から`cbAfterDelay`を登録しています。36.10.2が起動時に認める理由は6つだけで、`cbAfterDelay`は含まれません。値は38.16と38.35のとおりです。 |
| `ch39/test_vpi_assertion_system_control` | 36.10.2、39.4.1 | 起動時の関数から`cbAssertionSys…`のコールバックを登録しています。これも36.10.2の6つに含まれません。 |
| `ch38/test_vpi_callback_registration_errors` | 38.36.1 | `cbForce`を、値の構造体を指定せずに登録しています。38.36.1は値の形式の指定を求めるので、ビット選択の登録が拒否された理由を区別できません。 |
| `ch38/test_vpi_put_value_delay_modes` | 38.34、4.7 | 同じ時刻に複数の値が更新され、1つのalwaysブロックがそれを表示します。更新とブロックの実行の順序は決まらないので、途中の値の行が増えても規格に沿います。 |
| `ch38/test_vpi_stmt_callback_kinds` | 37.12、38.36.1.1 | 文を、`vpiStmt`の反復で返る順番で見分けています。規格はこの順序を定めていません（軽微）。 |
| `ch39/test_vpi_assertion_kill_keeps_past_sampling` | 39.4.2 | コールバックの時刻を、時刻の型を確かめずに整数として読んでいます。39.4.2は型を定めていません。同じ章のほかのテストは型を確かめています。 |
| `ch40/test_coverage_reset_and_stop` | 40.2.2、40.3.2.1 | リセットの直後、測定範囲の中の変数`r`が0から1に変わってから読んでいます。そのビットを数えるかどうかは決まりません。 |
| `ch40/test_coverage_save_merge` | 40.2.2、40.3.2.5 | 2回の読出しの間に、測定範囲の中の変数`cov_before`と`saved`が変わります。保存の前後で値が同じとは限りません。 |
| `ch40/test_coverage_scope_sums` | 40.2.2、40.3.2.3 | 最上位のモジュールとその階層を別々の文で読みます。その文と変数自身が、間でカバレッジを変えます。 |
| `ch40/test_coverage_uninstantiated_module` | 23.3.1、40.3.2.1 | どこからも実体化されないモジュールは、23.3.1では最上位モジュールで、暗黙に1つ実体化されます。「インスタンスがない」ことは、ツールの最上位の指定に依存します。 |
| `ch40/test_coverage_get_status_and_relations` | 40.2.1、40.3.2.2 | カバレッジの種類99を不正な引数と期待しています。40.2.1はベンダーが種類を追加できるとしています（軽微）。 |

<a id="contested"></a>

## 読み方が割れる11本

| テスト | 節 | 割れる点 |
|---|---|---|
| `ch36/test_vpi_chk_error_callbacks` | 38.36.2 | 誤りのある登録が`NULL`を返すことを、38.36.2は述べていません。エラーになることは決まっています。 |
| `ch36/test_vpi_compiletf_sizetf` | 36.10.2、38.37.1 | compiletfが`cbEndOfCompile`より前に呼ばれることを、36.10.2は明示していません。 |
| `ch38/test_vpi_error_callback_runtime_errors` | 38.36.3、20.10 | `$error`が`cbError`を起こすかどうかを、38.36.3は述べていません。20.10は実行時エラーと呼んでいます。 |
| `ch38/test_vpi_get_value_array` | 38.16、38.15 | `logic [7:0]`の要素を`vpiIntVal`で読めるかどうかが割れます。38.16は、要素の型に合わない形式をエラーとしています。 |
| `ch38/test_vpi_get_value_real_conversion` | 38.15 | 実数の文字列の「16桁の精度」が、有効数字か小数点以下の桁数かが割れます。 |
| `ch38/test_vpi_mcd_open_reuse` | 38.25 | ファイルのないチャネルのflushが失敗かどうかを、38.25は述べていません。ほかの5行は正しいです。 |
| `ch38/test_vpi_value_change_event` | 38.36.1、37.27 | named eventのオブジェクトに`cbValueChange`を置いています。38.36.1が述べるのはevent文です。 |
| `ch39/test_vpi_assertion_reset_restores_initial_state` | 39.5.2 | リセットで戻る「初期状態」が、有効・無効やアクションの設定を含むかどうかが割れます。 |
| `ch40/test_coverage_control_package_scope` | 40.3.2.1、40.5.3 | パッケージ名の文字列を範囲に渡しています。40.3.2.1が述べるのはモジュールの定義名だけで、その読み方では誤りです。40.5.3からはパッケージも範囲になると読めます。 |
| `ch40/test_coverage_fsm_next_state_pragmas` | 40.4、40.4.5 | プラグマが、プラグマのない信号の自動抽出まで止めるかどうかで、最大値5が変わります。 |
| `ch40/test_vpi_coverage_save_merge` | 38.4、40.5.3 | 保存していない名前のマージで`vpi_control`が返す値が、0（38.4）か-1（40.5.3）かが割れます。 |

<a id="figures"></a>

## 図で確かめたこと

- `ch38/test_vpi_intermod_path_levels`：37.37の図で、inter mod pathからportsへ二重矢印があります。`vpiPort`で反復でき、期待値は正しいです。
- `ch39/test_vpi_assertion_handles`：37.49の図で、assertionからinstanceへ矢印があります。期待値は正しいです。

<a id="next"></a>

## このあとの扱い

- 誤りの3本と欠陥の19本は、次にGhostの結果を保存し直すときに直します。
- 読み方が割れる11本は、判断を待ちます。
- 起動時の関数から36.10.2が認めないルーチンや理由を使うCコードは、Ghost以外でも一致しているテストにもありえます。次の見直しで全体を検索します。
- カバレッジの数字は変わりません。
