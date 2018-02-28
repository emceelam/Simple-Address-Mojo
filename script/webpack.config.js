const path = require('path');

module.exports = {
  entry: "./src/index.js",
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, '../public')
  },
  module: {
    rules: [
      {
        test: require.resolve('./src/index.js'),
      }
    ]
  },
  mode: 'development',
  devtool: 'inline-source-map',
};