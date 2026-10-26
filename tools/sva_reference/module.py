"""Declarations and directives in a single-module, single-clock source subset."""

from dataclasses import dataclass, replace
import re

from .parser import Definition, Node, Parser, Spec, Unsupported, expand, lex, parse_spec, substitute
from .source import Directive, _balanced, inspect_source, tokens
from .values import evaluate


@dataclass(frozen=True)
class ParsedDirective:
    source: Directive
    spec: Spec


@dataclass(frozen=True)
class Module:
    top: str
    definitions: dict
    directives: tuple[ParsedDirective, ...]
    stimulus: str  # declarations and directives removed, including actions
    parameters: dict


def _formals(text):
    if not text.strip():
        return (), (), ()
    result, casts, defaults, previous_type = [], [], [], None
    formals, current, depth = [], [], 0
    for word in lex(text):
        if word in {"(", "[", "{"}:
            depth += 1
        elif word in {")", "]", "}"}:
            depth -= 1
        if word == "," and depth == 0:
            formals.append(current)
            current = []
        else:
            current.append(word)
    formals.append(current)
    for words in formals:
        default = None
        if "=" in words:
            assignment = words.index("=")
            parser = Parser(" ".join(words[assignment + 1:]))
            default = parser.boolean()
            parser.finish()
            words = words[:assignment]
        if any(word in {"local", "ref", "output", "inout", "property", "sequence"} for word in words):
            raise Unsupported("only expression/signal formal arguments are supported")
        if not words or not re.fullmatch(r"[a-zA-Z_]\w*", words[-1]):
            raise Unsupported("invalid formal argument")
        # F.4.1 substitutes untyped actuals and casts typed expression actuals.
        # Reject unpacked dimensions after the formal name.
        allowed = {"input", "untyped", "logic", "bit", "reg", "int", "integer", "byte", "shortint", "longint", "time", "signed", "unsigned",
                   "[", "]", ":"}
        if any(word not in allowed and not word.isdigit() for word in words[:-1]):
            raise Unsupported("unsupported formal argument type")
        result.append(words[-1])
        typewords = [word for word in words[:-1] if word != "input"]
        if typewords:
            if "untyped" in typewords:
                previous_type = None
            else:
                atom_types = {"byte": 8, "shortint": 16, "int": 32, "integer": 32, "longint": 64, "time": 64}
                signed = ("signed" in typewords or any(word in set(atom_types) - {"time"} for word in typewords)) and "unsigned" not in typewords
                atom = next((word for word in typewords if word in atom_types), None)
                width = atom_types[atom] if atom else 1
                lsb, ascending = 0, False
                if "[" in typewords:
                    if atom:
                        raise Unsupported("packed dimension on an integer atom type")
                    bracket = typewords.index("[")
                    if typewords[bracket:] != ["[", *typewords[bracket + 1:bracket + 4], "]"] or typewords[bracket + 2] != ":":
                        raise Unsupported("formal packed ranges require literal bounds")
                    msb, lsb = int(typewords[bracket + 1]), int(typewords[bracket + 3])
                    width, ascending = abs(msb - lsb) + 1, msb < lsb
                previous_type = (width, signed, any(word in {"bit", "byte", "shortint", "int", "longint"} for word in typewords), lsb, ascending)
        casts.append(previous_type)
        defaults.append(default)
    if len(set(result)) != len(result):
        raise Unsupported("duplicate formal name")
    return tuple(result), tuple(casts), tuple(defaults)


