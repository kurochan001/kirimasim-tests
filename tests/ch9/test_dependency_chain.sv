/*
:name: test_dependency_chain
:description: A chain of always_comb blocks updates in order after its input changes
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dependency_chain.expected
*/
module test_dependency_chain;
    int pass_count = 0;
    logic [7:0] a, b, c, d;

    // Chain of dependencies: a -> b -> c -> d
    always_comb begin
        b = a + 1;
    end

    always_comb begin
        c = b + 1;
    end

    always_comb begin
        d = c + 1;
    end

    initial begin
        a = 8'd10;
        #1;
        if (b == 8'd11) pass_count++;
        if (c == 8'd12) pass_count++;
        if (d == 8'd13) pass_count++;

        a = 8'd20;
        #1;
        if (d == 8'd23) pass_count++;

        $display("PASS: dependency chain (%0d/4)", pass_count);
        $finish;
    end
endmodule
