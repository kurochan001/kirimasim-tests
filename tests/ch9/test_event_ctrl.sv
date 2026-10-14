/*
:name: test_event_ctrl
:description: Event control
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_ctrl.expected
*/
// IEEE 1800-2023 Section 9.4.2: Event control
module test_event_ctrl;
    logic clk;
    logic [7:0] data;
    int count;
    event ev;

    initial begin
        clk = 0;
        repeat (20) #5 clk = ~clk;
    end

    initial begin
        count = 0;
        data = 8'h00;

        // Wait for posedge
        @(posedge clk);
        count = count + 1;
        if (count == 1)
            $display("PASS: posedge wait");
        else
            $display("FAIL: posedge = %0d", count);

        // Wait for negedge
        @(negedge clk);
        count = count + 1;
        if (count == 2)
            $display("PASS: negedge wait");
        else
            $display("FAIL: negedge = %0d", count);

        // Wait for any edge
        @(clk);
        count = count + 1;
        if (count == 3)
            $display("PASS: any edge wait");
        else
            $display("FAIL: any = %0d", count);

        // Multiple clocks
        repeat (3) @(posedge clk);
        count = count + 1;
        if (count == 4)
            $display("PASS: repeat edge");
        else
            $display("FAIL: repeat = %0d", count);

        $display("TEST PASSED: event control tests completed");
        $finish;
    end
endmodule
