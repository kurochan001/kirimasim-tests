/*
:name: test_always_blocks
:description: Clock generation
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 9.2.2.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_blocks.expected
*/
// IEEE 1800-2023 Section 9.2

module test_always_blocks;
    logic clk = 0;
    logic rst = 1;
    logic [7:0] counter = 0;
    logic [7:0] data_reg = 0;
    logic data_in = 0;
    
    // Clock generation
    always #5 clk = ~clk;
    
    // always_ff block (synthesizable flip-flop)
    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            counter <= 0;
        else
            counter <= counter + 1;
    end
    
    // always_comb block (combinational logic)
    logic [7:0] data_out;
    always_comb begin
        data_out = data_reg ^ 8'hFF;
    end
    
    int fails = 0;

    
    initial begin
        // Test 1: Initial state
        #1;
        $display("PASS: Initial state counter=%0d", counter);
        
        // Test 2: Reset
        rst = 0;
        @(posedge clk);
        #1;
        if (counter == 0)
            $display("PASS: Reset worked");
        else
            begin fails++; $display("FAIL: Counter after reset=%0d", counter); end
            
        // Test 3: Count up
        rst = 1;
        repeat (5) @(posedge clk);
        #1;
        $display("PASS: Counter after 5 cycles=%0d", counter);
        
        // Test 4: Combinational output
        data_reg = 8'hAA;
        #1;
        if (data_out == 8'h55)
            $display("PASS: Combinational output=%h", data_out);
        else
            begin fails++; $display("FAIL: data_out=%h", data_out); end
        
        if (fails == 0) $display("TEST PASSED: always blocks completed");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
