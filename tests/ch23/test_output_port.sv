/*
:name: test_output_port
:description: Test output ports (IEEE 1800-2023 Section 23.2.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.2 23.3.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_output_port.expected
*/
// Test output ports (IEEE 1800-2023 Section 23.2.2)

module output_mod (
  output logic [7:0] data_out,
  output logic valid
);
  initial begin
    data_out = 8'hFF;
    valid = 1;
  end
endmodule

module test_output_port;
  logic [7:0] data;
  logic v;
  int pass_count;

  output_mod dut (.data_out(data), .valid(v));

  initial begin
    pass_count = 0;
    #1;

    // Test 1: Output data
    if (data == 8'hFF) pass_count++;

    // Test 2: Output valid
    if (v == 1) pass_count++;

    // Test 3: Both outputs
    if (data == 8'hFF && v == 1) pass_count++;

    $display("Output port tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Output port tests");
    end else begin
      $display("FAIL: Some output port tests failed");
    end
  end
endmodule
