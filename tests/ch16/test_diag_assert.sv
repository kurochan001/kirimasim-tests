/*
:name: test_diag_assert
:description: Immediate assertions with and without action blocks
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_diag_assert.expected
*/
// Immediate assertions with and without action blocks
module test_diag_assert;
    int val = 10;
    
    initial begin
        // Passing assertions
        assert (val > 0) else $error("val should be positive");
        assert (val == 10);
        
        // With action block
        assert (val < 100)
            $display("Assertion passed");
        else
            $error("Assertion failed");
        
        $display("PASS: Diag assert test");
        $finish;
    end
endmodule
