/*
:name: test_syntax_expect_property_statement
:description: expect takes a property and an action block, runs the statement before else when the property matches and the else statement when it does not, and waits for the property to finish (IEEE 1800-2023 Section 16.17, A.6.4, A.6.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.17 A.6.4 A.6.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_expect_property_statement.expected
*/
// IEEE 1800-2023 A.6.4: a statement item may be an expect_property_statement.
// §16.17: expect ( property_spec ) action_block starts the property when it
// executes, blocks the process until the property completes, and runs the
// pass statement before else when it matches and the else statement when it
// fails.
//
// The property is the clocked expression a == 1 at each rising edge. The
// first expect is reached with a = 1 and passes at the edge at 5; the second
// is reached with a = 0 and fails at the edge at 15; the third is reached
// with a = 1 again and passes at the edge at 25. Each action prints its time.
//
// The expected output follows the standard; Icarus Verilog 13.0 and the
// 5.052 release of the other simulator do not support expect.

`timescale 1ns/1ns

module test_syntax_expect_property_statement;
  logic clk = 1'b0;
  logic a = 1'b0;

  always #5 clk = ~clk;

  initial begin
    a = 1;
    expect (@(posedge clk) a == 1) $display("%0t expect pass", $time);
      else $display("wrong");

    a = 0;
    expect (@(posedge clk) a == 1) $display("wrong");
      else $display("%0t expect fail", $time);

    a = 1;
    expect (@(posedge clk) a == 1) $display("%0t expect pass again", $time);
      else $display("wrong");

    $finish;
  end
endmodule
