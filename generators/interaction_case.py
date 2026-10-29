"""Cross case matching widths/signs, X/Z masks and first-match priority.

12.5 sizes every comparison to the longest operand and uses signed
extension only when all operands are signed. 12.5.1 ignores Z on either
side for casez, and X/Z on either side for casex. Each test checks a
duplicate-item priority scenario and then a distinct fallback item.
"""

from common import Case
from interaction_bits import pattern, resize
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_case"
VERSION = 1
CHAPTER = 12

MODEL = Model(
    "case_matching",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("selector_sign", ("unsigned", "signed")), ("item_sign", ("unsigned", "signed")),
     ("item_width", ("narrow", "same", "wide")), ("kind", ("case", "casez", "casex")),
     ("value", ("known", "x", "z")),
     ("pattern", ("equal", "flip_low", "wild_high", "unknown_low"))),
    lambda r: r[0] != "1" or r[3] != "narrow",
    groups=(("kind", "value", "pattern"), ("width", "item_width", "selector_sign"),
            ("selector_sign", "item_sign", "kind")),
    anchors=(("129", "signed", "signed", "narrow", "casez", "z", "wild_high"),
             ("65", "signed", "unsigned", "wide", "case", "known", "equal"),
             ("33", "unsigned", "signed", "same", "casex", "x", "unknown_low")),
    constraints=("幅1のnarrowは幅0になるため除外。2つの項目は同じ型・幅。"
                 "unique/priority修飾、inside、matches、式の副作用は対象外",),
)


def case_name(row: Row) -> str:
    w, selector, item, relation, kind, value, variant = row
    return f"test_gen_cross_case_w{w}_{selector[0]}{item[0]}_{relation[0]}_{kind}_{value[0]}_{variant}"


def matches(selector: str, item: str, signed: bool, kind: str) -> bool:
    n = max(len(selector), len(item))
    a, b = resize(selector, n, signed), resize(item, n, signed)
    ignored = "z" if kind == "casez" else "xz" if kind == "casex" else ""
    return all(x == y or x in ignored or y in ignored for x, y in zip(a, b))


def reference(row: Row) -> tuple[str, str, str, int, int]:
    w, selector_sign, item_sign, relation, kind, value, variant = row
    w = int(w)
    iw = w + {"narrow": -1, "same": 0, "wide": 1}[relation]
    selector = pattern(w, value)
    baseline = resize(selector, iw, selector_sign == "signed")
    first = list(baseline)
    if variant == "flip_low":
        first[-1] = "1" if first[-1] == "0" else "0"
    elif variant == "wild_high":
        first[0] = "z"
    elif variant == "unknown_low":
        first[-1] = "x"
    first = "".join(first)
    signed = selector_sign == item_sign == "signed"
    hit = matches(selector, first, signed, kind)
    fallback = matches(selector, baseline, signed, kind)
    return selector, first, baseline, 1 if hit else 9, 1 if hit else 2 if fallback else 9


def make_case(row: Row) -> Case:
    w, selector_sign, item_sign, relation, kind, value, variant = row
    w = int(w)
    iw = w + {"narrow": -1, "same": 0, "wide": 1}[relation]
    selector, first, baseline, duplicate, fallback = reference(row)
    name = case_name(row)
    block = [f"    {kind} (selector)", "      item0: picked = 1;", "      item1: picked = 2;",
             "      default: picked = 9;", "    endcase"]
    lines = [f"module {name};", f"  logic {selector_sign} [{w - 1}:0] selector;",
             f"  logic {item_sign} [{iw - 1}:0] item0, item1;", "  integer picked;",
             "  initial begin", f"    selector = {literal(selector)};",
             f"    item0 = {literal(first)};", "    item1 = item0;", *block,
             '    $display("selector=%b first=%b", selector, item0);',
             '    $display("duplicate=%0d", picked);', f"    item1 = {literal(baseline)};", *block,
             '    $display("second=%b fallback=%0d", item1, picked);',
             "    $finish;", "  end", "endmodule"]
    return Case(
        name, "Case matching combines common sizing, signs, wildcard rules and first-match priority",
        "12.5 12.5.1 11.8.1 11.8.2",
        "Comparison width is the longest selector/item width; extension is signed only "
        "when all operands are signed. Plain case compares X/Z exactly, casez masks Z "
        "on either side, and casex masks X/Z on either side. The first run uses duplicate "
        "items to check first-match priority; the second restores a baseline fallback. "
        "Item expressions are variables of identical types, without side effects.",
        "\n".join(lines), f"selector={selector} first={first}\nduplicate={duplicate}\n"
        f"second={baseline} fallback={fallback}\n",
        fourstate=value != "known" or variant in ("wild_high", "unknown_low"),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
