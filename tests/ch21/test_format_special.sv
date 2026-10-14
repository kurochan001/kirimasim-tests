/*
:name: test_format_special
:description: Special format characters
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 5.9.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_special.expected
*/
// IEEE 1800-2023 §21.2.1.1 and §5.9.1: %% and escape sequences
module test_format_special;
    int pass_count = 0;
    int fail_count = 0;
    string s;

    initial begin
        // Test 1: Percent sign
        s = $sformatf("100%%");
        if (s == "100%") begin
            $display("Test 1 PASS: percent");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got '%s'", s);
            fail_count++;
        end

        // Test 2: Newline (check length increases)
        s = $sformatf("a\nb");
        if (s.len() == 3) begin
            $display("Test 2 PASS: newline");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: len=%0d", s.len());
            fail_count++;
        end

        // Test 3: Tab character
        s = $sformatf("a\tb");
        if (s.len() == 3) begin
            $display("Test 3 PASS: tab");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: len=%0d", s.len());
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
