import esbuild from 'esbuild';

esbuild.build({
  entryPoints: ['./scripts/entry.js'],
  bundle: true,
  outfile: 'public/index.js',
  minify: true,
  sourcemap: true,
  target: ['chrome70', 'firefox57', 'safari11', 'edge16'],
  watch: false,
}).catch(() => process.exit(1))
