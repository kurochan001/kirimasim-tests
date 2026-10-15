/*
:name: test_assign_queue
:description: Test for queue assignment
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_queue.expected
*/
// Test for queue assignment
// IEEE 1800-2023 §7.10: Queues
module test_assign_queue;
    initial begin
        int q1[$];
        int q2[$];

        // Push elements
        q1.push_back(10);
        q1.push_back(20);
        q1.push_back(30);

        // Queue copy
        q2 = q1;
        if (q2.size() != 3) $display("FAIL: Queue size");
        if (q2[1] != 20) $display("FAIL: Queue element");

        // Modify copy
        q2[0] = 100;
        if (q1[0] != 10) $display("FAIL: Original unchanged");

        // Element assignment
        q1[1] = 200;
        if (q1[1] != 200) $display("FAIL: Element assign");

        // Insert
        q1.insert(1, 15);
        if (q1[1] != 15) $display("FAIL: Insert");
        if (q1.size() != 4) $display("FAIL: Size after insert");

        // Delete
        q1.delete(1);
        if (q1[1] != 200) $display("FAIL: After delete");

        $display("PASS: Queue assignment");
        $finish;
    end
endmodule
