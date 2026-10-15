/*
:name: test_operator_test
:description: Arithmetic, comparison, logical and shift operators on 32-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.4 11.4.7 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_test.expected
*/
module test_operator_test;
    int pass_count = 0;
    logic [31:0] a, b, c;
    logic result;
    
    initial begin
        a = 32'd181;
        b = 32'd191;
        
        // Arithmetic operators
        c = a + b;
        if (c == 372) pass_count++;
        
        c = b - a;
        if (c == 10) pass_count++;
        
        // Comparison
        result = (a < b);
        if (result) pass_count++;
        
        // Logical operators
        result = (a > 0) && (b > 0);
        if (result) pass_count++;
        
        // Shift operators
        c = a << 2;
        if (c == (181 * 4)) pass_count++;
        
        $display("PASS: operator test 181 (%0d/5)", pass_count);
        $finish;
    end
endmodule
