/*
:name: test_sv_string
:description: Test: String: len(), substr(), {concat}, toupper/tolower, atoi, comparisons
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sv_string.expected
*/
// Test: String: len(), substr(), {concat}, toupper/tolower, atoi, comparisons
module test_sv_string;

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    string s1, s2, s3;

    s1 = "Hello";

    // Check 1: len()
    if (s1.len() == 5) begin pass_cnt++; $display("PASS: len == 5"); end
    else begin fail_cnt++; $display("FAIL: len = %0d", s1.len()); end

    // Check 2: substr()
    s2 = s1.substr(1, 3);
    if (s2 == "ell") begin pass_cnt++; $display("PASS: substr(1,3) == ell"); end
    else begin fail_cnt++; $display("FAIL: substr = %s", s2); end

    // Check 3: concatenation
    s3 = {s1, " World"};
    if (s3 == "Hello World") begin pass_cnt++; $display("PASS: concat == Hello World"); end
    else begin fail_cnt++; $display("FAIL: concat = %s", s3); end

    // Check 4: toupper
    s2 = s1.toupper();
    if (s2 == "HELLO") begin pass_cnt++; $display("PASS: toupper == HELLO"); end
    else begin fail_cnt++; $display("FAIL: toupper = %s", s2); end

    // Check 5: tolower
    s2 = s1.tolower();
    if (s2 == "hello") begin pass_cnt++; $display("PASS: tolower == hello"); end
    else begin fail_cnt++; $display("FAIL: tolower = %s", s2); end

    // Check 6: atoi
    s2 = "12345";
    if (s2.atoi() == 12345) begin pass_cnt++; $display("PASS: atoi == 12345"); end
    else begin fail_cnt++; $display("FAIL: atoi = %0d", s2.atoi()); end

    // Check 7: comparison (equal)
    s2 = "Hello";
    if (s1 == s2) begin pass_cnt++; $display("PASS: Hello == Hello"); end
    else begin fail_cnt++; $display("FAIL: Hello != Hello"); end

    // Check 8: comparison (not equal)
    s2 = "World";
    if (s1 != s2) begin pass_cnt++; $display("PASS: Hello != World"); end
    else begin fail_cnt++; $display("FAIL: Hello == World"); end

    // Check 9: getc (character access)
    if (s1.getc(0) == "H") begin pass_cnt++; $display("PASS: getc(0) == H"); end
    else begin fail_cnt++; $display("FAIL: getc(0) = %0d", s1.getc(0)); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
