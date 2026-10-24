/*
:name: test_module_contains_specify_block
:description: A specify block in a module, with specparams and a module path from an input port to an output port with separate rise and fall delays, delays the output by 3 on a rise and 5 on a fall (IEEE 1800-2023 Section 3.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.3 30.3 30.4.1 30.5 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_contains_specify_block.expected
*/
// IEEE 1800-2023 §3.3: a module can contain specify blocks. In the specify
// block of spec_buf, specparams give a rise delay of 3 and a fall delay of 5
// (§30.5), and a simple module path from input a to output y uses them
// (§30.3, §30.4.1): the 0 to 1 change of a at time 10 reaches y at 13, and
// the 1 to 0 change at time 20 reaches y at 25 (§30.5.1: two delays are the
// rise and the fall delay). The buffer gate itself has no delay, so without
// the path delay y would follow a at once. y is printed one time unit before
// and one after each expected change.

`timescale 1ns/1ns

module spec_buf(input wire a, output wire y);
  buf g(y, a);

  specify
    specparam t_rise = 3, t_fall = 5;
    (a => y) = (t_rise, t_fall);
  endspecify
endmodule

module test_module_contains_specify_block;
  logic a = 1'b0;
  wire y;

  spec_buf u(.a(a), .y(y));

  initial begin
    #10 a = 1'b1;
    #2 $display("t=%0t a=%b y=%b", $time, a, y);
    #2 $display("t=%0t a=%b y=%b", $time, a, y);
    #6 a = 1'b0;
    #4 $display("t=%0t a=%b y=%b", $time, a, y);
    #2 $display("t=%0t a=%b y=%b", $time, a, y);
    $finish;
  end
endmodule
