/*
:name: test_specparam_from_parameters_and_specparams
:description: a specparam takes a constant expression of parameters and of earlier specparams, in the module body and in a specify block, and the values follow a parameter override (IEEE 1800-2023 Sections 6.20.5 and 6.20.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.5 6.20.2 30.3 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specparam_from_parameters_and_specparams.expected
*/
// IEEE 1800-2023 §6.20.5: the value of a specparam is any constant
// expression; it may use parameters and earlier specparams (Table 6-11).
// §6.20.2: unlike other value parameters, a specparam can be set to an
// expression with specparams. tA uses the parameter P, tB the specparam tA,
// and in the specify block (§30.3) tRise uses tB and P. The instance sets P
// to 3, so tA = 9, tB = 10 and tRise = 13; the path a => y (§30.5.1) has the
// rise delay tRise and the fall delay tA. The module prints tA and tB at time
// 0; the top prints the changes of y after time 10. The path delays of
// specify blocks are not applied by Verilator 5.052 (y changes at 10 and 30).

`timescale 1ns/1ns

module spd_buf #(parameter int P = 2) (output y, input a);
  specparam tA = P * 3;
  specparam tB = tA + 1;

  buf (y, a);
  specify
    specparam tRise = tB + P;
    (a => y) = (tRise, tA);
  endspecify
  initial $display("tA=%0d tB=%0d", tA, tB);
endmodule

module test_specparam_from_parameters_and_specparams;
  reg a = 0;
  wire y;

  spd_buf #(.P(3)) u (y, a);

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);

  initial begin
    #10 a = 1;
    #20 a = 0;
    #20 $finish;
  end
endmodule
