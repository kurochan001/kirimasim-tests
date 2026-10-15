/*
:name: test_valueops_power
:description: Power operator on int values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_valueops_power.expected
*/
// IEEE 1800-2023 §11.4: Arithmetic power operations
module test_valueops_power;
    int pass_count = 0;
    int fail_count = 0;
    int a, b, c;
    real r1, r2, r3;

    initial begin
        // Test 1: Integer power
        a = 2;
        b = 8;
        c = a ** 3;
        if (c == 8) begin
            $display("Test 1 PASS: int pow = %0d", c);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 2: Power of zero
        a = 5;
        c = a ** 0;
        if (c == 1) begin
            $display("Test 2 PASS: pow 0 = %0d", c);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", c);
            fail_count++;
        end

        // Test 3: Square
        a = 7;
        c = a ** 2;
        if (c == 49) begin
            $display("Test 3 PASS: square = %0d", c);
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
