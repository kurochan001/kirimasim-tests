/*
:name: test_queue_delete_2
:description: Queue delete at index method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_delete_2.expected
*/
// Queue delete at index method
module test_queue_delete;
    int q[$];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Delete at beginning
        q = '{10, 20, 30};
        q.delete(0);
        if (q.size() == 2 && q[0] == 20 && q[1] == 30) begin
            $display("Test 1 PASS: delete at beginning");
            passed++;
        end else begin
            $display("Test 1 FAIL: delete at beginning");
            failed++;
        end

        // Test 2: Delete in middle
        q = '{10, 20, 30};
        q.delete(1);
        if (q.size() == 2 && q[0] == 10 && q[1] == 30) begin
            $display("Test 2 PASS: delete in middle");
            passed++;
        end else begin
            $display("Test 2 FAIL: delete in middle");
            failed++;
        end

        // Test 3: Delete at end
        q = '{10, 20, 30};
        q.delete(2);
        if (q.size() == 2 && q[0] == 10 && q[1] == 20) begin
            $display("Test 3 PASS: delete at end");
            passed++;
        end else begin
            $display("Test 3 FAIL: delete at end");
            failed++;
        end

        // Test 4: Delete to make empty
        q = '{50};
        q.delete(0);
        if (q.size() == 0) begin
            $display("Test 4 PASS: delete to make empty");
            passed++;
        end else begin
            $display("Test 4 FAIL: delete to make empty");
            failed++;
        end

        // Test 5: Delete all (no argument)
        q = '{10, 20, 30};
        q.delete();
        if (q.size() == 0) begin
            $display("Test 5 PASS: delete all elements");
            passed++;
        end else begin
            $display("Test 5 FAIL: delete all elements");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
