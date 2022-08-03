import esbuild from "esbuild";

esbuild
  .build({
    entryPoints: ["./scripts/entry.js"],
    bundle: true,
    outfile: "public/index.js",
    minify: false,
    sourcemap: true,
    target: ["chrome70", "firefox57", "safari11", "edge18"],
    watch: true,
    logLevel: "info",
  })
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
