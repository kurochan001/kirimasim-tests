"""Audited interaction profiles, including existing scheduling test witnesses.

No keyword scan is used to infer coverage. A profile's generator defines the
stimulus, observation and independent expected output for that exact row.
"""

from dataclasses import dataclass
from typing import Callable

import interaction_nba
import interaction_expr
import interaction_select
import interaction_cond
import interaction_shift
import interaction_cast
import interaction_task
import interaction_binding
import interaction_struct
import interaction_case
import interaction_port
import interaction_array
import interaction_query
import interaction_stream
import interaction_compare
import interaction_method
import interaction_index
import interaction_queue
import interaction_queue_ref
import interaction_divide
import interaction_resize
import interaction_concat
import interaction_logic
import interaction_shortcircuit
import interaction_edge
import interaction_iff
import interaction_clocking
import interaction_assertion
import interaction_wait
import interaction_class_method
import interaction_return
import interaction_loop_nba
import interaction_process
import interaction_generate
import interaction_default
import interaction_event_task
import interaction_delay
import interaction_import
import interaction_memfile
import interaction_program
import interaction_nettype
import interaction_ifgenerate
import interaction_reactive
import interaction_config
import interaction_udp
import interaction_udpstate
import interaction_ifimport
import interaction_mailbox
import interaction_event_rebind
import interaction_dpi_nba
import interaction_constraint
import interaction_clockassert
import interaction_dpi_array
import interaction_class_array
import interaction_strengthfmt
import interaction_vif_class
import interaction_clockiff
import interaction_assocquery
import interaction_randreduce
import interaction_gendisable
import interaction_dist
import interaction_eventlife
import interaction_dpiquery
import interaction_sdfpath
import interaction_checksample
import interaction_progassert
import interaction_cgsample
import interaction_deferdis
import interaction_clockevent
import interaction_deferarg
import interaction_compound
import interaction_inside
import interaction_range
import interaction_case_inside
import combination_monitors
import scheduling
from interaction_cover import Model, Row

GENERATORS = (scheduling, interaction_nba, interaction_expr, interaction_select, interaction_cond,
              interaction_shift, interaction_cast, interaction_task, interaction_binding,
              interaction_struct, interaction_case, interaction_port,
              interaction_array, interaction_query, interaction_stream,
              interaction_compare, interaction_method,
              interaction_index, interaction_queue, interaction_queue_ref,
              interaction_divide, interaction_resize,
              interaction_concat, interaction_logic,
              interaction_shortcircuit, interaction_edge, interaction_iff, combination_monitors,
              interaction_clocking,
              interaction_assertion, interaction_wait, interaction_class_method, interaction_return,
              interaction_loop_nba, interaction_process, interaction_generate, interaction_default,
              interaction_event_task,
              interaction_delay,
              interaction_import,
              interaction_memfile,
              interaction_program,
              interaction_nettype,
              interaction_ifgenerate,
              interaction_reactive,
              interaction_config,
              interaction_udp,
              interaction_udpstate,
              interaction_ifimport,
              interaction_mailbox,
              interaction_event_rebind, interaction_dpi_nba, interaction_constraint, interaction_clockassert, interaction_dpi_array, interaction_class_array, interaction_strengthfmt, interaction_vif_class, interaction_clockiff, interaction_assocquery, interaction_randreduce,
              interaction_gendisable, interaction_dist, interaction_eventlife, interaction_dpiquery, interaction_sdfpath, interaction_checksample, interaction_progassert, interaction_cgsample, interaction_deferdis, interaction_compound, interaction_inside, interaction_range,
              interaction_case_inside, interaction_clockevent, interaction_deferarg)


@dataclass
class SuiteModel:
    model: Model
    path: Callable[[Row], str]
    available: tuple[Row, ...]
    witness: str


