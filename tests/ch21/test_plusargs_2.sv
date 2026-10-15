/*
:name: test_plusargs_2
:description: $test$plusargs and $value$plusargs system tasks
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_plusargs_2.expected
*/
// $test$plusargs and $value$plusargs system tasks
module test_plusargs;
    int pass_count = 0;
    string str_val;
    int int_val;
    real real_val;

    initial begin
        // Test $test$plusargs
        if ($test$plusargs("DEBUG")) begin
            $display("DEBUG mode enabled");
        end
        pass_count++;

        if ($test$plusargs("VERBOSE")) begin
            $display("VERBOSE mode");
        end
        pass_count++;

        // Test $value$plusargs with string
        if ($value$plusargs("TESTNAME=%s", str_val)) begin
            $display("Test name: %s", str_val);
        end
        pass_count++;

        // Test $value$plusargs with integer
        if ($value$plusargs("SEED=%d", int_val)) begin
            $display("Seed: %0d", int_val);
        end
        pass_count++;

        // Test $value$plusargs with hex
        if ($value$plusargs("ADDR=%h", int_val)) begin
            $display("Address: 0x%h", int_val);
        end
        pass_count++;

        $display("PASS: plusargs (%0d/5)", pass_count);
        $finish;
    end
endmodule
