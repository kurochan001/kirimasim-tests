/*
:name: test_string_putc_getc
:description: String data type
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.2 6.16.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_putc_getc.expected
*/
// IEEE 1800-2023 Section 6.16 - String data type
// Test: String character access (putc, getc)

module test_string_putc_getc;
  string s;
  byte c;

  initial begin
    // Test getc() - get character at index
    s = "Hello";
    c = s.getc(0);
    if (c != 8'h48) $fatal(1, "FAIL: getc(0) = '%c'", c);  // 'H' = 0x48

    c = s.getc(4);
    if (c != 8'h6F) $fatal(1, "FAIL: getc(4) = '%c'", c);  // 'o' = 0x6F

    c = s.getc(2);
    if (c != 8'h6C) $fatal(1, "FAIL: getc(2) = '%c'", c);  // 'l' = 0x6C

    // Test putc() - set character at index
    s = "Hello";
    s.putc(0, 8'h68);  // Change 'H' to 'h' (0x68)
    if (s != "hello") $fatal(1, "FAIL: putc(0,'h') = '%s'", s);

    s.putc(4, 8'h21);  // Change 'o' to '!' (0x21)
    if (s != "hell!") $fatal(1, "FAIL: putc(4,'!') = '%s'", s);

    s.putc(2, 8'h4C);  // Change first 'l' to 'L' (0x4C)
    if (s != "heLl!") $fatal(1, "FAIL: putc(2,'L') = '%s'", s);

    // Test character iteration
    s = "ABC";
    for (int i = 0; i < s.len(); i++) begin
      c = s.getc(i);
      $display("  s[%0d] = '%c' (0x%02h)", i, c, c);
    end

    // Test modifying string character by character
    s = "test";
    for (int i = 0; i < s.len(); i++) begin
      c = s.getc(i);
      if (c >= 8'h61 && c <= 8'h7A) begin  // 'a' = 0x61, 'z' = 0x7A
        s.putc(i, c - 32);  // Convert to uppercase
      end
    end
    if (s != "TEST") $fatal(1, "FAIL: uppercase conversion = '%s'", s);

    $display("PASS: String putc/getc methods");
    $finish(0);
  end
endmodule
