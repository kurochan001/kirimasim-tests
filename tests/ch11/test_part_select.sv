/*
:name: test_part_select
:description: Test: Part select [a:b], [a+:b], [a-:b]
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_part_select.expected
*/
// Test: Part select [a:b], [a+:b], [a-:b]

module test_part_select;
    int pass_count = 0;
    int total_tests = 25;

    // Test variables
    logic [31:0] data32;
    logic [15:0] data16;
    logic [7:0] data8;
    logic [63:0] data64;
    int idx;
    logic [3:0] result4;
    logic [7:0] result8;

    initial begin
        // Test 1: Basic constant part select
        data32 = 32'hABCD_EF01;
        result8 = data32[7:0];
        if (result8 == 8'h01) begin
            $display("Test 1 PASSED: data32[7:0] = 0x01");
            pass_count++;
        end else $display("Test 1 FAILED: data32[7:0] = %h", result8);

        // Test 2: Upper byte select
        result8 = data32[31:24];
        if (result8 == 8'hAB) begin
            $display("Test 2 PASSED: data32[31:24] = 0xAB");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: Middle byte select
        result8 = data32[15:8];
        if (result8 == 8'hEF) begin
            $display("Test 3 PASSED: data32[15:8] = 0xEF");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: Nibble select
        result4 = data32[3:0];
        if (result4 == 4'h1) begin
            $display("Test 4 PASSED: data32[3:0] = 0x1");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Indexed part select ascending (+:)
        data32 = 32'h12345678;
        idx = 0;
        result8 = data32[idx +: 8];
        if (result8 == 8'h78) begin
            $display("Test 5 PASSED: data32[0+:8] = 0x78");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: Indexed part select at byte 1
        idx = 8;
        result8 = data32[idx +: 8];
        if (result8 == 8'h56) begin
            $display("Test 6 PASSED: data32[8+:8] = 0x56");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: Indexed part select at byte 2
        idx = 16;
        result8 = data32[idx +: 8];
        if (result8 == 8'h34) begin
            $display("Test 7 PASSED: data32[16+:8] = 0x34");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: Indexed part select at byte 3
        idx = 24;
        result8 = data32[idx +: 8];
        if (result8 == 8'h12) begin
            $display("Test 8 PASSED: data32[24+:8] = 0x12");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: Descending part select (-:)
        data32 = 32'hAABBCCDD;
        idx = 31;
        result8 = data32[idx -: 8];
        if (result8 == 8'hAA) begin
            $display("Test 9 PASSED: data32[31-:8] = 0xAA");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: Descending part select lower
        idx = 7;
        result8 = data32[idx -: 8];
        if (result8 == 8'hDD) begin
            $display("Test 10 PASSED: data32[7-:8] = 0xDD");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: Part select in expression
        data16 = 16'hAB12;
        if (data16[15:8] + data16[7:0] == 16'hBD) begin
            $display("Test 11 PASSED: data16[15:8] + data16[7:0] = 0xBD");
            pass_count++;
        end else $display("Test 11 FAILED");

        // Test 12: Single bit via part select
        data8 = 8'b10101010;
        if (data8[7:7] == 1'b1) begin
            $display("Test 12 PASSED: data8[7:7] = 1");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: Part select width 4
        data32 = 32'hFEDCBA98;
        result4 = data32[7:4];
        if (result4 == 4'h9) begin
            $display("Test 13 PASSED: data32[7:4] = 0x9");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Variable in ascending select
        data64 = 64'h0123456789ABCDEF;
        idx = 32;
        result8 = data64[idx +: 8];
        if (result8 == 8'h67) begin
            $display("Test 14 PASSED: data64[32+:8] = 0x67");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Part select for write
        data32 = 32'h00000000;
        data32[7:0] = 8'hFF;
        if (data32 == 32'h000000FF) begin
            $display("Test 15 PASSED: data32[7:0] = 0xFF write");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Part select upper byte write
        data32 = 32'h00000000;
        data32[31:24] = 8'hAA;
        if (data32 == 32'hAA000000) begin
            $display("Test 16 PASSED: data32[31:24] = 0xAA write");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: Part select middle write
        data32 = 32'hFFFFFFFF;
        data32[15:8] = 8'h00;
        if (data32 == 32'hFFFF00FF) begin
            $display("Test 17 PASSED: data32[15:8] = 0x00 write");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: Indexed ascending write
        data32 = 32'h00000000;
        idx = 16;
        data32[idx +: 8] = 8'h55;
        if (data32 == 32'h00550000) begin
            $display("Test 18 PASSED: data32[16+:8] = 0x55 write");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: Indexed descending write
        data32 = 32'hFFFFFFFF;
        idx = 23;
        data32[idx -: 8] = 8'h00;
        if (data32 == 32'hFF00FFFF) begin
            $display("Test 19 PASSED: data32[23-:8] = 0x00 write");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Nibble select and compare
        data16 = 16'hA5B6;
        if (data16[15:12] == 4'hA && data16[3:0] == 4'h6) begin
            $display("Test 20 PASSED: nibble select correct");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Part select loop
        data32 = 32'hDEADBEEF;
        begin
            logic [7:0] bytes[4];
            for (int i = 0; i < 4; i++) begin
                bytes[i] = data32[i*8 +: 8];
            end
            if (bytes[0] == 8'hEF && bytes[3] == 8'hDE) begin
                $display("Test 21 PASSED: part select loop");
                pass_count++;
            end else $display("Test 21 FAILED");
        end

        // Test 22: Expression index
        data32 = 32'h12345678;
        idx = 2;
        result8 = data32[(idx*8) +: 8];
        if (result8 == 8'h34) begin
            $display("Test 22 PASSED: data32[(2*8)+:8] = 0x34");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Narrow part select (2 bits)
        data8 = 8'b11001010;
        if (data8[5:4] == 2'b00) begin
            $display("Test 23 PASSED: data8[5:4] = 2'b00");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: Part select chained
        data32 = 32'hCAFEBABE;
        data16 = data32[31:16];
        result8 = data16[7:0];
        if (result8 == 8'hFE) begin
            $display("Test 24 PASSED: chained part select = 0xFE");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: Part select all bits
        data16 = 16'h1234;
        if (data16[15:0] == 16'h1234) begin
            $display("Test 25 PASSED: data16[15:0] = full value");
            pass_count++;
        end else $display("Test 25 FAILED");

        $display("PASS: part_select (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
