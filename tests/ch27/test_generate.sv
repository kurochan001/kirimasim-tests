/*
:name: test_generate
:description: Generate loops and if-generate with initial blocks and continuous assignments
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_generate.expected
*/
// Generate loops and if-generate with initial blocks and continuous assignments
module test_generate;
    int pass_count = 0;
    int test_count = 0;
    
    parameter WIDTH = 8;
    parameter DEPTH = 4;
    
    logic [WIDTH-1:0] data[DEPTH];
    logic [WIDTH-1:0] sum;
    
    // Generate for loop
    genvar gi;
    generate
        for (gi = 0; gi < DEPTH; gi++) begin : gen_init
            initial data[gi] = gi * 10;
        end
    endgenerate
    
    // Generate if
    generate
        if (WIDTH > 4) begin : wide_path
            assign sum = data[0] + data[1];
        end else begin : narrow_path
            assign sum = data[0];
        end
    endgenerate
    
    initial begin
        #1;
        
        // Test 1: Generated initialization
        test_count++;
        if (data[0] == 0) pass_count++;
        
        // Test 2: Second element
        test_count++;
        if (data[1] == 10) pass_count++;
        
        // Test 3: Third element
        test_count++;
        if (data[2] == 20) pass_count++;
        
        // Test 4: Fourth element
        test_count++;
        if (data[3] == 30) pass_count++;
        
        // Test 5: Sum from generate if
        test_count++;
        if (sum == 10) pass_count++;
        
        // Test 6: Modify generated data
        test_count++;
        data[0] = 100;
        #1;
        if (data[0] == 100) pass_count++;
        
        // Test 7: Sum update
        test_count++;
        #1;
        if (sum == 110) pass_count++;
        
        // Test 8: All elements valid
        test_count++;
        begin
            static int valid = 1;
            for (int j = 0; j < DEPTH; j++)
                if (data[j] === 'x) valid = 0;
            if (valid) pass_count++;
        end
        
        // Test 9: Parameter check
        test_count++;
        if (WIDTH == 8) pass_count++;
        
        // Test 10: Depth check
        test_count++;
        if (DEPTH == 4) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
