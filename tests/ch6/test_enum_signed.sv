/*
:name: test_enum_signed
:description: Signed enum values and the first, last, num, next and prev methods
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.19.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_signed.expected
*/
`timescale 1ns/1ps

module test_enum_signed;
  typedef enum int signed {NEG=-10, ZERO=0, POS=10} signed_t;

  signed_t sg;
  int i;
  bit test_passed;

  initial begin
    test_passed = 1;

    // Test: Check enum values
    sg = NEG;
    i = int'(sg);
    $display("NEG = %0d (expected -10)", i);
    if (i != -10) test_passed = 0;

    sg = ZERO;
    i = int'(sg);
    $display("ZERO = %0d (expected 0)", i);
    if (i != 0) test_passed = 0;

    sg = POS;
    i = int'(sg);
    $display("POS = %0d (expected 10)", i);
    if (i != 10) test_passed = 0;

    // Test: first() and last()
    sg = sg.first();
    i = int'(sg);
    $display("first() = %0d (expected -10)", i);
    if (i != -10) test_passed = 0;

    sg = sg.last();
    i = int'(sg);
    $display("last() = %0d (expected 10)", i);
    if (i != 10) test_passed = 0;

    // Test: num()
    i = sg.num();
    $display("num() = %0d (expected 3)", i);
    if (i != 3) test_passed = 0;

    // Test: next() from NEG
    sg = NEG;
    sg = sg.next();
    i = int'(sg);
    $display("NEG.next() = %0d (expected 0)", i);
    if (i != 0) test_passed = 0;

    // Test: next() from ZERO
    sg = ZERO;
    sg = sg.next();
    i = int'(sg);
    $display("ZERO.next() = %0d (expected 10)", i);
    if (i != 10) test_passed = 0;

    // Test: prev() from POS
    sg = POS;
    sg = sg.prev();
    i = int'(sg);
    $display("POS.prev() = %0d (expected 0)", i);
    if (i != 0) test_passed = 0;

    if (test_passed) begin
      $display("PASS: Signed enum methods");
    end else begin
      $display("FAIL: Some signed enum tests failed");
    end
    $finish;
  end
endmodule
