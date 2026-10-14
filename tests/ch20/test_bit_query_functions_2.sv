/*
:name: test_bit_query_functions_2
:description: Bit operation system functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9 20.8.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bit_query_functions_2.expected
*/
// Bit operation system functions
module test_bit_query_functions_2;
    int pass_count = 0;
    logic [31:0] val;
    int result;

    initial begin
        // Test $countones
        val = 32'hF0F0_F0F0;
        result = $countones(val);
        if (result == 16) pass_count++;

        // Test $countbits
        val = 32'hAAAA_AAAA;
        result = $countbits(val, 1'b1);
        if (result == 16) pass_count++;

        // Test $onehot
        val = 32'h0000_0008;
        if ($onehot(val)) pass_count++;

        val = 32'h0000_0018;
        if (!$onehot(val)) pass_count++;

        // Test $onehot0
        val = 32'h0000_0000;
        if ($onehot0(val)) pass_count++;

        val = 32'h0000_0001;
        if ($onehot0(val)) pass_count++;

        // Test $isunknown
        val = 32'hxxxx_xxxx;
        if ($isunknown(val)) pass_count++;

        val = 32'h1234_5678;
        if (!$isunknown(val)) pass_count++;

        // Test $clog2
        result = $clog2(16);
        if (result == 4) pass_count++;

        result = $clog2(17);
        if (result == 5) pass_count++;

        $display("PASS: bit query functions (%0d/10)", pass_count);
        $finish;
    end
endmodule
