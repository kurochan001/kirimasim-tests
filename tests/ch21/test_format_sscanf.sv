/*
:name: test_format_sscanf
:description: $sscanf system function
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_sscanf.expected
*/
// IEEE 1800-2023 §21.3.4.3: $sscanf system function
module test_format_sscanf;
    int pass_count = 0;
    int fail_count = 0;
    int a, b, n;
    string s;

    initial begin
        // Test 1: Parse single integer
        s = "42";
        n = $sscanf(s, "%d", a);
        if (n == 1 && a == 42) begin
            $display("Test 1 PASS: sscanf single");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: n=%0d a=%0d", n, a);
            fail_count++;
        end

        // Test 2: Parse two integers
        s = "10 20";
        n = $sscanf(s, "%d %d", a, b);
        if (n == 2 && a == 10 && b == 20) begin
            $display("Test 2 PASS: sscanf two");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: n=%0d a=%0d b=%0d", n, a, b);
            fail_count++;
        end

        // Test 3: Parse hex
        s = "ff";
        n = $sscanf(s, "%h", a);
        if (n == 1 && a == 255) begin
            $display("Test 3 PASS: sscanf hex");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: n=%0d a=%0d", n, a);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
