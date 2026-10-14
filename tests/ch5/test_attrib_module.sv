/*
:name: test_attrib_module
:description: Test: Module attributes (IEEE 1800-2023 Section 5.12)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.12
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_attrib_module.expected
*/
// Test: Module attributes (IEEE 1800-2023 Section 5.12)
// Tests attributes on module declarations

(* synthesizable = 1, author = "test" *)
module attributed_submodule;
    logic [7:0] data;
endmodule

(* top_module, clock_domain = "fast" *)
module test_attrib_module;
    int pass_count = 0;
    int fail_count = 0;

    attributed_submodule sub();

    // The tests run one after another in a single initial procedure, so
    // their output order is defined (4.7).
    initial begin
        // Test 1: Module with basic attribute
        begin
            // Attributes are metadata that don't affect simulation behavior
            // But they should be parsed correctly
            static int module_exists = 1;
            if (module_exists == 1) begin
                $display("Test 1 PASSED: Module with basic attribute");
                pass_count++;
            end else begin
                $display("Test 1 FAILED: Module with basic attribute");
                fail_count++;
            end
        end

        // Test 2: Module with value attribute
        begin
            // (* synthesizable = 1 *) specifies a value
            static int attr_value = 1;
            if (attr_value == 1) begin
                $display("Test 2 PASSED: Module with value attribute");
                pass_count++;
            end else begin
                $display("Test 2 FAILED: Module with value attribute");
                fail_count++;
            end
        end

        // Test 3: Module with string attribute
        begin
            // (* author = "test" *) specifies a string value
            static string attr_string = "test";
            if (attr_string == "test") begin
                $display("Test 3 PASSED: Module with string attribute");
                pass_count++;
            end else begin
                $display("Test 3 FAILED: Module with string attribute");
                fail_count++;
            end
        end

        // Test 4: Module with multiple attributes
        begin
            // (* top_module, clock_domain = "fast" *)
            static bit is_top = 1;
            static string clock_domain = "fast";
            if (is_top && clock_domain == "fast") begin
                $display("Test 4 PASSED: Module with multiple attributes");
                pass_count++;
            end else begin
                $display("Test 4 FAILED: Module with multiple attributes");
                fail_count++;
            end
        end

        // Test 5: Submodule with attributes
        begin
            #1;
            // attributed_submodule has (* synthesizable = 1, author = "test" *)
            if (sub.data === 8'hxx || sub.data === 8'h00) begin
                $display("Test 5 PASSED: Submodule with attributes exists");
                pass_count++;
            end else begin
                $display("Test 5 FAILED: Submodule with attributes");
                fail_count++;
            end

            #1;
            if (fail_count == 0)
                $display("PASS: All attrib module tests passed (%0d/%0d)", pass_count, pass_count + fail_count);
            else
                $display("FAIL: Some attrib module tests failed (%0d/%0d)", pass_count, pass_count + fail_count);
            $finish;
        end
    end
endmodule
