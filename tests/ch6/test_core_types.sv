/*
:name: test_core_types
:description: Test core types (IEEE 1800-2023 Section 6)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 6.12 6.16 6.4
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_core_types.expected
*/
// Test core types (IEEE 1800-2023 Section 6)

module test_core_types;
  // Various types
  bit b;
  logic l;
  reg r;
  integer i;
  real re;
  shortreal sr;
  time t;
  shortint si;
  int ii;
  longint li;
  byte by;
  string s;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: bit type
    b = 1'b1;
    if (b == 1'b1) pass_count++;

    // Test 2: logic type
    l = 1'bx;
    if ($isunknown(l)) pass_count++;

    // Test 3: reg type
    r = 1'b0;
    if (r == 1'b0) pass_count++;

    // Test 4: integer type
    i = -100;
    if (i == -100) pass_count++;

    // Test 5: real type
    re = 3.14159;
    if (re > 3.14 && re < 3.15) pass_count++;

    // Test 6: time type
    t = 1000;
    if (t == 1000) pass_count++;

    // Test 7: shortint type
    si = -32000;
    if (si == -32000) pass_count++;

    // Test 8: int type
    ii = 2147483647;
    if (ii == 2147483647) pass_count++;

    // Test 9: byte type
    by = 8'hAB;
    if (by == 8'hAB) pass_count++;

    // Test 10: string type
    s = "hello";
    if (s == "hello") pass_count++;

    $display("Core types tests: %0d/10 passed", pass_count);
    if (pass_count >= 9) begin
      $display("PASS: Core types tests");
    end else begin
      $display("FAIL: Some core type tests failed");
    end
  end
endmodule
