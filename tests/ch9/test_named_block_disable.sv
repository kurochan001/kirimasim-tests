/*
:name: test_named_block_disable
:description: Test for named block disable (IEEE 1800-2023 Section 9.6.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_named_block_disable.expected
*/
// Test for named block disable (IEEE 1800-2023 Section 9.6.2)
// This test verifies that disable statement can target named blocks

module test_named_block_disable;
    int result;

    initial begin
        // Test 1: Basic named block disable
        result = 0;
        begin : outer_block
            result = 1;
            begin : inner_block
                result = 2;
                disable inner_block;
                result = 99;  // Should not execute
            end
            result = result + 10;  // Should execute after inner_block disabled
        end

        if (result == 12)
            $display("PASS: Basic named block disable");
        else
            $display("FAIL: Basic named block expected 12, got %0d", result);

        // Test 2: Disable outer block from inner
        result = 0;
        begin : outer2
            result = 1;
            begin : inner2
                result = 2;
                disable outer2;
                result = 99;  // Should not execute
            end
            result = 99;  // Should not execute
        end

        if (result == 2)
            $display("PASS: Disable outer block from inner");
        else
            $display("FAIL: Disable outer from inner expected 2, got %0d", result);

        // Test 3: Named block in loop
        result = 0;
        for (int i = 0; i < 5; i++) begin : loop_block
            result = result + 1;
            if (i == 2) begin
                disable loop_block;  // Exit current iteration only
            end
            result = result + 10;
        end

        // Expected: 0->1->11, 1->12->22, 2->23 (disabled), 3->24->34, 4->35->45
        if (result == 45)
            $display("PASS: Named block in loop");
        else
            $display("FAIL: Named block in loop expected 45, got %0d", result);

        $display("TEST PASSED: named block disable tests completed");
        $finish;
    end
endmodule
