/*
:name: test_nonblocking_assignment
:description: Nonblocking procedural assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonblocking_assignment.expected
*/
// IEEE 1800-2023 §10.4.2 Nonblocking procedural assignments
// Test non-blocking assignment scheduling and visibility

module test_nonblocking_assignment;
  logic clk = 0;
  logic [7:0] a, b, c;

  always #5 clk = ~clk;

  initial begin
    a = 8'h00;
    b = 8'h00;
    c = 8'h00;

    @(posedge clk);
    // Non-blocking assignments schedule updates for NBA region
    a <= 8'h10;
    b <= a;  // b gets OLD value of a (0x00)
    c <= b + 1;  // c gets OLD value of b (0x00) + 1

    @(posedge clk);
    // Verify that updates happened in NBA region
    assert(a == 8'h10) else $fatal(1, "a should be 0x10, got 0x%0h", a);
    assert(b == 8'h00) else $fatal(1, "b should be 0x00 (old a), got 0x%0h", b);
    assert(c == 8'h01) else $fatal(1, "c should be 0x01 (old b + 1), got 0x%0h", c);

    // Test simultaneous non-blocking assignments
    a <= 8'h20;
    b <= a;  // Gets 0x10
    c <= b;  // Gets 0x00

    @(posedge clk);
    assert(a == 8'h20) else $fatal(1, "a should be 0x20");
    assert(b == 8'h10) else $fatal(1, "b should be 0x10 (old a)");
    assert(c == 8'h00) else $fatal(1, "c should be 0x00 (old b)");

    $display("PASS: Non-blocking assignment test completed");
    $finish;
  end
endmodule
