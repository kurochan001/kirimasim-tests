/*
:name: test_macro_actual_substituted_literally
:description: Each actual argument of a macro is substituted as text for every use of its formal argument, so an expression is not grouped and a function call is evaluated once per use; a formal argument is replaced only where it stands as a whole identifier, up to the end of the macro text, also across a continued line (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_actual_substituted_literally.expected
*/
// IEEE 1800-2023 §22.5.1: each actual argument is substituted for its formal
// argument literally, so an expression given as actual is substituted whole
// and is evaluated as many times as the formal appears. SQ(1 + 2) becomes
// (1 + 2 * 1 + 2), which is 5, not 9; TWICE(bump()) calls bump twice, which
// returns 1 and 2, so the sum is 3 and calls is 2 in either order of the
// calls. A formal argument is used in the macro text like an identifier and
// its scope extends to the end of the text: in SCOPE(5), n_off is another
// identifier and stays a variable of the module, and n is replaced also on
// the continued line, giving 5 + 1000 + 5 + 5.

`define SQ(x) (x * x)
`define TWICE(x) (x + x)
`define SCOPE(n) (n + n_off + \
  n + n)

module test_macro_actual_substituted_literally;
  int n_off = 1000;
  int calls = 0;
  int v;

  function automatic int bump();
    calls++;
    return calls;
  endfunction

  initial begin
    $display("SQ(1 + 2): %0d", `SQ(1 + 2));
    v = `TWICE(bump());
    $display("TWICE(bump()): %0d calls=%0d", v, calls);
    $display("SCOPE(5): %0d", `SCOPE(5));
  end
endmodule
