/*
:name: test_stmt_case_2
:description: Case statements test
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_case_2.expected
*/
// Case statements test
module test_case;
    int sel, result;
    logic [3:0] opcode;
    int pass_count = 0;

    initial begin
        // Scenario 1: Simple case with integer
        sel = 2;
        case (sel)
            0: result = 10;
            1: result = 20;
            2: result = 30;
            3: result = 40;
            default: result = -1;
        endcase
        if (result == 30) pass_count++;
        else $display("FAIL: Simple case with integer");

        // Scenario 2: Case with default
        sel = 10;
        case (sel)
            0: result = 10;
            1: result = 20;
            2: result = 30;
            default: result = 99;
        endcase
        if (result == 99) pass_count++;
        else $display("FAIL: Case with default");

        // Scenario 3: Case with multiple values per branch
        sel = 3;
        case (sel)
            0, 1: result = 100;
            2, 3: result = 200;
            4, 5: result = 300;
            default: result = 0;
        endcase
        if (result == 200) pass_count++;
        else $display("FAIL: Case with multiple values per branch");

        // Scenario 4: Case with logic type
        opcode = 4'b1010;
        case (opcode)
            4'b0000: result = 0;
            4'b0101: result = 1;
            4'b1010: result = 2;
            4'b1111: result = 3;
            default: result = -1;
        endcase
        if (result == 2) pass_count++;
        else $display("FAIL: Case with logic type");

        // Scenario 5: Nested case statements
        sel = 1;
        opcode = 4'b0011;
        case (sel)
            0: result = 0;
            1: begin
                case (opcode)
                    4'b0001: result = 10;
                    4'b0011: result = 30;
                    default: result = 99;
                endcase
            end
            default: result = -1;
        endcase
        if (result == 30) pass_count++;
        else $display("FAIL: Nested case statements");

        if (pass_count == 5) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
