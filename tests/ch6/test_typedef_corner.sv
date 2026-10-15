/*
:name: test_typedef_corner
:description: Tests various typedef declarations and forward typedefs
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18 7.2 7.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef_corner.expected
*/
// Tests various typedef declarations and forward typedefs
`timescale 1ns/1ps

module test_typedef_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Simple typedef
    typedef logic [7:0] byte_t;
    typedef logic [31:0] word_t;

    // Signed typedef
    typedef logic signed [15:0] signed_half_t;

    // Array typedef
    typedef logic [7:0] byte_array_t[4];
    typedef int int_queue_t[$];

    // Nested typedef
    typedef byte_t data_byte_t;

    // Struct typedef
    typedef struct packed {
        byte_t addr;
        byte_t data;
    } simple_packet_t;

    // Typedef of typedef
    typedef simple_packet_t packet_alias_t;

    // Parameterized-like typedef (using localparam)
    localparam int WIDTH = 16;
    typedef logic [WIDTH-1:0] param_word_t;

    // Test 1: Simple typedef
    task test_simple_typedef();
        byte_t b;
        word_t w;

        b = 8'hAB;
        w = 32'hDEADBEEF;

        if (b == 8'hAB && w == 32'hDEADBEEF) begin
            $display("PASS: Simple typedef works");
            pass_count++;
        end else begin
            $display("FAIL: Simple typedef failed");
            fail_count++;
        end
    endtask

    // Test 2: Signed typedef
    task test_signed_typedef();
        signed_half_t s;

        s = -1;
        if (s == -1 && s == 16'hFFFF) begin
            $display("PASS: Signed typedef works");
            pass_count++;
        end else begin
            $display("FAIL: Signed typedef failed");
            fail_count++;
        end
    endtask

    // Test 3: Array typedef
    task test_array_typedef();
        byte_array_t arr;
        int i;

        for (i = 0; i < 4; i++) begin
            arr[i] = i * 16;
        end

        if (arr[0] == 0 && arr[3] == 48) begin
            $display("PASS: Array typedef works");
            pass_count++;
        end else begin
            $display("FAIL: Array typedef failed");
            fail_count++;
        end
    endtask

    // Test 4: Queue typedef
    task test_queue_typedef();
        int_queue_t q;

        q.push_back(10);
        q.push_back(20);
        q.push_back(30);

        if (q.size() == 3 && q[1] == 20) begin
            $display("PASS: Queue typedef works");
            pass_count++;
        end else begin
            $display("FAIL: Queue typedef failed");
            fail_count++;
        end
    endtask

    // Test 5: Nested typedef
    task test_nested_typedef();
        data_byte_t db;

        db = 8'h55;
        if (db == 8'h55) begin
            $display("PASS: Nested typedef works");
            pass_count++;
        end else begin
            $display("FAIL: Nested typedef failed");
            fail_count++;
        end
    endtask

    // Test 6: Struct typedef
    task test_struct_typedef();
        simple_packet_t pkt;

        pkt.addr = 8'h10;
        pkt.data = 8'h20;

        if (pkt.addr == 8'h10 && pkt.data == 8'h20) begin
            $display("PASS: Struct typedef works");
            pass_count++;
        end else begin
            $display("FAIL: Struct typedef failed");
            fail_count++;
        end
    endtask

    // Test 7: Typedef alias
    task test_typedef_alias();
        packet_alias_t pkt;

        pkt.addr = 8'hAA;
        pkt.data = 8'hBB;

        if (pkt.addr == 8'hAA && pkt.data == 8'hBB) begin
            $display("PASS: Typedef alias works");
            pass_count++;
        end else begin
            $display("FAIL: Typedef alias failed");
            fail_count++;
        end
    endtask

    // Test 8: Parameterized-like typedef
    task test_param_typedef();
        param_word_t pw;

        pw = 16'hCAFE;
        if (pw == 16'hCAFE) begin
            $display("PASS: Parameterized-like typedef works");
            pass_count++;
        end else begin
            $display("FAIL: Parameterized-like typedef failed");
            fail_count++;
        end
    endtask

    // Test 9: Typedef in function return
    function byte_t get_byte();
        return 8'h42;
    endfunction

    task test_typedef_function();
        byte_t result;

        result = get_byte();
        if (result == 8'h42) begin
            $display("PASS: Typedef in function return works");
            pass_count++;
        end else begin
            $display("FAIL: Typedef in function return failed");
            fail_count++;
        end
    endtask

    // Test 10: Typedef in function argument
    function word_t combine_bytes(byte_t b3, byte_t b2, byte_t b1, byte_t b0);
        return {b3, b2, b1, b0};
    endfunction

    task test_typedef_argument();
        word_t result;

        result = combine_bytes(8'h01, 8'h02, 8'h03, 8'h04);
        if (result == 32'h01020304) begin
            $display("PASS: Typedef in function argument works");
            pass_count++;
        end else begin
            $display("FAIL: Typedef in function argument failed");
            fail_count++;
        end
    endtask

    // Test 11: Typedef comparison
    task test_typedef_comparison();
        byte_t a, b;

        a = 8'h10;
        b = 8'h20;

        if (a < b) begin
            $display("PASS: Typedef comparison works");
            pass_count++;
        end else begin
            $display("FAIL: Typedef comparison failed");
            fail_count++;
        end
    endtask

    // Test 12: Typedef arithmetic
    task test_typedef_arithmetic();
        byte_t a, b, c;

        a = 8'h10;
        b = 8'h05;
        c = a + b;

        if (c == 8'h15) begin
            $display("PASS: Typedef arithmetic works");
            pass_count++;
        end else begin
            $display("FAIL: Typedef arithmetic failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Typedef Corner Cases Test ===");

        test_simple_typedef();
        test_signed_typedef();
        test_array_typedef();
        test_queue_typedef();
        test_nested_typedef();
        test_struct_typedef();
        test_typedef_alias();
        test_param_typedef();
        test_typedef_function();
        test_typedef_argument();
        test_typedef_comparison();
        test_typedef_arithmetic();

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
