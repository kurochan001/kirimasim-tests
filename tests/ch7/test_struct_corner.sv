/*
:name: test_struct_corner
:description: Tests packed/unpacked structs, nested structs, struct operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1 7.2.2 10.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_corner.expected
*/
// Tests packed/unpacked structs, nested structs, struct operations
`timescale 1ns/1ps

module test_struct_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Packed struct
    typedef struct packed {
        logic [7:0] addr;
        logic [7:0] data;
        logic       valid;
        logic       ready;
    } packet_t;

    // Unpacked struct
    typedef struct {
        int value;
        string name;
        real weight;
    } item_t;

    // Nested struct
    typedef struct packed {
        logic [3:0] opcode;
        logic [3:0] flags;
    } header_t;

    typedef struct packed {
        header_t header;
        logic [23:0] payload;
    } frame_t;

    // Struct with array
    typedef struct {
        int data[4];
        int count;
    } buffer_t;

    // Test 1: Packed struct basic
    task test_packed_struct();
        packet_t pkt;

        pkt.addr = 8'hAB;
        pkt.data = 8'hCD;
        pkt.valid = 1;
        pkt.ready = 0;

        if (pkt.addr == 8'hAB && pkt.data == 8'hCD &&
            pkt.valid == 1 && pkt.ready == 0) begin
            $display("PASS: Packed struct basic access works");
            pass_count++;
        end else begin
            $display("FAIL: Packed struct basic access failed");
            fail_count++;
        end
    endtask

    // Test 2: Packed struct as bit vector
    task test_packed_as_vector();
        packet_t pkt;
        logic [17:0] vec;

        pkt = '{addr: 8'hFF, data: 8'h00, valid: 1'b1, ready: 1'b0};
        vec = pkt;

        if (vec[17:10] == 8'hFF && vec[9:2] == 8'h00 &&
            vec[1] == 1 && vec[0] == 0) begin
            $display("PASS: Packed struct as bit vector works");
            pass_count++;
        end else begin
            $display("FAIL: Packed struct conversion (value: %h)", vec);
            fail_count++;
        end
    endtask

    // Test 3: Unpacked struct
    task test_unpacked_struct();
        item_t item;

        item.value = 42;
        item.name = "test_item";
        item.weight = 3.14;

        if (item.value == 42 && item.name == "test_item") begin
            $display("PASS: Unpacked struct works");
            pass_count++;
        end else begin
            $display("FAIL: Unpacked struct failed");
            fail_count++;
        end
    endtask

    // Test 4: Nested struct
    task test_nested_struct();
        frame_t frame;

        frame.header.opcode = 4'hA;
        frame.header.flags = 4'h5;
        frame.payload = 24'hCAFE00;

        if (frame.header.opcode == 4'hA && frame.header.flags == 4'h5 &&
            frame.payload == 24'hCAFE00) begin
            $display("PASS: Nested struct works");
            pass_count++;
        end else begin
            $display("FAIL: Nested struct failed");
            fail_count++;
        end
    endtask

    // Test 5: Struct with array
    task test_struct_with_array();
        buffer_t mybuf;
        int i;

        for (i = 0; i < 4; i++) begin
            mybuf.data[i] = i * 10;
        end
        mybuf.count = 4;

        if (mybuf.data[0] == 0 && mybuf.data[3] == 30 && mybuf.count == 4) begin
            $display("PASS: Struct with array works");
            pass_count++;
        end else begin
            $display("FAIL: Struct with array failed");
            fail_count++;
        end
    endtask

    // Test 6: Struct assignment
    task test_struct_assignment();
        packet_t pkt1, pkt2;

        pkt1 = '{addr: 8'h11, data: 8'h22, valid: 1'b1, ready: 1'b0};
        pkt2 = pkt1;

        pkt2.addr = 8'h33;

        if (pkt1.addr == 8'h11 && pkt2.addr == 8'h33) begin
            $display("PASS: Struct assignment creates copy");
            pass_count++;
        end else begin
            $display("FAIL: Struct assignment failed");
            fail_count++;
        end
    endtask

    // Test 7: Struct comparison
    task test_struct_comparison();
        packet_t pkt1, pkt2;

        pkt1 = '{addr: 8'hAA, data: 8'hBB, valid: 1'b1, ready: 1'b1};
        pkt2 = pkt1;

        if (pkt1 == pkt2) begin
            $display("PASS: Struct comparison (equal) works");
            pass_count++;
        end else begin
            $display("FAIL: Struct comparison failed");
            fail_count++;
        end

        pkt2.data = 8'hCC;
        if (pkt1 != pkt2) begin
            $display("PASS: Struct comparison (not equal) works");
            pass_count++;
        end else begin
            $display("FAIL: Struct not-equal comparison failed");
            fail_count++;
        end
    endtask

    // Test 8: Struct literal assignment
    task test_struct_literal();
        packet_t pkt;

        pkt = '{8'hDE, 8'hAD, 1'b1, 1'b0};

        if (pkt.addr == 8'hDE && pkt.data == 8'hAD) begin
            $display("PASS: Struct literal assignment works");
            pass_count++;
        end else begin
            $display("FAIL: Struct literal assignment failed");
            fail_count++;
        end
    endtask

    // Test 9: Struct in function
    function packet_t create_packet(input logic [7:0] a, input logic [7:0] d);
        packet_t p;
        p.addr = a;
        p.data = d;
        p.valid = 1;
        p.ready = 0;
        return p;
    endfunction

    task test_struct_function();
        packet_t pkt;

        pkt = create_packet(8'h12, 8'h34);

        if (pkt.addr == 8'h12 && pkt.data == 8'h34 && pkt.valid == 1) begin
            $display("PASS: Struct in function works");
            pass_count++;
        end else begin
            $display("FAIL: Struct in function failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Struct Corner Cases Test ===");

        test_packed_struct();
        test_packed_as_vector();
        test_unpacked_struct();
        test_nested_struct();
        test_struct_with_array();
        test_struct_assignment();
        test_struct_comparison();
        test_struct_literal();
        test_struct_function();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
