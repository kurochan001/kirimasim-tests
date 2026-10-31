"""Cross concurrent assertion sampling with typed updates and action observations.

Static variables are sampled in Preponed (16.5.1). Both action branches run
in Reactive (16.14.1); $sampled in an action retains the sampled expression
(16.9.3). Updates before, at and after the clock distinguish these values.
"""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_assertion"
VERSION = 1
CHAPTER = 16

MODEL = Model(
    "assertion_sample_visibility",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("expression", ("reduce_or", "equal", "case_equal")),
     ("edge", ("posedge", "negedge")), ("update", ("blocking", "nba")),
     ("timing", ("before", "edge", "after")), ("home", ("module", "interface"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("expression", "state", "value"),
            ("timing", "edge", "update"), ("home", "timing", "update"),
            ("home", "expression", "timing")),
    anchors=(("1", "bit", "known", "reduce_or", "posedge", "nba", "edge", "module"),
             ("129", "logic", "z", "equal", "negedge", "nba", "edge", "interface"),
             ("65", "logic", "x", "case_equal", "posedge", "blocking", "after", "module"),
             ("33", "bit", "x", "equal", "negedge", "blocking", "before", "interface"),
             ("32", "logic", "known", "equal", "posedge", "blocking", "edge", "module"),
             ("64", "bit", "known", "reduce_or", "negedge", "blocking", "before", "interface"),
             ("65", "logic", "known", "case_equal", "posedge", "nba", "after", "module")),
    constraints=("全2592行は合法。単一クロックの単一サイクルBoolean propertyで、"
                 "pass/failの両actionを明示する。初期化・刺激準備・最終観測は別時刻。"
                 "X/Z行も既知値の正負対照を含む。program、clocking変数、automatic変数、"
                 "disable iff、アサーション制御、時間演算と履歴関数は対象外。未対応では除外しない",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_assert_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, str, str]]:
    width = int(row[0])
    zero, one = "0" * width, "1" * width
    pattern = ("01" * width)[:width]
    inverse = pattern.translate(str.maketrans("01", "10"))
    result = [("k0", zero, one), ("k1", one, zero), ("k2", pattern, inverse)]
    if row[2] != "known":
        unknown = row[2] * width
        result += [("u0", unknown, one), ("u1", zero, unknown), ("u2", one, unknown)]
    return result


def predicate(bits: str, expression: str) -> str:
    if expression == "reduce_or":
        return "1" if "1" in bits else "x" if set(bits) & set("xz") else "0"
    if expression == "equal":
        if "1" in bits:
            return "0"
        if set(bits) & set("xz"):
            return "x"
    return "1" if set(bits) == {"0"} else "0"


def reference(row: Row) -> str:
    passed = failed = 0
    result = []
    convert = lambda bits: bits.translate(str.maketrans("xz", "00")) if row[1] == "bit" else bits
    for label, before_raw, incoming in phases(row):
        before, final = convert(before_raw), convert(incoming)
        sampled = final if row[6] == "before" else before
        action = before if row[6] == "after" else final
        value = predicate(sampled, row[3])
        passed += value == "1"
        failed += value != "1"
        result += [f"{label} before={before} source={incoming}",
                   f"{label} pass={passed} fail={failed} predicate={value} "
                   f"sampled={sampled} at_action={action} final={final}"]
    return "\n".join(result) + "\n"


def make_case(row: Row) -> Case:
    width, state, value, expression, edge, update, timing, home = row
    w = int(width)
    name = case_name(row)
    inactive, active = ("0", "1") if edge == "posedge" else ("1", "0")
    expr = {"reduce_or": "(|data)", "equal": "(data == '0)",
            "case_equal": "(data === '0)"}[expression]
    declarations = [f"  {state} [{w - 1}:0] data;",
                    f"  logic [{w - 1}:0] seen_sample, seen_live;",
                    "  logic seen_predicate;", "  int passed = 0, failed = 0;"]
    assertion = [f"  check_value: assert property (@({edge} clk) {expr})", "    begin",
                 "      passed++;", "      seen_sample = $sampled(data);",
                 f"      seen_predicate = $sampled({expr});", "      seen_live = data;",
                 "    end else begin", "      failed++;", "      seen_sample = $sampled(data);",
                 f"      seen_predicate = $sampled({expr});", "      seen_live = data;", "    end"]
    lines = ["`timescale 1ns/1ns"]
    if home == "module":
        lines += [f"module {name};", f"  bit clk = 1'b{inactive};", *declarations, *assertion]
        prefix = ""
    else:
        site = name + "_site"
        lines += [f"interface {site}(", "  input bit clk", ");", *declarations, *assertion,
                  "endinterface", f"module {name};", f"  bit clk = 1'b{inactive};",
                  f"  {site} site(", "    clk", "  );"]
        prefix = "site."
    storage = prefix + "data"
    assignment = f"{storage} {'<=' if update == 'nba' else '='} incoming;"
    lines += [f"  logic [{w - 1}:0] incoming;"]
    if timing == "edge":
        lines += [f"  always @({edge} clk) {assignment}"]
    lines += ["  initial begin"]
    for label, before, incoming in phases(row):
        lines += [f"    {storage} = {literal(before)};", f"    incoming = {literal(incoming)};",
                  f'    $display("{label} before=%b source=%b", {storage}, incoming);', "    #1;"]
        if timing == "before":
            lines += ["    " + assignment]
        lines += ["    #1;", f"    clk = 1'b{active};", "    #1;"]
        if timing == "after":
            lines += ["    " + assignment]
        lines += ["    #1;",
                  f'    $display("{label} pass=%0d fail=%0d predicate=%b sampled=%b at_action=%b final=%b",',
                  f"             {prefix}passed, {prefix}failed, {prefix}seen_predicate,",
                  f"             {prefix}seen_sample, {prefix}seen_live, {storage});",
                  f"    clk = 1'b{inactive};", "    #1;"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Concurrent assertion samples and Reactive action values straddle typed blocking/NBA updates",
        "16.5.1 16.9.3 16.14.1 4.4.2 6.11.2 10.4.1 10.4.2 11.4.5 11.4.9" +
        (" 25.3" if home == "interface" else ""),
        "Each isolated edge starts with stable typed data and a prepared raw input. "
        "The input is assigned one tick before the edge, in its module Active/NBA "
        "region, or one tick later. A static concurrent assertion evaluates a single "
        "Boolean expression on Preponed values. Both pass and fail actions record "
        "the sampled data, sampled one-bit predicate and live data in Reactive; the "
        "stimulus prints them and cumulative action counts two ticks after the edge. "
        "Known zero/one and complementary backgrounds supply positive and negative "
        "controls. X/Z rows also test unknown-to-known and known-to-unknown updates; "
        "bit storage converts unknowns before any sampling. No delayed property, "
        "vacuous implication, disable condition or assertion control is used. "
        "Module and interface declarations use the same stimulus and expectations.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
