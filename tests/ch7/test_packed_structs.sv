/*
:name: test_packed_structs
:description: Test packed structures (IEEE 1800-2023 Section 7.2.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_structs.expected
*/
// Test packed structures (IEEE 1800-2023 Section 7.2.1)

module test_packed_structs;
  typedef struct packed {
    logic [7:0] byte3;
    logic [7:0] byte2;
    logic [7:0] byte1;
    logic [7:0] byte0;
  } word_t;

  typedef struct packed {
    logic valid;
    logic [6:0] tag;
    logic [23:0] data;
  } packet_t;

  word_t w;
  packet_t p;
  logic [31:0] raw;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Individual field access
    w.byte0 = 8'h11;
    w.byte1 = 8'h22;
    w.byte2 = 8'h33;
    w.byte3 = 8'h44;
    if (w.byte0 == 8'h11) pass_count++;
    if (w.byte3 == 8'h44) pass_count++;

    // Test 2: Struct to logic conversion
    raw = w;
    if (raw == 32'h44332211) pass_count++;

    // Test 3: Logic to struct conversion
    raw = 32'hAABBCCDD;
    w = raw;
    if (w.byte0 == 8'hDD) pass_count++;
    if (w.byte3 == 8'hAA) pass_count++;

    // Test 4: Packed struct with mixed fields
    p.valid = 1'b1;
    p.tag = 7'h5A;
    p.data = 24'hCAFE01;
    if (p.valid == 1'b1) pass_count++;
    if (p.tag == 7'h5A) pass_count++;
    if (p.data == 24'hCAFE01) pass_count++;

    // Test 5: Struct comparison
    begin
      word_t w2;
      w2 = w;
      if (w == w2) pass_count++;
    end

    $display("Packed struct tests: %0d/9 passed", pass_count);
    if (pass_count >= 8) begin
      $display("PASS: Packed struct tests");
    end else begin
      $display("FAIL: Some packed struct tests failed");
    end
  end
endmodule
