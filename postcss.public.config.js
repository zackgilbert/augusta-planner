// PostCSS config for public pages (standalone, no theme dependencies)
module.exports = {
  plugins: [
    require('postcss-import'),
    require('tailwindcss/nesting'),
    require('tailwindcss')('./tailwind.public.config.js'),
    require('autoprefixer'),
  ]
}

