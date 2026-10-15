/*
:name: test_format_binary
:description: Test: %b/%B format specifiers
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.2 21.2.1.3 21.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_format_binary.expected
*/
// Test: %b/%B format specifiers

module test_format_binary;
    int pass_count = 0;
    int total_tests = 0;

    // Test variables
    logic [7:0] lv8;
    logic [3:0] nibble;
    logic [15:0] lv16;
    logic [31:0] lv32;
    bit [7:0] b8;
    int i;
    string s;

    initial begin
        // Test 1: basic %b
        total_tests++;
        lv8 = 8'b1010_1010;
        $sformat(s, "%b", lv8);
        if (s == "10101010") begin
            pass_count++;
            $display("PASS: basic %%b");
        end else $display("FAIL: basic %%b, got '%s'", s);

        // Test 2: %B (same output)
        total_tests++;
        lv8 = 8'b1100_0011;
        $sformat(s, "%B", lv8);
        if (s == "11000011") begin
            pass_count++;
            $display("PASS: %%B format");
        end else $display("FAIL: %%B, got '%s'", s);

        // Test 3: nibble (4-bit)
        total_tests++;
        nibble = 4'b1001;
        $sformat(s, "%b", nibble);
        if (s == "1001") begin
            pass_count++;
            $display("PASS: nibble binary");
        end else $display("FAIL: nibble, got '%s'", s);

        // Test 4: 16-bit value
        total_tests++;
        lv16 = 16'b1111_0000_1111_0000;
        $sformat(s, "%b", lv16);
        if (s == "1111000011110000") begin
            pass_count++;
            $display("PASS: 16-bit binary");
        end else $display("FAIL: 16-bit, got '%s'", s);

        // Test 5: zero value
        total_tests++;
        lv8 = 8'b0;
        $sformat(s, "%b", lv8);
        if (s == "00000000") begin
            pass_count++;
            $display("PASS: zero binary");
        end else $display("FAIL: zero, got '%s'", s);

        // Test 6: all ones
        total_tests++;
        lv8 = 8'b1111_1111;
        $sformat(s, "%b", lv8);
        if (s == "11111111") begin
            pass_count++;
            $display("PASS: all ones binary");
        end else $display("FAIL: all ones, got '%s'", s);

        // Test 7: x values
        total_tests++;
        lv8 = 8'b10xx_01xx;
        $sformat(s, "%b", lv8);
        if (s == "10xx01xx") begin
            pass_count++;
            $display("PASS: x in binary");
        end else $display("FAIL: x values, got '%s'", s);

        // Test 8: z values
        total_tests++;
        lv8 = 8'b1z1z_0z0z;
        $sformat(s, "%b", lv8);
        if (s == "1z1z0z0z") begin
            pass_count++;
            $display("PASS: z in binary");
        end else $display("FAIL: z values, got '%s'", s);

        // Test 9: mixed x and z
        total_tests++;
        lv8 = 8'b1xz0_xz10;
        $sformat(s, "%b", lv8);
        if (s == "1xz0xz10") begin
            pass_count++;
            $display("PASS: mixed x/z");
        end else $display("FAIL: mixed x/z, got '%s'", s);

        // Test 10: %0b (minimal width)
        total_tests++;
        lv8 = 8'b0000_1111;
        $sformat(s, "%0b", lv8);
        if (s == "1111") begin  // width 0: minimum width, no leading zeros (21.2.1.2)
            pass_count++;
            $display("PASS: %%0b");
        end else $display("FAIL: %%0b, got '%s'", s);

        // Test 11: int as binary
        total_tests++;
        i = 255;
        $sformat(s, "%b", i[7:0]);
        if (s == "11111111") begin
            pass_count++;
            $display("PASS: int slice as binary");
        end else $display("FAIL: int slice, got '%s'", s);

        // Test 12: single bit
        total_tests++;
        lv8 = 8'b1;
        $sformat(s, "%b", lv8[0]);
        if (s == "1") begin
            pass_count++;
            $display("PASS: single bit");
        end else $display("FAIL: single bit, got '%s'", s);

        // Test 13: alternating pattern
        total_tests++;
        lv16 = 16'b0101_0101_0101_0101;
        $sformat(s, "%b", lv16);
        if (s == "0101010101010101") begin
            pass_count++;
            $display("PASS: alternating pattern");
        end else $display("FAIL: alternating, got '%s'", s);

        // Test 14: bit type
        total_tests++;
        b8 = 8'b1001_0110;
        $sformat(s, "%b", b8);
        if (s == "10010110") begin
            pass_count++;
            $display("PASS: bit type binary");
        end else $display("FAIL: bit type, got '%s'", s);

        $display("PASS: format_binary (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
