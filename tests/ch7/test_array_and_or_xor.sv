/*
:name: test_array_and_or_xor
:description: Test: Array and/or/xor methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_and_or_xor.expected
*/
// Test: Array and/or/xor methods

module test_array_and_or_xor;
    logic [7:0] arr[4] = '{8'hFF, 8'h0F, 8'hF0, 8'hAA};
    logic [7:0] result;

    initial begin
        result = arr.and();
        if (result != 8'h00) begin
            $display("FAIL: array and got %h", result);
            $finish;
        end

        result = arr.or();
        if (result != 8'hFF) begin
            $display("FAIL: array or got %h", result);
            $finish;
        end

        result = arr.xor();
        if (result != 8'hAA) begin  // FF ^ 0F ^ F0 ^ AA = AA
            $display("FAIL: array xor got %h", result);
            $finish;
        end

        $display("PASS: array and or xor");
        $finish;
    end
endmodule
