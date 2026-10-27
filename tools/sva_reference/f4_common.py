"""Finite table registry shared by the Annex F.4 formal case modules.

The F.4.1/F.4.2 flattening cases and the F.4/F.4.3 declaration-assignment
rewriting cases live in separate modules and register into this one table so
that ``formal.py`` can enumerate them with the same exhaustive exporter used
for F.5.4-F.5.7.
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