def parse_module(source):
    ts = tokens(source)
    words = [token.text for token in ts]
    definitions, spans, constants = {}, [], {}
    default_clock = None
    default_disable = None
    i = 0
    while i < len(ts):
        word = words[i]
        if word in {"task", "function"}:
            try:
                i = words.index("end" + word, i + 1) + 1
            except ValueError as exc:
                raise Unsupported("unterminated subroutine") from exc
            continue
        if word == "let":
            name, j = words[i + 1], i + 2
            parameters, casts, defaults = (), (), ()
            if words[j] == "(":
                end = _balanced(ts, j)
                parameters, casts, defaults = _formals(source[ts[j].end:ts[end - 1].start])
                j = end
            if words[j] != "=":
                raise Unsupported("invalid let declaration")
            end = words.index(";", j + 1)
            parser = Parser(source[ts[j].end:ts[end].start])
            expression = parser.boolean()
            parser.finish()
            if name in definitions:
                raise Unsupported("duplicate let/SVA definition")
            definitions[name] = Definition("let", parameters, Spec(Node("bool", (expression,))), casts, defaults)
            spans.append((ts[i].start, ts[end].end))
            i = end + 1
            continue
        if word in {"parameter", "localparam"}:
            try:
                final = words.index(";", i + 1)
            except ValueError as exc:
                raise Unsupported("unterminated parameter declaration") from exc
            names, casts, defaults = _formals(source[ts[i].end:ts[final].start])
            for name, cast, default in zip(names, casts, defaults):
                if default is None or name in constants:
                    raise Unsupported("missing or duplicate parameter value")
                bindings = {key: Node("literal", value=f"{value.width}'{'s' if value.signed else ''}b{value.bits}")
                            for key, value in constants.items()}
                expression = substitute(default, bindings)
                if cast is not None:
                    expression = Node("cast", (expression,), cast)
                constants[name] = evaluate(expression, {})
            i = final + 1
            continue
        if word == "default" and i + 1 < len(ts) and words[i + 1] == "clocking":
            if default_clock is not None:
                raise Unsupported("duplicate default clocking")
            j = i + 2
            if words[j] != "@":
                j += 1  # optional block name
            if words[j] != "@":
                raise Unsupported("only an inline empty default clocking block is supported")
            end_clock = _balanced(ts, j + 1)
            spec = parse_spec(source[ts[j].start:ts[end_clock - 1].end] + " 1")
            if words[end_clock:end_clock + 2] != [";", "endclocking"]:
                raise Unsupported("clocking block variables/skews are outside v1")
            default_clock = (spec.clock, spec.edge)
            spans.append((ts[i].start, ts[end_clock + 1].end))
            i = end_clock + 2
            continue
        if word == "default" and words[i + 1:i + 3] == ["disable", "iff"]:
            if default_disable is not None:
                raise Unsupported("duplicate default disable iff")
            if words[i + 3] == "(":
                end = _balanced(ts, i + 3)
                condition = source[ts[i + 3].end:ts[end - 1].start]
            else:
                end = words.index(";", i + 3)
                condition = source[ts[i + 3].start:ts[end].start]
            spec = parse_spec("disable iff (" + condition + ") 1")
            if words[end] != ";":
                raise Unsupported("unterminated default disable iff")
            default_disable = spec.disable
            spans.append((ts[i].start, ts[end].end))
            i = end + 1
            continue
        if word not in {"sequence", "property"} or i > 0 and words[i - 1] in {"assert", "assume", "cover"}:
            i += 1
            continue
        if i + 2 >= len(ts):
            raise Unsupported("unterminated SVA declaration")
        name, j = words[i + 1], i + 2
        if not re.fullmatch(r"[a-zA-Z_]\w*", name):
            raise Unsupported("invalid SVA declaration name")
        parameters, casts, defaults = (), (), ()
        if words[j] == "(":
            end = _balanced(ts, j)
            parameters, casts, defaults = _formals(source[ts[j].end:ts[end - 1].start])
            j = end
        if words[j] != ";":
            raise Unsupported("missing declaration header semicolon")
        try:
            end = words.index("end" + word, j + 1)
        except ValueError as exc:
            raise Unsupported("unterminated SVA declaration") from exc
        body = source[ts[j].end:ts[end].start].strip()
        if body.endswith(";"):
            body = body[:-1]
        if name in definitions:
            raise Unsupported("duplicate named SVA declaration")
        definitions[name] = Definition(word, parameters, parse_spec(body), casts, defaults)
        final = end + 1
        if final < len(ts) and words[final] == ":":
            if final + 1 >= len(ts) or words[final + 1] != name:
                raise Unsupported("mismatched end label")
            final += 2
        spans.append((ts[i].start, ts[final - 1].end))
        i = final
    stripped = source
    for begin, end in sorted(spans, reverse=True):
        stripped = stripped[:begin] + "".join("\n" if c == "\n" else " " for c in stripped[begin:end]) + stripped[end:]
    top, directives = inspect_source(stripped, allow_unlabeled=True)
    bindings = {key: Node("literal", value=f"{value.width}'{'s' if value.signed else ''}b{value.bits}")
                for key, value in constants.items()}
    resolved_definitions = {}
    for name, definition in definitions.items():
        local = {key: value for key, value in bindings.items() if key not in definition.parameters}
        inner = definition.spec
        spec = replace(inner, body=substitute(inner.body, local),
                       disable=substitute(inner.disable, local) if inner.disable else None)
        defaults = tuple(substitute(arg, bindings) if arg is not None else None for arg in definition.defaults)
        resolved_definitions[name] = replace(definition, spec=spec, defaults=defaults)
    definitions = resolved_definitions
    parsed = []
    clocks = set()
    for directive in directives:
        raw = parse_spec(directive.expression)
        raw = replace(raw, body=substitute(raw.body, bindings),
                      disable=substitute(raw.disable, bindings) if raw.disable else None)
        spec = expand(raw, definitions)
        if spec.clock is None and default_clock:
            spec = replace(spec, clock=default_clock[0], edge=default_clock[1])
        if spec.disable is None and default_disable:
            spec = replace(spec, disable=substitute(default_disable, bindings))
        if spec.clock is None:
            raise Unsupported("a directive requires an explicit or default clock")
        clocks.add((spec.clock, spec.edge))
        parsed.append(ParsedDirective(directive, spec))
    if len(clocks) > 1:
        raise Unsupported("multiple clocks are outside v1")
    stimulus = stripped
    for directive in reversed(directives):
        stimulus = stimulus[:directive.start] + "".join("\n" if c == "\n" else " "
                                                       for c in stimulus[directive.start:directive.end]) + stimulus[directive.end:]
    return Module(top, definitions, tuple(parsed), stimulus, constants)
