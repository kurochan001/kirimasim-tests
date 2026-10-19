/*
:name: test_nba_interface_array_element
:description: Nonblocking assignments to elements of an unpacked array declared in an interface, from inside and outside the interface (IEEE 1800-2023 Section 10.4.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 25.3 23.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_interface_array_element.expected
*/
// IEEE 1800-2023 §10.4.2, §25.3: a nonblocking assignment to an element of an
// unpacked array declared in an interface updates that element of the array of
// the interface instance, with a constant or a variable index. Each instance
// has its own array. A process outside the interface reaches the array with a
// hierarchical name (23.6), and its nonblocking assignments update it the same
// way.

interface nba_ifc_active(input logic clk);
    logic [7:0] din, sc;
    logic [7:0] mem[4];
    always_ff @(posedge clk) begin
        sc            <= din ^ 8'h33;   // scalar
        mem[din[7:6]] <= din ^ 8'h33;   // variable index
        mem[0]        <= din + 8'h01;   // constant index
    end
endinterface

// No process inside; the testbench writes the array.
interface nba_ifc_passive(input logic clk);
    logic [7:0] din, sc;
    logic [7:0] mem[4];
endinterface

module test_nba_interface_array_element;
    logic clk = 0;
    always #5 clk = ~clk;

    nba_ifc_active x(.clk(clk));
    nba_ifc_active y(.clk(clk));
    nba_ifc_passive z(.clk(clk));

    always_ff @(posedge clk) begin
        z.sc              <= z.din ^ 8'h33;
        z.mem[z.din[7:6]] <= z.din ^ 8'h33;
        z.mem[0]          <= z.din + 8'h01;
    end

    int errors = 0;

    initial begin
        x.din = 8'h80;  // din[7:6] = 2
        y.din = 8'h41;  // din[7:6] = 1
        z.din = 8'hC0;  // din[7:6] = 3
        repeat (2) @(posedge clk);
        #1;

        if (x.sc !== 8'hB3) begin
            $display("FAIL: scalar x.sc=%0h (exp B3)", x.sc);
            errors++;
        end
        if (x.mem[2] !== 8'hB3) begin
            $display("FAIL: variable index x.mem[2]=%0h (exp B3)", x.mem[2]);
            errors++;
        end
        if (x.mem[0] !== 8'h81) begin
            $display("FAIL: constant index x.mem[0]=%0h (exp 81)", x.mem[0]);
            errors++;
        end
        // 0x41 ^ 0x33 = 0x72, written to y's own array
        if (y.mem[1] !== 8'h72) begin
            $display("FAIL: second instance y.mem[1]=%0h (exp 72)", y.mem[1]);
            errors++;
        end
        if (y.mem[0] !== 8'h42) begin
            $display("FAIL: second instance y.mem[0]=%0h (exp 42)", y.mem[0]);
            errors++;
        end
        // 0xC0 ^ 0x33 = 0xF3, written from outside the interface
        if (z.sc !== 8'hF3) begin
            $display("FAIL: outside scalar z.sc=%0h (exp F3)", z.sc);
            errors++;
        end
        if (z.mem[3] !== 8'hF3) begin
            $display("FAIL: outside variable index z.mem[3]=%0h (exp F3)", z.mem[3]);
            errors++;
        end
        if (z.mem[0] !== 8'hC1) begin
            $display("FAIL: outside constant index z.mem[0]=%0h (exp C1)", z.mem[0]);
            errors++;
        end

        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED: %0d error(s)", errors);
        $finish;
    end
endmodule
