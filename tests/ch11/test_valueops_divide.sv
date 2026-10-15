/*
:name: test_valueops_divide
:description: Division of int and real values, with truncation of int division
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_valueops_divide.expected
*/
// IEEE 1800-2023 §11.4: Arithmetic divide operations
module test_valueops_divide;
    int pass_count = 0;
    int fail_count = 0;
    int a, b, c;
    real r1, r2, r3;

    initial begin
        // Test 1: Integer division
        a = 20;
        b = 4;
        c = a / b;
        if (c == 5) begin
            $display("Test 1 PASS: int div = %0d", c);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 2: Integer division truncation
        a = 17;
        b = 5;
        c = a / b;
        if (c == 3) begin
            $display("Test 2 PASS: trunc div = %0d", c);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 3: Real division
        r1 = 7.5;
        r2 = 2.5;
        r3 = r1 / r2;
        if (r3 == 3.0) begin
            $display("Test 3 PASS: real div = %f", r3);
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
