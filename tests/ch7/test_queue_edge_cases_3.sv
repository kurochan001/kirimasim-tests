/*
:name: test_queue_edge_cases_3
:description: Corner Case: Queue Edge Cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_edge_cases_3.expected
*/
// Corner Case: Queue Edge Cases
// Tests queue operations at boundaries

module test_queue_edge_cases;
    int test_count;
    int pass_count;

    int q[$];
    int value;
    int popped;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: Empty queue size
        test_count++;
        if (q.size() == 0) pass_count++;
        else $display("FAIL: Empty queue size = %0d", q.size());

        // Test 2: Push to empty queue
        q.push_back(10);
        test_count++;
        if (q.size() == 1 && q[0] == 10) pass_count++;
        else $display("FAIL: Push to empty - size=%0d, [0]=%0d", q.size(), q[0]);

        // Test 3: Push front
        q.push_front(5);
        test_count++;
        if (q[0] == 5 && q[1] == 10) pass_count++;
        else $display("FAIL: Push front - [0]=%0d, [1]=%0d", q[0], q[1]);

        // Test 4: Pop back
        popped = q.pop_back();
        test_count++;
        if (popped == 10 && q.size() == 1) pass_count++;
        else $display("FAIL: Pop back - popped=%0d, size=%0d", popped, q.size());

        // Test 5: Pop front
        popped = q.pop_front();
        test_count++;
        if (popped == 5 && q.size() == 0) pass_count++;
        else $display("FAIL: Pop front - popped=%0d, size=%0d", popped, q.size());

        // Test 6: Delete all
        q.push_back(1);
        q.push_back(2);
        q.push_back(3);
        q.delete();
        test_count++;
        if (q.size() == 0) pass_count++;
        else $display("FAIL: Delete - size=%0d", q.size());

        // Test 7: Insert at index
        q.push_back(10);
        q.push_back(30);
        q.insert(1, 20);  // Insert 20 at index 1
        test_count++;
        if (q[0] == 10 && q[1] == 20 && q[2] == 30) pass_count++;
        else $display("FAIL: Insert - q=%p", q);

        // Test 8: Delete specific index
        q.delete(1);  // Delete index 1 (20)
        test_count++;
        if (q.size() == 2 && q[0] == 10 && q[1] == 30) pass_count++;
        else $display("FAIL: Delete index - q=%p", q);

        $display("Corner Case Queue Edge: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
