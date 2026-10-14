/*
:name: test_format_octal
:description: Test: %o/%O format specifiers
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.2 21.2.1.3 21.3.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_format_octal.expected
*/
// Test: %o/%O format specifiers

module test_format_octal;
    int pass_count = 0;
    int total_tests = 0;

    // Test variables
    logic [8:0] lv9;      // 3 octal digits
    logic [11:0] lv12;    // 4 octal digits
    logic [23:0] lv24;    // 8 octal digits
    logic [2:0] lv3;      // 1 octal digit
    bit [8:0] b9;
    int i;
    string s;

    initial begin
        // Test 1: basic %o
        total_tests++;
        lv9 = 9'o777;
        $sformat(s, "%o", lv9);
        if (s == "777") begin
            pass_count++;
            $display("PASS: basic %%o");
        end else $display("FAIL: basic %%o, got '%s'", s);

        // Test 2: %O (same as %o)
        total_tests++;
        lv9 = 9'o123;
        $sformat(s, "%O", lv9);
        if (s == "123") begin
            pass_count++;
            $display("PASS: %%O format");
        end else $display("FAIL: %%O, got '%s'", s);

        // Test 3: single octal digit
        total_tests++;
        lv3 = 3'o7;
        $sformat(s, "%o", lv3);
        if (s == "7") begin
            pass_count++;
            $display("PASS: single octal digit");
        end else $display("FAIL: single digit, got '%s'", s);

        // Test 4: 12-bit value
        total_tests++;
        lv12 = 12'o7654;
        $sformat(s, "%o", lv12);
        if (s == "7654") begin
            pass_count++;
            $display("PASS: 12-bit octal");
        end else $display("FAIL: 12-bit, got '%s'", s);

        // Test 5: 24-bit value
        total_tests++;
        lv24 = 24'o77777777;
        $sformat(s, "%o", lv24);
        if (s == "77777777") begin
            pass_count++;
            $display("PASS: 24-bit octal");
        end else $display("FAIL: 24-bit, got '%s'", s);

        // Test 6: zero value
        total_tests++;
        lv9 = 9'o0;
        $sformat(s, "%o", lv9);
        if (s == "000") begin
            pass_count++;
            $display("PASS: zero octal");
        end else $display("FAIL: zero, got '%s'", s);

        // Test 7: all ones (9 bits = 511 decimal = 777 octal)
        total_tests++;
        lv9 = 9'b111111111;
        $sformat(s, "%o", lv9);
        if (s == "777") begin
            pass_count++;
            $display("PASS: all ones octal");
        end else $display("FAIL: all ones, got '%s'", s);

        // Test 8: x values in octal
        total_tests++;
        lv9 = 9'bxxx_xxx_xxx;
        $sformat(s, "%o", lv9);
        if (s == "xxx") begin  // all bits of each digit are x (21.2.1.3)
            pass_count++;
            $display("PASS: x in octal");
        end else $display("FAIL: x values, got '%s'", s);

        // Test 9: z values in octal
        total_tests++;
        lv9 = 9'bzzz_zzz_zzz;
        $sformat(s, "%o", lv9);
        if (s == "zzz") begin
            pass_count++;
            $display("PASS: z in octal");
        end else $display("FAIL: z values, got '%s'", s);

        // Test 10: partial x in octal digit
        total_tests++;
        lv9 = 9'b111_xxx_000;
        $sformat(s, "%o", lv9);
        // All three bits of the middle digit are x, so it prints as lowercase x
        if (s == "7x0") begin
            pass_count++;
            $display("PASS: partial x in octal");
        end else $display("FAIL: partial x, got '%s'", s);

        // Test 11: int as octal
        total_tests++;
        i = 8'o77;
        $sformat(s, "%o", i[8:0]);
        if (s == "077") begin
            pass_count++;
            $display("PASS: int slice as octal");
        end else $display("FAIL: int slice, got '%s'", s);

        // Test 12: bit type
        total_tests++;
        b9 = 9'o456;
        $sformat(s, "%o", b9);
        if (s == "456") begin
            pass_count++;
            $display("PASS: bit type octal");
        end else $display("FAIL: bit type, got '%s'", s);

        // Test 13: octal 0-7 values
        total_tests++;
        lv3 = 3'o0;
        $sformat(s, "%o", lv3);
        if (s == "0") begin
            lv3 = 3'o7;
            $sformat(s, "%o", lv3);
            if (s == "7") begin
                pass_count++;
                $display("PASS: octal 0-7");
            end else $display("FAIL: octal 7, got '%s'", s);
        end else $display("FAIL: octal 0, got '%s'", s);

        // Test 14: %0o (minimal width)
        total_tests++;
        lv9 = 9'o007;
        $sformat(s, "%0o", lv9);
        if (s == "7") begin  // width 0: minimum width (21.2.1.2)
            pass_count++;
            $display("PASS: %%0o");
        end else $display("FAIL: %%0o, got '%s'", s);

        $display("PASS: format_octal (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
