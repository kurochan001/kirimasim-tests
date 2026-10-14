/*
:name: test_ieee_compliance_dimensions_twostate
:description: Compliance Test - $dimensions and 2-state conversion
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11.2 7.4.1 8 20.7
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_ieee_compliance_dimensions_twostate.expected
*/
// IEEE 1800-2023 Compliance Test - $dimensions and 2-state conversion
// Tests:
//   - IEEE 1800-2023 §20.7: $dimensions should count packed + unpacked dimensions
//   - IEEE 1800-2023 §6.11.2: X/Z to 0 conversion for 2-state types

module test_ieee_compliance_dimensions_twostate;
    int pass_count = 0;
    int fail_count = 0;

    //=========================================================================
    // §20.7: $dimensions - returns total dimensions (packed + unpacked)
    // IEEE 1800-2023 §7.4.1: A vector like logic [7:0] counts as 1 packed dimension
    //=========================================================================
    logic [7:0] arr1d [0:9];           // 1 unpacked + 1 packed = 2
    logic [15:0] arr2d [0:3][0:7];     // 2 unpacked + 1 packed = 3
    logic [31:0] arr3d [0:1][0:2][0:3]; // 3 unpacked + 1 packed = 4

    task test_dimensions();
        // Test $dimensions with 1D unpacked array (1 unpacked + 1 packed)
        if ($dimensions(arr1d) == 2) begin
            $display("PASS: $dimensions(arr1d) = 2");
            pass_count++;
        end else begin
            $display("FAIL: $dimensions(arr1d) = %0d (expected 2)", $dimensions(arr1d));
            fail_count++;
        end

        // Test $dimensions with 2D unpacked array (2 unpacked + 1 packed)
        if ($dimensions(arr2d) == 3) begin
            $display("PASS: $dimensions(arr2d) = 3");
            pass_count++;
        end else begin
            $display("FAIL: $dimensions(arr2d) = %0d (expected 3)", $dimensions(arr2d));
            fail_count++;
        end

        // Test $dimensions with 3D unpacked array (3 unpacked + 1 packed)
        if ($dimensions(arr3d) == 4) begin
            $display("PASS: $dimensions(arr3d) = 4");
            pass_count++;
        end else begin
            $display("FAIL: $dimensions(arr3d) = %0d (expected 4)", $dimensions(arr3d));
            fail_count++;
        end

        // Test $unpacked_dimensions
        if ($unpacked_dimensions(arr1d) == 1) begin
            $display("PASS: $unpacked_dimensions(arr1d) = 1");
            pass_count++;
        end else begin
            $display("FAIL: $unpacked_dimensions(arr1d) = %0d (expected 1)", $unpacked_dimensions(arr1d));
            fail_count++;
        end

        if ($unpacked_dimensions(arr2d) == 2) begin
            $display("PASS: $unpacked_dimensions(arr2d) = 2");
            pass_count++;
        end else begin
            $display("FAIL: $unpacked_dimensions(arr2d) = %0d (expected 2)", $unpacked_dimensions(arr2d));
            fail_count++;
        end

        if ($unpacked_dimensions(arr3d) == 3) begin
            $display("PASS: $unpacked_dimensions(arr3d) = 3");
            pass_count++;
        end else begin
            $display("FAIL: $unpacked_dimensions(arr3d) = %0d (expected 3)", $unpacked_dimensions(arr3d));
            fail_count++;
        end
    endtask

    //=========================================================================
    // §6.11.2: 4-state to 2-state conversion - X and Z become 0
    // IEEE 1800-2023: byte' cast is 8-bit 2-state, correctly converts X/Z to 0
    //=========================================================================
    task test_twostate_conversion();
        static logic [7:0] logic_x = 8'bxxxx_xxxx;
        static logic [7:0] logic_z = 8'bzzzz_zzzz;
        static logic [7:0] logic_mixed = 8'b10xz_01xz;
        bit [7:0] bit_from_x;
        bit [7:0] bit_from_z;
        bit [7:0] bit_from_mixed;

        // IEEE 1800-2023 §6.11.2: byte' cast (8-bit 2-state) converts X/Z to 0
        // Note: bit'() would cast to 1-bit, losing the upper bits
        bit_from_x = byte'(logic_x);
        bit_from_z = byte'(logic_z);
        bit_from_mixed = byte'(logic_mixed);

        // Test all-X conversion
        if (bit_from_x == 8'b0000_0000) begin
            $display("PASS: X to bit conversion = 00000000");
            pass_count++;
        end else begin
            $display("FAIL: X to bit conversion = %b (expected 00000000)", bit_from_x);
            fail_count++;
        end

        // Test all-Z conversion
        if (bit_from_z == 8'b0000_0000) begin
            $display("PASS: Z to bit conversion = 00000000");
            pass_count++;
        end else begin
            $display("FAIL: Z to bit conversion = %b (expected 00000000)", bit_from_z);
            fail_count++;
        end

        // Test mixed value conversion (1,0 preserved, X,Z become 0)
        // 10xz_01xz -> 1000_0100
        if (bit_from_mixed == 8'b1000_0100) begin
            $display("PASS: Mixed X/Z to bit conversion = 10000100");
            pass_count++;
        end else begin
            $display("FAIL: Mixed X/Z to bit conversion = %b (expected 10000100)", bit_from_mixed);
            fail_count++;
        end
    endtask

    //=========================================================================
    // §6.11.2: Single bit 2-state conversion using bit' cast
    // bit'() correctly converts a single 4-state bit to 2-state
    //=========================================================================
    task test_single_bit_conversion();
        static logic single_x = 1'bx;
        static logic single_z = 1'bz;
        bit bit_single_x;
        bit bit_single_z;

        // IEEE 1800-2023 §6.11.2: bit' cast on single bit X/Z
        bit_single_x = bit'(single_x);
        bit_single_z = bit'(single_z);

        if (bit_single_x == 1'b0) begin
            $display("PASS: Single X to bit = 0");
            pass_count++;
        end else begin
            $display("FAIL: Single X to bit = %b (expected 0)", bit_single_x);
            fail_count++;
        end

        if (bit_single_z == 1'b0) begin
            $display("PASS: Single Z to bit = 0");
            pass_count++;
        end else begin
            $display("FAIL: Single Z to bit = %b (expected 0)", bit_single_z);
            fail_count++;
        end
    endtask

    //=========================================================================
    // Main Test Sequence
    //=========================================================================
    initial begin
        $display("=== IEEE 1800-2023 Compliance: $dimensions and 2-state conversion ===");
        $display("");

        $display("--- §20.7 $dimensions Tests ---");
        test_dimensions();

        $display("");
        $display("--- §6.11.2 X/Z to 0 Conversion Tests (byte' cast) ---");
        test_twostate_conversion();

        $display("");
        $display("--- §6.11.2 Single Bit Conversion Tests (bit' cast) ---");
        test_single_bit_conversion();

        // Summary
        $display("");
        $display("=================================");
        $display("IEEE Compliance: %0d passed, %0d failed", pass_count, fail_count);
        $display("=================================");

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
