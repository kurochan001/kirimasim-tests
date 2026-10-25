/*
:name: test_illegal_randomize_argument_local
:description: a randomize() call outside the class that passes a local property as an argument is an error (IEEE 1800-2023 Section 18.11)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.11 8.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module calls o.randomize(secret), but secret is local to ral_obj, and only code within that class can change its random mode
:expected_stderr_regex: test_illegal_randomize_argument_local\.sv:41:
*/
// IEEE 1800-2023 §18.11: the arguments of randomize() name properties of the
// object, and the random mode of a local property can only be changed by a
// call that has access to it, that is, a call within the class that declares
// it (§8.18). The method roll of ral_obj calls randomize(secret), which is
// legal. The module calls o.randomize(open), a property that is not local,
// which is legal too, and then o.randomize(secret), which is the error.
// test_illegal_randomize_argument_expression passes an expression.
// Icarus Verilog 13.0 does not support randomize(), so its error does not
// count.

class ral_obj;
  rand bit [3:0] x;
  bit [3:0] open;
  local bit [3:0] secret;

  function int roll();
    return randomize(secret);
  endfunction
endclass

module test_illegal_randomize_argument_local;
  ral_obj o = new;
  int r1, r2, r3;

  initial begin
    r1 = o.roll();
    r2 = o.randomize(open);
    r3 = o.randomize(secret);   // illegal: secret is local to ral_obj
    $display("%0d %0d %0d", r1, r2, r3);
  end
endmodule
