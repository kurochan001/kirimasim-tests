/*
:name: test_mod_params
:description: Module Parameter Tests
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10 23.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mod_params.expected
*/
// IEEE 1800-2023 Section 23.2 - Module Parameter Tests
module parameterized #(parameter WIDTH = 8, parameter DEPTH = 4) (
    output logic [WIDTH-1:0] out
);
    assign out = WIDTH + DEPTH;
endmodule

module test_mod_params;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] out1;
    logic [15:0] out2;
    logic [7:0] out3;

    parameterized #(.WIDTH(8), .DEPTH(4)) u1 (.out(out1));
    parameterized #(.WIDTH(16), .DEPTH(8)) u2 (.out(out2));
    parameterized #(.WIDTH(8), .DEPTH(2)) u3 (.out(out3));

    initial begin
        #1;
        $display("=== IEEE 1800-2023 Module Parameter Tests ===");

        $display("Test 1: Default params");
        if (out1 == 12) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", out1); fail_count++; end

        $display("Test 2: Wide params");
        if (out2 == 24) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", out2); fail_count++; end

        $display("Test 3: Custom depth");
        if (out3 == 10) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", out3); fail_count++; end

        $display("Test 4: Out1 width");
        if ($bits(out1) == 8) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: Out2 width");
        if ($bits(out2) == 16) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        $display("Test 6: Instance check");
        if (out1 != out2) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: Out1 vs out3");
        if (out1 != out3) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: All different");
        if (out1 != out2 && out2 != out3 && out1 != out3) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
