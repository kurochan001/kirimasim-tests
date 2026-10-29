"""Cross explicit casts with later arithmetic and final state conversion.

6.24.1 defines a cast as an intermediate typed value. Size casts preserve
the source sign, signing casts preserve width, and typed bit casts convert
X/Z before the later operation. 11.6/11.8 then size the outer expression.
"""

from common import Case
from interaction_bits import pattern, resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_cast"
VERSION = 1
CHAPTER = 6


def legal(row: Row) -> bool:
    return ((row[3] not in ("signed", "unsigned") or row[4] == "same")
            and (row[0] != "1" or row[4] != "narrow"))


MODEL = Model(
    "cast_pipeline",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("sign", ("unsigned", "signed")), ("value", ("known", "x", "z")),
     ("cast", ("size", "signed", "unsigned", "typed_bit", "typed_logic")),
     ("cast_width", ("narrow", "same", "wide")), ("operation", ("plain", "add")),
     ("state", ("bit", "logic"))),
    legal,
    groups=(("cast", "value", "operation"), ("width", "sign", "state"),
            ("cast", "cast_width", "sign")),
    anchors=(("129", "signed", "x", "typed_bit", "narrow", "add", "logic"),
             ("65", "signed", "z", "size", "wide", "plain", "logic"),
             ("33", "signed", "known", "size", "narrow", "add", "bit")),
    constraints=("signing castは幅を変えないのでcast_width=same。幅1のnarrowは除外。"
                 "代入先は元の幅+2。typed castの型はunsigned",),
)


def case_name(row: Row) -> str:
    w, sign, value, cast, relation, operation, state = row
    return f"test_gen_cross_cast_w{w}_{sign[0]}_{value[0]}_{cast}_{relation[0]}_{operation}_{state[0]}"


def reference(row: Row) -> tuple[str, str, str]:
    w, sign, value, cast, relation, operation, state = row
    w = int(w)
    cw = w + {"narrow": -1, "same": 0, "wide": 1}[relation]
    source = pattern(w, value)
    signed = sign == "signed"
    if cast in ("signed", "unsigned"):
        intermediate = source
        signed = cast == "signed"
    else:
        intermediate = resize(source, cw, signed)
        if cast.startswith("typed_"):
            signed = False
            if cast == "typed_bit":
                intermediate = two_state(intermediate)
    result = resize(intermediate, w + 2, signed)
    if operation == "add":
        result = ("x" * (w + 2) if any(c in "xz" for c in result)
                  else f"{(int(result, 2) + 1) & ((1 << (w + 2)) - 1):0{w + 2}b}")
    return source, intermediate, two_state(result) if state == "bit" else result


def make_case(row: Row) -> Case:
    w, sign, value, cast, relation, operation, state = row
    w = int(w)
    cw = w + {"narrow": -1, "same": 0, "wide": 1}[relation]
    source, intermediate, result = reference(row)
    name = case_name(row)
    expr = (f"{cw}'(source)" if cast == "size" else
            "cast_t'(source)" if cast.startswith("typed_") else f"{cast}'(source)")
    lines = [f"module {name};", f"  logic {sign} [{w - 1}:0] source;",
             f"  {state} [{w + 1}:0] result;"]
    if cast.startswith("typed_"):
        lines.append(f"  typedef {cast[6:]} [{cw - 1}:0] cast_t;")
    lines += ["  initial begin", f"    source = {literal(source)};",
              f"    result = {expr}" + (" + 2'sb01;" if operation == "add" else ";"),
              '    $display("source=%b", source);', f'    $display("cast=%b", {expr});',
              '    $display("result=%b", result);', "    $finish;", "  end", "endmodule"]
    return Case(
        name, "Explicit cast conversion occurs before outer arithmetic and destination conversion",
        "6.24.1 6.11.2 11.6.1 11.8.1 11.8.2",
        "The cast makes an intermediate value before the outer assignment context applies. "
        "Size casts keep the source sign; signing casts keep its width; typed unsigned "
        "casts resize as assignments, with bit converting X/Z immediately. The optional "
        "addition uses signed two-bit positive one, preserving a signed cast's arithmetic "
        "sign. Output shows source, intermediate cast and final width+2 result separately.",
        "\n".join(lines), f"source={source}\ncast={intermediate}\nresult={result}\n",
        fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
