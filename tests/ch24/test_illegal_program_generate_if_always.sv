/*
:name: test_illegal_program_generate_if_always
:description: An always procedure is as illegal in a conditional generate block of a program as it is directly in the program (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the selected block of an if generate construct in the program pga_p contains an always procedure
:expected_stderr_regex: test_illegal_program_generate_if_always\.sv:28:
*/
// IEEE 1800-2023 §24.3: a program shall not contain always procedures, and,
// by footnote 5 of Syntax 24-1, a program_generate_item shall not contain any
// item that would be illegal in the program outside the generate item. In
// pga_p, the if generate construct (27.5) selects the block g_on, whose
// initial procedure is legal but whose always procedure is not. The program
// has no always procedure outside the generate construct.
// Oracle checks: the 5.052 release of Verilator, which rejects an always
// procedure written directly in a program, accepts this design.

program pga_p #(parameter bit EN = 1'b1) (input logic clk);
  int n = 0;

  if (EN) begin : g_on
    initial #12 $display("n=%0d", n);
    always @(posedge clk) n++;   // illegal: always in a program generate block
  end
endprogram

module test_illegal_program_generate_if_always;
  logic clk = 1'b0;
  always #5 clk = ~clk;
  pga_p u_p (clk);
endmodule
