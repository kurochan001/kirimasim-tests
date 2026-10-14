/*
:name: test_net_types_2
:description: wire, tri and supply nets driven by continuous assignments
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.1 6.6.6
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_types_2.expected
*/
// IEEE 1800-2023 Section 6.6.1 - wire and tri nets
module test_net_types_2;
    int passed = 0;
    int failed = 0;

    wire w1, w2;
    wire [7:0] w_byte;
    tri t1;
    supply0 s0;
    supply1 s1;

    logic driver1, driver2;
    logic [7:0] byte_val;

    assign w1 = driver1;
    assign w2 = driver2;
    assign t1 = driver1 ? 1'b1 : 1'bz;
    assign w_byte = byte_val;

    initial begin
        // Test wire basic
        driver1 = 1;
        driver2 = 0;
        #1;
        if (w1 == 1) passed++; else begin failed++; $display("FAIL: w1"); end
        if (w2 == 0) passed++; else begin failed++; $display("FAIL: w2"); end

        // Test wire byte
        byte_val = 8'h80;
        #1;
        if (w_byte == 8'h80) passed++; else begin failed++; $display("FAIL: w_byte = %h", w_byte); end

        // Test tri-state
        driver1 = 1;
        #1;
        if (t1 == 1) passed++; else begin failed++; $display("FAIL: tri1"); end

        driver1 = 0;
        #1;
        if (t1 === 1'bz) passed++; else begin failed++; $display("FAIL: tri0"); end

        // Supply nets (6.6.6)
        if (s0 === 1'b0) passed++; else begin failed++; $display("FAIL: supply0 = %b", s0); end
        if (s1 === 1'b1) passed++; else begin failed++; $display("FAIL: supply1 = %b", s1); end

        // Report
        if (failed == 0)
            $display("PASS: All %0d net type tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
