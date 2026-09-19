/*
 * Tiny Cyberdeck - Interactive VGA Logic Core
 * Hannelle Chua
 * IEEE Philippine BootCamp 2026
 *
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_hannellechua_tiny_cyberdeck (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // ------------------------------------------------------------
    // VGA timing: 640x480 @ ~60 Hz with a 25 MHz clock
    // ------------------------------------------------------------

    reg [9:0] h_count;
    reg [9:0] v_count;

    always @(posedge clk) begin
        if (!rst_n) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else begin
            if (h_count == 10'd799) begin
                h_count <= 10'd0;

                if (v_count == 10'd524)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 10'd1;
            end else begin
                h_count <= h_count + 10'd1;
            end
        end
    end

    wire hsync = ~((h_count >= 10'd656) &&
                   (h_count <  10'd752));

    wire vsync = ~((v_count >= 10'd490) &&
                   (v_count <  10'd492));

    wire visible = (h_count < 10'd640) &&
                   (v_count < 10'd480);

    // ------------------------------------------------------------
    // Cyberdeck display regions
    // ------------------------------------------------------------

    // Outer frame
    wire border =
        ((h_count >= 10'd60)  && (h_count < 10'd580) &&
         (v_count >= 10'd50)  && (v_count < 10'd58)) ||

        ((h_count >= 10'd60)  && (h_count < 10'd580) &&
         (v_count >= 10'd422) && (v_count < 10'd430)) ||

        ((h_count >= 10'd60)  && (h_count < 10'd68) &&
         (v_count >= 10'd50)  && (v_count < 10'd430)) ||

        ((h_count >= 10'd572) && (h_count < 10'd580) &&
         (v_count >= 10'd50)  && (v_count < 10'd430));

    // Header line
    wire header =
        (h_count >= 10'd95)  &&
        (h_count <  10'd545) &&
        (v_count >= 10'd100) &&
        (v_count <  10'd108);

    // Four input indicators
    wire box0 =
        (h_count >= 10'd120) && (h_count < 10'd190) &&
        (v_count >= 10'd170) && (v_count < 10'd240);

    wire box1 =
        (h_count >= 10'd230) && (h_count < 10'd300) &&
        (v_count >= 10'd170) && (v_count < 10'd240);

    wire box2 =
        (h_count >= 10'd340) && (h_count < 10'd410) &&
        (v_count >= 10'd170) && (v_count < 10'd240);

    wire box3 =
        (h_count >= 10'd450) && (h_count < 10'd520) &&
        (v_count >= 10'd170) && (v_count < 10'd240);

    // Complementary/inverted indicators
    wire inv0 =
        (h_count >= 10'd120) && (h_count < 10'd190) &&
        (v_count >= 10'd290) && (v_count < 10'd350);

    wire inv1 =
        (h_count >= 10'd230) && (h_count < 10'd300) &&
        (v_count >= 10'd290) && (v_count < 10'd350);

    wire inv2 =
        (h_count >= 10'd340) && (h_count < 10'd410) &&
        (v_count >= 10'd290) && (v_count < 10'd350);

    wire inv3 =
        (h_count >= 10'd450) && (h_count < 10'd520) &&
        (v_count >= 10'd290) && (v_count < 10'd350);

    // Decorative cyber-grid
    wire grid =
        ((h_count[5:0] == 6'd0) ||
         (v_count[5:0] == 6'd0));

    // ------------------------------------------------------------
    // RGB generation
    // 2 bits per channel
    // ------------------------------------------------------------

    reg [1:0] red;
    reg [1:0] green;
    reg [1:0] blue;

    always @(*) begin
        red   = 2'b00;
        green = 2'b00;
        blue  = 2'b00;

        if (visible) begin

            // Dim blue background grid
            if (grid) begin
                blue = 2'b01;
            end

            // Cyan cyberdeck border/header
            if (border || header) begin
                red   = 2'b00;
                green = 2'b11;
                blue  = 2'b11;
            end

            // DIRECT INPUT ROW
            if (box0) begin
                if (ui_in[0]) begin
                    green = 2'b11;
                    blue  = 2'b01;
                end else begin
                    red = 2'b01;
                end
            end

            if (box1) begin
                if (ui_in[1]) begin
                    green = 2'b11;
                    blue  = 2'b01;
                end else begin
                    red = 2'b01;
                end
            end

            if (box2) begin
                if (ui_in[2]) begin
                    green = 2'b11;
                    blue  = 2'b01;
                end else begin
                    red = 2'b01;
                end
            end

            if (box3) begin
                if (ui_in[3]) begin
                    green = 2'b11;
                    blue  = 2'b01;
                end else begin
                    red = 2'b01;
                end
            end

            // INVERTED OUTPUT ROW
            if (inv0) begin
                if (!ui_in[0]) begin
                    red  = 2'b11;
                    blue = 2'b11;
                end else begin
                    blue = 2'b01;
                end
            end

            if (inv1) begin
                if (!ui_in[1]) begin
                    red  = 2'b11;
                    blue = 2'b11;
                end else begin
                    blue = 2'b01;
                end
            end

            if (inv2) begin
                if (!ui_in[2]) begin
                    red  = 2'b11;
                    blue = 2'b11;
                end else begin
                    blue = 2'b01;
                end
            end

            if (inv3) begin
                if (!ui_in[3]) begin
                    red  = 2'b11;
                    blue = 2'b11;
                end else begin
                    blue = 2'b01;
                end
            end
        end
    end

    // ------------------------------------------------------------
    // TinyVGA PMOD output mapping
    //
    // uo_out[0] = R1
    // uo_out[1] = G1
    // uo_out[2] = B1
    // uo_out[3] = VSYNC
    // uo_out[4] = R0
    // uo_out[5] = G0
    // uo_out[6] = B0
    // uo_out[7] = HSYNC
    // ------------------------------------------------------------

    assign uo_out[0] = red[1];
    assign uo_out[1] = green[1];
    assign uo_out[2] = blue[1];
    assign uo_out[3] = vsync;

    assign uo_out[4] = red[0];
    assign uo_out[5] = green[0];
    assign uo_out[6] = blue[0];
    assign uo_out[7] = hsync;

    // Bidirectional pins unused
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Mark unused inputs
    wire _unused = &{ena, uio_in, ui_in[7:4], 1'b0};

endmodule

`default_nettype wire
