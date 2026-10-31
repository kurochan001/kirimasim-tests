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
              interaction_compound, interaction_inside, interaction_range,
              interaction_case_inside)


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
    )
