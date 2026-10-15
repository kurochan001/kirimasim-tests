/*
:name: test_function_in_always_comb
:description: Automatic functions called from always_comb
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 9.2.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_in_always_comb.expected
*/
module test_function_in_always_comb;
    int pass_count = 0;

    // Function with no side effects - compute only
    function automatic logic [7:0] compute_sum(logic [7:0] a, logic [7:0] b);
        return a + b;
    endfunction

    // Function with no side effects - decode pattern
    function automatic logic [3:0] decode_value(logic [7:0] in);
        return in[3:0];
    endfunction

    // Function with no side effects - check pattern
    function automatic bit check_valid(logic [7:0] val);
        return val != 8'h00;
    endfunction

    logic [7:0] in_a, in_b;
    logic [7:0] out_sum;
    logic [3:0] out_decoded;
    logic out_valid;

    always_comb begin
        out_sum = compute_sum(in_a, in_b);
        out_decoded = decode_value(in_a);
        out_valid = check_valid(in_a);
    end

    initial begin
        in_a = 8'hAB;
        in_b = 8'h10;
        #1;

        if (out_sum == 8'hBB) pass_count++;
        if (out_decoded == 4'hB) pass_count++;
        if (out_valid == 1'b1) pass_count++;

        in_a = 8'h00;
        #1;
        if (out_valid == 1'b0) pass_count++;

        $display("PASS: functions in always_comb (%0d/4)", pass_count);
        $finish;
    end
endmodule
