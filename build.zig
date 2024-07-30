const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zigscript_exe = blk: {
        const exe = b.addExecutable(.{
            .name = "zigscript",
            .root_source_file = b.path("cmdline.zig"),
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
        break :blk exe;
    };

    const test_step = b.step("test", "Run some tests");

    {
        const exe = b.addExecutable(.{
            .name = "zigscript-test",
            .root_source_file = b.path("test.zig"),
            .target = target,
            .optimize = optimize,
        });
        const run = b.addRunArtifact(exe);
        run.expectStdOutEqual(
            \\Hello, World!
            \\Hello, World with Concat!
            \\Hello Vars!
            \\
        );
        test_step.dependOn(&run.step);
    }
    {
        const run = b.addRunArtifact(zigscript_exe);
        run.addFileArg(b.path("examples/helloworld.zigscript"));
        run.expectStdOutEqual("Hello, World!\n");
        test_step.dependOn(&run.step);
    }
}
