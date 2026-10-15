/*
:name: test_struct_packed_2
:description: Packed struct bit operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_packed_2.expected
*/
// Packed struct bit operations
module test_struct_packed;
    int pass_count = 0;
    int fail_count = 0;

    // Simple packed struct
    typedef struct packed {
        logic [7:0] header;
        logic [15:0] payload;
        logic [7:0] footer;
    } packet_t;  // Total: 32 bits

    // Packed struct with sub-fields
    typedef struct packed {
        logic [3:0] opcode;
        logic [3:0] flags;
        logic [7:0] addr;
        logic [15:0] data;
    } command_t;  // Total: 32 bits

    // Nested packed struct
    typedef struct packed {
        logic [7:0] tag;
        command_t cmd;
        logic [7:0] checksum;
    } frame_t;  // Total: 48 bits

    packet_t pkt;
    command_t cmd;
    frame_t frame;
    logic [31:0] raw_pkt;
    logic [31:0] raw_cmd;

    initial begin
        // Test 1: Packed struct assignment and field access
        pkt.header = 8'hAA;
        pkt.payload = 16'h1234;
        pkt.footer = 8'hBB;

        if (pkt.header == 8'hAA && pkt.payload == 16'h1234 && pkt.footer == 8'hBB) begin
            $display("PASS: Packed struct field assignment");
            pass_count++;
        end else begin
            $display("FAIL: Field assignment - header=0x%02X, payload=0x%04X, footer=0x%02X",
                     pkt.header, pkt.payload, pkt.footer);
            fail_count++;
        end

        // Test 2: Packed struct as bit vector
        raw_pkt = pkt;
        if (raw_pkt == 32'hAA1234BB) begin
            $display("PASS: Packed struct to bit vector conversion");
            pass_count++;
        end else begin
            $display("FAIL: Bit vector - expected 0xAA1234BB, got 0x%08X", raw_pkt);
            fail_count++;
        end

        // Test 3: Bit vector to packed struct
        raw_pkt = 32'hCC5678DD;
        pkt = raw_pkt;
        if (pkt.header == 8'hCC && pkt.payload == 16'h5678 && pkt.footer == 8'hDD) begin
            $display("PASS: Bit vector to packed struct conversion");
            pass_count++;
        end else begin
            $display("FAIL: From bit vector - header=0x%02X, payload=0x%04X",
                     pkt.header, pkt.payload);
            fail_count++;
        end

        // Test 4: Bitwise operations on packed struct
        pkt = 32'hFFFFFFFF;
        pkt = pkt & 32'h00FFFF00;  // Clear header and footer
        if (pkt.header == 8'h00 && pkt.payload == 16'hFFFF && pkt.footer == 8'h00) begin
            $display("PASS: Bitwise AND on packed struct");
            pass_count++;
        end else begin
            $display("FAIL: Bitwise AND - got 0x%08X", pkt);
            fail_count++;
        end

        // Test 5: Command struct with sub-fields
        cmd.opcode = 4'hA;
        cmd.flags = 4'h5;
        cmd.addr = 8'h80;
        cmd.data = 16'hCAFE;

        if (cmd == 32'hA580CAFE) begin
            $display("PASS: Command struct packing");
            pass_count++;
        end else begin
            $display("FAIL: Command packing - expected 0xA580CAFE, got 0x%08X", cmd);
            fail_count++;
        end

        // Test 6: Bit slicing on packed struct
        raw_cmd = cmd;
        if (raw_cmd[31:28] == 4'hA && raw_cmd[15:0] == 16'hCAFE) begin
            $display("PASS: Bit slicing on packed struct");
            pass_count++;
        end else begin
            $display("FAIL: Bit slicing - [31:28]=0x%01X, [15:0]=0x%04X",
                     raw_cmd[31:28], raw_cmd[15:0]);
            fail_count++;
        end

        // Test 7: Nested packed struct
        frame.tag = 8'hEE;
        frame.cmd = cmd;
        frame.checksum = 8'hFF;

        if (frame.tag == 8'hEE && frame.cmd.opcode == 4'hA && frame.checksum == 8'hFF) begin
            $display("PASS: Nested packed struct");
            pass_count++;
        end else begin
            $display("FAIL: Nested struct - tag=0x%02X, opcode=0x%01X",
                     frame.tag, frame.cmd.opcode);
            fail_count++;
        end

        // Test 8: XOR operation on packed struct
        pkt = 32'hAA5555AA;
        pkt = pkt ^ 32'h55AA55AA;
        if (pkt == 32'hFFFF0000) begin
            $display("PASS: XOR operation on packed struct");
            pass_count++;
        end else begin
            $display("FAIL: XOR - expected 0xFFFF0000, got 0x%08X", pkt);
            fail_count++;
        end

        // Summary
        $display("Packed struct test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All packed struct tests passed");
        $finish;
    end
endmodule
