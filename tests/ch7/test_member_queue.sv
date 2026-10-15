/*
:name: test_member_queue
:description: Queue methods on int, byte and string queues
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_queue.expected
*/
// Queue methods on int, byte and string queues
module test_member_queue;
    int pass_count = 0;
    int total_tests = 8;

    int int_queue[$];
    logic [7:0] byte_queue[$];
    string str_queue[$];

    int popped_val;
    logic [7:0] popped_byte;
    string popped_str;

    initial begin
        // Test 1: push_back
        int_queue.push_back(10);
        int_queue.push_back(20);
        int_queue.push_back(30);
        if (int_queue.size() == 3 && int_queue[0] == 10 && int_queue[2] == 30) begin
            $display("Test 1 PASS: push_back works, size=%0d", int_queue.size());
            pass_count++;
        end else begin
            $display("Test 1 FAIL: push_back failed");
        end

        // Test 2: push_front
        int_queue.push_front(5);
        if (int_queue[0] == 5 && int_queue.size() == 4) begin
            $display("Test 2 PASS: push_front works, front=%0d", int_queue[0]);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: push_front failed");
        end

        // Test 3: pop_front
        popped_val = int_queue.pop_front();
        if (popped_val == 5 && int_queue.size() == 3) begin
            $display("Test 3 PASS: pop_front returned %0d", popped_val);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: pop_front returned %0d, expected 5", popped_val);
        end

        // Test 4: pop_back
        popped_val = int_queue.pop_back();
        if (popped_val == 30 && int_queue.size() == 2) begin
            $display("Test 4 PASS: pop_back returned %0d", popped_val);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: pop_back returned %0d, expected 30", popped_val);
        end

        // Test 5: insert
        int_queue.insert(1, 15);  // Insert 15 at index 1
        if (int_queue[1] == 15 && int_queue.size() == 3) begin
            $display("Test 5 PASS: insert at index 1 = %0d", int_queue[1]);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: insert failed");
        end

        // Test 6: delete specific index
        int_queue.delete(1);  // Remove the 15 we just inserted
        if (int_queue.size() == 2 && int_queue[0] == 10 && int_queue[1] == 20) begin
            $display("Test 6 PASS: delete(1) works, remaining: %0d, %0d", int_queue[0], int_queue[1]);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: delete failed");
        end

        // Test 7: Queue with byte type
        byte_queue.push_back(8'hAA);
        byte_queue.push_back(8'hBB);
        byte_queue.push_back(8'hCC);
        popped_byte = byte_queue.pop_front();
        if (popped_byte == 8'hAA && byte_queue.size() == 2) begin
            $display("Test 7 PASS: byte queue pop_front = %h", popped_byte);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: byte queue failed");
        end

        // Test 8: Queue with string type
        str_queue.push_back("hello");
        str_queue.push_back("world");
        str_queue.push_front("say");
        popped_str = str_queue.pop_back();
        if (popped_str == "world" && str_queue.size() == 2) begin
            $display("Test 8 PASS: string queue pop_back = %s", popped_str);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: string queue failed");
        end

        $display("PASS: member_queue (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
