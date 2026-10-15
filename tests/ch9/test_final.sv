/*
:name: test_final
:description: A final procedure runs after $finish; generate loop with continuous assignments
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.3 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_final.expected
*/
// IEEE 1800-2023 Final comprehensive test
module test_final;
    logic clk;
    logic [7:0] data;
    int count;

    initial begin
        clk = 0;
        repeat (50) #5 clk = ~clk;
    end

    // Test final block
    final begin
        $display("Final block executed");
        $display("Count at end: %0d", count);
    end

    // Test generate
    generate
        for (genvar i = 0; i < 4; i++) begin : gen_loop
            logic [7:0] gen_data;
            assign gen_data = data + i;
        end
    endgenerate

    initial begin
        data = 8'h00;
        count = 0;

        // Increment counter
        repeat (10) begin
            @(posedge clk);
            count = count + 1;
            data = data + 8'h10;
        end

        if (count == 10)
            $display("PASS: final count");
        else
            $display("FAIL: count = %0d", count);

        if (data == 8'hA0)
            $display("PASS: final data");
        else
            $display("FAIL: data = %h", data);

        // Check generate after the continuous assignment has been updated (4.7)
        #1;
        if (gen_loop[0].gen_data == 8'hA0)
            $display("PASS: generate");
        else
            $display("FAIL: gen = %h", gen_loop[0].gen_data);

        $display("TEST PASSED: final comprehensive tests completed");
        $finish;
    end
endmodule
