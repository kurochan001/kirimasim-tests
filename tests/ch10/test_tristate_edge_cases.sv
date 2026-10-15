/*
:name: test_tristate_edge_cases
:description: A tri-state buffer from a continuous assignment with z
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3 6.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_tristate_edge_cases.expected
*/
// IEEE 1800-2023: Tristate buffer edge cases
// Tests for tristate constructs

module test_tristate_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] din;
    logic oe;
    wire [7:0] bus;

    // Tristate buffer
    assign bus = oe ? din : 8'bz;

    initial begin
        // Test 1: Output enabled
        test_count++;
        din = 8'hAA; oe = 1;
        #1;
        if (bus == 8'hAA) begin
            pass_count++;
            $display("Test 1 PASS: oe=1 bus=%h", bus);
        end else begin
            $display("Test 1 FAIL: unexpected bus=%h", bus);
        end

        // Test 2: Output disabled (high-Z)
        test_count++;
        oe = 0;
        #1;
        if (bus === 8'bzzzzzzzz) begin
            pass_count++;
            $display("Test 2 PASS: oe=0 bus=Z");
        end else begin
            $display("Test 2 FAIL: unexpected bus=%h", bus);
        end

        // Test 3: Change data while enabled
        test_count++;
        oe = 1; din = 8'h55;
        #1;
        if (bus == 8'h55) begin
            pass_count++;
            $display("Test 3 PASS: din change bus=%h", bus);
        end else begin
            $display("Test 3 FAIL: unexpected");
        end

        // Test 4: All zeros
        test_count++;
        din = 8'h00; oe = 1;
        #1;
        if (bus == 0) begin
            pass_count++;
            $display("Test 4 PASS: zeros bus=%h", bus);
        end else begin
            $display("Test 4 FAIL: unexpected");
        end

        // Test 5: All ones
        test_count++;
        din = 8'hFF; oe = 1;
        #1;
        if (bus == 8'hFF) begin
            pass_count++;
            $display("Test 5 PASS: ones bus=%h", bus);
        end else begin
            $display("Test 5 FAIL: unexpected");
        end

        // Test 6: Toggle enable
        test_count++;
        din = 8'h12;
        oe = 1; #1;
        oe = 0; #1;
        oe = 1; #1;
        if (bus == 8'h12) begin
            pass_count++;
            $display("Test 6 PASS: Toggle enable");
        end else begin
            $display("Test 6 FAIL: bus=%h", bus);
        end

        // Test 7: Data change while disabled
        test_count++;
        oe = 0;
        din = 8'hAB; #1;
        din = 8'hCD; #1;
        oe = 1; #1;
        if (bus == 8'hCD) begin
            pass_count++;
            $display("Test 7 PASS: Data while disabled bus=%h", bus);
        end else begin
            $display("Test 7 FAIL: unexpected");
        end

        $display("=== Tristate Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
