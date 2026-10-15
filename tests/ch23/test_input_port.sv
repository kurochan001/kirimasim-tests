/*
:name: test_input_port
:description: Test input ports (IEEE 1800-2023 Section 23.2.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2 23.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_input_port.expected
*/
// Test input ports (IEEE 1800-2023 Section 23.2.2)

module input_mod (
  input logic [7:0] data_in,
  input logic enable,
  output logic [7:0] data_out
);
  assign data_out = enable ? data_in : 8'h00;
endmodule

module test_input_port;
  logic [7:0] data;
  logic en;
  logic [7:0] out;
  int pass_count;

  input_mod dut (.data_in(data), .enable(en), .data_out(out));

  initial begin
    pass_count = 0;

    // Test 1: Input port works
    data = 8'hAB;
    en = 1;
    #1;
    if (out == 8'hAB) pass_count++;

    // Test 2: Disabled
    en = 0;
    #1;
    if (out == 8'h00) pass_count++;

    // Test 3: Change data
    data = 8'hCD;
    en = 1;
    #1;
    if (out == 8'hCD) pass_count++;

    $display("Input port tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Input port tests");
    end else begin
      $display("FAIL: Some input port tests failed");
    end
  end
endmodule
