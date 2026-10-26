"""Parametric RTL specifications from 1800-2023 16.9; no evaluator imports.

For bounded patterns, ref[n] counts matches after exactly n consumed samples.
History index zero is the most recently consumed Boolean sample. Integer
parameters below are enumerated, not silently treated as symbolic integers.
"""

from dataclasses import dataclass


@dataclass(frozen=True)
class Case:
    name: str
    family: str
    expression: str
    signals: str
    clause: str
    reference: object
    parameters: tuple


def one(condition):
    return f"(({condition}) ? 32'd1 : 32'd0)"


def catalogue():
    cases = []
    def add(family, params, expr, signals, clause, reference):
        suffix = "_".join(str(p) for p in params)
        cases.append(Case(family + "_" + suffix, family, expr, signals, clause, reference, params))
    for low in range(4):
        for high in range(low, 4):
            plain, first, repeated = {}, {}, {}
            for delay in range(low, high + 1):
                plain[delay + 1] = f"h_a[{delay}] && h_b[0]"
                absent = " && ".join(f"!h_b[{delay-j}]" for j in range(low, delay))
                first[delay + 1] = plain[delay + 1] + (" && " + absent if absent else "")
                repeated[delay] = " && ".join(f"h_a[{j}]" for j in range(delay)) or "1"
            add("delay", (low, high), f"a ##[{low}:{high}] b", "ab", "16.9.1", plain)
            add("first", (low, high), f"first_match(a ##[{low}:{high}] b)", "ab", "16.9.8", first)
            add("repeat", (low, high), f"a[*{low}:{high}]", "a", "16.9.2.1", repeated)
    for outer in range(1, 4):
        for inner in range(1, outer + 1):
            placements = [one(f"h_x[{outer-start}] && h_x[{outer-start-inner}]") for start in range(outer-inner+1)]
            ref = f"{one(f'h_a[{outer}] && h_b[0]')} * ({' + '.join(placements)})"
            add("within", (inner, outer), f"(x ##{inner} x) within (a ##{outer} b)", "abx", "16.9.10", {outer+1: ref})
    for low in range(1, 4):
        for high in range(low, 4):
            ref = {d+1: f"h_a[{d}] && h_b[0] && " + " && ".join(f"h_x[{j}]" for j in range(d+1)) for d in range(low,high+1)}
            add("throughout", (low, high), f"x throughout (a ##[{low}:{high}] b)", "abx", "16.9.9", ref)
    for low in range(3):
        for high in range(low, 4):
            for right in range(1, 4):
                combined, intersect = {}, {}
                for left in range(low, high + 1):
                    end = max(left, right)
                    term = one(f"h_a[{end}] && h_b[{end-left}] && h_c[{end}] && h_d[{end-right}]")
                    combined[end+1] = combined.get(end+1, "32'd0") + " + " + term
                    if left == right:
                        intersect[right+1] = term
                for operator, ref, clause in [("and", combined, "16.9.5"), ("intersect", intersect, "16.9.6")]:
                    add(operator, (low, high, right), f"(a ##[{low}:{high}] b) {operator} (c ##{right} d)", "abcd", clause, ref)
    for last in range(1, 4):
        ref = {}
        for d in range(1, last + 1):
            absent = " && ".join(f"!h_b[{j}]" for j in range(1,d)) or "1"
            arrivals = f"({one('h_b[0]')} + {one('h_c[0]')})" if d == last else one("h_b[0]")
            ref[d+1] = f"{one(f'h_a[{d}] && {absent}')} * {arrivals}"
        add("tie", (last,), f"first_match((a ##[1:{last}] b) or (a ##{last} c))", "abc", "16.9.7/16.9.8", ref)
    for times in range(1, 4):
        for delay in range(3):
            history = f"reg [{delay-1}:0] hits=0;" if delay else ""
            update = f"hits<=(hits<<1)|hit;" if delay else ""
            arrival = f"hits[{delay-1}]" if delay else "hit"
            reference = f"""
              reg [2:0] seen=0;
              wire hit=letter[0] && seen=={times-1};
              {history}
              reg [31:0] reference_count=0;
              always @(posedge clk) begin
                if(letter[0] && seen<{times}) seen<=seen+1;
                {update}
                reference_count<=({arrival}) && letter[1];
              end
            """
            add("goto", (times, delay), f"a[->{times}] ##{delay} b", "ab", "16.9.2", reference)
        reference = f"""
          reg [2:0] seen=0;
          always @(posedge clk) if(letter[0] && seen<{times+1}) seen<=seen+1;
          wire [31:0] reference_count=seen=={times};
        """
        add("nonconsecutive", (times,), f"a[={times}]", "a", "16.9.2", reference)
    return cases
