/*
:name: test_type_casts_2
:description: Test type casts (IEEE 1800-2023 Section 6.24)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_casts_2.expected
*/
// Test type casts (IEEE 1800-2023 Section 6.24)

module test_type_casts;
  logic [31:0] logic_val;
  int int_val;
  real real_val;
  shortint short_val;
  longint long_val;
  byte byte_val;
  bit [31:0] bit_val;
  string str_val;
  typedef bit [31:0] bit32_t;

  initial begin
    static int pass_count = 0;

    // Test 1: int to logic
    int_val = 12345;
    logic_val = int_val;
    if (logic_val == 32'd12345) pass_count++;

    // Test 2: logic to int
    logic_val = 32'hABCD;
    int_val = int'(logic_val);
    if (int_val == 32'hABCD) pass_count++;

    // Test 3: int to real
    int_val = 100;
    real_val = real'(int_val);
    if (real_val == 100.0) pass_count++;

    // Test 4: real to int
    real_val = 123.456;
    int_val = int'(real_val);
    if (int_val == 123) pass_count++;

    // Test 5: logic to bit [31:0] (a cast to plain bit would give one bit)
    logic_val = 32'hDEADBEEF;
    bit_val = bit32_t'(logic_val);
    if (bit_val == 32'hDEADBEEF) pass_count++;

    // Test 6: shortint to int
    short_val = 16'h7FFF;
    int_val = int'(short_val);
    if (int_val == 32767) pass_count++;

    // Test 7: int to byte
    int_val = 255;
    byte_val = byte'(int_val);
    if (byte_val == 8'hFF) pass_count++;

    // Test 8: longint to int (truncation)
    long_val = 64'h123456789ABCDEF0;
    int_val = int'(long_val);
    if (int_val == 32'h9ABCDEF0) pass_count++;

    // Test 9: int to longint
    int_val = -1;
    long_val = longint'(int_val);
    if (long_val == -1) pass_count++;

    // Test 10: signed cast
    logic_val = 32'hFFFFFFFF;
    int_val = signed'(logic_val);
    if (int_val == -1) pass_count++;

    // Test 11: unsigned cast
    int_val = -1;
    logic_val = unsigned'(int_val);
    if (logic_val == 32'hFFFFFFFF) pass_count++;

    // Test 12: Width cast
    logic_val = 32'hABCDEF01;
    byte_val = 8'(logic_val);
    if (byte_val == 8'h01) pass_count++;

    $display("Type cast tests: %0d/12 passed", pass_count);
    if (pass_count == 12) begin
      $display("PASS: Type cast tests");
    end else begin
      $display("FAIL: Too few type cast tests passed");
    end
  end
endmodule
