/*
:name: test_module_port
:description: Test module ports (IEEE 1800-2023 Section 23.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.2 23.3.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_port.expected
*/
// Test module ports (IEEE 1800-2023 Section 23.2)

module port_child (
  input logic [7:0] in_a,
  input logic [7:0] in_b,
  output logic [7:0] out_sum,
  output logic out_carry
);
  assign {out_carry, out_sum} = in_a + in_b;
endmodule

module test_module_port;
  logic [7:0] a, b, sum;
  logic carry;
  int pass_count;

  port_child u1 (
    .in_a(a),
    .in_b(b),
    .out_sum(sum),
    .out_carry(carry)
  );

  initial begin
    pass_count = 0;

    // Test 1: Basic port connection
    a = 8'd10;
    b = 8'd20;
    #1;
    if (sum == 8'd30) pass_count++;

    // Test 2: Carry generation
    a = 8'hFF;
    b = 8'h01;
    #1;
    if (carry == 1'b1 && sum == 8'h00) pass_count++;

    // Test 3: No carry
    a = 8'd50;
    b = 8'd50;
    #1;
    if (carry == 1'b0 && sum == 8'd100) pass_count++;

    // Test 4: Zero inputs
    a = 8'd0;
    b = 8'd0;
    #1;
    if (sum == 8'd0 && carry == 1'b0) pass_count++;

    // Test 5: Max values
    a = 8'hFE;
    b = 8'h01;
    #1;
    if (sum == 8'hFF && carry == 1'b0) pass_count++;

    $display("Module port tests: %0d/5 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Module port tests");
    end else begin
      $display("FAIL: Some port tests failed");
    end
  end
endmodule
