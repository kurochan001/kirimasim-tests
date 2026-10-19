/*
:name: test_task_output_formal_initial_value
:description: An output formal starts from its own initial value, not from the caller's argument, in automatic and static tasks (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 6.21 13.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_output_formal_initial_value.expected
*/
// IEEE 1800-2023 §13.3: the value of an output formal is copied to the
// actual argument when the task returns, and nothing is copied in when it is
// called; only an inout formal is copied in. The formals of an automatic
// task are new for each call and start like other automatic variables
// (6.21), an int at 0, so "o = o + d" gives d whatever the caller's variable
// holds. The formals of a static task are static (13.3.1) and keep their
// values between calls, so in a static task o starts from what the previous
// call left in it.

module test_task_output_formal_initial_value;
  task automatic add_to(input int d, output int o);
    o = o + d;
  endtask

  task automatic add_later(input int d, output int o);
    #1 o = o + d;
  endtask

  task automatic add_inout(input int d, inout int o);
    o = o + d;
  endtask

  task add_static(input int d, output int o);
    o = o + d;
  endtask

  int a = 100, b = 100, c = 100, s1 = 100, s2 = 100;

  initial begin
    add_to(5, a);
    add_later(5, b);
    add_inout(5, c);
    add_static(5, s1);
    add_static(5, s2);
    $display("automatic output: %0d", a);
    $display("automatic output after a delay: %0d", b);
    $display("automatic inout: %0d", c);
    $display("static output, first call: %0d, second call: %0d", s1, s2);
  end
endmodule
