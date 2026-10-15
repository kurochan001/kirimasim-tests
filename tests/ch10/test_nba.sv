/*
:name: test_nba
:description: Non-blocking assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 4.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba.expected
*/
// IEEE 1800-2023 Section 10.4.2: Non-blocking assignments
module test_nba;
    logic [7:0] a, b, c;
    logic clk;

    int fails = 0;


    initial begin
        clk = 0;
        a = 8'h01;
        b = 8'h02;
        c = 8'h03;

        // Swap using NBA
        a <= b;
        b <= a;
        #1;
        if (a == 8'h02 && b == 8'h01)
            $display("PASS: NBA swap");
        else
            begin fails++; $display("FAIL: swap a=%h b=%h", a, b); end

        // Multiple NBA to same variable
        c <= 8'h10;
        c <= 8'h20;
        c <= 8'h30;
        #1;
        if (c == 8'h30)
            $display("PASS: multiple NBA");
        else
            begin fails++; $display("FAIL: multi = %h", c); end

        // NBA with delay - immediate effect variant
        a <= 8'hAA;
        #1;
        if (a == 8'hAA)
            $display("PASS: NBA applied");
        else
            begin fails++; $display("FAIL: applied = %h", a); end

        // Verify NBA timing
        b <= 8'hBB;
        if (b == 8'h01)
            $display("PASS: NBA pending in same cycle");
        else
            begin fails++; $display("FAIL: b changed before the nonblocking update (b = %h)", b); end

        if (fails == 0) $display("TEST PASSED: non-blocking assignment tests completed");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
