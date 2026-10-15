/*
:name: test_value_ops_edge_cases
:description: Targets: X/Z handling, signed/unsigned conversions, bit operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8 11.4.10 11.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_value_ops_edge_cases.expected
*/
// Checks X/Z handling, signed/unsigned conversions and bit operations

module test_value_ops_edge_cases;
    int pass_count = 0;
    int fail_count = 0;

    // Variables for tests
    logic [7:0] val_x;
    logic [7:0] val_z;
    logic [7:0] val_mixed;
    logic signed [7:0] signed_val;
    logic [7:0] unsigned_val;
    logic signed [15:0] extended;
    logic [7:0] small_val;
    logic [15:0] large_val;
    logic [3:0] a4, b4, result4;
    logic [7:0] val8;
    logic [31:0] data32;
    logic [7:0] byte_sel;
    logic [11:0] d12;
    logic [15:0] e16;
    int idx;

    initial begin
        $display("=== Value Ops Edge Cases Test ===");

        // Test X/Z value handling
        $display("\n--- X/Z Value Handling ---");
        val_x = 8'bxxxx_xxxx;
        val_z = 8'bzzzz_zzzz;
        val_mixed = 8'b10xz_10xz;

        if (val_x === 8'bxxxx_xxxx) begin
            $display("PASS: X value case equality");
            pass_count++;
        end else begin
            $display("FAIL: X value case equality");
            fail_count++;
        end

        if (val_z === 8'bzzzz_zzzz) begin
            $display("PASS: Z value case equality");
            pass_count++;
        end else begin
            $display("FAIL: Z value case equality");
            fail_count++;
        end

        // Test signed/unsigned conversion
        $display("\n--- Signed/Unsigned Conversion ---");
        signed_val = -1;
        unsigned_val = signed_val;
        if (unsigned_val == 8'hFF) begin
            $display("PASS: signed to unsigned conversion");
            pass_count++;
        end else begin
            $display("FAIL: signed to unsigned = %h", unsigned_val);
            fail_count++;
        end

        // Sign extension
        extended = signed'(signed_val);
        if (extended == 16'hFFFF) begin
            $display("PASS: sign extension");
            pass_count++;
        end else begin
            $display("FAIL: sign extension = %h", extended);
            fail_count++;
        end

        // Test zero extension
        $display("\n--- Zero Extension ---");
        small_val = 8'hAB;
        large_val = small_val;
        if (large_val == 16'h00AB) begin
            $display("PASS: zero extension");
            pass_count++;
        end else begin
            $display("FAIL: zero extension = %h", large_val);
            fail_count++;
        end

        // Test truncation
        $display("\n--- Truncation ---");
        large_val = 16'hCAFE;
        small_val = large_val[7:0];
        if (small_val == 8'hFE) begin
            $display("PASS: truncation");
            pass_count++;
        end else begin
            $display("FAIL: truncation = %h", small_val);
            fail_count++;
        end

        // Test bitwise operations with X/Z
        $display("\n--- Bitwise with X/Z ---");
        a4 = 4'b1010;
        b4 = 4'b11xx;

        // AND with X (11.4.8): 1&x is x, and 0&x is 0
        result4 = a4 & b4;
        if (result4 === 4'b10x0) begin
            $display("PASS: AND with X");
            pass_count++;
        end else begin
            $display("FAIL: AND with X = %b", result4);
            fail_count++;
        end

        // OR with X: 1|X=1, 0|X=X
        // IEEE 1800-2023 §11.4.8: 1010 | 11xx = 111x
        // bit3: 1|1=1, bit2: 0|1=1, bit1: 1|x=1, bit0: 0|x=x
        result4 = a4 | b4;
        if (result4 === 4'b111x) begin
            $display("PASS: OR with X");
            pass_count++;
        end else begin
            $display("FAIL: OR with X = %b", result4);
            fail_count++;
        end

        // Test reduction operators
        $display("\n--- Reduction Operators ---");
        val8 = 8'b10101010;

        if ((&val8) == 0) begin
            $display("PASS: reduction AND");
            pass_count++;
        end else begin
            $display("FAIL: reduction AND");
            fail_count++;
        end

        if ((|val8) == 1) begin
            $display("PASS: reduction OR");
            pass_count++;
        end else begin
            $display("FAIL: reduction OR");
            fail_count++;
        end

        if ((^val8) == 0) begin
            $display("PASS: reduction XOR");
            pass_count++;
        end else begin
            $display("FAIL: reduction XOR");
            fail_count++;
        end

        // Test part select edge cases
        $display("\n--- Part Select Edge Cases ---");
        data32 = 32'hDEAD_BEEF;

        byte_sel = data32[7:0];
        if (byte_sel == 8'hEF) begin
            $display("PASS: LSB part select");
            pass_count++;
        end else begin
            $display("FAIL: LSB part select = %h", byte_sel);
            fail_count++;
        end

        byte_sel = data32[31:24];
        if (byte_sel == 8'hDE) begin
            $display("PASS: MSB part select");
            pass_count++;
        end else begin
            $display("FAIL: MSB part select = %h", byte_sel);
            fail_count++;
        end

        // Variable part select
        idx = 8;
        byte_sel = data32[idx +: 8];
        if (byte_sel == 8'hBE) begin
            $display("PASS: variable part select");
            pass_count++;
        end else begin
            $display("FAIL: variable part select = %h", byte_sel);
            fail_count++;
        end

        // Test shift operations with different amounts
        $display("\n--- Shift Operations ---");
        val8 = 8'h01;

        if ((val8 << 7) == 8'h80) begin
            $display("PASS: left shift max");
            pass_count++;
        end else begin
            $display("FAIL: left shift max");
            fail_count++;
        end

        if ((val8 << 8) == 8'h00) begin
            $display("PASS: left shift overflow");
            pass_count++;
        end else begin
            $display("FAIL: left shift overflow");
            fail_count++;
        end

        val8 = 8'h80;
        if ((val8 >> 7) == 8'h01) begin
            $display("PASS: right shift max");
            pass_count++;
        end else begin
            $display("FAIL: right shift max");
            fail_count++;
        end

        // IEEE 1800-2023 §11.4.10 / §11.8.2: keep the comparison signed for sign fill.
        signed_val = 8'h80;
        if ((signed_val >>> 4) == 8'shF8) begin
            $display("PASS: arithmetic right shift");
            pass_count++;
        end else begin
            $display("FAIL: arithmetic right shift = %h", signed_val >>> 4);
            fail_count++;
        end

        // An unsigned comparison operand makes the shift expression unsigned.
        if ((signed_val >>> 4) == 8'h08) begin
            $display("PASS: right shift in unsigned comparison context");
            pass_count++;
        end else begin
            $display("FAIL: right shift in unsigned comparison context");
            fail_count++;
        end

        // Test concatenation edge cases
        $display("\n--- Concatenation Edge Cases ---");
        a4 = 4'hA;
        b4 = 4'hB;

        val8 = {a4, b4};
        if (val8 == 8'hAB) begin
            $display("PASS: basic concatenation");
            pass_count++;
        end else begin
            $display("FAIL: basic concatenation = %h", val8);
            fail_count++;
        end

        // Triple concatenation - use variable to ensure size
        result4 = 4'hC;
        d12 = {a4, b4, result4};
        if (d12 == 12'hABC) begin
            $display("PASS: triple concatenation");
            pass_count++;
        end else begin
            $display("FAIL: triple concatenation = %h", d12);
            fail_count++;
        end

        // Replication
        e16 = {4{a4}};
        if (e16 == 16'hAAAA) begin
            $display("PASS: replication");
            pass_count++;
        end else begin
            $display("FAIL: replication = %h", e16);
            fail_count++;
        end

        // Test $bits
        $display("\n--- Size Functions ---");
        if ($bits(val8) == 8) begin
            $display("PASS: $bits byte");
            pass_count++;
        end else begin
            $display("FAIL: $bits byte = %0d", $bits(val8));
            fail_count++;
        end

        if ($bits(large_val) == 16) begin
            $display("PASS: $bits word");
            pass_count++;
        end else begin
            $display("FAIL: $bits word = %0d", $bits(large_val));
            fail_count++;
        end

        $display("");
        $display("=== Summary: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $fatal(1, "TEST FAILED");
        $finish;
    end
endmodule
