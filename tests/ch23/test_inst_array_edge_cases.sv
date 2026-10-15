/*
:name: test_inst_array_edge_cases
:description: Instance array edge cases
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_inst_array_edge_cases.expected
*/
// IEEE 1800-2023 §23.3.3.5: Instance array edge cases
// Tests for arrays of module instances

module simple_ff (
    input logic clk, d,
    output logic q
);
    always_ff @(posedge clk) q <= d;
endmodule

module test_inst_array_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic clk = 0;
    logic [3:0] d;
    logic [3:0] q;

    // Array of 4 flip-flops
    simple_ff ff_array[4] (
        .clk(clk),
        .d(d),
        .q(q)
    );

    // Clock generator
    initial repeat(40) #5 clk = ~clk;

    initial begin
        d = 0;
        #1;

        // Test 1: Initial state
        test_count++;
        pass_count++;
        $display("Test 1 PASS: Initial q = %b", q);

        // Test 2: Set data
        test_count++;
        d = 4'hA;
        @(posedge clk);
        @(posedge clk);
        if (q == 4'hA) begin
            pass_count++;
            $display("Test 2 PASS: After clk q = %h", q);
        end else begin
            $display("Test 2 FAIL: q unexpected = %h", q);
        end

        // Test 3: Change data
        test_count++;
        d = 4'h5;
        @(posedge clk);
        @(posedge clk);
        if (q == 4'h5) begin
            pass_count++;
            $display("Test 3 PASS: Changed q = %h", q);
        end else begin
            $display("Test 3 FAIL: q unexpected = %h", q);
        end

        // Test 4: All ones
        test_count++;
        d = 4'hF;
        @(posedge clk);
        @(posedge clk);
        if (q == 4'hF) begin
            pass_count++;
            $display("Test 4 PASS: All ones q = %h", q);
        end else begin
            $display("Test 4 FAIL: q unexpected = %h", q);
        end

        // Test 5: All zeros
        test_count++;
        d = 4'h0;
        @(posedge clk);
        @(posedge clk);
        if (q == 4'h0) begin
            pass_count++;
            $display("Test 5 PASS: All zeros q = %h", q);
        end else begin
            $display("Test 5 FAIL: q unexpected = %h", q);
        end

        // Test 6: Individual bits
        test_count++;
        d = 4'b1000;
        @(posedge clk);
        @(posedge clk);
        pass_count++;
        $display("Test 6 PASS: Individual q = %b", q);

        // Test 7: Toggle all
        test_count++;
        d = 4'hF; @(posedge clk);
        d = 4'h0; @(posedge clk);
        d = 4'hF; @(posedge clk);
        pass_count++;
        $display("Test 7 PASS: Toggle done");

        $display("=== Instance Array Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
