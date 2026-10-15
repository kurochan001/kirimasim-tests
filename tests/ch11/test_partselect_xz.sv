/*
:name: test_partselect_xz
:description: Indexed part-selects in range, partly or fully out of range, and with x or z indexes
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 9.2.2.2 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_partselect_xz.expected
*/
// test_partselect_xz.sv
// IEEE 1800-2023 §11.5.1 Vector bit-select and part-select addressing

module test_partselect_xz;
    int pass_count = 0;
    int test_count = 17;

    logic [31:0] data;
    logic [31:0] idx;
    logic [7:0]  slice;
    logic [31:0] result32;
    logic [3:0]  result4;
    logic [0:0]  result1;

    // For T13
    logic [7:0] comb_out;
    logic [4:0] comb_idx;

    // For T15
    logic [31:0] arr [3:0];
    int i;

    always_comb begin
        comb_out = data[comb_idx+:8];
    end

    initial begin
        // T0: data[7:0] normal part-select (baseline)
        data = 32'hDEADBEEF;
        slice = data[7:0];
        if (slice == 8'hEF) begin
            $display("T0: PASS - data[7:0] == 0x%02x", slice);
            pass_count++;
        end else begin
            $display("T0: FAIL - data[7:0] == 0x%02x, expected 0xEF", slice);
        end
        #1;

        // T1: data[idx+:8] where idx=0 — normal ascending part-select
        data = 32'hDEADBEEF;
        idx = 0;
        slice = data[idx+:8];
        if (slice == 8'hEF) begin
            $display("T1: PASS - data[0+:8] == 0x%02x", slice);
            pass_count++;
        end else begin
            $display("T1: FAIL - data[0+:8] == 0x%02x, expected 0xEF", slice);
        end
        #1;

        // T2: data[idx+:8] where idx=24 — upper range
        data = 32'hDEADBEEF;
        idx = 24;
        slice = data[idx+:8];
        if (slice == 8'hDE) begin
            $display("T2: PASS - data[24+:8] == 0x%02x", slice);
            pass_count++;
        end else begin
            $display("T2: FAIL - data[24+:8] == 0x%02x, expected 0xDE", slice);
        end
        #1;

        // T3: data[idx+:8] where idx=28 — partial out-of-bounds
        // Bits 28-31 are valid (4 bits), bits 32-35 are out of range → X
        data = 32'hF0000000;
        idx = 28;
        slice = data[idx+:8];
        // Upper 4 bits should be X, lower 4 bits should be 0xF
        if (slice[3:0] == 4'hF && $isunknown(slice[7:4])) begin
            $display("T3: PASS - data[28+:8] partially OOB: lower=0x%01x, upper has X", slice[3:0]);
            pass_count++;
        end else begin
            $display("T3: FAIL - data[28+:8] == 0x%02x (binary: %08b)", slice, slice);
        end
        #1;

        // T4: data[idx+:8] where idx=32 — fully out-of-bounds
        data = 32'hFFFFFFFF;
        idx = 32;
        slice = data[idx+:8];
        // Out-of-range bits read as x (11.5.1)
        if (slice === 8'hxx) begin
            $display("T4: PASS - data[32+:8] fully OOB: 0x%02x ($isunknown=%0b)", slice, $isunknown(slice));
            pass_count++;
        end else begin
            $display("T4: FAIL - data[32+:8] == 0x%02x, expected X or 0", slice);
        end
        #1;

        // T5: data[idx+:8] where idx='x — X index → result should be X
        data = 32'hFFFFFFFF;
        idx = 32'hxxxxxxxx;
        slice = data[idx+:8];
        if ($isunknown(slice)) begin
            $display("T5: PASS - data[x+:8] == X (isunknown=1)");
            pass_count++;
        end else begin
            $display("T5: FAIL - data[x+:8] == 0x%02x, expected X", slice);
        end
        #1;

        // T6: data[idx-:8] where idx=7 — descending normal
        data = 32'hDEADBEEF;
        idx = 7;
        slice = data[idx-:8];
        if (slice == 8'hEF) begin
            $display("T6: PASS - data[7-:8] == 0x%02x", slice);
            pass_count++;
        end else begin
            $display("T6: FAIL - data[7-:8] == 0x%02x, expected 0xEF", slice);
        end
        #1;

        // T7: data[idx-:8] where idx has Z bits — result should be X
        data = 32'hFFFFFFFF;
        idx = 32'hzzzzzzzz;
        slice = data[idx-:8];
        if ($isunknown(slice)) begin
            $display("T7: PASS - data[z-:8] == X (isunknown=1)");
            pass_count++;
        end else begin
            $display("T7: FAIL - data[z-:8] == 0x%02x, expected X", slice);
        end
        #1;

        // T8: signed negative index: logic signed [3:0] sidx = -1; data[sidx+:4]
        begin
            logic signed [3:0] sidx;
            sidx = -1;  // 4'b1111 signed = -1
            data = 32'hFFFFFFFF;
            result4 = data[sidx+:4];
            // Negative index is out of range → X or 0
            if (result4 === 4'b111x) begin  // bit -1 is out of range (11.5.1)
                $display("T8: PASS - data[signed(-1)+:4] OOB handled: %04b ($isunknown=%0b)", result4, $isunknown(result4));
                pass_count++;
            end else begin
                $display("T8: FAIL - data[signed(-1)+:4] == %04b", result4);
            end
        end
        #1;

        // T9: part-select width == full width: data[0+:32] == data
        data = 32'hCAFEBABE;
        result32 = data[0+:32];
        if (result32 == 32'hCAFEBABE) begin
            $display("T9: PASS - data[0+:32] == 0x%08x", result32);
            pass_count++;
        end else begin
            $display("T9: FAIL - data[0+:32] == 0x%08x, expected 0xCAFEBABE", result32);
        end
        #1;

        // T10: part-select width == 1: data[0+:1] == data[0]
        data = 32'hCAFEBABE;  // bit 0 = 0
        result1 = data[0+:1];
        if (result1 == data[0]) begin
            $display("T10: PASS - data[0+:1] == %0b (same as data[0])", result1);
            pass_count++;
        end else begin
            $display("T10: FAIL - data[0+:1] == %0b, data[0] == %0b", result1, data[0]);
        end
        #1;

        // T11: chained: logic [31:0] d; d[16+:8] read
        begin
            logic [31:0] d;
            logic [7:0] mid_byte;
            d = 32'h11223344;
            mid_byte = d[16+:8];  // bits 23:16 = 0x22
            if (mid_byte == 8'h22) begin
                $display("T11: PASS - d[16+:8] == 0x%02x", mid_byte);
                pass_count++;
            end else begin
                $display("T11: FAIL - d[16+:8] == 0x%02x, expected 0x22", mid_byte);
            end
        end
        #1;

        // T12: part-select on RHS: b = data[idx+:8]
        data = 32'hAABBCCDD;
        idx = 8;
        begin
            logic [7:0] b_val;
            b_val = data[idx+:8];  // bits 15:8 = 0xCC
            if (b_val == 8'hCC) begin
                $display("T12: PASS - RHS part-select data[8+:8] == 0x%02x", b_val);
                pass_count++;
            end else begin
                $display("T12: FAIL - RHS part-select data[8+:8] == 0x%02x, expected 0xCC", b_val);
            end
        end
        #1;

        // T13: part-select in always_comb output
        data = 32'h99887766;
        comb_idx = 16;
        #1;  // Let always_comb propagate
        if (comb_out == 8'h88) begin
            $display("T13: PASS - always_comb data[16+:8] == 0x%02x", comb_out);
            pass_count++;
        end else begin
            $display("T13: FAIL - always_comb data[16+:8] == 0x%02x, expected 0x88", comb_out);
        end
        #1;

        // T14: dynamic index + NBA: data[idx+:8] <= val
        data = 32'h00000000;
        idx = 8;
        data[idx+:8] <= 8'hFF;
        #1;  // Wait for NBA
        if (data[15:8] == 8'hFF) begin
            $display("T14: PASS - NBA data[8+:8] <= FF → data == 0x%08x", data);
            pass_count++;
        end else begin
            $display("T14: FAIL - NBA data[8+:8] <= FF → data == 0x%08x, expected 0x0000FF00", data);
        end
        #1;

        // T15: part-select on array element: arr[i][8+:8]
        arr[0] = 32'hAABBCCDD;
        arr[1] = 32'h11223344;
        arr[2] = 32'h55667788;
        arr[3] = 32'h99AABBCC;
        i = 2;
        slice = arr[i][8+:8];  // arr[2] bits 15:8 = 0x77
        if (slice == 8'h77) begin
            $display("T15: PASS - arr[2][8+:8] == 0x%02x", slice);
            pass_count++;
        end else begin
            $display("T15: FAIL - arr[2][8+:8] == 0x%02x, expected 0x77", slice);
        end
        #1;

        // T16: descending part-select: data[idx-:8] where idx=31 → bits 31:24
        data = 32'hDEADBEEF;
        idx = 31;
        slice = data[idx-:8];
        if (slice == 8'hDE) begin
            $display("T16: PASS - data[31-:8] == 0x%02x", slice);
            pass_count++;
        end else begin
            $display("T16: FAIL - data[31-:8] == 0x%02x, expected 0xDE", slice);
        end

        #1;
        if (pass_count == test_count)
            $display("TEST PASSED (%0d/%0d)", pass_count, test_count);
        else
            $display("TEST FAILED (%0d/%0d)", pass_count, test_count);
        $finish;
    end
endmodule
