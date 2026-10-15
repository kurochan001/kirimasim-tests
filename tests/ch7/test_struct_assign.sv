/*
:name: test_struct_assign
:description: Test: Struct field assignment
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 10.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_assign.expected
*/
// Test: Struct field assignment

module test_struct_assign;
    int pass_count = 0;
    int total_tests = 15;

    // Simple struct
    typedef struct {
        logic [7:0] data;
        logic [3:0] addr;
        logic valid;
    } packet_t;

    // Nested struct
    typedef struct {
        logic [15:0] x;
        logic [15:0] y;
    } point_t;

    typedef struct {
        point_t start_pt;
        point_t end_pt;
        logic [7:0] color;
    } line_t;

    // Struct with array
    typedef struct {
        logic [7:0] bytes [0:3];
        int count;
    } buffer_t;

    // Packed struct
    typedef struct packed {
        logic [7:0] high;
        logic [7:0] low;
    } word_t;

    packet_t pkt1, pkt2;
    line_t line;
    buffer_t buffer;
    word_t word;
    point_t pt;

    initial begin
        // Test 1: Simple field assignment
        pkt1.data = 8'hAB;
        pkt1.addr = 4'hC;
        pkt1.valid = 1;
        if (pkt1.data == 8'hAB && pkt1.addr == 4'hC && pkt1.valid == 1) begin
            pass_count++;
            $display("PASS: Simple field assignment");
        end else $display("FAIL: Simple field assignment");

        // Test 2: Struct copy
        pkt2 = pkt1;
        if (pkt2.data == 8'hAB && pkt2.addr == 4'hC && pkt2.valid == 1) begin
            pass_count++;
            $display("PASS: Struct copy");
        end else $display("FAIL: Struct copy");

        // Test 3: Aggregate literal assignment
        pkt1 = '{data: 8'hFF, addr: 4'h5, valid: 0};
        if (pkt1.data == 8'hFF && pkt1.addr == 4'h5 && pkt1.valid == 0) begin
            pass_count++;
            $display("PASS: Aggregate literal assignment");
        end else $display("FAIL: Aggregate literal assignment");

        // Test 4: Positional aggregate
        pkt1 = '{8'h12, 4'h3, 1'b1};
        if (pkt1.data == 8'h12 && pkt1.addr == 4'h3 && pkt1.valid == 1) begin
            pass_count++;
            $display("PASS: Positional aggregate assignment");
        end else $display("FAIL: Positional aggregate assignment");

        // Test 5: Nested struct field assignment
        line.start_pt.x = 16'h0010;
        line.start_pt.y = 16'h0020;
        line.end_pt.x = 16'h0100;
        line.end_pt.y = 16'h0200;
        line.color = 8'hFF;
        if (line.start_pt.x == 16'h0010 && line.end_pt.y == 16'h0200) begin
            pass_count++;
            $display("PASS: Nested struct field assignment");
        end else $display("FAIL: Nested struct field assignment");

        // Test 6: Nested struct copy
        pt = line.start_pt;
        if (pt.x == 16'h0010 && pt.y == 16'h0020) begin
            pass_count++;
            $display("PASS: Nested struct copy");
        end else $display("FAIL: Nested struct copy");

        // Test 7: Struct with array - field assignment
        buffer.count = 4;
        for (int i = 0; i < 4; i++) begin
            buffer.bytes[i] = i * 16;
        end
        if (buffer.count == 4 && buffer.bytes[0] == 0 && buffer.bytes[3] == 48) begin
            pass_count++;
            $display("PASS: Struct with array field");
        end else $display("FAIL: Struct with array field");

        // Test 8: Packed struct assignment
        word.high = 8'hAB;
        word.low = 8'hCD;
        if (word.high == 8'hAB && word.low == 8'hCD) begin
            pass_count++;
            $display("PASS: Packed struct field assignment");
        end else $display("FAIL: Packed struct field assignment");

        // Test 9: Packed struct as whole
        word = 16'h1234;
        if (word.high == 8'h12 && word.low == 8'h34) begin
            pass_count++;
            $display("PASS: Packed struct whole assignment");
        end else $display("FAIL: Packed struct whole assignment, high=%h low=%h", word.high, word.low);

        // Test 10: Field with expression
        pkt1.data = pkt2.data + 8'h10;
        if (pkt1.data == 8'hBB) begin
            pass_count++;
            $display("PASS: Field with expression");
        end else $display("FAIL: Field with expression");

        // Test 11: Compound field assignment
        pkt1.addr = 4'h0;
        pkt1.addr += 4'h5;
        if (pkt1.addr == 4'h5) begin
            pass_count++;
            $display("PASS: Compound field assignment");
        end else $display("FAIL: Compound field assignment");

        // Test 12: Field bit slice assignment
        pkt1.data = 8'hAB;
        pkt1.data[7:4] = 4'hF;
        if (pkt1.data == 8'hFB) begin
            pass_count++;
            $display("PASS: Field bit slice assignment");
        end else $display("FAIL: Field bit slice assignment, got %h", pkt1.data);

        // Test 13: Default value in aggregate
        pkt1 = '{default: '0};
        if (pkt1.data == 0 && pkt1.addr == 0 && pkt1.valid == 0) begin
            pass_count++;
            $display("PASS: Default value in aggregate");
        end else $display("FAIL: Default value in aggregate");

        // Test 14: Mixed named and positional (partial)
        line.start_pt = '{16'hAAAA, 16'hBBBB};
        if (line.start_pt.x == 16'hAAAA && line.start_pt.y == 16'hBBBB) begin
            pass_count++;
            $display("PASS: Mixed aggregate assignment");
        end else $display("FAIL: Mixed aggregate assignment");

        // Test 15: Assignment from function/expression
        pkt1.data = 8'h80;
        pkt1.valid = (pkt1.data > 8'h7F);
        if (pkt1.valid == 1) begin
            pass_count++;
            $display("PASS: Field assignment from comparison");
        end else $display("FAIL: Field assignment from comparison");

        if (pass_count == total_tests) $display("PASS: struct_assign (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: struct_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
