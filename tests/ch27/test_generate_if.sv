/*
:name: test_generate_if
:description: Generate If (§27.5)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_if.expected
*/
// IEEE 1800-2023 Generate If (§27.5)
// Tests generate if-else construct

module configurable_adder #(parameter USE_PIPELINE = 1)(
    input logic clk,
    input logic [7:0] a, b,
    output logic [7:0] sum
);
    generate
        if (USE_PIPELINE) begin : pipelined
            logic [7:0] a_reg, b_reg;
            always_ff @(posedge clk) begin
                a_reg <= a;
                b_reg <= b;
                sum <= a_reg + b_reg;
            end
        end else begin : combinational
            assign sum = a + b;
        end
    endgenerate
endmodule

module test_generate_if;
    logic clk = 0;
    logic [7:0] a, b;
    logic [7:0] sum_pipe, sum_comb;
    int pass_count = 0;
    int fail_count = 0;

    always #5 clk = ~clk;

    // Pipelined version
    configurable_adder #(.USE_PIPELINE(1)) pipe_adder (
        .clk(clk),
        .a(a),
        .b(b),
        .sum(sum_pipe)
    );

    // Combinational version
    configurable_adder #(.USE_PIPELINE(0)) comb_adder (
        .clk(clk),
        .a(a),
        .b(b),
        .sum(sum_comb)
    );

    initial begin
        a = 8'd10;
        b = 8'd20;

        #1;

        // Test combinational - should be immediate
        if (sum_comb == 8'd30) begin
            $display("PASS: Combinational sum = %0d", sum_comb);
            pass_count++;
        end else begin
            $display("FAIL: Combinational sum = %0d, expected 30", sum_comb);
            fail_count++;
        end

        // Wait for pipelined version (2 clock cycles delay)
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        if (sum_pipe == 8'd30) begin
            $display("PASS: Pipelined sum = %0d", sum_pipe);
            pass_count++;
        end else begin
            $display("FAIL: Pipelined sum = %0d, expected 30", sum_pipe);
            fail_count++;
        end

        // Change inputs
        a = 8'd50;
        b = 8'd100;
        #1;

        // Combinational should update immediately
        if (sum_comb == 8'd150) begin
            $display("PASS: Combinational updated sum = %0d", sum_comb);
            pass_count++;
        end else begin
            $display("FAIL: Combinational updated sum = %0d, expected 150", sum_comb);
            fail_count++;
        end

        $display("");
        $display("=== Generate If Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
