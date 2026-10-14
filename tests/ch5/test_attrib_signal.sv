/*
:name: test_attrib_signal
:description: Test: Signal attributes (IEEE 1800-2023 Section 5.12)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_attrib_signal.expected
*/
// Test: Signal attributes (IEEE 1800-2023 Section 5.12)
// Tests attributes on signal declarations

module test_attrib_signal;
    int pass_count = 0;
    int fail_count = 0;

    // Signals with various attributes
    (* keep *)
    logic [7:0] keep_signal;

    (* dont_touch, optimize = 0 *)
    logic [15:0] preserved_signal;

    (* fsm_encoding = "one_hot" *)
    logic [3:0] state;

    (* ram_style = "block" *)
    logic [7:0] memory [0:255];

    (* full_case, parallel_case *)
    logic [1:0] case_sel;

    // The tests run one after another in a single initial procedure, so
    // their output order is defined (4.7).
    initial begin
        // Test 1: Signal with keep attribute
        begin
            keep_signal = 8'hAA;
            if (keep_signal == 8'hAA) begin
                $display("Test 1 PASSED: Signal with keep attribute");
                pass_count++;
            end else begin
                $display("Test 1 FAILED: Signal with keep attribute");
                fail_count++;
            end
        end

        // Test 2: Signal with multiple attributes
        begin
            preserved_signal = 16'h1234;
            if (preserved_signal == 16'h1234) begin
                $display("Test 2 PASSED: Signal with multiple attributes (dont_touch, optimize)");
                pass_count++;
            end else begin
                $display("Test 2 FAILED: Signal with multiple attributes");
                fail_count++;
            end
        end

        // Test 3: FSM state with encoding attribute
        begin
            state = 4'b0001;  // One-hot state 0
            #1;
            state = 4'b0010;  // One-hot state 1
            if (state == 4'b0010) begin
                $display("Test 3 PASSED: FSM state with encoding attribute");
                pass_count++;
            end else begin
                $display("Test 3 FAILED: FSM state with encoding attribute");
                fail_count++;
            end
        end

        // Test 4: Memory with ram_style attribute
        begin
            #2;
            memory[0] = 8'h55;
            memory[255] = 8'hAA;
            if (memory[0] == 8'h55 && memory[255] == 8'hAA) begin
                $display("Test 4 PASSED: Memory with ram_style attribute");
                pass_count++;
            end else begin
                $display("Test 4 FAILED: Memory with ram_style attribute");
                fail_count++;
            end
        end

        // Test 5: Case selector with synthesis attributes
        begin
            #3;
            case_sel = 2'b10;
            // full_case and parallel_case are synthesis directives
            case (case_sel)
                2'b00: ;
                2'b01: ;
                2'b10: ;
                2'b11: ;
            endcase
            if (case_sel == 2'b10) begin
                $display("Test 5 PASSED: Case selector with synthesis attributes");
                pass_count++;
            end else begin
                $display("Test 5 FAILED: Case selector with synthesis attributes");
                fail_count++;
            end

            #1;
            if (fail_count == 0)
                $display("PASS: All attrib signal tests passed (%0d/%0d)", pass_count, pass_count + fail_count);
            else
                $display("FAIL: Some attrib signal tests failed (%0d/%0d)", pass_count, pass_count + fail_count);
            $finish;
        end
    end
endmodule
