"""Cross case-inside item kinds with widths, signs, unknowns and qualifiers.

12.5.4 compares the case expression with each item by the inside operator
(11.4.13): the case expression is the left operand, an item value is a
wildcard on its X/Z bits (11.4.6) and a range uses the relational operators.
An item is selected only when that operation yields 1; 0 and X both move on
to the next item, and the default item runs when no item matches. The case
expression is evaluated once, before the items (12.5). A normal case stops
at the first match; a unique0-case goes on evaluating the other items after
a match, and reports nothing when no item matches (12.5.3). Every item has
one type, so each comparison has the same joint width and signedness.
"""

from common import Case
from interaction_bits import resize, two_state
from interaction_compare import compare
from interaction_cond import literal
from interaction_cover import Model, Row
from interaction_range import both, word

NAME = "interaction_case_inside"
VERSION = 1
CHAPTER = 12
FIRST = {"value": "first", "range": "[lo:hi]", "array": "arr", "list": "first, alt"}
CARRIER = {"value": "first", "range": "lo", "array": "arr1", "list": "alt"}


def legal(row: Row) -> bool:
    return row[0] != "1" or row[1] != "narrow"


MODEL = Model(
    "case_inside_selection",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("expr_width", ("narrow", "same", "wide")),
     ("expr_sign", ("unsigned", "signed")), ("item_sign", ("unsigned", "signed")),
     ("item_state", ("bit", "logic")),
     ("first", tuple(FIRST)),
     ("value", ("known", "expr_x", "item_x", "item_z")),
     ("qualifier", ("plain", "unique0")),
     ("third", ("variable", "call"))),
    legal,
    groups=(("width", "expr_width", "expr_sign"),
            ("expr_sign", "item_sign", "first"),
            ("item_state", "value", "first"),
            ("first", "value", "qualifier"),
            ("expr_width", "item_sign", "first"),
            ("third", "qualifier", "first")),
    anchors=(("33", "wide", "unsigned", "signed", "logic", "array", "known", "plain", "variable"),
             ("65", "wide", "unsigned", "signed", "logic", "range", "known", "unique0", "call"),
             ("129", "same", "signed", "signed", "logic", "value", "item_x", "plain", "variable"),
             ("64", "narrow", "signed", "unsigned", "bit", "list", "item_z", "unique0",
              "variable"),
             ("32", "same", "unsigned", "unsigned", "logic", "value", "expr_x", "plain", "call"),
             ("1", "wide", "signed", "signed", "logic", "range", "item_x", "plain", "variable"),
             ("64", "same", "unsigned", "unsigned", "logic", "range", "item_x", "plain", "call")),
    constraints=("幅1のnarrowは幅0になるため除外。全項目は同じ型・幅で、整数リテラルの項目は"
                 "使わない。priority・uniqueは一致がないときの違反報告とdefaultの関係を本文が"
                 "明記しないため対象外とし、unique0では一致する項目が1つ以下の入力だけを使う。"
                 "項目内の複数の式の評価回数、副作用の順序、caseのcasez/casexは対象外",),
)


def case_name(row: Row) -> str:
    w, relation, es, its, state, first, value, qualifier, third = row
    return (f"test_gen_cross_caseinside_w{w}_{relation[0]}_{es[0]}{its[0]}_{state[0]}_"
            f"{first}_{value}_{qualifier[0]}{third[0]}")


def widths(row: Row) -> tuple[int, int]:
    """Return the case expression width and the width of every item."""
    right = int(row[0])
    return right + {"narrow": -1, "same": 0, "wide": 1}[row[1]], right


def operands(row: Row) -> dict[str, str]:
    """Return the known item values: the first item's values, second and third."""
    w, first = int(row[0]), row[5]
    near_top = "1" + "0" * (w - 2) + "1" if w > 1 else "1"
    values = {"second": word(5, w), "third": word(6, w)} if w > 1 else {"second": "0", "third": "0"}
    if first == "value":
        values["first"] = near_top
    elif first == "range":
        values["lo"], values["hi"] = near_top, ("1" * (w - 1) + "0" if w > 1 else "1")
    elif first == "array":
        values["arr0"], values["arr1"] = (word(3, w) if w > 1 else "0"), near_top
    else:
        values["first"], values["alt"] = (word(3, w) if w > 1 else "0"), near_top
    return values


