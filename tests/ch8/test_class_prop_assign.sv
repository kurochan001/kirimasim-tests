/*
:name: test_class_prop_assign
:description: Test: Class property assignment
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.5 8.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_prop_assign.expected
*/
// Test: Class property assignment

module test_class_prop_assign;
    int pass_count = 0;
    int total_tests = 15;

    // Simple class
    class Packet;
        logic [7:0] data;
        logic [3:0] addr;
        bit valid;
        int count;
        string name;

        function new();
            data = 0;
            addr = 0;
            valid = 0;
            count = 0;
            name = "default";
        endfunction
    endclass

    // Class with array property
    class Buffer;
        logic [7:0] bytes [0:3];
        int size;

        function new();
            size = 4;
            foreach (bytes[i]) bytes[i] = 0;
        endfunction
    endclass

    // Class with nested object
    class Container;
        Packet pkt;
        int id;

        function new();
            pkt = new();
            id = 0;
        endfunction
    endclass

    // Class with static property
    class Counter;
        static int total_count = 0;
        int local_count;

        function new();
            local_count = 0;
            total_count++;
        endfunction
    endclass

    Packet p1, p2;
    Buffer buffer;
    Container cont;
    Counter c1, c2;

    initial begin
        // Test 1: Simple property assignment
        p1 = new();
        p1.data = 8'hAB;
        p1.addr = 4'hC;
        if (p1.data == 8'hAB && p1.addr == 4'hC) begin
            pass_count++;
            $display("PASS: Simple property assignment");
        end else $display("FAIL: Simple property assignment");

        // Test 2: Bit property assignment
        p1.valid = 1;
        if (p1.valid == 1) begin
            pass_count++;
            $display("PASS: Bit property assignment");
        end else $display("FAIL: Bit property assignment");

        // Test 3: Int property assignment
        p1.count = 42;
        if (p1.count == 42) begin
            pass_count++;
            $display("PASS: Int property assignment");
        end else $display("FAIL: Int property assignment");

        // Test 4: String property assignment
        p1.name = "packet1";
        if (p1.name == "packet1") begin
            pass_count++;
            $display("PASS: String property assignment");
        end else $display("FAIL: String property assignment");

        // Test 5: Object copy (shallow)
        p2 = new();
        p2.data = p1.data;
        p2.addr = p1.addr;
        if (p2.data == 8'hAB && p2.addr == 4'hC) begin
            pass_count++;
            $display("PASS: Object property copy");
        end else $display("FAIL: Object property copy");

        // Test 6: Array property element assignment
        buffer = new();
        buffer.bytes[0] = 8'h11;
        buffer.bytes[1] = 8'h22;
        buffer.bytes[2] = 8'h33;
        buffer.bytes[3] = 8'h44;
        if (buffer.bytes[0] == 8'h11 && buffer.bytes[3] == 8'h44) begin
            pass_count++;
            $display("PASS: Array property element");
        end else $display("FAIL: Array property element");

        // Test 7: Array property loop assignment
        for (int i = 0; i < 4; i++) begin
            buffer.bytes[i] = i * 16;
        end
        if (buffer.bytes[0] == 0 && buffer.bytes[3] == 48) begin
            pass_count++;
            $display("PASS: Array property loop");
        end else $display("FAIL: Array property loop");

        // Test 8: Nested object property
        cont = new();
        cont.pkt.data = 8'hFF;
        cont.pkt.addr = 4'h5;
        if (cont.pkt.data == 8'hFF && cont.pkt.addr == 4'h5) begin
            pass_count++;
            $display("PASS: Nested object property");
        end else $display("FAIL: Nested object property");

        // Test 9: Container id assignment
        cont.id = 100;
        if (cont.id == 100) begin
            pass_count++;
            $display("PASS: Container property");
        end else $display("FAIL: Container property");

        // Test 10: Static property (class-level)
        Counter::total_count = 0;  // Reset
        c1 = new();
        c2 = new();
        if (Counter::total_count == 2) begin
            pass_count++;
            $display("PASS: Static property increment");
        end else $display("FAIL: Static property increment, got %0d", Counter::total_count);

        // Test 11: Static property direct assignment
        Counter::total_count = 99;
        if (Counter::total_count == 99) begin
            pass_count++;
            $display("PASS: Static property direct assign");
        end else $display("FAIL: Static property direct assign");

        // Test 12: Property compound assignment
        p1.count = 10;
        p1.count += 5;
        if (p1.count == 15) begin
            pass_count++;
            $display("PASS: Property compound assignment");
        end else $display("FAIL: Property compound assignment");

        // Test 13: Property bit-slice assignment
        p1.data = 8'hAA;
        p1.data[7:4] = 4'hF;
        if (p1.data == 8'hFA) begin
            pass_count++;
            $display("PASS: Property bit-slice assignment");
        end else $display("FAIL: Property bit-slice assignment, got %h", p1.data);

        // Test 14: Property from expression
        p1.data = 8'h10;
        p1.addr = 4'h2;
        p2.data = p1.data + {4'h0, p1.addr};
        if (p2.data == 8'h12) begin
            pass_count++;
            $display("PASS: Property from expression");
        end else $display("FAIL: Property from expression");

        // Test 15: Multiple property assign same object
        p1.data = 8'h00;
        p1.addr = 4'h0;
        p1.valid = 0;
        p1.count = 0;
        if (p1.data == 0 && p1.addr == 0 && p1.valid == 0 && p1.count == 0) begin
            pass_count++;
            $display("PASS: Multiple property reset");
        end else $display("FAIL: Multiple property reset");

        if (pass_count == total_tests) $display("PASS: class_prop_assign (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: class_prop_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
