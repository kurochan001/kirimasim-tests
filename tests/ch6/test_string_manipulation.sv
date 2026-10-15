/*
:name: test_string_manipulation
:description: String data type
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.4 6.16.5 6.16.6 6.16.7 6.16.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_manipulation.expected
*/
// IEEE 1800-2023 Section 6.16 - String data type
// Test: String manipulation methods (substr, toupper, tolower, etc.)

module test_string_manipulation;
  string s, result;
  int pos;

  initial begin
    // Test len() - string length
    s = "Hello";
    if (s.len() != 5) $fatal(1, "FAIL: len()");

    // Test substr() - substring extraction
    s = "Hello World";
    result = s.substr(0, 4);
    if (result != "Hello") $fatal(1, "FAIL: substr(0,4) = '%s'", result);

    result = s.substr(6, 10);
    if (result != "World") $fatal(1, "FAIL: substr(6,10) = '%s'", result);

    // Test toupper() - convert to uppercase
    s = "hello";
    result = s.toupper();
    if (result != "HELLO") $fatal(1, "FAIL: toupper() = '%s'", result);

    s = "Hello World";
    result = s.toupper();
    if (result != "HELLO WORLD") $fatal(1, "FAIL: toupper(mixed) = '%s'", result);

    // Test tolower() - convert to lowercase
    s = "HELLO";
    result = s.tolower();
    if (result != "hello") $fatal(1, "FAIL: tolower() = '%s'", result);

    s = "Hello World";
    result = s.tolower();
    if (result != "hello world") $fatal(1, "FAIL: tolower(mixed) = '%s'", result);

    // Test compare() - case-sensitive comparison
    s = "hello";
    pos = s.compare("hello");
    if (pos != 0) $fatal(1, "FAIL: compare(equal) = %0d", pos);

    pos = s.compare("Hello");
    if (pos == 0) $fatal(1, "FAIL: compare(case different) should be non-zero");

    pos = s.compare("abc");
    if (pos <= 0) $fatal(1, "FAIL: compare('hello' vs 'abc') should be positive");

    // Test icompare() - case-insensitive comparison
    s = "hello";
    pos = s.icompare("HELLO");
    if (pos != 0) $fatal(1, "FAIL: icompare(case ignore) = %0d", pos);

    pos = s.icompare("Hello");
    if (pos != 0) $fatal(1, "FAIL: icompare(mixed case) = %0d", pos);

    $display("PASS: String manipulation methods");
    $finish(0);
  end
endmodule
