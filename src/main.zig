const std = @import("std");
const rl = @import("raylib");

// const rand = std.Random.DefaultPrng.init(blk: {
//     var seed: u64 = undefined;
//     try std.posix.getrandom(std.mem.asBytes(&seed));
//     break :blk seed;
// }).random();
const rand = std.crypto.random;

const State = enum {
    MENU,
    PLAYING,
    PAUSED,
    GAMEOVER,
};

const Game = struct {
    window: rl.Vector2 = .{
        .x = 800,
        .y = 450,
    },

    topLeftCorner: rl.Vector2 = .{ .x = 0, .y = 0 },
    topRightCorner: rl.Vector2 = .{ .x = 800, .y = 0, },
    bottomLeftCorner: rl.Vector2 = .{ .x = 0, .y = 450, },
    bottomRightCorner: rl.Vector2 = .{ .x = 800, .y = 450, },

};

// global
const game = Game{}; // var soon

const Player = struct {
    n: u4,
    body: rl.Rectangle,
    color: rl.Color,

    speed: f32 = 10,
    velocity: rl.Vector2 = .{ .x = 0, .y = 0 },

    score: u16 = 0,

    pub fn init(n: u4) Player {
        const dim: rl.Vector2 = .{ .x = 15, .y = 120 };
        const pos: rl.Vector2 = switch (n) {
            1 => .{
                .x = 0,
                .y = 100
            },
            2 => .{
                .x = game.window.x - dim.x,
                .y = game.window.y - 100
            },
            else => { @panic("NO!"); }
        };

        var newPlayer: Player = .{
            .n = n,
            .body = rl.Rectangle.init( pos.x, pos.y, dim.x, dim.y ),
            .color = .red,
        };

        newPlayer.reset();

        return newPlayer;
    }

    pub fn reset(self: *Player) void {
        self.score = 0;
    }

    pub fn setDirection(self: *Player, direction: i2) void {
        self.velocity.y = @as(f32, @floatFromInt(direction)) * self.speed;
    }

    pub fn update(self: *Player) void {
        self.body.x += self.velocity.x;
        self.body.y += self.velocity.y;
    }

    pub fn draw(self: Player) void {
        rl.drawRectangleRec(self.body, self.color);
    }

};

const Ball = struct {
    n: u4,
    pos: rl.Vector2,
    radius: f32,
    color: rl.Color,

    speed: f32 = 7,
    velocity: rl.Vector2 = .{ .x = 5, .y = 5 },

    pub fn init(n: u4) Ball {
        var newBall: Ball = .{
            .n = n,
            .pos = undefined,
            .radius = 8,
            .color = .white,
        };

        newBall.reset();

        return newBall;
    }

    pub fn setXDirection(self: *Ball, dir: i2) void {
        self.velocity.x = @as(f32, @floatFromInt(dir)) * self.speed;
    }

    pub fn setYDirection(self: *Ball, dir: i2) void {
        self.velocity.y = @as(f32, @floatFromInt(dir)) * self.speed;
    }

    pub fn reset(self: *Ball) void {
        self.pos = .{
            .x = game.window.x / 3.0 + @as(f32, @floatFromInt(rand.intRangeAtMost(u16, 0, @intFromFloat(game.window.x / 3.0)))),
            .y = game.window.y / 3.0 + @as(f32, @floatFromInt(rand.intRangeAtMost(u16, 0, @intFromFloat(game.window.y / 3.0)))),
        };

        self.setXDirection(if (rand.boolean()) 1 else -1);
        self.setYDirection(if (rand.boolean()) 1 else -1);
    }

    pub fn update(self: *Ball) void {
        self.pos.x += self.velocity.x;
        self.pos.y += self.velocity.y;
    }

    pub fn draw(self: Ball) void {
        rl.drawCircleV(self.pos, self.radius, self.color);
    }

};

