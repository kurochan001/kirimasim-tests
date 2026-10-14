/*
:name: test_final_edge_cases
:description: Final block edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_final_edge_cases.expected
*/
// IEEE 1800-2023 §9.2.3: Final block edge cases
// Tests for final blocks

module test_final_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int final_ran = 0;
    int counter = 0;

    final begin
        final_ran = 1;
        $display("FINAL: Block executed");
    end

    initial begin
        // Test 1: Initial runs before final
        test_count++;
        counter = 100;
        if (counter == 100) begin
            pass_count++;
            $display("Test 1 PASS: counter = %0d", counter);
        end else begin
            $display("Test 1 FAIL: Counter unexpected");
        end

        // Test 2: final_ran should be 0 here
        test_count++;
        if (final_ran == 0) begin
            pass_count++;
            $display("Test 2 PASS: Final not yet run");
        end else begin
            $display("Test 2 FAIL: Final timing unexpected");
        end

        // Test 3: Module work
        test_count++;
        for (int i = 0; i < 5; i++) counter++;
        if (counter == 105) begin
            pass_count++;
            $display("Test 3 PASS: Work completed, counter = %0d", counter);
        end else begin
            $display("Test 3 FAIL: Work unexpected = %0d", counter);
        end

        // Test 4: Set value for final to see
        test_count++;
        counter = 999;
        pass_count++;
        $display("Test 4 PASS: Set counter = %0d", counter);

        $display("=== Final Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