def registered() -> tuple[SuiteModel, ...]:
    schedule = Model(
        "scheduling_visibility",
        (("writer", tuple(scheduling.WRITERS)), ("reader", tuple(scheduling.READERS)),
         ("home", tuple(scheduling.CONTAINERS)), ("delay", tuple(scheduling.DELAYS))),
        lambda row: scheduling.allowed(*row),
        groups=(("writer", "reader", "delay"),),
        constraints=("既存のscheduling.allowedに従い、観測結果が定まらない組合せや"
                     "関数内の遅延付きNBAなどを除外。シミュレータの未対応による除外はしない",),
    )
    return (
        SuiteModel(
            schedule, lambda row: "tests/gen/ch4/test_gen_sched_" + "_".join(row) + ".sv",
            schedule.rows(),
            "既存の8ビットの書き込みを、書き込み元・待機中の別プロセス・strobe・monitorから"
            "指定の時刻とイベント領域で観測する。既存の生成テストと期待値は変更しない。",
        ),
        SuiteModel(
            interaction_nba.MODEL,
            lambda row: "tests/gen/ch10/" + interaction_nba.case_name(row) + ".sv",
            interaction_nba.MODEL.select(),
            "代入直後・刺激変更後・時刻1・最終結果の出力で、値と代入先の確定、隣接要素の保持、"
            "Active領域とNBA領域の順序、automaticタスクからの復帰後の更新を確認する。",
        ),
        SuiteModel(
            interaction_expr.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_expr.case_name(row) + ".sv",
            interaction_expr.MODEL.select(),
            "4組の入力で加減乗算の結果を確認する。演算前の符号・ゼロ拡張、"
            "代入先からの幅の伝播、キャリー、最終的な切り捨てを組み合わせる。",
        ),
        SuiteModel(
            interaction_select.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_select.case_name(row) + ".sv",
            interaction_select.MODEL.select(),
            "部分選択への書き込み前後にベクタ全体と選択範囲を表示し、添字方向・"
            "選択方向・X/Z変換に加え、選択していないビットの保持も確認する。",
        ),
        SuiteModel(
            interaction_cond.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_cond.case_name(row) + ".sv",
            interaction_cond.MODEL.select(),
            "両分岐の入力と条件演算の結果を表示し、分岐選択・X/Zのビットごとの結合・"
            "符号拡張・代入先の幅と2状態変換を一連の式で確認する。",
        ),
        SuiteModel(
            interaction_shift.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_shift.case_name(row) + ".sv",
            interaction_shift.MODEL.select(),
            "シフト前の値・シフト量・結果を表示し、代入先から伝わる幅、符号付きの埋め込み、"
            "X/Zの移動、未知のシフト量、最後の2状態変換を確認する。",
        ),
        SuiteModel(
            interaction_cast.MODEL,
            lambda row: "tests/gen/ch6/" + interaction_cast.case_name(row) + ".sv",
            interaction_cast.MODEL.select(),
            "元の値・キャスト直後の値・後続演算の結果を分けて表示し、キャストの幅と符号、"
            "演算前のX/Z変換、外側の代入コンテキストと最終変換の順序を確認する。",
        ),
        SuiteModel(
            interaction_task.MODEL,
            lambda row: "tests/gen/ch13/" + interaction_task.case_name(row) + ".sv",
            interaction_task.MODEL.select(),
            "タスク内部・復帰直前・復帰後から実引数を観測し、コピー渡しと参照渡しの"
            "更新時点の違い、値と隣接要素の保持を確認する。",
        ),
        SuiteModel(
            interaction_binding.MODEL,
            lambda row: "tests/gen/ch13/" + interaction_binding.case_name(row) + ".sv",
            interaction_binding.MODEL.select(),
            "呼出し後に添字を同値・次要素・-1へ変更し、実引数と仮引数の複数時刻の値を観測して、"
            "元の要素への結合、inputの値コピー、refの双方向の可視性、const refのライブな読取り、"
            "復帰時の書戻しや隣接要素の破壊がないことを確認する。",
        ),
        SuiteModel(
            interaction_struct.MODEL,
            lambda row: "tests/gen/ch7/" + interaction_struct.case_name(row) + ".sv",
            interaction_struct.MODEL.select(),
            "構造体の全ビット・payload・tagと、メンバ／全体の拡張結果を観測し、"
            "配置、更新領域、NBAの値の確定、各式の符号属性を確認する。",
        ),
        SuiteModel(
            interaction_case.MODEL,
            lambda row: "tests/gen/ch12/" + interaction_case.case_name(row) + ".sv",
            interaction_case.MODEL.select(),
            "セレクタと項目値を表示し、重複項目とフォールバック項目の2回の分岐結果から、"
            "幅・符号の統一、X/Zの扱い、最初に一致した項目の優先を確認する。",
        ),
        SuiteModel(
            interaction_port.MODEL,
            lambda row: "tests/gen/ch23/" + interaction_port.case_name(row) + ".sv",
            interaction_port.MODEL.select(),
            "親と子の間で幅が変わる接続を使い、元の値・4状態の接続線・サンプル変数を観測して、"
            "接続方向、駆動元の符号、宣言と接続形式、最後の2状態変換を確認する。",
        ),
        SuiteModel(
            interaction_array.MODEL,
            lambda row: "tests/gen/ch7/" + interaction_array.case_name(row) + ".sv",
            interaction_array.MODEL.select(),
            "2組の入力を配列全体／スライスへコピーし、宣言順の対応、非選択要素の保持、"
            "コピー元変更後の独立性と、読み出した要素の符号拡張を確認する。",
        ),
        SuiteModel(
            interaction_query.MODEL,
            lambda row: "tests/gen/ch20/" + interaction_query.case_name(row) + ".sv",
            interaction_query.MODEL.select(),
            "引数の実ビット列・幅と各関数の結果を表示し、式の形、状態変換、X/Zの位置、"
            "制御ビットの重複除去、one-hot判定と未知値の有無を確認する。",
        ),
        SuiteModel(
            interaction_stream.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_stream.case_name(row) + ".sv",
            interaction_stream.MODEL.select(),
            "入力ストリームと結果を比較し、ブロック順、端数ブロック、複数項目の連結、"
            "packとunpackの逆変換、2状態の格納先への変換を確認する。",
        ),
        SuiteModel(
            interaction_compare.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_compare.case_name(row) + ".sv",
            interaction_compare.MODEL.select(),
            "4組の入力で幅・符号の統一、未知値と既知の不一致、右辺だけのワイルドカードを"
            "確認し、1ビットの比較結果を広いlogic/bitへ直接代入して変換順序を観測する。",
        ),
        SuiteModel(
            interaction_method.MODEL,
            lambda row: "tests/gen/ch7/" + interaction_method.case_name(row) + ".sv",
            interaction_method.MODEL.select(),
            "固定長配列・動的配列・キューの集計を2組の背景値で観測し、with式による要素の"
            "型変換、戻り値の幅、オーバーフロー、X/Z伝播と呼出し後の拡張を確認する。",
        ),
        SuiteModel(
            interaction_index.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_index.case_name(row) + ".sv",
            interaction_index.MODEL.select(),
            "可変インデックスのビット列と書き込み前後の全ビットを観測し、添字の符号、"
            "範囲の始点と向き、無効な読み取りの既定値、無効な書き込み時の保持を確認する。",
        ),
        SuiteModel(
            interaction_queue.MODEL,
            lambda row: "tests/gen/ch7/" + interaction_queue.case_name(row) + ".sv",
            interaction_queue.MODEL.select(),
            "2組の入力でサイズと全要素、取り出した値、操作前のコピーを観測し、"
            "追加位置と容量による破棄、空の既定値、型変換、値コピーの独立性を確認する。",
        ),
        SuiteModel(
            interaction_queue_ref.MODEL,
            lambda row: "tests/gen/ch7/" + interaction_queue_ref.case_name(row) + ".sv",
            interaction_queue_ref.MODEL.select(),
            "3組の入力で保持中の参照値・変更後の全要素・2回の書込み後・値コピーを観測し、"
            "要素の移動後の同一性、削除・全体代入後の古い参照の存続と書込みの分離、"
            "容量超過での末尾要素の破棄、bit/logicの引数変換を確認する。",
        ),
        SuiteModel(
            interaction_divide.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_divide.case_name(row) + ".sv",
            interaction_divide.MODEL.select(),
            "両オペランドと演算結果を観測し、演算前の幅・符号の統一、商の0方向への丸め、"
            "剰余の符号、ゼロ除算とX/Zの伝播、最終的な2状態変換を確認する。",
        ),
        SuiteModel(
            interaction_resize.MODEL,
            lambda row: "tests/gen/ch7/" + interaction_resize.case_name(row) + ".sv",
            interaction_resize.MODEL.select(),
            "再確保前後のサイズと全要素を観測し、別配列コピー・自己リサイズ・初期化式なしの"
            "再生成、切り詰め、追加領域の型別既定値、コピー後の独立性を確認する。",
        ),
        SuiteModel(
            interaction_concat.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_concat.case_name(row) + ".sv",
            interaction_concat.MODEL.select(),
            "2組の既知入力とX/Zの入力で、連結全体への拡張と分割、各項の状態変換、"
            "即時更新とNBAの値確定、各項と連結を読み出す際の符号の違いを確認する。",
        ),
        SuiteModel(
            interaction_logic.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_logic.case_name(row) + ".sv",
            interaction_logic.MODEL.select(),
            "各行で全6リダクションと論理否定の入力・実際の式・結果を観測し、支配値とX/Z、"
            "演算前後の状態変換、1ビットunsigned結果の拡張、入力の自己決定幅を確認する。",
        ),
        SuiteModel(
            interaction_shortcircuit.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_shortcircuit.case_name(row) + ".sv",
            interaction_shortcircuit.MODEL.select(),
            "4演算ごとに左右の関数の呼出し回数・観測値・独立した副作用を表示し、短絡による"
            "右辺の評価抑止、未知値の真偽変換、結果と最終格納先の状態変換を確認する。",
        ),
        SuiteModel(
            interaction_edge.MODEL,
            lambda row: "tests/gen/ch9/" + interaction_edge.case_name(row) + ".sv",
            interaction_edge.MODEL.select(),
            "両背景で初期イベントを除外し、更新直後の値と次時刻の3カウンタを観測して、"
            "X/Z遷移、式の変化、ベクタのLSB規則、状態変換、NBAの更新時点を確認する。",
        ),
        SuiteModel(
            interaction_iff.MODEL,
            lambda row: "tests/gen/ch9/" + interaction_iff.case_name(row) + ".sv",
            interaction_iff.MODEL.select(),
            "独立した左右のイベント数と条件付きORの起床数、条件だけを変えた後の保持を観測し、"
            "iffの項ごとの結合、orとカンマの同義性、名前付きイベントの再発火、"
            "X/Zを含む条件の真偽、ブロッキング/NBAの更新時点を確認する。",
        ),
        SuiteModel(
            combination_monitors.MODEL,
            lambda row: "tests/gen/ch21/" + combination_monitors.case_name(row) + ".sv",
            combination_monitors.MODEL.select(),
            "9種類の登録場所と2種類のコンテナ・記述子を組み合わせ、ファイルを読み戻して、"
            "Postponedの最終値、非選択要素、選択・置換、monitoroff、閉鎖後の出力抑止を確認する。",
        ),
        SuiteModel(
            interaction_compound.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_compound.case_name(row) + ".sv",
            interaction_compound.MODEL.select(),
            "複合シフト代入の前後にスカラ・配列全要素・親ベクタ・拡張値と添字関数の回数を"
            "観測し、左辺の1回評価、部分選択の符号、シフト量の独立した幅と型変換を確認する。",
        ),
        SuiteModel(
            interaction_inside.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_inside.case_name(row) + ".sv",
            interaction_inside.MODEL.select(),
            "個別列挙・固定配列・動的配列・キューの要素とサイズ、異なる幅・符号の入力、"
            "生の判定値・拡張・bit変換・逆順リストを観測し、片側ワイルドカードとORを確認する。",
        ),
        SuiteModel(
            interaction_range.MODEL,
            lambda row: "tests/gen/ch11/" + interaction_range.case_name(row) + ".sv",
            interaction_range.MODEL.select(),
            "閉区間・逆順・$端点・絶対/相対許容差の範囲で、端点の格納値、各端点の前後の入力、"
            "生の判定値・拡張・bit変換と関係演算子での同じ判定を観測し、範囲の比較と"
            "集合値のワイルドカードの違い、許容差の端点の入れ替えと切り捨てを確認する。",
        ),
        SuiteModel(
            interaction_case_inside.MODEL,
            lambda row: "tests/gen/ch12/" + interaction_case_inside.case_name(row) + ".sv",
            interaction_case_inside.MODEL.select(),
            "値・範囲・固定配列・2値のリストを先頭項目にしたcase insideで、各項目とdefaultを"
            "狙う4組のケース式、格納後の項目値、選ばれた分岐、ケース式と数える項目の評価回数を"
            "観測し、Xの比較を不一致として後続へ進むこと、端点の拡張、unique0の評価を確認する。",
        ),
        SuiteModel(
            interaction_clocking.MODEL,
            lambda row: "tests/gen/ch14/" + interaction_clocking.case_name(row) + ".sv",
            interaction_clocking.MODEL.select(),
            "3組の背景値でクロック前の値と更新後の値、cbでのサンプルとライブ値、起床回数を観測し、"
            "#1step/#0、blocking/NBA、状態型、クロック方向とlocal/interface/virtual modportの"
            "参照経路の相互作用を確認する。X/Z行にも既知値の対照を保持する。",
        ),
        SuiteModel(
            interaction_assertion.MODEL,
            lambda row: "tests/gen/ch16/" + interaction_assertion.case_name(row) + ".sv",
            interaction_assertion.MODEL.select(),
            "更新前後の既知値とX/Zで、assertionのpass/fail回数、サンプル値と1ビットの式の値、"
            "Reactiveのライブ値と最終値を観測する。型、式、エッジ、blocking/NBA、"
            "更新時点、module/interfaceを組み合わせ、サンプリング時点とaction実行時点を区別する。",
        ),
        SuiteModel(
            interaction_wait.MODEL,
            lambda row: "tests/gen/ch9/" + interaction_wait.case_name(row) + ".sv",
            interaction_wait.MODEL.select(),
            "サイズ・先頭要素・両条件を待ち、動的配列とキューの作成・拡大・縮小・削除・"
            "同サイズ置換の前後で起床時刻・回数と全要素を観測する。無関係なコンテナ変更での"
            "早期起床を区別し、既に真の場合と、型変換後のX/Zをcase等価で待つ場合も確認する。",
        ),
        SuiteModel(
            interaction_class_method.MODEL,
            lambda row: "tests/gen/ch8/" + interaction_class_method.case_name(row) + ".sv",
            interaction_class_method.MODEL.select(),
            "2個の派生インスタンスをA/B/A順に呼び、virtual/非virtualの実行本体と所有者、"
            "再帰の入口・出口の仮引数とプロパティ、戻り値・カウンタ・ガードを観測する。"
            "inputのフレーム別コピーとref/const refの同一実体への参照、2状態変換を確認する。",
        ),
        SuiteModel(
            interaction_return.MODEL,
            lambda row: "tests/gen/ch13/" + interaction_return.case_name(row) + ".sv",
            interaction_return.MODEL.select(),
            "for/while/repeat内で最初の非0ビットからreturnし、戻り値・走査回数と添字の総和・"
            "末尾到達・return後の副作用を観測する。A/B/A呼出しでインスタンス別状態と"
            "packageの共有状態、呼出し元の同名変数の保持、X/Zの2状態変換も確認する。",
        ),
        SuiteModel(
            interaction_loop_nba.MODEL,
            lambda row: "tests/gen/ch10/" + interaction_loop_nba.case_name(row) + ".sv",
            interaction_loop_nba.MODEL.select(),
            "for/while/repeat内の複数代入で、途中結果を使うblockingと旧値からNBAを予約する動作を"
            "区別する。A/B/A呼出しの各反復の値・添字、ActiveとNBA後の全要素・カウンタ・"
            "ガードを観測し、書込み順序、状態変換、module/interfaceの独立した格納先を確認する。",
        ),
        SuiteModel(
            interaction_process.MODEL,
            lambda row: "tests/gen/ch9/" + interaction_process.case_name(row) + ".sv",
            interaction_process.MODEL.select(),
            "宣言時初期値による時刻0の起動、data/maskと関数内部の読取りによる再実行、"
            "0/X/Zでのcombの既定値とlatchの保持を観測する。1変数ずつ変更して両インスタンスの"
            "出力・評価回数を確認し、無関係なnoiseと自己更新による余分な起動も区別する。",
        ),
        SuiteModel(
            interaction_generate.MODEL,
            lambda row: "tests/gen/ch27/" + interaction_generate.case_name(row) + ".sv",
            interaction_generate.MODEL.select(),
            "2インスタンスのgenerate要素を階層名で読み、選択分岐・局所宣言・genvar定数・"
            "型幅・package定数と連続代入の値を観測する。importと明示修飾、入れ子、"
            "型と定数の隠蔽、X/Zを含む入力変更への追従と各スコープの独立性を確認する。",
        ),
        SuiteModel(
            interaction_default.MODEL,
            lambda row: "tests/gen/ch13/" + interaction_default.case_name(row) + ".sv",
            interaction_default.MODEL.select(),
            "A/B/Aの階層呼出しで既定値の元を毎回変え、両仮引数・戻り値と宣言側/呼出し元の"
            "関数評価回数を観測する。省略・空欄・名前付き・明示0での評価抑止、呼出し時の"
            "宣言スコープへの束縛、型変換とmodule/interfaceの各インスタンスの独立性を確認する。",
        ),
        SuiteModel(
            interaction_event_task.MODEL,
            lambda row: "tests/gen/ch15/" + interaction_event_task.case_name(row) + ".sv",
            interaction_event_task.MODEL.select(),
            "module/interfaceの別インスタンスまたはpackageの2イベントをinput/refで渡し、"
            "1/2/3待機者の時刻・回数・値を観測する。待機前のトリガの不保持、通常/NBA起床の"
            "値の可視性、トリガ経路、逆順での再待機、noiseと完了後の余計な起動を区別する。",
        ),
        SuiteModel(
            interaction_delay.MODEL,
            lambda row: "tests/gen/ch10/" + interaction_delay.case_name(row) + ".sv",
            interaction_delay.MODEL.select(),
            "幅1のスカラと幅2以上のベクタで1/2/3個の遅延を使い、短パルスの除去と予約の取消しを観測する。"
            "bit/logic格納と反転後の値、X/Zの遅延選択、全体値の更新時刻・回数・最終変化時刻を毎tick照合する。",
        ),
        SuiteModel(
            interaction_import.MODEL,
            lambda row: "tests/gen/ch23/" + interaction_import.case_name(row) + ".sv",
            interaction_import.MODEL.select(),
            "packageのwildcard/明示import、局所宣言、.*・.name・明示接続で入力の接続先と既定値を区別する。"
            "既定値0/全1の2子と独立した対照スコープを観測し、ライブ値の追従・隠蔽・型変換を確認する。",
        ),
        SuiteModel(
            interaction_memfile.MODEL,
            lambda row: "tests/gen/ch21/" + interaction_memfile.case_name(row) + ".sv",
            interaction_memfile.MODEL.select(),
            "bit/logicと列挙型のメモリファイルを出力し、元配列の変更後に別の添字範囲へ読み込む。"
            "独立に用意した入力も読み込み、要素の値・範囲外の保持・宣言方向と読込み順・上書きを照合する。",
        ),
        SuiteModel(
            interaction_program.MODEL,
            lambda row: "tests/gen/ch24/" + interaction_program.case_name(row) + ".sv",
            interaction_program.MODEL.select(),
            "programの自然終了と直接/タスク内の$exit、複数initial、子/孫プロセスの待機を組み合わせる。"
            "終了前の進捗と終了後の書込み取消し、同じ待機条件を持つ別programの起床、最後のprogramによる暗黙終了を観測する。",
        ),
        SuiteModel(
            interaction_nettype.MODEL,
            lambda row: "tests/gen/ch22/" + interaction_nettype.case_name(row) + ".sv",
            interaction_nettype.MODEL.select(),
            "ANSI/非ANSIのポート宣言でnet型を省略し、default_nettypeによるvectorとscalarの解決値・幅を親子で照合する。"
            "vectorだけの明示wireによる上書きと、指示解除後の別moduleを同じ刺激で比較し、既定型の適用範囲を確認する。",
        ),
        SuiteModel(
            interaction_ifgenerate.MODEL,
            lambda row: "tests/gen/ch27/" + interaction_ifgenerate.case_name(row) + ".sv",
            interaction_ifgenerate.MODEL.select(),
            "generate要素ごとに幅の違うinterfaceを2個置き、if/caseで選択した側をwhole/modportのwriter/readerへ接続する。"
            "bit/logicへの格納前の反転、非選択側の対照、実際の幅・識別タグ・接続先と全要素の独立性を観測する。",
        ),
        SuiteModel(
            interaction_reactive.MODEL,
            lambda row: "tests/gen/ch24/" + interaction_reactive.case_name(row) + ".sv",
            interaction_reactive.MODEL.select(),
            "moduleのNBA連鎖の完了前後を、早いmodule内の対照とReactiveで動くprogramで観測する。"
            "連続代入・blocking・Re-NBAの出力と採取値、型変換、全段の値・NBA予約回数・採取した文脈を照合する。",
        ),
        SuiteModel(
            interaction_config.MODEL,
            lambda row: "tests/gen/ch33/" + interaction_config.case_name(row) + ".sv",
            interaction_config.MODEL.select(),
            "configの設定・Wだけのリセット・全パラメータのリセットを、既定値・インスタンス指定・defparamと比較する。"
            "通常階層の親パラメータとconfig localparamの隠蔽、生成した幅・個数・if/case分岐、対象外の兄弟を観測する。",
        ),
        SuiteModel(
            interaction_udp.MODEL,
            lambda row: "tests/gen/ch29/" + interaction_udp.case_name(row) + ".sv",
            interaction_udp.MODEL.select(),
            "組合せUDPの配列へベクタをビット分配し、スカラーを共通接続する。"
            "単独出力・競合する別ドライバ付きの出力・名前なしの単一UDPを比較し、強度・全4状態の入力対・位置識別を照合する。",
        ),
        SuiteModel(
            interaction_udpstate.MODEL,
            lambda row: "tests/gen/ch29/" + interaction_udpstate.case_name(row) + ".sv",
            interaction_udpstate.MODEL.select(),
            "generateで初期値の異なる逐次UDPをビットごとに選択し、共通/交互のクロックで個別の状態を採取・保持する。"
            "bit/logicへのX/Z格納、未知入力前の全1準備、既知値への回復、別クロックの対照の保持と後の採取を照合する。",
        ),
        SuiteModel(
            interaction_ifimport.MODEL,
            lambda row: "tests/gen/ch25/" + interaction_ifimport.case_name(row) + ".sv",
            interaction_ifimport.MODEL.select(),
            "interfaceヘッダのimportでパラメータ既定値・型・package関数を結合し、targetだけの幅/タグ変更をguardと比較する。"
            "同名の呼出し側宣言を対照に、bit/logicの仮引数変換がpackage関数の演算前に行われる順序と実際の幅・中間値を照合する。",
        ),
        SuiteModel(
            interaction_mailbox.MODEL,
            lambda row: "tests/gen/ch15/" + interaction_mailbox.case_name(row) + ".sv",
            interaction_mailbox.MODEL.select(),
            "classハンドルをtyped/typelessのmailboxへ渡し、FIFO・get/peek・容量制限・nullメッセージと"
            "取得前後の双方向のメンバ更新を確認する。別mailboxの保持と後の更新、空の非ブロッキング戻り値も観測する。",
        ),
        SuiteModel(
            interaction_dist.MODEL,
            lambda row: "tests/gen/ch18/" + interaction_dist.case_name(row) + ".sv",
            interaction_dist.MODEL.select(),
            "演算子の優先順位と括弧、幅・符号、distの重みと重複項目を照合する。"
            "候補値から解を一意にし、全重みゼロによる失敗時の値保持を、毎回成功する別実体と比較する。",
        ),
        SuiteModel(
            interaction_gendisable.MODEL,
            lambda row: "tests/gen/ch16/" + interaction_gendisable.case_name(row) + ".sv",
            interaction_gendisable.MODEL.select(),
            "generate内でのdefault disable iffの継承・上書き・名前解決・宣言位置と、"
            "明示条件・ゼロによる取消しを照合する。二つの実体を独立に無効化し、"
            "開始前・クロック間・終了クロックのNBAで、無効化と成功・失敗の回数を対照と比較する。",
        ),
        SuiteModel(
            interaction_randreduce.MODEL,
            lambda row: "tests/gen/ch18/" + interaction_randreduce.case_name(row) + ".sv",
            interaction_randreduce.MODEL.select(),
            "固定配列と動的配列の一意な解と矛盾を切り替え、要素型とwith式の型でのリダクション、"
            "演算前の拡張、失敗時の全要素とサイズの保持、独立した対照オブジェクトを照合する。",
        ),
        SuiteModel(
            interaction_assocquery.MODEL,
            lambda row: "tests/gen/ch20/" + interaction_assocquery.case_name(row) + ".sv",
            interaction_assocquery.MODEL.select(),
            "連想配列の挿入・上書き・削除・再利用で、添字型の範囲と割当て済みの範囲、"
            "問い合わせのinteger変換とfirst/lastの幅・符号、要素数と全キー/値を照合する。",
        ),
        SuiteModel(
            interaction_clockiff.MODEL,
            lambda row: "tests/gen/ch14/" + interaction_clockiff.case_name(row) + ".sv",
            interaction_clockiff.MODEL.select(),
            "iffで選別したclocking eventとrawエッジを別計数し、通過時の採取と不通過時のサンプル保持を照合する。"
            "ガードだけの前後の変更、33ビットの上位1、入力skew・更新方式を交差し、cbと観測器の値を比較する。",
        ),
        SuiteModel(
            interaction_vif_class.MODEL,
            lambda row: "tests/gen/ch25/" + interaction_vif_class.case_name(row) + ".sv",
            interaction_vif_class.MODEL.select(),
            "クラスのvirtual interfaceの結合を浅いコピー/ハンドル代入で比較し、再結合とnull時の書込み抑止を照合する。"
            "別に保存した参照・元/コピーの結合先・成功回数・guardを、メソッド/直接経路とfull/modport型で確認する。",
        ),
        SuiteModel(
            interaction_strengthfmt.MODEL,
            lambda row: "tests/gen/ch21/" + interaction_strengthfmt.case_name(row) + ".sv",
            interaction_strengthfmt.MODEL.select(),
            "2ドライバの競合・解放とtri0/tri1のpull既定値を、3種類のformat APIで値と強度を分けて照合する。"
            "強度差・更新順・極性を交差し、全11観測の上書きと独立したsupply対照を確認する。",
        ),
        SuiteModel(
            interaction_class_array.MODEL,
            lambda row: "tests/gen/ch8/" + interaction_class_array.case_name(row) + ".sv",
            interaction_class_array.MODEL.select(),
            "クラスの浅いコピーとハンドル代入を対照に、配列領域の独立性と要素ハンドルの参照先の共有を照合する。"
            "元/コピーからの要素置換・拡大/縮小、保存ハンドルの存続、コンストラクタ回数と別guardの保持を確認する。",
        ),
        SuiteModel(
            interaction_dpi_array.MODEL,
            lambda row: "tests/gen/ch35/" + interaction_dpi_array.case_name(row) + ".sv",
            interaction_dpi_array.MODEL.select(),
            "固定/動的配列/キューをopen arrayとしてDPIへ渡し、各呼出しの範囲・全要素・復帰後の書戻しを照合する。"
            "入力方向・数値順の走査方向・符号パターン・繰返し前の拡大/縮小を交差し、別のguard配列の保持も確認する。",
        ),
        SuiteModel(
            interaction_clockassert.MODEL,
            lambda row: "tests/gen/ch16/" + interaction_clockassert.case_name(row) + ".sv",
            interaction_clockassert.MODEL.select(),
            "既定/明示の#1step clocking入力を、そのイベントと後続の別クロックのアサーションで観測する。"
            "更新の前後とblocking/NBA、独立したエッジ極性を組み合わせ、sampled値・Reactiveの生信号・"
            "判定回数を分けて照合し、別クロックでの誤った再サンプリングを検出する。",
        ),
        SuiteModel(
            interaction_constraint.MODEL,
            lambda row: "tests/gen/ch18/" + interaction_constraint.case_name(row) + ".sv",
            interaction_constraint.MODEL.select(),
            "基底/派生ハンドルから3階層の継承制約を解き、同名の置換・別名の追加とpure/externの完了を照合する。"
            "一意解と矛盾を交互に与え、初回失敗時の初期値・成功後の値の保持と、別オブジェクトの独立した成功を確認する。",
        ),
        SuiteModel(
            interaction_dpi_nba.MODEL,
            lambda row: "tests/gen/ch35/" + interaction_dpi_nba.case_name(row) + ".sv",
            interaction_dpi_nba.MODEL.select(),
            "DPIのinput/output/inoutとNBA予約の前後、同じ/別の配列要素を組み合わせる。"
            "幅・符号・bit/logicからintへの変換、復帰直後の書戻し、予約後の添字・値の変更、"
            "Postponedと次時刻の全要素を照合し、NBAの値と代入先の確定を確認する。",
        ),
        SuiteModel(
            interaction_eventlife.MODEL,
            lambda row: "tests/gen/ch15/" + interaction_eventlife.case_name(row) + ".sv",
            interaction_eventlife.MODEL.select(),
            "自動タスク復帰後の構造体内イベントの同一性・別名解放・遅延した待機登録と、"
            "別呼出しの独立性・全体コピー後のpayload・起床時刻を照合する。",
        ),
        SuiteModel(
            interaction_dpiquery.MODEL,
            lambda row: "tests/gen/ch20/" + interaction_dpiquery.case_name(row) + ".sv",
            interaction_dpiquery.MODEL.select(),
            "同じ実引数のSV/DPI-C問い合わせを、次元番号の対応・packed範囲の正規化・"
            "各次元の範囲とincrement・呼出しごとの形状更新で照合する。",
        ),
        SuiteModel(
            interaction_sdfpath.MODEL,
            lambda row: "tests/gen/ch32/" + interaction_sdfpath.case_name(row) + ".sv",
            interaction_sdfpath.MODEL.select(),
            "SDFの条件・注釈範囲・置換/加算と、立上り/立下りの遅延を照合する。"
            "兄弟インスタンスと別出力を対照とし、値・変化回数・最終変化時刻を観測する。",
        ),
        SuiteModel(
            interaction_checksample.MODEL,
            lambda row: "tests/gen/ch17/" + interaction_checksample.case_name(row) + ".sv",
            interaction_checksample.MODEL.select(),
            "checkerとmodule参照モデルで、判定・サンプル値・Reactiveの値・実行時刻を照合する。"
            "接続形式と配置を変え、2実体の独立性と出力引数の伝播も観測する。",
        ),
        SuiteModel(
            interaction_progassert.MODEL,
            lambda row: "tests/gen/ch24/" + interaction_progassert.case_name(row) + ".sv",
            interaction_progassert.MODEL.select(),
            "programとmodule参照モデルの各クロック試行を、単周期判定・同サイクル/次サイクル含意で照合する。"
            "空虚な成功と未完了の試行を区別し、判定数と完了時のサンプル値総和を出力引数から観測する。",
        ),
        SuiteModel(
            interaction_cgsample.MODEL,
            lambda row: "tests/gen/ch19/" + interaction_cgsample.case_name(row) + ".sv",
            interaction_cgsample.MODEL.select(),
            "配列・キューの変更前後でサイズ・先頭/末尾値をsampleし、直接参照と引数、空のガード、"
            "必要ヒット数と対象/対照それぞれのbin履歴を照合する。",
        ),
        SuiteModel(
            interaction_deferdis.MODEL,
            lambda row: "tests/gen/ch16/" + interaction_deferdis.case_name(row) + ".sv",
            interaction_deferdis.MODEL.select(),
            "disable対象のスコープと未成熟の遅延報告を、兄弟・別プロセスの対照、引数取得と副作用、"
            "報告時の生値・通常の制御移動・報告済み履歴の保持と照合する。",
        ),
        SuiteModel(
            interaction_event_rebind.MODEL,
            lambda row: "tests/gen/ch15/" + interaction_event_rebind.case_name(row) + ".sv",
            interaction_event_rebind.MODEL.select(),
            "静的イベントをタスク呼出し前・待機登録前・登録後に再結合し、inputのコピーとref/直接参照、"
            "登録済み待機の保持、複数待機者、後着待機者、別名の独立性とActive/NBAの観測値を照合する。",
        ),
        SuiteModel(
            interaction_clockevent.MODEL,
            lambda row: "tests/gen/ch14/" + interaction_clockevent.case_name(row) + ".sv",
            interaction_clockevent.MODEL.select(),
            "clocking入力から名前付きイベントで待機者へ通知し、受信直後と生信号変更後の採取値・生値を照合する。"
            "入力skew・エッジ・更新方式・通知方式・待機者数・幅を交差し、別イベントによる誤起床と反復時の再待機も観測する。",
        ),
        SuiteModel(
            interaction_deferarg.MODEL,
            lambda row: "tests/gen/ch13/" + interaction_deferarg.case_name(row) + ".sv",
            interaction_deferarg.MODEL.select(),
            "遅延報告の値渡しと静的な参照渡しを、登録時の取得値・報告時の生値・幅変換と照合する。"
            "関数とタスク、報告領域、更新方式、幅と符号を交差し、引数評価の副作用と実行時刻も観測する。",
        ),
    )
