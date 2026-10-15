/*
:name: test_format_precision
:description: Format specifiers for integers and reals in $sformatf: width, precision, %e, %g, %x, %o, %b
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.2.1.2 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_precision.expected
*/
// test_format_precision.sv
// IEEE 1800-2023 §21.3.3 Formatting data to a string

module test_format_precision;
    int pass_count = 0;
    int test_count = 14;

    string result;

    initial begin
        // T0: $sformatf("%0d", 42) — minimum width, no padding
        result = $sformatf("%0d", 42);
        if (result == "42") begin
            $display("T0: PASS - %%0d: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T0: FAIL - %%0d: \"%s\", expected \"42\"", result);
        end
        #1;

        // T1: $sformatf("%.0f", 3.7) — precision 0 for real, should round
        result = $sformatf("%.0f", 3.7);
        if (result == "4") begin
            $display("T1: PASS - %%.0f: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T1: FAIL - %%.0f of 3.7: \"%s\", expected \"4\"", result);
        end
        #1;

        // T2: $sformatf("%f", 3.14159) — default precision 6
        result = $sformatf("%f", 3.14159);
        if (result == "3.141590") begin
            $display("T2: PASS - %%f: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T2: FAIL - %%f of 3.14159: \"%s\", expected \"3.141590\"", result);
        end
        #1;

        // T3: $sformatf("%.10f", 1.0/3.0) — high precision
        result = $sformatf("%.10f", 1.0 / 3.0);
        if (result == "0.3333333333") begin
            $display("T3: PASS - %%.10f: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T3: FAIL - %%.10f of 1/3: \"%s\", expected \"0.3333333333\"", result);
        end
        #1;

        // T4: $sformatf("%e", 12345.6789) — scientific notation
        result = $sformatf("%e", 12345.6789);
        // Real formats follow C (21.2.1.1): the exponent has at least two digits.
        if (result == "1.234568e+04") begin
            $display("T4: PASS - %%e: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T4: FAIL - %%e of 12345.6789: \"%s\", expected \"1.234568e+04\"", result);
        end
        #1;

        // T5: $sformatf("%.0e", 12345.0) — scientific with precision 0
        result = $sformatf("%.0e", 12345.0);
        if (result == "1e+04") begin
            $display("T5: PASS - %%.0e: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T5: FAIL - %%.0e of 12345.0: \"%s\", expected \"1e+04\"", result);
        end
        #1;

        // T6-T8 are not checked: the 0 and - flags for integer formats are not
        // defined by the standard, which pads decimal values with spaces (21.2.1.2).

        // T9: $sformatf("%10.3f", 3.14) — width 10 with precision 3
        result = $sformatf("%10.3f", 3.14);
        if (result == "     3.140") begin
            $display("T9: PASS - %%10.3f: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T9: FAIL - %%10.3f of 3.14: \"%s\", expected \"     3.140\"", result);
        end
        #1;

        // T10: $sformatf("%%d") — escaped percent literal
        result = $sformatf("%%d");
        if (result == "%d") begin
            $display("T10: PASS - %%%%d: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T10: FAIL - %%%%d: \"%s\", expected \"%%d\"", result);
        end
        #1;

        // T11: $sformatf("%g", 100000.0) — %g format for large value
        result = $sformatf("%g", 100000.0);
        if (result == "100000") begin
            $display("T11: PASS - %%g large: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T11: FAIL - %%g of 100000.0: \"%s\", expected \"100000\"", result);
        end
        #1;

        // T12: $sformatf("%g", 0.00001) — %g format for small value
        result = $sformatf("%g", 0.00001);
        if (result == "1e-05") begin
            $display("T12: PASS - %%g small: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T12: FAIL - %%g of 0.00001: \"%s\", expected \"1e-05\"", result);
        end
        #1;

        // T13: $sformatf("%0d", 0) — zero value with %0d
        result = $sformatf("%0d", 0);
        if (result == "0") begin
            $display("T13: PASS - %%0d of 0: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T13: FAIL - %%0d of 0: \"%s\", expected \"0\"", result);
        end
        #1;

        // T14: $sformatf("%x", 255) — hex format
        result = $sformatf("%x", 255);
        // Without a field width, hex shows every digit of the 32-bit value,
        // leading zeros included (21.2.1.2).
        if (result == "000000ff") begin
            $display("T14: PASS - %%x of 255: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T14: FAIL - %%x of 255: \"%s\", expected \"000000ff\"", result);
        end
        #1;

        // T15: $sformatf("%o", 8) — octal format
        result = $sformatf("%o", 8);
        // 11 octal digits for a 32-bit value, leading zeros included (21.2.1.2)
        if (result == "00000000010") begin
            $display("T15: PASS - %%o of 8: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T15: FAIL - %%o of 8: \"%s\", expected \"00000000010\"", result);
        end
        #1;

        // T16: $sformatf("%b", 8'hA5) — binary format
        result = $sformatf("%b", 8'hA5);
        // 8 binary digits for an 8-bit value (21.2.1.2)
        if (result == "10100101") begin
            $display("T16: PASS - %%b of 8'hA5: \"%s\"", result);
            pass_count++;
        end else begin
            $display("T16: FAIL - %%b of 8'hA5: \"%s\", expected \"10100101\"", result);
        end

        #1;
        if (pass_count == test_count)
            $display("TEST PASSED (%0d/%0d)", pass_count, test_count);
        else
            $display("TEST FAILED (%0d/%0d)", pass_count, test_count);
        $finish;
    end
endmodule
