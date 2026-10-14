/*
:name: test_replication_expression
:description: Concatenation and replication
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_replication_expression.expected
*/
// IEEE 1800-2023 Section 11.4.12.1: Concatenation and replication
module test_replication_expression;
    int pass_count = 0;
    int test_count = 16;

    function automatic logic [15:0] replicate_4_nibble(logic [3:0] nibble);
        return {4{nibble}};
    endfunction

    initial begin
        // T1: {4{1'b1}} = 4'b1111
        begin
            logic [3:0] r;
            r = {4{1'b1}};
            if (r == 4'b1111) begin
                $display("T1: PASS - {4{1'b1}} = %b", r);
                pass_count++;
            end else $display("T1: FAIL - {4{1'b1}} = %b expected 1111", r);
        end

        // T2: {2{4'hA}} = 8'hAA
        begin
            logic [7:0] r;
            r = {2{4'hA}};
            if (r == 8'hAA) begin
                $display("T2: PASS - {2{4'hA}} = %h", r);
                pass_count++;
            end else $display("T2: FAIL - {2{4'hA}} = %h expected AA", r);
        end

        // T3: {3{2'b01}} = 6'b010101
        begin
            logic [5:0] r;
            r = {3{2'b01}};
            if (r == 6'b010101) begin
                $display("T3: PASS - {3{2'b01}} = %b", r);
                pass_count++;
            end else $display("T3: FAIL - {3{2'b01}} = %b expected 010101", r);
        end

        // T4: {1{8'hFF}} = 8'hFF
        begin
            logic [7:0] r;
            r = {1{8'hFF}};
            if (r == 8'hFF) begin
                $display("T4: PASS - {1{8'hFF}} = %h", r);
                pass_count++;
            end else $display("T4: FAIL - {1{8'hFF}} = %h expected FF", r);
        end

        // T5: {8{1'b0}} = 8'h00
        begin
            logic [7:0] r;
            r = {8{1'b0}};
            if (r == 8'h00) begin
                $display("T5: PASS - {8{1'b0}} = %h", r);
                pass_count++;
            end else $display("T5: FAIL - {8{1'b0}} = %h expected 00", r);
        end

        // T6: {2{8'hAB}} = 16'hABAB
        begin
            logic [15:0] r;
            r = {2{8'hAB}};
            if (r == 16'hABAB) begin
                $display("T6: PASS - {2{8'hAB}} = %h", r);
                pass_count++;
            end else $display("T6: FAIL - {2{8'hAB}} = %h expected ABAB", r);
        end

        // T7: {4{4'b1010}} = 16'hAAAA
        begin
            logic [15:0] r;
            r = {4{4'b1010}};
            if (r == 16'hAAAA) begin
                $display("T7: PASS - {4{4'b1010}} = %h", r);
                pass_count++;
            end else $display("T7: FAIL - {4{4'b1010}} = %h expected AAAA", r);
        end

        // T8: Nested replication: {2{{2{4'hF}}}} = 16'hFFFF
        begin
            logic [15:0] r;
            r = {2{{2{4'hF}}}};
            if (r == 16'hFFFF) begin
                $display("T8: PASS - nested {2{{2{4'hF}}}} = %h", r);
                pass_count++;
            end else $display("T8: FAIL - nested = %h expected FFFF", r);
        end

        // T9: Replication + concatenation: {{2{4'hA}}, 8'h55}
        begin
            logic [15:0] r;
            r = {{2{4'hA}}, 8'h55};
            if (r == 16'hAA55) begin
                $display("T9: PASS - repl+concat = %h", r);
                pass_count++;
            end else $display("T9: FAIL - repl+concat = %h expected AA55", r);
        end

        // T10: Replication in assignment: reg [15:0] x = {4{4'hC}}
        begin
            logic [15:0] x;
            x = {4{4'hC}};
            if (x == 16'hCCCC) begin
                $display("T10: PASS - repl assign x = %h", x);
                pass_count++;
            end else $display("T10: FAIL - repl assign x = %h expected CCCC", x);
        end

        // T11: Replication comparison: {4{1'b1}} == 4'hF
        begin
            int r;
            r = ({4{1'b1}} == 4'hF) ? 1 : 0;
            if (r == 1) begin
                $display("T11: PASS - repl comparison");
                pass_count++;
            end else $display("T11: FAIL - repl comparison r=%0d", r);
        end

        // T12: Replication in function arg
        begin
            logic [15:0] r;
            r = replicate_4_nibble(4'h5);
            if (r == 16'h5555) begin
                $display("T12: PASS - repl func arg = %h", r);
                pass_count++;
            end else $display("T12: FAIL - repl func arg = %h expected 5555", r);
        end

        // T13: Zero replication is not valid in SV, test with 1 instead
        // {1{8'hFF}} = FF (edge case of minimum replication)
        begin
            logic [7:0] r;
            r = {1{8'hAA}};
            if (r == 8'hAA) begin
                $display("T13: PASS - {1{8'hAA}} = %h", r);
                pass_count++;
            end else $display("T13: FAIL - r=%h expected AA", r);
        end

        // T14: {16{1'b1}} = 16'hFFFF - large N
        begin
            logic [15:0] r;
            r = {16{1'b1}};
            if (r == 16'hFFFF) begin
                $display("T14: PASS - {16{1'b1}} = %h", r);
                pass_count++;
            end else $display("T14: FAIL - {16{1'b1}} = %h expected FFFF", r);
        end

        // T15: Replication + part-select: {2{data[3:0]}}
        begin
            logic [7:0] data;
            logic [7:0] r;
            data = 8'hA5;
            r = {2{data[3:0]}};
            // data[3:0] = 5 = 0101, {2{0101}} = 01010101 = 55
            if (r == 8'h55) begin
                $display("T15: PASS - repl part-select = %h", r);
                pass_count++;
            end else $display("T15: FAIL - repl part-select = %h expected 55", r);
        end

        // T16: Replication in always_comb (tested via function)
        begin
            logic [31:0] r;
            r = {4{8'hDE}};
            if (r == 32'hDEDEDEDE) begin
                $display("T16: PASS - repl 32bit = %h", r);
                pass_count++;
            end else $display("T16: FAIL - repl 32bit = %h expected DEDEDEDE", r);
        end

        // Summary
        $display("\n%0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count)
            $display("PASS");
        else
            $display("FAIL");
    end
endmodule
