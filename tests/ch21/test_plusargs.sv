/*
:name: test_plusargs
:description: Plusargs system tasks
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_plusargs.expected
*/
// IEEE 1800-2023 Section 21.6: Plusargs system tasks
module test_plusargs;
    int value;
    string str_val;
    int result;

    initial begin
        // Test 1: $test$plusargs - check if plusarg exists
        if ($test$plusargs("testname"))
            $display("INFO: +testname was provided");
        else
            $display("INFO: +testname was not provided");
        $display("PASS: $test$plusargs executed");

        // Test 2: $value$plusargs with integer
        result = $value$plusargs("timeout=%d", value);
        if (result)
            $display("INFO: timeout value = %0d", value);
        else
            $display("INFO: timeout plusarg not found");
        $display("PASS: $value$plusargs integer executed");

        // Test 3: $value$plusargs with string
        result = $value$plusargs("testname=%s", str_val);
        if (result)
            $display("INFO: testname = %s", str_val);
        else
            $display("INFO: testname plusarg not found");
        $display("PASS: $value$plusargs string executed");

        // Test 4: $value$plusargs with hex format
        result = $value$plusargs("addr=%h", value);
        if (result)
            $display("INFO: addr = 0x%0h", value);
        else
            $display("INFO: addr plusarg not found");
        $display("PASS: $value$plusargs hex executed");

        $display("TEST PASSED: plusargs tests completed");
        $finish;
    end
endmodule
