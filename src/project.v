/*
 * Tiny Cyberdeck - CYBER DODGE
 * Hannelle Chua
 * IEEE Philippine BootCamp 2026
 *
 * Controls:
 * ui_in[0] = LEFT
 * ui_in[1] = RIGHT
 * ui_in[2] = START / RESTART
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

    // ============================================================
    // VGA TIMING - 640x480
    // ============================================================

    reg [9:0] h_count;
    reg [9:0] v_count;

    wire frame_tick;

    assign frame_tick =
        (h_count == 10'd799) &&
        (v_count == 10'd524);

    always @(posedge clk) begin
        if (!rst_n) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end
        else begin
            if (h_count == 10'd799) begin
                h_count <= 10'd0;

                if (v_count == 10'd524)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 10'd1;
            end
            else begin
                h_count <= h_count + 10'd1;
            end
        end
    end

    wire hsync =
        ~((h_count >= 10'd656) &&
          (h_count <  10'd752));

    wire vsync =
        ~((v_count >= 10'd490) &&
          (v_count <  10'd492));

    wire visible =
        (h_count < 10'd640) &&
        (v_count < 10'd480);


    // ============================================================
    // GAME STATE
    // ============================================================

    localparam STATE_WAIT = 2'd0;
    localparam STATE_PLAY = 2'd1;
    localparam STATE_OVER = 2'd2;

    reg [1:0] game_state;

    // Player
    reg [9:0] player_x;

    localparam PLAYER_Y = 10'd410;
    localparam PLAYER_W = 10'd40;
    localparam PLAYER_H = 10'd20;

    // Falling enemy
    reg [9:0] enemy_x;
    reg [9:0] enemy_y;

    localparam ENEMY_W = 10'd35;
    localparam ENEMY_H = 10'd35;

    // Score
    reg [7:0] score;

    // Pseudo-random generator
    reg [15:0] lfsr;

    // Slow movement divider
    reg [2:0] move_divider;

    // Start button edge detection
    reg start_previous;

    wire start_pressed =
        ui_in[2] && !start_previous;


    // ============================================================
    // GAME LOGIC
    // ============================================================

    always @(posedge clk) begin

        if (!rst_n) begin

            game_state     <= STATE_WAIT;

            player_x       <= 10'd300;

            enemy_x        <= 10'd150;
            enemy_y        <= 10'd70;

            score          <= 8'd0;

            lfsr           <= 16'hACE1;

            move_divider   <= 3'd0;

            start_previous <= 1'b0;
        end

        else begin

            start_previous <= ui_in[2];

            // LFSR pseudo-random generator
            lfsr <= {
                lfsr[14:0],
                lfsr[15] ^
                lfsr[13] ^
                lfsr[12] ^
                lfsr[10]
            };

            if (frame_tick) begin

                move_divider <= move_divider + 3'd1;

                // --------------------------------------------
                // WAITING SCREEN
                // --------------------------------------------

                if (game_state == STATE_WAIT) begin

                    if (start_pressed) begin
                        game_state <= STATE_PLAY;

                        player_x <= 10'd300;

                        enemy_x <= 10'd100 +
                                   {2'b00, lfsr[8:1]};

                        enemy_y <= 10'd60;

                        score <= 8'd0;
                    end
                end


                // --------------------------------------------
                // GAMEPLAY
                // --------------------------------------------

                else if (game_state == STATE_PLAY) begin

                    // Player movement

                    if (ui_in[0] && !ui_in[1]) begin
                        if (player_x > 10'd70)
                            player_x <= player_x - 10'd5;
                    end

                    else if (ui_in[1] && !ui_in[0]) begin
                        if (player_x < 10'd530)
                            player_x <= player_x + 10'd5;
                    end


                    // Enemy movement
                    if (move_divider[0] == 1'b1) begin

                        if (enemy_y < 10'd445) begin
                            enemy_y <= enemy_y + 10'd6;
                        end

                        else begin

                            enemy_y <= 10'd60;

                            enemy_x <=
                                10'd70 +
                                {1'b0, lfsr[8:0]};

                            score <= score + 8'd1;
                        end
                    end


                    // Collision detection
                    if (
                        (player_x < enemy_x + ENEMY_W) &&
                        (player_x + PLAYER_W > enemy_x) &&
                        (PLAYER_Y < enemy_y + ENEMY_H) &&
                        (PLAYER_Y + PLAYER_H > enemy_y)
                    ) begin

                        game_state <= STATE_OVER;
                    end
                end


                // --------------------------------------------
                // GAME OVER
                // --------------------------------------------

                else if (game_state == STATE_OVER) begin

                    if (start_pressed) begin

                        game_state <= STATE_PLAY;

                        player_x <= 10'd300;

                        enemy_x <= 10'd100 +
                                   {2'b00, lfsr[8:1]};

                        enemy_y <= 10'd60;

                        score <= 8'd0;
                    end
                end
            end
        end
    end


    // ============================================================
    // DRAWING
    // ============================================================

    wire border =
        ((h_count >= 10'd50) &&
         (h_count <  10'd590) &&
         (v_count >= 10'd40) &&
         (v_count <  10'd46))

        ||

        ((h_count >= 10'd50) &&
         (h_count <  10'd590) &&
         (v_count >= 10'd450) &&
         (v_count <  10'd456))

        ||

        ((h_count >= 10'd50) &&
         (h_count <  10'd56) &&
         (v_count >= 10'd40) &&
         (v_count <  10'd456))

        ||

        ((h_count >= 10'd584) &&
         (h_count <  10'd590) &&
         (v_count >= 10'd40) &&
         (v_count <  10'd456));


    wire player_pixel =
        (h_count >= player_x) &&
        (h_count < player_x + PLAYER_W) &&
        (v_count >= PLAYER_Y) &&
        (v_count < PLAYER_Y + PLAYER_H);


    wire enemy_pixel =
        (h_count >= enemy_x) &&
        (h_count < enemy_x + ENEMY_W) &&
        (v_count >= enemy_y) &&
        (v_count < enemy_y + ENEMY_H);


    // Decorative background grid
    wire grid =
        (h_count[5:0] == 6'd0) ||
        (v_count[5:0] == 6'd0);


    // Waiting screen center icon
    wire start_icon =
        (h_count >= 10'd270) &&
        (h_count <  10'd370) &&
        (v_count >= 10'd190) &&
        (v_count <  10'd290);


    // Game-over cross
    wire over_horizontal =
        (h_count >= 10'd220) &&
        (h_count <  10'd420) &&
        (v_count >= 10'd230) &&
        (v_count <  10'd250);

    wire over_vertical =
        (h_count >= 10'd310) &&
        (h_count <  10'd330) &&
        (v_count >= 10'd140) &&
        (v_count <  10'd340);


    // Score bar
    wire score_bar =
        (h_count >= 10'd70) &&
        (h_count <
            (10'd70 + {score[5:0], 2'b00})) &&
        (v_count >= 10'd65) &&
        (v_count <  10'd75);


    // ============================================================
    // COLOR GENERATION
    // ============================================================

    reg [1:0] red;
    reg [1:0] green;
    reg [1:0] blue;

    always @(*) begin

        red   = 2'b00;
        green = 2'b00;
        blue  = 2'b00;

        if (visible) begin

            // Background grid
            if (grid) begin
                blue = 2'b01;
            end


            // Cyber border
            if (border) begin
                green = 2'b11;
                blue  = 2'b11;
            end


            // ================================================
            // WAIT SCREEN
            // ================================================

            if (game_state == STATE_WAIT) begin

                if (start_icon) begin
                    green = 2'b11;
                    blue  = 2'b11;
                end
            end


            // ================================================
            // GAME
            // ================================================

            else if (game_state == STATE_PLAY) begin

                // Score
                if (score_bar) begin
                    green = 2'b11;
                    blue  = 2'b01;
                end

                // Enemy
                if (enemy_pixel) begin
                    red   = 2'b11;
                    green = 2'b00;
                    blue  = 2'b01;
                end

                // Player
                if (player_pixel) begin
                    red   = 2'b00;
                    green = 2'b11;
                    blue  = 2'b11;
                end
            end


            // ================================================
            // GAME OVER
            // ================================================

            else if (game_state == STATE_OVER) begin

                if (over_horizontal ||
                    over_vertical) begin

                    red   = 2'b11;
                    green = 2'b00;
                    blue  = 2'b00;
                end
            end
        end
    end


    // ============================================================
    // TINY VGA OUTPUT MAPPING
    // ============================================================

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


    // Unused inputs
    wire _unused =
        &{
            ena,
            uio_in,
            ui_in[7:3],
            1'b0
        };

endmodule

`default_nettype wire
