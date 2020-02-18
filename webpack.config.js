var process = require("process")

module.exports = {
  target: "webworker",
  entry: "./index.js",
  mode: "production", // CF Worker only works in production mode
  optimization: {
		// We no not want to minimize our code.
		minimize: process.env.NODE_ENV == "production"
  },
  resolve: {
    extensions: ['.js', '.coffee']
  },
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      },
      {
        type: 'javascript/auto',
        test: /\.json$/,
        use: [ 'json-loader' ]
      },
      {
        test: /\.html$/,
        use: [ 'raw-loader' ]
      }
    ]
  }
}