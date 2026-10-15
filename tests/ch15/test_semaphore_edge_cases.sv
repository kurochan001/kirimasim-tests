/*
:name: test_semaphore_edge_cases
:description: Semaphore edge cases
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_edge_cases.expected
*/
// IEEE 1800-2023 Section 15.3 - Semaphore edge cases
// Tests corner cases for semaphore operations

module test_semaphore_edge_cases;
    semaphore sem;
    int pass_count = 0;
    int fail_count = 0;
    int key_count;

    initial begin
        $display("IEEE 1800-2023 Section 15.3 - Semaphore Edge Cases Test");
        $display("============================================================");

        // Test 1: Create semaphore with initial key count
        sem = new(3);
        if (sem != null) begin
            $display("PASS: Test 1 - Semaphore created with 3 keys");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Semaphore creation failed");
            fail_count++;
        end

        // Test 2: get() single key
        sem = new(3);
        sem.get(1);
        // After getting 1, 2 keys remain: 2 can be taken, a third cannot
        if (sem.try_get(2) > 0 && sem.try_get(1) == 0) begin
            $display("PASS: Test 2 - get(1) succeeded");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - wrong key count after get(1)");
            fail_count++;
        end

        // Test 3: get() multiple keys
        sem = new(5);
        sem.get(3);
        if (sem.try_get(2) > 0 && sem.try_get(1) == 0) begin
            $display("PASS: Test 3 - get(3) succeeded");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - wrong key count after get(3)");
            fail_count++;
        end

        // Test 4: put() keys back
        sem = new(0);
        sem.put(2);
        sem.put(3);
        // Should now have 5 keys
        if (sem.try_get(5) > 0 && sem.try_get(1) == 0) begin
            $display("PASS: Test 4 - put() keys back succeeded");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - wrong key count after put()");
            fail_count++;
        end

        // Test 5: try_get() with available keys
        sem = new(3);
        if (sem.try_get(2)) begin
            $display("PASS: Test 5 - try_get(2) succeeded when keys available");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - try_get(2) should have succeeded");
            fail_count++;
        end

        // Test 6: try_get() with insufficient keys
        sem = new(1);
        if (!sem.try_get(5)) begin
            $display("PASS: Test 6 - try_get(5) returned 0 when only 1 key available");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - try_get(5) should have failed");
            fail_count++;
        end

        // Test 7: Semaphore with zero initial keys
        sem = new(0);
        if (!sem.try_get(1)) begin
            $display("PASS: Test 7 - try_get on empty semaphore returns 0");
            pass_count++;
        end else begin
            $display("FAIL: Test 7 - try_get should fail on empty semaphore");
            fail_count++;
        end

        // Test 8: put() then get() sequence
        sem = new(0);
        sem.put(1);
        sem.get(1);
        if (sem.try_get(1) == 0) begin
            $display("PASS: Test 8 - put() then get() sequence works");
            pass_count++;
        end else begin
            $display("FAIL: Test 8 - a key was left after put(1) and get(1)");
            fail_count++;
        end

        // Test 9: Multiple put() operations
        sem = new(0);
        sem.put(1);
        sem.put(1);
        sem.put(1);
        if (sem.try_get(3)) begin
            $display("PASS: Test 9 - Multiple put() accumulates keys");
            pass_count++;
        end else begin
            $display("FAIL: Test 9 - Multiple put() should have 3 keys");
            fail_count++;
        end

        // Test 10: Default argument for get()
        sem = new(5);
        sem.get();  // Default is 1
        if (sem.try_get(4)) begin
            $display("PASS: Test 10 - get() default argument is 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 10 - get() default argument issue");
            fail_count++;
        end

        // Summary
        $display("============================================================");
        $display("Test Summary: %0d passed, %0d failed", pass_count, fail_count);

        if (fail_count == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end

        $finish;
    end
endmodule
