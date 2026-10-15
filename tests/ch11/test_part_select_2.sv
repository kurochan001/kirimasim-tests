/*
:name: test_part_select_2
:description: Constant and indexed part-selects and bit-selects of a 32-bit vector
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_part_select_2.expected
*/
// IEEE 1800-2023 Part Select (§11.5.1)
// Tests constant and indexed part select

module test_part_select;
    initial begin
        logic [31:0] data;
        logic [7:0] byte_val;
        int idx;
        static int pass_count = 0;
        static int fail_count = 0;

        data = 32'h12345678;

        // Test 1: Constant part select
        byte_val = data[7:0];
        if (byte_val == 8'h78) begin
            $display("PASS: data[7:0] = 0x%02X", byte_val);
            pass_count++;
        end else begin
            $display("FAIL: data[7:0] = 0x%02X, expected 0x78", byte_val);
            fail_count++;
        end

        byte_val = data[31:24];
        if (byte_val == 8'h12) begin
            $display("PASS: data[31:24] = 0x%02X", byte_val);
            pass_count++;
        end else begin
            $display("FAIL: data[31:24] = 0x%02X, expected 0x12", byte_val);
            fail_count++;
        end

        // Test 2: Indexed part select +:
        idx = 8;
        byte_val = data[idx +: 8];
        if (byte_val == 8'h56) begin
            $display("PASS: data[8 +: 8] = 0x%02X", byte_val);
            pass_count++;
        end else begin
            $display("FAIL: data[8 +: 8] = 0x%02X, expected 0x56", byte_val);
            fail_count++;
        end

        idx = 16;
        byte_val = data[idx +: 8];
        if (byte_val == 8'h34) begin
            $display("PASS: data[16 +: 8] = 0x%02X", byte_val);
            pass_count++;
        end else begin
            $display("FAIL: data[16 +: 8] = 0x%02X, expected 0x34", byte_val);
            fail_count++;
        end

        // Test 3: Indexed part select -:
        idx = 15;
        byte_val = data[idx -: 8];
        if (byte_val == 8'h56) begin
            $display("PASS: data[15 -: 8] = 0x%02X", byte_val);
            pass_count++;
        end else begin
            $display("FAIL: data[15 -: 8] = 0x%02X, expected 0x56", byte_val);
            fail_count++;
        end

        // Test 4: Single bit select
        if (data[0] == 1'b0) begin
            $display("PASS: data[0] = %b", data[0]);
            pass_count++;
        end else begin
            $display("FAIL: data[0] = %b, expected 0", data[0]);
            fail_count++;
        end

        // Test 5: Variable bit select
        idx = 4;
        if (data[idx] == 1'b1) begin
            $display("PASS: data[4] = %b", data[idx]);
            pass_count++;
        end else begin
            $display("FAIL: data[4] = %b, expected 1", data[idx]);
            fail_count++;
        end

        $display("");
        $display("=== Part Select Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
