/*
:name: test_bits_2
:description: $bits system function test
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2 6.24.3
:oracle: spec iverilog@13.0 verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits_2.expected
*/
// IEEE 1800-2023 §20.6: $bits system function test
// Tests bit width query for various data types

module test_bits_2;
    // Test data types
    logic [7:0] byte_val;
    logic [31:0] word_val;
    logic [63:0] dword_val;
    logic [127:0] qword_val;
    int int_val;
    string str_val;
    bit single_bit;

    // Packed array
    logic [3:0][7:0] packed_arr;

    // Struct
    typedef struct packed {
        logic [7:0] a;
        logic [15:0] b;
    } my_struct_t;
    my_struct_t my_struct;

    int pass_count;
    int fail_count;

    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("=== IEEE 1800-2023 §20.6 $bits Test ===");

        // Test 1: 8-bit logic
        if ($bits(byte_val) == 8) begin
            $display("Test 1 PASS: $bits(logic[7:0]) = %0d", $bits(byte_val));
            pass_count++;
        end else begin
            $display("Test 1 FAIL: Expected 8, got %0d", $bits(byte_val));
            fail_count++;
        end

        // Test 2: 32-bit logic
        if ($bits(word_val) == 32) begin
            $display("Test 2 PASS: $bits(logic[31:0]) = %0d", $bits(word_val));
            pass_count++;
        end else begin
            $display("Test 2 FAIL: Expected 32, got %0d", $bits(word_val));
            fail_count++;
        end

        // Test 3: 64-bit logic
        if ($bits(dword_val) == 64) begin
            $display("Test 3 PASS: $bits(logic[63:0]) = %0d", $bits(dword_val));
            pass_count++;
        end else begin
            $display("Test 3 FAIL: Expected 64, got %0d", $bits(dword_val));
            fail_count++;
        end

        // Test 4: 128-bit logic
        if ($bits(qword_val) == 128) begin
            $display("Test 4 PASS: $bits(logic[127:0]) = %0d", $bits(qword_val));
            pass_count++;
        end else begin
            $display("Test 4 FAIL: Expected 128, got %0d", $bits(qword_val));
            fail_count++;
        end

        // Test 5: int type (32 bits)
        if ($bits(int_val) == 32) begin
            $display("Test 5 PASS: $bits(int) = %0d", $bits(int_val));
            pass_count++;
        end else begin
            $display("Test 5 FAIL: Expected 32, got %0d", $bits(int_val));
            fail_count++;
        end

        // real is not a bit-stream type, so $bits does not apply to it (6.24.3).

        // Test 7: single bit
        if ($bits(single_bit) == 1) begin
            $display("Test 7 PASS: $bits(bit) = %0d", $bits(single_bit));
            pass_count++;
        end else begin
            $display("Test 7 FAIL: Expected 1, got %0d", $bits(single_bit));
            fail_count++;
        end

        // Test 8: packed array (4*8 = 32 bits)
        if ($bits(packed_arr) == 32) begin
            $display("Test 8 PASS: $bits(logic[3:0][7:0]) = %0d", $bits(packed_arr));
            pass_count++;
        end else begin
            $display("Test 8 FAIL: Expected 32, got %0d", $bits(packed_arr));
            fail_count++;
        end

        // Test 9: packed struct (8 + 16 = 24 bits)
        if ($bits(my_struct) == 24) begin
            $display("Test 9 PASS: $bits(packed struct) = %0d", $bits(my_struct));
            pass_count++;
        end else begin
            $display("Test 9 FAIL: Expected 24, got %0d", $bits(my_struct));
            fail_count++;
        end

        // Summary
        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end
endmodule
