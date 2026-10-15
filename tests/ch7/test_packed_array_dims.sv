/*
:name: test_packed_array_dims
:description: Packed array dimension index access test
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 7.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_array_dims.expected
*/
// IEEE 1800-2023 §7.4: Packed array dimension index access test
// Tests read/write access to packed union members with multi-dimensional packed arrays
module test;
    // Packed union with multi-dimensional packed array member
    typedef union packed {
        logic [31:0] word;
        logic [3:0][7:0] bytes;  // 4 bytes, each 8 bits
    } u_t;

    u_t data;
    int test_count = 0;
    int pass_count = 0;

    task check(input string name, input logic [31:0] actual, input logic [31:0] expected);
        test_count++;
        if (actual === expected) begin
            $display("PASS: %s = %h (expected %h)", name, actual, expected);
            pass_count++;
        end else begin
            $display("FAIL: %s = %h (expected %h)", name, actual, expected);
        end
    endtask

    initial begin
        $display("=== IEEE 1800-2023 §7.4 Packed Array Dimension Index Access Tests ===");

        // Test 1: Read packed array elements from union
        $display("\n--- Test 1: Read packed array elements ---");
        data.word = 32'hDEADBEEF;
        check("data.bytes[0]", data.bytes[0], 8'hEF);
        check("data.bytes[1]", data.bytes[1], 8'hBE);
        check("data.bytes[2]", data.bytes[2], 8'hAD);
        check("data.bytes[3]", data.bytes[3], 8'hDE);

        // Test 2: Write to packed array elements
        $display("\n--- Test 2: Write to packed array elements ---");
        data.word = 32'h00000000;
        data.bytes[0] = 8'hAA;
        check("data.word after bytes[0]=AA", data.word, 32'h000000AA);

        data.bytes[1] = 8'hBB;
        check("data.word after bytes[1]=BB", data.word, 32'h0000BBAA);

        data.bytes[2] = 8'hCC;
        check("data.word after bytes[2]=CC", data.word, 32'h00CCBBAA);

        data.bytes[3] = 8'hDD;
        check("data.word after bytes[3]=DD", data.word, 32'hDDCCBBAA);

        // Test 3: Overwrite specific byte
        $display("\n--- Test 3: Overwrite specific byte ---");
        data.word = 32'hDEADBEEF;
        data.bytes[0] = 8'h00;
        check("data.word after bytes[0]=00", data.word, 32'hDEADBE00);

        // Test 4: Read back after write
        $display("\n--- Test 4: Read back after write ---");
        data.word = 32'h12345678;
        data.bytes[2] = 8'hFF;
        check("data.bytes[0] unchanged", data.bytes[0], 8'h78);
        check("data.bytes[1] unchanged", data.bytes[1], 8'h56);
        check("data.bytes[2] modified", data.bytes[2], 8'hFF);
        check("data.bytes[3] unchanged", data.bytes[3], 8'h12);

        // Summary
        $display("\n=== Test Summary ===");
        $display("Passed: %0d / %0d", pass_count, test_count);
        if (pass_count == test_count)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
    end
endmodule
