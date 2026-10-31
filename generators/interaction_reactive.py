"""Module NBA fixed points, Reactive program sampling and Re-NBA readback."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_reactive"
VERSION = 1
CHAPTER = 24

MODEL = Model(
    "program_reactive_handoff",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("source_state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("depth", ("1", "2", "3")), ("update", ("blocking", "nba")),
     ("producer", ("continuous", "blocking", "nba")), ("operation", ("direct", "invert"))),
    lambda row: True,
    groups=(("width", "source_state", "value"), ("depth", "update", "producer"),
            ("update", "producer", "operation"), ("producer", "source_state", "value")),
    anchors=(("1", "bit", "known", "1", "blocking", "continuous", "direct"),
             ("129", "logic", "z", "3", "nba", "nba", "invert"),
             ("65", "logic", "x", "2", "blocking", "blocking", "invert"),
             ("33", "bit", "z", "3", "nba", "continuous", "invert"),
             ("32", "logic", "known", "2", "nba", "blocking", "direct"),
             ("64", "bit", "known", "1", "blocking", "nba", "invert")),
    constraints=("1296行はすべて合法で未対応による除外なし。moduleのsource更新から1/2/3段のNBA連鎖を起こす。"
                 "programは連続代入またはイベント待機後のblocking/NBAで出力する。module内の同じ式は早い対照。"
                 "16回の既知刺激でビット位置を識別し、X/Zの各刺激直前には全1を与えて変化を保証する。"
                 "各刺激を10時刻離し、1時刻後に値と採取済み文脈を観測する。自動変数へのNBA、clocking、"
                 "複数書込みの競合、同時刻の外部刺激は対象外",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_reactive_" + "_".join(row)


def stimuli(row: Row) -> list[str]:
    width = int(row[0])
    result = []
    for phase in range(8):
        bits = "".join(str(((bit+1) >> phase) & 1) for bit in range(width-1, -1, -1))
        result += [bits, bits.translate(str.maketrans("01", "10"))]
    if row[2] != "known":
        for phase in range(3):
            result.append("1"*width)
            bits = result[2*phase]
            bad = {0, width-1, (phase+1) % width}
            result.append("".join(row[2] if width-1-i in bad else bit for i, bit in enumerate(bits)))
    return result


def source_value(row: Row, raw: str) -> str:
    return raw.translate(str.maketrans("xz", "00")) if row[1] == "bit" else raw


def expression(row: Row, bits: str) -> str:
    return bits.translate(str.maketrans("01xz", "10xx")) if row[6] == "invert" else bits


def stage_words(row: Row, source: str) -> list[str]:
    result, width = [], len(source)
    for stage in range(int(row[3])):
        source = "".join("x" if bit in "xz" else str(int(bit) ^ (((stage+1) >> (width-1-i)) & 1))
                         for i, bit in enumerate(source))
        result.append(source)
    return result


def reference(row: Row) -> str:
    width, depth = int(row[0]), int(row[3])
    src = sampled = "0"*width
    stages = stage_words(row, src)
    last_sample = stages[-1]
    output = captured = expression(row, src)
    steps = visits = early = late = sample_steps = 0
    lines = []
    for epoch, raw in enumerate(stimuli(row)):
        time = (epoch+1)*10
        new = source_value(row, raw)
        target = expression(row, new)
        if new != src:
            if target != output:
                early += 1
                lines += [f"early t={time} value={target} last={stages[-1]}"]
            steps += depth
            visits += 1
            stages = stage_words(row, new)
            sampled, last_sample = new, stages[-1]
            sample_steps = steps
            captured = output if row[5] == "nba" else target
            if target != output:
                late += 1
                lines += [f"late t={time} value={target} last={stages[-1]} steps={steps}"]
        src, output = new, target
        lines += [f"p{epoch} t={time+1} raw={raw} source={src} out={output} "
                  f"early={early} late={late} steps={steps}",
                  f"p{epoch} stages " + " ".join(f"s{i}={bits}" for i, bits in enumerate(stages)),
                  f"p{epoch} program captured={captured} sampled={sampled} last={last_sample} "
                  f"steps={sample_steps} visits={visits}"]
    return "\n".join(lines) + "\n"


def producer_block(row: Row) -> list[str]:
    name = case_name(row)
    producer, invert = row[5], row[6] == "invert"
    expr, initial = ("~src", "'1") if invert else ("src", "'0")
    kind = "wire" if producer == "continuous" else "logic"
    lines = ["program region_producer #(parameter int W = 1)(",
             f"  input wire [W-1:0] src, output {kind} [W-1:0] y,",
             "  output logic [W-1:0] captured, sampled_src, sampled_last,",
             "  output int sampled_steps, visits);"]
    if producer == "continuous":
        lines += [f"  assign y = {expr};", "  initial begin"]
    else:
        assign = "<=" if producer == "nba" else "="
        lines += ["  initial begin", f"    y {assign} {initial};"]
    zero_stage = stage_words(row, "0"*int(row[0]))[-1]
    lines += [f"    captured = {initial};", "    sampled_src = '0;", f"    sampled_last = {literal(zero_stage)};",
              "    sampled_steps = 0; visits = 0;",
              "    forever begin", "      @(src);", "      if ($time > 0) begin"]
    if producer != "continuous":
        lines += [f"        y {assign} {expr};"]
    lines += [f"        captured = {expr if producer == 'continuous' else 'y'};",
              "        sampled_src = src;", "        sampled_last =", f"          {name}.s{int(row[3])-1};",
              "        sampled_steps =", f"          {name}.module_steps;", "        visits++;",
              "      end", "    end", "  end", "endprogram"]
    return lines


def make_case(row: Row) -> Case:
    width, state, value, depth, update, producer, operation = row
    w, n, name = int(width), int(depth), case_name(row)
    expr = "~source" if operation == "invert" else "source"
    lines = ["`timescale 1ns/1ns", *producer_block(row), f"module {name};",
             f"  logic [{w-1}:0] raw = '0;", f"  {state} [{w-1}:0] source = '0;",
             *[f"  logic [{w-1}:0] s{i} = {literal(bits)};"
               for i, bits in enumerate(stage_words(row, "0"*w))],
             f"  wire [{w-1}:0] tap, result;", "  int module_steps = 0, early_count = 0, late_count = 0;",
             f"  wire [{w-1}:0] captured, sampled_src, sampled_last;",
             "  wire signed [31:0] sampled_steps, visits;",
             "  region_producer #(.W(" + width + ")) p(.src(source), .y(result),",
             "    .captured(captured), .sampled_src(sampled_src), .sampled_last(sampled_last),",
             "    .sampled_steps(sampled_steps), .visits(visits));", f"  assign tap = {expr};"]
    for i in range(n):
        prior = "source" if i == 0 else f"s{i-1}"
        lines += [f"  always @({prior}) if ($time > 0) begin", f"    s{i} <= {prior} ^ {w}'d{i+1};",
                  "    module_steps++;", "  end"]
    lines += ["  always @(tap) if ($time > 0) begin", "    early_count++;",
              f'    $display("early t=%0d value=%b last=%b", $time, tap, s{n-1});', "  end",
              "  always @(result) if ($time > 0) begin", "    late_count++;",
              '    $display("late t=%0d value=%b last=%b steps=%0d",',
              f"             $time, result, s{n-1}, module_steps);", "  end", "  initial begin"]
    for epoch, raw in enumerate(stimuli(row)):
        lines += [f"    #{10 if epoch == 0 else 9};", f"    raw = {literal(raw)};",
                  "    source " + ("<=" if update == "nba" else "=") + " raw;", "    #1;",
                  f'    $display("p{epoch} t=%0d raw=%b source=%b out=%b early=%0d late=%0d steps=%0d",',
                  "             $time, raw, source, result, early_count, late_count, module_steps);",
                  f'    $display("p{epoch} stages ' + " ".join(f"s{i}=%b" for i in range(n)) + '",',
                  "             " + ", ".join(f"s{i}" for i in range(n)) + ");",
                  f'    $display("p{epoch} program captured=%b sampled=%b last=%b steps=%0d visits=%0d",',
                  "             captured, sampled_src, sampled_last, sampled_steps, visits);"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Program output and sampling wait for the module NBA fixed point and preserve Re-NBA readback",
        "24.3.1 24.3.2 4.4.2.4 4.4.2.6 4.4.2.8 4.5 10.4.2 6.11.2 11.4.8",
        "A module updates a bit/logic source by blocking or nonblocking "
        "assignment and propagates each change through one/two/three NBA "
        "stages. Stage i XORs its input with the width-sized value i+1, so "
        "source and intermediate values are distinguishable. An equal "
        "module expression is the early control; its output "
        "event must see the previous final stage. A program produces direct "
        "or complemented output by continuous assignment, blocking assignment "
        "or NBA. Its context sampler reads the actual module final stage and "
        "step count hierarchically after the active-region fixed point. "
        "Immediately after program NBA, captured retains the previous output; "
        "blocking/continuous cases capture the new value. Early and late "
        "output events, every stage and all sampled context are observed. "
        "No-op source writes must not cause visits. Sixteen known frames "
        "identify every bit; each X/Z frame follows an all-ones control. "
        "Epochs are ten time units apart, with snapshots one unit after "
        "each write. Automatic-variable NBA, clocking, conflicting writers "
        "and simultaneous external updates are outside this model.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{key}={val}" for key, val in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
