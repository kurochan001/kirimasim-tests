/*
:name: test_tagged_union_expression_and_matches_precedence
:description: A tagged union expression is the keyword tagged, the member name and optionally a primary as the member value; it sets the tag and the value of the union, and a matches clause that tests it is a cond_pattern used in an if predicate with &&& terms and in case ... matches (IEEE 1800-2023 Sections 11.9, 7.3.2 and 12.6)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.9 7.3.2 12.6 A.8.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tagged_union_expression_and_matches_precedence.expected
*/
// IEEE 1800-2023 A.8.3: an expression can be a tagged union expression,
// which is the keyword tagged, a member name and an optional primary.
// §11.9: the expression sets the tag to the named member and, when a primary
// follows, the value of that member. §7.3.2: a void member has no value, so
// tagged Invalid has none.
//
// §12.6: "expression matches pattern" is a cond_pattern, which is a term of a
// cond_predicate and is not itself an expression. It is allowed in an if
// predicate, in case ... matches and as part of a conditional predicate, but
// never as an operand of && or ||, so a match result that is used as a value
// is first turned into 0 or 1 by a statement. The terms of one predicate are
// joined with &&&, not with &&.
//
// With a = tagged Invalid, b = tagged Valid(42) and c = tagged Valid(7),
// a matches Invalid is 1, b matches Valid is 1 and c matches Invalid is 0.
// The three conjunction and disjunction results converted to one bit are
// (b matches Valid) && (c matches Valid) = 1, (a matches Invalid) ||
// (b matches Invalid) = 1, and (a matches Invalid) && (b matches Invalid) =
// 0; the middle one takes its else-if arm. The case with matches binds v to
// 42 for b and takes the Invalid alternative for a.
//
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports tagged unions, so
// this expected output follows the standard.

module test_tagged_union_expression_and_matches_precedence;
  typedef union tagged {
    void Invalid;
    int Valid;
  } value_t;

  value_t a, b, c;

  initial begin
    int ta, tb, tc;
    int p1, p2, p3;

    a = tagged Invalid;
    b = tagged Valid(42);
    c = tagged Valid(7);

    ta = 0;
    tb = 0;
    tc = 0;
    if (a matches tagged Invalid) ta = 1;
    if (b matches tagged Valid) tb = 1;
    if (c matches tagged Invalid) tc = 1;
    $display("tag %0d %0d %0d", ta, tb, tc);

    p1 = 0;
    if (b matches tagged Valid &&& c matches tagged Valid) p1 = 1;
    p2 = 0;
    if (a matches tagged Invalid) p2 = 1;
    else if (b matches tagged Invalid) p2 = 1;
    p3 = 0;
    if (a matches tagged Invalid &&& b matches tagged Invalid) p3 = 1;
    $display("prec %0d %0d %0d", p1, p2, p3);

    case (b) matches
      tagged Valid .v: $display("payload %0d", v);
      default: $display("payload none");
    endcase
    case (a) matches
      tagged Invalid: $display("void none");
      default: $display("void some");
    endcase
  end
endmodule
