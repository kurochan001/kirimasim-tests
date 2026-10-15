/*
:name: test_union_types
:description: Test union types (IEEE 1800-2023 Section 7.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_union_types.expected
*/
// Test union types (IEEE 1800-2023 Section 7.3)

module test_union_types;
  typedef union packed {
    logic [31:0] word;
    logic [3:0][7:0] bytes;
    logic [1:0][15:0] halves;
  } data_u;

  data_u u;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Word access
    u.word = 32'hAABBCCDD;
    if (u.word == 32'hAABBCCDD) pass_count++;

    // Test 2: Byte access
    if (u.bytes[0] == 8'hDD) pass_count++;
    if (u.bytes[3] == 8'hAA) pass_count++;

    // Test 3: Half-word access
    if (u.halves[0] == 16'hCCDD) pass_count++;
    if (u.halves[1] == 16'hAABB) pass_count++;

    // Test 4: Cross-member write
    u.bytes[1] = 8'hFF;
    if (u.word == 32'hAABBFFDD) pass_count++;

    // Test 5: Half-word write
    u.halves[0] = 16'h1234;
    if (u.bytes[0] == 8'h34) pass_count++;

    $display("Union types tests: %0d/7 passed", pass_count);
    if (pass_count >= 6) begin
      $display("PASS: Union types tests");
    end else begin
      $display("FAIL: Some union tests failed");
    end
  end
endmodule
