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
import scheduling
from interaction_cover import Model, Row

GENERATORS = (scheduling, interaction_nba, interaction_expr, interaction_select, interaction_cond,
              interaction_shift, interaction_cast, interaction_task,
              interaction_struct, interaction_case, interaction_port,
              interaction_array, interaction_query, interaction_stream,
              interaction_compare, interaction_method,
              interaction_index, interaction_queue)


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
    )
