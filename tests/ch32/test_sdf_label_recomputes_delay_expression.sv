/*
:name: test_sdf_label_recomputes_delay_expression
:description: An SDF label update re-evaluates a dependent procedural delay expression (IEEE 1800-2023 Section 32.4.3)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_label_recomputes_delay_expression.expected
*/
// IEEE 1800-2023 32.4.3: The specparam starts at two and an increment of three
// makes a twice-parameter delay ten; sampling distinguishes that result from
// the original four.
// Oracle checks: Icarus Verilog 13.0 does not reproduce the clause-derived
// output. The 5.052 release does not reproduce the clause-derived output.

`timescale 1ns/1ns
module expression_label_leaf(output reg pulse);
  specparam D = 2;
  initial begin pulse = 0; #10 pulse = 1; #(2*D) pulse = 0; end
endmodule
module test_sdf_label_recomputes_delay_expression;
  wire pulse;
  integer fd;
  expression_label_leaf u(pulse);
  initial begin
    fd = $fopen("label.sdf", "w");
    if (fd == 0) $fatal(1, "open failed");
    $fdisplay(fd, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(fd, "(CELL (CELLTYPE \"expression_label_leaf\") (INSTANCE u)");
    $fdisplay(fd, "(LABEL (ABSOLUTE (D 5)))))");
    $fclose(fd); $sdf_annotate("label.sdf");
    #17 $display("during=%b", pulse);
    #4 $display("after=%b", pulse);
  end
endmodule
