/*
:name: test_always_comb
:description: always_comb
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb.expected
*/
// IEEE 1800-2023 Section 9.2.2: always_comb
module test_always_comb;
    logic a, b, c;
    logic [7:0] data, result;

    always_comb begin
        c = a & b;
    end

    always_comb begin
        result = data + 8'h01;
    end

    initial begin
        a = 0; b = 0;
        data = 8'h00;
        #1;

        // Test combinational logic
        a = 1; b = 1;
        #1;
        if (c == 1)
            $display("PASS: always_comb and");
        else
            $display("FAIL: and = %b", c);

        a = 1; b = 0;
        #1;
        if (c == 0)
            $display("PASS: always_comb update");
        else
            $display("FAIL: update = %b", c);

        data = 8'h10;
        #1;
        if (result == 8'h11)
            $display("PASS: always_comb add");
        else
            $display("FAIL: add = %h", result);

        $display("TEST PASSED: always_comb tests completed");
        $finish;
    end
endmodule
