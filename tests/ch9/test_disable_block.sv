/*
:name: test_disable_block
:description: Test for disable statement
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_block.expected
*/
// Test for disable statement
// IEEE 1800-2023 Section 9.6

module test_disable_block;
    int result = 0;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Disable named block
        test_count++;
        result = 0;
        begin : block1
            result = 1;
            if (result == 1) disable block1;
            result = 2;  // Should not execute
        end
        if (result == 1) begin
            $display("Test 1: Disable named block PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL result=%0d", result);
        end

        // Test 2: Disable in nested block
        test_count++;
        result = 0;
        begin : outer
            result = 1;
            begin : inner
                result = 2;
                disable outer;
                result = 3;
            end
            result = 4;
        end
        if (result == 2) begin
            $display("Test 2: Disable nested block PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL result=%0d", result);
        end

        // Test 3: Disable loop
        test_count++;
        result = 0;
        begin : loop_block
            for (int i = 0; i < 10; i++) begin
                result = i;
                if (i == 5) disable loop_block;
            end
        end
        if (result == 5) begin
            $display("Test 3: Disable loop PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL result=%0d", result);
        end

        // Test 4: Conditional disable
        test_count++;
        result = 0;
        begin : cond_block
            result = 1;
            if (result > 0)
                disable cond_block;
            result = 2;
        end
        if (result == 1) begin
            $display("Test 4: Conditional disable PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL result=%0d", result);
        end

        // Test 5: No disable (control case)
        test_count++;
        result = 0;
        begin : no_disable
            result = 1;
            result = 2;
        end
        if (result == 2) begin
            $display("Test 5: No disable control PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL result=%0d", result);
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
