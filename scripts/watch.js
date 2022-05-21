import esbuild from 'esbuild';

esbuild.build({
  entryPoints: ['./scripts/entry.js'],
  bundle: true,
  outfile: 'public/index.js',
  minify: false,
  sourcemap: true,
  target: ['chrome70', 'firefox57', 'safari11', 'edge16'],
  watch: true,
  logLevel: 'info',
}).catch(() => process.exit(1))
