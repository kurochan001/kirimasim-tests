/*
:name: test_semaphore_try_get
:description: Test: Semaphore try_get operation
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3 15.3.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_try_get.expected
*/
// Test: Semaphore try_get operation
// IEEE 1800-2023 Section 15.3

module test_semaphore_try_get;

    // Test 1: try_get with available keys
    task test_try_get_available;
        static semaphore sem1 = new(5);
        int result;
        result = sem1.try_get(3);
        if (result > 0) begin  // success returns a positive integer (15.3)
            $display("PASS: test_try_get_available - try_get succeeded");
        end else begin
            $display("FAIL: test_try_get_available - try_get failed unexpectedly");
        end
    endtask

    // Test 2: try_get with insufficient keys
    task test_try_get_insufficient;
        static semaphore sem2 = new(2);
        int result;
        result = sem2.try_get(5);
        if (result == 0) begin
            $display("PASS: test_try_get_insufficient - try_get returns 0");
        end else begin
            $display("FAIL: test_try_get_insufficient - Should have failed");
        end
    endtask

    // Test 3: try_get on empty semaphore
    task test_try_get_empty;
        static semaphore sem3 = new(0);
        int result;
        result = sem3.try_get(1);
        if (result == 0) begin
            $display("PASS: test_try_get_empty - try_get on empty returns 0");
        end else begin
            $display("FAIL: test_try_get_empty - Should have failed");
        end
    endtask

    // Test 4: try_get with default argument
    task test_try_get_default;
        static semaphore sem4 = new(1);
        int result;
        result = sem4.try_get();
        if (result > 0) begin  // success returns a positive integer (15.3)
            $display("PASS: test_try_get_default - Default argument works");
        end else begin
            $display("FAIL: test_try_get_default - Default argument failed");
        end
    endtask

    // Test 5: try_get does not block
    task test_try_get_nonblocking;
        static semaphore sem5 = new(0);
        int result;
        // This should return immediately, not block
        result = sem5.try_get(10);
        if (result == 0) begin
            $display("PASS: test_try_get_nonblocking - Non-blocking behavior confirmed");
        end else begin
            $display("FAIL: test_try_get_nonblocking - Unexpected success");
        end
    endtask

    initial begin
        test_try_get_available();
        test_try_get_insufficient();
        test_try_get_empty();
        test_try_get_default();
        test_try_get_nonblocking();
        $finish;
    end
endmodule
