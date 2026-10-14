/*
:name: test_format_float
:description: Test: %f/%e/%g format specifiers
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_float.expected
*/
// Test: %f/%e/%g format specifiers

module test_format_float;
    int pass_count = 0;
    int total_tests = 0;

    // Test variables
    real r;
    shortreal sr;
    string s;

    initial begin
        // Test 1: basic %f
        total_tests++;
        r = 3.14159;
        $sformat(s, "%f", r);
        if (s == "3.141590") begin
            pass_count++;
            $display("PASS: basic %%f: %s", s);
        end else $display("FAIL: basic %%f");

        // Test 2: %f with integer value
        total_tests++;
        r = 42.0;
        $sformat(s, "%f", r);
        if (s == "42.000000") begin
            pass_count++;
            $display("PASS: %%f integer: %s", s);
        end else $display("FAIL: %%f integer");

        // Test 3: %f negative
        total_tests++;
        r = -123.456;
        $sformat(s, "%f", r);
        if (s == "-123.456000") begin
            pass_count++;
            $display("PASS: %%f negative: %s", s);
        end else $display("FAIL: %%f negative");

        // Test 4: %e scientific notation
        total_tests++;
        r = 1234567.89;
        $sformat(s, "%e", r);
        if (s == "1.234568e+06") begin
            pass_count++;
            $display("PASS: %%e scientific: %s", s);
        end else $display("FAIL: %%e");

        // Test 5: %E uppercase exponent
        total_tests++;
        r = 0.000123;
        $sformat(s, "%E", r);
        if (s == "1.230000E-04") begin
            pass_count++;
            $display("PASS: %%E uppercase: %s", s);
        end else $display("FAIL: %%E");

        // Test 6: %g general format
        total_tests++;
        r = 123.456;
        $sformat(s, "%g", r);
        if (s == "123.456") begin
            pass_count++;
            $display("PASS: %%g general: %s", s);
        end else $display("FAIL: %%g");

        // Test 7: %G uppercase general
        total_tests++;
        r = 1.0e10;
        $sformat(s, "%G", r);
        if (s == "1E+10") begin
            pass_count++;
            $display("PASS: %%G uppercase: %s", s);
        end else $display("FAIL: %%G");

        // Test 8: zero value
        total_tests++;
        r = 0.0;
        $sformat(s, "%f", r);
        if (s == "0.000000") begin
            pass_count++;
            $display("PASS: zero %%f: %s", s);
        end else $display("FAIL: zero");

        // Test 9: very small value
        total_tests++;
        r = 0.000000001;
        $sformat(s, "%e", r);
        if (s == "1.000000e-09") begin
            pass_count++;
            $display("PASS: very small %%e: %s", s);
        end else $display("FAIL: very small");

        // Test 10: very large value
        total_tests++;
        r = 1.0e100;
        $sformat(s, "%e", r);
        if (s == "1.000000e+100") begin
            pass_count++;
            $display("PASS: very large %%e: %s", s);
        end else $display("FAIL: very large");

        // Test 11: shortreal
        total_tests++;
        sr = 2.5;
        $sformat(s, "%f", sr);
        if (s == "2.500000") begin
            pass_count++;
            $display("PASS: shortreal %%f: %s", s);
        end else $display("FAIL: shortreal");

        // Test 12: %f prints six digits after the point by default
        total_tests++;
        r = 3.14159265359;
        $sformat(s, "%f", r);
        if (s == "3.141593") begin
            pass_count++;
            $display("PASS: precision %%f: %s", s);
        end else $display("FAIL: precision");

        // Test 13: negative exponent
        total_tests++;
        r = 0.0000012345;
        $sformat(s, "%e", r);
        if (s == "1.234500e-06") begin
            pass_count++;
            $display("PASS: negative exp %%e: %s", s);
        end else $display("FAIL: negative exp");

        // Test 14: multiple floats
        total_tests++;
        r = 1.5;
        sr = 2.5;
        $sformat(s, "%f + %f = %f", r, sr, r + sr);
        if (s == "1.500000 + 2.500000 = 4.000000") begin
            pass_count++;
            $display("PASS: multiple floats: %s", s);
        end else $display("FAIL: multiple");

        // Test 15: %g with small value
        total_tests++;
        r = 0.0001;
        $sformat(s, "%g", r);
        if (s == "0.0001") begin
            pass_count++;
            $display("PASS: %%g small: %s", s);
        end else $display("FAIL: %%g small");

        // Test 16: math result
        total_tests++;
        r = $sqrt(2.0);
        $sformat(s, "%f", r);
        if (s == "1.414214") begin
            pass_count++;
            $display("PASS: sqrt(2) %%f: %s", s);
        end else $display("FAIL: sqrt");

        $display("PASS: format_float (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
