/*
:name: test_valueops_multiply
:description: Multiplication of int and real values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_valueops_multiply.expected
*/
// IEEE 1800-2023 §11.4: Arithmetic multiply operations
module test_valueops_multiply;
    int pass_count = 0;
    int fail_count = 0;
    int a, b, c;
    real r1, r2, r3;

    initial begin
        // Test 1: Integer multiplication
        a = 6;
        b = 7;
        c = a * b;
        if (c == 42) begin
            $display("Test 1 PASS: int mul = %0d", c);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 2: Negative multiplication
        a = -5;
        b = 4;
        c = a * b;
        if (c == -20) begin
            $display("Test 2 PASS: neg mul = %0d", c);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 3: Real multiplication
        r1 = 2.5;
        r2 = 4.0;
        r3 = r1 * r2;
        if (r3 == 10.0) begin
            $display("Test 3 PASS: real mul = %f", r3);
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
