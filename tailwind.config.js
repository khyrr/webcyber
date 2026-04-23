/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/templates/**/*.html",
    "./app/static/js/**/*.js",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"],
        display: ["Plus Jakarta Sans", "Inter", "ui-sans-serif", "sans-serif"],
        mono: ["JetBrains Mono", "ui-monospace", "SFMono-Regular", "monospace"],
      },
      fontSize: {
        "2xs": ["0.6875rem", { lineHeight: "1rem", letterSpacing: "0.01em" }],
        xs:    ["0.75rem",   { lineHeight: "1.125rem", letterSpacing: "0.01em" }],
        sm:    ["0.8125rem", { lineHeight: "1.25rem", letterSpacing: "0.005em" }],
        base:  ["0.9375rem", { lineHeight: "1.6", letterSpacing: "0" }],
        md:    ["1.0625rem", { lineHeight: "1.55", letterSpacing: "-0.005em" }],
        lg:    ["1.125rem",  { lineHeight: "1.5", letterSpacing: "-0.01em" }],
        xl:    ["1.25rem",   { lineHeight: "1.4", letterSpacing: "-0.015em" }],
        "2xl": ["1.5rem",    { lineHeight: "1.3", letterSpacing: "-0.02em" }],
        "3xl": ["1.875rem",  { lineHeight: "1.25", letterSpacing: "-0.025em" }],
        "4xl": ["2.25rem",   { lineHeight: "1.15", letterSpacing: "-0.03em" }],
      },
      fontWeight: {
        light: "300", normal: "400", medium: "500",
        semibold: "600", bold: "700", extrabold: "800",
      },
      colors: {
        brand: {
          50: "#f0f9fa", 100: "#e6f4f6", 200: "#bcdde3", 300: "#92c7d0",
          400: "#6ab0be", 500: "#4F95A3", 600: "#3e7e8c", 700: "#2F6573",
          800: "#1e4a57", 900: "#0f2d37",
        },
        accent: { 500: "#E08B64", 600: "#c87450" },
        violet: {
          50: "#f0f9fa", 100: "#e6f4f6", 200: "#bcdde3", 300: "#92c7d0",
          400: "#6ab0be", 500: "#4F95A3", 600: "#3e7e8c", 700: "#2F6573",
          800: "#1e4a57", 900: "#0f2d37",
        },
      },
    },
  },
  plugins: [],
};
