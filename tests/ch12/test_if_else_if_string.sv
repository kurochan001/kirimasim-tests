/*
:name: test_if_else_if_string
:description: An if-else-if chain choosing a string
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_if_else_if_string.expected
*/
module test_if_else_if_string;
    int val;
    string result;
    
    initial begin
        val = 15;
        if (val < 10)
            result = "small";
        else if (val < 20)
            result = "medium";
        else
            result = "big";
        
        if (result == "medium")
            $display("PASS: if-else-if chain");
        else
            $display("FAIL: result=%s", result);
        $finish;
    end
endmodule
