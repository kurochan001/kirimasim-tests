"""Small, deliberately restricted source rewriter for the M0 experiments.

This locates module-level directives and action boundaries; it does not parse
SVA expressions. Unsupported contexts fail rather than silently lose code.
"""

from dataclasses import dataclass
import re


class UnsupportedSource(ValueError):
    pass


@dataclass(frozen=True)
class Token:
    text: str
    start: int
    end: int


@dataclass(frozen=True)
class Directive:
    label: str
    kind: str
    expression: str
    passed: str
    failed: str
    start: int
    end: int


LEX = re.compile(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|'
                 r'\\\S+|[a-zA-Z_$][\w$]*|\d+(?:\w|\.)*|\S', re.S)


def tokens(source):
    return [Token(m[0], m.start(), m.end()) for m in LEX.finditer(source)
            if not m[0].startswith(("//", "/*"))]


def _balanced(ts, i):
    closing = {"(": ")", "[": "]", "{": "}"}
    if i >= len(ts) or ts[i].text not in closing:
        raise UnsupportedSource("expected a balanced delimiter")
    stack = [closing[ts[i].text]]
    i += 1
    while i < len(ts):
        word = ts[i].text
        if word in closing:
            stack.append(closing[word])
        elif word in closing.values():
            if word != stack.pop():
                raise UnsupportedSource("mismatched delimiters")
            if not stack:
                return i + 1
        i += 1
    raise UnsupportedSource("unterminated delimiter")


def _statement(ts, i):
    """Return the first token after a supported procedural statement."""
    if i >= len(ts):
        raise UnsupportedSource("missing action or procedural statement")
    if i + 1 < len(ts) and ts[i + 1].text == ":":
        return _statement(ts, i + 2)
    word = ts[i].text
    if word == "begin":
        i += 1
        if ts[i].text == ":":
            i += 2
        while i < len(ts) and ts[i].text != "end":
            i = _statement(ts, i)
        if i >= len(ts):
            raise UnsupportedSource("unterminated begin/end")
        i += 1
        if i < len(ts) and ts[i].text == ":":
            i += 2
        return i
    if word in {"if", "for", "foreach", "while", "repeat"}:
        end = _statement(ts, _balanced(ts, i + 1))
        if word == "if" and end < len(ts) and ts[end].text == "else":
            end = _statement(ts, end + 1)
        return end
    if word in {"forever"}:
        return _statement(ts, i + 1)
    if word in {"#", "@"}:
        j = _balanced(ts, i + 1) if ts[i + 1].text == "(" else i + 2
        return _statement(ts, j)
    if word in {"case", "casex", "casez", "fork", "do"}:
        raise UnsupportedSource(f"M0 statement rewriter does not handle {word}")
    while i < len(ts):
        if ts[i].text == ";":
            return i + 1
        if ts[i].text in {"(", "[", "{"}:
            i = _balanced(ts, i)
        elif ts[i].text in {"end", "endmodule"}:
            break
        else:
            i += 1
    raise UnsupportedSource("unterminated statement")


def inspect_source(source, *, allow_unlabeled=False):
    """Return (top, directives). Only one plain module and no dependencies."""
    ts = tokens(source)
    words = [t.text for t in ts]
    if words.count("module") != 1 or words.count("endmodule") != 1:
        raise UnsupportedSource("M0 requires exactly one module")
    for i, word in enumerate(words):
        if word == "`" and (i + 1 == len(words) or words[i + 1] != "timescale"):
            raise UnsupportedSource("M0 permits only the timescale preprocessor directive")
    if re.search(r":(?:files|defines|incdirs|dpi_c|vpi_c|args|top_module):", source):
        raise UnsupportedSource("M0 does not capture external source inputs")
    module = words.index("module")
    top = words[module + 1]
    if not re.fullmatch(r"[a-zA-Z_]\w*", top):
        raise UnsupportedSource("M0 requires an ordinary module identifier")
    i = module + 2
    while i < len(ts) and ts[i].text != ";":
        i += 1
    i += 1
    directives = []
    while i < len(ts) and ts[i].text != "endmodule":
        word = ts[i].text
        if word in {"task", "function"}:
            endword = "end" + word
            try:
                j = words.index(endword, i + 1) + 1
            except ValueError as exc:
                raise UnsupportedSource(f"missing {endword}") from exc
            if any(w in {"assert", "assume", "cover"} for w in words[i:j]):
                raise UnsupportedSource("procedural assertion context is outside M0")
            i = j
            continue
        if word in {"initial", "always", "always_ff", "always_comb", "always_latch", "final"}:
            j = _statement(ts, i + 1)
            if any(w in {"assert", "assume", "cover"} for w in words[i:j]):
                raise UnsupportedSource("procedural assertion context is outside M0")
            i = j
            continue
        if word in {"sequence", "property", "generate", "checker", "clocking", "restrict"}:
            raise UnsupportedSource(f"{word} declarations/contexts are outside M0")
        if word not in {"assert", "assume", "cover"}:
            i += 1
            continue
        if i + 2 >= len(ts) or ts[i + 1].text not in {"property", "sequence"}:
            raise UnsupportedSource("immediate assertions are outside M0")
        labeled = i >= 2 and ts[i - 1].text == ":"
        if not labeled and not allow_unlabeled:
            raise UnsupportedSource("M0 requires a label on each directive")
        close = _balanced(ts, i + 2)
        expression = source[ts[i + 2].end:ts[close - 1].start]
        passed, failed = ";", ";"
        end = close
        if ts[end].text != "else":
            end = _statement(ts, close)
            passed = source[ts[close].start:ts[end - 1].end]
        if end < len(ts) and ts[end].text == "else":
            if word == "cover":
                raise UnsupportedSource("cover cannot have a fail action")
            fail_start = end + 1
            end = _statement(ts, fail_start)
            failed = source[ts[fail_start].start:ts[end - 1].end]
        label = ts[i - 2].text if labeled else f"unnamed_{len(directives) + 1}"
        directives.append(Directive(label, word + " " + ts[i + 1].text,
                                    expression, passed, failed,
                                    ts[i - 2].start if labeled else ts[i].start, ts[end - 1].end))
        i = end
    if len({d.label for d in directives}) != len(directives):
        raise UnsupportedSource("duplicate directive label")
    return top, directives


def rewrite(source, replacements=None, extra=""):
    """Remove whole directives, including actions; retain all other source."""
    _, directives = inspect_source(source)
    replacements = replacements or {}
    unknown = set(replacements) - {d.label for d in directives}
    if unknown:
        raise UnsupportedSource(f"unknown directive replacements: {sorted(unknown)}")
    for directive in reversed(directives):
        replacement = replacements.get(directive.label, "")
        # Keep source locations stable when stripping for diagnostics.
        if not replacement:
            replacement = "".join("\n" if c == "\n" else " "
                                  for c in source[directive.start:directive.end])
        source = source[:directive.start] + replacement + source[directive.end:]
    if extra:
        end = next(t.start for t in tokens(source) if t.text == "endmodule")
        source = source[:end] + extra + "\n" + source[end:]
    return source
