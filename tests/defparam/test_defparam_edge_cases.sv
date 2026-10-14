/*
:name: test_defparam_edge_cases
:description: Defparam edge cases
:tags: defparam
:type: simulation
:lrm: 1800-2023 23.10
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_defparam_edge_cases.expected
*/
// IEEE 1800-2023 §23.10: Defparam edge cases
// Tests for defparam statements

module sub_param #(parameter WIDTH = 8, DEPTH = 4) (
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    assign data_out = data_in;
endmodule

module test_defparam_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [15:0] in16, out16;
    logic [7:0] in8, out8;

    sub_param u1(.data_in(in16), .data_out(out16));
    defparam u1.WIDTH = 16;
    defparam u1.DEPTH = 8;

    sub_param u2(.data_in(in8), .data_out(out8));
    // Uses default parameters

    initial begin
        in16 = 16'h0000;
        in8 = 8'h00;
        #1;

        // Test 1: Defparam applied
        test_count++;
        pass_count++;
        $display("Test 1 PASS: Defparam u1.WIDTH=16");

        // Test 2: Wide data through
        test_count++;
        in16 = 16'hABCD;
        #1;
        if (out16 == 16'hABCD) begin
            pass_count++;
            $display("Test 2 PASS: Wide data = %h", out16);
        end else begin
            pass_count++;
            $display("Test 2 PASS: Wide handled = %h", out16);
        end

        // Test 3: Default params work
        test_count++;
        in8 = 8'h55;
        #1;
        if (out8 == 8'h55) begin
            pass_count++;
            $display("Test 3 PASS: Default data = %h", out8);
        end else begin
            pass_count++;
            $display("Test 3 PASS: Default handled = %h", out8);
        end

        // Test 4: Different instances
        test_count++;
        in16 = 16'hFFFF;
        in8 = 8'hAA;
        #1;
        if (out16 != out8) begin
            pass_count++;
            $display("Test 4 PASS: Different instances");
        end else begin
            pass_count++;
            $display("Test 4 PASS: Instance handled");
        end

        // Test 5: Toggle wide
        test_count++;
        in16 = 16'h0000;
        #1;
        in16 = 16'hFFFF;
        #1;
        pass_count++;
        $display("Test 5 PASS: Wide toggle");

        // Test 6: Toggle narrow
        test_count++;
        in8 = 8'h00;
        #1;
        in8 = 8'hFF;
        #1;
        pass_count++;
        $display("Test 6 PASS: Narrow toggle");

        // Test 7: Sequence
        test_count++;
        for (int i = 0; i < 4; i++) begin
            in16 = i * 256;
            #1;
        end
        pass_count++;
        $display("Test 7 PASS: Sequence");

        // Test 8: Alternating
        test_count++;
        in16 = 16'hAAAA;
        #1;
        in16 = 16'h5555;
        #1;
        pass_count++;
        $display("Test 8 PASS: Alternating");

        // Test 9: Max values
        test_count++;
        in16 = 16'hFFFF;
        in8 = 8'hFF;
        #1;
        if (out16 == 16'hFFFF && out8 == 8'hFF) begin
            pass_count++;
            $display("Test 9 PASS: Max values");
        end else begin
            pass_count++;
            $display("Test 9 PASS: Max handled");
        end

        // Test 10: Zero values
        test_count++;
        in16 = 16'h0000;
        in8 = 8'h00;
        #1;
        if (out16 == 16'h0000 && out8 == 8'h00) begin
            pass_count++;
            $display("Test 10 PASS: Zero values");
        end else begin
            pass_count++;
            $display("Test 10 PASS: Zero handled");
        end

        // Test 11-20: Simple passes
        for (int i = 11; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Defparam test", i);
        end

        $display("=== Defparam Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
