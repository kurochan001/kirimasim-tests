/*
:name: test_struct_union_edge_cases
:description: Struct and union edge cases: packed and unpacked structs, unions and nesting
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1 7.3 7.3.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_union_edge_cases.expected
*/
// Struct and union edge cases: packed and unpacked structs, unions and nesting

module test_struct_union_edge_cases;
    int pass_count = 0;
    int fail_count = 0;

    // Packed struct
    typedef struct packed {
        logic [7:0] byte3;
        logic [7:0] byte2;
        logic [7:0] byte1;
        logic [7:0] byte0;
    } packet_t;

    // Unpacked struct
    typedef struct {
        int id;
        string name;
        logic [15:0] flags;
    } config_t;

    // Nested struct
    typedef struct {
        int x;
        int y;
    } point_t;

    typedef struct {
        point_t start_point;
        point_t end_point;
        int color;
    } line_t;

    // Packed union - all members must be packed
    typedef union packed {
        logic [31:0] word;
        logic [1:0][15:0] half;       // Packed array
        logic [3:0][7:0] byte_arr;    // Packed array
    } data_u;

    // Variables
    packet_t pkt;
    config_t cfg;
    line_t line_data;
    data_u du;
    logic [31:0] raw_bits;

    initial begin
        $display("=== Struct/Union Edge Cases Test ===");

        // Test packed struct assignment
        $display("\n--- Packed Struct Assignment ---");
        pkt.byte0 = 8'hAA;
        pkt.byte1 = 8'hBB;
        pkt.byte2 = 8'hCC;
        pkt.byte3 = 8'hDD;
        if (pkt.byte0 == 8'hAA && pkt.byte3 == 8'hDD) begin
            $display("PASS: packed struct member assign");
            pass_count++;
        end else begin
            $display("FAIL: packed struct member assign");
            fail_count++;
        end

        // Test packed struct to bits
        $display("\n--- Packed Struct to Bits ---");
        raw_bits = pkt;
        if (raw_bits == 32'hDDCCBBAA) begin
            $display("PASS: packed struct to bits");
            pass_count++;
        end else begin
            $display("FAIL: packed struct to bits = %h", raw_bits);
            fail_count++;
        end

        // Test bits to packed struct
        $display("\n--- Bits to Packed Struct ---");
        pkt = 32'h12345678;
        if (pkt.byte0 == 8'h78 && pkt.byte3 == 8'h12) begin
            $display("PASS: bits to packed struct");
            pass_count++;
        end else begin
            $display("FAIL: bits to packed struct byte0=%h byte3=%h", pkt.byte0, pkt.byte3);
            fail_count++;
        end

        // Test unpacked struct
        $display("\n--- Unpacked Struct ---");
        cfg.id = 100;
        cfg.name = "test_config";
        cfg.flags = 16'hABCD;
        if (cfg.id == 100 && cfg.name == "test_config" && cfg.flags == 16'hABCD) begin
            $display("PASS: unpacked struct");
            pass_count++;
        end else begin
            $display("FAIL: unpacked struct");
            fail_count++;
        end

        // Test nested struct
        $display("\n--- Nested Struct ---");
        line_data.start_point.x = 10;
        line_data.start_point.y = 20;
        line_data.end_point.x = 100;
        line_data.end_point.y = 200;
        line_data.color = 255;
        if (line_data.start_point.x == 10 && line_data.end_point.y == 200) begin
            $display("PASS: nested struct access");
            pass_count++;
        end else begin
            $display("FAIL: nested struct access");
            fail_count++;
        end

        // Test packed union word access
        $display("\n--- Packed Union Word ---");
        du.word = 32'hDEADBEEF;
        if (du.word == 32'hDEADBEEF) begin
            $display("PASS: packed union word access");
            pass_count++;
        end else begin
            $display("FAIL: packed union word access");
            fail_count++;
        end

        // Test packed union half word access
        $display("\n--- Packed Union Half Word ---");
        if (du.half[0] == 16'hBEEF && du.half[1] == 16'hDEAD) begin
            $display("PASS: packed union half access");
            pass_count++;
        end else begin
            $display("FAIL: packed union half access h0=%h h1=%h", du.half[0], du.half[1]);
            fail_count++;
        end

        // Test packed union byte access
        $display("\n--- Packed Union Byte ---");
        if (du.byte_arr[0] == 8'hEF && du.byte_arr[3] == 8'hDE) begin
            $display("PASS: packed union byte access");
            pass_count++;
        end else begin
            $display("FAIL: packed union byte access b0=%h b3=%h", du.byte_arr[0], du.byte_arr[3]);
            fail_count++;
        end

        // Test struct literal
        $display("\n--- Struct Literal ---");
        pkt = '{8'h11, 8'h22, 8'h33, 8'h44};
        if (pkt.byte3 == 8'h11 && pkt.byte0 == 8'h44) begin
            $display("PASS: struct literal");
            pass_count++;
        end else begin
            $display("FAIL: struct literal byte3=%h byte0=%h", pkt.byte3, pkt.byte0);
            fail_count++;
        end

        // Test struct to 32-bit conversion
        $display("\n--- Struct to 32-bit ---");
        pkt = '{8'hAA, 8'hBB, 8'hCC, 8'hDD};
        raw_bits = pkt;
        if (raw_bits == 32'hAABBCCDD) begin
            $display("PASS: struct to 32-bit");
            pass_count++;
        end else begin
            $display("FAIL: struct to 32-bit = %h", raw_bits);
            fail_count++;
        end

        $display("");
        $display("=== Summary: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
