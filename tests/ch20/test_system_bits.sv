/*
:name: test_system_bits
:description: $bits - bit width query
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_bits.expected
*/
// $bits - bit width query
module test_bits;
    logic [7:0] byte_val;
    logic [31:0] word_val;
    logic [63:0] dword_val;
    int int_val;
    shortint short_val;
    longint long_val;
    real real_val;

    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
        logic [15:0] c;
    } my_struct_t;
    my_struct_t struct_val;

    logic [3:0][7:0] packed_array;

    int bits_count;

    initial begin
        // Test 1: 8-bit logic
        bits_count = $bits(byte_val);
        if (bits_count == 8)
            $display("PASS: $bits(logic[7:0]) = %0d", bits_count);
        else
            $display("FAIL: $bits(logic[7:0]) = %0d, expected 8", bits_count);

        // Test 2: 32-bit int
        bits_count = $bits(int_val);
        if (bits_count == 32)
            $display("PASS: $bits(int) = %0d", bits_count);
        else
            $display("FAIL: $bits(int) = %0d, expected 32", bits_count);

        // Test 3: 64-bit longint
        bits_count = $bits(long_val);
        if (bits_count == 64)
            $display("PASS: $bits(longint) = %0d", bits_count);
        else
            $display("FAIL: $bits(longint) = %0d, expected 64", bits_count);

        // Test 4: Packed struct (8+8+16 = 32 bits)
        bits_count = $bits(struct_val);
        if (bits_count == 32)
            $display("PASS: $bits(packed struct) = %0d", bits_count);
        else
            $display("FAIL: $bits(packed struct) = %0d, expected 32", bits_count);

        // Test 5: Packed array (4*8 = 32 bits)
        bits_count = $bits(packed_array);
        if (bits_count == 32)
            $display("PASS: $bits(logic[3:0][7:0]) = %0d", bits_count);
        else
            $display("FAIL: $bits(logic[3:0][7:0]) = %0d, expected 32", bits_count);

        $finish;
    end
endmodule
