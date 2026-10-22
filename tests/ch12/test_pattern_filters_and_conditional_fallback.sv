/*
:name: test_pattern_filters_and_conditional_fallback
:description: Pattern filters select a later case item and bind an identifier only along a successful conditional branch (IEEE 1800-2023 Section 12.6.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6.1 12.6.2 12.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pattern_filters_and_conditional_fallback.expected
*/
// IEEE 1800-2023 12.6.1 12.6.2 12.6.3: A structurally matching item with a
// false filter must fall through; if and conditional matches reuse the bound
// payload after a successful tag match.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

module test_pattern_filters_and_conditional_fallback;
  typedef union tagged { void Empty; int Number; } token_t;
  token_t value;
  int selected, conditional_value;
  initial begin
    value = tagged Number 4;
    case (value) matches
      tagged Number .n &&& (n > 8): selected = 1;
      tagged Number .n &&& (n == 4): selected = 2;
      default: selected = 3;
    endcase
    if (value matches tagged Number .n &&& n == 4)
      $display("case=%0d bound=%0d", selected, n);
    value = tagged Empty;
    conditional_value = value matches tagged Number .n ? n : -7;
    $display("fallback=%0d", conditional_value);
  end
endmodule
