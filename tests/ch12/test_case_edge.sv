/*
:name: test_case_edge
:description: Case statement edge cases: defaults, item lists, casex, casez, unique, priority, nested case
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5 12.5.1 12.5.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_case_edge.expected
*/
// Case statement edge cases: defaults, item lists, casex, casez, unique, priority, nested case
module test_case_edge;
    int pass_count = 0;
    int test_count = 0;
    logic [3:0] sel;
    logic [7:0] result;
    
    initial begin
        // Test 1: Basic case
        test_count++;
        sel = 4'd2;
        case (sel)
            4'd0: result = 8'h00;
            4'd1: result = 8'h11;
            4'd2: result = 8'h22;
            4'd3: result = 8'h33;
            default: result = 8'hFF;
        endcase
        if (result == 8'h22) pass_count++;
        
        // Test 2: Default case
        test_count++;
        sel = 4'd15;
        case (sel)
            4'd0: result = 8'h00;
            4'd1: result = 8'h11;
            default: result = 8'hFF;
        endcase
        if (result == 8'hFF) pass_count++;
        
        // Test 3: Multiple values
        test_count++;
        sel = 4'd5;
        case (sel)
            4'd0, 4'd1: result = 8'hAA;
            4'd2, 4'd3, 4'd4: result = 8'hBB;
            4'd5, 4'd6, 4'd7: result = 8'hCC;
            default: result = 8'hDD;
        endcase
        if (result == 8'hCC) pass_count++;
        
        // Test 4: casex with X
        test_count++;
        sel = 4'b1010;
        casex (sel)
            4'b1xxx: result = 8'h10;
            4'b0xxx: result = 8'h00;
            default: result = 8'hFF;
        endcase
        if (result == 8'h10) pass_count++;
        
        // Test 5: casez with Z
        test_count++;
        sel = 4'b0101;
        casez (sel)
            4'b???1: result = 8'h01;
            4'b???0: result = 8'h00;
            default: result = 8'hFF;
        endcase
        if (result == 8'h01) pass_count++;
        
        // Test 6: Unique case
        test_count++;
        sel = 4'd3;
        unique case (sel)
            4'd0: result = 8'h00;
            4'd1: result = 8'h11;
            4'd2: result = 8'h22;
            4'd3: result = 8'h33;
        endcase
        if (result == 8'h33) pass_count++;
        
        // Test 7: Priority case
        test_count++;
        sel = 4'd2;
        priority case (sel)
            4'd0: result = 8'h00;
            4'd1: result = 8'h11;
            4'd2: result = 8'h22;
            default: result = 8'hFF;
        endcase
        if (result == 8'h22) pass_count++;
        
        // Test 8: Case with expression
        test_count++;
        sel = 4'd4;
        case (sel + 1)
            4'd5: result = 8'h55;
            default: result = 8'hFF;
        endcase
        if (result == 8'h55) pass_count++;
        
        // Test 9: Nested case
        test_count++;
        sel = 4'd1;
        case (sel)
            4'd0: result = 8'h00;
            4'd1: begin
                case (sel + 1)
                    4'd2: result = 8'h12;
                    default: result = 8'hFF;
                endcase
            end
            default: result = 8'hFF;
        endcase
        if (result == 8'h12) pass_count++;
        
        // Test 10: Empty case item
        test_count++;
        sel = 4'd7;
        result = 8'h00;
        case (sel)
            4'd0: ; // empty
            4'd7: result = 8'h77;
            default: result = 8'hFF;
        endcase
        if (result == 8'h77) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
