"""Finite-word semantics for Annex F clocking cases.

This module is deliberately independent of the SVA parser, derivative engine
and evaluator.  It supplies the *actual* side of the F.3.1 / F.3.2 / F.3.4.3.7
/ F.3.4.4 / F.5.1 formal tables; the independent RTL references live in
``formal_cases``.  Every word is a sequence of two-valued samples with tick 0
first and signal bits packed least-significant bit first inside each tick.

The clock rewrite follows IEEE 1800-2023 F.5.1.1 and F.5.1.2 literally:

* ``Ts(b, c)`` consumes zero or more letters with ``c = 0`` and then requires
  one letter with ``c & b``.  It cannot skip a letter where ``c`` is true.
* ``Ts`` distributes through ``##1``/``##0`` with the delay counted in global
  letters, and through ``or``/``intersect``/``first_match``/repetition.
* An explicit nested ``@(c2)`` replaces the inherited clock for its operand.
* ``Tp`` keeps ``disable iff``/``accept_on`` ungated; implication transforms
  the antecedent with ``Ts`` and the consequent with ``Tp``.

Only finite words without local variables are modelled.  Property results use
the same status nibble as the rest of the formal suite: success=0t,
failure=1t, vacuous=2t, holds=3f, pending=4f, disabled=5t.
"""

SUCCESS, FAILURE, VACUOUS, HOLDS, PENDING, DISABLED = 0, 1, 2, 3, 4, 5


def samples(word, dims, horizon):
    """Decode ``word`` into ``horizon`` rows of {name: integer value}."""
    rows = []
    offset = 0
    for _ in range(horizon):
        row = {}
        for name, width in dims:
            row[name] = (word >> offset) & ((1 << width) - 1)
            offset += width
        rows.append(row)
    return rows


def bits(samples, name):
    return [row[name] for row in samples]


def code(status, tick=None):
    return (status << 4) | (15 if tick is None else tick)


def _skip_nonclock(clock, start, horizon):
    tick = max(0, start)
    while tick < horizon and not clock[tick]:
        tick += 1
    return tick if tick < horizon else None


def _next_clock(clock, tick):
    for following in range(tick + 1, len(clock)):
        if clock[following]:
            return following
    return None


def _first_clock(clock):
    return _next_clock(clock, -1)


def _bool_ends(clock, values, start):
    tick = _skip_nonclock(clock, start, len(clock))
    if tick is None or not values[tick]:
        return []
    return [tick]


def _repetition_ends(node, clock, values, start, low, high):
    result = []
    stack = [(max(0, start), max(0, start) - 1, 0)]
    while stack:
        following, last, count = stack.pop()
        if count >= low:
            result.append(last)
        if high is not None and count >= high:
            continue
        for end in _sequence_ends(node, clock, values, following):
            if end < following:
                continue  # an empty operand would not advance the repetition
            stack.append((end + 1, end, count + 1))
    return result


def _sequence_ends(node, clock, values, start):
    kind = node[0]
    if kind == "bool":
        return _bool_ends(clock, values[node[1]], start)
    if kind == "cat":
        _, left, right, delay = node
        ends = []
        for first_end in _sequence_ends(left, clock, values, start):
            following = first_end if delay == 0 else first_end + delay
            ends.extend(_sequence_ends(right, clock, values, following))
        return ends
    if kind == "or":
        return (_sequence_ends(node[1], clock, values, start)
                + _sequence_ends(node[2], clock, values, start))
    if kind == "intersect":
        left = _sequence_ends(node[1], clock, values, start)
        right = _sequence_ends(node[2], clock, values, start)
        common = []
        for end in set(left) & set(right):
            common.extend([end] * min(left.count(end), right.count(end)))
        return common
    if kind == "first":
        ends = _sequence_ends(node[1], clock, values, start)
        if not ends:
            return []
        earliest = min(ends)
        return [earliest] * ends.count(earliest)
    if kind == "rep":
        _, operand, low, high = node
        return _repetition_ends(operand, clock, values, start, low, high)
    if kind == "clock":
        return _sequence_ends(node[2], values[node[1]], values, start)
    raise ValueError(f"unknown clocked sequence node: {kind}")



def _packed_counts(rows, node, clock_name, horizon):
    values = {name: [row[name] for row in rows] for name in rows[0]}
    clock = values[clock_name]
    ends = _sequence_ends(node, clock, values, 0)
    counts = [0] * (horizon + 1)
    for end in ends:
        age = end + 1
        if 0 <= age <= horizon:
            counts[age] += 1
    packed = 0
    for age, amount in enumerate(counts):
        packed |= (amount & 15) << (4 * age)
    return packed


