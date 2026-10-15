/*
:name: test_bits_system
:description: $bits system function variations
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits_system.expected
*/
// $bits system function variations
module test_bits_system;
    logic [7:0] byte_var;
    logic [31:0] word_var;
    logic [63:0] dword_var;
    integer int_var;
    real real_var;
    string str_var;

    typedef struct packed {
        logic [7:0] a;
        logic [15:0] b;
        logic [7:0] c;
    } packed_struct_t;

    packed_struct_t ps;

    logic [3:0][7:0] packed_array;
    logic [7:0] unpacked_array [0:3];

    integer pass_count;

    initial begin
        pass_count = 0;

        // Test 1: $bits of basic types
        if ($bits(byte_var) == 8 && $bits(word_var) == 32 && $bits(dword_var) == 64) begin
            $display("Test 1: $bits basic types - PASS");
            $display("  bits(byte)=%0d, bits(word)=%0d, bits(dword)=%0d",
                     $bits(byte_var), $bits(word_var), $bits(dword_var));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: $bits basic types - FAIL");
        end

        // Test 2: $bits of integer
        if ($bits(int_var) == 32) begin
            $display("Test 2: $bits(integer) = %0d - PASS", $bits(int_var));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2: $bits(integer) - FAIL (got %0d)", $bits(int_var));
        end

        // Test 3: $bits of packed struct
        if ($bits(ps) == 32) begin  // 8 + 16 + 8 = 32
            $display("Test 3: $bits(packed_struct) = %0d - PASS", $bits(ps));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 3: $bits(packed_struct) - FAIL (got %0d)", $bits(ps));
        end

        // Test 4: $bits of packed array
        if ($bits(packed_array) == 32) begin  // 4 * 8 = 32
            $display("Test 4: $bits(packed_array) = %0d - PASS", $bits(packed_array));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 4: $bits(packed_array) - FAIL (got %0d)", $bits(packed_array));
        end

        // Test 5: $bits of type expression
        if ($bits(logic [15:0]) == 16) begin
            $display("Test 5: $bits(logic[15:0]) = %0d - PASS", $bits(logic [15:0]));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 5: $bits(type) - FAIL");
        end

        if (pass_count == 5)
            $display("All bits tests PASS");
        else
            $display("Some tests FAIL: %0d/5 passed", pass_count);

        $finish;
    end
endmodule
