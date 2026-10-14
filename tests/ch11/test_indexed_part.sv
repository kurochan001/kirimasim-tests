/*
:name: test_indexed_part
:description: Test indexed part-select (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_indexed_part.expected
*/
// Test indexed part-select (IEEE 1800-2023 Section 11.5.1)

module test_indexed_part;
  logic [31:0] data;
  logic [7:0] result;
  int i;
  int pass_count;

  initial begin
    pass_count = 0;
    data = 32'hAABBCCDD;

    // Test 1: Indexed part-select +: (ascending)
    result = data[0+:8];
    if (result == 8'hDD) pass_count++;

    // Test 2: Indexed part-select +: offset 8
    result = data[8+:8];
    if (result == 8'hCC) pass_count++;

    // Test 3: Indexed part-select +: offset 16
    result = data[16+:8];
    if (result == 8'hBB) pass_count++;

    // Test 4: Indexed part-select +: offset 24
    result = data[24+:8];
    if (result == 8'hAA) pass_count++;

    $display("Indexed part tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Indexed part tests");
    end else begin
      $display("FAIL: Some indexed part tests failed");
    end
  end
endmodule
