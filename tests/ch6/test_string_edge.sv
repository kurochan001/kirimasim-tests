/*
:name: test_string_edge
:description: String edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 6.16.9 6.16.10 6.16.11 6.16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_edge.expected
*/
// IEEE 1800-2023 §6.16: String edge cases
`timescale 1ns/1ps

module test_string_edge;
  string s, s2, s3;
  int i;
  real r;
  bit test_passed;

  initial begin
    test_passed = 1;

    // Test 1: Empty string
    s = "";
    if (s.len() != 0) begin
      $display("FAIL: Empty string len should be 0");
      test_passed = 0;
    end

    // Test 2: Basic assignment and len
    s = "Hello";
    if (s.len() != 5) begin
      $display("FAIL: 'Hello' len should be 5");
      test_passed = 0;
    end

    // Test 3: getc
    if (s.getc(0) != 72) begin  // 'H' = 72
      $display("FAIL: getc(0) should be 72 ('H')");
      test_passed = 0;
    end

    // Test 4: putc
    s.putc(0, 74);  // 'J'
    if (s != "Jello") begin
      $display("FAIL: putc failed, got '%s'", s);
      test_passed = 0;
    end

    // Test 5: toupper
    s = "hello";
    s2 = s.toupper();
    if (s2 != "HELLO") begin
      $display("FAIL: toupper failed, got '%s'", s2);
      test_passed = 0;
    end

    // Test 6: tolower
    s = "WORLD";
    s2 = s.tolower();
    if (s2 != "world") begin
      $display("FAIL: tolower failed, got '%s'", s2);
      test_passed = 0;
    end

    // Test 7: compare
    s = "abc";
    s2 = "abd";
    if (s.compare(s2) >= 0) begin
      $display("FAIL: 'abc'.compare('abd') should be < 0");
      test_passed = 0;
    end

    // Test 8: icompare (case insensitive)
    s = "ABC";
    s2 = "abc";
    if (s.icompare(s2) != 0) begin
      $display("FAIL: 'ABC'.icompare('abc') should be 0");
      test_passed = 0;
    end

    // Test 9: substr
    s = "Hello World";
    s2 = s.substr(0, 4);
    if (s2 != "Hello") begin
      $display("FAIL: substr(0,4) should be 'Hello', got '%s'", s2);
      test_passed = 0;
    end

    // Test 10: atoi
    s = "12345";
    i = s.atoi();
    if (i != 12345) begin
      $display("FAIL: atoi() should be 12345, got %0d", i);
      test_passed = 0;
    end

    // Test 11: atoi does not read a sign, so "-999" gives 0 (6.16.9)
    s = "-999";
    i = s.atoi();
    if (i != 0) begin
      $display("FAIL: atoi('-999') should be 0, got %0d", i);
      test_passed = 0;
    end

    // Test 12: atohex
    s = "FF";
    i = s.atohex();
    if (i != 255) begin
      $display("FAIL: atohex('FF') should be 255, got %0d", i);
      test_passed = 0;
    end

    // Test 13: atobin
    s = "1010";
    i = s.atobin();
    if (i != 10) begin
      $display("FAIL: atobin('1010') should be 10, got %0d", i);
      test_passed = 0;
    end

    // Test 14: atooct
    s = "77";
    i = s.atooct();
    if (i != 63) begin
      $display("FAIL: atooct('77') should be 63, got %0d", i);
      test_passed = 0;
    end

    // Test 15: atoreal
    s = "3.14159";
    r = s.atoreal();
    if (r < 3.14 || r > 3.15) begin
      $display("FAIL: atoreal failed, got %f", r);
      test_passed = 0;
    end

    // Test 16: itoa
    s = "";
    s.itoa(42);
    if (s != "42") begin
      $display("FAIL: itoa(42) should be '42', got '%s'", s);
      test_passed = 0;
    end

    // Test 17: hextoa
    s = "";
    s.hextoa(255);
    if (s.tolower() != "ff") begin
      $display("FAIL: hextoa(255) should be 'ff', got '%s'", s);
      test_passed = 0;
    end

    // Test 18: String concatenation
    s = "Hello";
    s2 = " World";
    s3 = {s, s2};
    if (s3 != "Hello World") begin
      $display("FAIL: Concatenation failed, got '%s'", s3);
      test_passed = 0;
    end

    // Test 19: String with literal concatenation
    s = "ab";
    s2 = "cd";
    s3 = {s, s2};
    if (s3 != "abcd") begin
      $display("FAIL: String variable concat failed, got '%s'", s3);
      test_passed = 0;
    end

    // Test 20: Empty string operations
    s = "";
    s2 = s.toupper();
    if (s2 != "") begin
      $display("FAIL: toupper on empty should be empty");
      test_passed = 0;
    end

    if (test_passed) begin
      $display("PASS: String edge cases");
    end else begin
      $display("FAIL: Some string tests failed");
    end
    $finish;
  end
endmodule
