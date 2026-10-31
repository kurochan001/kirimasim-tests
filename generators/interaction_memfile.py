"""Typed memory files, explicit ranges, independent input and guarded destinations."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_memfile"
VERSION = 1
CHAPTER = 21

MODEL = Model(
    "typed_memory_file",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("source_state", ("bit", "logic")), ("kind", ("plain", "enum")),
     ("value", ("known", "x", "z")), ("format", ("bin", "hex")),
     ("span", ("all", "middle", "single")), ("declaration", ("up", "down")),
     ("target_state", ("bit", "logic")), ("read_order", ("forward", "reverse"))),
    lambda row: row[5] != "single" or row[8] == "forward",
    groups=(("width", "source_state", "value"), ("kind", "source_state", "value"),
            ("format", "value", "target_state"), ("kind", "format", "span"),
            ("declaration", "read_order", "span")),
    anchors=(("1", "bit", "plain", "known", "bin", "all", "up", "logic", "forward"),
             ("129", "logic", "enum", "z", "hex", "middle", "down", "bit", "reverse"),
             ("65", "logic", "plain", "x", "bin", "all", "down", "logic", "reverse"),
             ("33", "bit", "enum", "x", "hex", "single", "up", "logic", "forward"),
             ("32", "logic", "enum", "known", "bin", "middle", "up", "bit", "reverse"),
             ("64", "bit", "plain", "known", "hex", "all", "down", "bit", "forward")),
    constraints=("固定1次元配列を使う。singleの逆順は開始/終了が同じで等価なため順方向に代表させ、"
                 "576行を重複削減して2880行とする。全行は合法で未対応による除外なし。"
                 "元配列は[2:6]、書込みは2:6/3:5/4:4、読込み先は[10:16]または[16:10]で"
                 "11からの1/3/5要素だけを更新する。enumへの格納は明示キャスト。未知値はニブル単位に揃え、"
                 "hexでの部分ニブルの情報損失を混ぜない。動的/連想配列・多次元・幅変換・符号変換は対象外",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_memfile_" + "_".join(row)


def pattern(width: int, code: int, phase: int) -> str:
    return "".join(str((code >> ((pos + phase) % 3)) & 1) for pos in range(width))


def phases(row: Row) -> list[tuple[str, int, list[str]]]:
    w = int(row[0])
    result = [(f"k{phase}", phase, [pattern(w, code, phase) for code in range(1, 6)])
              for phase in range(3)]
    if row[3] != "known":
        groups = (w + 3) // 4
        for phase in range(3):
            words = []
            for code in range(1, 6):
                bad = {0, groups - 1, (groups // 2 + code + phase) % groups}
                bits = pattern(w, code, phase)
                words.append("".join(row[3] if (w - 1 - i) // 4 in bad else bit
                                     for i, bit in enumerate(bits)))
            result.append((f"u{phase}", phase, words))
    return result


def stored(state: str, bits: str) -> str:
    return bits.translate(str.maketrans("xz", "00")) if state == "bit" else bits


def poison(bits: str) -> str:
    return "".join("0" if bit == "1" else "1" for bit in bits)


def source_indices(row: Row) -> list[int]:
    return {"all": list(range(2, 7)), "middle": [3, 4, 5], "single": [4]}[row[5]]


def target_indices(row: Row) -> list[int]:
    result = list(range(11, 11 + len(source_indices(row))))
    return result if row[8] == "forward" else result[::-1]


def token(row: Row, bits: str) -> str:
    if row[4] == "bin":
        return bits
    padded = bits.rjust((len(bits) + 3) // 4 * 4, "0")
    return "".join("x" if "x" in nibble else "z" if "z" in nibble else f"{int(nibble, 2):x}"
                   for nibble in (padded[i:i+4] for i in range(0, len(padded), 4)))


def reference(row: Row) -> str:
    w, output = int(row[0]), []
    write, read = source_indices(row), target_indices(row)
    for label, phase, words in phases(row):
        source = [stored(row[1], bits) for bits in words]
        output.append(f"{label} count={len(write)} write={write[0]}:{write[-1]} read={read[0]}:{read[-1]}")
        output += [f"{label} before idx={i} raw={words[i-2]} source={source[i-2]}" for i in range(2, 7)]
        output += [f"{label} after idx={i} source={poison(source[i-2])}" for i in range(2, 7)]
        destination = {i: pattern(w, 6 if i == 10 else 7 if i == 16 else 0, phase)
                       for i in range(10, 17)}
        for src, dst in zip(write, read):
            destination[dst] = stored(row[7], source[src-2])
        output += [f"{label} dest idx={i} written={destination[i]} canonical={destination[i]}"
                   for i in range(10, 17)]
        output.append(f"{label} addresses written=0 canonical=0")
    return "\n".join(output) + "\n"


def address_counter() -> list[str]:
    return [
        "  function automatic int addresses(input string filename);",
        "    int handle, c, state, previous, count;",
        '    handle = $fopen(filename, "r");', "    if (handle == 0) return -1;",
        "    state = 0; previous = 0; count = 0; c = $fgetc(handle);",
        "    while (c != -1) begin", "      case (state)",
        "        0: begin", "          if (c == 8'd47) state = 1;",
        "          else if (c == 8'd64) count++;", "        end",
        "        1: begin", "          if (c == 8'd47) state = 2;",
        "          else if (c == 8'd42) state = 3;", "          else begin",
        "            state = 0; if (c == 8'd64) count++;", "          end", "        end",
        "        2: if (c == 10 || c == 13) state = 0;",
        "        3: if (previous == 8'd42 && c == 8'd47) state = 0;", "      endcase",
        "      previous = c; c = $fgetc(handle);", "    end", "    $fclose(handle);",
        "    return count;", "  endfunction",
    ]


def token_line(value: str) -> list[str]:
    if len(value) <= 48:
        return [f'    $fdisplay(fd, "{value}");']
    parts = [value[i:i+48] for i in range(0, len(value), 48)]
    return ['    $fdisplay(fd, "%s", {',
            *[f'      "{part}"' + ("," if i+1 < len(parts) else "") for i, part in enumerate(parts)],
            "    });"]


def make_case(row: Row) -> Case:
    width, source_state, kind, value, encoding, span, declaration, target_state, read_order = row
    w, name = int(width), case_name(row)
    write, read = source_indices(row), target_indices(row)
    bounds = "10:16" if declaration == "up" else "16:10"
    suffix = "b" if encoding == "bin" else "h"
    lines = [f"module {name};"]
    if kind == "enum":
        lines += [f"  typedef enum {source_state} [{w-1}:0] {{E_ZERO = '0, E_ONE = '1}} source_t;"]
    else:
        lines += [f"  typedef {source_state} [{w-1}:0] source_t;"]
    lines += [f"  logic [{w-1}:0] raw[2:6];", "  source_t source[2:6];",
              f"  {target_state} [{w-1}:0] loaded[{bounds}], canonical[{bounds}];",
              "  int fd, phase;", *address_counter(), "  initial begin"]
    for ordinal, (label, phase, words) in enumerate(phases(row)):
        source = [stored(source_state, bits) for bits in words]
        lines += [f"    phase = {ordinal};",
                  f'    $display("{label} count={len(write)} write={write[0]}:{write[-1]} read={read[0]}:{read[-1]}");']
        lines += [f"    raw[{i}] = {literal(bits)};" for i, bits in enumerate(words, 2)]
        lines += ["    for (int i = 2; i <= 6; i++) begin", "      source[i] = source_t'(raw[i]);",
                  f'      $display("{label} before idx=%0d raw=%b source=%b", i, raw[i], source[i]);',
                  "    end", f'    $writemem{suffix}("written.mem", source, {write[0]}, {write[-1]});']
        lines += [f"    source[{i}] = source_t'({literal(poison(bits))});" for i, bits in enumerate(source, 2)]
        lines += ["    for (int i = 2; i <= 6; i++)",
                  f'      $display("{label} after idx=%0d source=%b", i, source[i]);',
                  '    fd = $fopen("canonical.mem", "w");',
                  '    if (fd == 0) $fatal(1, "canonical open failed");',
                  '    $fdisplay(fd, "// @ inside a line comment");',
                  '    $fdisplay(fd, "/* @ inside a block comment */");']
        for index in write:
            lines += token_line(token(row, source[index-2]))
        lines += ["    $fclose(fd);"]
        for index in range(10, 17):
            guard = pattern(w, 6 if index == 10 else 7 if index == 16 else 0, phase)
            lines += [f"    loaded[{index}] = {literal(guard)};", f"    canonical[{index}] = {literal(guard)};"]
        lines += [f'    $readmem{suffix}("written.mem", loaded, {read[0]}, {read[-1]});',
                  f'    $readmem{suffix}("canonical.mem", canonical, {read[0]}, {read[-1]});',
                  "    for (int i = 10; i <= 16; i++)",
                  f'      $display("{label} dest idx=%0d written=%b canonical=%b", i, loaded[i], canonical[i]);',
                  f'    $display("{label} addresses written=%0d canonical=%0d",',
                  '             addresses("written.mem"), addresses("canonical.mem"));']
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Typed memory files preserve numerical words, explicit read direction and untouched guards",
        "21.5 21.5.1 21.5.2 21.5.3 21.4 21.4.1 6.19.4 6.24.1 6.11.2 7.4.3",
        "A fixed array of bit/logic words or enum values is written as binary "
        "or hex, with explicit source bounds. Static casts store numerical "
        "values in enums without enum-value validity checking. After writing, "
        "every source word is changed to a different known value. A second "
        "file contains independently specified literal tokens, not values "
        "formatted from the live source. Both files are loaded into separate "
        "guarded arrays of either declaration direction, using explicit "
        "forward/reverse target bounds at a different index offset. Known "
        "three-phase index codes distinguish every selected source location "
        "even at width 1; X/Z phases add whole unknown nibbles. Source "
        "conversion precedes serialization; target conversion occurs on "
        "loading. All source and destination elements are observed, including "
        "unselected cells. Files are reused across phases to check overwrite. "
        "An address scanner ignores line/block comments; the canonical file "
        "contains comment-only @ characters. Whitespace, case and comment "
        "layout of written files are not fixed. Single-element reverse "
        "bounds are identical to forward bounds, so only one is retained. "
        "No dynamic/associative arrays, multidimensional order, width or sign "
        "conversion, or partial-X/Z hex nibbles are included.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{key}={val}" for key, val in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
