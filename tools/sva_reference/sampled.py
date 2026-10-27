"""Static integral sampled expressions, IEEE 1800-2023 16.5.1 and 16.9.3.

History is independent of property attempts, assertion enables and action calls.
Only a single resolved scalar clock is supported. Automatic/const expressions,
method values, user functions and clocks with different histories are rejected
by the parser/bridge rather than inferred from a first sample or live value.
"""

from .parser import Node, Unsupported
from .values import evaluate, logical


class History:
    def __init__(self, samples, *, defaults=None, clock=None):
        self.samples = tuple(dict(row) for row in samples)
        self.defaults = {} if defaults is None else dict(defaults)
        self.clock = clock

    def evaluate(self, node, tick, *, live=None):
        if not -1 <= tick < len(self.samples):
            raise Unsupported("sampled expression tick is outside its history")
        values = dict(self.defaults if tick == -1 else self.samples[tick]) if live is None else dict(live)

        def bind(part):
            if part.op == "sampled":
                value = self.function(part, tick)
                # Retain declared width, sign and selection range, with no
                # accidental resizing of the expression inside a system call.
                name = "\0sampled" + str(len(values))
                values[name] = value
                return Node("name", value=name)
            return Node(part.op, tuple(bind(arg) for arg in part.args), part.value)

        return evaluate(bind(node), values)

    def function(self, node, tick):
        name, args = node.value, node.args
        if name not in {"$sampled", "$past", "$rose", "$fell", "$stable", "$changed",
                        "$past_gclk", "$future_gclk"}:
            raise Unsupported("unknown sampled function")
        if name in {"$past_gclk", "$future_gclk"}:
            target = tick - 1 if name == "$past_gclk" else tick + 1
            if target < 0:
                return self.evaluate(args[0], -1)
            if target >= len(self.samples):
                raise Unsupported("$future_gclk at the final letter of a finite word is undefined")
            return self.evaluate(args[0], target)
        event = args[-1] if args[-1].op == "clock" else None
        if event is not None and event.value != self.clock:
            raise Unsupported("sampled function uses a different or unresolved clock")
        if name == "$sampled":
            return self.evaluate(args[0], tick)
        count = 1
        gate = None
        if name == "$past":
            if len(args) > 1 and args[1].op != "omitted":
                count = evaluate(args[1], {}).integer()
                if count < 1:
                    raise Unsupported("$past tick count must be a positive elaboration constant")
            if len(args) > 2 and args[2].op != "omitted":
                gate = args[2]
        prior = -1
        for index in range(tick - 1, -1, -1):
            if gate is None or self.evaluate(gate, index).assertion():
                count -= 1
                if count == 0:
                    prior = index
                    break
        previous = self.evaluate(args[0], prior)
        if name == "$past":
            return previous
        current = self.evaluate(args[0], tick)
        if name == "$rose":
            return logical(current.bits[-1] == "1" and previous.bits[-1] != "1")
        if name == "$fell":
            return logical(current.bits[-1] == "0" and previous.bits[-1] != "0")
        same = current.bits == previous.bits
        return logical(same if name == "$stable" else not same)
