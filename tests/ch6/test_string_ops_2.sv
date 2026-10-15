/*
:name: test_string_ops_2
:description: String len, concatenation, toupper, tolower and substr
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_ops_2.expected
*/
`timescale 1ns/1ps
module test_string_ops_2;
    string s1, s2, s3;
    int len;
    
    int fails = 0;

    
    initial begin
        s1 = "Hello";
        s2 = "World";
        
        len = s1.len();
        if (len != 5) begin fails++; $display("FAIL: len"); end
        
        s3 = {s1, " ", s2};
        if (s3 != "Hello World") begin fails++; $display("FAIL: concat"); end
        
        s1 = s1.toupper();
        if (s1 != "HELLO") begin fails++; $display("FAIL: toupper"); end
        
        s1 = s1.tolower();
        if (s1 != "hello") begin fails++; $display("FAIL: tolower"); end
        
        s3 = s3.substr(0, 4);
        if (s3 != "Hello") begin fails++; $display("FAIL: substr"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