def stored_values(row: Row) -> tuple[dict[str, str], dict[str, str]]:
    """Return the values as given, with any unknown bit, and as stored."""
    given = operands(row)
    if row[6] in ("item_x", "item_z"):
        carrier = CARRIER[row[5]]
        bits = given[carrier]
        i = bits.rindex("1")
        given[carrier] = bits[:i] + row[6][-1] + bits[i + 1:]
    stored = {k: two_state(v) if row[4] == "bit" else v for k, v in given.items()}
    return given, stored


def item_results(row: Row, expr: str, stored: dict[str, str]) -> list[str]:
    """Return the inside result of the three items, in the order written."""
    es, its, first = row[2], row[3], row[5]

    def value(v):
        return compare(expr, v, es, its, "weq")

    def any_of(results):
        return "1" if "1" in results else "x" if "x" in results else "0"

    if first == "value":
        head = value(stored["first"])
    elif first == "range":
        head = both(compare(expr, stored["lo"], es, its, "ge"),
                    compare(expr, stored["hi"], es, its, "le"))
    elif first == "array":
        head = any_of([value(stored["arr0"]), value(stored["arr1"])])
    else:
        head = any_of([value(stored["first"]), value(stored["alt"])])
    return [head, value(stored["second"]), value(stored["third"])]


def selected(results: list[str]) -> int:
    """Return the number of the first item whose result is 1, or 0 for default."""
    return next((i + 1 for i, r in enumerate(results) if r == "1"), 0)


def expressions(row: Row) -> list[str]:
    """Return four case expressions that reach as many outcomes as the row allows."""
    we, w = widths(row)
    es, its = row[2] == "signed", row[3] == "signed"
    common = es and its
    _, stored = stored_values(row)
    known = operands(row)
    candidates = []
    for name in ("arr1", "alt", "first", "lo", "hi", "second", "third", "arr0"):
        if name in known:
            candidates += [resize(known[name], we, common), resize(known[name], we, its)]
    step = lambda bits, d: word(int(bits, 2) + d, we)
    candidates += [step(candidates[0], -1), "1" * we, "0" * we, word(1, we), step(candidates[0], 1)]
    candidates = list(dict.fromkeys(candidates))
    if row[6] == "expr_x":
        candidates = [c[:-1] + "x" for c in candidates]
        candidates = list(dict.fromkeys(candidates))

    def usable(expr):
        results = item_results(row, expr, stored)
        return row[7] == "plain" or results.count("1") <= 1

    def skips_unknown(expr):
        # Prefer an expression for which an earlier item yields X, so the
        # search has to go past an unknown result to reach its target.
        results = item_results(row, expr, stored)
        choice = selected(results)
        return "x" in results[:choice - 1 if choice else 3]

    chosen = []
    for target in (1, 2, 3, 0):
        reach = [c for c in candidates if c not in chosen and usable(c)
                 and selected(item_results(row, c, stored)) == target]
        reach.sort(key=lambda c: not skips_unknown(c))
        if reach:
            chosen.append(reach[0])
    for c in candidates:
        if len(chosen) == 4:
            break
        if c not in chosen and usable(c):
            chosen.append(c)
    if not chosen:
        raise ValueError("no usable case expression for " + case_name(row))
    return [chosen[i % len(chosen)] for i in range(4)]


