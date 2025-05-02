/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.{erb,html}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/assets/stylesheets/**/*.css',
  ],
  darkMode: 'class', // Enable class-based dark mode
  theme: {
    extend: {
      colors: {
        // SupplyFlow Brand Colors
        'primary': {
          DEFAULT: 'var(--primary)',
          'dark': 'var(--primary-dark)',
          'light': 'var(--primary-light)',
        },
        'secondary': {
          DEFAULT: 'var(--secondary)',
          'dark': 'var(--secondary-dark)',
          'light': 'var(--secondary-light)',
        },
        'accent': {
          DEFAULT: 'var(--accent)',
          'dark': 'var(--accent-dark)',
          'light': 'var(--accent-light)',
        },
        
        // Semantic Colors
        'success': {
          DEFAULT: 'var(--success)',
          'light': 'var(--success-light)',
          'dark': 'var(--success-dark)',
        },
        'warning': {
          DEFAULT: 'var(--warning)',
          'light': 'var(--warning-light)',
          'dark': 'var(--warning-dark)',
        },
        'danger': {
          DEFAULT: 'var(--danger)',
          'light': 'var(--danger-light)',
          'dark': 'var(--danger-dark)',
        },
        'info': {
          DEFAULT: 'var(--info)',
          'light': 'var(--info-light)',
          'dark': 'var(--info-dark)',
        },
      },
      animation: {
        'spin-slow': 'spin 20s linear infinite',
        'pulse-ring': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      backgroundImage: {
        'gradient-animated': 'linear-gradient(45deg, var(--primary), var(--secondary), var(--accent), var(--primary))',
        'gradient-sunset': 'linear-gradient(45deg, var(--accent), var(--secondary), var(--primary), var(--accent))',
        'pattern': 'url("data:image/svg+xml,%3Csvg width=\'20\' height=\'20\' viewBox=\'0 0 20 20\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'%23ffffff\' fill-opacity=\'0.05\' fill-rule=\'evenodd\'%3E%3Ccircle cx=\'3\' cy=\'3\' r=\'3\'/%3E%3Ccircle cx=\'13\' cy=\'13\' r=\'3\'/%3E%3C/g%3E%3C/svg%3E")',
      },
      boxShadow: {
        'neon': '0 0 5px rgba(var(--primary-rgb), 0.2), 0 0 20px rgba(var(--primary-rgb), 0.2), 0 0 30px rgba(var(--primary-rgb), 0.2)',
        '3d': '0 10px 30px -10px rgba(0, 0, 0, 0.3), 0 1px 3px rgba(0, 0, 0, 0.1)',
      },
    },
  },
  plugins: [],
}
