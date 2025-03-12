const std = @import("std");
const rl = @import("raylib");

const Game = struct {
    window: rl.Vector2 = .{
        .x = 800,
        .y = 450,
    },
};

// global
const game = Game{}; // var soon

const Player = struct {
    n: u4,
    pos: rl.Vector2,
    dim: rl.Vector2,
    color: rl.Color,

    speed: f32 = 10,
    velocity: rl.Vector2 = .{ .x = 0, .y = 0 },

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

        return .{
            .n = n,
            .pos = pos,
            .dim = dim,
            .color = .red,
        };
    }

    pub fn setDirection(self: *Player, direction: i2) void {
        self.velocity.y = @as(f32, @floatFromInt(direction)) * self.speed;
    }

    pub fn update(self: *Player) void {
        self.pos.x += self.velocity.x;
        self.pos.y += self.velocity.y;
    }

    pub fn draw(self: Player) void {
        rl.drawRectangleV(self.pos, self.dim, self.color);
    }

};

pub fn main() anyerror!void {
    rl.initWindow(@intFromFloat(game.window.x),
                  @intFromFloat(game.window.y),
                  "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var p1 = Player.init(1);
    var p2 = Player.init(2);

    while (!rl.windowShouldClose()) {
        if (rl.isKeyDown(.w)) {
            p1.setDirection(-1);

            std.debug.print("W", .{});
        } else if (rl.isKeyDown(.s)) {
            p1.setDirection(1);

            std.debug.print("S", .{});
        } else {
            p1.setDirection(0);
        }

        p1.update();
        p2.update();

        rl.beginDrawing();

        rl.clearBackground(rl.Color.black);
        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);

        p1.draw();
        p2.draw();

        rl.endDrawing();

    }
}
