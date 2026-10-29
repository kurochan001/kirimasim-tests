"""Cross packed member layout, whole/member signs and update mechanisms.

7.2.1 places the first member at the MSB; whole and member expressions
have their own signedness. The oracle assembles strings and extends each
expression independently. A fixed tag exposes writes beyond the payload.
"""

from common import Case
from interaction_bits import pattern, resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_struct"
VERSION = 1
CHAPTER = 7

MODEL = Model(
    "packed_structure",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("layout", ("first", "last")), ("aggregate_sign", ("unsigned", "signed")),
     ("member_sign", ("unsigned", "signed")), ("state", ("bit", "logic")),
     ("value", ("known", "x", "z")), ("access", ("member", "whole")),
     ("update", ("blocking", "nba"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("layout", "access", "update"),
            ("aggregate_sign", "member_sign", "layout")),
    anchors=(("129", "first", "signed", "unsigned", "logic", "z", "whole", "nba"),
             ("65", "last", "unsigned", "signed", "logic", "x", "member", "nba"),
             ("33", "first", "signed", "signed", "bit", "x", "member", "blocking")),
    constraints=("payloadと3ビットのtagは同じ2/4状態型。tagは101に固定。"
                 "拡張先はpayload幅+4。パック構造体はstaticで、NBA後は#1で観測",),
)


def case_name(row: Row) -> str:
    w, layout, aggregate, member, state, value, access, update = row
    return (f"test_gen_cross_struct_w{w}_{layout[0]}_{aggregate[0]}{member[0]}_"
            f"{state[0]}_{value[0]}_{access[0]}_{update[0]}")


def reference(row: Row) -> tuple[str, str, str, str, str, str]:
    w, layout, aggregate, member, state, value, _, update = row
    w = int(w)
    source = pattern(w, value)
    payload = two_state(source) if state == "bit" else source
    before = ("".join("0" if c == "1" else "1" for c in source) if value == "known"
              else ("1" if state == "bit" else "0") * w)
    pack = lambda p: p + "101" if layout == "first" else "101" + p
    scheduled = pack(before) if update == "nba" else pack(payload)
    return (source, before, scheduled, pack(payload),
            resize(payload, w + 4, member == "signed"),
            resize(pack(payload), w + 4, aggregate == "signed"))


def make_case(row: Row) -> Case:
    w, layout, aggregate, member, state, value, access, update = row
    w = int(w)
    source, before, scheduled, final, member_out, whole_out = reference(row)
    name = case_name(row)
    payload = f"    {state} {member} [{w - 1}:0] payload;"
    tag = f"    {state} [2:0] tag;"
    fields = [payload, tag] if layout == "first" else [tag, payload]
    destination = "packet.payload" if access == "member" else "packet"
    rhs = "source" if access == "member" else (
        "{source, 3'b101}" if layout == "first" else "{3'b101, source}")
    assign = "<=" if update == "nba" else "="
    lines = ["`timescale 1ns/1ns", f"module {name};", f"  typedef struct packed {aggregate} {{",
             *fields, "  } packet_t;", "  packet_t packet;", f"  logic [{w - 1}:0] source;",
             f"  logic [{w + 3}:0] member_out, whole_out;", "  initial begin",
             f"    packet.payload = {literal(before)};", "    packet.tag = 3'b101;",
             f"    source = {literal(source)};", f"    {destination} {assign} {rhs};",
             '    $display("scheduled=%b", packet);', "    source = '1;", "    #1;",
             "    member_out = packet.payload;", "    whole_out = packet;",
             '    $display("packet=%b payload=%b tag=%b", packet, packet.payload, packet.tag);',
             '    $display("member=%b whole=%b", member_out, whole_out);',
             "    $finish;", "  end", "endmodule"]
    captured = two_state(source) if state == "bit" else source
    return Case(
        name, "Packed layout, field signs and whole/member updates preserve values and tag",
        "7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2",
        "The first declared member occupies the MSBs. A member write must preserve the tag; "
        "a whole write explicitly carries that same tag. Source mutation follows the write. "
        "The scheduled observation distinguishes blocking from NBA updates. After #1, "
        "separate wide assignments check the member's sign and the aggregate's sign. "
        "All members have the same state type; bit storage converts X/Z on assignment.",
        "\n".join(lines), f"scheduled={scheduled}\npacket={final} payload={captured} tag=101\n"
        f"member={member_out} whole={whole_out}\n", fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
