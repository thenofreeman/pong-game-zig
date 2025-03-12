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
    pos: rl.Vector2,
    dim: rl.Vector2,
    color: rl.Color,
    n: i4,

    pub fn init(n: i4) Player {
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
            .pos = pos,
            .dim = dim,
            .color = .red,
            .n = n,
        };
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
        if (rl.isKeyDown(.right)) {
            std.debug.print("RIGHT", .{});
        }

        rl.beginDrawing();

        rl.clearBackground(rl.Color.black);
        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);

        p1.draw();
        p2.draw();

        rl.endDrawing();

    }
}
