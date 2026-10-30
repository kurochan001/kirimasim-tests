"""Finite source-context matrix for heap-backed file monitor lifetimes.

Every row has a monitor whose arguments refer only to static container and
selector variables. Changes settle in Postponed; file contents, including
the absence of output after closure, are read back by the design itself.
Native scheduler callback reentry is a separate, unconfirmed API question.
"""

from common import Case
from interaction_cover import Model, Row

NAME = "combination_monitors"
VERSION = 1
CHAPTER = 21
ISSUE = "https://github.com/kurochan001/kirimasim-tests/issues/21"
CONTEXTS = ("initial", "task", "function", "fork", "generate", "interface",
            "program", "package", "always")

MODEL = Model(
    "heap_file_monitor_context",
    (("context", CONTEXTS), ("storage", ("queue", "dynamic")),
     ("descriptor", ("mcd", "fd"))),
    lambda row: True,
    anchors=(("program", "dynamic", "mcd"),
             ("package", "queue", "fd"),
             ("function", "queue", "mcd")),
    constraints=("全36行は合法。contextは登録を行う場所で、監視対象はstatic変数。"
                 "programには別の存続プロセスを置く。各行で選択・サイズ・置換・"
                 "同時刻の複数更新・monitoroff・close後不出力を観測する。"
                 "native callbackからの再入・再配置は別の未確認API範囲",),
)


def case_name(row: Row) -> str:
    context, storage, descriptor = row
    return f"test_gen_comb_file_monitor_{storage}_{descriptor}_{context}"


def expected_lines() -> list[str]:
    """Project selected values and sizes, then suppress unchanged arguments."""
    samples = ((1, [4, 8], 0), (2, [7, 8], 0), (3, [7, 9], 0),
               (4, [7, 9], 1), (5, [2, 3, 5], 1), (6, [2, 11, 5], 1))
    previous = None
    output = []
    for time, values, index in samples:
        current = values[index], len(values)
        if current != previous:
            output.append(f"original:{time} v={current[0]} n={current[1]}")
        previous = current
    return output + ["original:end", "replacement:replacement", "replacement:end"]


def monitor_statement(prefix: str = "") -> str:
    # Keep long hierarchical names on separate lines, including the index.
    return ("    $fmonitor(\n"
            f"      {prefix}out,\n"
            '      "%0d v=%0d n=%0d", $time,\n'
            f"      {prefix}values[\n"
            f"        {prefix}pick],\n"
            f"      {prefix}values.size());")


def make_case(row: Row) -> Case:
    context, storage, descriptor = row
    name = case_name(row)
    container = "int values[$];" if storage == "queue" else "int values[];"
    fields = (f"  {container}\n  int out, pick;\n"
              "  bit ready = 0, installed = 0;")
    monitor = monitor_statement()
    definitions = ""
    scope_items = ""
    invocation = ""
    if context == "package":
        package = name + "_state"
        definitions = (f"package {package};\n{fields}\n"
                       "  function void install();\n" + monitor + "\n"
                       "    installed = 1;\n  endfunction\nendpackage\n")
        fields = f"  import {package}::*;"
        invocation = "    install();"
    elif context in ("interface", "program"):
        helper = name + "_site"
        prefix = name + "."
        end_kind = "endinterface" if context == "interface" else "endprogram"
        definitions = (f"{context} {helper};\n  initial begin\n"
                       f"    wait ({prefix}ready);\n" + monitor_statement(prefix) + "\n"
                       f"    {prefix}installed = 1;\n  end\n")
        if context == "program":
            definitions += "  initial #30;\n"
        definitions += end_kind + "\n"
        scope_items = f"  {helper} site();\n"
    elif context in ("task", "function"):
        declaration = ("task automatic install();" if context == "task" else
                       "function void install();")
        ending = "endtask" if context == "task" else "endfunction"
        scope_items = ("  " + declaration + "\n" + monitor + "\n"
                       "    installed = 1;\n  " + ending + "\n")
        invocation = "    install();"
    elif context == "generate":
        scope_items = ("  if (1) begin : generated_site\n    initial begin\n"
                       "      wait (ready);\n" + monitor + "\n"
                       "      installed = 1;\n    end\n  end\n")
    elif context == "always":
        scope_items = ("  always @(posedge ready) begin\n" + monitor + "\n"
                       "    installed = 1;\n  end\n")
    elif context == "fork":
        invocation = ("    fork\n      begin\n" + monitor + "\n"
                      "        installed = 1;\n      end\n    join_none")
    else:
        invocation = monitor + "\n    installed = 1;"

    initial_values = ("    values = '{0,8};" if storage == "queue" else
                      "    values = new[2]; values[0] = 0; values[1] = 8;")
    replacement = ("    values = '{2,3,5};" if storage == "queue" else
                   "    values = new[3]; values[0] = 2; values[1] = 3; values[2] = 5;")
    mode = ", \"w\"" if descriptor == "fd" else ""
    original_file = name + ".log"
    replacement_file = name + ".closed"
    body = ("`timescale 1ns/1ns\n" + definitions + f"module {name};\n" + fields + "\n"
            + scope_items + """  task show(input string label, input string filename);
    int rd;
    string line;
    rd = $fopen(filename, "r");
    if (rd == 0) $fatal(1, "missing output file");
    while ($fgets(line, rd) != 0) $write("%s:%s", label, line);
    $fclose(rd);
    $display("%s:end", label);
  endtask
  initial begin
""" + initial_values + "\n    pick = 0;\n"
            + f'    out = $fopen("{original_file}"{mode});\n'
            + '    if (out == 0) $fatal(1, "cannot open monitor output");\n'
            + "    #1 ready = 1;\n" + invocation + "\n"
            + """    wait (installed);
    values[0] = 4;
    #1 values[0] = 6; values[0] = 7;
    #1 values[1] = 9;
    #1 pick = 1;
    #1;
""" + replacement + "\n"
            + "    #1 $monitoroff; values[1] = 11;\n"
            + "    #1 $fclose(out);\n"
            + f'    out = $fopen("{replacement_file}"{mode});\n'
            + '    if (out == 0) $fatal(1, "cannot reopen output");\n'
            + '    $fdisplay(out, "replacement");\n'
            + "    values[1] = 13;\n    #1 values[1] = 17;\n"
            + "    #1 $fclose(out);\n    #1;\n"
            + f'    show("original", "{original_file}");\n'
            + f'    show("replacement", "{replacement_file}");\n'
            + "    $finish;\n  end\nendmodule\n")
    return Case(
        name, "Heap-backed file monitors retain source-context-independent values and cancellation",
        "21.3.2 21.2.3 21.3.1 21.3.4.2 4.4.2.9 "
        + ("7.10" if storage == "queue" else "7.5.1"),
        "The registration reads static container and selector variables. Installation is "
        "acknowledged before the first data write, avoiding startup races in every "
        "context. Two selected writes in one time produce one final Postponed value. "
        "An unrelated cell changes without adding a line; selection and whole-container "
        "replacement then change the watched expression. File monitoring continues "
        "under monitoroff. Closing its descriptor cancels it before further heap writes "
        "and another file is opened. Both artifacts are read back. No descriptor number "
        "or callback evaluation order is fixed. Native callback reentry and allocation "
        "during callback dispatch are separate unconfirmed implementation-API scopes.",
        body, "\n".join(expected_lines()) + "\n",
        extra={"issue": ISSUE, "combination_gap": "U01", "top_module": name,
               "interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
