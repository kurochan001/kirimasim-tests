/*
:name: test_queue_methods_3
:description: Queue push_back, push_front, pop_front and pop_back
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_methods_3.expected
*/
// Queue push_back, push_front, pop_front and pop_back

module test_queue_methods;
    initial begin
        int q[$];

        // Push
        q.push_back(1);
        q.push_back(2);
        q.push_front(0);

        if (q.size() != 3 || q[0] != 0 || q[1] != 1 || q[2] != 2) begin
            $display("FAIL: push operations");
            $finish;
        end

        // Pop
        void'(q.pop_front());
        if (q.size() != 2 || q[0] != 1) begin
            $display("FAIL: pop_front");
            $finish;
        end

        void'(q.pop_back());
        if (q.size() != 1 || q[0] != 1) begin
            $display("FAIL: pop_back");
            $finish;
        end

        $display("PASS: queue methods");
        $finish;
    end
endmodule
