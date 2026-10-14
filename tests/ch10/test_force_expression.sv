/*
:name: test_force_expression
:description: force with expressions
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_expression.expected
*/
// IEEE 1800-2023 §10.6.2: force with expressions
module test_force_expression;
    logic [7:0] a, b, result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        a = 8'h10;
        b = 8'h20;

        // Test 1: Force with constant expression
        force result = 8'h30 + 8'h05;
        #1;
        if (result == 8'h35) begin
            $display("Test 1 PASS: force expr=%02h", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: expected 35, got %02h", result);
            fail_count++;
        end
        release result;

        // Test 2: Force with variable expression
        force result = a + b;
        #1;
        if (result == 8'h30) begin
            $display("Test 2 PASS: force a+b=%02h", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: expected 30, got %02h", result);
            fail_count++;
        end
        release result;

        // Test 3: Force with bitwise operation
        force result = a | b;
        #1;
        if (result == 8'h30) begin
            $display("Test 3 PASS: force a|b=%02h", result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: expected 30, got %02h", result);
            fail_count++;
        end
        release result;

        // Test 4: Force with shift
        force result = a << 2;
        #1;
        if (result == 8'h40) begin
            $display("Test 4 PASS: force a<<2=%02h", result);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: expected 40, got %02h", result);
            fail_count++;
        end
        release result;

        $display("Passed: %0d/4", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
