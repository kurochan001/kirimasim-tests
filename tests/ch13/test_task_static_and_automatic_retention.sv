/*
:name: test_task_static_and_automatic_retention
:description: Static task locals retain values between calls while automatic task locals start again (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_static_and_automatic_retention.expected
*/
// IEEE 1800-2023 13.3.2: Repeated sequential calls distinguish static storage
// retention from activation-specific automatic storage without relying on a
// concurrent call order.

module test_task_static_and_automatic_retention;
  task static count_static(output int result);
    int counter;
    counter++; result = counter;
  endtask
  task automatic count_auto(output int result);
    int counter;
    counter++; result = counter;
  endtask
  int a, b, c, d;
  initial begin
    count_static(a); count_static(b); count_auto(c); count_auto(d);
    $display("static=%0d,%0d automatic=%0d,%0d", a, b, c, d);
  end
endmodule
