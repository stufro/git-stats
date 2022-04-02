require('dotenv').config();
const path = require('path');
const Dotenv = require('dotenv-webpack');

module.exports = {
  entry: {
    app: [
      './assets/index.js'
    ]
  },

  output: {
    path: path.resolve(__dirname + '/dist'),
    filename: '[name].js',
  },

  plugins: [
    new Dotenv()
  ],

  module: {
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      use: {
        loader: 'elm-webpack-loader',
        options: {}
      }
    },
    {
      test: /\.s[ac]ss$/i,
      use: [ "style-loader", "css-loader", "sass-loader", ],
    },
    {
      test: /.html$/,
      use: {
        loader: "file-loader",
        options: {
          name: "[name].html"
        }
      }
    }]
  }
};