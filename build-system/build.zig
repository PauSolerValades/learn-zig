const std = @import("std");
const Build = std.Build;

pub fn builda(b: *Build) void {
    // Crea un node al DAG
    const exe: *Build.Step.Compile = b.addExecutable(.{
        .name = "hello_world",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host,
        }),
    });
    // afegeix la dependencia entre Install (root) i Compile
    // és a dir, aresta entre compile i install, no es pot instalar
    // fins que no s'hagi compilat.
    // Concretament, installArtifact fa dues coses:
    // 1. crea el node Install (default)
    // 2. afegieix la dependència entre exer (Step.Compile) i el node Install
    b.installArtifact(exe);
    
    // crea un altre node, en aquest cas un RUN 
    const run_exe: *Build.Step.Run = b.addRunArtifact(exe);
    
    // afegeix el node a dins del graf, amb noms i cognoms. això sortirà al help
    // al fer zig build -h (molt guapo)
    const run_step: *Build.Step = b.step("run", "Run the application");
    // afegeix l'aresta entre dos steps:  
    run_step.dependOn(&run_exe.step);
}

/// matisos sobre lo de dalt:
/// La línia run_step només diu al build system que existeix l'step "zig build run"
/// però no fa executar res. si no crees el run_exe: *Build.Step.Run i no l'associes
/// al run_exe.step, literalment apareixerà `zig build run` però no executarà res.
/// tal com es veu a la funció de sota.
pub fn buildUselessStepRun(b: *Build) void {
    // Crea un node al DAG
    const exe: *Build.Step.Compile = b.addExecutable(.{
        .name = "hello_world",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host,
        }),
    });
    // afegeix la dependencia entre Install (root) i Compile
    // és a dir, aresta entre compile i install, no es pot instalar
    // fins que no s'hagi compilat.
    // Concretament, installArtifact fa dues coses:
    // 1. crea el node Install (default)
    // 2. afegieix la dependència entre exer (Step.Compile) i el node Install
    b.installArtifact(exe);
    
    // crea un altre node, en aquest cas un RUN 
    // const run_exe: *Build.Step.Run = b.addRunArtifact(exe);
    
    // afegeix el node a dins del graf, amb noms i cognoms. això sortirà al help
    // al fer zig build -h (molt guapo)
    _ = b.step("run", "Run the application");
    // afegeix l'aresta entre dos steps:  
    //run_step.dependOn(&run_exe.step);
}

/// obviament, també es pot crear un graf que en comptes de tenir dos
/// camins fins a l'execució, només en tingui un, és a dir,
/// 1. compila
/// 2. executa
/// 3. instal·la
/// es demostra en la següent funció

//pub fn buildStraightGraph(b: *Build) void {
pub fn build(b: *Build) void {
    // Crea un node al DAG
    const exe: *Build.Step.Compile = b.addExecutable(.{
        .name = "hello_world",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host,
        }),
    });
    b.installArtifact(exe);
    
    // crea un altre node, en aquest cas un RUN 
    const run_exe: *Build.Step.Run = b.addRunArtifact(exe);
    // ara hem de fer que, després de compilar, el següent pas sigui executar, no
    // instal·lar (per defecte) i el que farem serà obtenir el pas d'instal·lar de
    // la build, i fer-lo dependre del pas d'executar!
    b.getInstallStep().dependOn(&run_exe.step);
}


