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
import scheduling
from interaction_cover import Model, Row

GENERATORS = (scheduling, interaction_nba, interaction_expr, interaction_select, interaction_cond)


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
    )
