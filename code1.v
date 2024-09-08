module fp_multiplier(
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,
    output [31:0] result,
    output reg overflow,
    output reg underflow,
    output reg inf,
    output reg nan
);

    // Parameters
    parameter EXP_WIDTH = 8;
    parameter MANTISSA_WIDTH = 23;
    parameter ROUNDING_MODE = 0; // 0: round to nearest, 1: round towards zero, 2: round towards +inf, 3: round towards -inf

    // Signals
    reg [EXP_WIDTH-1:0] exp_a, exp_b, exp_result;
    reg [MANTISSA_WIDTH-1:0] mantissa_a, mantissa_b, mantissa_result;
    reg sign_result;

    // Check for special cases
    always @(*) begin
        if (a[30:23] == 2**EXP_WIDTH - 1 && a[22:0] != 0) begin // NaN
            inf <= 0;
            nan <= 1;
        end else if (a[30:23] == 2**EXP_WIDTH - 1 && a[22:0] == 0) begin // Infinity
            inf <= 1;
            nan <= 0;
        end else if (a[30:23] == 0 && a[22:0] == 0) begin // Zero
            inf <= 0;
            nan <= 0;
        end else begin
            inf <= 0;
            nan <= 0;
        end
    end

    // Extract components
    always @(*) begin
        exp_a = a[30:23];
        mantissa_a = a[22:0];
        exp_b = b[30:23];
        mantissa_b = b[22:0];
        sign_result = a[31] ^ b[31];
    end

    // Multiply mantissas
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            mantissa_result <= 0;
        end else begin
            mantissa_result <= mantissa_a * mantissa_b;
        end
    end

    // Add exponents and adjust for normalization
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            exp_result <= 0;
        end else begin
            exp_result <= exp_a + exp_b - (EXP_WIDTH - 1); // Adjust for normalization

            // Check for overflow/underflow
            if (exp_result >= 2**EXP_WIDTH - 1) begin
                overflow <= 1;
                underflow <= 0;
                exp_result <= 2**EXP_WIDTH - 1;
            end else if (exp_result <= 0) begin
                overflow <= 0;
                underflow <= 1;
                exp_result <= 0;
            end else begin
                overflow <= 0;
                underflow <= 0;
            end
        end
    end

    // Round the result
    always @(*) begin
        case (ROUNDING_MODE)
            0: begin // Round to nearest
                if (mantissa_result[MANTISSA_WIDTH-1]) begin
                    if (mantissa_result[MANTISSA_WIDTH-2]) begin
                        mantissa_result <= mantissa_result + 1;
                        if (mantissa_result == 0) begin
                            exp_result <= exp_result + 1;
                        end
                    end
                end
            end
            1: begin // Round towards zero
                // Do nothing
            end
            2: begin // Round towards +inf
                if (mantissa_result[MANTISSA_WIDTH-1] && sign_result) begin
                    mantissa_result <= mantissa_result + 1;
                    if (mantissa_result == 0) begin
                        exp_result <= exp_result + 1;
                    end
                end
            end
            3: begin // Round towards -inf
                if (mantissa_result[MANTISSA_WIDTH-1] && !sign_result) begin
                    mantissa_result <= mantissa_result + 1;
                    if (mantissa_result == 0) begin
                        exp_result <= exp_result + 1;
                    end
                end
            end
            default: begin
                // Handle invalid rounding mode
                result <= {1'b1, 2**EXP_WIDTH - 1, 0}; // Set result to NaN
            end
        end
    end

    // Assemble result
    always @(*) begin
        if (inf) begin
            result <= {sign_result, 2**EXP_WIDTH - 1, 0};
        end else if (nan) begin
            result <= {1'b1, 2**EXP_WIDTH - 1, 0};
        end else begin
            result[31] <= sign_result;
            result[30:23] <= exp_result;
            result[22:0] <= mantissa_result;
        end
    end

endmodule