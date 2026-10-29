"""Deterministic, bounded covering sets for small constrained factor models.

Targets exist only when a complete legal row witnesses them. This deliberately
enumerates small models, not an unbounded product of all language features.
Selection is greedy followed by redundant-row removal; it is not an optimum.
"""

from dataclasses import dataclass, field
from itertools import combinations, product
from math import prod
from typing import Callable

Row = tuple[str, ...]
Target = tuple[tuple[int, str], ...]


@dataclass
class Model:
    name: str
    factors: tuple[tuple[str, tuple[str, ...]], ...]
    legal: Callable[[Row], bool]
    groups: tuple[tuple[str, ...], ...] = ()
    anchors: tuple[Row, ...] = ()
    constraints: tuple[str, ...] = ()
    version: int = 1
    max_rows: int = 10000
    _rows: tuple[Row, ...] | None = field(default=None, init=False, repr=False)

    def __post_init__(self):
        names = [n for n, _ in self.factors]
        if len(names) < 2 or len(set(names)) != len(names):
            raise ValueError("at least two distinct factors are required")
        if any(not values or len(set(values)) != len(values) for _, values in self.factors):
            raise ValueError("factor values must be nonempty and unique")
        if prod(len(v) for _, v in self.factors) > self.max_rows:
            raise ValueError("model exceeds enumeration limit; split its semantic scope")
        for group in self.groups:
            if len(group) < 3 or len(set(group)) != len(group) or not set(group) <= set(names):
                raise ValueError("higher-strength groups must name distinct existing factors")

    def rows(self) -> tuple[Row, ...]:
        if self._rows is None:
            rows = tuple(row for row in product(*(v for _, v in self.factors))
                         if self.legal(row))
            if not rows:
                raise ValueError("model has no legal complete rows")
            if not set(self.anchors) <= set(rows):
                raise ValueError("a mandatory witness is not a legal complete row")
            self._rows = rows
        return self._rows

    def projections(self) -> tuple[tuple[int, ...], ...]:
        names = [n for n, _ in self.factors]
        groups = {tuple(sorted(names.index(n) for n in group)) for group in self.groups}
        return tuple(sorted(set(combinations(range(len(names)), 2)) | groups))

    def targets(self, row: Row) -> frozenset[Target]:
        if len(row) != len(self.factors):
            raise ValueError("row has the wrong arity")
        if row not in self.rows():
            raise ValueError("row is not a legal complete assignment")
        return frozenset(tuple((i, row[i]) for i in indices) for indices in self.projections())

    def universe(self) -> frozenset[Target]:
        return frozenset(t for row in self.rows() for t in self.targets(row))

    def select(self) -> tuple[Row, ...]:
        rows = self.rows()
        covered = {row: self.targets(row) for row in rows}
        universe = frozenset(t for targets in covered.values() for t in targets)
        selected = list(dict.fromkeys(self.anchors))
        missing = set(universe)
        for row in selected:
            missing.difference_update(covered[row])
        remaining = [row for row in rows if row not in selected]
        while missing:
            best = max(remaining, key=lambda row: len(covered[row] & missing))
            if not covered[best] & missing:
                raise ValueError("uncoverable target")
            selected.append(best)
            missing.difference_update(covered[best])
            remaining.remove(best)
        # Keep the explicit boundary witnesses even when their projections
        # also appear in other rows.
        anchors = set(self.anchors)
        for row in selected[::-1]:
            if row in anchors:
                continue
            others = set(t for other in selected if other != row for t in covered[other])
            if universe <= others:
                selected.remove(row)
        return tuple(selected)

    def values(self, row: Row) -> dict[str, str]:
        return {name: value for (name, _), value in zip(self.factors, row)}
