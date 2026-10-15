/*
:name: test_format_sformatf
:description: $sformatf system function
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_sformatf.expected
*/
// IEEE 1800-2023 §21.3.3: $sformatf system function
module test_format_sformatf;
    int pass_count = 0;
    int fail_count = 0;
    string s;
    logic [7:0] val;

    initial begin
        // Test 1: Basic format
        s = $sformatf("val=%0d", 100);
        if (s == "val=100") begin
            $display("Test 1 PASS: sformatf basic");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got '%s'", s);
            fail_count++;
        end

        // Test 2: Binary format with %0b
        val = 8'hAA;
        s = $sformatf("bin=%0b", val);
        if (s == "bin=10101010") begin
            $display("Test 2 PASS: sformatf binary");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got '%s'", s);
            fail_count++;
        end

        // Test 3: String format
        s = $sformatf("str=%s", "hello");
        if (s == "str=hello") begin
            $display("Test 3 PASS: sformatf string");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got '%s'", s);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
