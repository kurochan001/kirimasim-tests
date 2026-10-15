/*
:name: test_interface_advanced
:description: Advanced Interface Tests
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_advanced.expected
*/
// IEEE 1800-2023 Section 25 - Advanced Interface Tests
// Tests: interface signals and a function declared in the interface

interface simple_if(input logic clk);
    logic [7:0] data;
    logic valid;
    logic ready;

    // Method in interface
    function logic [7:0] get_data();
        return data;
    endfunction

    // Task in interface
    task write_data(input logic [7:0] d);
        @(posedge clk);
        data = d;
        valid = 1;
        @(posedge clk);
        valid = 0;
    endtask

    modport master(output data, output valid, input ready, import write_data);
    modport slave(input data, input valid, output ready, import get_data);
endinterface

module test_interface_advanced;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    always #5 clk = ~clk;

    simple_if sif(clk);

    initial begin
        $display("=== IEEE 1800-2023 Advanced Interface Tests ===");
        sif.data = 0;
        sif.valid = 0;
        sif.ready = 0;

        // Test 1: Direct signal access
        $display("Test 1: Direct signal access");
        sif.data = 8'hAB;
        #1;
        if (sif.data == 8'hAB) begin
            $display("Test 1 PASS: data=%h", sif.data);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %h", sif.data);
            fail_count++;
        end

        // Test 2: Valid signal
        $display("Test 2: Valid signal");
        sif.valid = 1;
        #1;
        if (sif.valid == 1) begin
            $display("Test 2 PASS: valid=%b", sif.valid);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %b", sif.valid);
            fail_count++;
        end

        // Test 3: Ready signal
        $display("Test 3: Ready signal");
        sif.ready = 1;
        #1;
        if (sif.ready == 1) begin
            $display("Test 3 PASS: ready=%b", sif.ready);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %b", sif.ready);
            fail_count++;
        end

        // Test 4: Interface function call
        $display("Test 4: Interface function call");
        sif.data = 8'hCD;
        #1;
        if (sif.get_data() == 8'hCD) begin
            $display("Test 4 PASS: get_data()=%h", sif.get_data());
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %h", sif.get_data());
            fail_count++;
        end

        // Test 5: Multiple signal assignment
        $display("Test 5: Multiple signal assignment");
        sif.data = 8'h12;
        sif.valid = 0;
        sif.ready = 1;
        #1;
        if (sif.data == 8'h12 && sif.valid == 0 && sif.ready == 1) begin
            $display("Test 5 PASS: data=%h valid=%b ready=%b", sif.data, sif.valid, sif.ready);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Signal toggle
        $display("Test 6: Signal toggle");
        sif.valid = 1;
        #1;
        sif.valid = 0;
        #1;
        if (sif.valid == 0) begin
            $display("Test 6 PASS: toggle complete");
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Data pattern
        $display("Test 7: Data pattern");
        sif.data = 8'b10101010;
        #1;
        if (sif.data == 8'hAA) begin
            $display("Test 7 PASS: pattern=%b (%h)", sif.data, sif.data);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %h", sif.data);
            fail_count++;
        end

        // Test 8: Zero data
        $display("Test 8: Zero data");
        sif.data = 8'h00;
        sif.valid = 0;
        sif.ready = 0;
        #1;
        if (sif.data == 0 && sif.valid == 0 && sif.ready == 0) begin
            $display("Test 8 PASS: all zeros");
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
