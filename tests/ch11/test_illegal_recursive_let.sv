/*
:name: test_illegal_recursive_let
:description: a let cannot be instantiated recursively in its own body (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the body of the let countdown instantiates countdown itself
:expected_stderr_regex: test_illegal_recursive_let\.sv:(25|29):
*/
// IEEE 1800-2023 §11.12: the body of a let is expanded with the actual
// arguments, and recursive let instantiations are not permitted. A let whose
// body uses another let declared before it is legal; countdown uses itself.
// A tool can report the declaration or the instantiation.
// Icarus Verilog 13.0 does not support let declarations.

module test_illegal_recursive_let;
  int n = 3, r1, r2;

  let dec(x) = x - 1;
  let twice_dec(x) = dec(dec(x));
  let countdown(x) = (x > 0) ? countdown(x - 1) : 0;   // illegal: a recursive let

  initial begin
    r1 = twice_dec(n);
    r2 = countdown(n);   // (or reported here)
    $display("%0d", r1);
  end
endmodule
