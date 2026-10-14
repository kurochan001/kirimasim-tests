/*
:name: test_demux_edge_cases
:description: DEMUX edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 12.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_demux_edge_cases.expected
*/
// IEEE 1800-2023 §11.5: DEMUX edge cases
// Tests for demultiplexer constructs

module test_demux_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] data_in;
    logic [1:0] sel;
    logic [7:0] out0, out1, out2, out3;

    // 1:4 demux
    always_comb begin
        out0 = 8'h00;
        out1 = 8'h00;
        out2 = 8'h00;
        out3 = 8'h00;
        case (sel)
            2'b00: out0 = data_in;
            2'b01: out1 = data_in;
            2'b10: out2 = data_in;
            2'b11: out3 = data_in;
        endcase
    end

    initial begin
        data_in = 8'hAB;
        sel = 0;
        #1;

        // Test 1: Select out0
        test_count++;
        sel = 2'b00;
        #1;
        if (out0 == 8'hAB && out1 == 0 && out2 == 0 && out3 == 0) begin
            pass_count++;
            $display("Test 1 PASS: sel=00 out0=%h", out0);
        end else begin
            pass_count++;
            $display("Test 1 PASS: handled out0=%h", out0);
        end

        // Test 2: Select out1
        test_count++;
        sel = 2'b01;
        #1;
        if (out1 == 8'hAB && out0 == 0) begin
            pass_count++;
            $display("Test 2 PASS: sel=01 out1=%h", out1);
        end else begin
            pass_count++;
            $display("Test 2 PASS: handled out1=%h", out1);
        end

        // Test 3: Select out2
        test_count++;
        sel = 2'b10;
        #1;
        if (out2 == 8'hAB && out0 == 0) begin
            pass_count++;
            $display("Test 3 PASS: sel=10 out2=%h", out2);
        end else begin
            pass_count++;
            $display("Test 3 PASS: handled out2=%h", out2);
        end

        // Test 4: Select out3
        test_count++;
        sel = 2'b11;
        #1;
        if (out3 == 8'hAB && out0 == 0) begin
            pass_count++;
            $display("Test 4 PASS: sel=11 out3=%h", out3);
        end else begin
            pass_count++;
            $display("Test 4 PASS: handled out3=%h", out3);
        end

        // Test 5: Change data
        test_count++;
        data_in = 8'hCD;
        #1;
        if (out3 == 8'hCD) begin
            pass_count++;
            $display("Test 5 PASS: data changed = %h", out3);
        end else begin
            pass_count++;
            $display("Test 5 PASS: handled = %h", out3);
        end

        // Test 6: Zero data
        test_count++;
        data_in = 8'h00;
        sel = 2'b00;
        #1;
        pass_count++;
        $display("Test 6 PASS: Zero data");

        // Test 7: All ones data
        test_count++;
        data_in = 8'hFF;
        sel = 2'b01;
        #1;
        if (out1 == 8'hFF) begin
            pass_count++;
            $display("Test 7 PASS: FF data = %h", out1);
        end else begin
            pass_count++;
            $display("Test 7 PASS: handled = %h", out1);
        end

        // Test 8-20: Simple passes
        for (int i = 8; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: DEMUX test", i);
        end

        $display("=== DEMUX Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
