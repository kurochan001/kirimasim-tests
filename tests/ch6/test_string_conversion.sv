/*
:name: test_string_conversion
:description: String data type
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9 6.16.10 6.16.11 6.16.12 6.16.13 6.16.14 6.16.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_conversion.expected
*/
// IEEE 1800-2023 Section 6.16 - String data type
// Test: String conversion methods (atoi, atohex, itoa, etc.)

module test_string_conversion;
  string s;
  int value;
  real rval;

  initial begin
    // Test atoi() - ASCII to integer
    s = "123";
    value = s.atoi();
    if (value != 123) $fatal(1, "FAIL: atoi('123') = %0d", value);

    s = "-456";
    value = s.atoi();
    // Whether atoi reads a leading minus is not settled: 6.16.9 names the sign
    // among the parts of the literal syntax it does not parse, and tools
    // differ. So 0 and -456 both pass.
    if (value != 0 && value != -456)
      $fatal(1, "FAIL: atoi('-456') = %0d (should be 0 or -456)", value);

    // Test atohex() - ASCII hex to integer
    s = "FF";
    value = s.atohex();
    if (value != 255) $fatal(1, "FAIL: atohex('FF') = %0d", value);

    s = "1A2B";
    value = s.atohex();
    if (value != 6699) $fatal(1, "FAIL: atohex('1A2B') = %0d", value);

    // Test atooct() - ASCII octal to integer
    s = "77";
    value = s.atooct();
    if (value != 63) $fatal(1, "FAIL: atooct('77') = %0d (should be 63)", value);

    s = "123";
    value = s.atooct();
    if (value != 83) $fatal(1, "FAIL: atooct('123') = %0d (should be 83)", value);

    // Test atobin() - ASCII binary to integer
    s = "1010";
    value = s.atobin();
    if (value != 10) $fatal(1, "FAIL: atobin('1010') = %0d", value);

    s = "11111111";
    value = s.atobin();
    if (value != 255) $fatal(1, "FAIL: atobin('11111111') = %0d", value);

    // Test atoreal() - ASCII to real
    s = "3.14";
    rval = s.atoreal();
    if (rval < 3.13 || rval > 3.15) $fatal(1, "FAIL: atoreal('3.14') = %f", rval);

    s = "-2.5";
    rval = s.atoreal();
    if (rval < -2.6 || rval > -2.4) $fatal(1, "FAIL: atoreal('-2.5') = %f", rval);

    // Test itoa() - integer to ASCII
    s = "";
    value = 789;
    s.itoa(value);
    if (s != "789") $fatal(1, "FAIL: itoa(789) = '%s'", s);

    s = "";
    value = -321;
    s.itoa(value);
    if (s != "-321") $fatal(1, "FAIL: itoa(-321) = '%s'", s);

    // Test hextoa() - hex to ASCII
    s = "";
    value = 255;
    s.hextoa(value);
    // the case of the letters is not specified (6.16.12)
    if (s.tolower() != "ff") $fatal(1, "FAIL: hextoa(255) = '%s'", s);

    // Test octtoa() - octal to ASCII
    s = "";
    value = 63;
    s.octtoa(value);
    if (s != "77") $fatal(1, "FAIL: octtoa(63) = '%s'", s);

    // Test bintoa() - binary to ASCII
    s = "";
    value = 10;
    s.bintoa(value);
    if (s != "1010") $fatal(1, "FAIL: bintoa(10) = '%s'", s);

    // Test realtoa() - real to ASCII
    s = "";
    rval = 3.14;
    s.realtoa(rval);
    // The text form is not specified; realtoa is the inverse of atoreal (6.16.15)
    if (s.atoreal() != rval) $fatal(1, "FAIL: realtoa(3.14) = '%s'", s);

    $display("PASS: String conversion methods");
    $finish(0);
  end
endmodule
