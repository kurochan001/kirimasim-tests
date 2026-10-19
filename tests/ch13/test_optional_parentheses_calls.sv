/*
:name: test_optional_parentheses_calls
:description: Tasks and void functions with no arguments, or with defaults for all of them, can be called without parentheses (IEEE 1800-2023 Section 13.5.5)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.5 13.5.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_optional_parentheses_calls.expected
*/
// IEEE 1800-2023 §13.5.5: the empty parentheses after the name of a task or a
// void function that has no arguments may be left out, and so may they when
// every argument has a default value (13.5.3), in which case the defaults are
// used.

module test_optional_parentheses_calls;
  int n = 0;

  task bump;
    n += 1;
  endtask

  task add(int k = 5);
    n += k;
  endtask

  function void addf(int k = 100);
    n += k;
  endfunction

  initial begin
    bump;
    $display("after bump: n=%0d", n);
    bump();
    $display("after bump(): n=%0d", n);
    add;
    $display("after add: n=%0d", n);
    add(2);
    $display("after add(2): n=%0d", n);
    addf;
    $display("after addf: n=%0d", n);
  end
endmodule
