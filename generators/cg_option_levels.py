"""Generates illegal designs that assign a coverage option in the body of a
coverpoint or a cross at which the option cannot be specified, one for each
"No" cell of Table 19-2 (instance options, 19.7) and Table 19-4 (type
options, 19.7.1) of IEEE 1800-2023.

The reference model is the two tables: for each option, whether it can be
specified at the covergroup, coverpoint and cross syntactic levels. 19.10
declares option and type_option of a covergroup, a coverpoint and a cross as
implicit structures, and the members of each structure are the options that
the table allows at that level; the generator checks that the cells and the
members agree, and that the covergroup structures hold every option of Table
19-1 and Table 19-3. A "No" cell is therefore a member that the option
structure of that level does not have, and an assignment to it in the body of
a coverpoint or a cross is an error that a tool has to report at that
assignment. Each design has one such assignment, with a value of the type
19.10 gives the member at the levels that have it, and is legal otherwise.

The covergroup column has no "No" cell. The "Yes" cells are legal designs,
whose effects other tests check, and the rules of 19.7 and 19.7.1 on which
options can be assigned procedurally after construction are other rules; none
of them is generated here.
"""

import textwrap

from common import Case

NAME = "cg_option_levels"
VERSION = 1
CHAPTER = 19

LEVELS = ("covergroup", "coverpoint", "cross")

# Table 19-1 and Table 19-3: the instance options and the type options.
TABLE_19_1 = ("name weight goal comment at_least auto_bin_max cross_num_print_missing "
              "cross_retain_auto_bins detect_overlap per_instance get_inst_coverage").split()
TABLE_19_3 = "weight goal comment strobe merge_instances distribute_first real_interval".split()

# Table 19-2 and Table 19-4: whether each option can be specified at the
# covergroup, coverpoint and cross levels.
Y, N = True, False
TABLE_19_2 = {
    "name": (Y, N, N),
    "weight": (Y, Y, Y),
    "goal": (Y, Y, Y),
    "comment": (Y, Y, Y),
    "at_least": (Y, Y, Y),
    "auto_bin_max": (Y, Y, N),
    "cross_num_print_missing": (Y, N, Y),
    "cross_retain_auto_bins": (Y, N, Y),
    "detect_overlap": (Y, Y, N),
    "per_instance": (Y, N, N),
    "get_inst_coverage": (Y, N, N),
}
TABLE_19_4 = {
    "weight": (Y, Y, Y),
    "goal": (Y, Y, Y),
    "comment": (Y, Y, Y),
    "strobe": (Y, N, N),
    "merge_instances": (Y, N, N),
    "distribute_first": (Y, N, N),
    "real_interval": (Y, Y, N),
}

# 19.10: the members of the implicit option and type_option structures, with
# their types.
STRUCTS_19_10 = {
    ("option", "covergroup"): {
        "name": "string", "weight": "int", "goal": "int", "comment": "string",
        "at_least": "int", "auto_bin_max": "int", "cross_num_print_missing": "int",
        "cross_retain_auto_bins": "bit", "detect_overlap": "bit", "per_instance": "bit",
        "get_inst_coverage": "bit"},
    ("option", "coverpoint"): {
        "weight": "int", "goal": "int", "comment": "string", "at_least": "int",
        "auto_bin_max": "int", "detect_overlap": "bit"},
    ("option", "cross"): {
        "weight": "int", "goal": "int", "comment": "string", "at_least": "int",
        "cross_num_print_missing": "int", "cross_retain_auto_bins": "bit"},
    ("type_option", "covergroup"): {
        "weight": "int", "goal": "int", "comment": "string", "strobe": "bit",
        "merge_instances": "bit", "distribute_first": "bit", "real_interval": "real"},
    ("type_option", "coverpoint"): {
        "weight": "int", "goal": "int", "comment": "string", "real_interval": "real"},
    ("type_option", "cross"): {
        "weight": "int", "goal": "int", "comment": "string"},
}

KINDS = {"option": (TABLE_19_1, TABLE_19_2, "19-2", "19.7"),
         "type_option": (TABLE_19_3, TABLE_19_4, "19-4", "19.7.1")}

# A value of each member type; a type option takes a constant expression
# (19.7.1), and a literal is one.
VALUE = {"string": '"p"', "int": "2", "bit": "1", "real": "0.5"}

# The item that has the assignment, by level.
ITEM = {"coverpoint": "cp", "cross": "x"}

# What the 5.054 release of Verilator does with the cases. common.render wraps
# the comment, and a comment line that starts with the word Verilator is a
# directive to it, so the first remark with which no line starts with the
# word is used.
_WARNING = ("that it ignores an unsupported coverage option, as it does for options the "
            "level allows, such as option.comment, and accepts the design. Neither is "
            "evidence for the rule, and the cited clauses alone decide this case.")
SIMULATOR_REMARKS = (" The 5.054 release of Verilator warns at the assignment " + _WARNING,
                     " At the assignment, the 5.054 release of Verilator warns " + _WARNING,
                     " There, the 5.054 release of Verilator only warns " + _WARNING)


