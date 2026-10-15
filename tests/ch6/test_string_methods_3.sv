/*
:name: test_string_methods_3
:description: String methods len, getc, putc, atoi and atohex
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_methods_3.expected
*/
// String methods len, getc, putc, atoi and atohex (6.16)
`timescale 1ns/1ps
module test_string_methods_3;
    string s;
    int val;
    
    int fails = 0;

    
    initial begin
        s = "Hello World";
        
        if (s.len() != 11) begin fails++; $display("FAIL: len"); end
        if (s.getc(0) != 72) begin fails++; $display("FAIL: getc"); end // 'H'
        
        s.putc(0, 74); // 'J'
        if (s.getc(0) != 74) begin fails++; $display("FAIL: putc"); end
        
        s = "123";
        val = s.atoi();
        if (val != 123) begin fails++; $display("FAIL: atoi"); end
        
        s = "FF";
        val = s.atohex();
        if (val != 255) begin fails++; $display("FAIL: atohex"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
