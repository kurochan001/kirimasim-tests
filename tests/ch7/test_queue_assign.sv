/*
:name: test_queue_assign
:description: Test: Queue element assignment
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_assign.expected
*/
// Test: Queue element assignment

module test_queue_assign;
    int pass_count = 0;
    int total_tests = 15;

    // Various queue types
    int int_q[$];
    logic [7:0] byte_q[$];
    string str_q[$];

    typedef struct {
        int id;
        string name;
    } item_t;
    item_t struct_q[$];

    int temp;
    item_t item;

    initial begin
        // Test 1: Queue element assignment after push
        int_q = {};
        int_q.push_back(10);
        int_q.push_back(20);
        int_q.push_back(30);
        int_q[1] = 25;
        if (int_q[1] == 25) begin
            pass_count++;
            $display("PASS: Queue element assignment");
        end else $display("FAIL: Queue element assignment, got %0d", int_q[1]);

        // Test 2: First element assignment
        int_q[0] = 15;
        if (int_q[0] == 15) begin
            pass_count++;
            $display("PASS: First element assignment");
        end else $display("FAIL: First element assignment");

        // Test 3: Last element assignment
        int_q[2] = 35;
        if (int_q[2] == 35) begin
            pass_count++;
            $display("PASS: Last element assignment");
        end else $display("FAIL: Last element assignment");

        // Test 4: Byte queue element
        byte_q = {};
        byte_q.push_back(8'hAA);
        byte_q.push_back(8'hBB);
        byte_q[0] = 8'hCC;
        if (byte_q[0] == 8'hCC) begin
            pass_count++;
            $display("PASS: Byte queue element");
        end else $display("FAIL: Byte queue element");

        // Test 5: String queue element
        str_q = {};
        str_q.push_back("hello");
        str_q.push_back("world");
        str_q[1] = "universe";
        if (str_q[1] == "universe") begin
            pass_count++;
            $display("PASS: String queue element");
        end else $display("FAIL: String queue element");

        // Test 6: Struct queue element field
        struct_q = {};
        item.id = 1;
        item.name = "first";
        struct_q.push_back(item);
        item.id = 2;
        item.name = "second";
        struct_q.push_back(item);
        struct_q[0].id = 100;
        if (struct_q[0].id == 100) begin
            pass_count++;
            $display("PASS: Struct queue element field");
        end else $display("FAIL: Struct queue element field");

        // Test 7: Struct queue element name
        struct_q[1].name = "modified";
        if (struct_q[1].name == "modified") begin
            pass_count++;
            $display("PASS: Struct queue element name");
        end else $display("FAIL: Struct queue element name");

        // Test 8: Queue element compound assignment
        int_q = {100, 200, 300};
        int_q[1] += 50;
        if (int_q[1] == 250) begin
            pass_count++;
            $display("PASS: Queue element compound");
        end else $display("FAIL: Queue element compound");

        // Test 9: Queue element from expression
        int_q[0] = int_q[1] + int_q[2];
        if (int_q[0] == 550) begin
            pass_count++;
            $display("PASS: Queue element from expression");
        end else $display("FAIL: Queue element from expression, got %0d", int_q[0]);

        // Test 10: Queue swap elements
        int_q = {1, 2, 3};
        temp = int_q[0];
        int_q[0] = int_q[2];
        int_q[2] = temp;
        if (int_q[0] == 3 && int_q[2] == 1) begin
            pass_count++;
            $display("PASS: Queue swap elements");
        end else $display("FAIL: Queue swap elements");

        // Test 11: Queue whole assignment (literal)
        int_q = '{10, 20, 30, 40, 50};
        if (int_q.size() == 5 && int_q[4] == 50) begin
            pass_count++;
            $display("PASS: Queue whole assignment");
        end else $display("FAIL: Queue whole assignment");

        // Test 12: Queue element variable index
        int_q = {100, 200, 300, 400};
        for (int i = 0; i < 4; i++) begin
            int_q[i] = i * 100;
        end
        if (int_q[0] == 0 && int_q[3] == 300) begin
            pass_count++;
            $display("PASS: Queue variable index");
        end else $display("FAIL: Queue variable index");

        // Test 13: Queue clear and reassign
        int_q = {};
        int_q.push_back(999);
        int_q[0] = 888;
        if (int_q.size() == 1 && int_q[0] == 888) begin
            pass_count++;
            $display("PASS: Queue clear and reassign");
        end else $display("FAIL: Queue clear and reassign");

        // Test 14: Byte queue bit-slice
        byte_q = {8'hAB};
        byte_q[0][7:4] = 4'hF;
        if (byte_q[0] == 8'hFB) begin
            pass_count++;
            $display("PASS: Queue element bit-slice");
        end else $display("FAIL: Queue element bit-slice, got %h", byte_q[0]);

        // Test 15: Queue copy element by element
        int_q = {1, 2, 3};
        for (int i = 0; i < int_q.size(); i++) begin
            int_q[i] = int_q[i] * 10;
        end
        if (int_q[0] == 10 && int_q[1] == 20 && int_q[2] == 30) begin
            pass_count++;
            $display("PASS: Queue copy element by element");
        end else $display("FAIL: Queue copy element by element");

        if (pass_count == total_tests) $display("PASS: queue_assign (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: queue_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
