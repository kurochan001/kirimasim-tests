/*
:name: test_ct_assignment_complex
:description: Signals for NBA tests
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4 10.6.2 11.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ct_assignment_complex.expected
*/
module test_ct_assignment_complex;
    int pass_count = 0;
    int test_count = 17;

    logic clk = 0;
    always #5 clk = ~clk;

    // Signals for NBA tests
    logic [7:0] nba_reg;
    logic [7:0] nba_arr[4];
    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
    } pair_t;
    pair_t nba_struct;
    logic [15:0] nba_packed;

    // Force/release targets
    logic [7:0] force_sig;
    logic force_bit;

    // Module-level array for task output test (T13)
    int t13_arr[3];

    // Tasks declared in the module
    task automatic t13_set_element(output int val);
        val = 999;
    endtask

    task automatic t14_compute(input int a, input int b, output int result);
        result = a + b;
    endtask

    initial begin
        // T1: Force and release
        begin
            force_sig = 8'h00;
            #1;
            force force_sig = 8'hFF;
            #1;
            if (force_sig == 8'hFF) begin
                release force_sig;
                force_sig = 8'h42;
                #1;
                if (force_sig == 8'h42) begin
                    $display("T1: PASS - force/release");
                    pass_count++;
                end else
                    $display("T1: FAIL - after release=%0h", force_sig);
            end else
                $display("T1: FAIL - force=%0h", force_sig);
        end

        begin
            static logic [7:0] val = 8'h00;
            val[0] = 1'b1;
            val[7] = 1'b1;
            if (val == 8'h81) begin
                $display("T2: PASS - bit-select write %0h", val);
                pass_count++;
            end else
                $display("T2: FAIL - val=%0h", val);
        end

        // T3: Part-select write
        begin
            static logic [15:0] val = 16'h0000;
            val[7:0] = 8'hAB;
            val[15:8] = 8'hCD;
            if (val == 16'hCDAB) begin
                $display("T3: PASS - part-select write %0h", val);
                pass_count++;
            end else
                $display("T3: FAIL - val=%0h", val);
        end

        // T4: Indexed plus part-select +: write
        begin
            static logic [31:0] val = 32'h0;
            val[8 +: 8] = 8'hFF;
            if (val == 32'h0000FF00) begin
                $display("T4: PASS - indexed +: write %0h", val);
                pass_count++;
            end else
                $display("T4: FAIL - val=%0h", val);
        end

        // T5: Indexed minus part-select -: write
        begin
            static logic [31:0] val = 32'h0;
            val[15 -: 8] = 8'hAA;
            if (val == 32'h0000AA00) begin
                $display("T5: PASS - indexed -: write %0h", val);
                pass_count++;
            end else
                $display("T5: FAIL - val=%0h", val);
        end

        // T6: Concatenation LHS assignment
        begin
            logic [7:0] hi, lo;
            {hi, lo} = 16'hABCD;
            if (hi == 8'hAB && lo == 8'hCD) begin
                $display("T6: PASS - concat LHS hi=%0h lo=%0h", hi, lo);
                pass_count++;
            end else
                $display("T6: FAIL - hi=%0h lo=%0h", hi, lo);
        end

        begin
            static logic [7:0] arr[4] = '{8'h00, 8'h00, 8'h00, 8'h00};
            arr[1][3] = 1'b1;
            arr[2][7] = 1'b1;
            if (arr[1] == 8'h08 && arr[2] == 8'h80) begin
                $display("T7: PASS - array bit-select");
                pass_count++;
            end else
                $display("T7: FAIL - arr[1]=%0h arr[2]=%0h", arr[1], arr[2]);
        end

        // T8: NBA simple (non-blocking assignment)
        @(posedge clk);
        nba_reg <= 8'hAA;
        @(posedge clk);
        if (nba_reg == 8'hAA) begin
            $display("T8: PASS - NBA simple %0h", nba_reg);
            pass_count++;
        end else
            $display("T8: FAIL - nba_reg=%0h", nba_reg);

        // T9: NBA to struct packed
        @(posedge clk);
        nba_struct <= '{a: 8'h12, b: 8'h34};
        @(posedge clk);
        if (nba_struct.a == 8'h12 && nba_struct.b == 8'h34) begin
            $display("T9: PASS - NBA struct %0h,%0h", nba_struct.a, nba_struct.b);
            pass_count++;
        end else
            $display("T9: FAIL");

        // T10: NBA to array element
        @(posedge clk);
        nba_arr[0] <= 8'h10;
        nba_arr[1] <= 8'h20;
        nba_arr[2] <= 8'h30;
        nba_arr[3] <= 8'h40;
        @(posedge clk);
        if (nba_arr[0] == 8'h10 && nba_arr[1] == 8'h20 &&
            nba_arr[2] == 8'h30 && nba_arr[3] == 8'h40) begin
            $display("T10: PASS - NBA array");
            pass_count++;
        end else
            $display("T10: FAIL");

        // T11: Multiple NBA to same target
        @(posedge clk);
        nba_reg <= 8'h11;
        nba_reg <= 8'h22;
        nba_reg <= 8'h33;
        @(posedge clk);
        if (nba_reg == 8'h33) begin
            $display("T11: PASS - multiple NBA last wins %0h", nba_reg);
            pass_count++;
        end else
            $display("T11: FAIL - nba_reg=%0h", nba_reg);

        // T12: Concat NBA
        begin
            logic [3:0] ch, cl;
            ch = 4'h0; cl = 4'h0;
            @(posedge clk);
            {ch, cl} <= 8'hAB;
            @(posedge clk);
            if (ch == 4'hA && cl == 4'hB) begin
                $display("T12: PASS - concat NBA ch=%0h cl=%0h", ch, cl);
                pass_count++;
            end else
                $display("T12: FAIL - ch=%0h cl=%0h", ch, cl);
        end

        // T14: Task output to variable
        begin
            int r;
            t14_compute(10, 20, r);
            if (r == 30) begin
                $display("T14: PASS - task output r=%0d", r);
                pass_count++;
            end else
                $display("T14: FAIL - r=%0d", r);
        end

        // T15: Compound assignment operators
        begin
            static int val = 10;
            val += 5;   // 15
            val -= 3;   // 12
            val *= 2;   // 24
            val /= 4;   // 6
            if (val == 6) begin
                $display("T15: PASS - compound assign val=%0d", val);
                pass_count++;
            end else
                $display("T15: FAIL - val=%0d", val);
        end

        // T16: Pre/post increment/decrement
        begin
            static int a = 10;
            int b;
            b = a++;
            if (b == 10 && a == 11) begin
                int c;
                c = ++a;
                if (c == 12 && a == 12) begin
                    $display("T16: PASS - inc/dec a=%0d", a);
                    pass_count++;
                end else
                    $display("T16: FAIL - pre-inc c=%0d a=%0d", c, a);
            end else
                $display("T16: FAIL - post-inc b=%0d a=%0d", b, a);
        end

        // T17: 2D array assignment
        begin
            int arr2d[2][3];
            for (int i = 0; i < 2; i++)
                for (int j = 0; j < 3; j++)
                    arr2d[i][j] = i * 10 + j;
            if (arr2d[0][0] == 0 && arr2d[0][2] == 2 &&
                arr2d[1][0] == 10 && arr2d[1][2] == 12) begin
                $display("T17: PASS - 2D array");
                pass_count++;
            end else
                $display("T17: FAIL");
        end

        // T18: Hierarchical path signal
        begin
            // Test within same module scope
            nba_packed = 16'hBEEF;
            #1;
            if (nba_packed == 16'hBEEF) begin
                $display("T18: PASS - packed NBA %0h", nba_packed);
                pass_count++;
            end else
                $display("T18: FAIL - nba_packed=%0h", nba_packed);
        end

        $display("pass_count = %0d / %0d", pass_count, test_count);
        if (pass_count == test_count)
            $display("PASS: test_ct_assignment_complex");
        else
            $display("FAIL: test_ct_assignment_complex (pass_count=%0d/%0d)", pass_count, test_count);
        $finish;
    end
endmodule
