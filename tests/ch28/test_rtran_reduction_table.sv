/*
:name: test_rtran_reduction_table
:description: rtran lowers each driving strength one step as Table 28-8 says, strong and pull to pull and weak, and weak to the medium charge strength (IEEE 1800-2023 Section 28.14)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.14 28.8 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_rtran_reduction_table.expected
*/
// IEEE 1800-2023 §28.14: rtran and the other resistive devices reduce the
// strength of what passes through them as Table 28-8 says: supply and strong
// become pull, pull becomes weak, and weak becomes medium. Each a net is
// driven with one strength, and its b net, connected only through an rtran
// (28.8), shows the reduced strength with %v (21.2.1.4).

`timescale 1ns/1ns

module test_rtran_reduction_table;
  logic v = 1'b1;
  wire a_st, b_st, a_pu, b_pu, a_we, b_we;

  assign (strong0, strong1) a_st = v;
  assign (pull0, pull1) a_pu = v;
  assign (weak0, weak1) a_we = v;

  rtran r1(a_st, b_st);
  rtran r2(a_pu, b_pu);
  rtran r3(a_we, b_we);

  initial begin
    #1 $display("strong: %v -> %v", a_st, b_st);
    $display("pull:   %v -> %v", a_pu, b_pu);
    $display("weak:   %v -> %v", a_we, b_we);
    v = 1'b0;
    #1 $display("strong: %v -> %v", a_st, b_st);
    $display("pull:   %v -> %v", a_pu, b_pu);
    $display("weak:   %v -> %v", a_we, b_we);
  end
endmodule
