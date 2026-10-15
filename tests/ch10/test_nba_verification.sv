/*
:name: test_nba_verification
:description: Direct signal monitoring
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 25.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_verification.expected
*/
interface simple_ifc(input logic clk);
  logic d, q;
endinterface

module dut(simple_ifc i);
  always_ff @(posedge i.clk) i.q <= i.d;
endmodule

module test_nba_verification;
  logic clk = 0;
  simple_ifc i(clk);
  dut u(i);

  // Direct signal monitoring
  logic local_d, local_q;
  assign local_d = i.d;
  assign local_q = i.q;

  always #1 clk = ~clk;

  initial begin
    i.d = 0;
    repeat (2) @(posedge clk);
    i.d = 1;
    repeat (2) @(posedge clk);

    // Check using local signals (continuous assignment)
    if (local_q !== 1) begin
      $display("FAIL: local_q = %b (expected 1)", local_q);
      $fatal(1, "Test failed via local_q");
    end

    // Check using interface signal directly
    if (i.q !== 1) begin
      $display("FAIL: i.q = %b (expected 1)", i.q);
      $fatal(1, "Test failed via i.q");
    end

    $display("PASS: Both local_q and i.q = 1");
    $finish;
  end
endmodule
