"""Formal cases for the F.3.4.6 free-checker rewrite rules.

F.3.4.6 gives the formal reading of a free checker variable.  An assignment
to such a variable in an ``always_ff`` procedure becomes an assumption about
the future-global value of the variable, and a declaration initializer becomes
an initial assumption at the first clock.  The three tables below model the
three rules on a finite trace instead of extending the parser:

* ``f346_nonblocking``  ``always_ff @c u<=e`` (and ``u<=c?e:u``) versus
  ``future-global u === c?e:u``.  The actual side is a forward execution of
  the nonblocking update; the reference side is the assumption predicate.
* ``f346_enable``       the same comparison when the assignment sits under an
  enclosing combined conditional enable (if, nested if, if/else-if, case).
  The assumption must carry the same enable, so a false enable holds ``u``.
* ``f346_rand_init``    a rand-variable declaration initializer versus
  ``initial assume property(@1 u===e)``.  Only the initial tick is constrained;
  later values of the free variable stay arbitrary.

Each ``actual`` is an imperative finite-state model (a register update or an
initialization).  Each ``reference`` is RTL written from the clause as a
constraint over the trace; it never calls the parser, the derivative engine or
the evaluator.  The exporter enumerates every word of the finite alphabet in a
single combinational case statement, so a PASS is exhaustive for the listed
shapes and trace length, not a claim about the whole language.
"""

from .f_extra_common import table  # noqa: F401  (registers into f_extra_common.TABLES)


# ---------------------------------------------------------------------------
# helpers


def _bit(row, name):
    """One bit of a sampled signal row."""
    return row[name].integer() & 1


def _first_bad(observed, step):
    """First tick where the forward model disagrees with the observed trace.

    ``observed[k]`` is the free trace value at tick ``k``.  ``step(tick,
    state)`` is the update performed by the procedure at tick ``tick``.  A
    return of 0 means that the trace is a legal execution; ``k+1`` identifies
    the first offending tick.
    """
    state = observed[0]
    for tick in range(len(observed) - 1):
        state = step(tick, state)
        if state != observed[tick + 1]:
            return tick + 1
    return 0


# ---------------------------------------------------------------------------
# F.3.4.6 always_ff free checker assignment


def nonblocking_code(samples, local, sel):
    """Forward execution of ``u <= e`` / ``u <= c ? e : u`` over two ticks."""
    u = [_bit(row, "u") for row in samples]
    e = [_bit(row, "e") for row in samples]
    c = [_bit(row, "c") for row in samples]

    def step(tick, state):
        # A nonblocking assignment reads the values sampled at this tick and
        # writes at the end of the tick.  Selector 0 is the plain assignment;
        # selector 1 is the conditional right-hand side c ? e : u.
        return e[tick] if sel == 0 or c[tick] else state

    return _first_bad(u, step)


table(
    "f346_nonblocking", "F.3.4.6",
    "always_ff @c u<=e  <=>  always_ff assumption (future-global u === c?e:u)",
    signals=[("u", 1), ("e", 1), ("c", 1)], horizon=3, selectors=1,
    actual=nonblocking_code,
    reference="""
      always @* begin
        reference_result = 0;
        // Tick 0: $future_gclk(u) is the u value at tick 1.  The right-hand
        // side is sampled at tick 0; a conditional RHS keeps u when c is 0.
        if (s_u_1 !== (sel ? (s_c_0 ? s_e_0 : s_u_0) : s_e_0))
          reference_result = 1;
        else if (s_u_2 !== (sel ? (s_c_1 ? s_e_1 : s_u_1) : s_e_1))
          reference_result = 2;
      end
    """,
    cover="sel==1 && !s_c_0 && s_u_1==s_u_0",
    why="The always_ff assignment updates u at the end of each tick from the "
        "values sampled at that tick.  Rewriting it to an always_ff assumption "
        "makes the future-global u (the value at the next tick) case-equal to "
        "the assigned expression.  Over two ticks the forward update and the "
        "assumption predicate agree on the first violated tick: with the plain "
        "assignment the next value is e, and with the conditional right-hand "
        "side c?e:u the next value is e when c is true and the current u when c "
        "is false (hold).  The cover witnesses the hold case.  Case equality is "
        "checked with 1-bit two-state values, so === and == coincide here.",
    limitation="A finite-state representative model: 1-bit u/e/c, two update "
               "ticks, two-state values, and only the plain and conditional-RHS "
               "assignment forms.  It is not the full syntax of free checker "
               "variables or of arbitrary always_ff bodies, and it does not "
               "model real-time scheduling, the NBA update region, multiple "
               "assignments to one variable, or x/z values.")


# ---------------------------------------------------------------------------
# F.3.4.6 enclosing combined conditional enable


def combined_enable(form, b0, b1):
    """Enable contributed by the enclosing statement, from its source path.

    ``b0`` is c[0] (the LSB) and ``b1`` is c[1] (the MSB).

    0: if (c[0]) u <= e;
    1: if (c[0]) if (c[1]) u <= e;
    2: if (c[0]) u <= e; else if (c[1]) u <= e;
    3: case (c) 2'b01: u <= e; default: ;
    """
    if form == 0:
        return b0
    if form == 1:
        return b0 and b1
    if form == 2:
        return b0 or b1
    return b0 and not b1


