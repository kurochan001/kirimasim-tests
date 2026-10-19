/*
:name: test_automatic_variable_in_static_subroutine
:description: An automatic variable in a static function or task is initialized again on every call, while a static one keeps its value (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 13.3.1 13.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_automatic_variable_in_static_subroutine.expected
*/
// IEEE 1800-2023 §6.21: in a static task or function (13.3.1, 13.4.2), a
// variable declared automatic is created on each entry and its initializer
// runs on each call, while a static variable is initialized once and keeps
// its value from call to call.

module test_automatic_variable_in_static_subroutine;
  int r, f1, f2;

  function int f(input int x);
    automatic int m = x * 10;
    static int calls = 0;
    calls++;
    return m + calls;
  endfunction

  task t(input int x);
    automatic int m = x;
    m = m + 1;
    r = m;
  endtask

  initial begin
    f1 = f(1);
    f2 = f(2);
    $display("f(1)=%0d f(2)=%0d", f1, f2);
    t(1);
    $display("t(1) gives %0d", r);
    t(5);
    $display("t(5) gives %0d", r);
  end
endmodule
