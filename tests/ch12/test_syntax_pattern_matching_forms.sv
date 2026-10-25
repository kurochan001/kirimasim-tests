/*
:name: test_syntax_pattern_matching_forms
:description: Matching patterns as a constant, a parenthesized pattern, a variable, the wildcard, a tagged pattern, and brace patterns with positional and named members select the case item of A.6.7.1 (IEEE 1800-2023 Sections 12.6.1 and 12.6.2, A.6.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6 12.6.1 12.6.2 A.6.7 A.6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_pattern_matching_forms.expected
*/
// IEEE 1800-2023 A.6.7.1: a pattern is a parenthesized pattern, ".
// variable_identifier", ".*", a constant expression, "tagged
// member_identifier [ pattern ]", "'{ pattern { , pattern } }" or "'{
// member_identifier : pattern { , ... } }". §12.6.1: a case with matches
// takes pattern items, the first matching pattern wins, and a pattern
// variable takes the matching value.
//
// pat_int shows a constant and a parenthesized pattern; a separate case
// shows the wildcard, which matches any value, and a variable pattern, which
// also matches any value and binds it. pat_tag matches the two alternatives
// of a tagged union, the second with the value. pat_pos and pat_named match a
// packed structure by position and by member name; the named item has an
// &&& guard that uses the value bound by its member pattern. A pattern item
// with no match falls to default.
//
// The expected output follows the standard; Icarus Verilog 13.0 does not
// support case with matches.

module test_syntax_pattern_matching_forms;
  typedef struct packed {
    int a;
    int b;
  } pair_t;

  typedef union tagged {
    void Invalid;
    int Valid;
  } value_t;

  function automatic string pat_int(int x);
    case (x) matches
      7: return "constant";
      (8): return "parenthesized";
      default: return "neither";
    endcase
  endfunction

  function automatic string pat_var(int x);
    case (x) matches
      .v: return $sformatf("variable %0d", v);
    endcase
  endfunction

  function automatic string pat_wild(int x);
    case (x) matches
      .*: return "wildcard";
    endcase
  endfunction

  function automatic string pat_tag(value_t u);
    case (u) matches
      tagged Invalid: return "invalid";
      tagged Valid .n: return $sformatf("valid %0d", n);
    endcase
  endfunction

  function automatic string pat_pos(pair_t p);
    case (p) matches
      '{1, .v}: return $sformatf("position 1 %0d", v);
      '{2, 3}: return "position 2 3";
      default: return "other position";
    endcase
  endfunction

  function automatic string pat_named(pair_t p);
    case (p) matches
      '{a: 1, b: .v} &&& v > 0: return $sformatf("named a1 b%0d", v);
      '{a: 2, b: 3}: return "named a2 b3";
      default: return "other named";
    endcase
  endfunction

  initial begin
    pair_t p1 = '{1, 5};
    pair_t p2 = '{2, 3};
    pair_t p3 = '{4, 4};
    value_t ok = tagged Valid (9);
    value_t no = tagged Invalid;

    $display("int: %s %s %s", pat_int(7), pat_int(8), pat_int(9));
    $display("var: %s", pat_var(42));
    $display("wild: %s", pat_wild(0));
    $display("tag: %s %s", pat_tag(ok), pat_tag(no));
    $display("pos: %s %s %s", pat_pos(p1), pat_pos(p2), pat_pos(p3));
    $display("named: %s %s %s", pat_named(p1), pat_named(p2), pat_named(p3));
  end
endmodule
