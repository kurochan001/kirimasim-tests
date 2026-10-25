/*
:name: test_syntax_case_matches_and_inside_forms
:description: case with matches takes a pattern item with an optional &&& guard, and case with inside takes a range list of all six value range forms, and each runs the item of the first match (IEEE 1800-2023 Sections 12.5.4 and 12.6.1, A.6.7, A.6.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5 12.5.4 12.6.1 A.6.7 A.6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_case_matches_and_inside_forms.expected
*/
// IEEE 1800-2023 A.6.7: "case ( expression ) matches" takes case_pattern_item
// items, each a pattern with an optional "&&& expression" and a colon before
// its statement; "case ( expression ) inside" takes case_inside_item items,
// each a range_list. §12.5.4: a case inside item matches when the case
// expression is a member of the range list. §12.6.1: the first matching
// pattern item runs, and a pattern variable takes the matching value.
//
// matched shows an enum matched by a constant pattern and by a pattern with a
// guard that uses the matched value; when the guard is false the next item
// runs. inside_ranges shows the six value ranges for an 8-bit unsigned value,
// where $ is 255: [2:4] is 2 to 4, [10 +/- 2] is 8 to 12, 20 is the single
// value 20, [30 +%- 10] is 30 plus and minus 10 percent, that is 27 to 33,
// [250:$] is 250 to 255, and [$:240] is 0 to 240. A value that matches none
// of them runs default.
//
// The expected output follows the standard; Icarus Verilog 13.0 does not
// support case with matches, and Verilator 5.052 does not support the +/- or
// +%- range.

module test_syntax_case_matches_and_inside_forms;
  typedef enum logic [1:0] {RED, GREEN, BLUE} color_t;

  function automatic int matched(color_t c, int v);
    case (c) matches
      RED: return 1;
      GREEN &&& v > 0: return 2;
      GREEN: return 3;
      default: return 4;
    endcase
  endfunction

  function automatic int inside_ranges(input logic [7:0] x);
    case (x) inside
      [2:4]: return 1;
      [10 +/- 2]: return 2;
      20: return 3;
      [30 +%- 10]: return 4;
      [250:$]: return 5;
      [$:240]: return 6;
      default: return 0;
    endcase
  endfunction

  initial begin
    $display("matches: %0d %0d %0d %0d",
             matched(RED, 0), matched(GREEN, 1), matched(GREEN, 0),
             matched(BLUE, 0));
    $display("ranges: %0d %0d %0d %0d %0d %0d %0d",
             inside_ranges(3), inside_ranges(9), inside_ranges(20),
             inside_ranges(31), inside_ranges(252), inside_ranges(240),
             inside_ranges(100));
  end
endmodule
