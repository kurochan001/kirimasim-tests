/*
:name: test_compare_ops
:description: Test for comparison operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_compare_ops.expected
*/
// Test for comparison operations
// IEEE 1800-2023 §11.4

module test_compare_ops;
    int a, b;
    logic result;
    logic [3:0] x, y;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Equal
        test_count++;
        a = 10;
        b = 10;
        result = (a == b);
        if (result) begin
            $display("Test 1: Equal PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Not equal
        test_count++;
        b = 20;
        result = (a != b);
        if (result) begin
            $display("Test 2: Not equal PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Greater than
        test_count++;
        result = (b > a);
        if (result) begin
            $display("Test 3: Greater than PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Less than
        test_count++;
        result = (a < b);
        if (result) begin
            $display("Test 4: Less than PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Greater or equal
        test_count++;
        a = 20;
        result = (a >= b);
        if (result) begin
            $display("Test 5: Greater or equal PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Test 6: Less or equal
        test_count++;
        result = (a <= b);
        if (result) begin
            $display("Test 6: Less or equal PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL");
        end

        // Test 7: Case equality
        test_count++;
        x = 4'b1010;
        y = 4'b1010;
        result = (x === y);
        if (result) begin
            $display("Test 7: Case equality PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
