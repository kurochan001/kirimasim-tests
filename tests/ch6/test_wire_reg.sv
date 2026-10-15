/*
:name: test_wire_reg
:description: Test for wire and reg types
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5 6.7 6.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wire_reg.expected
*/
// Test for wire and reg types
// IEEE 1800-2023 §6

module test_wire_reg;
    wire [7:0] w1;
    reg [7:0] r1;
    logic [7:0] l1;
    wire w_single;
    int pass_count = 0;
    int test_count = 0;

    assign w1 = 8'hAA;
    assign w_single = 1'b1;

    initial begin
        // Test 1: Wire read
        test_count++;
        #1;
        if (w1 == 8'hAA) begin
            $display("Test 1: Wire read PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Reg assignment
        test_count++;
        r1 = 8'h55;
        if (r1 == 8'h55) begin
            $display("Test 2: Reg assignment PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Logic assignment
        test_count++;
        l1 = 8'hCC;
        if (l1 == 8'hCC) begin
            $display("Test 3: Logic assignment PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Single bit wire
        test_count++;
        if (w_single == 1'b1) begin
            $display("Test 4: Single bit wire PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Logic modify
        test_count++;
        l1 = l1 + 1;
        if (l1 == 8'hCD) begin
            $display("Test 5: Logic modify PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
