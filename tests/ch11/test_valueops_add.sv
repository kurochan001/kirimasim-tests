/*
:name: test_valueops_add
:description: Addition of int and real values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_valueops_add.expected
*/
// IEEE 1800-2023 §11.4: Arithmetic add operations
module test_valueops_add;
    int pass_count = 0;
    int fail_count = 0;
    int a, b, c;
    real r1, r2, r3;

    initial begin
        // Test 1: Integer addition
        a = 10;
        b = 20;
        c = a + b;
        if (c == 30) begin
            $display("Test 1 PASS: int add = %0d", c);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 2: Negative addition
        a = -5;
        b = 15;
        c = a + b;
        if (c == 10) begin
            $display("Test 2 PASS: neg add = %0d", c);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 3: Real addition
        r1 = 1.5;
        r2 = 2.5;
        r3 = r1 + r2;
        if (r3 == 4.0) begin
            $display("Test 3 PASS: real add = %f", r3);
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
