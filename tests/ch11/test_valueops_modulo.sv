/*
:name: test_valueops_modulo
:description: Modulus of int values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_valueops_modulo.expected
*/
// IEEE 1800-2023 §11.4: Arithmetic modulo operations
module test_valueops_modulo;
    int pass_count = 0;
    int fail_count = 0;
    int a, b, c;

    initial begin
        // Test 1: Basic modulo
        a = 17;
        b = 5;
        c = a % b;
        if (c == 2) begin
            $display("Test 1 PASS: mod = %0d", c);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 2: Even division
        a = 20;
        b = 4;
        c = a % b;
        if (c == 0) begin
            $display("Test 2 PASS: even mod = %0d", c);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 3: Large modulo
        a = 100;
        b = 7;
        c = a % b;
        if (c == 2) begin
            $display("Test 3 PASS: large mod = %0d", c);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", c);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
