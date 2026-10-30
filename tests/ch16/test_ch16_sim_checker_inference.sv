/*
:name: test_ch16_sim_checker_inference
:description: a sequence with the method triggered passed as an actual to a checker is substituted for the checker's sequence formal and clocked by the checker's inferred clock (IEEE 1800-2023 Section 16.13.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.6 16.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch16_sim_checker_inference.expected
*/
// IEEE 1800-2023 §16.13.6: if a sequence with a method is passed as an
// actual argument to a checker instantiation, it is substituted in place of
// the corresponding formal argument and shall be clocked as if it were
// instantiated inside the checker. The clock-free sequence e4 is only used
// as e4.triggered in the actual of checker chk, whose default clocking is
// the formal c. e4 therefore samples b at the rising ticks of c, and
// e4.triggered is true at a c tick where that sample is 1. c rises at 10,
// 30, 50 and 70; b is 1 before 25 and between 35 and 55, so the c ticks at
// 10 and 50 see b as 1 while the ticks at 30 and 70 do not. The example
// cover statement prints a line at each of the two hits. The checker prints
// its count in a final procedure (§17.5), because §23.6 forbids hierarchical
// references into a checker from the module.
// Neither simulator can run this test: Icarus Verilog 13.0 does not support
// checkers and Verilator 5.052 reports "Unsupported: sequence argument data
// type". The expected output is the behavior that §16.13.6 defines.

`timescale 1ns/1ns

checker chk(logic c, sequence s);
  default clocking @(posedge c); endclocking
  int hits = 0;
  c1: cover property (s) begin
        hits++;
        $display("triggered at %0t", $time);
      end
  final $display("hits=%0d", hits);
endchecker

module test_ch16_sim_checker_inference;
  logic b = 0;
  logic c = 0;

  sequence e4;
    b;
  endsequence

  always #10 c = ~c;

  chk i1(c, e4.triggered);

  initial begin
    b = 1;
    #25 b = 0;
    #10 b = 1;
    #20 b = 0;
    #30;
    $finish;
  end
endmodule
