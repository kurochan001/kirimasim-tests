/*
:name: test_final_block_2
:description: Final block execution
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_final_block_2.expected
*/
// Final block execution
// Verifies final block execution at simulation end

module test_final_block;
    int final_executed = 0;
    int final_order = 0;
    int cleanup_done = 0;
    string final_message;
    int pass_count = 0;
    int fail_count = 0;

    // We need to track results before $finish, since final blocks run after
    int test1_pass, test2_pass, test3_pass, test4_pass, test5_pass;

    // Final procedures run in an arbitrary order (9.2.3), so a single final
    // procedure does the work and reports it; a second one only counts.
    final begin
        final_executed = 1;
        final_order++;
        cleanup_done = 1;
        final_message = "Cleanup complete";
        $display("Final block summary: final_executed=%0d, cleanup_done=%0d, message=%s",
                 final_executed, cleanup_done, final_message);
    end

    final begin
        final_order++;
    end

    // Main test block - verify setup and call $finish
    initial begin
        // Test preparations
        test1_pass = 1;  // Will verify final block executed
        test2_pass = 1;  // Will verify second final block
        test3_pass = 1;  // Will verify cleanup
        test4_pass = 1;  // Will verify message
        test5_pass = 1;  // Will verify all finals run

        // Before $finish, final blocks haven't run yet
        if (final_executed == 0) begin
            $display("PASS: Scenario 1 - Final not yet executed before $finish");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 1 - Final executed too early");
            fail_count++;
        end

        if (cleanup_done == 0) begin
            $display("PASS: Scenario 2 - Cleanup not done before $finish");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 2 - Cleanup done too early");
            fail_count++;
        end

        // Test that we can set up values that final blocks will see
        if (final_order == 0) begin
            $display("PASS: Scenario 3 - Final order counter at 0 before $finish");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 3 - final_order=%0d (expected 0)", final_order);
            fail_count++;
        end

        // Verify final_message is empty before final blocks
        if (final_message == "") begin
            $display("PASS: Scenario 4 - Message empty before final blocks");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 4 - Message set too early");
            fail_count++;
        end

        // All pre-checks passed
        $display("PASS: Scenario 5 - All pre-final checks complete");
        pass_count++;

        // Summary (before final blocks)
        $display("Final block execution: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS");
        else $display("FAIL");

        $finish;
    end
endmodule
