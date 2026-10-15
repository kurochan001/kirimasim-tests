/*
:name: test_valueops_subtract
:description: Subtraction of int and real values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_valueops_subtract.expected
*/
// IEEE 1800-2023 §11.4: Arithmetic subtract operations
module test_valueops_subtract;
    int pass_count = 0;
    int fail_count = 0;
    int a, b, c;
    real r1, r2, r3;

    initial begin
        // Test 1: Integer subtraction
        a = 30;
        b = 10;
        c = a - b;
        if (c == 20) begin
            $display("Test 1 PASS: int sub = %0d", c);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 2: Negative result
        a = 5;
        b = 15;
        c = a - b;
        if (c == -10) begin
            $display("Test 2 PASS: neg sub = %0d", c);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 3: Real subtraction
        r1 = 5.5;
        r2 = 2.0;
        r3 = r1 - r2;
        if (r3 == 3.5) begin
            $display("Test 3 PASS: real sub = %f", r3);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %f", r3);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