def make_any(dims, horizon, names):
    """Plain Boolean-or truth for a one-letter associativity table."""
    def actual(word):
        rows = samples(word, dims, horizon)
        return int(any(rows[0][name] for name in names))
    return actual


def make_clocked_counts(node, dims, horizon, clock_name):
    """Return actual(word) for a clocked sequence match-count table."""
    def actual(word):
        return _packed_counts(samples(word, dims, horizon), node, clock_name, horizon)
    return actual


# ---------------------------------------------------------------------------
# F.3.1 tau: event controls become Boolean clock predicates.


def make_tau(kind, dims, horizon):
    def actual(word):
        rows = samples(word, dims, horizon)
        value = lambda name, tick: rows[tick][name]
        if kind == "boolean_clocks":
            # Number of event occasions over the first horizon-1 transitions.
            return sum(value("b", tick) != value("b", tick + 1)
                       for tick in range(horizon - 1))
        if kind == "change":
            return int(value("b", 0) != value("b", 1))
        if kind == "posedge":
            return int(((value("b", 0) & 1) == 0) and ((value("b", 1) & 1) == 1))
        if kind == "negedge":
            return int(((value("b", 0) & 1) == 1) and ((value("b", 1) & 1) == 0))
        if kind == "edge":
            return int((value("b", 0) & 1) != (value("b", 1) & 1))
        if kind == "global":
            return 1
        if kind == "or_event":
            return int((value("b", 0) != value("b", 1))
                       or (value("c", 0) != value("c", 1)))
        if kind == "iff":
            edge = ((value("c", 0) & 1) == 0) and ((value("c", 1) & 1) == 1)
            return int(edge and value("b", 0))
        if kind == "named":
            # The auxiliary event bit is one exactly in trigger slots, so
            # $future_gclk of that bit is the next slot.
            return int(value("trig", 1))
        raise ValueError(f"unknown tau case: {kind}")
    return actual


def make_global_comparison(direction, dims, horizon):
    """F.3.4.4 rose/fell/steady/changing against past or future global."""
    def actual(word):
        rows = samples(word, dims, horizon)
        if direction == "future":
            prior, current = rows[0]["v"], rows[1]["v"]
        else:
            prior, current = rows[horizon - 2]["v"], rows[horizon - 1]["v"]
        rose = ((prior & 1) == 0) and ((current & 1) == 1)
        fell = ((prior & 1) == 1) and ((current & 1) == 0)
        steady = prior == current
        changing = prior != current
        return ((int(changing) << 3) | (int(steady) << 2)
                | (int(fell) << 1) | int(rose))
    return actual


# ---------------------------------------------------------------------------
# F.5.1.2 property transforms and F.3.4.3.7 abort operators.

def _clocked_property(kind, rows, horizon, clock_name):
    values = {name: [row[name] for row in rows] for name in rows[0]}
    clock = values[clock_name]

    def sequence_decision(clock_name):
        node = ("cat", ("bool", "a"), ("bool", "b"), 1)
        clock_bits = values[clock_name]
        first = _first_clock(clock_bits)
        if first is None:
            return HOLDS, horizon - 1
        if not values["a"][first]:
            return FAILURE, first
        second = _next_clock(clock_bits, first)
        if second is None:
            return HOLDS, horizon - 1
        if values["b"][second]:
            return SUCCESS, second
        return FAILURE, second

    if kind == "sequence":
        status, tick = sequence_decision(clock_name)
        return code(HOLDS) if status == HOLDS else code(status, tick)
    if kind == "not_sequence":
        status, tick = sequence_decision(clock_name)
        status = {SUCCESS: FAILURE, FAILURE: SUCCESS}.get(status, status)
        return code(HOLDS) if status == HOLDS else code(status, tick)
    if kind == "implication_boolean":
        first = _first_clock(clock)
        if first is None:
            return code(HOLDS)
        if not values["a"][first]:
            return code(VACUOUS, first)
        return code(SUCCESS if values["b"][first] else FAILURE, first)
    if kind == "nexttime":
        first = _first_clock(clock)
        if first is None:
            return code(HOLDS)
        second = _next_clock(clock, first)
        if second is None:
            return code(HOLDS)
        return code(SUCCESS if values["p"][second] else FAILURE, second)
    if kind == "until":
        first = _first_clock(clock)
        if first is None:
            return code(HOLDS)
        for tick in range(first, horizon):
            if not clock[tick]:
                continue
            if values["q"][tick]:
                return code(SUCCESS, tick)
            if not values["p"][tick]:
                return code(FAILURE, tick)
        return code(HOLDS)
    if kind == "async_disable":
        status, tick = sequence_decision(clock_name)
        for now in range(0, min(tick, horizon - 1) + 1):
            if values["d"][now]:
                return code(DISABLED, now)
        return code(HOLDS) if status == HOLDS else code(status, tick)
    if kind == "sync_accept":
        status, tick = sequence_decision(clock_name)
        for now in range(0, min(tick, horizon - 1) + 1):
            if clock[now] and values["g"][now]:
                return code(SUCCESS, now)
        return code(HOLDS) if status == HOLDS else code(status, tick)
    if kind == "clock_independence":
        first = _first_clock(clock)
        if first is None:
            return code(HOLDS)
        if not values["a"][first]:
            return code(VACUOUS, first)
        second = _next_clock(clock, first)
        if second is None or not values["b"][second]:
            return code(VACUOUS, first)
        return code(SUCCESS if values["d"][second] else FAILURE, second)
    raise ValueError(f"unknown clocked property case: {kind}")


