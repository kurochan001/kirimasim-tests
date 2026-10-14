/*
:name: test_assign_expr
:description: Assignment expressions
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 11.4.3 11.4.8 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_expr.expected
*/
// IEEE 1800-2023 §10.4: Assignment expressions
module test_assign_expr;
    int pass_count = 0;
    int fail_count = 0;
    logic [7:0] a, b, c;

    initial begin
        // Test 1: Arithmetic in assignment
        a = 8'd10 + 8'd20;
        if (a == 8'd30) begin
            $display("Test 1 PASS: add = %0d", a);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", a);
            fail_count++;
        end

        // Test 2: Bitwise in assignment
        a = 8'hF0 & 8'h0F;
        if (a == 8'h00) begin
            $display("Test 2 PASS: and = %02h", a);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %02h", a);
            fail_count++;
        end

        // Test 3: Ternary in assignment
        b = 8'd100;
        a = (b > 50) ? 8'hAA : 8'hBB;
        if (a == 8'hAA) begin
            $display("Test 3 PASS: ternary = %02h", a);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %02h", a);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
