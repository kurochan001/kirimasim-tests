/*
:name: test_format_width
:description: Format width specifiers
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_width.expected
*/
// IEEE 1800-2023 §21.2.1.2: Format width specifiers
module test_format_width;
    int pass_count = 0;
    int fail_count = 0;
    string s;

    initial begin
        // Test 1: Width specifier
        s = $sformatf("%5d", 42);
        if (s == "   42") begin
            $display("Test 1 PASS: width 5");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got '%s'", s);
            fail_count++;
        end

        // Test 2: Hex width
        s = $sformatf("%04h", 8'hAB);
        if (s == "00ab") begin
            $display("Test 2 PASS: hex width");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got '%s'", s);
            fail_count++;
        end

        $display("Passed: %0d/2", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