def check_model() -> None:
    no_cells = 0
    for kind, (options, table, _, _) in KINDS.items():
        assert list(table) == options, kind
        for column, level in enumerate(LEVELS):
            allowed = {o for o in options if table[o][column]}
            members = STRUCTS_19_10[kind, level]
            assert allowed == set(members), (kind, level, allowed ^ set(members))
            no_cells += len(options) - len(allowed)
        assert set(STRUCTS_19_10[kind, "covergroup"]) == set(options), kind
        for level in LEVELS:
            for member, type_ in STRUCTS_19_10[kind, level].items():
                assert type_ == STRUCTS_19_10[kind, "covergroup"][member], (kind, member)
    assert no_cells == 17, no_cells


def allowed_levels(kind: str, member: str) -> str:
    """The levels that allow the option, as "the covergroup level" or "the
    covergroup and cross levels"."""
    table = KINDS[kind][1]
    levels = [level for column, level in enumerate(LEVELS) if table[member][column]]
    return "the " + " and ".join(levels) + (" levels" if len(levels) > 1 else " level")


def body(name: str, kind: str, member: str, level: str) -> str:
    assignment = f"{kind}.{member} = {VALUE[STRUCTS_19_10[kind, 'covergroup'][member]]};"
    if level == "coverpoint":
        items = ("    cp: coverpoint a {\n"
                 f"      {assignment}  // illegal\n"
                 "    }\n"
                 "    cq: coverpoint b;\n"
                 "    x: cross cp, cq;\n")
    else:
        items = ("    cp: coverpoint a;\n"
                 "    cq: coverpoint b;\n"
                 "    x: cross cp, cq {\n"
                 f"      {assignment}  // illegal\n"
                 "    }\n")
    return (f"module {name};\n"
            "  bit [1:0] a, b;\n"
            "\n"
            "  covergroup cg;\n"
            f"{items}"
            "  endgroup\n"
            "\n"
            "  cg g = new;\n"
            "\n"
            "  initial begin\n"
            "    a = 1;\n"
            "    b = 2;\n"
            "    g.sample();\n"
            "  end\n"
            "endmodule\n")


def comment(kind: str, member: str, level: str) -> str:
    _, _, table, clause = KINDS[kind]
    item = ITEM[level]
    text = (f"IEEE 1800-2023 §{clause}: Table {table} allows {kind}.{member} only at "
            f"{allowed_levels(kind, member)}, not at the {level} level, and the "
            f"{kind} structure that 19.10 declares for a {level} has no member {member}. "
            f"The design assigns {kind}.{member} in the body of {level} {item}, the only "
            f"error, which a tool has to report at that assignment; the rest of the "
            f"covergroup is legal.")
    if kind == "option" and member == "cross_retain_auto_bins":
        text += (" 19.7 also says that this option can only be set in the covergroup or "
                 "coverpoint definition, which names the coverpoint where Table 19-2 has "
                 "No. That sentence sets the definition against procedural assignment "
                 "after construction, as 19.7.1 does when it says that real_interval can "
                 "only be set in the covergroup definition, which Table 19-4 and 19.10 "
                 "nevertheless allow in a coverpoint. It declares no member, and the "
                 "coverpoint structure of 19.10 has none, so Table 19-2 and 19.10 decide "
                 "the level here.")
    text += (" Icarus Verilog 13.0 does not implement covergroups, and its syntax errors "
             "fall on every line of the construct.")
    for remark in SIMULATOR_REMARKS:
        candidate = text + remark
        if not any(line.startswith("Verilator") for line in textwrap.wrap(candidate, 77)):
            return candidate
    raise AssertionError(f"a comment line of {kind}.{member} at {level} starts with Verilator")


def case(kind: str, member: str, level: str) -> Case:
    name = f"test_gen_cglevel_{kind}_{member}_{level}"
    _, _, table, clause = KINDS[kind]
    return Case(
        name=name,
        description=f"{kind}.{member}, which Table {table} does not allow at the {level} "
                    f"level, is assigned in the body of a {level}",
        lrm=f"{clause} 19.10",
        comment=comment(kind, member, level),
        body=body(name, kind, member, level),
        expected="",
        should_fail_because=f"Table {table} allows {kind}.{member} only at "
                            f"{allowed_levels(kind, member)}, and the {kind} "
                            f"structure of a {level} (19.10) has no member {member}, so the "
                            f"assignment in the body of {level} {ITEM[level]} is an error",
        # Icarus rejects every covergroup line, so its error at this line is
        # no evidence of the intended one.
        unregistered=("icarus",),
    )


def cases() -> list[Case]:
    check_model()
    out = []
    for kind, (options, table, _, _) in KINDS.items():
        for member in options:
            for column, level in enumerate(LEVELS):
                if not table[member][column]:
                    out.append(case(kind, member, level))
    return out
