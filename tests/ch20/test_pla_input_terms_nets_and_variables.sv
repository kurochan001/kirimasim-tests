/*
:name: test_pla_input_terms_nets_and_variables
:description: The input terms of a PLA system task can be nets as well as variables, and an asynchronous array with net inputs gives the same outputs as one with variable inputs and the same personality (IEEE 1800-2023 Section 20.16)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pla_input_terms_nets_and_variables.expected
*/
// IEEE 1800-2023 §20.16: the input terms of a PLA system task can be nets
// or variables, while the output terms are variables. Both calls of
// $async$and$array here use the personality mem, whose words select the
// inputs of each output (20.16.3, 20.16.4): mem[1] = 110 gives
// b1 = in1 & in2 and mem[2] = 011 gives b2 = in2 & in3. The first call
// takes the wires n1 to n3, driven by continuous assignments from d1 to d3;
// the second takes the variables v1 to v3. An asynchronous array is
// evaluated again whenever an input term or a word of the personality
// changes (20.16.1). The tasks are called before the personality is written,
// and each step gives the same values to d and v and prints after #1, so
// both arrays print b1 b2 = 10, 01, 11 and 00 for the inputs 110, 011, 111
// and 100. An array that did not follow its net inputs would keep its old
// outputs, which the changes of every step would show.
// Neither Icarus Verilog 13.0 nor the 5.054 release of Verilator implements
// the PLA tasks.

`timescale 1ns/1ns

module test_pla_input_terms_nets_and_variables;
  logic [1:3] mem [1:2];
  logic d1 = 0, d2 = 0, d3 = 0;
  wire n1, n2, n3;
  logic v1 = 0, v2 = 0, v3 = 0;
  logic bn1, bn2, bv1, bv2;

  assign n1 = d1;
  assign n2 = d2;
  assign n3 = d3;

  task automatic step(logic [1:3] in);
    {d1, d2, d3} = in;
    {v1, v2, v3} = in;
    #1 $display("in = %b: nets %b%b, variables %b%b", in, bn1, bn2, bv1, bv2);
  endtask

  initial begin
    $async$and$array(mem, {n1, n2, n3}, {bn1, bn2});
    $async$and$array(mem, {v1, v2, v3}, {bv1, bv2});
    mem[1] = 3'b110;
    mem[2] = 3'b011;
    step(3'b110);
    step(3'b011);
    step(3'b111);
    step(3'b100);
  end
endmodule
