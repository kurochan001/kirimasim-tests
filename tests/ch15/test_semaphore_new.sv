/*
:name: test_semaphore_new
:description: Test: Semaphore constructor
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3 15.3.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_new.expected
*/
// Test: Semaphore constructor
// IEEE 1800-2023 Section 15.3

module test_semaphore_new;

    // Test 1: Create semaphore with default keys
    task test_default_semaphore;
        semaphore sem1;
        sem1 = new();
        if (sem1 != null) begin
            $display("PASS: test_default_semaphore - Semaphore created");
        end else begin
            $display("FAIL: test_default_semaphore - Semaphore is null");
        end
    endtask

    // Test 2: Create semaphore with initial keys
    task test_semaphore_with_keys;
        semaphore sem2;
        sem2 = new(5);
        if (sem2 != null) begin
            // Verify keys by trying to get them
            sem2.get(5);
            $display("PASS: test_semaphore_with_keys - Semaphore with 5 keys created");
        end else begin
            $display("FAIL: test_semaphore_with_keys - Semaphore is null");
        end
    endtask

    // Test 3: Create semaphore with 1 key
    task test_semaphore_one_key;
        semaphore sem3;
        sem3 = new(1);
        if (sem3 != null) begin
            sem3.get(1);
            $display("PASS: test_semaphore_one_key - Single-key semaphore works");
        end else begin
            $display("FAIL: test_semaphore_one_key - Creation failed");
        end
    endtask

    // Test 4: Create multiple semaphores
    task test_multiple_semaphores;
        semaphore sa, sb, sc;
        sa = new(1);
        sb = new(10);
        sc = new(100);
        if (sa != null && sb != null && sc != null) begin
            $display("PASS: test_multiple_semaphores - Multiple semaphores created");
        end else begin
            $display("FAIL: test_multiple_semaphores - Some semaphores are null");
        end
    endtask

    // Test 5: Semaphore with zero initial keys
    task test_semaphore_zero_keys;
        semaphore sem0;
        int result;
        sem0 = new(0);
        if (sem0 != null) begin
            result = sem0.try_get(1); // Should fail immediately
            if (result == 0) begin
                $display("PASS: test_semaphore_zero_keys - Zero-key semaphore works");
            end else begin
                $display("FAIL: test_semaphore_zero_keys - try_get should fail");
            end
        end else begin
            $display("FAIL: test_semaphore_zero_keys - Creation failed");
        end
    endtask

    initial begin
        test_default_semaphore();
        test_semaphore_with_keys();
        test_semaphore_one_key();
        test_multiple_semaphores();
        test_semaphore_zero_keys();
        $finish;
    end
endmodule
