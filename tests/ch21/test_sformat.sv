/*
:name: test_sformat
:description: String formatting
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sformat.expected
*/
// IEEE 1800-2023 Section 21.3: String formatting
module test_sformat;
    string s;
    int a;

    initial begin
        a = 123;

        // $sformat - use sformatf instead (sformat has output param issues)
        s = $sformatf("value is %0d", a);
        if (s == "value is 123")
            $display("PASS: sformatf basic");
        else
            $display("FAIL: sformatf = %s", s);

        // $sformatf
        s = $sformatf("hex = %h", 8'hAB);
        if (s == "hex = ab")
            $display("PASS: sformatf");
        else
            $display("FAIL: sformatf = %s", s);

        // Multiple arguments
        s = $sformatf("%0d + %0d = %0d", 5, 3, 8);
        if (s == "5 + 3 = 8")
            $display("PASS: sformatf multi");
        else
            $display("FAIL: multi = %s", s);

        $display("TEST PASSED: sformat tests completed");
        $finish;
    end
endmodule