def make_clocked_property(kind, dims, horizon, clock_name):
    def actual(word):
        rows = samples(word, dims, horizon)
        return _clocked_property(kind, rows, horizon, clock_name)
    return actual


def _weak_sequence_abort(rows, horizon, guard_name, mode, clock_name=None):
    """F.3.4.3.7 abort operators around weak(a ##1 b).

    ``clock_name`` is None for clock context 1 (the F.3.4.3.7 sync cases);
    otherwise the condition is evaluated only on clock ticks.
    """
    values = {name: [row[name] for row in rows] for name in rows[0]}
    clock = values[clock_name] if clock_name else [1] * horizon
    first = _first_clock(clock)
    if first is None:
        status, tick = HOLDS, horizon - 1
    elif not values["a"][first]:
        status, tick = FAILURE, first
    else:
        second = _next_clock(clock, first)
        if second is None:
            status, tick = HOLDS, horizon - 1
        elif values["b"][second]:
            status, tick = SUCCESS, second
        else:
            status, tick = FAILURE, second
    accepted = None
    for now in range(0, min(tick, horizon - 1) + 1):
        if clock[now] and values[guard_name][now]:
            accepted = now
            break
    decision = tick
    if mode == "accept":
        if accepted is not None:
            return code(SUCCESS, accepted)
        return code(HOLDS) if status == HOLDS else code(status, decision)
    if mode == "reject":
        if accepted is not None:
            return code(FAILURE, accepted)
        return code(HOLDS) if status == HOLDS else code(status, decision)
    raise ValueError(f"unknown abort mode: {mode}")


def make_abort(mode, dims, horizon, clock_name=None):
    def actual(word):
        return _weak_sequence_abort(samples(word, dims, horizon), horizon,
                                    "g", mode, clock_name)
    return actual


def make_sync_abort(mode, dims, horizon, clock_name):
    """sync_accept_on/sync_reject_on at a nonconstant clock.

    ``Tp(sync_accept_on(g) p, c) = accept_on(g && c) Tp(p, c)`` and the
    reject form is the negation dual.
    """
    def actual(word):
        rows = samples(word, dims, horizon)
        values = {name: [row[name] for row in rows] for name in rows[0]}
        clock = values[clock_name]
        # Recompute acceptance with the gated condition g && c.
        first = _first_clock(clock)
        if first is None:
            status, tick = HOLDS, horizon - 1
        elif not values["a"][first]:
            status, tick = FAILURE, first
        else:
            second = _next_clock(clock, first)
            if second is None:
                status, tick = HOLDS, horizon - 1
            elif values["b"][second]:
                status, tick = SUCCESS, second
            else:
                status, tick = FAILURE, second
        hit = None
        for now in range(0, min(tick, horizon - 1) + 1):
            if clock[now] and values["g"][now]:
                hit = now
                break
        if mode == "accept":
            return (code(SUCCESS, hit) if hit is not None
                    else (code(HOLDS) if status == HOLDS else code(status, tick)))
        # sync_reject_on = not sync_accept_on not P; the two negations
        # cancel when no accept occurs, so the result is P or failure.
        if hit is not None:
            return code(FAILURE, hit)
        return code(HOLDS) if status == HOLDS else code(status, tick)
    return actual
