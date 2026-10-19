/*
:name: test_module_automatic_lifetime
:description: In a module declared automatic, variables of its tasks and functions are automatic by default and start again on each call, except those declared static, while module-level variables stay static; in an ordinary module they are static (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 6.8 13.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_automatic_lifetime.expected
*/
// IEEE 1800-2023 §6.21: the lifetime qualifier of a module gives the default
// lifetime of the variables of its tasks, functions and blocks; without one it
// is static. In ma_auto, declared module automatic, calls of count_call each
// start with calls initialized to 0 (6.8), so both calls see 1; kept is
// declared static and keeps counting. module_var is outside any task or
// procedure, so it is static in either case. In ma_static the variable calls
// of count_call is static and keeps its value from the first call (13.3.1).
// The values are stored before they are printed, so the order in which
// arguments are evaluated does not matter.

module automatic ma_auto;
  int module_var = 0;

  task count_call(output int seen);
    int calls;
    calls++;
    module_var++;
    seen = calls;
  endtask

  function int keep();
    static int kept = 0;
    kept++;
    return kept;
  endfunction
endmodule

module ma_static;
  task count_call(output int seen);
    int calls;
    calls++;
    seen = calls;
  endtask
endmodule

module test_module_automatic_lifetime;
  ma_auto a();
  ma_static s();

  initial begin
    int r1, r2, r3, r4, k1, k2;
    a.count_call(r1);
    a.count_call(r2);
    s.count_call(r3);
    s.count_call(r4);
    k1 = a.keep();
    k2 = a.keep();
    $display("automatic module: %0d %0d, module variable %0d", r1, r2, a.module_var);
    $display("static module: %0d %0d", r3, r4);
    $display("explicitly static variable: %0d %0d", k1, k2);
  end
endmodule
