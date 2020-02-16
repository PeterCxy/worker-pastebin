const webpack = require('webpack')
const path = require('path')

module.exports = {
  target: "webworker",
  entry: "./index.js",
  mode: "production",
  optimization: {
		// We no not want to minimize our code.
		minimize: false
  },
  resolve: {
    extensions: ['.js', '.coffee'],
    alias: {
      'blob-shim': path.resolve(__dirname, './blob-shim.js'),
    }
  },
  plugins: [
    new webpack.NormalModuleReplacementPlugin(
      // Rewritten xhr.js to use Fetch API
      // Mostly from <https://github.com/aws/aws-sdk-js/issues/2807>
      // Modified to fix a few bugs
      /node_modules\/aws-sdk\/lib\/http\/xhr.js/,
      '../../../../xhr-shim.js'
    ),
    new webpack.NormalModuleReplacementPlugin(
      // Force it to use node_parser
      // Because we are not actually in browser
      /node_modules\/aws-sdk\/lib\/xml\/browser_parser.js/,
      './node_parser.js'
    ),
    new webpack.ProvidePlugin({
      'Blob': 'blob-shim'
    })
  ],
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      },
      {
        type: 'javascript/auto', // Needed for aws-sdk
        test: /\.json$/,
        use: [ 'json-loader' ]
      }
    ]
  }
}