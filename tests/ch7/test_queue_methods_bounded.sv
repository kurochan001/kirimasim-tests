/*
:name: test_queue_methods_bounded
:description: Queue methods, assignment from a list and a bounded queue
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_methods_bounded.expected
*/
`timescale 1ns/1ps

module test_queue_methods_bounded;
    int q[$];
    int q2[$:10]; // Bounded queue

    initial begin
        // Push operations
        q.push_back(1);
        q.push_back(2);
        q.push_front(0);

        if (q.size() != 3) $display("FAIL: size after push");
        if (q[0] != 0) $display("FAIL: q[0]");
        if (q[1] != 1) $display("FAIL: q[1]");
        if (q[2] != 2) $display("FAIL: q[2]");

        // Pop operations
        if (q.pop_front() != 0) $display("FAIL: pop_front");
        if (q.pop_back() != 2) $display("FAIL: pop_back");
        if (q.size() != 1) $display("FAIL: size after pop");

        // Insert/delete
        q.delete();
        q = '{1, 2, 3, 4, 5};
        q.insert(2, 99);
        if (q[2] != 99) $display("FAIL: insert");

        q.delete(2);
        if (q[2] != 3) $display("FAIL: delete");

        // Bounded queue
        for (int i = 0; i < 15; i++) begin
            if (q2.size() < 10)
                q2.push_back(i);
        end
        if (q2.size() != 10) $display("FAIL: bounded size");

        $display("TEST PASSED");
        $finish;
    end
endmodule
