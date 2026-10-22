/*
:name: test_program_instances
:description: Each instance of a program has its own variables and initial procedures, and a parameter gives each instance its own initial value (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 6.20
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_instances.expected
*/
// IEEE 1800-2023 §24.3: a program is instantiated like a module, and each
// instance has its own variables and its own initial procedures. §24.2: the
// parameter ID gives a and b different initial values of count, and the delay
// of each initial procedure depends on its own ID, so the order of the
// messages is fixed. §6.20: the parameter is a local constant of the instance.

`timescale 1ns/1ns

program p_inst #(parameter int ID = 0);
  int count = ID;

  initial begin
    #(10 * ID + 1) $display("id=%0d count=%0d", ID, count);
    count = count + 1;
    #5 $display("id=%0d count=%0d", ID, count);
  end
endprogram

module test_program_instances;
  p_inst #(.ID(1)) a();
  p_inst #(.ID(2)) b();

  initial #50 $finish;
endmodule
