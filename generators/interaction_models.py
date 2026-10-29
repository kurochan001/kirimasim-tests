"""Audited interaction profiles, including existing scheduling test witnesses.

No keyword scan is used to infer coverage. A profile's generator defines the
stimulus, observation and independent expected output for that exact row.
"""

from dataclasses import dataclass
from typing import Callable

import interaction_nba
import scheduling
from interaction_cover import Model, Row


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
    )
