/*
:name: test_streaming_op
:description: Test streaming operators (IEEE 1800-2023 Section 11.4.14)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_op.expected
*/
// Test streaming operators (IEEE 1800-2023 Section 11.4.14)

module test_streaming_op;
  logic [31:0] data;
  logic [7:0] bytes[4];
  int pass_count;

  initial begin
    pass_count = 0;
    data = 32'h12345678;

    // Test 1: Stream right (big-endian unpack)
    {>>{bytes}} = data;
    if (bytes[0] == 8'h12 && bytes[3] == 8'h78) pass_count++;

    // Test 2: Stream left (little-endian unpack)
    {<<8{bytes}} = data;
    if (bytes[0] == 8'h78 && bytes[3] == 8'h12) pass_count++;

    // Test 3: Pack back
    bytes = '{8'hAA, 8'hBB, 8'hCC, 8'hDD};
    data = {>>{bytes}};
    if (data == 32'hAABBCCDD) pass_count++;

    $display("Streaming op tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Streaming op tests");
    end else begin
      $display("FAIL: Some streaming op tests failed");
    end
  end
endmodule
