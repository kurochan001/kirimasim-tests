/*
:name: test_integer_types
:description: Chapter 6: Data types
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 6.11.1 6.11.2 6.11.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_integer_types.expected
*/
// IEEE 1800-2023 Chapter 6: Data types
// §6.11 Integer data types

module test_integer_types;
    // §6.11.1 Integral types
    bit b;
    logic l;
    reg r;

    // §6.11.2 2-state vs 4-state
    bit [7:0] bit8;
    logic [7:0] logic8;

    // §6.11.3 Signed and unsigned
    byte signed_byte;
    shortint signed_short;
    int signed_int;
    longint signed_long;

    integer int_type;

    int test_count;
    int pass_count;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: bit type (2-state)
        b = 1'b1;
        test_count++;
        if (b == 1) pass_count++;
        else $display("FAIL: bit assignment - b=%0b", b);

        // Test 2: logic type (4-state)
        l = 1'bx;
        test_count++;
        if ($isunknown(l)) pass_count++;
        else $display("FAIL: logic X - l=%0b", l);

        // Test 3: 2-state bit array
        bit8 = 8'hFF;
        test_count++;
        if (bit8 == 255) pass_count++;
        else $display("FAIL: bit8 - value=%0d", bit8);

        // Test 4: byte range (-128 to 127)
        signed_byte = -100;
        test_count++;
        if (signed_byte == -100) pass_count++;
        else $display("FAIL: byte - value=%0d", signed_byte);

        // Test 5: shortint range
        signed_short = -30000;
        test_count++;
        if (signed_short == -30000) pass_count++;
        else $display("FAIL: shortint - value=%0d", signed_short);

        // Test 6: int type
        signed_int = -2000000000;
        test_count++;
        if (signed_int == -2000000000) pass_count++;
        else $display("FAIL: int - value=%0d", signed_int);

        // Test 7: longint type
        signed_long = 64'h7FFFFFFFFFFFFFFF;
        test_count++;
        if (signed_long == 64'sh7FFFFFFFFFFFFFFF) pass_count++;
        else $display("FAIL: longint - value=%0d", signed_long);

        // Test 8: integer type (4-state)
        int_type = 32'hxxxxxxxx;
        test_count++;
        if ($isunknown(int_type)) pass_count++;
        else $display("FAIL: integer X - value=%0h", int_type);

        $display("Chapter 6.11 Integer Types: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
