/*
:name: test_expr_binary
:description: Binary expressions test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.4 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_binary.expected
*/
// Binary expressions test
module test_expr_binary;
    int a, b, result;
    logic cmp_result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Arithmetic binary (add, sub, mul)
        a = 15; b = 4;
        result = a + b;
        if (result == 19) begin
            $display("PASS: 15 + 4 = 19");
            pass_count++;
        end else begin
            $display("FAIL: 15 + 4, expected 19, got %0d", result);
            fail_count++;
        end

        // Test 2: Division and modulo
        a = 17; b = 5;
        result = a / b;
        if (result == 3) begin
            result = a % b;
            if (result == 2) begin
                $display("PASS: 17/5=3, 17%%5=2");
                pass_count++;
            end else begin
                $display("FAIL: 17%%5, expected 2, got %0d", result);
                fail_count++;
            end
        end else begin
            $display("FAIL: 17/5, expected 3, got %0d", result);
            fail_count++;
        end

        // Test 3: Comparison operators
        a = 10; b = 20;
        cmp_result = (a < b) && (a <= 10) && (b > a) && (b >= 20);
        if (cmp_result == 1'b1) begin
            $display("PASS: Comparison operators all correct");
            pass_count++;
        end else begin
            $display("FAIL: Comparison operators failed");
            fail_count++;
        end

        // Test 4: Shift operators
        a = 8;
        result = a << 2;
        if (result == 32) begin
            result = a >> 1;
            if (result == 4) begin
                $display("PASS: 8<<2=32, 8>>1=4");
                pass_count++;
            end else begin
                $display("FAIL: 8>>1, expected 4, got %0d", result);
                fail_count++;
            end
        end else begin
            $display("FAIL: 8<<2, expected 32, got %0d", result);
            fail_count++;
        end

        // Test 5: Power operator
        a = 2; b = 10;
        result = a ** b;
        if (result == 1024) begin
            $display("PASS: 2 ** 10 = 1024");
            pass_count++;
        end else begin
            $display("FAIL: 2**10, expected 1024, got %0d", result);
            fail_count++;
        end

        // Summary
        $display("Binary expressions: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All binary expression tests passed");
        else $display("FAIL: Some binary expression tests failed");
        $finish;
    end
endmodule
