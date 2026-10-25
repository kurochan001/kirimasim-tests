/*
:name: test_tagged_union_expression_and_matches_precedence
:description: A tagged union expression is the keyword tagged, the member name and optionally a primary as the member value; it sets the tag and the value of the union, and the matches operator that tests it binds more tightly than && and || (IEEE 1800-2023 Sections 11.9 and 7.3.2, and footnote 30 of A.10)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.9 7.3.2 A.8.3 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tagged_union_expression_and_matches_precedence.expected
*/
// IEEE 1800-2023 A.8.3: an expression can be a tagged union expression,
// which is the keyword tagged, a member name and an optional primary.
// Footnote 30 of A.10: the matches operator has higher precedence than && and
// ||. §11.9: the expression sets the tag to the named member and, when a
// primary follows, the value of that member. §7.3.2: a void member has no
// value, so tagged Invalid has none.
//
// With a = tagged Invalid, b = tagged Valid(42) and c = tagged Valid(7),
// a matches Invalid is 1, b matches Valid is 1 and c matches Invalid is 0.
// Because matches binds more tightly than the logical operators, the three
// expressions without parentheses are (b matches Valid) && (c matches Valid)
// = 1, (a matches Invalid) || (b matches Invalid) = 1, and (a matches
// Invalid) && (b matches Invalid) = 0. The case with matches binds v to 42
// for b and takes the Invalid alternative for a.
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
    a = tagged Invalid;
    b = tagged Valid(42);
    c = tagged Valid(7);
    $display("tag %0d %0d %0d", a matches tagged Invalid,
             b matches tagged Valid, c matches tagged Invalid);
    $display("prec %0d %0d %0d",
             b matches tagged Valid && c matches tagged Valid,
             a matches tagged Invalid || b matches tagged Invalid,
             a matches tagged Invalid && b matches tagged Invalid);
    case (b) matches
      tagged Valid(v): $display("payload %0d", v);
      default: $display("payload none");
    endcase
    case (a) matches
      tagged Invalid: $display("void none");
      default: $display("void some");
    endcase
  end
endmodule
