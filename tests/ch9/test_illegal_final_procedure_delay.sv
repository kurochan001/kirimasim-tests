/*
:name: test_illegal_final_procedure_delay
:description: a final procedure can only contain the statements allowed in a function, so it cannot contain a delay (IEEE 1800-2023 Section 9.2.3)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second final procedure contains the delay control #1
:expected_stderr_regex: test_illegal_final_procedure_delay\.sv:39:
*/
// IEEE 1800-2023 §9.2.3: the only statements allowed inside a final procedure
// are those permitted inside a function declaration, since final procedures
// run in zero time as a series of function calls from one process. The first
// final procedure uses a loop, a function call and $display, which a
// function may contain; the second one waits with a delay, which a function
// may not (13.4).

module test_illegal_final_procedure_delay;
  int total;

  function int twice(int v);
    return 2 * v;
  endfunction

  initial begin
    total = 3;
    #5 $finish;
  end

  final begin
    for (int i = 0; i < 2; i++) total = total + twice(i);
    $display("total=%0d", total);
  end

  final begin
    #1 $display("late");   // illegal: a delay in a final procedure
  end
endmodule