def make_case(row: Row) -> Case:
    _, _, es, its, state, first, value, qualifier, third = row
    we, w = widths(row)
    name = case_name(row)
    given, stored = stored_values(row)
    names = list(given)
    keyword = "unique0 case" if qualifier == "unique0" else "case"
    lines = [f"module {name};", f"  typedef {state} {its} [{w-1}:0] item_t;",
             f"  typedef logic {es} [{we-1}:0] expr_t;", "  expr_t expr;"]
    plain = [n for n in names if not n.startswith("arr")]
    lines += [f"  logic [{w-1}:0] {n}_given;" for n in names]
    lines += [f"  item_t {', '.join(plain)};"]
    if first == "array":
        lines += ["  item_t arr[0:1];"]
    lines += ["  int r, sel_calls, probe_calls;",
              "  function automatic expr_t sel();", "    sel_calls++;", "    return expr;",
              "  endfunction"]
    if third == "call":
        lines += ["  function automatic item_t probe();", "    probe_calls++;",
                  "    return third;", "  endfunction"]
    lines += ["  initial begin"]
    last = "probe()" if third == "call" else "third"
    for n in names:
        target = f"arr[{n[-1]}]" if n.startswith("arr") else n
        lines += [f"    {n}_given = {literal(given[n])};", f"    {target} = {n}_given;"]
        lines += [f'    $display("{n} given=%b stored=%b", {n}_given, {target});']
    expected = [f"{n} given={given[n]} stored={stored[n]}" for n in names]
    for phase, expr in enumerate(expressions(row)):
        results = item_results(row, expr, stored)
        choice = selected(results)
        if qualifier == "unique0" and results.count("1") > 1:
            raise ValueError("a unique0 phase with overlapping items in " + name)
        lines += [f"    expr = {literal(expr)};", "    r = -1;", "    sel_calls = 0;",
                  "    probe_calls = 0;", f"    {keyword} (sel()) inside",
                  f"      {FIRST[first]}: r = 1;", "      second: r = 2;",
                  f"      {last}: r = 3;", "      default: r = 0;", "    endcase"]
        if third == "variable":
            lines += [f'    $display("p{phase} expr=%b r=%0d sel=%0d", expr, r, sel_calls);']
            expected += [f"p{phase} expr={expr} r={choice} sel=1"]
        elif qualifier == "unique0":
            # The other items are still evaluated after a match, in any order.
            lines += [f'    $display("p{phase} expr=%b r=%0d sel=%0d probe_seen=%0d",',
                      "             expr, r, sel_calls, probe_calls > 0);"]
            expected += [f"p{phase} expr={expr} r={choice} sel=1 probe_seen=1"]
        else:
            lines += [f'    $display("p{phase} expr=%b r=%0d sel=%0d probe=%0d",',
                      "             expr, r, sel_calls, probe_calls);"]
            expected += [f"p{phase} expr={expr} r={choice} sel=1 "
                         f"probe={int(choice in (0, 3))}"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Case inside combines item kinds, widths, signs, unknowns and the unique0 qualifier",
        "12.5.4 12.5 12.5.3 11.4.13 11.4.6 11.8.1 11.8.2 6.11.2",
        "The first item is a value, a range, a fixed array or a list of two values; then come "
        "a value, a third value held in a variable or returned by a function call that counts "
        "its evaluations, and a default item. Every "
        "item has one type, so the case expression and an item are compared at their joint "
        "width and signedness, and an unsigned side zero-extends a signed item. Four case "
        "expressions in the case expression's own width aim at each item and at the default, "
        "including the item value extended by its own sign, which only a sign-extending error "
        "selects. An X/Z bit of an item value is a wildcard, in a range bound it makes the "
        "comparison X, and an X/Z bit of the case expression is never a wildcard; an X result "
        "is no match and the search goes on. Bit storage turns given X/Z bits into zero "
        "first. The case expression, a counting function, is evaluated once. A plain case "
        "does not call the counting item after an earlier match; a unique0-case still calls it, "
        "and its "
        "inputs never match more than one item. Priority and unique qualifiers, several "
        "expressions with side effects in one item, and casez/casex are outside this finite "
        "model.",
        "\n".join(lines), "\n".join(expected) + "\n",
        fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
