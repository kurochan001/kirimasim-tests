/*
:name: test_semaphore_multiple
:description: Semaphore get, put and try_get with several keys at a time
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_multiple.expected
*/
// IEEE 1800-2023 §15.3 Semaphores
// Test: Semaphore with multiple keys
module test_semaphore_multiple;
    semaphore sem;
    int errors = 0;
    int acquired_count = 0;

    initial begin
        // Test 1: Create semaphore with 5 keys
        sem = new(5);

        // Test 2: Get multiple keys at once
        sem.get(3);
        acquired_count = 3;

        // Test 3: try_get remaining keys
        if (sem.try_get(2) <= 0) begin
            $display("FAIL: try_get(2) should succeed with 2 keys remaining");
            errors++;
        end else begin
            acquired_count += 2;
        end

        // Test 4: try_get when none available
        if (sem.try_get(1) != 0) begin
            $display("FAIL: try_get should fail with 0 keys");
            errors++;
        end

        // Test 5: try_get with 0 keys (edge case)
        if (sem.try_get(0) <= 0) begin
            $display("FAIL: try_get(0) should always succeed");
            errors++;
        end

        // Test 6: Put keys back incrementally
        sem.put(2);
        if (sem.try_get(2) <= 0) begin
            $display("FAIL: After put(2), try_get(2) should succeed");
            errors++;
        end
        sem.put(2);  // Return them

        // Test 7: Put more keys than initial (allowed)
        sem.put(3);  // Now have 5 keys
        if (sem.try_get(5) <= 0) begin
            $display("FAIL: Should have 5 keys available");
            errors++;
        end

        // Test 8: Bulk operations
        sem.put(10);  // Put 10 keys
        sem.get(7);   // Get 7
        if (sem.try_get(3) <= 0) begin
            $display("FAIL: Should have 3 keys remaining");
            errors++;
        end
        if (sem.try_get(1) != 0) begin
            $display("FAIL: Should have 0 keys now");
            errors++;
        end

        // Return all keys for cleanup
        sem.put(10);

        if (errors == 0) begin
            $display("TEST PASSED: Multiple key semaphore tests passed");
        end else begin
            $display("TEST FAILED: %0d errors", errors);
        end
        $finish;
    end
endmodule