def enable_code(samples, local, sel):
    """Forward execution under the same combined enable used by the source."""
    u = [_bit(row, "u") for row in samples]
    e = [_bit(row, "e") for row in samples]
    b0 = [row["c"].integer() & 1 for row in samples]
    b1 = [(row["c"].integer() >> 1) & 1 for row in samples]

    def step(tick, state):
        # The assignment runs only when every enclosing condition is true;
        # otherwise the always_ff procedure leaves u unchanged.
        if combined_enable(sel, b0[tick], b1[tick]):
            return e[tick]
        return state

    return _first_bad(u, step)


table(
    "f346_enable", "F.3.4.6",
    "assumption uses the same enclosing combined conditional enable",
    signals=[("u", 1), ("e", 1), ("c", 2)], horizon=2, selectors=2,
    actual=enable_code,
    reference="""
      reg g;
      always @* begin
        reference_result = 0;
        g = 0;
        // Reconstruct the combined conditional enable of the source statement
        // at the clock edge, independently from the forward model.
        case (sel)
          0: g = s_c_0[0];
          1: g = s_c_0[0] && s_c_0[1];
          2: g = s_c_0[0] || s_c_0[1];
          default: g = (s_c_0 == 2'b01);
        endcase
        // The assumption is guarded by that same enable: when it is false the
        // assigned expression e is not used and the future value equals u.
        if (s_u_1 !== (g ? s_e_0 : s_u_0))
          reference_result = 1;
      end
    """,
    cover="sel==0 && !s_c_0[0] && s_u_0==s_u_1 && s_e_0!=s_u_0",
    why="The source assignment sits under an enclosing conditional statement.  "
        "Its combined conditional enable is the conjunction/disjunction of the "
        "conditions on the path: c[0] for a single if, c[0]&&c[1] for nested "
        "ifs, c[0]||c[1] for two branches that assign the same u, and c==2'b01 "
        "for a case label.  The equivalent assumption must use that same enable.  "
        "The forward execution assigns e when the enable is true and otherwise "
        "holds u; the assumption requires future-global u === enable?e:u.  The "
        "two sides agree for every word.  The cover witnesses the hold case: the "
        "enable is false, e differs from u, and u keeps its value.",
    limitation="A finite-state representative of the combined enable: four "
               "enclosing forms over a 2-bit condition, one update tick (tick 0 "
               "to tick 1), 1-bit u/e, two-state values.  A disable iff or "
               "clocking-event iff condition enters the same combined enable as "
               "one more conjunct; the conjunction rule is represented by form "
               "1, but no separate disable form is enumerated.  It is not the "
               "full statement grammar (loops, multiple or conflicting "
               "assignments, priority and unique case semantics) and does not "
               "model real-time scheduling or the NBA update region.")


# ---------------------------------------------------------------------------
# F.3.4.6 rand-variable declaration initializer


def rand_init_code(samples, local, sel):
    """Initial value assigned by the declaration initializer at tick 0."""
    u0 = samples[0]["u"].integer() & 3
    e0 = samples[0]["e"].integer() & 3
    expected = [e0, (~e0) & 3, None, 2][sel]
    return 0 if expected is None or u0 == expected else 1


table(
    "f346_rand_init", "F.3.4.6",
    "rand variable initializer  <=>  initial assume property(@1 u===e)",
    signals=[("u", 2), ("e", 2)], horizon=2, selectors=2,
    actual=rand_init_code,
    reference="""
      always @* begin
        reference_result = 0;
        // initial assume property(@1 u===e): only the value at the first
        // tick is constrained.  u_1 and e_1 are deliberately not consulted.
        case (sel)
          0: if (s_u_0 !== s_e_0) reference_result = 1;
          1: if (s_u_0 !== ~s_e_0) reference_result = 1;
          2: ;                                  // no initializer: u_0 is free
          default: if (s_u_0 !== 2'd2) reference_result = 1;
        endcase
      end
    """,
    cover="sel==0 && s_u_0==s_e_0 && s_u_1!=s_e_0",
    why="A rand-variable declaration initializer sets the variable at the "
        "initial tick.  Its formal counterpart is an initial assumption at the "
        "first clock (@1), so the initial value of u must case-equal e.  The "
        "model compares the initialized value u_0 with the initializer "
        "expression e_0 (or its complement or a constant), and leaves the later "
        "free value u_1 unconstrained, which is why the assumption is initial "
        "and not an always property.  The cover witnesses a trace whose later "
        "u differs from the initializer while the initial assumption still "
        "holds.  The no-initializer variant admits every u_0.",
    limitation="A finite-state representative model: 2-bit u/e, two ticks, "
               "four initializer variants, two-state values.  It is not the full "
               "syntax of rand declarations (types, arrays, multiple "
               "declarators, initializer side effects) and does not model "
               "real-time scheduling or the exact time step at which @1 first "
               "fires.")
