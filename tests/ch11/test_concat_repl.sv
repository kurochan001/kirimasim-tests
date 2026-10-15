/*
:name: test_concat_repl
:description: Concatenation and replication
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_repl.expected
*/
// IEEE 1800-2023 Section 11.4.12: Concatenation and replication
module test_concat_repl;
    logic [7:0] a, b;
    logic [15:0] result16;
    logic [31:0] result32;
    logic [3:0] nibble;

    initial begin
        a = 8'hAB;
        b = 8'hCD;

        // Simple concatenation
        result16 = {a, b};
        if (result16 == 16'hABCD)
            $display("PASS: {a, b} = 0xABCD");
        else
            $display("FAIL: {a, b} = 0x%h", result16);

        // Nested concatenation
        nibble = 4'hF;
        result32 = {{2{a}}, {2{b}}};
        if (result32 == 32'hABABCDCD)
            $display("PASS: nested concat");
        else
            $display("FAIL: nested concat = 0x%h", result32);

        // Replication
        result32 = {4{a}};
        if (result32 == 32'hABABABAB)
            $display("PASS: {4{a}} = 0xABABABAB");
        else
            $display("FAIL: {4{a}} = 0x%h", result32);

        // Mixed concat and replication
        result16 = {nibble, {3{nibble}}};
        if (result16 == 16'hFFFF)
            $display("PASS: mixed concat/replication");
        else
            $display("FAIL: mixed = 0x%h", result16);

        // Bit replication
        result16 = {16{1'b1}};
        if (result16 == 16'hFFFF)
            $display("PASS: bit replication");
        else
            $display("FAIL: bit replication = 0x%h", result16);

        $display("TEST PASSED: concatenation tests completed");
        $finish;
    end
endmodule
