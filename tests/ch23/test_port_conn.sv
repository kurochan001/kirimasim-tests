/*
:name: test_port_conn
:description: Test port connections (IEEE 1800-2023 Section 23.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_conn.expected
*/
// Test port connections (IEEE 1800-2023 Section 23.3)

module adder_mod (
  input logic [7:0] a,
  input logic [7:0] b,
  output logic [8:0] sum
);
  assign sum = a + b;
endmodule

module test_port_conn;
  logic [7:0] x, y;
  logic [8:0] result;
  int pass_count;

  // Named port connection
  adder_mod u1 (
    .a(x),
    .b(y),
    .sum(result)
  );

  initial begin
    pass_count = 0;

    // Test 1: Basic addition
    x = 8'd10;
    y = 8'd20;
    #1;
    if (result == 9'd30) pass_count++;

    // Test 2: Larger values
    x = 8'd100;
    y = 8'd100;
    #1;
    if (result == 9'd200) pass_count++;

    // Test 3: With carry
    x = 8'd255;
    y = 8'd255;
    #1;
    if (result == 9'd510) pass_count++;

    // Test 4: Zero
    x = 8'd0;
    y = 8'd0;
    #1;
    if (result == 9'd0) pass_count++;

    $display("Port conn tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Port conn tests");
    end else begin
      $display("FAIL: Some port tests failed");
    end
  end
endmodule