pub fn main() anyerror!void {
    rl.initWindow(@intFromFloat(game.window.x),
                  @intFromFloat(game.window.y),
                  "Pong!");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var p1 = Player.init(1);
    var p2 = Player.init(2);
    var ball = Ball.init(2);

    var state: State = .MENU;

    var buf1: [16:0]u8 = undefined;
    var buf2: [16:0]u8 = undefined;
    var p1ScoreStr: [:0]u8 = try std.fmt.bufPrintZ(&buf1, "{}", .{p1.score});
    var p2ScoreStr: [:0]u8 = try std.fmt.bufPrintZ(&buf2, "{}", .{p2.score});

    while (!rl.windowShouldClose()) {

        switch (state) {
            .MENU => {
                if (rl.isKeyPressed(.space)) {
                    state = .PLAYING;
                }

                rl.beginDrawing();
                defer rl.endDrawing();

                rl.clearBackground(rl.Color.black);

                rl.drawText("Pong!", 380, 200, 20, rl.Color.light_gray);
            },
            .PLAYING => {
                if (rl.isKeyDown(.w)) {
                    p1.setDirection(-1);
                } else if (rl.isKeyDown(.s)) {
                    p1.setDirection(1);
                } else {
                    p1.setDirection(0);
                }

                if (rl.isKeyDown(.up)) {
                    p2.setDirection(-1);
                } else if (rl.isKeyDown(.down)) {
                    p2.setDirection(1);
                } else {
                    p2.setDirection(0);
                }

                if (rl.isKeyPressed(.space)) {
                    state = .PAUSED;
                }

                p1.update();
                p2.update();
                ball.update();

                if (rl.checkCollisionCircleRec(ball.pos, ball.radius, p1.body)) {
                    ball.setXDirection(1);
                } else if (rl.checkCollisionCircleRec(ball.pos, ball.radius, p2.body)) {
                    ball.setXDirection(-1);
                }

                if (rl.checkCollisionCircleLine(ball.pos, ball.radius, game.topLeftCorner, game.topRightCorner)) {
                    ball.setYDirection(1);
                } else if (rl.checkCollisionCircleLine(ball.pos, ball.radius, game.bottomLeftCorner, game.bottomRightCorner)) {
                    ball.setYDirection(-1);
                }

                if (rl.checkCollisionCircleLine(ball.pos, ball.radius, game.topLeftCorner, game.bottomLeftCorner)) {
                    p2.score += 1;

                    p2ScoreStr = try std.fmt.bufPrintZ(&buf2, "{}", .{p2.score});

                    ball.reset();
                } else if (rl.checkCollisionCircleLine(ball.pos, ball.radius, game.topRightCorner, game.bottomRightCorner)) {
                    p1.score += 1;

                    p1ScoreStr = try std.fmt.bufPrintZ(&buf1, "{}", .{p1.score});

                    ball.reset();
                }

                rl.beginDrawing();
                defer rl.endDrawing();

                rl.clearBackground(rl.Color.black);

                p1.draw();
                p2.draw();
                ball.draw();

                // draw player scores
                rl.drawText(p1ScoreStr, 50, 50, 20, rl.Color.light_gray);
                rl.drawText(p2ScoreStr, @intFromFloat(game.window.x - 50.0), 50, 20, rl.Color.light_gray);

                if (p1.score >= 7 or p2.score >= 7) {
                    state = .GAMEOVER;
                }

            },
            .PAUSED => {
                if (rl.isKeyPressed(.space)) {
                    state = .PLAYING;
                }

                rl.beginDrawing();
                defer rl.endDrawing();

                rl.clearBackground(rl.Color.black);

                rl.drawText("Paused.", 380, 200, 20, rl.Color.light_gray);

            },
            .GAMEOVER => {
                if (rl.isKeyPressed(.space)) {
                    state = .MENU;
                    p1.reset();
                    p2.reset();

                    p1ScoreStr = try std.fmt.bufPrintZ(&buf1, "{}", .{p1.score});
                    p2ScoreStr = try std.fmt.bufPrintZ(&buf2, "{}", .{p2.score});
                }

                rl.beginDrawing();
                defer rl.endDrawing();

                rl.clearBackground(rl.Color.black);

                rl.drawText(if (p1.score > p2.score) "Player 1 Wins!" else "Player 2 Wins!", 340, 200, 20, rl.Color.light_gray);
            },
        }
    }
}
