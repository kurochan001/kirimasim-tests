/*
:name: test_operator_inc_dec
:description: Increment/decrement operators test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_inc_dec.expected
*/
// Increment/decrement operators test
module test_operator_inc_dec;
    int a, b, result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Pre-increment
        a = 5;
        result = ++a;
        if (result == 6 && a == 6) begin
            $display("PASS: Pre-increment ++a: result=6, a=6");
            pass_count++;
        end else begin
            $display("FAIL: Pre-increment, expected result=6 a=6, got result=%0d a=%0d", result, a);
            fail_count++;
        end

        // Test 2: Post-increment
        a = 5;
        result = a++;
        if (result == 5 && a == 6) begin
            $display("PASS: Post-increment a++: result=5, a=6");
            pass_count++;
        end else begin
            $display("FAIL: Post-increment, expected result=5 a=6, got result=%0d a=%0d", result, a);
            fail_count++;
        end

        // Test 3: Pre-decrement
        a = 10;
        result = --a;
        if (result == 9 && a == 9) begin
            $display("PASS: Pre-decrement --a: result=9, a=9");
            pass_count++;
        end else begin
            $display("FAIL: Pre-decrement, expected result=9 a=9, got result=%0d a=%0d", result, a);
            fail_count++;
        end

        // Test 4: Post-decrement
        a = 10;
        result = a--;
        if (result == 10 && a == 9) begin
            $display("PASS: Post-decrement a--: result=10, a=9");
            pass_count++;
        end else begin
            $display("FAIL: Post-decrement, expected result=10 a=9, got result=%0d a=%0d", result, a);
            fail_count++;
        end

        // Test 5: Increment in expression
        a = 3;
        b = 2;
        result = (++a) + (b++);
        if (result == 6 && a == 4 && b == 3) begin
            $display("PASS: Mixed inc: (++3) + (2++) = 6, a=4, b=3");
            pass_count++;
        end else begin
            $display("FAIL: Mixed inc, expected 6 a=4 b=3, got %0d a=%0d b=%0d", result, a, b);
            fail_count++;
        end

        // Summary
        $display("Increment/decrement operators: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All increment/decrement operator tests passed");
        else $display("FAIL: Some increment/decrement operator tests failed");
        $finish;
    end
endmodule
