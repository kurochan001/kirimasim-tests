"""Finite table registry shared by the closing Annex F wave.

The word-operation cases, the local-assignment cases and the free-checker
cases live in separate modules and register into this table so that
``formal.py`` enumerates them with the same exhaustive exporter used for
F.4 and F.5.4-F.5.7.
"""

TABLES = {}


def table(name, clause, expression, *, signals=(), horizon=1, context=(),
          inputs=(), selectors=0, actual, reference, cover="1",
          why="", limitation=""):
    TABLES[name] = {
        "clause": clause, "expression": expression, "signals": list(signals),
        "horizon": horizon, "context": list(context), "inputs": list(inputs),
        "selectors": selectors, "actual": actual, "reference": reference,
        "cover": cover, "why": why, "limitation": limitation,
    }
