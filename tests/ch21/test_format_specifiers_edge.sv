/*
:name: test_format_specifiers_edge
:description: Format specifiers in $sformatf: %d, %h, %b, %o, %s, %f, %e, %c, %m and %%
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.2.1.2 21.2.1.5 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_specifiers_edge.expected
*/
// IEEE 1800-2023 Section 21.2: Display system tasks
module test_format_specifiers_edge;
    int pass_count = 0;
    int test_count = 16;

    initial begin
        // T1: %0d minimal width
        begin
            static string s = $sformatf("%0d", 42);
            if (s == "42") begin
                $display("T1: PASS - %%0d: '%s'", s);
                pass_count++;
            end else $display("T1: FAIL - '%s' expected '42'", s);
        end

        // T2: %10d right-justified width
        begin
            static string s = $sformatf("%10d", 42);
            if (s.len() == 10) begin
                $display("T2: PASS - %%10d: '%s' len=%0d", s, s.len());
                pass_count++;
            end else $display("T2: FAIL - '%s' len=%0d expected 10", s, s.len());
        end

        // T3: %h hex uppercase detection
        begin
            static string s = $sformatf("%h", 255);
            if (s.len() > 0) begin
                $display("T3: PASS - %%h: '%s'", s);
                pass_count++;
            end else $display("T3: FAIL - empty");
        end

        // T4: %b binary format
        begin
            static string s = $sformatf("%b", 8'b10101010);
            if (s == "10101010") begin
                $display("T4: PASS - %%b: '%s'", s);
                pass_count++;
            end else $display("T4: FAIL - '%s' expected '10101010'", s);
        end

        // T5: %o octal format
        begin
            static string s = $sformatf("%o", 8'o377);
            if (s == "377") begin
                $display("T5: PASS - %%o: '%s'", s);
                pass_count++;
            end else $display("T5: FAIL - '%s' expected '377'", s);
        end

        // T6: %s string format
        begin
            static string name = "hello";
            static string s;
            // Assigned here so the result does not depend on the order of static initializers.
            s = $sformatf("[%s]", name);
            if (s == "[hello]") begin
                $display("T6: PASS - %%s: '%s'", s);
                pass_count++;
            end else $display("T6: FAIL - '%s' expected '[hello]'", s);
        end

        // T7: %f real format
        begin
            static string s = $sformatf("%f", 3.14);
            if (s.len() > 3) begin
                $display("T7: PASS - %%f: '%s'", s);
                pass_count++;
            end else $display("T7: FAIL - '%s'", s);
        end

        // T8: %e scientific notation
        begin
            static string s = $sformatf("%e", 1234.5);
            if (s.len() > 5) begin
                $display("T8: PASS - %%e: '%s'", s);
                pass_count++;
            end else $display("T8: FAIL - '%s'", s);
        end

        // T9: %c character format
        begin
            static string s = $sformatf("%c%c%c", 72, 105, 33);  // "Hi!"
            if (s == "Hi!") begin
                $display("T9: PASS - %%c: '%s'", s);
                pass_count++;
            end else $display("T9: FAIL - '%s' expected 'Hi!'", s);
        end

        // T10: %m module path
        begin
            static string s = $sformatf("%m");
            if (s.len() > 0) begin
                // The name shown for an unnamed block depends on the simulator, so it is not printed.
                $display("T10: PASS - %%m is not empty");
                pass_count++;
            end else $display("T10: FAIL - empty");
        end

        // T11: Mixed format specifiers
        begin
            static string s = $sformatf("d=%0d h=%0h b=%0b s=%s", 10, 10, 4'b1010, "ok");
            if (s == "d=10 h=a b=1010 s=ok") begin
                $display("T11: PASS - mixed: '%s'", s);
                pass_count++;
            end else $display("T11: FAIL - '%s'", s);
        end

        // T12: Escaped percent
        begin
            static string s = $sformatf("100%%");
            if (s == "100%") begin
                $display("T12: PASS - escaped %%%%: '%s'", s);
                pass_count++;
            end else $display("T12: FAIL - '%s' expected '100%%'", s);
        end

        // T13: $sformatf with no args
        begin
            static string s = $sformatf("no args");
            if (s == "no args") begin
                $display("T13: PASS - no args: '%s'", s);
                pass_count++;
            end else $display("T13: FAIL - '%s'", s);
        end

        // T14: Large integer formatting
        begin
            static longint val = 64'hFFFF_FFFF_FFFF_FFFF;
            static string s;
            // Assigned here so the result does not depend on the order of static initializers.
            s = $sformatf("%0h", val);
            if (s.len() >= 16) begin
                $display("T14: PASS - 64-bit hex: '%s'", s);
                pass_count++;
            end else $display("T14: FAIL - '%s' len=%0d", s, s.len());
        end

        // T15: Negative integer formatting
        begin
            static int neg = -1;
            static string s;
            // Assigned here so the result does not depend on the order of static initializers.
            s = $sformatf("%0d", neg);
            if (s == "-1") begin
                $display("T15: PASS - negative: '%s'", s);
                pass_count++;
            end else $display("T15: FAIL - '%s' expected '-1'", s);
        end

        // T16: Multiple format strings back to back
        begin
            static string s1 = $sformatf("%0d", 1);
            static string s2 = $sformatf("%0d", 2);
            static string s3 = $sformatf("%0d", 3);
            if (s1 == "1" && s2 == "2" && s3 == "3") begin
                $display("T16: PASS - sequential: %s %s %s", s1, s2, s3);
                pass_count++;
            end else $display("T16: FAIL - %s %s %s", s1, s2, s3);
        end

        $display("\n%0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
